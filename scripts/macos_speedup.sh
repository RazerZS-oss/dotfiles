#!/usr/bin/env bash
#
# macos_speedup.sh - High-Impact Performance & Responsiveness Tweaks for macOS (Apple Silicon M1)
#
# This script eliminates animation delays, accelerates keyboard repeat, and removes UI lag.
# Run with --revert to restore macOS defaults.

set -euo pipefail

if [[ "${1:-}" == "--revert" ]]; then
  echo "==> Restoring default macOS settings..."
  defaults delete -g InitialKeyRepeat 2>/dev/null || true
  defaults delete -g KeyRepeat 2>/dev/null || true
  defaults delete -g ApplePressAndHoldEnabled 2>/dev/null || true
  defaults delete -g NSWindowResizeTime 2>/dev/null || true
  defaults delete -g NSAutomaticWindowAnimationsEnabled 2>/dev/null || true
  defaults delete com.apple.dock autohide-delay 2>/dev/null || true
  defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true
  defaults delete com.apple.dock expose-animation-duration 2>/dev/null || true
  defaults delete com.apple.finder DisableAllAnimations 2>/dev/null || true
  killall Dock 2>/dev/null || true
  killall Finder 2>/dev/null || true
  echo "Defaults restored. Note: You may need to log out and log back in for all changes to take effect."
  exit 0
fi

echo "=================================================="
echo "⚡ Applying macOS Speed & Responsiveness Tweaks ⚡"
echo "=================================================="

# 1. KEYBOARD & INPUT RESPONSIVENESS (Huge boost for coding & Vim)
echo "--> Configuring instant keyboard repeat rate..."
# Disable press-and-hold for keys in favor of key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
# Set delay until repeat (default is 25 = 375ms, 12 = 180ms)
defaults write -g InitialKeyRepeat -int 12
# Set key repeat rate (default is 6 = 90ms, 1 = 15ms)
defaults write -g KeyRepeat -int 1

# 2. DOCK SPEEDUPS
echo "--> Removing Dock show/hide delays..."
# Instant Dock popup when autohide is enabled (no 0.5s pause)
defaults write com.apple.dock autohide-delay -float 0
# Snappy slide animation (0.12s instead of sluggish 0.5s default)
defaults write com.apple.dock autohide-time-modifier -float 0.12
# Speed up Mission Control / Expose animation
defaults write com.apple.dock expose-animation-duration -float 0.1

# 3. WINDOW & UI ANIMATIONS
echo "--> Accelerating window animations..."
# Accelerate window resize time to near-instant
defaults write -g NSWindowResizeTime -float 0.001
# Disable slow window open/close zoom animations
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
# Expand save and print panel dialogs by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write -g PMPrintingExpandedStateForPrint -bool true
defaults write -g PMPrintingExpandedStateForPrint2 -bool true

# 4. FINDER TWEAKS
echo "--> Speeding up Finder & file dialogs..."
# Disable Finder animations
defaults write com.apple.finder DisableAllAnimations -bool true
# Show path bar and status bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
# Prevent creation of .DS_Store files on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Disable extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# 5. RESTART AFFECTED APPS
echo "--> Restarting Dock and Finder to apply changes..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo ""
echo "✅ Done! Your Mac should now feel significantly snappier."
echo "💡 Note: For Keyboard Repeat changes to take full effect in all apps, you may need to log out and log back in."
echo "🔄 To revert anytime: bash $(basename "$0") --revert"
