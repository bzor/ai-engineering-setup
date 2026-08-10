[CmdletBinding()]
param()
$repo = Split-Path $PSScriptRoot -Parent
$env:Path = "$([Environment]::GetEnvironmentVariable('Path','Machine'));$([Environment]::GetEnvironmentVariable('Path','User'))"
$requiredFailures = [Collections.Generic.List[string]]::new()
$warnings = [Collections.Generic.List[string]]::new()
function Check-Command([string]$Name, [bool]$Required=$true) {
    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $command) { if ($Required) { $requiredFailures.Add("Missing command: $Name") } else { $warnings.Add("Missing optional command: $Name") }; return }
    $version = try { (& $command.Source --version 2>&1 | Select-Object -First 1) } catch { 'version unavailable' }
    Write-Host "$Name`t$($command.Source)`t$version"
}
Write-Host "Windows $([Environment]::OSVersion.Version) / PowerShell $($PSVersionTable.PSVersion) $($PSVersionTable.PSEdition)"
foreach ($name in 'pwsh','git','wezterm','nvim','node','npm','rg','fd','fzf','zoxide','yazi','magick','codex') { Check-Command $name }
Check-Command herdr $false

$targets = @(
    @{ D=Join-Path $HOME '.wezterm.lua'; S=Join-Path $repo 'configs\wezterm\wezterm.lua' },
    @{ D=Join-Path $env:LOCALAPPDATA 'nvim'; S=Join-Path $repo 'configs\nvim' },
    @{ D=$PROFILE.CurrentUserCurrentHost; S=Join-Path $repo 'configs\powershell\Microsoft.PowerShell_profile.ps1' },
    @{ D=Join-Path $env:APPDATA 'herdr\config.toml'; S=Join-Path $repo 'configs\herdr\config.windows.toml' }
)
foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target.D)) { $requiredFailures.Add("Missing config target: $($target.D)"); continue }
    $item = Get-Item -Force -LiteralPath $target.D
    if ($item.LinkType -and (($item.Target | ForEach-Object {[IO.Path]::GetFullPath($_)}) -contains [IO.Path]::GetFullPath($target.S))) { Write-Host "config linked: $($target.D)" }
    elseif ((Test-Path -LiteralPath "$($target.D).ai-engineering-setup-managed") -or (Test-Path -LiteralPath (Join-Path $target.D '.ai-engineering-setup-managed'))) { Write-Host "config managed copy: $($target.D)" }
    else { $requiredFailures.Add("Unmanaged config target: $($target.D)") }
}
$bin = Join-Path $repo 'configs\windows\bin'
$count = @([Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_.TrimEnd('\') -ieq $bin.TrimEnd('\') }).Count
if ($count -ne 1) { $requiredFailures.Add("Repository bin occurs $count times in user PATH (expected once).") }

if (Get-Command pwsh -ErrorAction SilentlyContinue) { & pwsh -NoProfile -Command ". '$($PROFILE.CurrentUserCurrentHost.Replace("'","''"))'; 'profile-ok'"; if ($LASTEXITCODE) { $requiredFailures.Add('PowerShell profile failed to load.') } }
if (Get-Command wezterm -ErrorAction SilentlyContinue) { & wezterm --config-file (Join-Path $repo 'configs\wezterm\wezterm.lua') ls-fonts *> $null; if ($LASTEXITCODE) { $requiredFailures.Add('WezTerm rejected its configuration.') } }
if (Get-Command nvim -ErrorAction SilentlyContinue) { & nvim --headless '+qa'; if ($LASTEXITCODE) { $requiredFailures.Add('Neovim failed headlessly.') } }
if (Get-Command herdr -ErrorAction SilentlyContinue) {
    & herdr config check
    if ($LASTEXITCODE) { $requiredFailures.Add('Herdr config validation failed.') }
    $warnings.Add('Herdr native Windows support is preview/beta; interactive pane rendering still needs day-to-day validation.')
}
if (-not (Get-Command cl,gcc,clang,zig -ErrorAction SilentlyContinue)) {
    $warnings.Add('No supported C/C++ compiler on PATH; Telescope fzf-native and new Treesitter parser builds are disabled.')
}
if (-not (Get-Command mmdc -ErrorAction SilentlyContinue)) {
    $warnings.Add('Mermaid CLI (mmdc) is absent; Markdown Mermaid rendering remains optional.')
}

$houdiniRoot = Join-Path $env:ProgramFiles 'Side Effects Software'
$hython = Get-ChildItem $houdiniRoot -Filter hython.exe -File -Recurse -ErrorAction SilentlyContinue | Sort-Object FullName -Descending
if ($hython) { $hython | ForEach-Object { Write-Host "Houdini: $($_.FullName)" } } else { $warnings.Add('Houdini/hython not installed; install through SideFX Launcher.') }
if (-not (Get-Command herdr -ErrorAction SilentlyContinue)) { $warnings.Add('Herdr Windows beta not installed; approval required.') }
Write-Host "Required failures: $($requiredFailures.Count)"; $requiredFailures | ForEach-Object { Write-Host "  FAIL: $_" }
Write-Host "Optional warnings: $($warnings.Count)"; $warnings | ForEach-Object { Write-Host "  WARN: $_" }
if ($requiredFailures.Count) { exit 1 }
