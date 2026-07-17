#!/usr/bin/env bash
# Fuzzy-pick any project under ~/Projects or ~/Repos and open it as a herdr
# WORKSPACE (reuses the workspace if it already exists). The herdr analog of
# tmux-sessionizer.sh — project = workspace so the sidebar shows one row per
# project with its agent state. Layout matches the tmux one:
#
#   +----------+----------+
#   |          | terminal |  p2 (top-right, 30%)
#   |   nvim   +----------+
#   |    p1    |  claude  |  p3 (bottom-right, 70%)
#   +----------+----------+
#
# herdr talks over its socket, so this works from any shell as long as the
# herdr server is running. Bind it to `prefix f` via config.toml, or run it
# from a shell. Requires fzf + jq.
set -euo pipefail

for dep in fzf jq herdr; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "herdr-sessionizer: $dep not installed" >&2
    exit 1
  fi
done

# Server must be up (agents live there). Don't silently spawn a fresh one.
if ! herdr status server >/dev/null 2>&1 || \
   ! herdr status server 2>/dev/null | grep -q 'status: running'; then
  echo "herdr-sessionizer: no running herdr server — start one with 'herdr'" >&2
  exit 1
fi

# --- project discovery: same roots as tmux-sessionizer -----------------------
ROOTS=("$HOME/Projects" "$HOME/Repos")
CONTAINERS=("$HOME/Repos/bzor-ads")

list_projects() {
  find "${ROOTS[@]}" -mindepth 1 -maxdepth 1 -type d -not -name '.*' 2>/dev/null
  for c in "${CONTAINERS[@]}"; do
    [ -d "$c" ] && find "$c" -mindepth 1 -maxdepth 1 -type d -not -name '.*' 2>/dev/null
  done
}

selected=$(list_projects \
  | grep -vFxf <(printf '%s\n' "${CONTAINERS[@]}") \
  | sort -u | fzf --prompt="herdr project> " \
      --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up')
[ -z "${selected:-}" ] && exit 0

name=$(basename "$selected")

# --- reuse existing workspace by label, else build a fresh one ---------------
existing=$(herdr workspace list 2>/dev/null \
  | jq -r --arg n "$name" '.result.workspaces[] | select(.label == $n) | .workspace_id' \
  | head -1)

if [ -n "${existing:-}" ]; then
  herdr workspace focus "$existing"   # already open — just jump to it
  exit 0
fi

# Create the workspace (focused) and grab its root pane.
ws_json=$(herdr workspace create --cwd "$selected" --label "$name" --focus)
editor=$(printf '%s' "$ws_json" | jq -r '.result.root_pane.pane_id')

# nvim left (50%) | right column: terminal (top 30%) over claude (bottom 70%).
# --ratio is the ORIGINAL pane's retained share, so 0.3 leaves the top
# (terminal) at 30% and gives claude the bottom 70%.
right=$(herdr pane split "$editor" --direction right --ratio 0.5 --no-focus \
  | jq -r '.result.pane.pane_id')
claude=$(herdr pane split "$right" --direction down --ratio 0.3 --focus \
  | jq -r '.result.pane.pane_id')

herdr pane run "$editor" "nvim"
herdr pane run "$claude" "claude"
# focus already left on the claude pane by the --focus split above.
