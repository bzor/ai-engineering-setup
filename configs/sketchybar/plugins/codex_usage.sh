#!/usr/bin/env bash
# codex plan usage: "codex 7d 10% [6d 1hr]"
#
# codex app-server exposes account/rateLimits/read over JSON-RPC on stdio,
# which answers straight from the account's current status — no session or
# API spend required. query_live_limits talks that protocol by hand (this
# box only has bash 3.2, no coproc) so the numbers move every 60s regardless
# of whether codex itself has run recently.
#
# Falls back to scanning rollout logs (the old approach: every token_count
# event in a session's log carries a rate_limits snapshot) if the live query
# fails — no codex binary, not logged in, app-server errors, etc.
#
# Runs off the codex_name item and drives that whole group of items.

source "$(dirname "$0")/usage_fmt.sh"

PREFIX="${NAME%_name}"
SESSIONS="$HOME/.codex/sessions"
SNAP='(fromjson? // empty) | .payload.rate_limits | select(type=="object")'

hide() { hide_group "$PREFIX"; exit 0; }

# Speaks just enough JSON-RPC to get one answer, then kills the server. The
# fifo has to stay open (fd 3) until the response is read — closing it right
# after the write causes app-server to see EOF and exit before it answers.
query_live_limits() {
  # sketchybar's launchd service runs with its own restricted PATH (no
  # ~/.local/bin, where the official installer puts codex), so `command -v`
  # alone finds nothing there even though an interactive shell resolves it
  # fine — check the well-known install spots too.
  local codex_bin
  codex_bin=$(command -v codex 2>/dev/null)
  if [ -z "$codex_bin" ]; then
    for codex_bin in "$HOME/.local/bin/codex" /opt/homebrew/bin/codex /usr/local/bin/codex; do
      [ -x "$codex_bin" ] && break
    done
  fi
  [ -x "$codex_bin" ] || return 1

  local fifo out pid line
  fifo=$(mktemp -u "${TMPDIR:-/tmp}/codex_usage_in.XXXXXX") || return 1
  out=$(mktemp "${TMPDIR:-/tmp}/codex_usage_out.XXXXXX") || return 1
  mkfifo "$fifo" || { rm -f "$out"; return 1; }

  "$codex_bin" app-server --stdio <"$fifo" >"$out" 2>/dev/null &
  pid=$!

  exec 3>"$fifo"
  printf '%s\n%s\n%s\n' \
    '{"id":1,"method":"initialize","params":{"clientInfo":{"name":"sketchybar-codex-usage","version":"1.0.0"},"capabilities":{"experimentalApi":true}}}' \
    '{"method":"initialized"}' \
    '{"id":2,"method":"account/rateLimits/read"}' >&3

  local i
  for (( i = 0; i < 30; i++ )); do
    line=$(grep -m1 '"id":2' "$out" 2>/dev/null)
    [ -n "$line" ] && break
    sleep 0.1
  done

  exec 3>&-
  kill "$pid" 2>/dev/null
  wait "$pid" 2>/dev/null
  rm -f "$fifo" "$out"

  [ -n "$line" ] || return 1

  # Reshape camelCase RPC fields to the snake_case the rollout log already
  # used, so everything downstream (shared with the fallback) stays the same.
  jq -ce '
    def reshape: if type == "object" then
      {window_minutes: .windowDurationMins, used_percent: .usedPercent, resets_at: (.resetsAt // 0)}
    else null end;
    .result.rateLimits
    | select(type == "object")
    | {primary: (.primary | reshape), secondary: (.secondary | reshape)}
  ' <<<"$line" 2>/dev/null
}

limits=$(query_live_limits)

if [ -z "$limits" ]; then
  [ -d "$SESSIONS" ] || hide

  # Newest few rollout logs, most recently written first. A session that
  # hasn't hit the API yet has no snapshot at all, hence looking past the
  # first file.
  while IFS= read -r f; do
    # The last snapshot in a log is the freshest, and it's near the end —
    # scan the tail first and only re-read the whole file if that's empty.
    limits=$(tail -n 1000 "$f" | jq -Rc "$SNAP" 2>/dev/null | tail -1)
    [ -z "$limits" ] && limits=$(jq -Rc "$SNAP" < "$f" 2>/dev/null | tail -1)
    [ -n "$limits" ] && break
  done < <(find "$SESSIONS" -name 'rollout-*.jsonl' -type f -mtime -14 \
             -exec stat -f '%m %N' {} + 2>/dev/null | sort -rn | head -4 | cut -d' ' -f2-)
fi

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
