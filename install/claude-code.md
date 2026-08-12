# claude code

Settings live in `configs/claude/settings.macos.json`, symlinked to
`~/.claude/settings.json` by `scripts/link-configs.sh`. Only the settings
*file* is linked — Claude keeps sessions, projects and credentials in
`~/.claude` alongside it.

## Why macOS gets its own file

Windows links `configs/claude/settings.json` instead. Most of the file is
portable and identical either way (`model`, `effortLevel`, `theme`, `tui`,
attribution, the skip flags), but two keys point at bash scripts that don't
exist on Windows:

- `statusLine.command` → `~/.local/bin/claude-statusline`, a bash + jq script
- `hooks` → one entry runs `~/.claude/hooks/herdr-agent-state.sh`

Those don't fail because of path syntax — there's no bash or jq on a native
Windows box to run them at all. Porting them means PowerShell twins, not a
tweak to the JSON. The other three hooks (`gh-axi`, `chrome-devtools-axi`,
`lavish-axi`) are node CLIs and work on both.

`~/.claude/hooks/herdr-agent-state.sh` is **not** tracked here yet, so a fresh
machine gets settings that reference a hook script it doesn't have.

## statusline

`configs/claude/statusline.sh` (linked to `~/.local/bin/claude-statusline`)
prints model, effort, context use and limit usage:

```
Opus 5 · effort:high · ctx:45k/200k · 5h:8% · resets:2h4m · 7d:2%
```

It also caches the `rate_limits` block to `~/.cache/ai-usage/claude.json`,
which is the only way those numbers reach anything outside a running session —
sketchybar's usage item reads that file. See `install/sketchybar.md`.

## Editing settings

Because `~/.claude/settings.json` is a symlink into this repo, changing a
setting from inside Claude Code (`/config`, model or theme switches) writes
straight into the working tree and shows up in `git status`. That's the point,
but it does mean routine toggles arrive as diffs. If an app ever replaces the
symlink with a real file, re-run `scripts/link-configs.sh` to reattach it —
check with:

```bash
ls -l ~/.claude/settings.json   # want a -> into this repo
```
