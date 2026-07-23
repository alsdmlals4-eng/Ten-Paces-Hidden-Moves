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

    if (-not [string]::IsNullOrWhiteSpace($env:GODOT_BIN) -and (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf)) {
        return (Resolve-Path -LiteralPath $env:GODOT_BIN).Path
    }

    foreach ($commandName in @("godot4", "godot", "Godot_v4.7.1-stable_win64_console", "Godot_v4.7.1-stable_win64")) {
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

    $searchRoots = @("$env:USERPROFILE\Downloads", "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents") |
        Where-Object { Test-Path -LiteralPath $_ -PathType Container }
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

    $insideWorkTree = Invoke-NativeChecked -FilePath "git" -Arguments @("-C", $repoRoot, "rev-parse", "--is-inside-work-tree") -Label "Check Git worktree"
    if (($insideWorkTree -join "").Trim() -ne "true") {
        throw "The script directory is not inside a Git worktree: $repoRoot"
    }

    Set-Location -LiteralPath $repoRoot
    $branch = ((Invoke-NativeChecked -FilePath "git" -Arguments @("branch", "--show-current") -Label "Check branch") -join "").Trim()
    if ($branch -ne $ExpectedBranch) {
        throw "Unexpected branch. expected=$ExpectedBranch actual=$branch"
    }

    $initialStatus = @(Invoke-NativeChecked -FilePath "git" -Arguments @("status", "--porcelain", "--untracked-files=all") -Label "Check clean worktree" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($initialStatus.Count -gt 0) {
        throw "The worktree is not clean. Preserve or commit existing changes before retrying.`n$($initialStatus -join "`n")"
    }

    Invoke-NativeChecked -FilePath "git" -Arguments @("fetch", "origin") -Label "Fetch origin" | Out-Null
    Invoke-NativeChecked -FilePath "git" -Arguments @("pull", "--ff-only", "origin", $ExpectedBranch) -Label "Fast-forward branch" | Out-Null

    $postPullStatus = @(Invoke-NativeChecked -FilePath "git" -Arguments @("status", "--porcelain", "--untracked-files=all") -Label "Recheck clean worktree" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($postPullStatus.Count -gt 0) {
        throw "Unexpected local changes appeared after pull.`n$($postPullStatus -join "`n")"
    }

    $godotExe = Resolve-GodotExecutable -ExplicitPath $GodotPath
    $godotVersion = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--version") -Label "Check Godot version"
    $versionText = ($godotVersion -join " ").Trim()
    if ($versionText -notmatch "^4\.") {
        throw "Godot 4.x is required. actual=$versionText"
    }

    $parseOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--editor", "--path", $repoRoot, "--quit") -Label "Import and parse Godot project"
    $step0Output = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_step0.gd") -Label "Verify STEP 0 card components"
    $boardOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_board.gd") -Label "Verify STEP 1-10 plus TARGETING 10.5 and start tiles 4/7"
    $responseOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_response_rules.gd") -Label "Verify RESPONSE 10.6 and immediate resource preview"
    $issue11Output = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_ultimate_interrupt_engagement.gd") -Label "Verify Issue #11 ultimates, interruption, fortitude, engagement, and timing snapshots"
    $ultimateUiOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_ultimate_ui.gd") -Label "Verify ultimate reservation and visible authoritative playback"
    $terminalOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_terminal_presentation.gd") -Label "Verify terminal combat presentation state and defeat SFX"
    $sfxOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_sfx_presentation.gd") -Label "Verify authoritative momentum and block SFX requests"
    $characterArtOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_character_art.gd") -Label "Verify full-body character art and tile foot anchors"
    $focusVisualsOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_focus_visuals.gd") -Label "Verify visible keyboard focus rings on standard combat controls"
    $focusOrderOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_focus_order.gd") -Label "Verify explicit keyboard focus order through combat planning controls"
    $assistiveLabelsOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_assistive_labels.gd") -Label "Verify Korean accessibility names and descriptions on combat controls"
    $pointerLockOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_pointer_lock.gd") -Label "Verify pointer inputs cannot alter reservations while resolving"
    $presentationControlsOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_presentation_controls.gd") -Label "Verify skip cancels an active ultimate presentation immediately"
    $keyboardOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_keyboard_accessibility.gd") -Label "Verify keyboard card-slot-target-progress path"
    $layoutOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_layout_accessibility.gd") -Label "Verify 960x640 and 1440x900 combat layout bounds"
    $performanceOutput = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_combat_performance_headless.gd") -Label "Record headless combat performance baseline"

    $sideEffects = @(Invoke-NativeChecked -FilePath "git" -Arguments @("status", "--porcelain", "--untracked-files=all") -Label "Check verification side effects" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($sideEffects.Count -gt 0) {
        throw "Verification modified unexpected files. Commit was blocked.`n$($sideEffects -join "`n")"
    }

    $reportPath = Join-Path $repoRoot $ReportRelativePath
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $reportPath) | Out-Null
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $parseBlock = Format-IndentedBlock -Lines $parseOutput
    $step0Block = Format-IndentedBlock -Lines $step0Output
    $boardBlock = Format-IndentedBlock -Lines $boardOutput
    $responseBlock = Format-IndentedBlock -Lines $responseOutput
    $issue11Block = Format-IndentedBlock -Lines $issue11Output
    $ultimateUiBlock = Format-IndentedBlock -Lines $ultimateUiOutput
    $terminalBlock = Format-IndentedBlock -Lines $terminalOutput
    $sfxBlock = Format-IndentedBlock -Lines $sfxOutput
    $characterArtBlock = Format-IndentedBlock -Lines $characterArtOutput
    $focusVisualsBlock = Format-IndentedBlock -Lines $focusVisualsOutput
    $focusOrderBlock = Format-IndentedBlock -Lines $focusOrderOutput
    $assistiveLabelsBlock = Format-IndentedBlock -Lines $assistiveLabelsOutput
    $pointerLockBlock = Format-IndentedBlock -Lines $pointerLockOutput
    $presentationControlsBlock = Format-IndentedBlock -Lines $presentationControlsOutput
    $keyboardBlock = Format-IndentedBlock -Lines $keyboardOutput
    $layoutBlock = Format-IndentedBlock -Lines $layoutOutput
    $performanceBlock = Format-IndentedBlock -Lines $performanceOutput

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
- [x] STEP 1-9 presentation, HUD, timing, cards, detail, log, progress, and placement
- [x] Ten-tile board starts the player on tile 4 and the enemy on tile 7
- [x] Initial combat distance is 3 tiles
- [x] First movement fixture advances the player 4→5 and the enemy 7→6
- [x] Combat begins at round 1, bundle 1, timing 1
- [x] STEP 10 resolves in response, quick attack, move, and general order
- [x] TARGETING 10.5 movement cards require an explicit destination tile
- [x] TARGETING 10.5 attack cards require an explicit left or right direction
- [x] Movable and attackable tiles use color, shape, and text cues
- [x] Progress remains locked until all required targets are selected
- [x] Wrong-direction attacks resolve as misses
- [x] Explicit movement targets update the board position
- [x] RESPONSE 10.6 same-timing guard uses the stronger of 50% reduction and guard block
- [x] RESPONSE 10.6 same-bundle guard applies guard block
- [x] RESPONSE 10.6 same-timing evade fully avoids damage
- [x] Stance+response one-slot combos extend protection to the current bundle
- [x] Stance+guard increases guard block by 50%
- [x] Placement immediately previews resource costs and recovery
- [x] Insufficient planned resources keep progress locked
- [x] Completed bundle advances to the next bundle and round after timing 10
- [x] Resolution and targeting entries append to the combat log
- [x] Issue #11 interruption and fortitude are enabled; Focus is removed
- [x] Issue #11 three ultimate skills, engagement, interruption, fortitude, and authoritative timing snapshots
- [x] Ultimate reservation and visible authoritative VFX playback
- [x] Terminal combat presentation locks at combat_ended and requests defeat SFX
- [x] Authoritative momentum charge and block/metal-clash SFX requests
- [x] Full-body player/enemy character art loads while preserving tile foot anchors
- [x] Standard keyboard controls expose a visible white focus ring
- [x] Tab focus order is explicit: cards → timings → tiles → progress → presentation controls
- [x] Combat controls expose Korean accessibility names and descriptions
- [x] Pointer card, timing-slot, and ultimate inputs cannot alter reservations while resolving
- [x] Skip cancels an active ultimate presentation wait immediately
- [x] Keyboard card → slot → target → progress path
- [x] 960×640 and 1440×900 HUD, ultimate list, timing, progress, and tray bounds
- [x] Headless performance baseline record

## Godot import and parse output

$parseBlock

## STEP 0 output

$step0Block

## STEP 1-10 + TARGETING 10.5 + start tiles 4/7 output

$boardBlock

## RESPONSE 10.6 + resource preview output

$responseBlock

## Issue #11 rules and timing-snapshot output

$issue11Block

## Ultimate UI output

$ultimateUiBlock

## Terminal combat presentation output

$terminalBlock

## Procedural SFX presentation output

$sfxBlock

## Character-art presentation output

$characterArtBlock

## Keyboard-focus visual output

$focusVisualsBlock

## Keyboard-focus order output

$focusOrderBlock

## Assistive-label output

$assistiveLabelsBlock

## Pointer-lock presentation output

$pointerLockBlock

## Presentation-control output

$presentationControlsBlock

## Keyboard accessibility output

$keyboardBlock

## Layout accessibility output

$layoutBlock

## Headless performance output

$performanceBlock

## Scope limitation

This automation verifies headless structure, parsing, scene instantiation, player tile 4 and enemy tile 7 initialization, placement, targeting, deterministic bundle resolution, response mitigation, stance-response combos, immediate planned-resource preview, board-state updates, bundle advancement, Issue #11 interruption/fortitude/engagement/ultimates, terminal combat presentation, authoritative timing playback and SFX requests, resolving-pointer input lock, cancellable skip, explicit Tab order, Korean assistive labels, keyboard activation, and 960×640/1440×900 layout bounds. Final art quality, Windows pointer feel, real font rendering, screen-reader use, actual audio playback, and GPU/CPU/load performance on the target Windows platform still require manual review.
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
    $commitSha = ((Invoke-NativeChecked -FilePath "git" -Arguments @("rev-parse", "HEAD") -Label "Read commit SHA") -join "").Trim()

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
