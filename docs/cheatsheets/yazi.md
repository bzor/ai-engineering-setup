# yazi

Terminal file manager. Only the theme is customized (`configs/yazi/theme.toml`,
Black Metal / Gorgoroth) — keys below are yazi's defaults.

Launch with `y` (the shell wrapper): browse, quit with `q`, and your shell
cd's to wherever you ended up. Press `Q` to quit *without* the cd. Inside nvim,
`Space p y` opens it in a float.

## Move around

```
h j k l             leave dir / down / up / enter dir (or open file)
gg  /  G            top / bottom
Ctrl-u / Ctrl-d     half page up / down
Ctrl-b / Ctrl-f     full page up / down
gh                  cd ~            (g then h)
gc                  cd ~/.config
gd                  cd ~/Downloads
g<Space>            cd to a path you type
z                   zoxide jump (same DB as the shell's z)
Z                   fzf jump (interactive picker)
```

## Select

```
Space               toggle selection on this file, move down
v  /  V             visual select / visual unselect
Ctrl-a              select all
Ctrl-r              invert selection
Esc                 clear selection
```

## Act on files

```
o  /  Enter         open (O = open with… chooser)
y                   yank (copy)          x   yank (cut)
p                   paste                P   paste, overwriting
Y  /  X            cancel a pending copy / cut
d                   delete → trash (D = delete permanently)
a                   create — end the name with / to make a dir
r                   rename
;                   run a shell command with the selection
.                   toggle hidden files
cc                  copy full path to clipboard (cf = filename, cd = dirname)
```

## Find

```
/                   find in current dir (n / N = next / prev)
f                   filter the list as you type
s                   search by filename (fd)
S                   search by content (ripgrep)
Ctrl-s              stop the running search
```

## Tabs & preview

```
t                   new tab at cwd       1..9  jump to tab N
[  /  ]             prev / next tab      {  /  }  move tab left / right
J  /  K            scroll the preview pane down / up
w                   task manager (see running copies/moves)
~  or  F1          help — full keymap, searchable
q  /  Q            quit (with cd) / quit (no cd)
```

## Notes

- `d` goes to macOS Trash, so it's recoverable; `D` is the irreversible one.
- Paste never clobbers by default — same-name files get ` _1` suffixes. Use `P`
  only when you actually mean to overwrite.
- `z` here shares the exact database as `z` in the shell — see [zoxide](zoxide.md).
- Theme needs terminal OSC 11 support for the `#121212` background; kitty and
  WezTerm both do it.
