[CmdletBinding()]
param([switch]$WhatIf)
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'This bootstrap requires native Windows.' }
$env:Path = "$([Environment]::GetEnvironmentVariable('Path','Machine'));$([Environment]::GetEnvironmentVariable('Path','User'))"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'winget is required. Install Microsoft App Installer first.' }

$packages = @(
    @{ Name='PowerShell 7'; Command='pwsh'; Id='Microsoft.PowerShell' },
    @{ Name='Git'; Command='git'; Id='Git.Git' },
    @{ Name='WezTerm'; Command='wezterm'; Id='wez.wezterm' },
    @{ Name='Neovim'; Command='nvim'; Id='Neovim.Neovim' },
    @{ Name='Node.js LTS'; Command='node'; Id='OpenJS.NodeJS.LTS' },
    @{ Name='ripgrep'; Command='rg'; Id='BurntSushi.ripgrep.MSVC' },
    @{ Name='fd'; Command='fd'; Id='sharkdp.fd' },
    @{ Name='fzf'; Command='fzf'; Id='junegunn.fzf' },
    @{ Name='zoxide'; Command='zoxide'; Id='ajeetdsouza.zoxide' },
    @{ Name='Yazi'; Command='yazi'; Id='sxyazi.yazi' },
    @{ Name='ImageMagick'; Command='magick'; Id='ImageMagick.ImageMagick' }
    @{ Name='Zebar'; Command='zebar'; Id='glzr-io.zebar'; Scope='machine' }
)
$summary = [ordered]@{ Installed=@(); Present=@(); Skipped=@(); Failed=@() }
foreach ($package in $packages) {
    if (Get-Command $package.Command -ErrorAction SilentlyContinue) { $summary.Present += $package.Name; continue }
    $found = winget search --id $package.Id --exact --source winget --accept-source-agreements 2>&1
    if ($LASTEXITCODE -ne 0 -or ($found -join "`n") -notmatch [regex]::Escape($package.Id)) {
        $summary.Failed += "$($package.Name) (winget ID not resolved: $($package.Id))"; continue
    }
    if ($WhatIf) { $summary.Skipped += "$($package.Name) (WhatIf)"; continue }
    # User scope prevents an implicit elevation request. Packages that do not
    # provide a user-scope installer fail visibly and can be approved manually.
    $scope = if ($package.Scope) { $package.Scope } else { 'user' }
    winget install --id $package.Id --exact --source winget --scope $scope --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
    if ($LASTEXITCODE -eq 0) { $summary.Installed += $package.Name } else { $summary.Failed += $package.Name }
}

if (Get-Command codex -ErrorAction SilentlyContinue) { $summary.Present += 'Codex (native Windows)' }
else { $summary.Failed += 'Codex (install the official OpenAI Codex Windows app from the Microsoft Store)' }
$font = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue
if ($font.PSObject.Properties.Name -match '^IosevkaTerm NF') { $summary.Present += 'IosevkaTerm NF' }
else { $summary.Skipped += 'Iosevka Nerd Font (no verified winget package; install from the official Nerd Fonts release)' }
if (Get-Command herdr -ErrorAction SilentlyContinue) { $summary.Present += 'Herdr Windows preview' }
else { $summary.Skipped += 'Herdr (Windows preview/beta requires explicit approval)' }
$houdiniRoot = Join-Path $env:ProgramFiles 'Side Effects Software'
if (Get-ChildItem $houdiniRoot -Filter hython.exe -Recurse -ErrorAction SilentlyContinue) { $summary.Present += 'Houdini' }
else { $summary.Skipped += 'Houdini (install manually with SideFX Houdini Launcher)' }

foreach ($key in $summary.Keys) { Write-Host ("{0}: {1}" -f $key, ($(if ($summary[$key].Count) { $summary[$key] -join ', ' } else { 'none' }))) }
if ($summary.Failed.Count) { exit 1 }
