param(
    [string]$GodotPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
        "Godot_v4.7-stable_win64",
        "Godot_v4.7.1-stable_win64",
        "Godot_v4.7-stable_win64_console",
        "Godot_v4.7.1-stable_win64_console"
    )) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            return $command.Source
        }
    }

    $knownPaths = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\godot.exe",
        "$env:USERPROFILE\scoop\shims\godot.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4.7-stable_win64.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4.7.1-stable_win64.exe",
        "$env:ProgramFiles\Godot\Godot_v4.7-stable_win64.exe",
        "$env:ProgramFiles\Godot\Godot_v4.7.1-stable_win64.exe",
        "C:\Godot\Godot_v4.7-stable_win64.exe",
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
            Sort-Object @{ Expression = { if ($_.Name -like "*console*") { 1 } else { 0 } } }, FullName |
            Select-Object -First 1
        if ($null -ne $candidate) {
            return $candidate.FullName
        }
    }

    throw "Godot executable was not found. Use -GodotPath or set GODOT_BIN."
}

try {
    $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
    $projectPath = Join-Path $repoRoot "project.godot"
    if (-not (Test-Path -LiteralPath $projectPath -PathType Leaf)) {
        throw "project.godot was not found: $projectPath"
    }

    $godotExe = Resolve-GodotExecutable -ExplicitPath $GodotPath
    Start-Process -FilePath $godotExe -ArgumentList @("--path", $repoRoot) -WorkingDirectory $repoRoot
    Write-Host "Combat board launched in Godot." -ForegroundColor Green
}
catch {
    Write-Host "Failed to launch the combat board." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
