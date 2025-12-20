#!/bin/bash
set -e

echo "== Homebrew setup =="

# Homebrew がなければインストール
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon 用 PATH を明示
if [ -d "/opt/homebrew/bin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "== Brew bundle =="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

brew bundle --file="$SCRIPT_DIR/Brewfile"

echo "== Done =="
