#!/usr/bin/env bash
# codex plan usage: "codex 7d 10% [6d 1hr]"
#
# The codex CLI doesn't expose limits anywhere queryable, but every token_count
# event in its rollout log carries a rate_limits snapshot. So: newest session
# log that has one wins. Numbers only move while codex is actually running.
#
# Runs off the codex_name item and drives that whole group of items.

source "$(dirname "$0")/usage_fmt.sh"

PREFIX="${NAME%_name}"
SESSIONS="$HOME/.codex/sessions"
SNAP='(fromjson? // empty) | .payload.rate_limits | select(type=="object")'

hide() { hide_group "$PREFIX"; exit 0; }
[ -d "$SESSIONS" ] || hide

# Newest few rollout logs, most recently written first. A session that hasn't
# hit the API yet has no snapshot at all, hence looking past the first file.
limits=""
while IFS= read -r f; do
  # The last snapshot in a log is the freshest, and it's near the end — scan
  # the tail first and only re-read the whole file if that comes up empty.
  limits=$(tail -n 1000 "$f" | jq -Rc "$SNAP" 2>/dev/null | tail -1)
  [ -z "$limits" ] && limits=$(jq -Rc "$SNAP" < "$f" 2>/dev/null | tail -1)
  [ -n "$limits" ] && break
done < <(find "$SESSIONS" -name 'rollout-*.jsonl' -type f -mtime -14 \
           -exec stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -4 | cut -d' ' -f2-)

[ -n "$limits" ] || hide

# Flat stat/countdown pairs, one window per pair, for render_group.
pieces=()
worst=0
while read -r mins pct at; do
  [ -n "$mins" ] || continue
  expired "$at" && continue
  pct_r=$(printf '%.0f' "$pct")
  (( pct_r > worst )) && worst=$pct_r
  pieces+=("$(window_label "$mins"):${pct_r}%")
  if [ "$at" != "0" ]; then pieces+=("$(reset_label "$at")"); else pieces+=(""); fi
done < <(jq -r '[.primary, .secondary]
                | map(select(type == "object"))
                | sort_by(.window_minutes)[]
                | "\(.window_minutes) \(.used_percent) \(.resets_at // 0)"' <<<"$limits")

(( ${#pieces[@]} )) || hide

render_group "$PREFIX" "$(usage_color "$worst")" "$USAGE_MUTED" "${pieces[@]}"
