#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.config/nvim"

ln -sf "$REPO_DIR/configs/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
ln -sf "$REPO_DIR/configs/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$REPO_DIR/configs/nvim" "$HOME/.config/nvim"

# tmux helper scripts onto PATH
mkdir -p "$HOME/.local/bin"
ln -sf "$REPO_DIR/configs/tmux/tmux-work.sh" "$HOME/.local/bin/tmux-work"
ln -sf "$REPO_DIR/configs/tmux/tmux-sessionizer.sh" "$HOME/.local/bin/tmux-sessionizer"

echo "Linked configs from $REPO_DIR"