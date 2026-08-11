# AI agent workflow

Treat each agent as a project-scoped terminal peer.

1. Start the agent from the project root so repository instructions and paths
   resolve correctly.
2. Give it an outcome, relevant constraints, and the verification command. Keep
   credentials and machine-private notes outside the repository.
3. Let the agent inspect before editing. Review its diff and preserve unrelated
   worktree changes.
4. Require the narrowest meaningful tests, then run the repository-wide health
   check when configuration or setup scripts change.
5. Commit cohesive changes only after reviewing generated files and secrets.

On Windows, `herdr-sessionizer` opens Neovim, a shell, and Codex for a selected
project. `herdr-work` creates the configured workspaces without starting an
agent in every one. On macOS, the Herdr shell scripts provide the same pattern;
the retained tmux launchers use the older project-window workflow.

Claude Code receives the repository-managed settings file. On Windows its
status line also writes supported context and rate-limit data to the local
Zebar widget cache. That cache is generated machine state and is ignored by
Git.
