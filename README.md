# Dotfiles

個人用の開発環境設定ファイル管理リポジトリ

## サポート環境

| OS | 状態 | ドキュメント |
|---|---|---|
| macOS | ✅ 対応済み | [mac/README.md](./mac/README.md) |
| Windows | 🚧 部分対応 (winget / Volta / Claude Code / PowerShell プロファイル) | [windows/README.md](./windows/README.md) |

OS 共通の設定（Claude Code など）は [common/](./common/) に集約し、各 OS のセットアップ
スクリプトから参照・リンクします。

## クイックスタート

### macOS

```bash
# 1. Homebrew とパッケージのインストール
./mac/brew/install-brew.sh

# 2. dotfiles のシンボリックリンク作成
./mac/install.sh

# 3. シェルの再読み込み
source ~/.zshrc
```

詳細は [mac/README.md](./mac/README.md) を参照してください。

## リポジトリ構成

```
dotfiles/
├── README.md           # このファイル
├── common/             # OS共通設定
│   ├── claude/         # Claude Code (settings/skills/commands/agents/CLAUDE.md)
│   └── git/            # Git設定 (.gitconfig / .gitignore_global)
├── mac/                # macOS用設定
│   ├── README.md       # macOS詳細ドキュメント
│   ├── install.sh      # セットアップスクリプト
│   ├── brew/           # Homebrew設定
│   ├── claude/         # Claude Code インストールスクリプト
│   ├── kitty/          # Kittyターミナル設定
│   ├── shell/          # シェル関数
│   ├── vscode/         # VSCode設定
│   └── zsh/            # Zsh設定
└── windows/            # Windows用設定
    ├── README.md       # Windows詳細ドキュメント
    ├── bootstrap.ps1   # 一括セットアップ (pwsh 導入 → 全スクリプト実行)
    ├── install.ps1     # シンボリックリンク作成 (Git / Claude Code / PowerShell プロファイル)
    ├── winget/         # winget パッケージ一括インストール
    ├── volta/          # Volta + Node.js インストールスクリプト
    ├── powershell/     # PowerShell 7 プロファイル ($PROFILE)
    └── scripts/        # ユーティリティ (claude-profile.ps1)
```

## 含まれる設定

### OS 共通 (common/)

- **Claude Code**: settings.json（プラグイン宣言）、CLAUDE.md、skills / commands / agents
  - 詳細は [common/claude/README.md](./common/claude/README.md) を参照してください。
- **Git**: LFS対応、グローバルignore（macOS / Windows 両対応）

### macOS

- **Zsh**: 補完、Volta (Node.js)、カスタム関数
- **Kitty**: ターミナル設定
- **VSCode**: Copilot、GitLens、日本語化
- **Shell Functions**: sencha (Docker + Colima)

詳細は [mac/README.md](./mac/README.md) を参照してください。

## 貢献

個人用リポジトリですが、アイデアや改善案は歓迎します。

## ライセンス

個人用設定ファイル
