#Requires -Version 5.1
<#
.SYNOPSIS
  One-shot bootstrap: installs PowerShell 7 (if needed) and runs the full setup.

.DESCRIPTION
  Runs on Windows PowerShell 5.1 (preinstalled on Windows), so this is the only
  entry point that works on a fresh machine. It installs PowerShell 7 via winget
  when missing, then runs the remaining setup scripts with pwsh:

    1. winget\install-winget.ps1  (winget packages, incl. Volta)
    2. volta\install-volta.ps1    (Node.js LTS via Volta)
    3. install.ps1                (symlink Git / Claude Code configs)

  NOTE: Keep this file ASCII-only. Windows PowerShell 5.1 misreads BOM-less
  UTF-8 as ANSI, so non-ASCII text here would be garbled. All other scripts
  are pwsh-only and may contain Japanese.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\windows\bootstrap.ps1
#>

$ErrorActionPreference = 'Stop'

$WindowsDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "== Bootstrap =="

# 1. winget check
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget not found. Install 'App Installer' from the Microsoft Store first."
  exit 1
}

# 2. Install PowerShell 7 if missing
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
  Write-Host "Installing PowerShell 7 via winget..."
  winget install --id Microsoft.PowerShell --exact --accept-source-agreements --accept-package-agreements
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install PowerShell 7 (winget exit code: $LASTEXITCODE)."
    exit 1
  }

  # Refresh PATH for the current session (winget only updates the registry)
  $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $userPath    = [Environment]::GetEnvironmentVariable('Path', 'User')
  $env:Path    = "$machinePath;$userPath"
}

if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
  Write-Error "pwsh still not found on PATH. Open a new terminal and re-run this script."
  exit 1
}

Write-Host "pwsh version: $(pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()')"

# 3. Run setup scripts with pwsh
$steps = @(
  (Join-Path $WindowsDir 'winget\install-winget.ps1'),
  (Join-Path $WindowsDir 'volta\install-volta.ps1'),
  (Join-Path $WindowsDir 'install.ps1')
)

foreach ($step in $steps) {
  Write-Host ""
  Write-Host "== Running: $step =="
  pwsh -ExecutionPolicy Bypass -File $step
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Step failed: $step"
    exit 1
  }
}

Write-Host ""
Write-Host "Bootstrap complete."
