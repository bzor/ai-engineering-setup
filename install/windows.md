# Native Windows setup

This repository supports a native Windows 11 stack:

```text
WezTerm -> PowerShell 7 -> Herdr -> Neovim + Codex -> Houdini
```

WSL, tmux, and Kitty are not used. Kitty and the retained tmux configuration are macOS/Linux legacy files.

## Install and link

Run from PowerShell 7:

```powershell
pwsh -NoProfile -File .\scripts\bootstrap-windows.ps1
pwsh -NoProfile -File .\scripts\link-configs-windows.ps1
pwsh -NoProfile -File .\scripts\check-health-windows.ps1
```

The bootstrap installs only missing stable winget packages. It deliberately leaves Herdr (Windows preview), Houdini, and the Iosevka Nerd Font for explicit/manual installation. Install Iosevka Term Nerd Font from the official Nerd Fonts Iosevka release, then restart WezTerm. Codex is supplied by the official native OpenAI Codex Windows app.

## AI usage bar

Zebar hosts a top-edge Codex and Claude usage widget. The Node collector
(`scripts/ai-usage-collector.js`) queries Codex's local app-server once per minute.
Claude Code sends its supported five-hour and seven-day rate-limit payload to the
same cache through the configured status-line command, so Claude values populate
after starting a Claude session. Both write `configs/zebar/ai-usage-bar/usage.json`,
which is runtime state: it is git-ignored and excluded from the linker's
change comparison.

Start the collector and widget with:

```powershell
pwsh -NoProfile -File .\scripts\start-ai-usage-bar.ps1 -RegisterStartup
```

`-RegisterStartup` also creates a per-user Windows startup shortcut so the
collector and Zebar return after signing out or rebooting. It is safe to run
again; the shortcut is refreshed in place.

### Placement

The active preset is `top-right`, selected in `~/.glzr/zebar/settings.json`. It sets
`dockToEdge` on the top edge, which registers the widget as a Windows appbar and
reserves a 42px strip out of the desktop work area:

```powershell
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Screen]::PrimaryScreen | Select-Object Bounds, WorkingArea
# Bounds {Width=2560,Height=1600} / WorkingArea {Y=42,Height=1558} when docked
```

Docking, not `zOrder`, is what keeps the bar visible. `top_most` is best-effort and
Windows demotes it — WezTerm in particular would cover the bar. Reserving work area
means a maximized window cannot occupy those pixels at all. Windows already open
when the reservation changes may need re-maximizing to pick it up; true fullscreen
windows still cover the strip. A tiling window manager such as GlazeWM is not
required for this, and would tile inside the reduced work area with no top gap
configured. The undocked `bottom-right` preset is retained in `zpack.json`.

### Readout

Each metric shows percent used, a countdown to reset, and a 2px meter filled to the
same percentage, coloured neutral below 70%, amber at 70%, red at 90%. The Claude
five-hour window shows only a countdown; the seven-day windows add the local reset
date in `M/D h:mmam` form. A clock sits at the right end, since the Windows taskbar
is hidden — it renders even when the collector is down, so it never disappears with
the usage groups.

### Claude Code status line

`configs/claude/settings.json` points `statusLine` at the same collector through
`ai-usage-collector.cmd --claude-status-line`. Every render caches the rate-limit
payload for the widget and prints the model, context percentage, and raw token
count:

```text
Opus 5 (1M context) · ctx 4% · 42k/1M
```

The five-hour and seven-day percentages are deliberately not printed there; they
are the widget's job, and duplicating them crowded the status line.

### Editing the widget

If `~/.glzr/zebar/ai-usage-bar` is a managed copy rather than a symbolic link,
editing this repository does not update the running widget. Rerun
`link-configs-windows.ps1`, then restart Zebar to reload:

```powershell
Get-Process zebar -ErrorAction SilentlyContinue | Stop-Process -Force
pwsh -NoProfile -File .\scripts\start-ai-usage-bar.ps1
```

The linker also moves any timestamped backup out of `~/.glzr/zebar`, because Zebar
treats every direct child of that directory as a widget pack and would otherwise
offer a stale copy.

The linker prefers symbolic links and falls back to marked managed copies. It refuses unmanaged targets. Managed targets are backed up with a timestamp before replacement. Re-running it does not duplicate the repository bin entry in the user PATH.

## Herdr Windows beta

Native Windows support is preview-only. Its official installer uses an execution-policy bypass for only the installer process, so the setup does not run it without approval. Download `https://herdr.dev/install.ps1` to a temporary file, inspect it, then run it only after approval. Current limitations include ConPTY cursor tradeoffs, partial live-cwd reporting, unverified image paste/Kitty graphics, no native `--remote`, and no live server handoff. Restart sessions after updating.

Customize project roots, active projects, and the optional agent command in `configs/herdr/projects.windows.psd1`. `herdr-sessionizer` starts one selected project with Neovim and Codex; `herdr-work` builds the active workspace list but intentionally launches no agent per project.

## Neovim notes

On Windows, Telescope's native FZF extension builds only when CMake and a supported C/C++ compiler are present. Telescope remains usable without it. This machine has no supported compiler on PATH, so native FZF and future Treesitter parser compilation are disabled; installing Visual Studio Build Tools requires approval. The existing requested Treesitter parsers are current. Clipboard uses native `unnamedplus`; Yazi and ImageMagick are found as external commands. Mermaid rendering remains optional because `mmdc` is not installed. `image.nvim` uses the graphics protocol implemented by WezTerm, but multiplexer image behavior depends on Herdr's Windows beta.

## Wispr Flow dictation in Codex

Wispr Flow inserts Windows dictation by temporarily putting the transcript on the clipboard and simulating `Ctrl+V`. Codex reserves the raw `Ctrl+V` chord for attaching a clipboard image, and that fixed action is not exposed by `/keymap`. Changing only Flow's activation shortcut therefore does not resolve the collision.

The Windows WezTerm configuration intercepts `Ctrl+V` with `wezterm.action.PasteFrom 'Clipboard'`. WezTerm then sends a normal terminal paste to Codex instead of forwarding the raw shortcut, so Flow dictation arrives as text. The tradeoff is that `Ctrl+V` is text paste inside WezTerm; attach images to Codex by file path when needed.

If Flow still triggers image paste, confirm which config WezTerm is actually loading:

```powershell
Get-Item -Force "$HOME\.wezterm.lua" | Select-Object FullName,LinkType,Target,LastWriteTime
Select-String -Path "$HOME\.wezterm.lua" -Pattern 'PasteFrom'
wezterm show-keys --lua | Select-String "key = 'v'.*mods = 'CTRL'.*PasteFrom"
```

On systems where symbolic links are unavailable, `link-configs-windows.ps1` installs a marked managed copy. Editing the repository does not update that live copy immediately; rerun the linker to back up and refresh it, then reload WezTerm with `Ctrl+Shift+R` or restart it. This stale-copy check also applies to the other managed Windows configuration targets.

## Houdini

Install Houdini manually through SideFX Launcher; this setup never changes licensing or preferences. Run a script through the newest detected `hython.exe`:

```powershell
pwsh -NoProfile -File .\configs\houdini\Invoke-HoudiniPython.ps1 .\my-script.py arg1 arg2
```

To select a release, pass `-HoudiniVersion 22.0`; to override discovery, pass `-HythonPath 'C:\...\hython.exe'`. The full smoke test saves only below `$env:TEMP` and may check out a license, so run it only after confirming license availability.

## Update, recovery, and verification

Use `winget upgrade --id <exact-id>` for stable packages and the vendor updater for Codex/Herdr/Houdini. Health checks are read-only:

```powershell
pwsh -NoProfile -File .\scripts\check-health-windows.ps1
pwsh -NoProfile -Command ". `$PROFILE; 'profile-ok'"
nvim --headless "+checkhealth" "+qa"
herdr config check
codex --version
```

If a managed copy must be refreshed, the linker creates a timestamped backup. An unmanaged destination must be moved or reconciled manually; the script will not overwrite it. Administrator access may be requested by a vendor installer. Herdr preview installation, execution-policy changes, compiler toolchains, Houdini/Launcher GUI work, and replacing existing user configuration always require explicit approval.
