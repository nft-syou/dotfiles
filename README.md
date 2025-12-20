# Dotfiles

個人用の開発環境設定ファイル管理リポジトリ

## サポート環境

| OS | 状態 | ドキュメント |
|---|---|---|
| macOS | ✅ 対応済み | [mac/README.md](./mac/README.md) |
| Windows | 🚧 未対応 | - |

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
└── mac/                # macOS用設定
    ├── README.md       # macOS詳細ドキュメント
    ├── install.sh      # セットアップスクリプト
    ├── brew/           # Homebrew設定
    ├── git/            # Git設定
    ├── kitty/          # Kittyターミナル設定
    ├── shell/          # シェル関数
    ├── vscode/         # VSCode設定
    └── zsh/            # Zsh設定
```

## 含まれる設定

### macOS

- **Zsh**: 補完、Volta (Node.js)、カスタム関数
- **Git**: LFS対応、グローバルignore
- **Kitty**: ターミナル設定
- **VSCode**: Copilot、GitLens、日本語化
- **Shell Functions**: sencha (Docker + Colima)

詳細は [mac/README.md](./mac/README.md) を参照してください。

## 貢献

個人用リポジトリですが、アイデアや改善案は歓迎します。

## ライセンス

個人用設定ファイル
