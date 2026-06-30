# tmux Cheatsheet

tmux is a terminal multiplexer. It lets me create persistent terminal sessions with multiple windows and panes inside a single terminal window.

The mental model:

```text
tmux session
  ├─ window 1: editor
  │    ├─ pane: nvim
  │    └─ pane: shell
  ├─ window 2: server
  ├─ window 3: git
  ├─ window 4: claude
  └─ window 5: codex
```

## Custom `tw` Helper

I added a shell helper called `tw` for quickly creating or attaching to named tmux sessions.

In `~/.zshrc`:

```bash
tw() {
  local session="${1:-work}"
  tmux new-session -A -s "$session"
}
```

Reload shell config:

```bash
source ~/.zshrc
```

Usage:

```bash
tw
```

Creates or attaches to the default `work` session.

```bash
tw work
```

Creates or attaches to a session named `work`.

```bash
tw bzor
tw client
tw ai-lab
tw scratch
```

Creates or attaches to named project sessions.

The underlying tmux command is:

```bash
tmux new-session -A -s work
```

Meaning:

```text
new-session    create a new tmux session
-A             attach if the session already exists
-s work        name the session "work"
```

## Sessions

List active sessions:

```bash
tmux ls
```

Create a new named session:

```bash
tmux new-session -s work
```

Create or attach to a named session:

```bash
tmux new-session -A -s work
```

Attach to an existing session:

```bash
tmux attach -t work
```

Detach from the current session:

```text
Ctrl-b d
```

Kill a session:

```bash
tmux kill-session -t work
```

Kill all tmux sessions:

```bash
tmux kill-server
```

## Prefix Key

The default tmux prefix is:

```text
Ctrl-b
```

Most tmux commands start by pressing:

```text
Ctrl-b
```

Then pressing another key.

Example:

```text
Ctrl-b c
```

Creates a new tmux window.

## Windows

tmux windows are like tabs inside a tmux session.

Create a new window:

```text
Ctrl-b c
```

Go to next window:

```text
Ctrl-b n
```

Go to previous window:

```text
Ctrl-b p
```

Go to a specific window by number:

```text
Ctrl-b 0
Ctrl-b 1
Ctrl-b 2
```

Rename current window:

```text
Ctrl-b ,
```

Close current window:

```text
exit
```

or:

```text
Ctrl-b &
```

## Panes

Panes split the current tmux window into multiple terminal areas.

Split vertically:

```text
Ctrl-b %
```

Split horizontally:

```text
Ctrl-b "
```

Move between panes:

```text
Ctrl-b arrow-key
```

Close current pane:

```text
exit
```

or:

```text
Ctrl-b x
```

Zoom current pane fullscreen:

```text
Ctrl-b z
```

Press again to unzoom.

## Custom Pane Bindings

In my tmux config, I may remap splits to easier keys:

```tmux
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %
```

With that config:

```text
Ctrl-b |
```

Splits vertically.

```text
Ctrl-b -
```

Splits horizontally.

I may also add Vim-style pane navigation:

```tmux
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

Then:

```text
Ctrl-b h
Ctrl-b j
Ctrl-b k
Ctrl-b l
```

Moves between panes.

## Copy Mode

Enter copy/scroll mode:

```text
Ctrl-b [
```

Move around with arrow keys or Vim keys if `mode-keys vi` is enabled.

Quit copy mode:

```text
q
```

Recommended config:

```tmux
setw -g mode-keys vi
```

## Reload tmux Config

After editing `~/.tmux.conf`, reload it from inside tmux:

```text
Ctrl-b :
```

Then type:

```tmux
source-file ~/.tmux.conf
```

A better custom binding:

```tmux
bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"
```

Then reload with:

```text
Ctrl-b r
```

## Useful Config Defaults

A simple starting `tmux.conf`:

```tmux
set -g mouse on
set -g history-limit 50000

setw -g mode-keys vi

bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"

bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

## Recommended Project Layout

For coding + AI engineering:

```text
1: editor     nvim
2: shell      git, scripts, commands
3: server     npm run dev / vite / backend
4: claude     Claude Code
5: codex      Codex CLI
```

Example:

```bash
tw ai-engineering-setup
```

Then inside tmux:

```text
Ctrl-b ,      rename first window to editor
Ctrl-b c      create a new window
Ctrl-b ,      rename it server
Ctrl-b c      create a new window
Ctrl-b ,      rename it claude
Ctrl-b c      create a new window
Ctrl-b ,      rename it codex
```

## Daily Workflow

Start or attach to a project session:

```bash
tw work
```

or:

```bash
tw ai-engineering-setup
```

Open Neovim in the editor window:

```bash
nvim
```

Create a new window for the dev server:

```text
Ctrl-b c
```

Rename it:

```text
Ctrl-b ,
```

Start the server:

```bash
npm run dev
```

Create another window for Claude Code:

```text
Ctrl-b c
```

Run:

```bash
claude
```

Create another window for Codex:

```text
Ctrl-b c
```

Run:

```bash
codex
```

Detach when done:

```text
Ctrl-b d
```

Later, resume with:

```bash
tw work
```

## Most Common Commands

```text
Ctrl-b d      detach session
Ctrl-b c      new window
Ctrl-b n      next window
Ctrl-b p      previous window
Ctrl-b ,      rename window
Ctrl-b &      close window
Ctrl-b %      vertical split
Ctrl-b "      horizontal split
Ctrl-b x      close pane
Ctrl-b z      zoom pane
Ctrl-b [      copy/scroll mode
Ctrl-b r      reload config, if custom binding exists
```

## Notes

tmux sessions persist after closing the terminal window.

This means I can:

```bash
tw work
```

Start working, then detach:

```text
Ctrl-b d
```

Later I can reconnect:

```bash
tw work
```

and my windows, panes, and running processes are still there.
