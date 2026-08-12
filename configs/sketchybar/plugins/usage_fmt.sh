#!/usr/bin/env bash
# Shared formatting for the codex / claude usage items.
# Colors mirror the palette at the top of ../sketchybarrc.

USAGE_FG=0xffc1c1c1
USAGE_MUTED=0xff8a8a8a # names, countdowns, separator — everything not a number
USAGE_DIM=0xff505050   # stale numbers (no live session writing them)
USAGE_WARN=0xffd7875f  # >= 75% of a window burned
USAGE_CRIT=0xffaf5f5f  # >= 90%

# window_label <minutes> -> "5h" / "7d"
window_label() {
  local hours=$(( $1 / 60 ))
  if (( hours > 0 && hours % 24 == 0 )); then
    echo "$(( hours / 24 ))d"
  else
    echo "${hours}h"
  fi
}

# reset_label <epoch> -> time left on the window: "6d:17hr" past a day out,
# "2h:5m" under one.
reset_label() {
  local at=$1 left days hours mins
  left=$(( at - $(date +%s) ))
  (( left < 0 )) && left=0
  if (( left >= 86400 )); then
    days=$(( left / 86400 ))
    hours=$(( (left % 86400) / 3600 ))
    echo "${days}d:${hours}hr"
  else
    hours=$(( left / 3600 ))
    mins=$(( (left % 3600) / 60 ))
    echo "${hours}h:${mins}m"
  fi
}

# expired <epoch> -> true once a window has rolled. Both sources are snapshots
# of whatever the CLI last saw, so a window can outlive its own numbers; better
# to drop it than to show a percentage for a window that no longer exists.
# 0 means "no reset time given", which isn't the same as expired.
expired() { [ "$1" != "0" ] && (( $1 < $(date +%s) )); }

# usage_color <max percent seen> -> hex
usage_color() {
  local pct=${1%%.*}
  if   (( pct >= 90 )); then echo "$USAGE_CRIT"
  elif (( pct >= 75 )); then echo "$USAGE_WARN"
  else                       echo "$USAGE_FG"
  fi
}

# How many windows one provider can show. sketchybarrc sources this file to
# build that many slots, so the two can't drift apart.
USAGE_SLOTS=3

# The dot between the two providers only means anything with a group either
# side of it, so it follows whichever group is currently drawing.
sync_separator() {
  local codex claude
  codex=$(sketchybar --query codex_name | jq -r '.geometry.drawing')
  claude=$(sketchybar --query claude_name | jq -r '.geometry.drawing')
  if [ "$codex" = "on" ] && [ "$claude" = "on" ]; then
    sketchybar --set usage_sep drawing=on
  else
    sketchybar --set usage_sep drawing=off
  fi
}

# render_group <prefix> <stat color> <muted color> <stat> <countdown> [...]
# One label takes one font, so a bold percentage next to a regular countdown
# has to be two items. The slots already exist (see sketchybarrc); this fills
# them and hides the leftovers, in a single sketchybar call so the group never
# paints half-updated. An empty countdown just leaves that piece hidden.
render_group() {
  local prefix=$1 color=$2 muted=$3; shift 3
  local slot=1
  local args=(--set "${prefix}_name" drawing=on label="$prefix" label.color="$muted")
  while (( $# >= 2 )); do
    args+=(--set "${prefix}_w${slot}_stat" drawing=on label="$1" label.color="$color")
    if [ -n "$2" ]; then
      args+=(--set "${prefix}_w${slot}_time" drawing=on label="[$2]" label.color="$muted")
    else
      args+=(--set "${prefix}_w${slot}_time" drawing=off)
    fi
    shift 2
    slot=$(( slot + 1 ))
  done
  while (( slot <= USAGE_SLOTS )); do
    args+=(--set "${prefix}_w${slot}_stat" drawing=off \
           --set "${prefix}_w${slot}_time" drawing=off)
    slot=$(( slot + 1 ))
  done
  sketchybar "${args[@]}"
  sync_separator
}

# hide_group <prefix> — no data, so the whole group goes away, name included.
hide_group() {
  local prefix=$1 slot
  local args=(--set "${prefix}_name" drawing=off)
  for (( slot = 1; slot <= USAGE_SLOTS; slot++ )); do
    args+=(--set "${prefix}_w${slot}_stat" drawing=off \
           --set "${prefix}_w${slot}_time" drawing=off)
  done
  sketchybar "${args[@]}"
  sync_separator
}
