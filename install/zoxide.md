# zoxide

zoxide is a smarter `cd` that ranks directories by how often and how recently
you visit them ("frecency"), so a few keystrokes jump anywhere.

## Install

```bash
brew install zoxide fzf   # fzf powers the interactive picker (zi)
```

Hooked into zsh at the bottom of `configs/zsh/zshrc`:

```bash
eval "$(zoxide init zsh)"
```

The database lives in `~/Library/Application Support/zoxide` (not in this repo —
it's per-machine learned state). Existing projects were seeded once with
`zoxide add`; after that it learns from normal `cd`/`z` usage.
