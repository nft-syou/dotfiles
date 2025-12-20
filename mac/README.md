# macOS Dotfiles

macOS用の開発環境設定ファイルとセットアップスクリプト

## 構成

```
mac/
├── brew/
│   ├── Brewfile        # Homebrew パッケージ定義
│   └── install-brew.sh # Homebrew セットアップスクリプト
├── claude/
│   └── install-claude-code.sh
├── docker/
│   └── init-docker-compose.sh
├── git/
│   ├── .gitconfig      # Git 設定
│   └── .gitignore_global
├── install.sh          # シンボリックリンク作成スクリプト
├── kitty/
│   └── kitty.conf      # Kitty ターミナル設定
├── shell/
│   └── functions.sh    # シェル関数（sencha等）
├── vscode/
│   └── setting.jsonc   # VSCode 設定
└── zsh/
    └── .zshrc          # Zsh 設定
```

## セットアップ手順

### 1. Homebrew のインストール

```bash
./mac/brew/install-brew.sh
```

以下のツールがインストールされます:
- **CLI ツール**: awscli, colima, docker, docker-compose, gh, git, volta
- **アプリケーション**: 1Password, Brave Browser, Kitty, Postman, Rocket.Chat, Tailscale, Thunderbird, VSCode
- **VSCode 拡張機能**: GitLens, Copilot, Prettier, 日本語パック等

### 2. dotfiles のシンボリックリンク作成

```bash
./mac/install.sh
```

以下のファイルにシンボリックリンクが作成されます:
- `~/.zshrc`
- `~/.gitconfig`
- `~/.gitignore_global`
- `~/.config/shell/functions.sh`
- `~/.config/kitty/kitty.conf`
- `~/Library/Application Support/Code/User/settings.json`

既存のファイルは `.backup` 拡張子で自動的にバックアップされます。

### 3. Docker Compose プラグインのセットアップ

```bash
source ./mac/docker/init-docker-compose.sh
```

### 4. Claude Code のインストール（オプション）

```bash
./mac/claude/install-claude-code.sh
```

### 5. シェルの再読み込み

```bash
source ~/.zshrc
```

または、ターミナルを再起動してください。

## 主な機能

### Zsh

- 補完機能の有効化（zsh-completions）
- AWS CLI の補完
- Volta (Node.js バージョン管理)
- カスタムシェル関数の読み込み

### Git

- デフォルトブランチ: `main`
- Git LFS 対応
- グローバル `.gitignore` 設定
- 自動プルーン有効化

### Shell Functions

#### sencha()

Sencha Cmd を Docker + Colima で実行するラッパー関数

**特徴:**
- Colima (vz + Rosetta) の自動起動/停止
- Java ヒープサイズの最適化 (Xmx8192m)
- linux/amd64 エミュレーション対応
- 終了時の自動クリーンアップ

**使用例:**
```bash
sencha app build
```

### Kitty Terminal

- フォントサイズ: 13.5pt
- スクロールバック: 15000行
- タブバー: powerline スタイル（上部配置）
- macOS フルスクリーンモード対応

### VSCode

- Git 自動フェッチ、スマートコミット有効化
- エディタ: タブサイズ2、自動フォーマット
- GitLens AI コミットメッセージ生成（日本語）
- GitHub Copilot 統合
- 全角スペース可視化
- インデントレインボー

## 更新

dotfilesリポジトリを更新した場合:

```bash
cd ~/Documents/git/dotfiles  # またはdotfilesのパス
git pull
./mac/install.sh  # シンボリックリンクの再作成
source ~/.zshrc
```

## トラブルシューティング

### シンボリックリンクが正しく作成されているか確認

```bash
ls -la ~/.zshrc
ls -la ~/.gitconfig
```

### Homebrew のパスが通っているか確認

```bash
which brew
brew --version
```

### Volta が正しくインストールされているか確認

```bash
volta --version
node --version
```
