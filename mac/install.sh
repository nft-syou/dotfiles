#!/bin/bash

set -e

MAC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Git
echo "Setting up Git..."
link_file "$MAC_DIR/git/.gitconfig" "$HOME/.gitconfig"
link_file "$MAC_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Shell functions
echo "Setting up Shell functions..."
link_file "$MAC_DIR/shell/functions.sh" "$HOME/.config/shell/functions.sh"

# Kitty
echo "Setting up Kitty..."
link_file "$MAC_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# VSCode (macOS specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Setting up VSCode..."
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
  mkdir -p "$VSCODE_USER_DIR"
  link_file "$MAC_DIR/vscode/setting.jsonc" "$VSCODE_USER_DIR/settings.json"
fi

echo ""
echo "✓ Dotfiles setup complete!"
echo ""
echo "Note: If you had existing files, they were backed up with .backup extension"
echo "Please restart your terminal or run: source ~/.zshrc"
