[CmdletBinding()]
param([switch]$RegisterStartup)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$collector = Join-Path $PSScriptRoot 'ai-usage-collector.js'

if ($RegisterStartup) {
    $taskName = 'AI Usage Collector'
    $node = (Get-Command node -ErrorAction Stop).Source
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $action = New-ScheduledTaskAction `
        -Execute $node `
        -Argument "`"$collector`"" `
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

    Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like '*ai-usage-collector.js*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
    Start-ScheduledTask -TaskName $taskName
    Write-Host "Registered and started scheduled task: $taskName"
}

if (-not $RegisterStartup -and -not (Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like '*ai-usage-collector.js*' })) {
    Start-Process node -ArgumentList @($collector) -WindowStyle Hidden
}

$zebar = Get-Command zebar -ErrorAction SilentlyContinue
if (-not $zebar) { throw 'Zebar is not installed or is not on PATH.' }
& $zebar.Source startup -q
