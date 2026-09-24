# ==============================================================================
# 80-prompt.zsh - Prompt Appearance & History Settings
# ==============================================================================

# History Options
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Clean 2-Line Minimal Prompt with Path and Symbol
PROMPT='%F{141}%~%f
%F{117}❯%f '

# Right Prompt: Realtime Vim Mode Indicator
RPROMPT='${CURRENT_VIM_STATUS}'
