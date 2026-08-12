# sketchybar

Minimal replacement for the macOS menu bar: spaces + focused app on the left,
codex/claude plan usage + battery / volume / clock on the right. Gorgoroth
palette, Iosevka font. Config in `configs/sketchybar/`, symlinked to
`~/.config/sketchybar`.

## Install

```bash
brew tap FelixKratz/formulae
brew trust --formula felixkratz/formulae/sketchybar
brew install sketchybar
brew services start sketchybar
```

Then hide the real menu bar so sketchybar takes its place:
System Settings → Control Center → "Automatically hide and show the menu bar" → **Always**.

## Iterating

```bash
brew services restart sketchybar   # after config edits (or: sketchybar --reload)
sketchybar --query bar             # inspect live state
```

Items live in `sketchybarrc`; each item's refresh logic is a small script in
`plugins/`. The bar doesn't show over natively-fullscreen apps
(`show_in_fullscreen off`) — keep kitty as a regular maximized window.

## Space names

The left side labels spaces by name, driven by the `SPACE_NAMES` array near the
top of `sketchybarrc` (`code web chat …`). Names are **per position** — space 1
is the leftmost, space 2 the next, etc. — because macOS spaces have no
persistent identity; sketchybar only knows them by index. macOS doesn't pin
apps to spaces, so the names describe what each slot is *for*, not what's
enforced there. Edit the array and `sketchybar --reload`. A space only appears
once it exists (create them in Mission Control, three-finger-swipe up + `＋`).

## Plan usage (codex / claude)

Left of the battery, how much of each rate-limit window is gone (bold) and how
long until it comes back:

```
codex **7d:3%** [4d:1hr] · claude **5h:19%** [1h:24m] **7d:3%** [6d:17hr]
```

Brackets hold the time left on the window — days and hours out past a day,
hours and minutes under one. Only the percentages are full-brightness; names,
countdowns and the separator sit a step down in grey so the numbers carry the
line. Those numbers turn amber at 75% of a window and red at 90%
(`usage_fmt.sh`). Everything refreshes every 60s and hides entirely when
there's no data — including the `·`, which follows both groups so it can never
be left floating on its own.

A sketchybar label takes exactly one font, so the bold percentages can't be
part of a longer string — each piece is its own item: `codex_name`,
`codex_w1_stat` (bold), `codex_w1_time`, and so on. `sketchybarrc` builds
`USAGE_SLOTS` empty slots per provider and the plugin fills however many
windows that provider reports, hiding the rest. Adding a window to either side
needs no config change; adding a *fourth* means bumping `USAGE_SLOTS` in
`plugins/usage_fmt.sh`.

Keeping it to the countdown is what lets these run at the bar's normal 13pt: on
the built-in 16" display the notch eats the middle 185pt, and left/right items
are laid out from the screen edges — `notch_width` only holds *centered* items
back, so a right-hand group long enough to reach x=956 just disappears under
the notch with no visual clipping to warn you. Appending wall-clock reset times
did exactly that. After changing the format, check it still clears:

```bash
sketchybar --query codex_name | jq '.bounding_rects[].origin[0]'   # want > 956
```

Neither CLI exposes limits in a queryable way, so both plugins read them
secondhand:

- **codex** — every `token_count` event in `~/.codex/sessions/**/rollout-*.jsonl`
  carries a `rate_limits` snapshot. `codex_usage.sh` takes the last one from
  the newest log that has any.
- **claude** — Claude Code hands these numbers *only* to the statusline hook, so
  `configs/claude/statusline.sh` (linked to `~/.local/bin/claude-statusline`,
  pointed at by `statusLine.command` in `~/.claude/settings.json`) caches the
  `rate_limits` block to `~/.cache/ai-usage/claude.json` on every refresh, and
  `claude_usage.sh` reads that.

Both therefore only move while that CLI is actually running. The reset
countdowns stay honest regardless — those are absolute timestamps — but the
percentages drift once nothing is refreshing them, so the claude label dims to
grey after 30 minutes without a session writing the cache. The codex label has
no equivalent tell; check the log's mtime if a number looks frozen.
