#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.config/wezterm"
mkdir -p "$HOME/.config/nvim"

ln -sf "$REPO_DIR/configs/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
ln -sf "$REPO_DIR/configs/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sfn "$REPO_DIR/configs/nvim" "$HOME/.config/nvim"

echo "Config files linked from:"
echo "$REPO_DIR"