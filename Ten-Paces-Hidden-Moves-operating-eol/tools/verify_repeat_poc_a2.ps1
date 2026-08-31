param(
    [switch]$NoGodot
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    python tests/check_repeat_poc_a2_contract.py
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    if (-not $NoGodot) {
        $godot = Get-Command godot -ErrorAction SilentlyContinue
        if ($null -eq $godot) {
            throw "Godot executable is required unless -NoGodot is supplied."
        }
        & $godot.Source --headless --editor --path . --quit
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        & $godot.Source --headless --path . --script res://tests/verify_combat_hypothesis.gd
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        & $godot.Source --headless --path . --script res://tests/verify_combat_review_summary.gd
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }

    Write-Output "REPEAT_POC_A2_VERIFY_OK"
}
finally {
    Pop-Location
}
