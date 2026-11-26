# Native Windows Engineering Environment Plan

## Execution status (2026-08-09)

- [x] Phase 1 inventory completed; no unmanaged user configuration conflicts found.
- [x] Phases 2-6 repository layer, bootstrap, safe linking, PowerShell profile, and cross-platform WezTerm configuration completed.
- [x] Phase 7 native Neovim installed, synchronized, and checked headlessly; compiler-dependent enhancements remain optional and are documented.
- [x] Phase 8 Herdr Windows preview installed with Codex integration; config validates and Windows beta limitations are documented.
- [x] Phase 9 Houdini discovery/wrapper completed and version-only check passed with Houdini 22.0.368 selected.
- [x] Phase 9 license-consuming scene smoke test approved and passed with Houdini 22.0.368.
- [x] Phase 10 documentation and read-only health check completed.
- [x] Final safe command-line verification completed; interactive WezTerm/Herdr use remains a manual visual check.

## Launch prompt

After cloning this repository onto the Windows PC, open the repository in Codex and send:

> Execute `WINDOWS_NATIVE_SETUP_PLAN.md` end to end. Work phase by phase, make the repository changes, install or configure what is safe, and verify the result. This machine must remain native Windows: do not install, enable, or use WSL, tmux, or Kitty. Use WezTerm, PowerShell 7, Herdr, Neovim, native Codex, and native Houdini. Ask before any action that requires administrator access, installs preview software, changes execution policy, or could overwrite an existing user configuration.

## Objective

Create a reproducible, Windows-native version of this development environment with this stack:

```text
WezTerm -> PowerShell 7 -> Herdr -> Neovim + Codex -> Houdini
```

The finished setup must:

- Run directly on Windows 11 without WSL.
- Use Herdr as the only terminal multiplexer; do not install or configure tmux.
- Use WezTerm as the terminal; do not install or configure Kitty on Windows.
- Preserve the existing macOS setup and avoid breaking shared configurations.
- Give Codex a reliable PowerShell command for running Houdini Python scripts with `hython.exe`.
- Be idempotent: rerunning setup scripts must not duplicate PATH entries or destroy user configuration.
- Include a read-only health check that reports actionable failures.

## Reference points to re-verify on the PC

These links describe the intended platform choices as of August 2026. Re-open them before using version-specific install commands because package names and preview status can change.

- [Official Codex native Windows sandbox documentation](https://learn.chatgpt.com/docs/windows/windows-sandbox)
- [WezTerm native Windows installation](https://wezterm.org/install/windows.html)
- [Herdr native Windows beta](https://herdr.dev/docs/windows-beta/)
- [Herdr installation](https://herdr.dev/docs/install/)
- [Kitty installation platforms](https://sw.kovidgoyal.net/kitty/binary/)
- [SideFX Houdini command-line environment on Windows](https://www.sidefx.com/faq/question/how-do-i-set-up-the-houdini-environment-for-command-line-tools/)
- [SideFX Houdini Python command-line scripting](https://www.sidefx.com/docs/houdini/hom/commandline)

## Operating rules for Codex

1. Treat this document as an implementation task, not a request for another plan.
2. Start by reading `README.md`, `scripts/`, `configs/`, `install/`, and the current Git status.
3. Preserve unrelated or pre-existing changes. Never discard user work.
4. Use native PowerShell and Windows executables. Do not invoke `wsl.exe`, Bash, Cygwin, MSYS shells, tmux, or Kitty.
5. Prefer `winget` for stable Windows packages. Use another package manager only when `winget` cannot provide a suitable package, and explain why.
6. Resolve and verify current package IDs before installing; do not guess package identifiers.
7. Use official vendor sources for Codex, Herdr, Houdini, WezTerm, Neovim, and fonts.
8. Before executing a downloaded installer script, save it to a temporary file, inspect it, summarize what it does, and request approval.
9. Request approval before:
   - administrator/elevated commands;
   - installing Herdr's preview/beta Windows build;
   - changing PowerShell execution policy;
   - installing large compiler toolchains such as Visual Studio Build Tools;
   - overwriting or replacing an existing configuration file.
10. Do not install or alter Houdini licensing. Detect and report its state only.
11. Do not commit, push, delete legacy files, or open a pull request unless the user explicitly asks.
12. Update this document's checkboxes while working so an interrupted run can resume safely.

## Phase 1: Inventory the Windows machine

- [ ] Confirm the machine is Windows 11 and is not relying on WSL for this setup.
- [ ] Record the PowerShell version and edition using `$PSVersionTable`.
- [ ] Check whether `winget` is installed and functional.
- [ ] Check the current versions and resolved paths of:
  - `pwsh`
  - `git`
  - `wezterm`
  - `nvim`
  - `node` and `npm`
  - `rg`
  - `fd`
  - `fzf`
  - `zoxide`
  - `yazi`
  - `magick`
  - `codex`
  - `herdr`
- [ ] Inspect `%ProgramFiles%\Side Effects Software` and the Houdini Launcher for installed Houdini versions.
- [ ] Locate `hython.exe` without assuming a specific Houdini version.
- [ ] Inspect the existing PowerShell profile, WezTerm config, Neovim config, Herdr config, and user PATH.
- [ ] Report conflicts or existing unmanaged configurations before modifying them.

## Phase 2: Add the Windows-native repository layer

Create these files where useful, adapting names only when the repository already establishes a better convention:

```text
install/windows.md
scripts/bootstrap-windows.ps1
scripts/link-configs-windows.ps1
scripts/check-health-windows.ps1

configs/powershell/Microsoft.PowerShell_profile.ps1
configs/herdr/config.windows.toml
configs/herdr/herdr-sessionizer.ps1
configs/herdr/herdr-work.ps1
configs/windows/bin/herdr-sessionizer.cmd
configs/windows/bin/herdr-work.cmd

configs/houdini/Invoke-HoudiniPython.ps1
configs/houdini/examples/smoke-test.py
```

Requirements:

- [ ] Keep the current macOS files functional.
- [ ] Do not delete the existing tmux or Kitty files during this task; remove them from the documented active Windows stack and label them legacy/macOS-only where needed.
- [ ] Avoid copying platform-specific logic into shared files when a small platform-specific wrapper is clearer.
- [ ] Use `$PSScriptRoot`, `Join-Path`, and environment folders instead of hardcoded usernames or drive letters.
- [ ] Put all reusable PowerShell scripts under source control.

## Phase 3: Build an idempotent Windows bootstrap

Implement `scripts/bootstrap-windows.ps1`.

The script should:

- [ ] Require native Windows and fail clearly on other operating systems.
- [ ] Detect whether `winget` is available before using it.
- [ ] Resolve exact `winget` IDs before installation.
- [ ] Install only missing stable packages.
- [ ] Cover the intended tools:
  - PowerShell 7
  - Git
  - WezTerm
  - Neovim
  - Node.js LTS
  - ripgrep
  - fd
  - fzf
  - zoxide
  - Yazi
  - ImageMagick
  - an Iosevka Term Nerd Font or the closest verified Iosevka Nerd Font package
- [ ] Treat native Codex installation as a first-class check and use the current official OpenAI Windows installation path if Codex is missing.
- [ ] Treat Herdr separately because native Windows support is preview/beta. Download only from the official Herdr source, inspect the installer, and ask before executing it.
- [ ] Not install Houdini automatically. Link to the official Houdini Launcher instructions and report whether Houdini is present.
- [ ] Not install compiler/build toolchains without approval.
- [ ] Return a nonzero exit code if a required install fails.
- [ ] Produce a concise summary of installed, already-present, skipped, and failed components.

## Phase 4: Link configurations safely

Implement `scripts/link-configs-windows.ps1` with these destinations:

| Source | Windows destination |
| --- | --- |
| `configs/wezterm/wezterm.lua` | `%USERPROFILE%\.wezterm.lua` |
| `configs/nvim/` | `%LOCALAPPDATA%\nvim` |
| `configs/powershell/Microsoft.PowerShell_profile.ps1` | the appropriate current-user PowerShell profile |
| `configs/herdr/config.windows.toml` | `%APPDATA%\herdr\config.toml` |
| Yazi config/theme files | the current official Yazi Windows config directory |
| Windows command shims | a repository-managed user bin directory on PATH |

Safety requirements:

- [ ] Discover the correct PowerShell and Yazi locations instead of assuming them.
- [ ] Prefer links when Windows Developer Mode or existing permissions make them reliable.
- [ ] When links are unavailable, use a clearly reported managed-copy fallback.
- [ ] Never silently overwrite an unmanaged file or non-empty directory.
- [ ] Before replacing an existing managed target, create a timestamped backup or request approval.
- [ ] Add the user bin directory to the user PATH once, without duplicate entries.
- [ ] Make repeated runs safe and predictable.

## Phase 5: Create the PowerShell environment

Implement `configs/powershell/Microsoft.PowerShell_profile.ps1`.

- [ ] Set `EDITOR` and `VISUAL` to `nvim`.
- [ ] Initialize zoxide for PowerShell when installed.
- [ ] Add a `y` function that launches Yazi and changes the PowerShell working directory to Yazi's final directory on exit.
- [ ] Ensure repository-managed command shims are available on PATH.
- [ ] Keep startup quiet when optional tools are missing.
- [ ] Avoid changing execution policy from inside the profile.
- [ ] Avoid network calls or package installation during shell startup.
- [ ] Make profile reload safe.
- [ ] Verify a clean profile load in a new `pwsh` process.

## Phase 6: Make WezTerm cross-platform

Update `configs/wezterm/wezterm.lua` without breaking macOS.

- [ ] Detect the target platform using WezTerm's supported platform information.
- [ ] On Windows, launch `pwsh.exe -NoLogo` by default.
- [ ] Apply macOS-only settings only on macOS.
- [ ] Preserve the Black Metal/Gorgoroth visual direction.
- [ ] Configure the installed Iosevka Nerd Font explicitly after verifying its exact Windows family name.
- [ ] Preserve true color, sensible padding, and current tab behavior.
- [ ] Ensure Alt-based Herdr bindings are not consumed or remapped by WezTerm.
- [ ] Validate that WezTerm starts without configuration errors.

## Phase 7: Make Neovim work natively on Windows

Audit the existing Neovim configuration and keep changes minimal.

- [ ] Make the `telescope-fzf-native.nvim` build platform-aware. Do not assume `make` exists on Windows.
- [ ] Prefer a supported CMake build on Windows when the required compiler is available.
- [ ] If no compiler exists, keep Telescope usable without the native FZF extension and report the optional limitation.
- [ ] Do not install Visual Studio Build Tools without approval.
- [x] Verify `nvim-treesitter` compiler requirements and ask before installing a large toolchain. Resolved by dropping the plugin: its `master` branch is incompatible with Neovim 0.12 and no branch can build a parser without a toolchain, so highlighting now uses Neovim's bundled parsers.
- [ ] Confirm native Windows clipboard integration works with `unnamedplus`.
- [ ] Confirm Yazi launches from Neovim.
- [ ] Confirm ImageMagick is found as `magick` and that `image.nvim` behaves correctly in Windows WezTerm.
- [ ] Verify Markdown/Mermaid rendering dependencies. Keep them optional if the required renderer is unavailable.
- [ ] Run an appropriate headless plugin sync and a Neovim health check.
- [ ] Capture any non-blocking optional warnings in `install/windows.md`.

## Phase 8: Port the Herdr workflow to PowerShell

Use Herdr as the only multiplexer.

- [ ] Create a Windows Herdr config derived from the current `configs/herdr/config.toml` theme and keybindings.
- [ ] Set Herdr's Windows default shell to PowerShell 7.
- [ ] Preserve the `Ctrl-Space` prefix and the current pane/workspace navigation where Windows and WezTerm pass those keys reliably.
- [ ] Remove Kitty-specific assumptions from the Windows config.
- [ ] Configure the project launcher command so it works with Herdr's Windows command execution behavior.
- [ ] Implement `herdr-sessionizer.ps1` using native PowerShell:
  - search configurable project roots such as `~/Projects` and `~/Repos`;
  - select a project with `fzf`;
  - reuse an existing Herdr workspace by label;
  - otherwise create the familiar layout with Neovim on the left, a terminal at top-right, and Codex or an empty agent pane at bottom-right;
  - use `ConvertFrom-Json` instead of depending on `jq` for Herdr JSON.
- [ ] Implement `herdr-work.ps1` to create or reuse a configured list of active project workspaces without launching one agent per project.
- [ ] Add `.cmd` shims or another reliable PATH-based entry point so Herdr can invoke the PowerShell scripts.
- [ ] Keep project roots and the active-project list easy to customize without editing several files.
- [ ] Run `herdr config check` or the current equivalent.
- [ ] Install the Herdr Codex integration only after confirming Codex is installed and after user approval for the Windows beta.
- [ ] Document Herdr's Windows beta limitations honestly.

## Phase 9: Add native Houdini control for Codex

Implement `configs/houdini/Invoke-HoudiniPython.ps1`.

The wrapper should:

- [ ] Discover installed Houdini versions under the standard SideFX installation root.
- [ ] Select the newest installed version by default using version-aware sorting.
- [ ] Support an explicit Houdini version or explicit `hython.exe` override.
- [ ] Validate that the resolved executable is really `hython.exe`.
- [ ] Accept a Python script path and forward remaining arguments without unsafe string concatenation.
- [ ] Preserve stdout, stderr, and the Houdini process exit code.
- [ ] Handle spaces in Windows paths correctly.
- [ ] Never alter Houdini licensing or preferences.
- [ ] Provide clear errors for missing Houdini, missing `hython.exe`, or license checkout failure.

Create `configs/houdini/examples/smoke-test.py` that:

- [ ] imports `hou`;
- [ ] prints the Houdini application version;
- [ ] creates a minimal geometry network;
- [ ] saves a disposable test scene only to a caller-supplied path under the Windows temporary directory;
- [ ] exits nonzero on failure.

Verification:

- [ ] Run the wrapper in a version-only or import-only mode first.
- [ ] Request confirmation before checking out a Houdini license for a fuller smoke test if doing so may consume a limited license.
- [ ] If Houdini is not installed, leave the bridge implemented and document the exact remaining manual step.
- [ ] Keep live `hrpyc` control and a Houdini MCP server out of the initial setup unless the user asks for them separately.

## Phase 10: Documentation and health check

Implement `scripts/check-health-windows.ps1` as a read-only diagnostic.

It should report:

- [ ] Windows and PowerShell versions.
- [ ] Required command versions and resolved executable paths.
- [ ] Whether expected config links or managed copies point to this repository.
- [ ] Whether the user bin directory is present exactly once on PATH.
- [ ] Whether WezTerm can load its config.
- [ ] Whether the PowerShell profile loads cleanly.
- [ ] Whether Neovim can start headlessly and load the configuration.
- [ ] Whether Herdr can validate its config.
- [ ] Whether Codex is available natively.
- [ ] Installed Houdini versions and the selected `hython.exe`.
- [ ] Required failures separately from optional warnings.
- [ ] A nonzero exit code when required checks fail.

Update documentation:

- [ ] Add `install/windows.md` with install, linking, verification, update, and recovery instructions.
- [ ] Update `README.md` to describe both macOS and native Windows support.
- [ ] Make Herdr the documented active multiplexer.
- [ ] Remove tmux from the current core workflow while keeping legacy files untouched during this task.
- [ ] State clearly that Kitty is macOS/Linux-only and WezTerm is the Windows terminal.
- [ ] Explain how to run the Houdini wrapper from Codex or PowerShell.
- [ ] Document which steps require administrator approval or manual GUI interaction.

## Final verification

Run all checks that are safe on the machine:

```powershell
pwsh -NoProfile -File .\scripts\check-health-windows.ps1
pwsh -NoProfile -Command ". `$PROFILE; 'profile-ok'"
nvim --headless "+checkhealth" "+qa"
herdr config check
codex --version
git diff --check
git status --short
```

Adapt commands only when current tool versions require a documented equivalent.

## Acceptance criteria

The task is complete when:

- [ ] No part of the Windows setup requires or invokes WSL, tmux, or Kitty.
- [ ] WezTerm opens directly into PowerShell 7 without configuration errors.
- [ ] Herdr starts with the intended theme, keys, and PowerShell panes.
- [ ] The PowerShell project launcher can create or reuse a Herdr workspace.
- [ ] Neovim starts natively and core navigation/search features work.
- [ ] Codex runs natively and is visible to Herdr.
- [ ] The Houdini wrapper locates `hython.exe` and either passes its smoke test or reports the exact external blocker.
- [ ] Bootstrap and linking scripts can be run twice without duplication or data loss.
- [ ] The health check distinguishes required failures from optional limitations.
- [ ] macOS configurations remain intact.
- [ ] Documentation is sufficient to reproduce the setup on another Windows 11 PC.

## Handoff format

When finished, Codex should report:

1. Files created and changed.
2. Software installed, skipped, or awaiting approval.
3. Verification commands run and their outcomes.
4. Any Herdr Windows beta limitations encountered.
5. Houdini versions detected and the selected `hython.exe`.
6. Any remaining manual steps.
7. The final `git status --short` output.
