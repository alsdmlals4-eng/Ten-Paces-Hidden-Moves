[CmdletBinding()]
param(
    [string]$ProjectPath = ".",
    [string]$GodotPath = "",
    [string]$HeraPath = "",
    [string]$OutputDir = "",
    [switch]$SkipGodotChecks,
    [switch]$SkipGut,
    [switch]$SkipHeraSmoke
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# READ_ONLY_EVIDENCE_COLLECTOR
# PROJECT_MUTATION_ATTEMPTED_FALSE

function Protect-SecretText([AllowNull()][string]$Text) {
    if ($null -eq $Text) { return "" }
    $safe = [string]$Text
    $safe = [regex]::Replace($safe, '(?i)(https?://)[^/@\s]+@', '$1[REDACTED]@')
    $safe = [regex]::Replace($safe, '(?i)\b(token|secret|authorization|api[_-]?key|password)\b\s*[:=]\s*[^\s,;]+', '$1=[REDACTED]')
    return $safe
}

function Write-EvidenceText([string]$Path, [AllowNull()][string]$Text) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [IO.File]::WriteAllText($Path, (Protect-SecretText $Text), $utf8NoBom)
}

function Invoke-Capture([string]$File, [string[]]$CommandArgs, [string]$Cwd, [string]$Log = "") {
    $old = Get-Location
    try {
        Set-Location -LiteralPath $Cwd
        $global:LASTEXITCODE = 0
        $text = & $File @CommandArgs 2>&1 | Out-String
        $code = $LASTEXITCODE
        if ($null -eq $code) { $code = 0 }
        $text = Protect-SecretText $text
        if ($Log) { Write-EvidenceText $Log $text }
        return [ordered]@{ exit_code = [int]$code; output = $text.TrimEnd() }
    }
    catch {
        $text = Protect-SecretText $_.Exception.Message
        if ($Log) { Write-EvidenceText $Log $text }
        return [ordered]@{ exit_code = -1; output = $text }
    }
    finally { Set-Location -LiteralPath $old.Path }
}

function Git-Read([string[]]$CommandArgs, [string]$Root) {
    return Invoke-Capture -File "git" -CommandArgs $CommandArgs -Cwd $Root
}

function Text-Sha256([string]$Text) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)))).Replace("-", "").ToLowerInvariant()
    }
    finally { $sha.Dispose() }
}

function Tracked-Fingerprint([string]$Root) {
    $diff = Git-Read @("diff", "--no-ext-diff", "--binary", "HEAD", "--") $Root
    $status = Git-Read @("status", "--porcelain=v1", "--untracked-files=no") $Root
    $payload = "d=$($diff.exit_code)`n$($diff.output)`ns=$($status.exit_code)`n$($status.output)"
    return [ordered]@{ sha256 = Text-Sha256 $payload; ok = ($diff.exit_code -eq 0 -and $status.exit_code -eq 0) }
}

function Resolve-Godot([string]$Explicit) {
    if ($Explicit) { if (Test-Path -LiteralPath $Explicit -PathType Leaf) { return (Resolve-Path -LiteralPath $Explicit).Path }; return $null }
    if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf)) { return (Resolve-Path $env:GODOT_BIN).Path }
    foreach ($name in @("godot4", "godot", "Godot_v4.7.1-stable_win64", "Godot_v4.7.1-stable_win64_console")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $cmd) { return $cmd.Source }
    }
    foreach ($p in @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\godot.exe",
        "$env:USERPROFILE\scoop\shims\godot.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4.7.1-stable_win64.exe",
        "$env:ProgramFiles\Godot\Godot_v4.7.1-stable_win64.exe",
        "C:\Godot\Godot_v4.7.1-stable_win64.exe",
        "$env:USERPROFILE\Downloads\Godot_v4.7.1-stable_win64.exe",
        "$env:USERPROFILE\Desktop\Godot_v4.7.1-stable_win64.exe"
    )) { if ($p -and (Test-Path -LiteralPath $p -PathType Leaf)) { return (Resolve-Path $p).Path } }
    foreach ($root in @("$env:USERPROFILE\Downloads", "$env:USERPROFILE\Desktop")) {
        if (-not $root -or -not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        $hit = Get-ChildItem -LiteralPath $root -Filter "Godot_v4.7*.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $hit) { return $hit.FullName }
    }
    return $null
}

function Resolve-Hera([string]$Explicit) {
    if ($Explicit) { if (Test-Path -LiteralPath $Explicit -PathType Leaf) { return (Resolve-Path -LiteralPath $Explicit).Path }; return $null }
    foreach ($name in @("hera", "hera.exe")) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $cmd) { return $cmd.Source }
    }
    foreach ($p in @(
        "$env:USERPROFILE\Downloads\hera.exe",
        "$env:USERPROFILE\Downloads\hera-windows-amd64\hera.exe",
        "$env:USERPROFILE\Desktop\hera.exe",
        "$env:USERPROFILE\Desktop\hera-windows-amd64\hera.exe",
        "$env:LOCALAPPDATA\Programs\Hera\hera.exe",
        "$env:USERPROFILE\.local\bin\hera.exe"
    )) { if ($p -and (Test-Path -LiteralPath $p -PathType Leaf)) { return (Resolve-Path $p).Path } }
    return $null
}

function Plugin([string]$Root, [string]$Relative, [string[]]$Enabled) {
    $path = Join-Path $Root ($Relative -replace '/', [IO.Path]::DirectorySeparatorChar)
    $version = $null
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        $m = [regex]::Match([IO.File]::ReadAllText($path), '(?m)^version="([^"]+)"\s*$')
        if ($m.Success) { $version = $m.Groups[1].Value }
    }
    return [ordered]@{ path = $Relative; present = (Test-Path -LiteralPath $path -PathType Leaf); version = $version; enabled = ($Enabled -contains ("res://" + $Relative)) }
}

$Root = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
if (-not (Test-Path -LiteralPath $Root -PathType Container)) { throw "ProjectPath is not a directory: $Root" }
$projectFile = Join-Path $Root "project.godot"

$stamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
if (-not $OutputDir) { $OutputDir = Join-Path $Root ("build/local-validation/{0}" -f $stamp) }
elseif (-not [IO.Path]::IsPathRooted($OutputDir)) { $OutputDir = Join-Path $Root $OutputDir }
[IO.Directory]::CreateDirectory($OutputDir) | Out-Null
$OutputDir = (Resolve-Path -LiteralPath $OutputDir).Path

$git = [ordered]@{ available = $false; sync_status = "LOCAL_SYNC_BLOCKED_GIT_UNAVAILABLE" }
if ($null -ne (Get-Command git -ErrorAction SilentlyContinue)) {
    $inside = Git-Read @("rev-parse", "--is-inside-work-tree") $Root
    if ($inside.exit_code -eq 0 -and $inside.output.Trim() -eq "true") {
        $branch = Git-Read @("branch", "--show-current") $Root
        $head = Git-Read @("rev-parse", "HEAD") $Root
        $origin = Git-Read @("rev-parse", "origin/main") $Root
        $short = Git-Read @("status", "--short", "--branch") $Root
        $porcelain = Git-Read @("status", "--porcelain=v1") $Root
        $remote = Git-Read @("remote", "get-url", "origin") $Root
        $ahead = $null; $behind = $null
        if ($origin.exit_code -eq 0) {
            $counts = Git-Read @("rev-list", "--left-right", "--count", "HEAD...origin/main") $Root
            if ($counts.exit_code -eq 0) {
                $parts = $counts.output.Trim() -split '\s+'
                if ($parts.Count -ge 2) { $ahead = [int]$parts[0]; $behind = [int]$parts[1] }
            }
        }
        $clean = ($porcelain.exit_code -eq 0 -and -not $porcelain.output)
        if (-not $clean) { $sync = "LOCAL_SYNC_BLOCKED_DIRTY_WORKTREE" }
        elseif ($null -eq $ahead -or $null -eq $behind) { $sync = "LOCAL_SYNC_BLOCKED_ORIGIN_MAIN_UNRESOLVED" }
        elseif ($ahead -gt 0 -and $behind -gt 0) { $sync = "LOCAL_SYNC_BLOCKED_DIVERGED_MAIN" }
        elseif ($ahead -gt 0) { $sync = "LOCAL_SYNC_BLOCKED_LOCAL_ONLY_COMMITS" }
        elseif ($behind -gt 0) { $sync = "LOCAL_SYNC_READY_FAST_FORWARD" }
        else { $sync = "LOCAL_SYNC_CURRENT" }
        $originValue = $null; if ($origin.exit_code -eq 0) { $originValue = $origin.output.Trim() }
        $git = [ordered]@{
            available = $true; branch = $branch.output.Trim(); head = $head.output.Trim(); origin_main = $originValue
            ahead = $ahead; behind = $behind; working_tree_clean = $clean; short_status = $short.output
            remote_origin = $remote.output; sync_status = $sync
        }
        Write-EvidenceText (Join-Path $OutputDir "git-status.txt") $short.output
    }
}

$projectText = ""
if (Test-Path -LiteralPath $projectFile -PathType Leaf) { $projectText = [IO.File]::ReadAllText($projectFile) }
$mainScene = $null
$m = [regex]::Match($projectText, '(?m)^run/main_scene="([^"]+)"\s*$'); if ($m.Success) { $mainScene = $m.Groups[1].Value }
$enabledPlugins = @()
$section = [regex]::Match($projectText, '(?ms)^\[editor_plugins\]\s*(.*?)(?=^\[|\z)')
if ($section.Success) { foreach ($x in [regex]::Matches($section.Value, '"(res://addons/[^"]+/plugin\.cfg)"')) { $enabledPlugins += $x.Groups[1].Value } }
$autoloads = @()
$section = [regex]::Match($projectText, '(?ms)^\[autoload\]\s*(.*?)(?=^\[|\z)')
if ($section.Success) { foreach ($line in ($section.Groups[1].Value -split "`r?`n")) { if ($line.Trim()) { $autoloads += $line.Trim() } } }
$projectExists = Test-Path -LiteralPath $projectFile -PathType Leaf
$project = [ordered]@{ status = $(if ($projectExists) { "PASS" } else { "PROJECT_GODOT_NOT_FOUND" }); exists = $projectExists; main_scene = $mainScene; editor_plugins = $enabledPlugins; autoload_entries = $autoloads }
$plugins = [ordered]@{
    godot_ai = Plugin $Root "addons/godot_ai/plugin.cfg" $enabledPlugins
    gut = Plugin $Root "addons/gut/plugin.cfg" $enabledPlugins
    hera = Plugin $Root "addons/hera_agent_godot/plugin.cfg" $enabledPlugins
}

$godotExe = Resolve-Godot $GodotPath
$godot = [ordered]@{ executable = $godotExe; status = "GODOT_EXECUTABLE_UNRESOLVED"; version = $null; import_parse = "NOT_RUN"; import_parse_exit_code = $null }
if ($godotExe) {
    $r = Invoke-Capture $godotExe @("--version") $Root (Join-Path $OutputDir "godot-version.txt")
    $godot.version = $r.output.Trim(); $godot.status = $(if ($r.exit_code -eq 0) { "PASS" } else { "GODOT_VERSION_COMMAND_FAILED" })
    if (-not $git.available) {
        $godot.import_parse = "NOT_RUN_GIT_UNAVAILABLE_SAFETY"
        Write-EvidenceText (Join-Path $OutputDir "godot-import-parse.txt") $godot.import_parse
    }
    elseif (-not $git.working_tree_clean) {
        $godot.import_parse = "NOT_RUN_DIRTY_WORKTREE_SAFETY"
        Write-EvidenceText (Join-Path $OutputDir "godot-import-parse.txt") $godot.import_parse
    }
    elseif (-not $SkipGodotChecks) {
        $r = Invoke-Capture $godotExe @("--headless", "--editor", "--path", $Root, "--quit") $Root (Join-Path $OutputDir "godot-import-parse.txt")
        $godot.import_parse_exit_code = $r.exit_code; $godot.import_parse = $(if ($r.exit_code -eq 0) { "PASS" } else { "FAIL" })
    } else { $godot.import_parse = "NOT_RUN_SKIP_REQUESTED" }
} else {
    Write-EvidenceText (Join-Path $OutputDir "godot-version.txt") "GODOT_EXECUTABLE_UNRESOLVED"
    Write-EvidenceText (Join-Path $OutputDir "godot-import-parse.txt") "GODOT_EXECUTABLE_UNRESOLVED"
}

$gut = [ordered]@{ status = "NOT_RUN"; plugin_version = $plugins.gut.version; exit_code = $null; junit_path = "build/test-results/gut.xml" }
if (-not $git.available) { $gut.status = "NOT_RUN_GIT_UNAVAILABLE_SAFETY" }
elseif (-not $git.working_tree_clean) { $gut.status = "NOT_RUN_DIRTY_WORKTREE_SAFETY" }
elseif ($SkipGut) { $gut.status = "NOT_RUN_SKIP_REQUESTED" }
elseif (-not $plugins.gut.present) { $gut.status = "GUT_ADDON_NOT_FOUND" }
elseif (-not $godotExe) { $gut.status = "GUT_RUN_BLOCKED_GODOT_EXECUTABLE_UNRESOLVED" }
else {
    $r = Invoke-Capture $godotExe @("--headless", "--path", $Root, "--script", "res://addons/gut/gut_cmdln.gd") $Root (Join-Path $OutputDir "gut.txt")
    $gut.exit_code = $r.exit_code; $gut.status = $(if ($r.exit_code -eq 0) { "PASS" } else { "FAIL" })
}
if (-not (Test-Path (Join-Path $OutputDir "gut.txt"))) { Write-EvidenceText (Join-Path $OutputDir "gut.txt") $gut.status }

$heraExe = Resolve-Hera $HeraPath
$hera = [ordered]@{
    executable = $heraExe; status = "HERA_CLI_NOT_FOUND_OR_PATH_UNSET"; cli_version = $null
    version_exit_code = $null; live_status = "NOT_RUN"; live_status_exit_code = $null
    smoke = "NOT_RUN"; smoke_exit_code = $null; tracked_source_delta = "NOT_RUN"
}
if ($heraExe) {
    $r = Invoke-Capture $heraExe @("version") $Root (Join-Path $OutputDir "hera-version.txt")
    $hera.version_exit_code = $r.exit_code; $hera.cli_version = $r.output.Trim(); $hera.status = $(if ($r.exit_code -eq 0) { "PASS" } else { "HERA_VERSION_COMMAND_FAILED" })
    $r = Invoke-Capture $heraExe @("status") $Root (Join-Path $OutputDir "hera-status.txt")
    $hera.live_status_exit_code = $r.exit_code; $hera.live_status = $(if ($r.exit_code -eq 0) { "PASS" } else { "FAIL_OR_EDITOR_UNAVAILABLE" })
    if (-not $git.available) {
        $hera.smoke = "NOT_RUN_GIT_UNAVAILABLE_SAFETY"
        $hera.tracked_source_delta = "NOT_RUN_GIT_UNAVAILABLE_SAFETY"
        Write-EvidenceText (Join-Path $OutputDir "hera-smoke.txt") $hera.smoke
    }
    elseif (-not $git.working_tree_clean) {
        $hera.smoke = "NOT_RUN_DIRTY_WORKTREE_SAFETY"
        $hera.tracked_source_delta = "NOT_RUN_DIRTY_WORKTREE_SAFETY"
        Write-EvidenceText (Join-Path $OutputDir "hera-smoke.txt") $hera.smoke
    }
    elseif (-not $SkipHeraSmoke) {
        $pre = Tracked-Fingerprint $Root
        $r = Invoke-Capture $heraExe @("smoke", "--skip-game") $Root (Join-Path $OutputDir "hera-smoke.txt")
        $post = Tracked-Fingerprint $Root
        $hera.smoke_exit_code = $r.exit_code; $hera.smoke = $(if ($r.exit_code -eq 0) { "PASS" } else { "FAIL" })
        if ($pre.ok -and $post.ok -and $pre.sha256 -eq $post.sha256) { $hera.tracked_source_delta = "HERA_SOURCE_DELTA_NONE" }
        elseif (-not $pre.ok -or -not $post.ok) { $hera.tracked_source_delta = "HERA_SOURCE_DELTA_BLOCKED_GIT_UNVERIFIED" }
        else { $hera.tracked_source_delta = "HERA_SOURCE_DELTA_DETECTED_FAIL" }
    } else { $hera.smoke = "NOT_RUN_SKIP_REQUESTED"; $hera.tracked_source_delta = "NOT_RUN_SKIP_REQUESTED" }
} else {
    Write-EvidenceText (Join-Path $OutputDir "hera-version.txt") "HERA_CLI_NOT_FOUND_OR_PATH_UNSET"
    Write-EvidenceText (Join-Path $OutputDir "hera-status.txt") "HERA_CLI_NOT_FOUND_OR_PATH_UNSET"
    Write-EvidenceText (Join-Path $OutputDir "hera-smoke.txt") "HERA_CLI_NOT_FOUND_OR_PATH_UNSET"
}

$finalGit = $git
if ($git.available) {
    $s = Git-Read @("status", "--short", "--branch") $Root
    Write-EvidenceText (Join-Path $OutputDir "git-status-after.txt") $s.output
    $finalGit = [ordered]@{}
    foreach ($key in $git.Keys) { $finalGit[$key] = $git[$key] }
    $finalGit.short_status = $s.output
}

$blocking = @()
foreach ($v in @($git.sync_status, $project.status, $godot.status, $gut.status, $hera.status, $hera.live_status, $hera.smoke, $hera.tracked_source_delta)) {
    if ($null -ne $v -and ([string]$v) -match 'BLOCKED|UNRESOLVED|FAIL|NOT_FOUND') { $blocking += [string]$v }
}
$blocking = @($blocking | Select-Object -Unique)
$status = $(if ($blocking.Count -gt 0) { "COMPLETE_WITH_BLOCKERS" } else { "COMPLETE" })
$evidence = [ordered]@{
    schema_version = 1; collector_id = "TEN-LOCAL-GODOT-LIVE-EVIDENCE"; collector_mode = "READ_ONLY_EVIDENCE_COLLECTOR"
    collected_at_utc = (Get-Date).ToUniversalTime().ToString("o"); project_path = $Root; output_dir = $OutputDir
    safety = [ordered]@{ persistent_project_mutation = "PROJECT_MUTATION_ATTEMPTED_FALSE"; repository_sync_performed = $false; destructive_git_operation_performed = $false; secret_redaction = "ENABLED" }
    git = $git; project = $project; plugins = $plugins; godot = $godot; gut = $gut; hera = $hera; final_git = $finalGit
    blocking_statuses = $blocking; collector_status = $status
}
$jsonPath = Join-Path $OutputDir "godot-live-evidence.json"
Write-EvidenceText $jsonPath ($evidence | ConvertTo-Json -Depth 12)
Write-Host "Local Godot evidence collection complete." -ForegroundColor Green
Write-Host "Collector status: $status"
Write-Host "Git sync status: $($git.sync_status)"
Write-Host "Godot: $($godot.status) / import-parse: $($godot.import_parse)"
Write-Host "GUT: $($gut.status)"
Write-Host "Hera: $($hera.status) / status: $($hera.live_status) / smoke: $($hera.smoke) / delta: $($hera.tracked_source_delta)"
Write-Host "Evidence JSON: $jsonPath"
exit 0
