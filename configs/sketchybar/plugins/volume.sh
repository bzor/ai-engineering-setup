#!/usr/bin/env bash
if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  VOLUME=$(osascript -e 'output volume of (get volume settings)')
fi

case "$VOLUME" in
  [6-9][0-9]|100) ICON="󰕾" ;;
  [1-5][0-9])     ICON="󰖀" ;;
  [1-9])          ICON="󰕿" ;;
  *)              ICON="󰝟" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
