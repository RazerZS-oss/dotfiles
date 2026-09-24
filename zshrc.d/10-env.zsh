# ==============================================================================
# 10-env.zsh - Environment Variables & Dynamic Homebrew Path
# ==============================================================================

# Dynamically discover Homebrew prefix for Apple Silicon (/opt/homebrew) or Intel (/usr/local)
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
  fi
fi

# User Local Binaries
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Tool Defaults
export BAT_THEME="Dracula"
export CLICOLOR=1

# Default Editor: micro -> nano -> vim
if (( $+commands[micro] )); then
  export EDITOR='micro'
elif (( $+commands[nano] )); then
  export EDITOR='nano'
else
  export EDITOR='vim'
fi
