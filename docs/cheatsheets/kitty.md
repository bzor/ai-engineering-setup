# kitty

GPU terminal, config in `configs/kitty/kitty.conf` (symlinked to `~/.config/kitty`).
Reload config: `cmd+ctrl+,`

## Everyday

```
cmd + / cmd -        font size up / down
cmd 0                reset font size
cmd n                new OS window
ctrl shift e         URL hints — type the letter to open a link on screen
ctrl shift u         unicode/emoji input
cmd ,                edit kitty.conf
```

Tabs/splits exist (`cmd t`, etc.) but tmux owns that job here.

## Custom app icon

kitty (0.36+) uses `configs/kitty/kitty.app.png` if present — Dock and the
Cmd-Tab switcher, no `.app` bundle editing, survives upgrades. Current icon is
`kitty.app.png` (1024×1024; macOS rounds it into the squircle). To swap it,
replace that file and fully quit kitty (`cmd q`) — the icon applies on launch.

## Kittens (bundled mini-tools)

```bash
kitten icat photo.png        # render an image inline in the terminal
kitten themes                # interactive theme browser (careful: writes config)
kitten choose-fonts          # interactive font picker
kitten diff old.txt new.txt  # fast side-by-side diff
kitten ssh host              # ssh that fixes terminfo on the remote end
```

## Gotchas

- kitty sets `TERM=xterm-kitty`; remote hosts often don't know it and backspace/
  clear break. Use `kitten ssh` instead of plain `ssh` for interactive sessions.
- Inside tmux, scrollback/search belong to tmux (`prefix [`), not kitty —
  kitty's `ctrl shift h` pager only sees what tmux has printed to it.
- `kitten icat` draws real pixels but only outside tmux (tmux passthrough is off).
