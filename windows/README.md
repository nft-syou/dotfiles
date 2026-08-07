# Windows Dotfiles

Windows 用のセットアップスクリプト。

```
windows/
├── README.md
├── bootstrap.ps1            # 一括セットアップ (pwsh 導入 → 全スクリプト実行)
├── install.ps1              # Claude Code 設定のシンボリックリンク作成
├── winget/
│   ├── install-winget.ps1   # packages.txt のパッケージを一括インストール
│   └── packages.txt         # winget パッケージ ID 一覧 (Brewfile 相当)
├── volta/
│   └── install-volta.ps1    # Volta 経由で Node.js (LTS) をセットアップ
├── powershell/
│   └── profile.ps1          # pwsh 7 プロファイル本体 ($PROFILE スタブから読み込まれる)
└── scripts/
    └── claude-profile.ps1   # Claude Desktop をプロファイル別に起動
```

## 前提

シンボリックリンクの作成には、次のいずれかが必要です。

- **開発者モード**を有効化（推奨）
  設定 > プライバシーとセキュリティ > 開発者向け > 開発者モード をオン
- または PowerShell を**管理者として実行**

## セットアップ（一括）

まっさらなマシンではこれ1本で完了します（プリインストールの Windows PowerShell 5.1 で動作）。
PowerShell 7 (`pwsh`) が未導入なら winget で自動インストールし、以降のスクリプトを pwsh で実行します。

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\bootstrap.ps1
```

## 個別セットアップ

各ステップを個別に実行する場合。`bootstrap.ps1` 以外のスクリプトは PowerShell 7 (`pwsh`) 専用です。

### 1. winget パッケージの一括インストール

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\winget\install-winget.ps1
```

[packages.txt](winget/packages.txt) に列挙したパッケージ（Volta など）を winget で
インストールします。導入済みのものはスキップされるため、何度実行しても安全です。

パッケージを追加するときは `packages.txt` に ID を1行追記して再実行します
（ID は `winget search <名前>` で確認）。

### 2. Node.js のセットアップ（Volta 経由）

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\volta\install-volta.ps1
```

Volta 経由で Node.js (LTS) と npm をセットアップします。
Context7 プラグイン（npx 経由の MCP サーバー）の動作にも必要です。

### 3. 設定ファイルのリンク（Git / Claude Code）

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\install.ps1
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
- ユーティリティスクリプト（Windows 固有 / [scripts](scripts/)）:
  - `%USERPROFILE%\Scripts\claude-profile.ps1`（Claude Desktop のプロファイル別起動）
- PowerShell 7 プロファイル（Windows 固有 / [powershell](powershell/)）:
  - `$PROFILE`（`Documents\PowerShell\Microsoft.PowerShell_profile.ps1`）は**マシンローカルのスタブ**として
    生成され、[powershell/profile.ps1](powershell/profile.ps1) を dot-source します。
    インストーラ類（safe-chain 等）による環境依存の追記はスタブ側に残り、リポジトリには入りません。

### 4. Safe Chain（npm マルウェア対策）

[Aikido Safe Chain](https://github.com/AikidoSec/safe-chain) で npm / npx / yarn / pnpm 等の
パッケージ取得をマルウェアスキャン経由にします。
[公式 README](https://github.com/AikidoSec/safe-chain#readme) の Windows 用ワンライナー
（SHA256 検証付き・スタンドアロンバイナリを `~\.safe-chain\` に設置）を実行してください。

- インストーラが `$PROFILE`（マシンローカルのスタブ）へ統合行を追記します。
  追記行はスタブ側に残るため、リポジトリが環境依存のパスで汚れることはありません。
- **Volta と共存可能**: コマンドはシェル関数でラップされ、実体は PATH 上の Volta シム
  経由で実行されます。旧来の `npm install -g @aikidosec/safe-chain` 方式は Volta の
  シムと衝突する（[#283](https://github.com/AikidoSec/safe-chain/issues/283)）ため使わないこと。
- 動作確認: `npm safe-chain-verify` が成功し、`npm install safe-chain-test` がブロックされれば OK。

## 確認

```powershell
Get-Item $env:USERPROFILE\.claude\settings.json | Select-Object LinkType, Target
```

`LinkType` が `SymbolicLink` になっていれば成功です。

## 今後の拡張

VSCode / Git など Windows 固有の設定は、このディレクトリに追加していく想定です。
OS 共通のものは [common/](../common/) に置いて両 OS のスクリプトから参照します。
インストールするアプリの追加は [winget/packages.txt](winget/packages.txt) に追記します。
