#!/usr/bin/env bash
# Fuzzy-pick any project under ~/Projects or ~/Repos and open it as a window
# in the current tmux session (reuses the window if it already exists).
# Bound to `prefix + f`. Requires fzf.
set -euo pipefail

if ! command -v fzf >/dev/null 2>&1; then
  msg="tmux-sessionizer: fzf not installed — run 'brew install fzf'"
  tmux display-message "$msg" 2>/dev/null || echo "$msg"
  exit 1
fi

# Where to look for projects: top level of each root, plus one level deeper
# inside "container" repos that hold many sub-projects.
ROOTS=("$HOME/Projects" "$HOME/Repos")
CONTAINERS=("$HOME/Repos/bzor-ads")

list_projects() {
  find "${ROOTS[@]}" -mindepth 1 -maxdepth 1 -type d -not -name '.*' 2>/dev/null
  for c in "${CONTAINERS[@]}"; do
    [ -d "$c" ] && find "$c" -mindepth 1 -maxdepth 1 -type d -not -name '.*' 2>/dev/null
  done
}

# Hide the container roots themselves — they're holders, not projects.
selected=$(list_projects \
  | grep -vFxf <(printf '%s\n' "${CONTAINERS[@]}") \
  | sort -u | fzf --prompt="project> " \
      --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up')
[ -z "${selected:-}" ] && exit 0

name=$(basename "$selected" | tr '.' '_')

open_layout() {  # $1 = target window (session:name), $2 = path
  local target="$1" path="$2"
  local editor right claude
  # 50/50 columns: nvim full height on the left; right = small command
  # terminal (top) over claude (bottom 70%).
  editor=$(tmux list-panes -t "$target" -F '#{pane_id}' | head -1)
  right=$(tmux split-window -h -t "$editor" -c "$path" -l 50% -P -F '#{pane_id}')
  claude=$(tmux split-window -v -t "$right" -c "$path" -l 70% -P -F '#{pane_id}')
  tmux send-keys -t "$editor" 'nvim' C-m
  tmux send-keys -t "$claude" 'claude' C-m
  tmux select-pane -t "$claude"
}

# Not inside tmux: start/attach the work session with this project as a window.
if [ -z "${TMUX:-}" ]; then
  tmux new-session -As work -n "$name" -c "$selected"
  open_layout "work:$name" "$selected"
  tmux attach -t work
  exit 0
fi

# Find the session we're acting on. In a display-popup TMUX_PANE is unset,
# but "current" resolves to the client the popup is on, which is what we want.
# When run from a regular pane, anchor to that pane explicitly.
if [ -n "${TMUX_PANE:-}" ]; then
  session=$(tmux display-message -p -t "$TMUX_PANE" '#S')
else
  session=$(tmux display-message -p '#S')
fi
if tmux list-windows -t "$session" -F '#W' | grep -qx "$name"; then
  tmux select-window -t "$session:$name"   # already open — just jump to it
else
  tmux new-window -t "$session" -n "$name" -c "$selected"
  open_layout "$session:$name" "$selected"
fi
