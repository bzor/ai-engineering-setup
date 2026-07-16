# tmux Cheatsheet

tmux is a terminal multiplexer. It lets me create persistent terminal sessions with multiple windows and panes inside a single terminal window.

The mental model — one `work` session, one window per project:

```text
work session
  ├─ window 1: ai-engineering-setup    nvim | claude / terminal
  ├─ window 2: hammerworth             nvim | claude / terminal
  ├─ window 3: small-omens             ...
  └─ window n: (any project, via prefix f)
```

## The `work` Session (`tmux-work`)

The whole environment is built by one script, `configs/tmux/tmux-work.sh`
(on PATH as `tmux-work`):

```bash
tmux-work
```

First run: creates the `work` session with a window per project in the
script's `PROJECTS` array, each laid out with nvim, claude, and a spare
terminal, then attaches. Any later run just re-attaches — windows, panes,
and running processes survive detaching or closing the terminal.

Edit the `PROJECTS` array in the script to change the everyday lineup.

For anything not in the list, `prefix f` fuzzy-picks any project under
`~/Projects` or `~/Repos` and opens it as a new window in the same session
(jumping to it instead if it's already open).

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

My prefix is:

```text
Ctrl-Space    (primary)
Ctrl-b        (tmux default, still works as secondary)
```

Most tmux commands start with the prefix, then another key.

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

## Daily Workflow

Start (or re-attach to) the work session from a plain shell:

```bash
tmux-work
```

Every active project is already a window with nvim, claude, and a spare
terminal. Jump between projects with:

```text
prefix 1..9       go to window by number
prefix n / p      next / previous window
prefix f          fuzzy-open any other project as a new window
```

Need an extra pane for a dev server or one-off command? Split inside the
project's window:

```text
prefix |          split right
prefix -          split down
```

Detach when done:

```text
prefix d
```

Everything keeps running; `tmux-work` later drops you right back in.

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

This means I can start working, detach with `prefix d` (or just close the
terminal), and later run:

```bash
tmux-work
```

and my windows, panes, and running processes are still there.
