# Daily coding session

## Windows

1. Start WezTerm and run `herdr` to attach to the persistent session.
2. Run `herdr-work` to create any missing active-project workspaces.
3. Use `prefix w` to select a workspace or `prefix f` to open another project.
4. Work in Neovim and start Codex only in the project panes that need an agent.
5. Detach with `prefix q`; Herdr keeps the session running.

The optional usage widget starts at sign-in after running
`pwsh -NoProfile -File .\scripts\start-ai-usage-bar.ps1 -RegisterStartup` once.
Claude limits appear after a Claude Code session has emitted its status-line
payload.

## macOS

Use `tmux-work` for the established tmux lineup, or start `herdr` followed by
`herdr-work` for agent-aware workspaces. Run each multiplexer in its own terminal
window; do not nest them. Detach with the multiplexer-specific prefix command
and reattach later.

Across both platforms, `Space p f` finds files, `Space p s` searches project
text, `Space p y` opens Yazi from Neovim, and `y` opens Yazi from the shell.
