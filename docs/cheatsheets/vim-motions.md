
# Vim Motions Cheatsheet

Vim is built around composable editing commands.

The core idea:

```text
verb + motion
```

Examples:

```text
dw      delete word
cw      change word
y$      yank to end of line
d}      delete to next paragraph
ci"     change inside quotes
```

Instead of thinking “move cursor, select text, delete,” the goal is to think in small editing sentences.

## Modes

Normal mode:

```text
Esc
```

Insert before cursor:

```text
i
```

Insert after cursor:

```text
a
```

Append at end of line:

```text
A
```

Insert at beginning of line:

```text
I
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

## Basic Movement

Move left:

```text
h
```

Move down:

```text
j
```

Move up:

```text
k
```

Move right:

```text
l
```

The goal is to avoid arrow keys during practice so these become automatic.

## Word Movement

Move to next word:

```text
w
```

Move back one word:

```text
b
```

Move to end of word:

```text
e
```

Move by bigger WORDS, separated only by whitespace:

```text
W
B
E
```

Example:

```text
hello.world
```

`w` treats punctuation as breaks.

`W` jumps by whitespace-separated chunks.

## Line Movement

Start of line:

```text
0
```

First non-blank character:

```text
^
```

End of line:

```text
$
```

Go to specific column-ish movement with character search:

```text
f<char>
t<char>
F<char>
T<char>
```

Examples:

```text
f,    move forward to comma
t,    move forward until before comma
F)    move backward to )
T)    move backward until after )
```

Repeat last character search:

```text
;
```

Reverse last character search:

```text
,
```

## File Movement

Top of file:

```text
gg
```

Bottom of file:

```text
G
```

Go to line number:

```text
42G
```

Half-page down:

```text
Ctrl-d
```

Half-page up:

```text
Ctrl-u
```

Page down:

```text
Ctrl-f
```

Page up:

```text
Ctrl-b
```

## Search Movement

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

Search word under cursor backward:

```text
#
```

## Basic Operators

Delete:

```text
d
```

Change:

```text
c
```

Yank/copy:

```text
y
```

Visual select:

```text
v
```

Format/indent according to motion:

```text
=
```

The important idea is that operators want a motion.

Examples:

```text
dw      delete to next word
cw      change to next word
d$      delete to end of line
c$      change to end of line
y$      yank to end of line
dgg     delete to top of file
dG      delete to bottom of file
```

## Common Editing Commands

Delete current line:

```text
dd
```

Yank current line:

```text
yy
```

Change current line:

```text
cc
```

Paste after cursor/line:

```text
p
```

Paste before cursor/line:

```text
P
```

Undo:

```text
u
```

Redo:

```text
Ctrl-r
```

Repeat last change:

```text
.
```

Join current line with next line:

```text
J
```

## Text Objects

Text objects are one of the best parts of Vim.

They usually use:

```text
i    inside
a    around
```

Examples:

```text
iw      inside word
aw      around word
i"      inside double quotes
a"      around double quotes
i'      inside single quotes
a'      around single quotes
i(      inside parentheses
a(      around parentheses
i[      inside brackets
a[      around brackets
i{      inside braces
a{      around braces
ip      inside paragraph
ap      around paragraph
```

## Text Object Examples

Change inside word:

```text
ciw
```

Delete around word:

```text
daw
```

Change inside double quotes:

```text
ci"
```

Delete around double quotes:

```text
da"
```

Change inside parentheses:

```text
ci(
```

Yank inside braces:

```text
yi{
```

Delete a paragraph:

```text
dap
```

Change inside paragraph:

```text
cip
```

These are small editing sentences:

```text
ci"   change inside quotes
dap   delete around paragraph
yi(   yank inside parentheses
```

## Visual Mode

Start visual selection:

```text
v
```

Start linewise visual selection:

```text
V
```

After selecting text:

```text
d    delete selection
c    change selection
y    yank selection
>    indent selection
<    outdent selection
```

Move selected lines down:

```text
:m '>+1
```

Move selected lines up:

```text
:m '<-2
```

This can be mapped later for easier use.

## Visual Block (multi-cursor)

The native equivalent of VS Code's column / multi-cursor editing. Great for
inserting the same text down a column of rows at once.

Enter Visual Block mode:

```text
Ctrl-v
```

Then extend the block down with `j` (and `h`/`l` for width), and use:

```text
I    insert before the block, on every row
A    append after the block, on every row
c    change: delete the block, then type the replacement
d    delete the block (no insert)
```

Type your text, then press `Esc` — the edit applies to all rows at once.

Important: while typing you only see the change on the top row. It fans out to
the other rows the moment you hit `Esc`. That's expected.

Examples:

```text
Ctrl-v jjj I text Esc      insert "text" at the column, all 4 rows
Ctrl-v jjj A text Esc      append "text" at the column, all rows
Ctrl-v jjj $ A ; Esc       append ";" at the true end of each line (ragged lengths)
Ctrl-v jjj d               delete the column block
```

Reselect the last block:

```text
gv
```

For free-floating (non-columnar) multiple cursors like VS Code's `Cmd-D`, that's
not built in — the `vim-visual-multi` plugin does it. For column edits, `Ctrl-v`
+ `I`/`A` is all you need.

## Counts

Most motions and commands accept counts.

Move down 5 lines:

```text
5j
```

Move forward 3 words:

```text
3w
```

Delete 2 words:

```text
d2w
```

Delete 3 lines:

```text
3dd
```

Go to line 20:

```text
20G
```

## Practical Editing Patterns

Change a word:

```text
ciw
```

Delete a word:

```text
diw
```

Delete a word plus surrounding space:

```text
daw
```

Change inside quotes:

```text
ci"
```

Change inside parentheses:

```text
ci(
```

Delete to end of line:

```text
d$
```

Change to end of line:

```text
c$
```

Yank to end of line:

```text
y$
```

Delete current paragraph:

```text
dap
```

Search for a word:

```text
/word
```

Repeat the last change:

```text
.
```

## Leader Key

My Neovim leader key is:

```text
Space
```

Leader mappings are custom shortcuts that start with the leader key.

Example:

```text
Space p f
```

This means:

```text
press Space
then press p
then press f
```

It is not a simultaneous key chord.

Current useful leader mappings:

```text
Space p f    find project files
Space p s    search project text
Space p b    show open buffers
Space p h    search help docs
```

The pattern I’m using is:

```text
Space → category → action
```

For example:

```text
Space p f
```

means:

```text
leader → project → files
```

## Daily Practice Drill

For five minutes, practice only movement:

```text
h j k l
w b e
0 ^ $
gg G
/ n N
```

Then practice edits:

```text
dw
cw
ciw
ci"
ci(
dd
yy
p
u
Ctrl-r
.
```

The goal is not speed at first. The goal is to stop reaching for the mouse and arrow keys.

## Things to Memorize First

Highest priority:

```text
Esc       normal mode
i         insert before cursor
a         insert after cursor
o         new line below
h j k l   movement
w b e     word movement
0 ^ $     line movement
gg G      top/bottom of file
/         search
n N       search next/previous
dd        delete line
yy        yank line
p         paste
u         undo
Ctrl-r    redo
.         repeat
```

Then:

```text
dw
cw
ciw
ci"
ci(
d$
c$
dap
```

Once those feel natural, Vim starts becoming compositional instead of memorized.
