#Requires -Version 5.1
<#
.SYNOPSIS
  winget で Volta をインストールし、Volta 経由で Node.js (LTS) をセットアップ

.DESCRIPTION
  1. winget の存在確認
  2. Volta のインストール (winget)
  3. 現在のセッションに PATH を反映
  4. volta install node で Node.js LTS + npm をインストール

  Context7 プラグイン (npx 経由の MCP サーバー) の動作にも Node.js が必要です。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\windows\volta\install-volta.ps1
#>

$ErrorActionPreference = 'Stop'

Write-Host "== Installing Volta + Node.js =="

# 1. winget の存在確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget が見つかりません。Microsoft Store から「アプリ インストーラー」を導入してください。"
  exit 1
}

# 2. Volta のインストール
if (Get-Command volta -ErrorAction SilentlyContinue) {
  Write-Host "Volta is already installed: $(volta --version)"
} else {
  Write-Host "Installing Volta via winget..."
  winget install --id Volta.Volta --exact --accept-source-agreements --accept-package-agreements
}

# 3. 現在のセッションに PATH を反映 (winget が更新するのは環境変数のみで、
#    実行中のセッションには反映されないため)
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath    = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path    = "$machinePath;$userPath"

if (-not (Get-Command volta -ErrorAction SilentlyContinue)) {
  Write-Error "volta コマンドが見つかりません。ターミナルを開き直してから再実行してください。"
  exit 1
}

# 4. Node.js (LTS) のインストール
Write-Host "Installing Node.js (LTS) via Volta..."
volta install node

# 確認
Write-Host ""
Write-Host "✓ Setup complete!"
Write-Host "  volta : $(volta --version)"
Write-Host "  node  : $(node --version)"
Write-Host "  npm   : $(npm --version)"
