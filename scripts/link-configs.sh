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

# yazi: link individual config files so its runtime/package directories remain local.
mkdir -p "$HOME/.config/yazi"
ln -sf "$REPO_DIR/configs/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
ln -sf "$REPO_DIR/configs/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"

# herdr: link the config FILE, not the dir — herdr keeps its sockets, logs and
# session.json in ~/.config/herdr alongside it.
mkdir -p "$HOME/.config/herdr"
ln -sf "$REPO_DIR/configs/herdr/config.toml" "$HOME/.config/herdr/config.toml"

# claude code: link the settings FILE, not the dir — Claude stores sessions,
# projects, credentials in ~/.claude alongside it. macOS gets its own copy:
# the hooks and statusLine point at bash scripts that don't exist on Windows,
# so a single shared file would break one side or the other.
mkdir -p "$HOME/.claude"
ln -sf "$REPO_DIR/configs/claude/settings.macos.json" "$HOME/.claude/settings.json"

# helper scripts onto PATH
mkdir -p "$HOME/.local/bin"
ln -sf "$REPO_DIR/configs/tmux/tmux-work.sh" "$HOME/.local/bin/tmux-work"
ln -sf "$REPO_DIR/configs/tmux/tmux-sessionizer.sh" "$HOME/.local/bin/tmux-sessionizer"
ln -sf "$REPO_DIR/configs/herdr/herdr-sessionizer.sh" "$HOME/.local/bin/herdr-sessionizer"
ln -sf "$REPO_DIR/configs/herdr/herdr-work.sh" "$HOME/.local/bin/herdr-work"
# pointed at by statusLine.command in ~/.claude/settings.json
ln -sf "$REPO_DIR/configs/claude/statusline.sh" "$HOME/.local/bin/claude-statusline"

echo "Linked configs from $REPO_DIR"
