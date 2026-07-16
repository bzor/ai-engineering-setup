# kitty

kitty is a GPU-accelerated terminal, trying it as a wezterm alternative. Config lives in `configs/kitty/` and is symlinked to `~/.config/kitty` by `scripts/link-configs.sh`.

## Install

```bash
brew install --cask kitty
```

Put the CLI tools on PATH (the app bundles them):

```bash
ln -sf /Applications/kitty.app/Contents/MacOS/kitty ~/.local/bin/kitty
ln -sf /Applications/kitty.app/Contents/MacOS/kitten ~/.local/bin/kitten
```

## Theme

`configs/kitty/themes/black-metal-gorgoroth.conf` is copied from the
black-metal-theme-neovim plugin's `extras/kitty/` — same palette as nvim.
If the plugin updates the palette, re-copy it from
`~/.local/share/nvim/lazy/black-metal-theme-neovim/extras/kitty/gorgoroth.conf`.
