#!/usr/bin/env bash
# ==============================================================================
# 🚀 Universal macOS Dotfiles Installer
# ==============================================================================
# Automated, safe, and idempotent setup script for macOS (Apple Silicon & Intel).
# Backs up existing configurations before creating symlinks.
#
# Usage:
#   ./install.sh [OPTIONS]
#
# Options:
#   -y, --yes             Run non-interactively, assuming 'yes' to all prompts
#   --skip-brew           Skip Homebrew bundle installation
#   --skip-speedup        Skip macOS UI speedup script
#   -h, --help            Show this help message
# ==============================================================================

set -euo pipefail

# ANSI Color Codes
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

log_info()    { echo -e "${BLUE}${BOLD}==>${RESET} ${BOLD}$*${RESET}"; }
log_success() { echo -e "${GREEN}${BOLD}==> ✔${RESET} ${BOLD}$*${RESET}"; }
log_warn()    { echo -e "${YELLOW}${BOLD}==> ⚠${RESET} ${YELLOW}$*${RESET}"; }
log_error()   { echo -e "${RED}${BOLD}==> ✖${RESET} ${RED}$*${RESET}"; }

# Script Location (Repository Root)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${TARGET_HOME}/.dotfiles_backup/${BACKUP_TIMESTAMP}"

AUTO_CONFIRM=false
SKIP_BREW=false
SKIP_SPEEDUP=false

# Parse CLI Arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes|--non-interactive)
      AUTO_CONFIRM=true
      shift
      ;;
    --skip-brew)
      SKIP_BREW=true
      shift
      ;;
    --skip-speedup)
      SKIP_SPEEDUP=true
      shift
      ;;
    -h|--help)
      echo "Universal macOS Dotfiles Installer"
      echo "Usage: ./install.sh [-y|--yes] [--skip-brew] [--skip-speedup]"
      exit 0
      ;;
    *)
      log_warn "Unknown option: $1"
      shift
      ;;
  esac
done

echo -e "${CYAN}${BOLD}"
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo -e "${RESET}"
log_info "Starting macOS Dotfiles Installation..."
echo "    Repository: ${SOURCE_DIR}"
echo "    Target:     ${TARGET_HOME}"
echo ""

# 1. Verify macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  log_error "This dotfiles suite is designed exclusively for macOS."
  exit 1
fi

ARCH="$(uname -m)"
log_info "Detected Architecture: ${BOLD}${ARCH}${RESET}"

# Helper function to ask yes/no
confirm() {
  local prompt="$1"
  local default="${2:-y}"
  if [[ "$AUTO_CONFIRM" == true ]]; then
    return 0
  fi
  if [[ "$default" == "y" ]]; then
    read -r -p "$prompt [Y/n]: " response
    response=${response:-y}
    [[ "$response" =~ ^[Yy]$ ]]
  else
    read -r -p "$prompt [y/N]: " response
    response=${response:-n}
    [[ "$response" =~ ^[Yy]$ ]]
  fi
}

# 2. Package Management with Homebrew
if [[ "$SKIP_BREW" == false ]]; then
  if command -v brew >/dev/null 2>&1; then
    log_info "Homebrew found."
    if [[ -f "${SOURCE_DIR}/Brewfile" ]]; then
      if confirm "Would you like to install/bundle required packages via Homebrew (Brewfile)?"; then
        log_info "Executing 'brew bundle --file=${SOURCE_DIR}/Brewfile'..."
        brew bundle --file="${SOURCE_DIR}/Brewfile" || log_warn "Some Homebrew packages had warnings or were already installed."
        log_success "Homebrew packages ready."
      else
        log_warn "Skipped Homebrew bundle."
      fi
    fi
  else
    log_warn "Homebrew not found. Install it from https://brew.sh to get eza, bat, paneru, borders, sketchybar, etc."
  fi
fi

# 3. Safe Backup & Symlinking Function
backup_and_link() {
  local src="$1"
  local dest="$2"

  local dest_parent="$(dirname "$dest")"
  mkdir -p "$dest_parent"

  # If destination already exists
  if [[ -e "$dest" || -L "$dest" ]]; then
    # Check if already correctly symlinked
    if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
      log_success "Already linked: ${dest} -> ${src}"
      return 0
    fi

    # Create backup directory lazily on first backup
    mkdir -p "$BACKUP_DIR"
    local rel_backup="${dest#"${TARGET_HOME}/"}"
    mkdir -p "$(dirname "${BACKUP_DIR}/${rel_backup}")"

    log_warn "Backing up existing: ${dest} -> ${BACKUP_DIR}/${rel_backup}"
    mv "$dest" "${BACKUP_DIR}/${rel_backup}"
  fi

  ln -s "$src" "$dest"
  log_success "Linked: ${dest} -> ${src}"
}

# 4. Create Configurations Symlinks
log_info "Creating configuration symlinks..."

# Zsh Shell Configs
backup_and_link "${SOURCE_DIR}/.zshrc" "${TARGET_HOME}/.zshrc"
backup_and_link "${SOURCE_DIR}/zshrc.d" "${TARGET_HOME}/.zshrc.d"

# Application Configs (~/.config)
backup_and_link "${SOURCE_DIR}/config/borders" "${TARGET_HOME}/.config/borders"
backup_and_link "${SOURCE_DIR}/config/fastfetch" "${TARGET_HOME}/.config/fastfetch"
backup_and_link "${SOURCE_DIR}/config/ghostty" "${TARGET_HOME}/.config/ghostty"
backup_and_link "${SOURCE_DIR}/config/paneru" "${TARGET_HOME}/.config/paneru"
backup_and_link "${SOURCE_DIR}/config/sketchybar" "${TARGET_HOME}/.config/sketchybar"
backup_and_link "${SOURCE_DIR}/config/yazi" "${TARGET_HOME}/.config/yazi"

# 5. Setup fzf-tab plugin
if [[ ! -d "${TARGET_HOME}/.zsh/fzf-tab" ]]; then
  log_info "Installing fzf-tab plugin..."
  mkdir -p "${TARGET_HOME}/.zsh"
  git clone --depth=1 https://github.com/Aloxaf/fzf-tab "${TARGET_HOME}/.zsh/fzf-tab" 2>/dev/null || log_warn "Could not clone fzf-tab. Please check internet connection."
else
  log_success "fzf-tab plugin already present."
fi

# 6. Optional macOS Speedup Tweaks
if [[ "$SKIP_SPEEDUP" == false && -f "${SOURCE_DIR}/scripts/macos_speedup.sh" ]]; then
  echo ""
  if confirm "Would you like to apply macOS UI speedups (zero Dock delay & instant keyboard repeat)?"; then
    log_info "Running macos_speedup.sh..."
    bash "${SOURCE_DIR}/scripts/macos_speedup.sh" || log_warn "macos_speedup.sh exited with warnings."
    log_success "macOS speedups applied!"
  else
    log_info "Skipped macOS speedup tweaks."
  fi
fi

echo ""
log_success "Installation Complete!"
if [[ -d "$BACKUP_DIR" ]]; then
  log_info "Backups of your previous configs were preserved at: ${BOLD}${BACKUP_DIR}${RESET}"
fi
echo ""
echo -e "${GREEN}${BOLD}Next steps:${RESET}"
echo -e "  1. Reload your shell:  ${CYAN}source ~/.zshrc${RESET}  or open a new terminal window"
echo -e "  2. Start Paneru:       ${CYAN}paneru &${RESET}"
echo -e "  3. Start Borders:      ${CYAN}brew services start borders${RESET}"
echo -e "  4. Start Sketchybar:   ${CYAN}brew services start sketchybar${RESET}"
echo ""
