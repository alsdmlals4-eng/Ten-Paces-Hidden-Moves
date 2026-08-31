param(
    [string]$GodotPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Write-Host "`n== $Label ==" -ForegroundColor Cyan
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed (exit=$LASTEXITCODE)"
    }
}

function Resolve-GodotExecutable {
    param([string]$ExplicitPath)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        if (-not (Test-Path -LiteralPath $ExplicitPath -PathType Leaf)) {
            throw "Godot executable was not found: $ExplicitPath"
        }
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    if (-not [string]::IsNullOrWhiteSpace($env:GODOT_BIN) -and (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf)) {
        return (Resolve-Path -LiteralPath $env:GODOT_BIN).Path
    }

    foreach ($commandName in @("godot4", "godot", "Godot_v4.7.1-stable_win64_console", "Godot_v4.7.1-stable_win64")) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            return $command.Source
        }
    }

    throw "Godot executable was not found. Use -GodotPath or set GODOT_BIN."
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
Set-Location -LiteralPath $repoRoot

$python = Get-Command python -ErrorAction SilentlyContinue
if ($null -eq $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if ($null -eq $python) {
    throw "Python was not found."
}

Invoke-Checked -FilePath $python.Source -Arguments @("tests/check_rival_tendency_contract.py") -Label "Validate rival tendency static contract"

$godot = Resolve-GodotExecutable -ExplicitPath $GodotPath
Invoke-Checked -FilePath $godot -Arguments @("--headless", "--editor", "--path", $repoRoot, "--quit") -Label "Parse Godot project"
Invoke-Checked -FilePath $godot -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_ai_rival_tendency.gd") -Label "Verify seeded rival tendency policy"
Invoke-Checked -FilePath $godot -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_step12_13_restart_ai.gd") -Label "Verify STEP 12 AI and STEP 13 restart regression"

Write-Host "`nREPEAT_POC_A1_VERIFY_OK" -ForegroundColor Green
