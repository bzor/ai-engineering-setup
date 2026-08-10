[CmdletBinding(DefaultParameterSetName='Discover')]
param(
    [Parameter(Position=0)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })][string]$ScriptPath,
    [Parameter(ParameterSetName='Discover')][string]$HoudiniVersion,
    [Parameter(ParameterSetName='Explicit')][string]$HythonPath,
    [Parameter(ValueFromRemainingArguments)][string[]]$ScriptArguments,
    [switch]$VersionOnly
)
$ErrorActionPreference = 'Stop'

if ($HythonPath) {
    $candidate = Get-Item -LiteralPath $HythonPath -ErrorAction Stop
} else {
    $root = Join-Path $env:ProgramFiles 'Side Effects Software'
    if (-not (Test-Path -LiteralPath $root)) { throw "Houdini is not installed under '$root'. Install it with Houdini Launcher." }
    $candidates = Get-ChildItem -LiteralPath $root -Filter hython.exe -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.DirectoryName -match '[\\/]bin$' }
    if ($HoudiniVersion) { $candidates = $candidates | Where-Object FullName -Match ([regex]::Escape($HoudiniVersion)) }
    $candidate = $candidates | Sort-Object @{ Expression = {
        $match = [regex]::Match($_.FullName, 'Houdini\s+(\d+(?:\.\d+)+)')
        if ($match.Success) { [version]$match.Groups[1].Value } else { [version]'0.0' }
    }; Descending = $true }, FullName | Select-Object -First 1
}
if (-not $candidate) { throw 'No matching hython.exe was found.' }
if ($candidate.Name -ine 'hython.exe') { throw "Resolved executable is not hython.exe: $($candidate.FullName)" }
Write-Verbose "Using $($candidate.FullName)"
if ($VersionOnly) { & $candidate.FullName --version; exit $LASTEXITCODE }
if (-not $ScriptPath) { throw 'ScriptPath is required unless -VersionOnly is used.' }
$resolvedScript = (Resolve-Path -LiteralPath $ScriptPath).Path
& $candidate.FullName $resolvedScript @ScriptArguments
exit $LASTEXITCODE
