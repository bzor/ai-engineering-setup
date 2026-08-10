# AI Engineering Setup

My reproducible coding environment and learning journal for AI-assisted engineering on macOS and native Windows 11.

Core tools:

- WezTerm
- Herdr (active multiplexer)
- Neovim
- Claude Code
- Codex
- PowerShell 7 on Windows; zsh on macOS
- winget on Windows; Homebrew on macOS

## Goals

- Build a fast terminal-native coding workflow
- Learn Neovim from first principles
- Use Herdr as the project cockpit
- Treat Claude Code and Codex as terminal-based coding agents
- Document setup decisions and learning progress
- Make the environment reproducible on a new machine

## Repo Layout

```text
configs/    tool configuration files
scripts/    setup and linking scripts
install/    installation notes
docs/       learning logs, decisions, cheatsheets, workflows
templates/  reusable project templates
notes/      scratch notes
```

## Platforms

- Windows 11: WezTerm → PowerShell 7 → Herdr → Neovim + native Codex → Houdini. See [install/windows.md](install/windows.md).
- macOS: the existing shell, tmux, Kitty, and Sketchybar files remain available as legacy/macOS-specific configuration.

Windows setup never requires WSL, tmux, or Kitty. WezTerm is the Windows terminal and Herdr is the only active Windows multiplexer.
