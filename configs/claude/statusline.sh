#!/usr/bin/env bash
# Claude Code statusline — model · effort · context · limit usage.
#
# Also caches the rate_limits block for sketchybar's claude usage item: the
# statusline hook is the only place Claude Code hands those numbers out, so
# anything outside a session has to read them secondhand.

input=$(cat)

cache="$HOME/.cache/ai-usage/claude.json"
mkdir -p "$(dirname "$cache")"
prev='{}'
[ -s "$cache" ] && prev=$(cat "$cache")

# Every concurrent session writes this file, and an idle one keeps reporting
# whatever it last saw — days old, sometimes. Last-writer-wins made the bar
# flap between live and stale numbers, so merge per window instead: a window
# only ever moves forward, so the higher resets_at is the fresher snapshot
# (same window: the higher percentage), and an already-expired window is
# dropped rather than shown as fact.
if limits=$(jq -ce --argjson prev "$prev" '
      (.rate_limits // {}) as $new
      | ($prev + $new | to_entries)
      | map(select(.value | type == "object"))
      | map(.value = (
          ($prev[.key] // null) as $p
          | ($new[.key] // null) as $n
          | if   $p == null then $n
            elif $n == null then $p
            elif ($n.resets_at // 0) > ($p.resets_at // 0) then $n
            elif ($n.resets_at // 0) < ($p.resets_at // 0) then $p
            elif ($n.used_percentage // 0) >= ($p.used_percentage // 0) then $n
            else $p end))
      | map(select(.value.resets_at == null or .value.resets_at > now))
      | from_entries
      | select(length > 0)' <<<"$input" 2>/dev/null); then
  printf '%s\n' "$limits" > "$cache.tmp" && mv "$cache.tmp" "$cache"
fi

jq -r '
  def h: if . >= 1000000 then "\((./100000|round)/10)M"
         elif . >= 1000 then "\(./1000|floor)k"
         else "\(.)" end;
  [ (.model.display_name // empty),
    (if .effort.level then "effort:\(.effort.level)" else empty end),
    (if .context_window.total_input_tokens != null then
       ("ctx:" + (.context_window.total_input_tokens|h)
        + (if .context_window.context_window_size != null
           then "/" + (.context_window.context_window_size|h) else "" end))
     else empty end),
    (if .rate_limits.five_hour.used_percentage != null then
       "5h:\(.rate_limits.five_hour.used_percentage|round)%" else empty end),
    (if .rate_limits.five_hour.resets_at != null then
       ((.rate_limits.five_hour.resets_at - now) as $s
        | if $s > 0 then "resets:\($s/3600|floor)h\(($s%3600)/60|floor)m" else empty end)
     else empty end),
    (if .rate_limits.seven_day.used_percentage != null then
       "7d:\(.rate_limits.seven_day.used_percentage|round)%" else empty end)
  ] | join(" · ")' <<<"$input"
