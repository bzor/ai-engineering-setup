#!/usr/bin/env bash
# Build (or attach to) the "work" tmux session: one window per active project,
# each laid out as:  nvim (left) | claude (top-right) / terminal (bottom-right).
#
# Run from a plain shell:  tmux-work
# Edit the PROJECTS list below to change what shows up in the status bar.
set -euo pipefail

SESSION="work"

# Active projects — full paths, so it doesn't matter whether a project lives
# in ~/Projects or ~/Repos. The window name is the folder's basename.
PROJECTS=(
  "$HOME/Projects/ai-engineering-setup"
  "$HOME/Projects/hammerworth"
  "$HOME/Projects/small-omens"
  "$HOME/Projects/weno-process"
  "$HOME/Projects/ici/SYNERLYTICS"
  "$HOME/Projects/signal-atlas"
  "$HOME/Projects/autonomous-revenue-lab"
)

attach() {
  if [ -n "${TMUX:-}" ]; then tmux switch-client -t "$SESSION"; else tmux attach -t "$SESSION"; fi
}

# Already built? Just go there.
if tmux has-session -t "$SESSION" 2>/dev/null; then
  attach; exit 0
fi

first=1
for path in "${PROJECTS[@]}"; do
  name=$(basename "$path")
  if [ ! -d "$path" ]; then
    echo "skip (missing dir): $path" >&2
    continue
  fi

  if [ "$first" = 1 ]; then
    main=$(tmux new-session -d -s "$SESSION" -n "$name" -c "$path" -P -F '#{pane_id}')
    first=0
  else
    main=$(tmux new-window -t "$SESSION" -n "$name" -c "$path" -P -F '#{pane_id}')
  fi

  # right column (40% wide), then split it into top (claude) / bottom (terminal)
  right=$(tmux split-window -h -t "$main" -c "$path" -l 40% -P -F '#{pane_id}')
  tmux split-window -v -t "$right" -c "$path" -l 50%

  # Launch nvim in the main pane. Comment out to leave it as a plain shell.
  tmux send-keys -t "$main" 'nvim' C-m
  tmux select-pane -t "$main"
done

tmux select-window -t "$SESSION:1"
attach
