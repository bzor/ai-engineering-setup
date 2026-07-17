# herdr Cheatsheet

herdr is a terminal multiplexer that understands coding agents — "tmux, but
agent-aware." It shows each agent's state (`blocked` / `working` / `done` /
`idle`) in a sidebar, so I can run several long tasks in parallel and check in
on each without hunting through windows. Trialing it alongside tmux; setup
notes live in `install/herdr.md`.

The mental model — one row per project in the sidebar, each a **workspace**:

```text
session
  ├─ workspace: ai-engineering-setup   [idle]     nvim | terminal / claude
  ├─ workspace: hammerworth            [working]  nvim | terminal / claude
  ├─ workspace: small-omens            [blocked]  ...
  └─ workspace: (any project, via prefix f)
```

Project = **workspace**, on purpose. herdr's hierarchy is
`session → workspace → tab → pane`; mapping a project to a workspace (not a tab)
is what makes the sidebar show one status row per project. Tabs are spare
capacity *within* a project.

## The lineup (`herdr-work`)

The everyday environment is built by one script, `configs/herdr/herdr-work.sh`
(on PATH as `herdr-work`), the herdr analog of `tmux-work`:

```bash
herdr-work
```

It opens every project in the script's `PROJECTS` array as a workspace, each
laid out with nvim, a spare terminal, and a claude shell, then focuses the
first. Unlike the launcher below it does **not** auto-start `claude` in each —
that would spawn one agent per project; the bottom-right pane is left as a
shell, type `claude` in the ones you want. Safe to re-run: projects already
open are left as-is (matched by label), so it both builds and tops up the
lineup. Edit the `PROJECTS` array to change the everyday set.

Needs a running herdr server (`herdr` first) plus `jq`. Because herdr drives
over its socket, `herdr-work` works from any shell — inside a pane or out.

## Project launcher (`prefix f`)

For anything not in the lineup, `prefix f` opens a popup that fuzzy-picks any
project under `~/Projects` or `~/Repos` and opens it as a workspace (jumping to
it if already open). This is `configs/herdr/herdr-sessionizer.sh`, also on PATH
as `herdr-sessionizer`. Same layout every time:

```text
+----------+----------+
|          | terminal |  top-right, 30%
|   nvim   +----------+
|          |  claude  |  bottom-right, 70%
+----------+----------+
```

Unlike `herdr-work`, the launcher **does** start `claude` in the bottom-right
pane — it's the "I want to work on this one now" path. Needs `fzf` + `jq`.

## Prefix key

My prefix is `Ctrl-Space`, matching tmux (herdr's own default is `Ctrl-b`):

```text
Ctrl-Space       then another key
```

Set in `configs/herdr/config.toml`. Don't nest herdr inside tmux — the prefixes
fight. Run herdr in its own kitty window.

## Panes

Bindings are tuned to match tmux muscle memory. `-` and `h/j/k/l` are already
herdr defaults; only split-right is rebound (`|`, from the default `v`):

```text
prefix |         split right
prefix -         split down
prefix h j k l   focus pane left / down / up / right
prefix tab       cycle to next pane
prefix z         zoom pane fullscreen (again to unzoom)
prefix x         close pane
```

### Resize mode

`prefix r` enters a modal for resizing — then h/j/k/l grow the focused pane,
`esc` exits. (This is why `prefix r` is *not* reload-config here; reload is
`prefix shift-r`.)

```text
prefix r         enter resize mode
  h j k l        grow the focused pane left / down / up / right
  esc            exit
```

## Workspaces and tabs

```text
prefix w         workspace picker
prefix shift-n   new workspace
prefix shift-w   rename workspace
prefix shift-d   close workspace
prefix c         new tab (within the current workspace)
prefix n / p     next / previous tab
prefix 1..9      jump to tab by number
prefix b         toggle sidebar
prefix q         detach (server keeps running)
```

## Keybindings, the herdr way

herdr rebinds **built-in actions** as plain `action = "key"` pairs under
`[keys]` in `config.toml` — the `[[keys.command]]` block is only for launching
external commands (that's how `prefix f` runs the launcher). The authoritative
list of action names and their defaults:

```bash
herdr --default-config      # every rebindable action + default key
```

After editing the config:

```bash
herdr config check          # validate — names the bad key, disables just it
herdr server reload-config  # apply live to the running server
```

`prefix ?` inside the app shows what's *actually* bound right now — the ground
truth if a binding ever seems off.

## Driving herdr from a shell

The CLI is JSON-out and socket-based, so these work from any shell while the
server runs — handy for scripting layouts (both `herdr-work` and the launcher
are built on them):

```bash
herdr status                    client + server status, no attach
herdr workspace list            all workspaces (+ agent state) as JSON
herdr workspace focus <id>      jump to a workspace
herdr workspace close <id>      close one
herdr pane split <id> \         split a pane; --ratio is the ORIGINAL pane's
  --direction right --ratio 0.5   retained share, not the new pane's
herdr pane run <id> "<cmd>"     launch a program in a pane
```

## Daily workflow

Start the server and build the lineup:

```bash
herdr                # launch/attach the persistent session
herdr-work           # open every active project as a workspace
```

Every project is a sidebar row with its live agent state. Jump around by
clicking the sidebar or `prefix w`; `prefix f` opens anything not in the
lineup. Split for a dev server with `prefix |` / `prefix -`, resize with
`prefix r`. Detach with `prefix q` — the server keeps every agent running, and
`herdr` later drops you right back in.

## Most common

```text
herdr            launch / attach
herdr-work       build the project lineup
prefix f         fuzzy-open any project
prefix w         workspace picker
prefix | / -     split right / down
prefix h j k l   move between panes
prefix r         resize mode
prefix z         zoom pane
prefix q         detach
prefix ?         live keybinding help
```
