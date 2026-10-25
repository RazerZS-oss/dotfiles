# ==============================================================================
# ⚡ Modular Zsh Configuration Loader
# ==============================================================================
# Automatically sources all *.zsh modules in ~/.zshrc.d in alphanumeric order.

if [[ -d "$HOME/.zshrc.d" ]]; then
  for module in "$HOME/.zshrc.d/"*.zsh(N); do
    source "$module"
  done
  unset module
fi


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# Laravel Herd configuration (if installed)
if [[ -d "$HOME/Library/Application Support/Herd" ]]; then
  export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84"
  export HERD_PHP_74_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/74"
  export HERD_PHP_86_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/86"
  export NVM_DIR="$HOME/Library/Application Support/Herd/config/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"
  export PATH="$HOME/Library/Application Support/Herd/bin":$PATH
fi
