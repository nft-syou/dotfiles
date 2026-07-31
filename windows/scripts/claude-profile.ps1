#Requires -Version 7.0
<#
    claude-profile.ps1
    Claude デスクトップアプリをプロファイル (--user-data-dir) 別に起動する。

    用法:
        起動              .\claude-profile.ps1 -Name syou
        ショートカット作成  .\claude-profile.ps1 -Name syou -CreateShortcut

    インストールパスにバージョン番号が含まれるため、実行ファイルは
    パッケージファミリ名から都度解決している。アップデートで壊れない。
#>
[CmdletBinding()]
param(
    # プロファイル名。%USERPROFILE%\.claude-instances\<Name> がデータ格納先になる
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$Name,

    # 指定するとデスクトップにショートカットを作成して終了する
    [switch]$CreateShortcut
)

$ErrorActionPreference = 'Stop'

# パッケージファミリ名はバージョン更新でも変化しない
$FamilyName   = 'Claude_pzs8sxrjxfjjc'
$InstanceRoot = Join-Path $env:USERPROFILE '.claude-instances'
$DataDir      = Join-Path $InstanceRoot $Name

function Get-ClaudeExe {
    $pkg = Get-AppxPackage | Where-Object { $_.PackageFamilyName -eq $FamilyName }
    if (-not $pkg) {
        throw "Claude パッケージが見つかりません ($FamilyName)。インストール状態を確認してください。"
    }
    $exe = Join-Path $pkg.InstallLocation 'app\claude.exe'
    if (-not (Test-Path -LiteralPath $exe)) {
        throw "実行ファイルが見つかりません: $exe"
    }
    $exe
}

# --- ショートカット作成モード ---------------------------------------------
if ($CreateShortcut) {
    $exe = Get-ClaudeExe
    New-Item -ItemType Directory -Force -Path $InstanceRoot | Out-Null

    # アイコンは版依存パスを参照させたくないので抽出して固定の場所に置く
    $iconPath = Join-Path $InstanceRoot 'claude.ico'
    try {
        Add-Type -AssemblyName System.Drawing
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exe)
        $fs   = [System.IO.File]::Create($iconPath)
        $icon.Save($fs)
        $fs.Close()
    } catch {
        Write-Warning "アイコンの抽出に失敗しました。既定のアイコンを使用します。"
        $iconPath = $null
    }

    $lnkPath = Join-Path ([Environment]::GetFolderPath('Desktop')) "Claude ($Name).lnk"
    $shell   = New-Object -ComObject WScript.Shell
    $sc      = $shell.CreateShortcut($lnkPath)

    $sc.TargetPath       = (Get-Command pwsh).Source
    $sc.Arguments        = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Name {1}' -f $PSCommandPath, $Name
    $sc.WorkingDirectory = Split-Path -Parent $PSCommandPath
    $sc.Description      = "Claude Desktop - $Name プロファイル"
    $sc.WindowStyle      = 7   # 最小化
    if ($iconPath) { $sc.IconLocation = "$iconPath,0" }
    $sc.Save()

    Write-Host "作成しました: $lnkPath"
    Write-Host "データ格納先: $DataDir"
    return
}

# --- 起動モード -------------------------------------------------------------
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
$exe = Get-ClaudeExe
Start-Process -FilePath $exe -ArgumentList "--user-data-dir=`"$DataDir`""
