# ==============================================================================
# 20-completion.zsh - High-Performance Completion & LS_COLORS Caching
# ==============================================================================
autoload -Uz compinit

# Fast compinit: only re-index completions once every 24 hours
_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -s "$_zcompdump" && $(($(date +%s) - $(stat -f %m "$_zcompdump" 2>/dev/null || echo 0))) -lt 86400 ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
  # Byte-compile in background for faster future loads
  { zcompile "$_zcompdump" } 2>/dev/null &!
fi

# Cache LS_COLORS from vivid (snazzy theme) to eliminate subshell overhead
_lscache="${XDG_CACHE_HOME:-$HOME/.cache}/ls_colors_snazzy"
if [[ ! -s "$_lscache" ]] && (( $+commands[vivid] )); then
  mkdir -p "${_lscache:h}"
  vivid generate snazzy > "$_lscache" 2>/dev/null
fi

if [[ -s "$_lscache" ]]; then
  export LS_COLORS="$(<"$_lscache")"
elif (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate snazzy 2>/dev/null)"
fi

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Clustered Dropdown Completion Menu
zstyle ':completion:*:descriptions' format $'\e[1;38;5;212m✦ [ %d ]\e[0m'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select

unset _zcompdump _lscache
