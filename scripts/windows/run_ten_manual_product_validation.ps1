[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Executable,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-f]{40}$')]
    [string]$HeadSha,

    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,

    [int]$TimeoutSeconds = 120
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$executablePath = (Resolve-Path -LiteralPath $Executable).Path
$outputPath = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null

$stdoutPath = Join-Path $outputPath 'windows-runtime.stdout.log'
$stderrPath = Join-Path $outputPath 'windows-runtime.stderr.log'
$scenarioPath = Join-Path $outputPath 'product_scenarios.json'
$evidencePath = Join-Path $outputPath 'product_validation_evidence.json'

$env:TEN_MANUAL_EVIDENCE_DIR = $outputPath
$arguments = @(
    '--headless',
    '--script',
    'res://tests/verify_ten_manual_product_gate.gd'
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$process = Start-Process `
    -FilePath $executablePath `
    -ArgumentList $arguments `
    -PassThru `
    -NoNewWindow `
    -RedirectStandardOutput $stdoutPath `
    -RedirectStandardError $stderrPath

$peakWorkingSet = 0L
$timedOut = $false
while (-not $process.HasExited) {
    if ($process.PeakWorkingSet64 -gt $peakWorkingSet) {
        $peakWorkingSet = $process.PeakWorkingSet64
    }
    if ($stopwatch.Elapsed.TotalSeconds -ge $TimeoutSeconds) {
        $timedOut = $true
        $process.Kill($true)
        break
    }
    Start-Sleep -Milliseconds 100
    $process.Refresh()
}
$process.WaitForExit()
$stopwatch.Stop()

if ($timedOut) {
    throw "Windows product validation timed out after $TimeoutSeconds seconds."
}
if ($process.ExitCode -ne 0) {
    throw "Windows product validation exited with code $($process.ExitCode). See $stdoutPath and $stderrPath."
}
if (-not (Test-Path -LiteralPath $scenarioPath)) {
    throw "Windows runtime did not create scenario evidence: $scenarioPath"
}

$scenario = Get-Content -LiteralPath $scenarioPath -Raw | ConvertFrom-Json
if ([int]$scenario.scenario_count -ne 50 -or [int]$scenario.failed -ne 0) {
    throw "Windows runtime scenario evidence is incomplete or failed."
}

$pckPath = [System.IO.Path]::ChangeExtension($executablePath, '.pck')
$artifactBytes = (Get-Item -LiteralPath $executablePath).Length
if (Test-Path -LiteralPath $pckPath) {
    $artifactBytes += (Get-Item -LiteralPath $pckPath).Length
}

$repository = if ($env:GITHUB_REPOSITORY) { $env:GITHUB_REPOSITORY } else { 'alsdmlals4-eng/Ten-Paces-Hidden-Moves' }
$runId = if ($env:GITHUB_RUN_ID) { $env:GITHUB_RUN_ID } else { 'LOCAL_NOT_CI' }
$prNumber = if ($env:PR_NUMBER) { [int]$env:PR_NUMBER } else { 92 }
$artifactName = "ten-manual-product-validation-$HeadSha"

$evidence = [ordered]@{
    decision_id = 'TEN_MANUAL_PRODUCT_VALIDATION_GATE'
    head_sha = $HeadSha
    godot_version = '4.7.1'
    platform = 'windows-x86_64'
    scenario_count = [int]$scenario.scenario_count
    scenario_passed = [int]$scenario.passed
    scenario_failed = [int]$scenario.failed
    windows_export = 'PASS'
    windows_ci_runtime = 'PASS'
    windows_local_render = 'NOT_RUN'
    keyboard_synthetic = 'PASS'
    mouse_synthetic = 'PASS'
    gamepad_physical = 'NOT_RUN'
    resolution_matrix = 'PASS'
    accessibility_automated = 'PASS'
    accessibility_user = 'NOT_RUN'
    performance_baseline = 'CAPTURED'
    release_performance = 'NOT_RUN'
    human_step14 = 'NOT_RUN'
    participant_count = 0
    product_gate = 'PARTIAL_AUTOMATED_COMPLETE'
    performance = [ordered]@{
        runtime_elapsed_ms = [math]::Round($stopwatch.Elapsed.TotalMilliseconds, 2)
        peak_working_set_bytes = $peakWorkingSet
        artifact_bytes = $artifactBytes
    }
    artifact = [ordered]@{
        name = $artifactName
        workflow_run_id = $runId
        build_utc = [DateTime]::UtcNow.ToString('o')
        preset = 'Windows Desktop Product Validation'
        repository = $repository
        pr = $prNumber
        head_sha = $HeadSha
    }
    performance_environment = [ordered]@{
        runner = 'windows-latest'
        godot_version = '4.7.1'
    }
}

$evidence | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $evidencePath -Encoding utf8
Write-Host "TEN_MANUAL_WINDOWS_PRODUCT_EVIDENCE_OK $evidencePath"
