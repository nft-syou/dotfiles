# ---- Completion (zsh) ----
fpath=(
  ~/.zsh/completions
  /opt/homebrew/share/zsh/site-functions
  /opt/homebrew/share/zsh-completions
  $fpath
)
autoload -Uz compinit
compinit -i

# ---- AWS completion (bash style) ----
if command -v aws_completer >/dev/null 2>&1; then
  autoload -Uz bashcompinit
  bashcompinit
  complete -C "$(command -v aws_completer)" aws
fi

# ---- Volta (Node.js) ----
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ---- functions ----
source ~/.config/shell/functions.sh
