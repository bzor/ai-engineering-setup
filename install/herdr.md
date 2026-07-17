# Herdr

Agent multiplexer — tmux, but it understands coding agents. Shows each agent's
state at a glance (`blocked` / `working` / `done` / `idle`), so you can run
several long tasks in parallel and check in on each without hunting through
windows. Rust single binary, no Electron/account/telemetry. Trialing it
alongside tmux to compare — not a replacement yet.

## Install

```bash
brew install herdr                    # homebrew/core, no tap needed
herdr integration install claude      # richer Claude Code state + session resume
```

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

## Keys (default prefix `Ctrl-b`)

```
prefix v         split right
prefix -         split down
prefix c         new tab
prefix n / p     next / prev tab
prefix q         detach (server keeps running; closing the window also detaches)
```

## Project launcher (prefix f)

`configs/herdr/herdr-sessionizer.sh` is the herdr analog of `tmux-sessionizer`.
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

Herdr's default prefix is `Ctrl-b` — one of our tmux prefixes too (the other is
`Ctrl-Space`). Don't nest herdr inside tmux or the prefixes fight. For the
trial, run herdr in its **own kitty window**, separate from tmux.

## Uninstall / back out

```bash
herdr integration uninstall claude    # removes the hook + settings entry
brew uninstall herdr
```
