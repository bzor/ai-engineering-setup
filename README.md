# AI Engineering Setup

My reproducible coding environment and learning journal for AI-assisted engineering on macOS and native Windows 11.

Core tools:

- WezTerm
- Herdr (active multiplexer)
- Neovim
- Claude Code
- Codex
- Zebar usage widget on Windows
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

- Windows 11: WezTerm → PowerShell 7 → Herdr → Neovim + native Codex → Houdini, with an optional Zebar Codex/Claude usage widget. See [install/windows.md](install/windows.md).
- macOS: zsh → Kitty or WezTerm → tmux/Herdr → Neovim. See [install/macos.md](install/macos.md).

Windows setup never requires WSL, tmux, or Kitty. WezTerm is the Windows terminal and Herdr is the only active Windows multiplexer.

## Quick start

On Windows, open PowerShell 7 in the cloned repository:

```powershell
pwsh -NoProfile -File .\scripts\bootstrap-windows.ps1
pwsh -NoProfile -File .\scripts\link-configs-windows.ps1
pwsh -NoProfile -File .\scripts\check-health-windows.ps1
```

On macOS, see the manual prerequisites and linking caveats in
[install/macos.md](install/macos.md) before running the scripts.

Daily commands and keybindings are collected in
[docs/cheatsheets/main.md](docs/cheatsheets/main.md). Project and agent routines
live under [docs/workflows](docs/workflows).
