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
