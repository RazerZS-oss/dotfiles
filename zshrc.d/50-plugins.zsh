# ==============================================================================
# 50-plugins.zsh - Syntax Highlighting & Autosuggestions
# ==============================================================================

# Search Homebrew share directory for plugins across architectures (Apple Silicon & Intel)
_brew_share="${HOMEBREW_PREFIX:-/opt/homebrew}/share"
if [[ ! -d "$_brew_share" && -d "/usr/local/share" ]]; then
  _brew_share="/usr/local/share"
fi

# Load Syntax Highlighting Safely (Homebrew or Standalone Git clone in ~/.zsh)
if [[ -f "$_brew_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$_brew_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Load Autosuggestions Safely (Homebrew or Standalone Git clone in ~/.zsh)
if [[ -f "$_brew_share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$_brew_share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

unset _brew_share

# Autosuggestion Styling
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#1b4d6e,bold"

# Syntax Highlighting Palette
typeset -A ZSH_HIGHLIGHT_STYLES 2>/dev/null || true
ZSH_HIGHLIGHT_STYLES[path]='fg=#00f5ff,bold,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#38bdf8,bold'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#5dfcff,bold'
ZSH_HIGHLIGHT_STYLES[default]='fg=#e0f2fe'
