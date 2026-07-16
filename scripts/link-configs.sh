#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.config"

# Symlink a whole config dir. If the target already exists as a real (empty)
# directory — e.g. the app created it on first launch — remove it first, or
# BSD ln would nest the link inside it. rmdir refuses non-empty dirs, so real
# configs are never clobbered.
link_dir() {
  local src="$1" dst="$2"
  [ -d "$dst" ] && [ ! -L "$dst" ] && rmdir "$dst"
  ln -sfn "$src" "$dst"
}

ln -sf "$REPO_DIR/configs/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
ln -sf "$REPO_DIR/configs/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$REPO_DIR/configs/zsh/zshrc" "$HOME/.zshrc"
link_dir "$REPO_DIR/configs/nvim" "$HOME/.config/nvim"
link_dir "$REPO_DIR/configs/kitty" "$HOME/.config/kitty"
link_dir "$REPO_DIR/configs/sketchybar" "$HOME/.config/sketchybar"

# tmux helper scripts onto PATH
mkdir -p "$HOME/.local/bin"
ln -sf "$REPO_DIR/configs/tmux/tmux-work.sh" "$HOME/.local/bin/tmux-work"
ln -sf "$REPO_DIR/configs/tmux/tmux-sessionizer.sh" "$HOME/.local/bin/tmux-sessionizer"

echo "Linked configs from $REPO_DIR"