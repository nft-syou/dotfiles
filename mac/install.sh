#!/bin/bash

set -e

MAC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$MAC_DIR/.." && pwd)"
COMMON_DIR="$REPO_ROOT/common"

echo "Setting up macOS dotfiles from $MAC_DIR"

# Create necessary directories
mkdir -p ~/.config/shell
mkdir -p ~/.config/kitty
mkdir -p ~/.zsh/completions

# Function to create symlink with backup
link_file() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    echo "  Removing existing symlink: $dest"
    rm "$dest"
  elif [ -f "$dest" ] || [ -d "$dest" ]; then
    echo "  Backing up existing file: $dest -> ${dest}.backup"
    mv "$dest" "${dest}.backup"
  fi

  echo "  Linking: $dest -> $src"
  ln -s "$src" "$dest"
}

# Zsh
echo "Setting up Zsh..."
link_file "$MAC_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Git (OS 共通 / common/git)
echo "Setting up Git..."
link_file "$COMMON_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$COMMON_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Shell functions
echo "Setting up Shell functions..."
link_file "$MAC_DIR/shell/functions.sh" "$HOME/.config/shell/functions.sh"

# Kitty
echo "Setting up Kitty..."
link_file "$MAC_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Tmux
echo "Setting up Tmux..."
link_file "$MAC_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# VSCode (macOS specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Setting up VSCode..."
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
  mkdir -p "$VSCODE_USER_DIR"
  link_file "$MAC_DIR/vscode/setting.jsonc" "$VSCODE_USER_DIR/settings.json"
fi

# Claude Code (OS 共通 / common/claude)
echo "Setting up Claude Code..."
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"
link_file "$COMMON_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
link_file "$COMMON_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
link_file "$COMMON_DIR/claude/skills" "$CLAUDE_DIR/skills"
link_file "$COMMON_DIR/claude/commands" "$CLAUDE_DIR/commands"
link_file "$COMMON_DIR/claude/agents" "$CLAUDE_DIR/agents"

# git clean フィルタ: Orca が settings.json に注入する hooks/statusLine をコミットから外す (.gitattributes 参照)
echo "Registering git clean filter for common/claude/settings.json..."
git -C "$REPO_ROOT" config filter.claude-settings.clean 'node common/claude/strip-orca.mjs'
git -C "$REPO_ROOT" config filter.claude-settings.required true

echo ""
echo "✓ Dotfiles setup complete!"
echo ""
echo "Note: If you had existing files, they were backed up with .backup extension"
echo "Please restart your terminal or run: source ~/.zshrc"
