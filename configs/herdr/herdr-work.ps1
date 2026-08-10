[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
if (-not (Get-Command herdr -ErrorAction SilentlyContinue)) { throw 'herdr-work: herdr is not installed or not on PATH.' }
$settings = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'projects.windows.psd1')
$existing = @((& herdr workspace list 2>$null | ConvertFrom-Json).result.workspaces)
$firstId = $null
foreach ($project in $settings.ActiveProjects) {
    if (-not (Test-Path -LiteralPath $project -PathType Container)) { Write-Warning "Skipping missing project: $project"; continue }
    $path = (Resolve-Path -LiteralPath $project).Path
    $label = Split-Path $path -Leaf
    $workspace = $existing | Where-Object label -EQ $label | Select-Object -First 1
    if (-not $workspace) {
        $created = & herdr workspace create --cwd $path --label $label --no-focus | ConvertFrom-Json
        $workspace = $created.result.workspace
        $editor = $created.result.root_pane.pane_id
        $right = (& herdr pane split $editor --direction right --ratio 0.5 --no-focus | ConvertFrom-Json).result.pane.pane_id
        & herdr pane split $right --direction down --ratio 0.3 --no-focus | Out-Null
        & herdr pane run $editor nvim
        Write-Host "created: $label"
    } else { Write-Host "reuse: $label" }
    if (-not $firstId) { $firstId = $workspace.workspace_id }
}
if ($firstId) { & herdr workspace focus $firstId | Out-Null }
