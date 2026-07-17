#!/usr/bin/env bash
# Open every active project as a herdr WORKSPACE in one go — the herdr analog
# of tmux-work.sh. Each workspace is laid out like the sessionizer's:
#
#   +----------+----------+
#   |          | terminal |  top-right, 30%
#   |   nvim   +----------+
#   |          |  claude  |  bottom-right, 70%
#   +----------+----------+
#
# Run from a plain shell:  herdr-work
# Edit the PROJECTS list below to change the everyday lineup.
#
# Safe to re-run: a project whose workspace is already open is left untouched
# (matched by label), so this both builds and tops up the lineup.
set -euo pipefail

for dep in jq herdr; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "herdr-work: $dep not installed" >&2
    exit 1
  fi
done

# Server must be up (agents live there). Don't silently spawn a fresh one.
if ! herdr status server >/dev/null 2>&1 || \
   ! herdr status server 2>/dev/null | grep -q 'status: running'; then
  echo "herdr-work: no running herdr server — start one with 'herdr'" >&2
  exit 1
fi

# Active projects — full paths, so it doesn't matter whether a project lives
# in ~/Projects or ~/Repos. The workspace label is the folder's basename.
PROJECTS=(
  "$HOME/Projects/ai-engineering-setup"
  "$HOME/Projects/hammerworth"
  "$HOME/Projects/small-omens"
  "$HOME/Projects/weno-process"
  "$HOME/Projects/ici/SYNERLYTICS"
  "$HOME/Projects/signal-atlas"
  "$HOME/Projects/autonomous-revenue-lab"
)

# Label -> workspace_id for everything already open, fetched once up front.
existing_json=$(herdr workspace list 2>/dev/null)
workspace_id_for() {
  printf '%s' "$existing_json" \
    | jq -r --arg n "$1" '.result.workspaces[] | select(.label == $n) | .workspace_id' \
    | head -1
}

first_ws=""

for path in "${PROJECTS[@]}"; do
  name=$(basename "$path")

  if [ ! -d "$path" ]; then
    echo "skip (missing dir): $path" >&2
    continue
  fi

  ws=$(workspace_id_for "$name")
  if [ -n "$ws" ]; then
    echo "reuse: $name ($ws)"
    if [ -z "$first_ws" ]; then first_ws="$ws"; fi
    continue
  fi

  # Build it unfocused — focusing each in turn would yank the view around the
  # whole lineup. We focus the first one once, at the end.
  ws_json=$(herdr workspace create --cwd "$path" --label "$name" --no-focus)
  ws=$(printf '%s' "$ws_json" | jq -r '.result.workspace.workspace_id')
  editor=$(printf '%s' "$ws_json" | jq -r '.result.root_pane.pane_id')

  # nvim left (50%) | right column: terminal (top 30%) over claude (bottom 70%).
  # --ratio is the ORIGINAL pane's retained share, so 0.3 leaves the top
  # (terminal) at 30% and gives the claude pane the bottom 70%.
  right=$(herdr pane split "$editor" --direction right --ratio 0.5 --no-focus \
    | jq -r '.result.pane.pane_id')
  herdr pane split "$right" --direction down --ratio 0.3 --no-focus >/dev/null

  herdr pane run "$editor" "nvim"
  # Deliberately NOT launching claude here (unlike the sessionizer): this loop
  # builds every project at once, which would spawn one agent per project. The
  # bottom-right pane is left as a shell — type `claude` in the ones you want.

  echo "created: $name ($ws)"
  if [ -z "$first_ws" ]; then first_ws="$ws"; fi
done

# Land on the first project, the way tmux-work leaves you on window 1.
if [ -n "$first_ws" ]; then
  herdr workspace focus "$first_ws" >/dev/null
fi
