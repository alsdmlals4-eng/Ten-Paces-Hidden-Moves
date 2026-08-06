[CmdletBinding()]
param(
    [string]$RepoRoot = "",
    [string]$ExpectedHead = "",
    [string]$WslDistribution = "",
    [string]$OutputRoot = "build/local-validation"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PackPolicy = "ALL_REQUIRED_ENVIRONMENTS_MUST_PASS"

function Invoke-NativeChecked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory
    )
    Push-Location $WorkingDirectory
    try {
        $lines = & $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
        $text = (($lines | Out-String) -replace "`0", "").TrimEnd()
        if ($text) { Write-Host $text }
        if ($exitCode -ne 0) {
            throw "NATIVE_COMMAND_FAILED exit=$exitCode command=$FilePath $($Arguments -join ' ')"
        }
        return $text
    }
    finally {
        Pop-Location
    }
}

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
} else {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
}

$actualHead = (Invoke-NativeChecked -FilePath "git" -Arguments @("rev-parse", "HEAD") -WorkingDirectory $RepoRoot).Trim()
if ([string]::IsNullOrWhiteSpace($ExpectedHead)) {
    $ExpectedHead = $actualHead
}
if ($actualHead -ne $ExpectedHead) {
    throw "EXACT_HEAD_MISMATCH expected=$ExpectedHead actual=$actualHead"
}

# Required marker and command: git status --porcelain
$cleanBefore = Invoke-NativeChecked -FilePath "git" -Arguments @("status", "--porcelain") -WorkingDirectory $RepoRoot
if (-not [string]::IsNullOrWhiteSpace($cleanBefore)) {
    throw "DIRTY_TREE_BEFORE_VALIDATION"
}

$runner = Join-Path $RepoRoot "tools/local_validation/run_matrix_contracts.py"
$resolvedOutput = Join-Path $RepoRoot $OutputRoot
New-Item -ItemType Directory -Force -Path $resolvedOutput | Out-Null

$windowsMatrix = @(
    [ordered]@{ Id = "windows-py311"; Selector = "-3.11"; Python = "3.11" },
    [ordered]@{ Id = "windows-py312"; Selector = "-3.12"; Python = "3.12" },
    [ordered]@{ Id = "windows-py313"; Selector = "-3.13"; Python = "3.13" }
)

foreach ($environment in $windowsMatrix) {
    Write-Host "=== $($environment.Id) ==="
    Invoke-NativeChecked -FilePath "py" -Arguments @(
        $environment.Selector,
        $runner,
        "--root", $RepoRoot,
        "--environment-id", $environment.Id,
        "--expected-python", $environment.Python,
        "--expected-head", $ExpectedHead,
        "--output-root", $OutputRoot
    ) -WorkingDirectory $RepoRoot | Out-Null
}

$distributionText = Invoke-NativeChecked -FilePath "wsl.exe" -Arguments @("-l", "-q") -WorkingDirectory $RepoRoot
$distributions = @($distributionText -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ([string]::IsNullOrWhiteSpace($WslDistribution)) {
    $WslDistribution = ($distributions | Where-Object { $_ -match "^Ubuntu" } | Select-Object -First 1)
}
if ([string]::IsNullOrWhiteSpace($WslDistribution) -or -not ($distributions -contains $WslDistribution)) {
    throw "UBUNTU_WSL_DISTRIBUTION_NOT_FOUND available=$($distributions -join ',')"
}

$kernel = Invoke-NativeChecked -FilePath "wsl.exe" -Arguments @("-d", $WslDistribution, "--", "uname", "-r") -WorkingDirectory $RepoRoot
if ($kernel -notmatch "WSL2") {
    throw "WSL_NOT_VERSION_2 kernel=$kernel"
}
Invoke-NativeChecked -FilePath "wsl.exe" -Arguments @("-d", $WslDistribution, "--", "python3.12", "--version") -WorkingDirectory $RepoRoot | Out-Null
Invoke-NativeChecked -FilePath "wsl.exe" -Arguments @("-d", $WslDistribution, "--", "git", "--version") -WorkingDirectory $RepoRoot | Out-Null
$wslRoot = (Invoke-NativeChecked -FilePath "wsl.exe" -Arguments @("-d", $WslDistribution, "--", "wslpath", "-a", $RepoRoot) -WorkingDirectory $RepoRoot).Trim()
$wslRunner = "$wslRoot/tools/local_validation/run_matrix_contracts.py"

Write-Host "=== wsl2-ubuntu-py312 ($WslDistribution) ==="
Invoke-NativeChecked -FilePath "wsl.exe" -Arguments @(
    "-d", $WslDistribution, "--",
    "python3.12", $wslRunner,
    "--root", $wslRoot,
    "--environment-id", "wsl2-ubuntu-py312",
    "--expected-python", "3.12",
    "--expected-head", $ExpectedHead,
    "--output-root", $OutputRoot
) -WorkingDirectory $RepoRoot | Out-Null

$requiredIds = @("windows-py311", "windows-py312", "windows-py313", "wsl2-ubuntu-py312")
$environmentResults = @()
foreach ($environmentId in $requiredIds) {
    $resultPath = Join-Path $resolvedOutput "results/$environmentId.json"
    if (-not (Test-Path $resultPath)) {
        throw "MISSING_ENVIRONMENT_RESULT environment=$environmentId"
    }
    $environmentResults += (Get-Content -Raw -Encoding UTF8 $resultPath | ConvertFrom-Json)
}

$cleanAfter = Invoke-NativeChecked -FilePath "git" -Arguments @("status", "--porcelain") -WorkingDirectory $RepoRoot
if (-not [string]::IsNullOrWhiteSpace($cleanAfter)) {
    throw "DIRTY_TREE_AFTER_VALIDATION"
}

$passed = @($environmentResults | Where-Object { $_.status -eq "PASS" }).Count
$summary = [ordered]@{
    schema_version = 1
    policy = $PackPolicy
    status = if ($passed -eq 4) { "PASS" } else { "FAIL" }
    expected_head = $ExpectedHead
    actual_head = $actualHead
    wsl_distribution = $WslDistribution
    required_environments = $requiredIds
    passed_environments = $passed
    environment_results = $environmentResults
    completed_at_utc = [DateTime]::UtcNow.ToString("o")
}
$summaryPath = Join-Path $resolvedOutput "summary.json"
$summary | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 $summaryPath

if ($passed -ne 4) {
    throw "LOCAL_MATRIX_FAILED passed=$passed required=4"
}
Write-Host "LOCAL_PYTHON_MATRIX_4_OF_4_PASS"
Write-Host "summary=$summaryPath"
