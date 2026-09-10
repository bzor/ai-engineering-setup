#!/usr/bin/env bash
# claude plan usage: "claude 5h 8% [2h 5m]  7d 22%→61% [6d 17hr]"
#
# Claude Code only hands these numbers to the statusline hook, so
# configs/claude/statusline.sh caches the rate_limits block here on every
# refresh. Nothing outside a running session updates it — hence the stale dim.
#
# Multi-day windows (7d, 7d opus) get a "→NN%" pace projection: where this
# window will land at reset if the burn rate so far holds. See project_pct in
# usage_fmt.sh.
#
# Runs off the claude_name item and drives that whole group of items.

source "$(dirname "$0")/usage_fmt.sh"

PREFIX="${NAME%_name}"
CACHE="$HOME/.cache/ai-usage/claude.json"
STALE_AFTER=1800  # 30 min without a session refreshing the cache

hide() { hide_group "$PREFIX"; exit 0; }
[ -s "$CACHE" ] || hide

# five_hour -> 5h, seven_day -> 7d. Unknown windows still render rather than
# silently vanishing if Claude adds one.
window_name() {
  case "$1" in
    five_hour)      echo "5h" ;;
    seven_day)      echo "7d" ;;
    seven_day_opus) echo "7d opus" ;;
    *)              echo "${1//_/ }" ;;
  esac
}

# Flat stat/countdown pairs, one window per pair, for render_group.
pieces=()
worst=0
while read -r key pct at; do
  [ -n "$key" ] || continue
  expired "$at" && continue
  pct_r=$(printf '%.0f' "$pct")
  stat="${pct_r}%"
  worst_candidate=$pct_r
  mins=$(key_minutes "$key")
  if [ -n "$mins" ] && (( mins >= USAGE_PROJECT_MIN_MINUTES )); then
    proj=$(project_pct "$pct" "$at" "$mins")
    if [ -n "$proj" ]; then
      stat="${pct_r}%→${proj}%"
      (( proj > worst_candidate )) && worst_candidate=$proj
    fi
  fi
  (( worst_candidate > worst )) && worst=$worst_candidate
  pieces+=("$(window_name "$key"):${stat}")
  if [ "$at" != "0" ]; then pieces+=("$(reset_label "$at")"); else pieces+=(""); fi
done < <(jq -r '
    # Shortest window first, to match how codex is ordered. Key order in the
    # cache is not stable — merging a fresh snapshot over the old one can
    # reshuffle it — so rank explicitly rather than trusting to_entries.
    # sort_by is stable, so anything unrecognised keeps its order at the end.
    def rank: {"five_hour": 1, "seven_day": 2, "seven_day_opus": 3}[.] // 9;
    to_entries
    | map(select(.value | type == "object")
          | select(.value.used_percentage != null))
    | sort_by(.key | rank)[]
    | "\(.key) \(.value.used_percentage) \(.value.resets_at // 0)"' "$CACHE" 2>/dev/null)

(( ${#pieces[@]} )) || hide

color=$(usage_color "$worst")
muted=$USAGE_MUTED
# Nothing has refreshed the cache in a while: drop the whole group, numbers
# included, to the dim grey rather than letting stale figures read as current.
age=$(( $(date +%s) - $(stat -f %m "$CACHE") ))
if (( age > STALE_AFTER )); then
  color=$USAGE_DIM
  muted=$USAGE_DIM
fi

render_group "$PREFIX" "$color" "$muted" "${pieces[@]}"
