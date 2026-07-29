#Requires -Version 5.1
<#
.SYNOPSIS
  packages.txt に列挙した winget パッケージを一括インストール (brew bundle 相当)

.DESCRIPTION
  同じディレクトリの packages.txt を読み込み、各パッケージ ID について
  未導入であれば winget でインストールします。導入済みのものはスキップするため、
  何度実行しても安全です (冪等)。

  packages.txt は 1 行 1 パッケージ ID。"#" 始まりの行と空行は無視されます。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\windows\winget\install-winget.ps1
#>

$ErrorActionPreference = 'Stop'

Write-Host "== Winget setup =="

# winget の存在確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget が見つかりません。Microsoft Store から「アプリ インストーラー」を導入してください。"
  exit 1
}

# packages.txt の読み込み (コメント・空行を除去)
$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackagesFile = Join-Path $ScriptDir 'packages.txt'

if (-not (Test-Path -LiteralPath $PackagesFile)) {
  Write-Error "packages.txt が見つかりません: $PackagesFile"
  exit 1
}

$Packages = Get-Content -LiteralPath $PackagesFile |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ -ne '' -and -not $_.StartsWith('#') }

if ($Packages.Count -eq 0) {
  Write-Host "packages.txt にパッケージがありません。"
  exit 0
}

# 各パッケージを冪等にインストール
foreach ($Id in $Packages) {
  winget list --id $Id --exact --accept-source-agreements *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Host "  Skip (installed): $Id"
  } else {
    Write-Host "  Installing: $Id"
    winget install --id $Id --exact --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
      Write-Error "インストールに失敗しました: $Id"
      exit 1
    }
  }
}

Write-Host ""
Write-Host "✓ Winget setup complete!"
