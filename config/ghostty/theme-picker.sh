#!/usr/bin/env zsh

theme_preview_cmd='
  clean_name=$(echo {} | sed "s/ (user)//g")
  user_path="$HOME/.config/ghostty/themes/$clean_name"
  if [ -f "$user_path" ]; then
    echo "📁 Custom User Theme: $user_path\n"
    bat --color=always --style=numbers "$user_path"
  else
    echo "📦 Built-in Ghostty Theme: $clean_name"
  fi
'

selected_theme=$(ghostty +list-themes | fzf --prompt="🎨 Select Theme > " \
  --color=bg+:#282a36,fg+:#f8f8f2,hl:#ff79c6,hl+:#50fa7b \
  --color=info:#bd93f9,prompt:#8be9fd,pointer:#00f5d4,marker:#ff79c6,header:#8be9fd,border:#6272a4 \
  --border=rounded --height=65% --reverse \
  --header="[→ / Enter]: Apply Theme | [← / Esc]: Go Back" \
  --bind="right:accept,left:abort" \
  --preview="$theme_preview_cmd" \
  --preview-window=right:45%:wrap)

if [ -n "$selected_theme" ]; then
  clean_theme=$(echo "$selected_theme" | sed 's/ (user)//g')
  config_file="$HOME/.config/ghostty/config"

  if grep -q "^theme =" "$config_file" 2>/dev/null; then
    sed -i '' "s/^theme = .*/theme = $clean_theme/" "$config_file"
  else
    echo "theme = $clean_theme" >> "$config_file"
  fi
  echo "✓ Ghostty theme successfully updated to: $clean_theme"
fi
