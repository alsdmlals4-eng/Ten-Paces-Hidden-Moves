param(
    [string]$GodotPath = "",
    [switch]$NoPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ExpectedBranch = "agent/t0-combat-poc-board"
$ReportRelativePath = "artifacts/verification/combat-ui-foundation-godot-verification.md"
$CommitMessage = "test: verify combat UI foundation in Godot"

function Invoke-NativeChecked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Write-Host "`n== $Label ==" -ForegroundColor Cyan
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

function Format-IndentedBlock {
    param([string[]]$Lines)
    if ($null -eq $Lines -or $Lines.Count -eq 0) {
        return "    (no output)"
    }
    return (($Lines | ForEach-Object { "    $_" }) -join "`r`n")
}

try {
    $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
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
    $godotVersion = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--version") -Label "Check Godot version"
    $versionText = ($godotVersion -join " ").Trim()
    if ($versionText -notmatch "^4\.") {
        throw "Godot 4.x is required. actual=$versionText"
    }

    $parseOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @(
        "--headless", "--editor", "--path", $repoRoot, "--quit"
    ) -Label "Import and parse Godot project"

    $step0Output = Invoke-NativeChecked -FilePath $godotExe -Arguments @(
        "--headless", "--path", $repoRoot, "--script", "res://tests/verify_step0.gd"
    ) -Label "Verify STEP 0 card components"

    $boardOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @(
        "--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_board.gd"
    ) -Label "Verify STEP 1-4 combat presentation foundation"

    $sideEffects = Invoke-NativeChecked -FilePath "git" -Arguments @(
        "status", "--porcelain", "--untracked-files=all"
    ) -Label "Check verification side effects"
    $sideEffects = @($sideEffects | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($sideEffects.Count -gt 0) {
        throw "Verification modified unexpected files. Commit was blocked.`n$($sideEffects -join "`n")"
    }

    $reportPath = Join-Path $repoRoot $ReportRelativePath
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $reportPath) | Out-Null
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $parseBlock = Format-IndentedBlock -Lines $parseOutput
    $step0Block = Format-IndentedBlock -Lines $step0Output
    $boardBlock = Format-IndentedBlock -Lines $boardOutput

    $report = @"
# Combat UI foundation Godot verification

- Status: PASS
- Verified at (UTC): $timestamp
- Branch: $ExpectedBranch
- Godot executable: `$godotExe`
- Godot version: `$versionText`
- Local Python required: no

## Checks

- [x] Clean worktree and expected branch
- [x] Fast-forwarded from origin
- [x] Project import and GDScript parsing
- [x] STEP 0 card catalog and preview scene
- [x] Seven CardView nodes and one CardDetailPanel
- [x] STEP 1 board contains exactly ten tiles
- [x] Player starts on tile 3
- [x] Enemy starts on tile 8
- [x] Player and enemy use identical scale
- [x] Character height is 1.5 times tile width
- [x] Character foot anchors match tile anchors
- [x] STEP 3 approved low-contrast battle background loads behind the board
- [x] STEP 4 player and enemy status panels are in the top HUD
- [x] Both ultimate momentum gauges contain six segments
- [x] Central round, bundle, selection, and resolution-order panel exists
- [x] No lower player/enemy status panels are used

## Godot import and parse output

$parseBlock

## STEP 0 output

$step0Block

## STEP 1-4 output

$boardBlock

## Scope limitation

This automation verifies headless structure, data, parsing, scene instantiation, tile count, scale, anchor positions, background layering, and top-HUD composition. Final art quality, Windows click behavior, minimum-resolution readability, fonts, and color accessibility still require manual review.
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
    Invoke-NativeChecked -FilePath "git" -Arguments @("commit", "-m", $CommitMessage) -Label "Commit verification report" | Out-Null
    $commitOutput = Invoke-NativeChecked -FilePath "git" -Arguments @("rev-parse", "HEAD") -Label "Read commit SHA"
    $commitSha = ($commitOutput -join "").Trim()

    if (-not $NoPush) {
        Invoke-NativeChecked -FilePath "git" -Arguments @("push", "origin", $ExpectedBranch) -Label "Push verification result" | Out-Null
    }

    Write-Host "`nCombat UI foundation verification completed." -ForegroundColor Green
    Write-Host "Commit: $commitSha"
    if ($NoPush) {
        Write-Host "Push: skipped (-NoPush)"
    }
    else {
        Write-Host "Push: origin/$ExpectedBranch completed"
    }
}
catch {
    Write-Host "`nCombat UI foundation verification failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "No automatic commit or push was performed after failure." -ForegroundColor Yellow
    exit 1
}
