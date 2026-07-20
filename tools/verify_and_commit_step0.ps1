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

function Get-PropertyNames {
    param([Parameter(Mandatory = $true)]$Object)
    return @($Object.PSObject.Properties | ForEach-Object { $_.Name })
}

function Assert-SameSet {
    param(
        [Parameter(Mandatory = $true)][object[]]$Actual,
        [Parameter(Mandatory = $true)][object[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $actualNormalized = @($Actual | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    $expectedNormalized = @($Expected | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    $difference = @(Compare-Object -ReferenceObject $expectedNormalized -DifferenceObject $actualNormalized)
    if ($difference.Count -gt 0) {
        throw "$Label mismatch. expected=$($expectedNormalized -join ',') actual=$($actualNormalized -join ',')"
    }
}

function Resolve-ResourcePath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$ResourcePath
    )

    if (-not $ResourcePath.StartsWith("res://", [System.StringComparison]::Ordinal)) {
        throw "Resource path must start with res:// : $ResourcePath"
    }

    $relative = $ResourcePath.Substring(6).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    return Join-Path $RepoRoot $relative
}

function Assert-ResourceExists {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$ResourcePath,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $fullPath = Resolve-ResourcePath -RepoRoot $RepoRoot -ResourcePath $ResourcePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "$Label resource was not found: $ResourcePath"
    }
}

function Assert-AtlasSpec {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)]$Spec,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Assert-SameSet -Actual (Get-PropertyNames -Object $Spec) -Expected @("atlas", "region") -Label "$Label fields"
    $atlasPath = [string]$Spec.atlas
    Assert-ResourceExists -RepoRoot $RepoRoot -ResourcePath $atlasPath -Label "$Label atlas"

    $region = @($Spec.region)
    if ($region.Count -ne 4) {
        throw "$Label region must contain exactly four numbers."
    }

    for ($index = 0; $index -lt 4; $index++) {
        $value = 0
        if (-not [int]::TryParse([string]$region[$index], [ref]$value) -or $value -lt 0) {
            throw "$Label region contains an invalid value at index $index."
        }
        if ($index -ge 2 -and $value -le 0) {
            throw "$Label region width and height must be greater than zero."
        }
    }
}

function Invoke-PowerShellCardContract {
    param([Parameter(Mandatory = $true)][string]$RepoRoot)

    Write-Host "`n== Validate card contract (PowerShell) ==" -ForegroundColor Cyan

    $catalogPath = Join-Path $RepoRoot "data/cards/basic_cards.json"
    $manifestPath = Join-Path $RepoRoot "assets/ui/cards/card_asset_manifest.json"
    if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
        throw "Card catalog was not found: $catalogPath"
    }
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "Card asset manifest was not found: $manifestPath"
    }

    $catalog = Get-Content -LiteralPath $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

    $requiredFields = @(
        "id", "name", "source_label", "source_badge", "range_text",
        "category", "category_label", "category_badge", "illustration",
        "target", "damage", "condition", "effect_text", "tags",
        "action_slots", "stamina_cost", "internal_cost", "flavor"
    )
    $forbiddenFields = @("action_point_cost", "guard_reduction")
    $expectedIds = @(
        "basic_move", "basic_guard", "basic_evade", "basic_quick_attack",
        "basic_heavy_attack", "basic_meditate", "basic_stance"
    )
    $expectedCategories = @("move", "attack", "response", "recovery", "strengthen")
    $expectedBasicLabel = ([string][char]0xAE30) + ([string][char]0xCD08)

    $cards = @($catalog.cards)
    if ($cards.Count -ne 7) {
        throw "The card catalog must contain exactly seven cards. actual=$($cards.Count)"
    }

    Assert-SameSet -Actual @($cards | ForEach-Object { $_.id }) -Expected $expectedIds -Label "Card IDs"
    Assert-SameSet -Actual @($cards | ForEach-Object { $_.category }) -Expected $expectedCategories -Label "Card categories"

    foreach ($card in $cards) {
        $cardId = [string]$card.id
        $names = Get-PropertyNames -Object $card
        foreach ($field in $requiredFields) {
            if ($names -notcontains $field) {
                throw "$cardId is missing required field: $field"
            }
        }
        foreach ($field in $forbiddenFields) {
            if ($names -contains $field) {
                throw "$cardId contains forbidden field: $field"
            }
        }
        if ([string]$card.source_label -ne $expectedBasicLabel) {
            throw "$cardId source_label is not the approved basic label."
        }
        if ([int]$card.action_slots -lt 1) {
            throw "$cardId action_slots must be at least 1."
        }
        if ([int]$card.stamina_cost -lt 0 -or [int]$card.internal_cost -lt 0) {
            throw "$cardId resource costs must be zero or greater."
        }
        Assert-AtlasSpec -RepoRoot $RepoRoot -Spec $card.source_badge -Label "$cardId.source_badge"
        Assert-AtlasSpec -RepoRoot $RepoRoot -Spec $card.category_badge -Label "$cardId.category_badge"
        Assert-AtlasSpec -RepoRoot $RepoRoot -Spec $card.illustration -Label "$cardId.illustration"
    }

    Assert-SameSet -Actual @($manifest.template_contract.bottom) -Expected @("action_slots", "stamina_cost", "internal_cost") -Label "Manifest bottom contract"
    Assert-SameSet -Actual @($manifest.template_contract.removed) -Expected $forbiddenFields -Label "Manifest removed fields"
    Assert-ResourceExists -RepoRoot $RepoRoot -ResourcePath ([string]$manifest.step_2_reference) -Label "STEP 2 reference"

    foreach ($atlasProperty in @($manifest.atlases.PSObject.Properties)) {
        $atlas = $atlasProperty.Value
        Assert-ResourceExists -RepoRoot $RepoRoot -ResourcePath ([string]$atlas.path) -Label "Manifest atlas $($atlasProperty.Name)"
        if (@($atlas.regions.PSObject.Properties).Count -eq 0) {
            throw "Manifest atlas has no regions: $($atlasProperty.Name)"
        }
    }

    $projectText = Get-Content -LiteralPath (Join-Path $RepoRoot "project.godot") -Raw -Encoding UTF8
    if ($projectText -notlike '*run/main_scene="res://scenes/ui/card_component_preview.tscn"*') {
        throw "project.godot does not point to the card component preview scene."
    }

    $requiredFiles = @(
        "scenes/ui/card_view.tscn",
        "scenes/ui/card_detail_panel.tscn",
        "scenes/ui/card_component_preview.tscn",
        "src/ui/card_catalog.gd",
        "src/ui/card_view.gd",
        "src/ui/card_detail_panel.gd",
        "src/ui/card_component_preview.gd",
        "tests/verify_step0.gd"
    )
    foreach ($relativePath in $requiredFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $relativePath) -PathType Leaf)) {
            throw "Required STEP 0 file was not found: $relativePath"
        }
    }

    $result = @(
        "PowerShell card component contract: PASS",
        "cards=7",
        "categories=move,attack,response,recovery,strengthen",
        "costs=action_slots,stamina_cost,internal_cost",
        "forbidden=action_point_cost,guard_reduction"
    )
    $result | ForEach-Object { Write-Host $_ }
    return $result
}

try {
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
    $godotVersion = Invoke-NativeChecked -FilePath $godotExe -Arguments @("--version") -Label "Check Godot version"
    $versionText = ($godotVersion -join " ").Trim()
    if ($versionText -notmatch "^4\.") {
        throw "Godot 4.x is required. actual=$versionText"
    }

    $staticOutput = Invoke-PowerShellCardContract -RepoRoot $repoRoot

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
- Static validator: Windows PowerShell 5.1 compatible, no local Python required

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
