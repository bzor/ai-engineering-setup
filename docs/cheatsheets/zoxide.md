# zoxide

Smarter cd. Type fragments, not paths — it matches against every directory
you've ever visited, ranked by frequency + recency.

```
z nicole            jump to ~/Projects/nicole-film from anywhere
z film              fragments match anywhere in the path
z proj anim         multiple words: all must match, in order
z ..                plain cd still works (z falls back to cd behavior)
z -                 previous directory
zi                  interactive: fzf picker over ranked matches
zi film             fzf picker pre-filtered to "film"
```

## Managing the database

```
zoxide query film           show what a keyword would resolve to
zoxide query --list         dump all known dirs (ranked)
zoxide add <path>           teach it a dir without visiting
zoxide remove <path>        forget a dir (e.g. deleted projects)
```

## Notes

- Ties break toward the more recently visited dir; keep using it and the
  ranking sorts itself out.
- `z foo<Space><Tab>` completes from the database interactively.
- yazi understands the same database: press `z` inside yazi for a zoxide jump.
