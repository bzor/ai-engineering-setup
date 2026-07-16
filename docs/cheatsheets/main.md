# Main Cheat Sheet

The everyday commands, all tools in one place. Deeper dives live in the
per-tool sheets: [tmux](tmux.md), [kitty](kitty.md), [zoxide](zoxide.md),
[git](git.md), [vim motions](vim-motions.md).

## Jumping around (zoxide)

```
z nicole            jump to ~/Projects/nicole-film from anywhere
z proj anim         fragments; all must match, in order
z -                 back to previous directory
zi                  fzf picker over ranked matches (zi film to pre-filter)
zoxide query --list see everything it knows, ranked
```

## Projects (tmux)

```
prefix = Ctrl-Space   (Ctrl-b also works)

tmux-work           build/attach the work session (window per active project)
prefix f            fuzzy-open any other project as a window (nvim + term/claude)
prefix 1..9         jump to window
prefix |  /  -      split right / down
prefix h j k l      move between panes
prefix [            scrollback/copy mode (vi keys; v select, y yank)
prefix r            reload tmux config
```

## Files

```
Space p f           find file (telescope)
Space p s           live grep project
Space p b           buffers
Space p y           yazi in nvim        (z inside yazi = zoxide jump)
y                   yazi from the shell; quitting cd's you to the browsed dir
                    (Q quits without the cd)
```

## nvim extras

```
(dashboard)         f find  g grep  r recent  c config  L lazy  q quit
Space n h           notification history
Ctrl-d / Ctrl-u     half-page scroll, centered
```

## sketchybar

```
sketchybar --reload             apply config edits
brew services restart sketchybar   if it gets wedged
```

## kitty

```
cmd+ctrl+,          reload kitty config
ctrl+shift+e        click links by keyboard
cmd + / cmd -       font size
kitten icat f.png   image in terminal (outside tmux)
kitten ssh host     ssh with working terminfo
```
