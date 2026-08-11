# macOS setup

The retained macOS stack uses zsh, Neovim, Yazi, and either Kitty or WezTerm.
tmux remains available for the established project workflow; Herdr can be run
alongside it, but the two multiplexers should not be nested because they share
the `Ctrl-Space` prefix.

## Install and link

Install the Xcode Command Line Tools and [Homebrew](homebrew.md) first. Then,
from the repository root:

```bash
./scripts/bootstrap-macos.sh
./scripts/link-configs.sh
```

The bootstrap installs Neovim, tmux, ripgrep, fd, Git, Node.js, Yazi, zoxide,
fzf, Kitty, Iosevka Term Nerd Font, and Sketchybar. It adds the third-party
FelixKratz tap before installing Sketchybar; review that tap before running the
script if this is a new machine.

The linker replaces the shell, terminal, and tmux file links with repository
links. For configuration directories it only removes an existing real
directory when that directory is empty; it will fail rather than delete a
non-empty configuration directory. Review existing `~/.zshrc`, `~/.tmux.conf`,
`~/.wezterm.lua`, `~/.config`, and `~/.claude/settings.json` first.

It also links the Yazi files, Herdr config and launchers, and tmux launchers.
Ensure `~/.local/bin` is on `PATH`; the supplied zsh config does this.

## Optional tools

- Install Claude Code and Codex separately using their vendor-supported method.
- Install Herdr as described in [herdr.md](herdr.md) if using the agent-aware
  workspace workflow.
- Kitty and Sketchybar details are in [kitty.md](kitty.md) and
  [sketchybar.md](sketchybar.md).

## Verify

There is not yet an automated macOS health script. Check the linked targets and
core commands directly:

```bash
command -v nvim tmux rg fd fzf yazi zoxide node
nvim --headless '+qa'
tmux -f "$HOME/.tmux.conf" start-server \; show-options -g prefix
```

If Herdr is installed, also run `herdr config check`. Reload Kitty with
`Cmd+Ctrl+,`, tmux with `prefix r`, and Sketchybar with `sketchybar --reload`.
