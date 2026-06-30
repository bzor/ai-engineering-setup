
# Neovim Cheatsheet

Neovim is my main terminal text editor. I’m building this setup from scratch so I understand each piece instead of relying on a full prebuilt distro.

## Mental Model

Neovim has a few important concepts:

```text
buffer   = an open file loaded into memory
window   = a visible view into a buffer
tab      = a layout/container of windows
```

This is different from VS Code, where tabs usually represent files.

In Neovim:

* I can have many buffers open.
* A window shows one buffer.
* Splits are multiple windows.
* Tabs are more like layout workspaces, not just file tabs.

## Opening Neovim

Open Neovim:

```bash
nvim
```

Open a specific file:

```bash
nvim README.md
```

Open the current project folder:

```bash
nvim .
```

## Saving and Quitting

Save current file:

```vim
:w
```

Quit current window:

```vim
:q
```

Save and quit:

```vim
:wq
```

Quit without saving:

```vim
:q!
```

Quit all windows:

```vim
:qa
```

Save all and quit:

```vim
:wqa
```

Important distinction:

```text
:wq   save/write file and quit
:q    quit the current window
:q!   quit without saving
```

For special buffers like `:Tutor`, help pages, plugin views, or scratch buffers, use:

```vim
:q
```

or:

```vim
:q!
```

not `:wq`.

## Modes

Normal mode:

```text
Esc
```

Insert mode before cursor:

```text
i
```

Insert mode after cursor:

```text
a
```

Open new line below:

```text
o
```

Open new line above:

```text
O
```

Visual mode:

```text
v
```

Visual line mode:

```text
V
```

Command mode:

```text
:
```

## Built-in File Browsing

Open netrw, the built-in file explorer:

```vim
:Ex
```

My mapping:

```text
Space p v
```

Meaning:

```text
leader → project → view
```

Common netrw controls:

```text
Enter   open file or directory
-       go up one directory
%       create new file
d       create new directory
D       delete file/directory
R       rename file/directory
```

## Opening Files

Open a file from inside Neovim:

```vim
:e README.md
```

Full command:

```vim
:edit README.md
```

Open a file in a horizontal split:

```vim
:split README.md
```

Open a file in a vertical split:

```vim
:vsplit README.md
```

## Buffers

List open buffers:

```vim
:ls
```

or:

```vim
:buffers
```

Switch to buffer by number:

```vim
:b 2
```

Switch to buffer by partial name:

```vim
:b invoice
```

Next buffer:

```vim
:bn
```

Previous buffer:

```vim
:bp
```

Delete/unload current buffer:

```vim
:bd
```

Useful mental model:

```text
:q    closes the current window/view
:bd   closes the current file/buffer
```

## Windows and Splits

Horizontal split:

```vim
:split
```

Vertical split:

```vim
:vsplit
```

Move between Neovim windows/splits:

```text
Ctrl-w h    move left
Ctrl-w j    move down
Ctrl-w k    move up
Ctrl-w l    move right
```

Close current split:

```vim
:q
```

Close all other splits:

```vim
:only
```

Resize splits:

```vim
:resize +5
:resize -5
:vertical resize +5
:vertical resize -5
```

## Leader Key

My leader key is:

```text
Space
```

Leader mappings are typed as sequences, not chords.

Example:

```text
Space p f
```

means:

```text
press Space
then press p
then press f
```

Pattern:

```text
Space → category → action
```

## Current Custom Mappings

Project view / netrw:

```text
Space p v    open project view
```

Telescope:

```text
Space p f    find project files
Space p s    search project text / live grep
Space p b    show open buffers
Space p h    search Neovim help docs
```

## Telescope

Telescope is my fuzzy finder for project navigation.

It helps with:

```text
finding files
searching text
switching buffers
searching help docs
```

Current mappings:

```text
Space p f    find project files
Space p s    search project text / live grep
Space p b    show open buffers
Space p h    search help docs
```

Useful Telescope controls:

```text
type text     filter results
Enter         open selected item
Ctrl-n        next result
Ctrl-p        previous result
Ctrl-v        open selected item in vertical split
Ctrl-x        open selected item in horizontal split
Esc           close picker
```

## Search

Search forward:

```text
/pattern
```

Search backward:

```text
?pattern
```

Next result:

```text
n
```

Previous result:

```text
N
```

Search word under cursor:

```text
*
```

Clear search highlight:

```vim
:noh
```

## Help

Open help:

```vim
:help
```

Open help for a specific command:

```vim
:help :w
```

Open help for a normal mode key:

```vim
:help w
```

Open help for options:

```vim
:help number
```

Search help with Telescope:

```text
Space p h
```

## Config Files

My Neovim config lives in this repo:

```text
configs/nvim/
  init.lua
  lua/
    bzor/
      init.lua
      remap.lua
      set.lua
      lazy.lua
```

The active config is symlinked to:

```text
~/.config/nvim
```

The root config file:

```text
configs/nvim/init.lua
```

loads:

```lua
require("bzor")
```

The module init file:

```text
configs/nvim/lua/bzor/init.lua
```

loads:

```lua
require("bzor.remap")
require("bzor.set")
require("bzor.lazy")
```

## Plugin Manager

I’m using:

```text
lazy.nvim
```

Open Lazy UI:

```vim
:Lazy
```

Sync plugins:

```text
S
```

inside the Lazy UI.

Health check:

```vim
:checkhealth lazy
```

Telescope health check:

```vim
:checkhealth telescope
```

## Daily Practice

A good short session:

```text
1. Open project with nvim
2. Use Space p f to open a file
3. Use Space p s to search project text
4. Edit one doc using normal Vim motions
5. Use :ls to inspect buffers
6. Use :bd to close unused buffers
7. Save with :w
8. Quit with :q
```

## Things to Remember

```text
Esc       return to normal mode
:w        save
:q        quit window
:wq       save and quit
:q!       quit without saving
:Ex       built-in file browser
:ls       list buffers
:b name   switch buffer
:bd       delete buffer
Space p f find files
Space p s search project
```
