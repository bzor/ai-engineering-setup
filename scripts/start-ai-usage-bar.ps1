[CmdletBinding()]
param([switch]$RegisterStartup)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$collector = Join-Path $PSScriptRoot 'ai-usage-collector.js'

if ($RegisterStartup) {
    $startup = [Environment]::GetFolderPath('Startup')
    $shortcutPath = Join-Path $startup 'AI Usage Bar.lnk'
    $pwsh = (Get-Command pwsh -ErrorAction Stop).Source
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $pwsh
    $shortcut.Arguments = "-NoProfile -WindowStyle Hidden -File `"$PSCommandPath`""
    $shortcut.WorkingDirectory = $repo
    $shortcut.Description = 'Start the Codex and Claude usage bar'
    $shortcut.Save()
    Write-Host "Registered Windows startup shortcut: $shortcutPath"
}

if (-not (Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like '*ai-usage-collector.js*' })) {
    Start-Process node -ArgumentList @($collector) -WindowStyle Hidden
}

$zebar = Get-Command zebar -ErrorAction SilentlyContinue
if (-not $zebar) { throw 'Zebar is not installed or is not on PATH.' }
& $zebar.Source startup -q
