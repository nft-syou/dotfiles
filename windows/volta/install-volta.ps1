#Requires -Version 7.0
<#
.SYNOPSIS
  Volta 経由で Node.js (LTS) をセットアップ

.DESCRIPTION
  1. 現在のセッションに PATH を反映
  2. volta コマンドの存在確認 (未導入なら winget\install-winget.ps1 の実行を案内)
  3. volta install node で Node.js LTS + npm をインストール

  Volta 本体のインストールは windows\winget\install-winget.ps1 (packages.txt) が担当します。
  Context7 プラグイン (npx 経由の MCP サーバー) の動作にも Node.js が必要です。

.EXAMPLE
  pwsh -ExecutionPolicy Bypass -File .\windows\volta\install-volta.ps1
#>

$ErrorActionPreference = 'Stop'

Write-Host "== Installing Node.js via Volta =="

# 1. 現在のセッションに PATH を反映 (winget が更新するのは環境変数のみで、
#    実行中のセッションには反映されないため)
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath    = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path    = "$machinePath;$userPath"

# 2. volta コマンドの存在確認
if (-not (Get-Command volta -ErrorAction SilentlyContinue)) {
  Write-Error "volta コマンドが見つかりません。先に .\windows\winget\install-winget.ps1 を実行してください。"
  exit 1
}

# 3. Node.js (LTS) のインストール
Write-Host "Installing Node.js (LTS) via Volta..."
volta install node

# 確認
Write-Host ""
Write-Host "✓ Setup complete!"
Write-Host "  volta : $(volta --version)"
Write-Host "  node  : $(node --version)"
Write-Host "  npm   : $(npm --version)"
