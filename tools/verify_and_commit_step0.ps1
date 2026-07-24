param(
    [string]$GodotPath = "",
    [switch]$NoPush
)

$arguments = @{}
if (-not [string]::IsNullOrWhiteSpace($GodotPath)) {
    $arguments["GodotPath"] = $GodotPath
}
if ($NoPush) {
    $arguments["NoPush"] = $true
}

& (Join-Path $PSScriptRoot "verify_and_commit_combat_foundation.ps1") @arguments
exit 0
