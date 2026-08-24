[CmdletBinding()]
param(
    [string]$BaseRoot = "",
    [string]$GodotPath = "",
    [string]$HeraPath = "",
    [int]$QaPort = 0,
    [switch]$SkipBrowser,
    [switch]$SkipGameLaunch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ISSUE54_HUMAN_VALIDATION_LAUNCHER
# FRESH_RUNTIME_ARTIFACT_GATE
# Freshness reference command: git ls-remote origin refs/heads/main
# This launcher prepares evidence and opens tools; it never promotes Human/device PASS.

function Resolve-Root([string]$Path, [string]$Label) {
    if (-not $Path) { throw "$Label path is empty." }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label path does not exist: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Invoke-GitText([string]$Root, [string[]]$Arguments) {
    $old = Get-Location
    try {
        Set-Location -LiteralPath $Root
        $global:LASTEXITCODE = 0
        $output = & git @Arguments 2>&1 | Out-String
        $code = $LASTEXITCODE
        if ($null -eq $code) { $code = 0 }
        if ($code -ne 0) {
            throw "git $($Arguments -join ' ') failed in $Root`: $($output.Trim())"
        }
        return $output.Trim()
    }
    finally {
        Set-Location -LiteralPath $old.Path
    }
}

function Assert-ExactRemoteMain([string]$Root, [string]$HeadMismatchCode) {
    $branch = Invoke-GitText $Root @("rev-parse", "--abbrev-ref", "HEAD")
    if ($branch -ne "main") {
        throw "LOCAL_BRANCH_MUST_BE_MAIN: $Root is on '$branch'."
    }

    $status = Invoke-GitText $Root @("status", "--porcelain=v1")
    if ($status) {
        throw "LOCAL_WORKTREE_MUST_BE_CLEAN: tracked/untracked changes exist in $Root."
    }

    $head = Invoke-GitText $Root @("rev-parse", "HEAD")
    $remote = Invoke-GitText $Root @("ls-remote", "origin", "refs/heads/main")
    $line = ($remote -split "`r?`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
    if (-not $line) { throw "REMOTE_MAIN_UNRESOLVED: $Root" }
    $remoteHead = ($line -split "\s+")[0]
    if ($remoteHead -notmatch '^[0-9a-f]{40}$') {
        throw "REMOTE_MAIN_INVALID_SHA: $remoteHead"
    }
    if ($head -ne $remoteHead) {
        throw "$HeadMismatchCode`: local=$head remote=$remoteHead"
    }
    return $head
}

function Resolve-Base([string]$Requested, [string]$ProjectRoot) {
    $candidates = New-Object System.Collections.Generic.List[string]
    if ($Requested) { $candidates.Add($Requested) }
    if ($env:TEN_PACES_BASE_ROOT) { $candidates.Add($env:TEN_PACES_BASE_ROOT) }

    $projectParent = Split-Path -Parent $ProjectRoot
    $projectGrandParent = Split-Path -Parent $projectParent
    $candidates.Add((Join-Path $projectParent "Base"))
    if ($projectGrandParent) { $candidates.Add((Join-Path $projectGrandParent "Base")) }
    if ($env:USERPROFILE) {
        $candidates.Add((Join-Path $env:USERPROFILE "Documents\GitHub\Base"))
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (-not $candidate) { continue }
        $qaProject = Join-Path $candidate "tools\qa-evidence-studio\pyproject.toml"
        if (Test-Path -LiteralPath $qaProject -PathType Leaf) {
            return Resolve-Root $candidate "BaseRoot"
        }
    }
    throw "BASE_ROOT_UNRESOLVED: pass -BaseRoot or set TEN_PACES_BASE_ROOT."
}

function Resolve-Godot471([string]$Requested) {
    $candidates = New-Object System.Collections.Generic.List[string]
    if ($Requested) { $candidates.Add($Requested) }
    if ($env:TEN_PACES_GODOT_PATH) { $candidates.Add($env:TEN_PACES_GODOT_PATH) }
    $command = Get-Command godot -ErrorAction SilentlyContinue
    if ($command) { $candidates.Add($command.Source) }
    if ($env:USERPROFILE) {
        $candidates.Add((Join-Path $env:USERPROFILE "Tools\Godot-Ten-Paces-4.7.1\Godot_v4.7.1-stable_win64.exe"))
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (-not $candidate -or -not (Test-Path -LiteralPath $candidate -PathType Leaf)) { continue }
        $resolved = (Resolve-Path -LiteralPath $candidate).Path
        $global:LASTEXITCODE = 0
        $version = (& $resolved --version 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and $version.StartsWith("4.7.1.")) {
            return [ordered]@{ path = $resolved; version = $version }
        }
    }
    throw "GODOT_471_UNRESOLVED: pass -GodotPath or set TEN_PACES_GODOT_PATH."
}

function Assert-TrackedClean([string]$Root, [string]$Stage) {
    $status = Invoke-GitText $Root @("status", "--porcelain=v1")
    if ($status) {
        throw "TRACKED_OR_UNTRACKED_DELTA_AFTER_$Stage`: $status"
    }
}

function Write-JsonUtf8([string]$Path, [object]$Payload) {
    $json = $Payload | ConvertTo-Json -Depth 12
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, $json + "`n", $utf8NoBom)
}

function Stop-ChildProcessSafely([object]$Process, [string]$Reason) {
    if ($null -eq $Process) { return }
    try {
        if (-not $Process.HasExited) {
            $Process.Kill()
            $Process.WaitForExit(3000) | Out-Null
        }
    }
    catch {
        Write-Warning "$Reason cleanup warning: $($_.Exception.Message)"
    }
}

$projectRoot = Resolve-Root (Join-Path $PSScriptRoot "..") "ProjectRoot"
$projectHead = Assert-ExactRemoteMain $projectRoot "LOCAL_HEAD_MUST_EQUAL_REMOTE_MAIN"
$baseRootResolved = Resolve-Base $BaseRoot $projectRoot
$baseHead = Assert-ExactRemoteMain $baseRootResolved "BASE_HEAD_MUST_EQUAL_REMOTE_MAIN"
$godot = Resolve-Godot471 $GodotPath

$runRoot = Join-Path $projectRoot ("build\issue54-human-validation\" + $projectHead)
if (Test-Path -LiteralPath $runRoot) {
    Remove-Item -LiteralPath $runRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null

$preflightDir = Join-Path $runRoot "preflight"
$collector = Join-Path $projectRoot "tools\collect_godot_live_evidence.ps1"
$collectorArgs = @(
    "-ProjectPath", $projectRoot,
    "-GodotPath", $godot.path,
    "-OutputDir", $preflightDir
)
if ($HeraPath) { $collectorArgs += @("-HeraPath", $HeraPath) }

& $collector @collectorArgs
if ($LASTEXITCODE -ne 0) {
    throw "LOCAL_EVIDENCE_COLLECTOR_PROCESS_FAILED: exit=$LASTEXITCODE"
}
$collectorJson = Join-Path $preflightDir "godot-live-evidence.json"
if (-not (Test-Path -LiteralPath $collectorJson -PathType Leaf)) {
    throw "LOCAL_EVIDENCE_COLLECTOR_JSON_MISSING: $collectorJson"
}
$collectorEvidence = Get-Content -LiteralPath $collectorJson -Raw | ConvertFrom-Json
if ($collectorEvidence.collector_status -ne "COMPLETE") {
    $blockers = @($collectorEvidence.blocking_statuses) -join ", "
    throw "LOCAL_EVIDENCE_PREFLIGHT_NOT_COMPLETE: $blockers"
}
Assert-TrackedClean $projectRoot "PREFLIGHT"

$productDir = Join-Path $runRoot "windows-product"
New-Item -ItemType Directory -Force -Path $productDir | Out-Null
$exePath = Join-Path $productDir "TenPacesHiddenMoves.exe"
$pckPath = Join-Path $productDir "TenPacesHiddenMoves.pck"
$exportStdout = Join-Path $runRoot "windows-export.stdout.log"
$exportStderr = Join-Path $runRoot "windows-export.stderr.log"
$exportArgs = @(
    "--headless",
    "--path", ('"' + $projectRoot + '"'),
    "--export-release", '"Windows Desktop Product Validation"',
    ('"' + $exePath + '"')
)
$exportProcess = Start-Process `
    -FilePath $godot.path `
    -ArgumentList $exportArgs `
    -WorkingDirectory $projectRoot `
    -Wait `
    -PassThru `
    -NoNewWindow `
    -RedirectStandardOutput $exportStdout `
    -RedirectStandardError $exportStderr
if ($exportProcess.ExitCode -ne 0) {
    throw "FRESH_WINDOWS_EXPORT_FAILED: exit=$($exportProcess.ExitCode)"
}
if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) {
    throw "FRESH_WINDOWS_EXE_MISSING: $exePath"
}
if (-not (Test-Path -LiteralPath $pckPath -PathType Leaf)) {
    throw "FRESH_WINDOWS_PCK_MISSING: $pckPath"
}
$exeInfo = Get-Item -LiteralPath $exePath
$pckInfo = Get-Item -LiteralPath $pckPath
$exeHash = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash.ToLowerInvariant()
$pckHash = (Get-FileHash -LiteralPath $pckPath -Algorithm SHA256).Hash.ToLowerInvariant()
Assert-TrackedClean $projectRoot "FRESH_WINDOWS_EXPORT"

$assetVaultLibrary = Join-Path $projectRoot ".asset-vault\library"
New-Item -ItemType Directory -Force -Path $assetVaultLibrary | Out-Null

$localAppData = [Environment]::GetFolderPath("LocalApplicationData")
if (-not $localAppData) { $localAppData = [IO.Path]::GetTempPath() }
$venvRoot = Join-Path $localAppData "TenPaces\qa-evidence-studio-venv"
$qaPython = Join-Path $venvRoot "Scripts\python.exe"
if (-not (Test-Path -LiteralPath $qaPython -PathType Leaf)) {
    $py = Get-Command py -ErrorAction SilentlyContinue
    if (-not $py) { throw "PYTHON_LAUNCHER_UNRESOLVED: Python launcher 'py' is required." }
    & $py.Source -3.12 -m venv $venvRoot
    if ($LASTEXITCODE -ne 0) { throw "QA_STUDIO_VENV_CREATE_FAILED" }
}

$baseIdentityMarker = Join-Path $venvRoot "installed-base-identity.json"
$installedBaseIdentity = $null
if (Test-Path -LiteralPath $baseIdentityMarker -PathType Leaf) {
    try {
        $installedBaseIdentity = Get-Content -LiteralPath $baseIdentityMarker -Raw | ConvertFrom-Json
    }
    catch {
        $installedBaseIdentity = $null
    }
}
$baseInstallMatches = $false
if ($null -ne $installedBaseIdentity) {
    $sameRoot = [string]::Equals(
        [string]$installedBaseIdentity.base_root,
        $baseRootResolved,
        [StringComparison]::OrdinalIgnoreCase
    )
    $sameCommit = ([string]$installedBaseIdentity.base_main_commit -eq $baseHead)
    $baseInstallMatches = ($sameRoot -and $sameCommit)
}
if (-not $baseInstallMatches) {
    $qaPackage = Join-Path $baseRootResolved "tools\qa-evidence-studio"
    & $qaPython -m pip install --disable-pip-version-check -e $qaPackage
    if ($LASTEXITCODE -ne 0) { throw "QA_EVIDENCE_STUDIO_INSTALL_FAILED" }
    Write-JsonUtf8 $baseIdentityMarker ([ordered]@{
        base_root = $baseRootResolved
        base_main_commit = $baseHead
    })
}
Assert-TrackedClean $baseRootResolved "QA_STUDIO_INSTALL"

$startupFile = Join-Path $runRoot "qa-startup.json"
$nonce = [Guid]::NewGuid().ToString("N")
$qaArgs = @(
    "-m", "qa_evidence_studio.app",
    "--project-root", ('"' + $projectRoot + '"'),
    "--project-id", "ten-paces-hidden-moves",
    "--port", $QaPort.ToString(),
    "--launch-nonce", $nonce,
    "--startup-file", ('"' + $startupFile + '"')
)
$qaProcess = Start-Process `
    -FilePath $qaPython `
    -ArgumentList $qaArgs `
    -WorkingDirectory $baseRootResolved `
    -PassThru

$startup = $null
for ($i = 0; $i -lt 100; $i++) {
    if (Test-Path -LiteralPath $startupFile -PathType Leaf) {
        $startup = Get-Content -LiteralPath $startupFile -Raw | ConvertFrom-Json
        break
    }
    if ($qaProcess.HasExited) {
        throw "QA_EVIDENCE_STUDIO_EXITED_BEFORE_READY: exit=$($qaProcess.ExitCode)"
    }
    Start-Sleep -Milliseconds 100
}
if ($null -eq $startup) {
    Stop-ChildProcessSafely $qaProcess "QA_EVIDENCE_STUDIO_STARTUP_TIMEOUT"
    throw "QA_EVIDENCE_STUDIO_STARTUP_TIMEOUT"
}
$qaUrl = "http://127.0.0.1:$($startup.port)"

try {
    Assert-TrackedClean $projectRoot "LAUNCH_READY"
    Assert-TrackedClean $baseRootResolved "LAUNCH_READY"
}
catch {
    Stop-ChildProcessSafely $qaProcess "QA_PROCESS_CLEANUP_AFTER_LAUNCH_READY_FAILURE"
    throw
}

$gameProcess = $null
try {
    if (-not $SkipGameLaunch) {
        $gameProcess = Start-Process -FilePath $exePath -WorkingDirectory $productDir -PassThru
    }
}
catch {
    Write-Warning "QA_PROCESS_CLEANUP_AFTER_GAME_LAUNCH_FAILURE"
    Stop-ChildProcessSafely $qaProcess "QA_PROCESS_CLEANUP_AFTER_GAME_LAUNCH_FAILURE"
    throw
}

if (-not $SkipBrowser) {
    try {
        Start-Process $qaUrl | Out-Null
    }
    catch {
        Write-Warning "BROWSER_OPEN_FAILED: $($_.Exception.Message)"
    }
}

$manifestPath = Join-Path $runRoot "issue54-human-validation-launch.json"
$manifest = [ordered]@{
    schema_version = 1
    launcher_id = "ISSUE54_HUMAN_VALIDATION_LAUNCHER"
    created_at_utc = [DateTime]::UtcNow.ToString("o")
    project_root = $projectRoot
    exact_git_commit = $projectHead
    base_root = $baseRootResolved
    base_main_commit = $baseHead
    godot = [ordered]@{ path = $godot.path; version = $godot.version }
    fresh_artifact_gate = "FRESH_RUNTIME_ARTIFACT_GATE"
    preflight_evidence = $collectorJson
    windows_product = [ordered]@{
        preset = "Windows Desktop Product Validation"
        exe_path = $exePath
        exe_bytes = $exeInfo.Length
        exe_sha256 = $exeHash
        pck_path = $pckPath
        pck_bytes = $pckInfo.Length
        pck_sha256 = $pckHash
    }
    qa_evidence_studio = [ordered]@{
        url = $qaUrl
        process_id = $qaProcess.Id
        startup_file = $startupFile
        base_root = $baseRootResolved
        base_main_commit = $baseHead
    }
    game_process_id = $(if ($gameProcess) { $gameProcess.Id } else { $null })
    result = "HUMAN_DEVICE_STATUS_REMAINS_NOT_RUN_UNTIL_REVIEW"
}
Write-JsonUtf8 $manifestPath $manifest

Write-Host "Issue #54 Human validation environment is ready." -ForegroundColor Green
Write-Host "Exact project main: $projectHead"
Write-Host "Exact Base main: $baseHead"
Write-Host "Fresh Windows EXE SHA256: $exeHash"
Write-Host "Fresh Windows PCK SHA256: $pckHash"
Write-Host "QA Evidence Studio: $qaUrl"
Write-Host "Launch manifest: $manifestPath"
Write-Host "HUMAN_DEVICE_STATUS_REMAINS_NOT_RUN_UNTIL_REVIEW" -ForegroundColor Yellow
Write-Host "Complete the Issue #54 checklist in QA Evidence Studio; do not infer PASS from launcher success."
