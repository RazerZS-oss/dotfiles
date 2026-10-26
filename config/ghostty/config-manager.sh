#!/usr/bin/env zsh

# Helper: Open Editor in Right Split Pane (Native Ghostty 1.3+ AppleScript)
open_split_editor() {
  local target_file="$1"
  local editor_bin="${EDITOR:-nvim}"
  if ! command -v "$editor_bin" >/dev/null 2>&1; then
    editor_bin="micro"
  fi
  local q_editor="${(q)editor_bin}"
  local q_target="${(q)target_file}"
  local shell_cmd="/bin/zsh -lc ${q_editor}\\ ${q_target}"

  osascript - "$PWD" "$shell_cmd" <<'APPLESCRIPT'
on run argv
  set targetCwd to item 1 of argv
  set editorCmd to item 2 of argv
  tell application "Ghostty"
    set cfg to new surface configuration
    set initial working directory of cfg to targetCwd
    set command of cfg to editorCmd
    set curTerm to focused terminal of selected tab of front window
    split curTerm direction right with configuration cfg
  end tell
end run
APPLESCRIPT
}

# Sub-menu: File Editor
edit_menu_flow() {
  while true; do
    local edit_items="ghostty/config      Configuration (Window, Font, Padding)
ghostty/dracula     Theme: Dracula Midnight (Purple)
ghostty/cyberpunk   Theme: Cyberpunk Neon (Cyan)
shell/zshrc         Zsh Shell & Keybindings
editor/micro        Micro Editor Settings"

    local edit_preview='
      case {} in
        *ghostty/config*)    bat --color=always --style=plain ~/.config/ghostty/config 2>/dev/null ;;
        *ghostty/dracula*)   bat --color=always --style=plain ~/.config/ghostty/themes/dracula-midnight 2>/dev/null ;;
        *ghostty/cyberpunk*) bat --color=always --style=plain ~/.config/ghostty/themes/cyberpunk-neon 2>/dev/null ;;
        *shell/zshrc*)       bat --color=always --style=plain --line-range :50 ~/.zshrc 2>/dev/null ;;
        *editor/micro*)      bat --color=always --style=plain ~/.config/micro/settings.json 2>/dev/null ;;
      esac
    '

    local selected_file=$(echo "$edit_items" | fzf \
      --color=bg+:#131c26,fg+:#e6edf3,hl:#38bdf8,hl+:#22d3ee \
      --color=info:#d946ef,prompt:#00f5d4,pointer:#00f5d4,marker:#d946ef,header:#38bdf8,border:#1f3a52 \
      --border=rounded --height=70% --reverse \
      --header="[→ / Enter]: Edit in Split  |  [← / Esc]: Back" \
      --bind="right:accept,left:abort" \
      --preview="$edit_preview" \
      --preview-window=right:55%:wrap \
      --prompt="edit ❯ ")

    [ -z "$selected_file" ] && break

    case "$selected_file" in
      *ghostty/config*)    open_split_editor "$HOME/.config/ghostty/config" ;;
      *ghostty/dracula*)   open_split_editor "$HOME/.config/ghostty/themes/dracula-midnight" ;;
      *ghostty/cyberpunk*) open_split_editor "$HOME/.config/ghostty/themes/cyberpunk-neon" ;;
      *shell/zshrc*)       open_split_editor "$HOME/.zshrc" ;;
      *editor/micro*)      open_split_editor "$HOME/.config/micro/settings.json" ;;
    esac
  done
}

# Main Menu Flow
while true; do
  current_theme=$(grep "^theme =" ~/.config/ghostty/config 2>/dev/null | awk -F'= ' '{print $2}' | sed 's/ (user)//g')
  [ -z "$current_theme" ] && current_theme="default"

  main_menu="1. Edit Configurations    Open config files in right split pane
2. Switch Theme          Browse & select Ghostty themes
3. Reload Shell          Apply ~/.zshrc changes instantly
4. Directory Tree        Explore ~/.config/ghostty structure
5. Environment Info      Check active theme & shell status"

  main_preview='
    case {} in
      *1.\ Edit*)
        echo "EDITABLE CONFIGURATIONS\n"
        echo "• Ghostty Config       (~/.config/ghostty/config)"
        echo "• Custom Themes        (~/.config/ghostty/themes/*)"
        echo "• Zsh Shell Profile    (~/.zshrc)"
        echo "• Micro Settings       (~/.config/micro/settings.json)"
        ;;
      *2.\ Switch*)
        (ghostty +list-themes 2>/dev/null || /Applications/Ghostty.app/Contents/MacOS/ghostty +list-themes 2>/dev/null) | head -n 35
        ;;
      *3.\ Reload*)
        echo "RELOAD SHELL CONFIG\n\nInstantly sources ~/.zshrc to apply latest aliases, plugins, and keybindings."
        ;;
      *4.\ Directory*)
        eza -T --icons=always --color=always ~/.config/ghostty 2>/dev/null
        ;;
      *5.\ Environment*)
        echo "ENVIRONMENT OVERVIEW\n"
        echo "Theme   : '$current_theme'"
        echo "Shell   : $SHELL"
        echo "Editor  : $EDITOR"
        echo "Config  : $HOME/.config/ghostty"
        ;;
    esac
  '

  selected_action=$(echo "$main_menu" | fzf \
    --color=bg+:#131c26,fg+:#e6edf3,hl:#38bdf8,hl+:#22d3ee \
    --color=info:#d946ef,prompt:#00f5d4,pointer:#00f5d4,marker:#d946ef,header:#38bdf8,border:#1f3a52 \
    --border=rounded --height=70% --reverse \
    --header="Theme: [ $current_theme ]  |  [→ / Enter]: Select  |  [← / Esc]: Exit" \
    --bind="right:accept,left:abort" \
    --preview="$main_preview" \
    --preview-window=right:55%:wrap \
    --prompt="config ❯ ")

  [ -z "$selected_action" ] && break

  case "$selected_action" in
    *1.\ Edit*)
      edit_menu_flow
      ;;
    *2.\ Switch*)
      source ~/.config/ghostty/theme-picker.sh
      ;;
    *3.\ Reload*)
      source ~/.zshrc
      clear
      echo "✓ Shell profile reloaded."
      sleep 0.8
      ;;
    *4.\ Directory*)
      clear
      echo "📂 Directory Structure:\n"
      eza -T --icons=always --color=always ~/.config/ghostty
      echo "\nPress Enter to return..."
      read -r
      ;;
    *5.\ Environment*)
      clear
      echo "⚡ Environment Details:\n"
      echo "  • Active Theme : $current_theme"
      echo "  • Shell        : $SHELL"
      echo "  • Editor       : $EDITOR"
      echo "  • Config Path  : $HOME/.config/ghostty"
      echo "\nPress Enter to return..."
      read -r
      ;;
  esac
done
