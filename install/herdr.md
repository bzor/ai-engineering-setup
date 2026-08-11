# Herdr

Agent multiplexer — tmux, but it understands coding agents. Shows each agent's
state at a glance (`blocked` / `working` / `done` / `idle`), so you can run
several long tasks in parallel and check in on each without hunting through
windows. It is the active Windows multiplexer. The macOS tmux configuration is
still retained, and Herdr can be used there as an alternative.

## Install

```bash
brew install herdr                    # homebrew/core, no tap needed
herdr integration install claude      # richer Claude Code state + session resume
```

Native Windows support is preview/beta. Follow the inspected-installer and
limitations guidance in [windows.md](windows.md); the repository supplies a
separate PowerShell config and launchers for that platform.

The Claude integration adds a `SessionStart` hook to `~/.claude/settings.json`
and drops `~/.claude/hooks/herdr-agent-state.sh`. The hook **no-ops unless run
inside a herdr pane** (guards on `HERDR_ENV` / `HERDR_SOCKET_PATH` /
`HERDR_PANE_ID`), so normal Claude Code sessions are unaffected. The script is
herdr-managed — updates overwrite it; add custom hooks beside it, don't edit it.

## Run

```
herdr                 launch or attach the persistent session
claude                (inside a pane) start a Claude agent — codex/opencode also work
herdr status          show client + server status without attaching
herdr server stop     stop the background server entirely
```

Sessions persist after you detach; the server keeps agents running. Reattach by
running `herdr` again. Also attachable over SSH (`herdr --remote <ssh-target>`).

## Keys (prefix `Ctrl-Space`, set in config.toml)

```
prefix |         split right     (rebound from herdr's default prefix v)
prefix -         split down
prefix h j k l   focus pane left/down/up/right
prefix r         resize mode — then h/j/k/l to resize, esc to exit
prefix c         new tab
prefix n / p     next / prev tab
prefix w         workspace picker
prefix z         zoom pane
prefix q         detach (server keeps running; closing the window also detaches)
prefix ?         help — the authoritative list of what's actually bound
```

Herdr rebinds **built-in actions** as plain `action = "key"` pairs under
`[keys]` — `[[keys.command]]` is only for launching external commands. Run
`herdr --default-config` for the full list of action names and their defaults.
Handy: the defaults already match our tmux for `-` (split down) and h/j/k/l
(pane focus), so `split_vertical = "prefix+|"` is the only override we need.

Validate with `herdr config check` — it reports an invalid key by name and
disables just that binding rather than failing the whole config.

## Project launcher (prefix f)

On macOS, `configs/herdr/herdr-sessionizer.sh` is the Herdr analog of
`tmux-sessionizer`.
It fuzzy-picks a project (same roots as the tmux one) and opens it as a
**workspace** — reusing it if already open — with the familiar layout:

```
+----------+----------+
|          | terminal |  top-right, 30%
|   nvim   +----------+
|          |  claude  |  bottom-right, 70%
+----------+----------+
```

Project = workspace (not tab) on purpose: that's what makes the sidebar show one
row per project with its agent state. Bound to `prefix f` via a popup in
`config.toml`. Needs `fzf` + `jq` and a running herdr server. Unlike tmux, it
drives herdr over the socket, so it works from any shell — no "am I inside it".

## Gotcha: prefix clash with tmux

Our tmux accepts *both* `Ctrl-Space` (prefix) and `Ctrl-b` (prefix2) — which is
herdr's default prefix and our chosen one respectively, so there is no prefix
herdr could use that tmux doesn't already claim. Don't nest herdr inside tmux or
the prefixes fight. On macOS, run Herdr in its own terminal window, separate
from tmux. Windows does not use tmux.

## Uninstall / back out

```bash
herdr integration uninstall claude    # removes the hook + settings entry
brew uninstall herdr
```
