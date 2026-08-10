# Windows sandbox troubleshooting

## Status

Resolved on 2026-08-10. After installing the conventional MSI distribution and
fully restarting the Codex/ChatGPT desktop application, Codex launched:

```text
C:\Program Files\PowerShell\7\pwsh.exe
```

The native Windows sandbox can now run shell commands. The original failure and
resolution are retained below for future troubleshooting.

## Original issue

Codex could not launch any shell command through the native Windows sandbox.
This affected even read-only commands such as:

```powershell
Get-Location
git status --short
rg --files docs
```

Each command failed before PowerShell started, so this was not a Git, ripgrep,
repository, or workspace-file permission problem.

## Observed error

```text
windows sandbox: CreateProcessAsUserW failed: -1073283067
(Win32 error -1073283067)
```

The attempted executable was:

```text
C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.4.0_x64__8wekyb3d8bbwe\pwsh.exe
```

The numeric result maps to `0xC0070005`, which represents Windows error 5:
access denied. The likely issue is that the sandbox's restricted process token
cannot launch the Microsoft Store-packaged PowerShell executable from
`WindowsApps`.

## Recommended fix

1. Install or repair the non-Store PowerShell distribution (MSI or WinGet).
2. Verify outside Codex that it runs:

   ```powershell
   & 'C:\Program Files\PowerShell\7\pwsh.exe' -NoProfile -Command Get-Location
   ```

3. Check which executable Windows resolves:

   ```powershell
   where.exe pwsh
   Get-Command pwsh | Format-List Source
   ```

4. Ensure `C:\Program Files\PowerShell\7` precedes the WindowsApps alias in
   `PATH`, or disable the `pwsh.exe` App Execution Alias.
5. Fully quit and restart the Codex/ChatGPT desktop application so it receives
   the updated environment. Restart Windows if Codex still selects the old
   packaged executable.

If the non-Store executable is already selected and process creation still
returns access denied, investigate endpoint security, Windows application
control, antivirus, or organization policy blocking restricted-token process
creation.

## Verification after restart

Codex successfully ran these commands without modifying files:

```powershell
Get-Location
git status --short
rg --files docs
```

The running process and executable resolution both reported the conventional
installation:

```text
PROCESS_PATH=C:\Program Files\PowerShell\7\pwsh.exe
PS_VERSION=7.6.4
where.exe pwsh -> C:\Program Files\PowerShell\7\pwsh.exe
Get-Command pwsh -All -> C:\Program Files\PowerShell\7\pwsh.exe
```

`Get-Location`, `git status --short`, and `rg --files docs` all completed with
exit code 0. This confirms that the sandbox process-creation failure is fixed.

If this failure recurs, preserve the complete error, including the executable
path, `cwd`, numeric result, and creation flags, for OpenAI Support or local
policy troubleshooting.

## Session notes

- Workspace: `E:\Projects\ai-engineering-setup`
- Date observed: 2026-08-10
- All attempted diagnostics were read-only.
- No workspace files were modified during the failed sandbox tests.
- This document was added directly because the sandbox could not start a shell.

## Resolution

PowerShell 7 was initially installed only as the Microsoft Store/MSIX package.
The following checks confirmed that the conventional installation was absent:

```powershell
Test-Path 'C:\Program Files\PowerShell\7\pwsh.exe'
where.exe pwsh
Get-Command pwsh -All | Select-Object Source
```

`Test-Path` returned `False`, and executable resolution returned only paths under
`C:\Program Files\WindowsApps` and the per-user `WindowsApps` alias. A normal
WinGet install with `--installer-type wix` detected the existing MSIX package
and did not install the MSI build. The successful command was:

```powershell
winget install --id Microsoft.PowerShell --exact --source winget --installer-type wix --scope machine --force
```

WinGet installed `PowerShell-7.6.4-win-x64.msi`, after which this check returned
`True`:

```powershell
Test-Path 'C:\Program Files\PowerShell\7\pwsh.exe'
```

After the Codex/ChatGPT desktop application was fully restarted, the sandbox
selected `C:\Program Files\PowerShell\7\pwsh.exe`, and all verification commands
completed successfully.

## Separate profile warning

The sandbox reports `ConstrainedLanguage` as its PowerShell language mode and
prints this warning after otherwise successful commands:

```text
Microsoft.PowerShell_profile.ps1: Cannot dot-source this command because it was
defined in a different language mode. To invoke this command without importing
its contents, omit the '.' operator.
```

This warning does not prevent commands from running and is separate from the
resolved `CreateProcessAsUserW` failure. The PowerShell profile should be
reviewed independently if clean shell output is desired.
