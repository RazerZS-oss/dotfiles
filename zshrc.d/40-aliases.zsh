# ==============================================================================
# 40-aliases.zsh - Resilient Aliases & Command Shortcuts
# ==============================================================================

# Modern File Listing (eza)
if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first'
else
  alias ll='ls -la'
fi

# Cat Replacement (bat)
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
fi

# Editors
if (( $+commands[nvim] )); then
  alias edit='nvim'
  alias vim='nvim'
elif (( $+commands[micro] )); then
  alias edit='micro'
  alias nano='micro'
fi

# GUI & CLI Editors
alias z="open -a Zed"
alias zed="open -a Zed"
alias gsc='git status | pbcopy'
alias pbc='pbcopy'

# Media Player (mpv)
if (( $+commands[mpv] )); then
  alias mpv='mpv'
elif [[ -x "${HOMEBREW_PREFIX:-/opt/homebrew}/bin/mpv" ]]; then
  alias mpv="${HOMEBREW_PREFIX:-/opt/homebrew}/bin/mpv"
fi

# Ghostty Config Manager & Theme Switcher Shortcuts
if [[ -f "$HOME/.config/ghostty/config-manager.sh" ]]; then
  alias conf='source ~/.config/ghostty/config-manager.sh'
  alias cfg='source ~/.config/ghostty/config-manager.sh'
fi
if [[ -f "$HOME/.config/ghostty/theme-picker.sh" ]]; then
  alias theme='source ~/.config/ghostty/theme-picker.sh'
fi
