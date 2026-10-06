# ==============================================================================
# 70-functions.zsh - Shell Functions & Hooks
# ==============================================================================

# Prevent automatic directory listing on cd
unfunction chpwd 2>/dev/null || true

# Terminal File Manager (yazi) - Auto cd on quit (q to cd, Q to stay)
unfunction y 2>/dev/null || true
function yy() {
  local yazi_bin="yazi"
  if ! (( $+commands[yazi] )) && [[ -x "${HOMEBREW_PREFIX:-/opt/homebrew}/bin/yazi" ]]; then
    yazi_bin="${HOMEBREW_PREFIX:-/opt/homebrew}/bin/yazi"
  fi
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  "$yazi_bin" "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
