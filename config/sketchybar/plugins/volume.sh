#!/bin/bash

VOLUME=$(osascript -e "output volume of (get volume settings)")

if [ "$VOLUME" -eq 0 ]; then
  ICON="󰝟"
elif [ "$VOLUME" -lt 33 ]; then
  ICON="󰕿"
elif [ "$VOLUME" -lt 66 ]; then
  ICON="󰖀"
else
  ICON="󰕾"
fi

sketchybar --set volume_icon icon="$ICON" icon.font="Symbols Nerd Font:Regular:16"
sketchybar --set volume_label label="$VOLUME%"
