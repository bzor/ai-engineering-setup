[CmdletBinding()]
param([string]$ProjectPath)
$ErrorActionPreference = 'Stop'
$settings = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'projects.windows.psd1')

foreach ($command in 'herdr','fzf') {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { throw "herdr-sessionizer: $command is not installed or not on PATH." }
}

function Get-Projects {
    $containers = @($settings.ContainerRoots | Where-Object { Test-Path -LiteralPath $_ -PathType Container })
    $parents = @($settings.ProjectRoots) + $containers
    foreach ($parent in $parents) {
        if (Test-Path -LiteralPath $parent -PathType Container) {
            Get-ChildItem -LiteralPath $parent -Directory -Force:$false | Where-Object FullName -NotIn $containers | Select-Object -ExpandProperty FullName
        }
    }
}

if (-not $ProjectPath) {
    $ProjectPath = Get-Projects | Sort-Object -Unique | & fzf --prompt 'herdr project> ' --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up'
}
if (-not $ProjectPath) { exit 0 }
$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
$label = Split-Path $ProjectPath -Leaf
$list = (& herdr workspace list 2>$null | ConvertFrom-Json).result.workspaces
$existing = $list | Where-Object label -EQ $label | Select-Object -First 1
if ($existing) { & herdr workspace focus $existing.workspace_id; exit $LASTEXITCODE }

$created = & herdr workspace create --cwd $ProjectPath --label $label --focus | ConvertFrom-Json
$editor = $created.result.root_pane.pane_id
$right = (& herdr pane split $editor --direction right --ratio 0.5 --no-focus | ConvertFrom-Json).result.pane.pane_id
$agent = (& herdr pane split $right --direction down --ratio 0.3 --focus | ConvertFrom-Json).result.pane.pane_id
& herdr pane run $editor nvim
if ($settings.AgentCommand -and (Get-Command $settings.AgentCommand -ErrorAction SilentlyContinue)) {
    & herdr pane run $agent $settings.AgentCommand
}
exit $LASTEXITCODE
