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
  local main right
  main=$(tmux list-panes -t "$target" -F '#{pane_id}' | head -1)
  right=$(tmux split-window -h -t "$main" -c "$path" -l 40% -P -F '#{pane_id}')
  tmux split-window -v -t "$right" -c "$path" -l 50%
  tmux send-keys -t "$main" 'nvim' C-m
  tmux select-pane -t "$main"
}

# Not inside tmux: start/attach the work session with this project as a window.
if [ -z "${TMUX:-}" ]; then
  tmux new-session -As work -n "$name" -c "$selected"
  open_layout "work:$name" "$selected"
  tmux attach -t work
  exit 0
fi

# Anchor to the pane the popup was launched from ($TMUX_PANE), so we act on the
# session the user is actually in — not whatever tmux guesses is "current".
pane="${TMUX_PANE:?not launched from a tmux pane}"
session=$(tmux display-message -p -t "$pane" '#S')
if tmux list-windows -t "$session" -F '#W' | grep -qx "$name"; then
  tmux select-window -t "$session:$name"   # already open — just jump to it
else
  tmux new-window -t "$session" -n "$name" -c "$selected"
  open_layout "$session:$name" "$selected"
fi
