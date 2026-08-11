[CmdletBinding()]
param([switch]$CopyOnly)
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'This linker requires native Windows.' }
$repo = Split-Path $PSScriptRoot -Parent
$managedMarker = '.ai-engineering-setup-managed'

function Set-ManagedTarget([string]$Source, [string]$Destination, [switch]$Directory) {
    $Source = (Resolve-Path -LiteralPath $Source).Path
    $parent = Split-Path $Destination -Parent
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    if (Test-Path -LiteralPath $Destination) {
        $item = Get-Item -Force -LiteralPath $Destination
        $sameLink = $item.LinkType -and (($item.Target | ForEach-Object { [IO.Path]::GetFullPath($_) }) -contains $Source)
        $marker = if ($Directory) { Join-Path $Destination $managedMarker } else { "$Destination$managedMarker" }
        if ($sameLink) { Write-Host "linked: $Destination"; return }
        if (-not (Test-Path -LiteralPath $marker)) { throw "Refusing to overwrite unmanaged target: $Destination" }
        $unchanged = if ($Directory) {
            $sourceFiles = @(Get-ChildItem -LiteralPath $Source -File -Recurse | Where-Object Name -NE 'usage.json' | ForEach-Object {
                $relative = [IO.Path]::GetRelativePath($Source, $_.FullName)
                "$relative|$((Get-FileHash -LiteralPath $_.FullName).Hash)"
            })
            $targetFiles = @(Get-ChildItem -LiteralPath $Destination -File -Recurse | Where-Object { $_.Name -notin @($managedMarker, 'usage.json') } | ForEach-Object {
                $relative = [IO.Path]::GetRelativePath($Destination, $_.FullName)
                "$relative|$((Get-FileHash -LiteralPath $_.FullName).Hash)"
            })
            (Compare-Object $sourceFiles $targetFiles).Count -eq 0
        } else {
            (Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash
        }
        if ($unchanged) { Write-Host "managed copy current: $Destination"; return }
        $backup = "$Destination.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Move-Item -LiteralPath $Destination -Destination $backup
        if (-not $Directory) { Remove-Item -LiteralPath $marker -ErrorAction SilentlyContinue }
        Write-Host "backup: $backup"
    }
    if (-not $CopyOnly) {
        try {
            New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -ErrorAction Stop | Out-Null
            Write-Host "linked: $Destination"; return
        } catch { Write-Warning "Link unavailable for $Destination; using managed copy." }
    }
    if ($Directory) { Copy-Item -LiteralPath $Source -Destination $Destination -Recurse; New-Item -ItemType File -Path (Join-Path $Destination $managedMarker) | Out-Null }
    else { Copy-Item -LiteralPath $Source -Destination $Destination; New-Item -ItemType File -Path "$Destination$managedMarker" | Out-Null }
    Write-Host "copied: $Destination"
}

Set-ManagedTarget (Join-Path $repo 'configs\wezterm\wezterm.lua') (Join-Path $HOME '.wezterm.lua')
Set-ManagedTarget (Join-Path $repo 'configs\nvim') (Join-Path $env:LOCALAPPDATA 'nvim') -Directory
Set-ManagedTarget (Join-Path $repo 'configs\powershell\Microsoft.PowerShell_profile.ps1') $PROFILE.CurrentUserCurrentHost
Set-ManagedTarget (Join-Path $repo 'configs\herdr\config.windows.toml') (Join-Path $env:APPDATA 'herdr\config.toml')
Set-ManagedTarget (Join-Path $repo 'configs\claude\settings.json') (Join-Path $HOME '.claude\settings.json')
$zebarRoot = Join-Path $HOME '.glzr\zebar'
$zebarTarget = Join-Path $zebarRoot 'ai-usage-bar'
Set-ManagedTarget (Join-Path $repo 'configs\zebar\ai-usage-bar') $zebarTarget -Directory
# Zebar treats every direct child of its config root as a widget pack. Preserve
# managed backups outside that scan root so stale copies cannot launch.
$zebarBackupRoot = Join-Path $HOME '.glzr\config-backups\zebar'
$zebarBackups = @(Get-ChildItem -LiteralPath $zebarRoot -Directory -Filter 'ai-usage-bar.backup-*' -ErrorAction SilentlyContinue)
if ($zebarBackups.Count) {
    New-Item -ItemType Directory -Path $zebarBackupRoot -Force | Out-Null
    foreach ($backup in $zebarBackups) {
        Move-Item -LiteralPath $backup.FullName -Destination $zebarBackupRoot
        Write-Host "moved Zebar backup outside widget scan root: $($backup.Name)"
    }
}
$yaziConfig = if ($env:YAZI_CONFIG_HOME) { $env:YAZI_CONFIG_HOME } else { Join-Path $env:APPDATA 'yazi\config' }
Set-ManagedTarget (Join-Path $repo 'configs\yazi\theme.toml') (Join-Path $yaziConfig 'theme.toml')
Set-ManagedTarget (Join-Path $repo 'configs\yazi\yazi.toml') (Join-Path $yaziConfig 'yazi.toml')

$bin = Join-Path $repo 'configs\windows\bin'
$userPath = [Environment]::GetEnvironmentVariable('Path','User')
$parts = @($userPath -split ';' | Where-Object { $_ })
if (($parts | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') }).Count -eq 0) {
    [Environment]::SetEnvironmentVariable('Path', (($parts + $bin) -join ';'), 'User')
    Write-Host "PATH added: $bin"
} else { Write-Host "PATH present: $bin" }
if (($env:Path -split ';') -notcontains $bin) { $env:Path = "$bin;$env:Path" }
