#Requires -Version 7.0
<#
.SYNOPSIS
  Windows 用 dotfiles セットアップ (OS 共通の Claude Code 設定をシンボリックリンク)

.DESCRIPTION
  common/claude 配下の設定を %USERPROFILE%\.claude にシンボリックリンクします。
  シンボリックリンク作成には「開発者モード」の有効化、または管理者権限が必要です。
  (設定 > プライバシーとセキュリティ > 開発者向け > 開発者モード)

.EXAMPLE
  pwsh -ExecutionPolicy Bypass -File .\windows\install.ps1
#>

$ErrorActionPreference = 'Stop'

$WindowsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot   = Split-Path -Parent $WindowsDir
$CommonDir  = Join-Path $RepoRoot 'common'

Write-Host "Setting up Windows dotfiles from $RepoRoot"

function Test-SymlinkCapability {
  # 開発者モード または 管理者権限の確認
  $devMode = $false
  try {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    $devMode = ((Get-ItemProperty -Path $key -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1)
  } catch {}

  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if (-not $devMode -and -not $isAdmin) {
    Write-Warning "シンボリックリンクの作成には開発者モードまたは管理者権限が必要です。"
    Write-Warning "開発者モードを有効化するか、管理者として PowerShell を再実行してください。"
  }
}

function Link-File {
  param(
    [Parameter(Mandatory)] [string] $Source,
    [Parameter(Mandatory)] [string] $Dest
  )

  $item = Get-Item -LiteralPath $Dest -ErrorAction SilentlyContinue
  if ($null -ne $item) {
    if ($item.LinkType -eq 'SymbolicLink') {
      Write-Host "  Removing existing symlink: $Dest"
      Remove-Item -LiteralPath $Dest -Force -Recurse
    } else {
      $backup = "$Dest.backup"
      Write-Host "  Backing up existing file: $Dest -> $backup"
      Move-Item -LiteralPath $Dest -Destination $backup -Force
    }
  }

  Write-Host "  Linking: $Dest -> $Source"
  New-Item -ItemType SymbolicLink -Path $Dest -Target $Source -Force | Out-Null
}

Test-SymlinkCapability

# Git (OS 共通 / common/git)
Write-Host "Setting up Git..."
$GitCommon = Join-Path $CommonDir 'git'
Link-File (Join-Path $GitCommon '.gitconfig')        (Join-Path $env:USERPROFILE '.gitconfig')
Link-File (Join-Path $GitCommon '.gitignore_global') (Join-Path $env:USERPROFILE '.gitignore_global')

# Claude Code (OS 共通 / common/claude)
Write-Host "Setting up Claude Code..."
$ClaudeDir = Join-Path $env:USERPROFILE '.claude'
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null

$ClaudeCommon = Join-Path $CommonDir 'claude'
Link-File (Join-Path $ClaudeCommon 'settings.json') (Join-Path $ClaudeDir 'settings.json')
Link-File (Join-Path $ClaudeCommon 'CLAUDE.md')      (Join-Path $ClaudeDir 'CLAUDE.md')
Link-File (Join-Path $ClaudeCommon 'skills')         (Join-Path $ClaudeDir 'skills')
Link-File (Join-Path $ClaudeCommon 'commands')       (Join-Path $ClaudeDir 'commands')
Link-File (Join-Path $ClaudeCommon 'agents')         (Join-Path $ClaudeDir 'agents')

# ユーティリティスクリプト (Windows 固有 / windows/scripts)
Write-Host "Setting up Scripts..."
$ScriptsDir = Join-Path $env:USERPROFILE 'Scripts'
New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
Link-File (Join-Path $WindowsDir 'scripts\claude-profile.ps1') (Join-Path $ScriptsDir 'claude-profile.ps1')

# PowerShell 7 プロファイル (Windows 固有 / windows/powershell)
# $PROFILE 実体はシンボリックリンクではなくマシンローカルのスタブにする。
# safe-chain 等のインストーラは $PROFILE に絶対パスの行を追記するため、リンクにすると
# 環境依存の行がリポジトリに混入してしまう。スタブで受けて repo 側プロファイルを dot-source する。
Write-Host "Setting up PowerShell profile..."
# pwsh 7 の $PROFILE は MyDocuments 配下 (フォルダリダイレクト環境も考慮し GetFolderPath で解決)
$PwshProfileDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'
New-Item -ItemType Directory -Path $PwshProfileDir -Force | Out-Null
$PwshProfilePath = Join-Path $PwshProfileDir 'Microsoft.PowerShell_profile.ps1'
$RepoProfile     = Join-Path $WindowsDir 'powershell\profile.ps1'
$ProfileMarker   = '# dotfiles-managed profile'
$SourceLine      = "if (Test-Path `"$RepoProfile`") { . `"$RepoProfile`" } $ProfileMarker"

# 旧方式 (シンボリックリンク) からの移行: リンクなら外してスタブを作り直す
$existing = Get-Item -LiteralPath $PwshProfilePath -ErrorAction SilentlyContinue
if ($null -ne $existing -and $existing.LinkType -eq 'SymbolicLink') {
  Write-Host "  Removing legacy symlink: $PwshProfilePath"
  Remove-Item -LiteralPath $PwshProfilePath -Force
}

# マーカー行を毎回貼り直す (repo パス変更に追従)。インストーラ追記行などはそのまま保持
$stubLines = @()
if (Test-Path -LiteralPath $PwshProfilePath) {
  $stubLines = @(Get-Content -LiteralPath $PwshProfilePath | Where-Object { $_ -notlike "*$ProfileMarker*" })
}
Write-Host "  Ensuring stub sources: $RepoProfile"
Set-Content -LiteralPath $PwshProfilePath -Value ($stubLines + $SourceLine)

Write-Host ""
Write-Host "✓ Dotfiles setup complete!"
Write-Host ""
Write-Host "Note: 既存ファイルがあった場合は .backup 拡張子で退避されています。"
