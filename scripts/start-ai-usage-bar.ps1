[CmdletBinding()]
param([switch]$RegisterStartup)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$collector = Join-Path $PSScriptRoot 'ai-usage-collector.js'
$launcher = Join-Path $PSScriptRoot 'run-hidden.vbs'

function Stop-Collector {
    Get-CimInstance Win32_Process -Filter "Name='node.exe' OR Name='wscript.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like '*ai-usage-collector.js*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

if ($RegisterStartup) {
    $taskName = 'AI Usage Collector'
    $node = (Get-Command node -ErrorAction Stop).Source
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    # A task that runs only while the user is logged on cannot suppress the
    # console window of a console program, so Task Scheduler running node.exe
    # directly leaves a blank terminal on the desktop for as long as the
    # collector lives. Windows Script Host is a GUI process, so node inherits a
    # hidden window from it; the launcher waits on node, which keeps the
    # single-instance and restart behaviour below working unchanged.
    $action = New-ScheduledTaskAction `
        -Execute (Join-Path $env:WINDIR 'System32\wscript.exe') `
        -Argument "`"$launcher`" `"$node`" `"$collector`"" `
        -WorkingDirectory $repo
    $logonTrigger = New-ScheduledTaskTrigger -AtLogOn -User $identity
    # A repeating trigger doubles as an independent watchdog. Task Scheduler
    # ignores it while the collector is healthy and starts a new instance on
    # the next tick if the process disappears for any reason.
    $watchdogTrigger = New-ScheduledTaskTrigger `
        -Once `
        -At (Get-Date).AddMinutes(1) `
        -RepetitionInterval (New-TimeSpan -Minutes 1) `
        -RepetitionDuration (New-TimeSpan -Days 3650)
    $principal = New-ScheduledTaskPrincipal `
        -UserId $identity `
        -LogonType Interactive `
        -RunLevel Limited
    $settings = New-ScheduledTaskSettingsSet `
        -StartWhenAvailable `
        -RestartCount 999 `
        -RestartInterval (New-TimeSpan -Minutes 1) `
        -ExecutionTimeLimit ([TimeSpan]::Zero) `
        -MultipleInstances IgnoreNew

    # Stop the old instance before replacing the definition, otherwise a
    # collector started by a previous action keeps running unsupervised.
    Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    Stop-Collector

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger @($logonTrigger, $watchdogTrigger) `
        -Principal $principal `
        -Settings $settings `
        -Description 'Keep the Codex and Claude usage collector running for Zebar.' `
        -Force | Out-Null

    # Remove the legacy one-shot shortcut. The scheduled task now owns the
    # collector lifecycle and restarts it if Node exits unexpectedly.
    $startup = [Environment]::GetFolderPath('Startup')
    $shortcutPath = Join-Path $startup 'AI Usage Bar.lnk'
    if (Test-Path -LiteralPath $shortcutPath) {
        Remove-Item -LiteralPath $shortcutPath -Force
    }

    Start-ScheduledTask -TaskName $taskName
    Write-Host "Registered and started scheduled task: $taskName"
}

if (-not $RegisterStartup -and -not (Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like '*ai-usage-collector.js*' })) {
    Start-Process node -ArgumentList @($collector) -WindowStyle Hidden
}

$zebar = Get-Command zebar -ErrorAction SilentlyContinue
if (-not $zebar) { throw 'Zebar is not installed or is not on PATH.' }
& $zebar.Source startup -q
