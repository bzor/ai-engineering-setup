# sketchybar

Minimal replacement for the macOS menu bar: spaces + focused app on the left,
battery / volume / clock on the right. Gorgoroth palette, Iosevka font.
Config in `configs/sketchybar/`, symlinked to `~/.config/sketchybar`.

## Install

```bash
brew tap FelixKratz/formulae
brew trust --formula felixkratz/formulae/sketchybar
brew install sketchybar
brew services start sketchybar
```

Then hide the real menu bar so sketchybar takes its place:
System Settings → Control Center → "Automatically hide and show the menu bar" → **Always**.

## Iterating

```bash
brew services restart sketchybar   # after config edits (or: sketchybar --reload)
sketchybar --query bar             # inspect live state
```

Items live in `sketchybarrc`; each item's refresh logic is a small script in
`plugins/`. The bar doesn't show over natively-fullscreen apps
(`show_in_fullscreen off`) — keep kitty as a regular maximized window.

## Space names

The left side labels spaces by name, driven by the `SPACE_NAMES` array near the
top of `sketchybarrc` (`code web chat …`). Names are **per position** — space 1
is the leftmost, space 2 the next, etc. — because macOS spaces have no
persistent identity; sketchybar only knows them by index. macOS doesn't pin
apps to spaces, so the names describe what each slot is *for*, not what's
enforced there. Edit the array and `sketchybar --reload`. A space only appears
once it exists (create them in Mission Control, three-finger-swipe up + `＋`).
