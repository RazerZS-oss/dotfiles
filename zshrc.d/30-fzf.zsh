# ==============================================================================
# 30-fzf.zsh - FZF-Tab Plugin & Interactive Preview Styling
# ==============================================================================

# Safely source fzf-tab plugin if installed
if [[ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"
fi

# Dracula & Snazzy FZF UI Styling
zstyle ':fzf-tab:*' fzf-flags \
   --color=bg+:#282a36,fg+:#f8f8f2,hl:#ff79c6,hl+:#50fa7b \
   --color=info:#bd93f9,prompt:#8be9fd,pointer:#00f5d4,marker:#ff79c6,header:#8be9fd,border:#6272a4 \
   --preview-window=right:55%:wrap \
   --border=rounded

# Interactive Previews with resilient fallbacks
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range :50 $realpath 2>/dev/null || head -n 50 $realpath'
