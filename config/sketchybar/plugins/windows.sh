#!/bin/bash

# ==============================================================================
# ⚡ SketchyBar Window Ribbon - Cyberpunk Neon (Optimized Zero-Lag)
# Directly reads from Paneru socket with jq (0.01s vs 0.4s AppleScript)
# ==============================================================================

MAX_WINS=10

DATA=$(/opt/homebrew/bin/paneru query on-screen 2>/dev/null)
if [ -z "$DATA" ] || [ "$DATA" = "null" ]; then
  exit 0
fi

ARGS=()
INDEX=0

while IFS=$'\t' read -r IS_FOCUSED APP; do
  [ -z "$APP" ] && continue
  [ $INDEX -ge $MAX_WINS ] && break

  ITEM_NAME="win.$INDEX"

  if [ "$IS_FOCUSED" = "true" ]; then
    BG_COLOR=0xff00f5ff
    TEXT_COLOR=0xff030712
    BORDER_COLOR=0xff5dfcff
    BORDER_WIDTH=1
  else
    BG_COLOR=0xee091322
    TEXT_COLOR=0xff7dd3fc
    BORDER_COLOR=0x55163b66
    BORDER_WIDTH=1
  fi

  CLICK="open -a '$APP'"

  ARGS+=(
    --add item "$ITEM_NAME" left
    --set "$ITEM_NAME"
      drawing=on
      click_script="$CLICK"
      label="$APP"
      label.color="$TEXT_COLOR"
      label.font="SF Pro:Semibold:13"
      label.padding_left=8
      label.padding_right=8
      icon.drawing=off
      background.drawing=on
      background.color="$BG_COLOR"
      background.border_color="$BORDER_COLOR"
      background.border_width="$BORDER_WIDTH"
      background.height=26
      background.corner_radius=6
      padding_left=4
      padding_right=2
  )

  INDEX=$((INDEX + 1))
done < <(echo "$DATA" | /usr/bin/jq -r '.[] | "\(.focused)\t\(.app_name)"')

for i in $(seq $INDEX $((MAX_WINS - 1))); do
  ARGS+=(--set "win.$i" drawing=off)
done

if [ ${#ARGS[@]} -gt 0 ]; then
  sketchybar "${ARGS[@]}" 2>/dev/null
fi
