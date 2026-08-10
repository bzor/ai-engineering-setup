$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

$repoBin = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'configs\windows\bin'
if ((Test-Path -LiteralPath $repoBin) -and (($env:Path -split ';') -notcontains $repoBin)) {
    $env:Path = "$repoBin;$env:Path"
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    (& zoxide init powershell | Out-String) | Invoke-Expression
}

function y {
    $cwdFile = Join-Path ([IO.Path]::GetTempPath()) ("yazi-cwd-{0}.txt" -f [guid]::NewGuid())
    try {
        & yazi @args --cwd-file $cwdFile
        if (Test-Path -LiteralPath $cwdFile) {
            $finalDirectory = (Get-Content -Raw -LiteralPath $cwdFile).Trim()
            if ($finalDirectory -and $finalDirectory -ne $PWD.Path -and (Test-Path -LiteralPath $finalDirectory -PathType Container)) {
                Set-Location -LiteralPath $finalDirectory
            }
        }
    } finally {
        Remove-Item -LiteralPath $cwdFile -ErrorAction SilentlyContinue
    }
}
