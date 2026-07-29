# Winget フォルダ新設によるインストール系集約 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** mac の `mac/brew/`(スクリプト + パッケージ一覧)と同じ構成の `windows/winget/` を新設し、winget によるインストール処理を `windows/volta/install-volta.ps1` から移して集約する。

**Architecture:** `winget/packages.txt`(1行1パッケージID、`#` コメント・空行可)を `winget/install-winget.ps1` が読み込み、未導入のものだけ `winget install` する冪等スクリプト。既存の `volta/install-volta.ps1` は winget 処理を削り `volta install node` の後処理専用に縮小する。

**Tech Stack:** PowerShell 5.1+(既存スクリプトの慣例: コメントベースヘルプ、`$ErrorActionPreference = 'Stop'`)

**Spec:** `docs/superpowers/specs/2026-07-24-winget-folder-design.md`

## Global Constraints

- スクリプトは `#Requires -Version 5.1` で始め、コメントベースヘルプ(.SYNOPSIS / .DESCRIPTION / .EXAMPLE)を付ける(既存 `windows/*.ps1` の慣例)
- `$ErrorActionPreference = 'Stop'` を設定する
- メッセージ・コメントは既存スクリプトに合わせ日本語主体
- 開発マシンは macOS のため Windows 実機での実行確認は行わない。検証は `pwsh` によるパースチェック(利用可能な場合)と目視確認で代替する
- packages.txt の初期内容は `Volta.Volta` のみ(挙動を変えない移行)

---

### Task 1: winget/packages.txt と winget/install-winget.ps1 の新設

**Files:**
- Create: `windows/winget/packages.txt`
- Create: `windows/winget/install-winget.ps1`

**Interfaces:**
- Consumes: なし
- Produces: `windows/winget/install-winget.ps1`(引数なしで実行。packages.txt の全パッケージを冪等にインストール)。Task 2 の install-volta.ps1 がエラーメッセージ内でこのパスを案内する。

- [ ] **Step 1: packages.txt を作成**

`windows/winget/packages.txt`:

```
# winget パッケージ一覧 (Brewfile 相当)
# 1行1パッケージID。"#" 始まりの行と空行は無視されます。
# ID は `winget search <名前>` で確認できます。

# --- 開発ツール ---
Volta.Volta
```

- [ ] **Step 2: install-winget.ps1 を作成**

`windows/winget/install-winget.ps1`:

```powershell
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
```

- [ ] **Step 3: 構文チェック**

`pwsh` が利用可能なら実行:

```bash
pwsh -NoProfile -Command '$t = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw "windows/winget/install-winget.ps1"), [ref]$null); "OK"'
```

Expected: `OK`(パースエラーなし)。`pwsh` がなければ目視確認で代替し、その旨を報告する。

- [ ] **Step 4: コミット**

```bash
git add windows/winget/packages.txt windows/winget/install-winget.ps1
git commit -m "windows/winget を新設し packages.txt による一括インストールを追加"
```

---

### Task 2: volta/install-volta.ps1 の縮小

**Files:**
- Modify: `windows/volta/install-volta.ps1`(全面書き換え)

**Interfaces:**
- Consumes: Task 1 の `windows/winget/install-winget.ps1`(エラーメッセージ内で実行を案内)
- Produces: `windows/volta/install-volta.ps1`(引数なしで実行。Volta 導入済みが前提で `volta install node` を行う)

- [ ] **Step 1: install-volta.ps1 を書き換え**

`windows/volta/install-volta.ps1` の全内容を以下に置き換える:

```powershell
#Requires -Version 5.1
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
  powershell -ExecutionPolicy Bypass -File .\windows\volta\install-volta.ps1
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
```

- [ ] **Step 2: 構文チェック**

`pwsh` が利用可能なら実行:

```bash
pwsh -NoProfile -Command '$t = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw "windows/volta/install-volta.ps1"), [ref]$null); "OK"'
```

Expected: `OK`(パースエラーなし)。`pwsh` がなければ目視確認で代替し、その旨を報告する。

- [ ] **Step 3: winget 処理が残っていないことを確認**

```bash
grep -n "winget install" windows/volta/install-volta.ps1
```

Expected: ヒットなし(exit code 1)。`winget` への言及は案内メッセージとヘルプコメントのみであること。

- [ ] **Step 4: コミット**

```bash
git add windows/volta/install-volta.ps1
git commit -m "install-volta.ps1 を volta install node の後処理専用に縮小"
```

---

### Task 3: windows/README.md の更新

**Files:**
- Modify: `windows/README.md`(全面書き換え)

**Interfaces:**
- Consumes: Task 1・Task 2 のスクリプトパスと役割
- Produces: なし(ドキュメントのみ)

- [ ] **Step 1: README.md を書き換え**

`windows/README.md` の全内容を以下に置き換える:

````markdown
# Windows Dotfiles

Windows 用のセットアップスクリプト。

```
windows/
├── README.md
├── install.ps1              # Claude Code 設定のシンボリックリンク作成
├── winget/
│   ├── install-winget.ps1   # packages.txt のパッケージを一括インストール
│   └── packages.txt         # winget パッケージ ID 一覧 (Brewfile 相当)
└── volta/
    └── install-volta.ps1    # Volta 経由で Node.js (LTS) をセットアップ
```

## 前提

シンボリックリンクの作成には、次のいずれかが必要です。

- **開発者モード**を有効化（推奨）
  設定 > プライバシーとセキュリティ > 開発者向け > 開発者モード をオン
- または PowerShell を**管理者として実行**

## セットアップ

### 1. winget パッケージの一括インストール

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\winget\install-winget.ps1
```

[packages.txt](winget/packages.txt) に列挙したパッケージ（Volta など）を winget で
インストールします。導入済みのものはスキップされるため、何度実行しても安全です。

パッケージを追加するときは `packages.txt` に ID を1行追記して再実行します
（ID は `winget search <名前>` で確認）。

### 2. Node.js のセットアップ（Volta 経由）

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\volta\install-volta.ps1
```

Volta 経由で Node.js (LTS) と npm をセットアップします。
Context7 プラグイン（npx 経由の MCP サーバー）の動作にも必要です。

### 3. 設定ファイルのリンク（Git / Claude Code）

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
```

以下がリンクされます（既存ファイルは `.backup` で退避）。

- Git（OS 共通 / [common/git](../common/git/)）:
  - `%USERPROFILE%\.gitconfig`
  - `%USERPROFILE%\.gitignore_global`
- Claude Code（OS 共通 / [common/claude](../common/claude/)）:
  - `%USERPROFILE%\.claude\settings.json`
  - `%USERPROFILE%\.claude\CLAUDE.md`
  - `%USERPROFILE%\.claude\skills`
  - `%USERPROFILE%\.claude\commands`
  - `%USERPROFILE%\.claude\agents`

## 確認

```powershell
Get-Item $env:USERPROFILE\.claude\settings.json | Select-Object LinkType, Target
```

`LinkType` が `SymbolicLink` になっていれば成功です。

## 今後の拡張

VSCode / Git など Windows 固有の設定は、このディレクトリに追加していく想定です。
OS 共通のものは [common/](../common/) に置いて両 OS のスクリプトから参照します。
インストールするアプリの追加は [winget/packages.txt](winget/packages.txt) に追記します。
````

- [ ] **Step 2: 構成図と実ファイルの整合確認**

```bash
ls windows/ windows/winget/ windows/volta/
```

Expected: README の構成図どおりに `install.ps1` / `winget/install-winget.ps1` / `winget/packages.txt` / `volta/install-volta.ps1` が存在する。

- [ ] **Step 3: コミット**

```bash
git add windows/README.md
git commit -m "windows/README を winget フォルダ構成に合わせて更新"
```
