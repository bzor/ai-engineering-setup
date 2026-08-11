# Project bootstrap

Use this checklist when starting a repository that will be shared with coding
agents.

1. Create or clone the project under a configured project root (`~/Projects` or
   `~/Repos` by default).
2. Add the language's generated files to `.gitignore`; the Node starting point
   is [`templates/gitignore-node.md`](../../templates/gitignore-node.md).
3. Copy and adapt [`templates/README-project.md`](../../templates/README-project.md).
4. Add the appropriate agent instructions from
   [`templates/AGENTS.md`](../../templates/AGENTS.md) and/or
   [`templates/CLAUDE.md`](../../templates/CLAUDE.md).
5. Record the real build, test, lint, and formatting commands in those files.
6. Initialize Git, make a baseline commit, and verify the working tree is clean.
7. Add the project to the platform launcher if it belongs in the daily lineup:
   `configs/herdr/projects.windows.psd1` on Windows, or the `PROJECTS` array in
   the macOS launcher scripts.

Open an ad-hoc project with `herdr-sessionizer` (or `prefix f`). On macOS, the
legacy tmux equivalent is `tmux-sessionizer`.
