# Windows Dotfiles

Windows 用のセットアップスクリプト。

```
windows/
├── README.md
├── install.ps1              # Claude Code 設定のシンボリックリンク作成
└── volta/
    └── install-volta.ps1    # Volta + Node.js (LTS) のインストール
```

## 前提

シンボリックリンクの作成には、次のいずれかが必要です。

- **開発者モード**を有効化（推奨）
  設定 > プライバシーとセキュリティ > 開発者向け > 開発者モード をオン
- または PowerShell を**管理者として実行**

## セットアップ

### 1. Volta + Node.js のインストール

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\volta\install-volta.ps1
```

winget で [Volta](https://volta.sh/) をインストールし、Volta 経由で Node.js (LTS) と npm を
セットアップします。Context7 プラグイン（npx 経由の MCP サーバー）の動作にも必要です。

### 2. 設定ファイルのリンク（Git / Claude Code）

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
