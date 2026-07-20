param(
    [string]$GodotPath = "",
    [switch]$NoPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ExpectedBranch = "agent/t0-combat-poc-board"
$ReportRelativePath = "artifacts/verification/step0-godot-verification.md"
$CommitMessage = "test: verify STEP 0 card components in Godot"

function Invoke-NativeChecked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Write-Host "`n== $Label ==" -ForegroundColor Cyan

    # Windows PowerShell 5.1 may convert normal native stderr output into a
    # terminating NativeCommandError when ErrorActionPreference is Stop.
    # Git commonly writes progress such as 'From https://...' to stderr even
    # when the command succeeds. Temporarily use Continue and judge only by
    # the native process exit code.
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = @(& $FilePath @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }

    foreach ($line in $output) {
        Write-Host ([string]$line)
    }

    if ($exitCode -ne 0) {
        throw "$Label failed (exit=$exitCode)"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function Resolve-GodotExecutable {
    param([string]$ExplicitPath)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        if (-not (Test-Path -LiteralPath $ExplicitPath -PathType Leaf)) {
            throw "Godot executable was not found: $ExplicitPath"
        }
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    if (-not [string]::IsNullOrWhiteSpace($env:GODOT_BIN)) {
        if (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf) {
            return (Resolve-Path -LiteralPath $env:GODOT_BIN).Path
        }
    }

    foreach ($commandName in @(
        "godot4",
        "godot",
        "Godot_v4.7.1-stable_win64_console",
        "Godot_v4.7.1-stable_win64"
    )) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            return $command.Source
        }
    }

    $knownPaths = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\godot.exe",
        "$env:USERPROFILE\scoop\shims\godot.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4.7.1-stable_win64.exe",
        "$env:ProgramFiles\Godot\Godot_v4.7.1-stable_win64_console.exe",
        "$env:ProgramFiles\Godot\Godot_v4.7.1-stable_win64.exe",
        "C:\Godot\Godot_v4.7.1-stable_win64_console.exe",
        "C:\Godot\Godot_v4.7.1-stable_win64.exe"
    )

    foreach ($candidate in $knownPaths) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $searchRoots = @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Documents"
    ) | Where-Object { Test-Path -LiteralPath $_ -PathType Container }

    foreach ($root in $searchRoots) {
        $candidate = Get-ChildItem -LiteralPath $root -Filter "Godot*.exe" -File -Recurse -ErrorAction SilentlyContinue |
            Sort-Object @{ Expression = { if ($_.Name -like "*console*") { 0 } else { 1 } } }, FullName |
            Select-Object -First 1
        if ($null -ne $candidate) {
            return $candidate.FullName
        }
    }

    throw "Godot executable was not found. Use -GodotPath or set GODOT_BIN."
}

function Resolve-PythonCommand {
    $py = Get-Command "py" -ErrorAction SilentlyContinue
    if ($null -ne $py) {
        return @{ Exe = $py.Source; Prefix = @("-3") }
    }

    $python = Get-Command "python" -ErrorAction SilentlyContinue
    if ($null -ne $python) {
        return @{ Exe = $python.Source; Prefix = @() }
    }

    throw "Python 3 was not found. Add py or python to PATH."
}

function Format-IndentedBlock {
    param([string[]]$Lines)

    if ($null -eq $Lines -or $Lines.Count -eq 0) {
        return "    (no output)"
    }

    return (($Lines | ForEach-Object { "    $_" }) -join "`r`n")
}

try {
    # Derive the repository from the script location. This avoids corruption
    # when Git emits a Korean Windows path through an OEM code page.
    $repoRootCandidate = Join-Path -Path $PSScriptRoot -ChildPath ".."
    $repoRoot = (Resolve-Path -LiteralPath $repoRootCandidate).Path

    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot "project.godot") -PathType Leaf)) {
        throw "project.godot was not found under the repository root: $repoRoot"
    }

    $insideWorkTree = Invoke-NativeChecked -FilePath "git" -Arguments @(
        "-C", $repoRoot, "rev-parse", "--is-inside-work-tree"
    ) -Label "Check Git worktree"
    if (($insideWorkTree -join "").Trim() -ne "true") {
        throw "The script directory is not inside a Git worktree: $repoRoot"
    }

    Set-Location -LiteralPath $repoRoot

    $branchOutput = Invoke-NativeChecked -FilePath "git" -Arguments @(
        "branch", "--show-current"
    ) -Label "Check branch"
    $branch = ($branchOutput -join "").Trim()
    if ($branch -ne $ExpectedBranch) {
        throw "Unexpected branch. expected=$ExpectedBranch actual=$branch"
    }

    $initialStatus = Invoke-NativeChecked -FilePath "git" -Arguments @(
        "status", "--porcelain", "--untracked-files=all"
    ) -Label "Check clean worktree"
    $initialStatus = @($initialStatus | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($initialStatus.Count -gt 0) {
        throw "The worktree is not clean. Preserve or commit existing changes before retrying.`n$($initialStatus -join "`n")"
    }

    Invoke-NativeChecked -FilePath "git" -Arguments @("fetch", "origin") -Label "Fetch origin" | Out-Null
    Invoke-NativeChecked -FilePath "git" -Arguments @(
        "pull", "--ff-only", "origin", $ExpectedBranch
    ) -Label "Fast-forward branch" | Out-Null

    $postPullStatus = Invoke-NativeChecked -FilePath "git" -Arguments @(
        "status", "--porcelain", "--untracked-files=all"
    ) -Label "Recheck clean worktree"
    $postPullStatus = @($postPullStatus | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($postPullStatus.Count -gt 0) {
        throw "Unexpected local changes appeared after pull.`n$($postPullStatus -join "`n")"
    }

    $godotExe = Resolve-GodotExecutable -ExplicitPath $GodotPath
    $python = Resolve-PythonCommand

    $godotVersion = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--version") -Label "Check Godot version"
    $versionText = ($godotVersion -join " ").Trim()
    if ($versionText -notmatch "^4\.") {
        throw "Godot 4.x is required. actual=$versionText"
    }

    $staticArgs = @($python.Prefix) + @("tests/check_card_component_contract.py")
    $staticOutput = Invoke-NativeChecked -FilePath $python.Exe -Arguments $staticArgs -Label "Validate card contract"

    $parseOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @(
        "--headless", "--editor", "--path", $repoRoot, "--quit"
    ) -Label "Import and parse Godot project"

    $runtimeOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @(
        "--headless", "--path", $repoRoot, "--script", "res://tests/verify_step0.gd"
    ) -Label "Run STEP 0 headless verification"

    $unexpectedBeforeReport = Invoke-NativeChecked -FilePath "git" -Arguments @(
        "status", "--porcelain", "--untracked-files=all"
    ) -Label "Check verification side effects"
    $unexpectedBeforeReport = @($unexpectedBeforeReport | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($unexpectedBeforeReport.Count -gt 0) {
        throw "Verification modified unexpected tracked files. Commit was blocked.`n$($unexpectedBeforeReport -join "`n")"
    }

    $reportPath = Join-Path $repoRoot $ReportRelativePath
    $reportDirectory = Split-Path -Parent $reportPath
    New-Item -ItemType Directory -Force -Path $reportDirectory | Out-Null

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $staticBlock = Format-IndentedBlock -Lines $staticOutput
    $parseBlock = Format-IndentedBlock -Lines $parseOutput
    $runtimeBlock = Format-IndentedBlock -Lines $runtimeOutput

    $report = @"
# STEP 0 Godot local verification

- Status: PASS
- Verified at (UTC): $timestamp
- Branch: $ExpectedBranch
- Godot executable: `$godotExe`
- Godot version: `$versionText`

## Checks

- [x] Clean worktree before execution
- [x] Fast-forwarded from origin
- [x] Static card contract
- [x] Godot project import and GDScript parsing
- [x] Seven basic cards and required/forbidden fields
- [x] Badge and illustration atlas paths
- [x] Card preview scene instantiation
- [x] Seven CardView nodes and one CardDetailPanel node

## Static contract output

$staticBlock

## Godot import and parse output

$parseBlock

## Godot STEP 0 output

$runtimeBlock

## Scope limitation

This automation verifies headless structure, data, parsing, and scene loading. Windows click behavior, scrolling, minimum resolution, fonts, color accessibility, and visual quality still require manual review.
"@

    Set-Content -LiteralPath $reportPath -Value $report -Encoding UTF8

    $changedFiles = @()
    $changedFiles += Invoke-NativeChecked -FilePath "git" -Arguments @("diff", "--name-only") -Label "List tracked changes"
    $changedFiles += Invoke-NativeChecked -FilePath "git" -Arguments @("ls-files", "--others", "--exclude-standard") -Label "List untracked changes"
    $changedFiles = @($changedFiles | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)

    $unexpectedFiles = @($changedFiles | Where-Object { $_ -ne $ReportRelativePath })
    if ($unexpectedFiles.Count -gt 0) {
        throw "Files other than the verification report changed. Commit was blocked.`n$($unexpectedFiles -join "`n")"
    }

    Invoke-NativeChecked -FilePath "git" -Arguments @("add", "--", $ReportRelativePath) -Label "Stage verification report" | Out-Null

    $cachedDiffExit = 0
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & git diff --cached --quiet
        $cachedDiffExit = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }

    if ($cachedDiffExit -eq 0) {
        Write-Host "Verification report is unchanged; no new commit was created." -ForegroundColor Yellow
    }
    elseif ($cachedDiffExit -eq 1) {
        Invoke-NativeChecked -FilePath "git" -Arguments @("commit", "-m", $CommitMessage) -Label "Commit verification report" | Out-Null
    }
    else {
        throw "git diff --cached --quiet failed (exit=$cachedDiffExit)"
    }

    $commitOutput = Invoke-NativeChecked -FilePath "git" -Arguments @("rev-parse", "HEAD") -Label "Read commit SHA"
    $commitSha = ($commitOutput -join "").Trim()

    if (-not $NoPush) {
        Invoke-NativeChecked -FilePath "git" -Arguments @("push", "origin", $ExpectedBranch) -Label "Push verification result" | Out-Null
    }

    Write-Host "`nSTEP 0 automated verification completed." -ForegroundColor Green
    Write-Host "Commit: $commitSha"
    if ($NoPush) {
        Write-Host "Push: skipped (-NoPush)"
    }
    else {
        Write-Host "Push: origin/$ExpectedBranch completed"
    }
}
catch {
    Write-Host "`nSTEP 0 automated verification failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "No automatic commit or push was performed after failure." -ForegroundColor Yellow
    exit 1
}
