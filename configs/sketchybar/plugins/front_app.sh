#!/usr/bin/env bash
# Show the focused application's name.
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
