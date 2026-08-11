# Ten Paces Local Executor Launcher v5
# Fixes: resilient Hera exact-instance auth source resolution + Windows PowerShell 5.1 Codex login branch.
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01
# ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP / BOOTSTRAP_MINIMUM_PREFLIGHT_ONLY

$Project = 'C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves'
$ExpectedRemote = 'https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves.git'
$TargetGodot = 'C:\Users\user\Tools\Godot-Ten-Paces-4.7.1'
$GodotExeName = 'Godot_v4.7.1-stable_win64.exe'
$GodotConsoleName = 'Godot_v4.7.1-stable_win64_console.exe'
$GodotZipName = 'Godot_v4.7.1-stable_win64.exe.zip'
$TargetGodotExe = Join-Path $TargetGodot $GodotExeName
$SelfContainedMarker = Join-Path $TargetGodot '_sc_'
$SelfContainedData = Join-Path $TargetGodot 'editor_data'
$HttpPort = 8003
$WsPort = 9503
$CodexHome = 'C:\Users\user\.codex-ten-paces'
$HeraHome = Join-Path $env:USERPROFILE '.hera-agent-godot'
$HeraInstances = Join-Path $HeraHome 'instances'
$HeraTokenFile = Join-Path $TargetGodot '.hera-token'
$HeraSharedTokenFile = Join-Path $HeraHome 'token'
$ExpectedHeraVersion = 'v1.0.0'
$GodotAiAddonSource = Join-Path $Project 'addons\godot_ai'

function Invoke-Capture([string]$File, [string[]]$CommandArgs, [string]$Cwd) {
    $old = Get-Location
    $oldPreference = $ErrorActionPreference
    try {
        Set-Location -LiteralPath $Cwd
        $ErrorActionPreference = 'Continue'
        $global:LASTEXITCODE = 0
        $text = & $File @CommandArgs 2>&1 | Out-String
        $code = $LASTEXITCODE
        if ($null -eq $code) { $code = 0 }
        return [ordered]@{ exit_code = [int]$code; output = $text.TrimEnd() }
    }
    catch {
        return [ordered]@{ exit_code = -1; output = $_.Exception.Message }
    }
    finally {
        $ErrorActionPreference = $oldPreference
        Set-Location -LiteralPath $old.Path
    }
}

function Normalize-PathText([string]$PathText) {
    if ([string]::IsNullOrWhiteSpace($PathText)) { return '' }
    return $PathText.Replace('/', '\').TrimEnd('\').ToLowerInvariant()
}

function Get-TargetGodotProcesses {
    $target = Normalize-PathText $TargetGodotExe
    try {
        return @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object {
            $_.ExecutablePath -and (Normalize-PathText ([string]$_.ExecutablePath)) -eq $target
        })
    }
    catch {
        throw "WINDOWS_PROCESS_QUERY_FAILED: $($_.Exception.Message)"
    }
}

function Get-ExactGodotProcess {
    $projectNeedle = Normalize-PathText $Project
    $targetProcesses = @(Get-TargetGodotProcesses)
    $foundEditors = @()
    foreach ($proc in $targetProcesses) {
        $rawCommandLine = [string]$proc.CommandLine
        $cmd = Normalize-PathText $rawCommandLine
        $hasExplicitPath = $rawCommandLine -match '(?i)(?:^|\s)--path(?:\s|=)'
        if ($hasExplicitPath -and $cmd.Contains($projectNeedle)) {
            $foundEditors += $proc
        }
    }
    # EXACT_GODOT_REQUIRES_PATH_ARGUMENT: a target executable without explicit
    # --path is never treated as the Ten Paces editor merely because its command
    # line happens to contain the project path elsewhere.
    if ($foundEditors.Count -gt 1) {
        throw "MULTIPLE_EXACT_TEN_PACES_GODOT_EDITORS: $($foundEditors.ProcessId -join ',')"
    }
    if ($foundEditors.Count -eq 1) { return $foundEditors[0] }
    if ($targetProcesses.Count -gt 0) {
        throw "DEDICATED_GODOT_RUNNING_WRONG_OR_UNRESOLVED_PROJECT pids=$($targetProcesses.ProcessId -join ',')"
    }
    return $null
}

function Get-ListenOwner([int]$Port) {
    try {
        $rows = @(Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction Stop)
        if ($rows.Count -gt 0) {
            return @($rows | Select-Object -ExpandProperty OwningProcess -Unique)
        }
    }
    catch {
        # Fall back to netstat for older/limited PowerShell environments.
    }

    $netstat = Get-Command 'netstat.exe' -ErrorAction SilentlyContinue
    if ($null -eq $netstat) { throw "PORT_OWNERSHIP_QUERY_UNAVAILABLE port=$Port" }
    $ownerPids = @()
    try {
        foreach ($line in @(& $netstat.Source -ano -p tcp 2>$null)) {
            if ($line -match ("^\s*TCP\s+\S+:" + $Port + "\s+\S+\s+LISTENING\s+(\d+)\s*$")) {
                $ownerPids += [int]$Matches[1]
            }
        }
    }
    catch {
        throw "PORT_OWNERSHIP_QUERY_FAILED port=$Port error=$($_.Exception.Message)"
    }
    return @($ownerPids | Select-Object -Unique)
}

function Test-ProcessDescendantOf([int]$ChildPid, [int]$AncestorPid) {
    if ($ChildPid -eq $AncestorPid) { return $true }
    $seen = @{}
    $current = $ChildPid
    for ($i = 0; $i -lt 16; $i++) {
        if ($seen.ContainsKey($current)) { return $false }
        $seen[$current] = $true
        try {
            $proc = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $current) -ErrorAction Stop
        }
        catch {
            return $false
        }
        if ($null -eq $proc) { return $false }
        $parent = [int]$proc.ParentProcessId
        if ($parent -eq $AncestorPid) { return $true }
        if ($parent -le 0 -or $parent -eq $current) { return $false }
        $current = $parent
    }
    return $false
}

function Assert-HiGodotPortOwnership([int]$EditorPid) {
    foreach ($port in @($HttpPort, $WsPort)) {
        $owners = @(Get-ListenOwner $port)
        if ($owners.Count -eq 0) {
            throw "HIGODOT_EXPECTED_PORT_NOT_READY port=$port editor_pid=$EditorPid"
        }
        if ($owners.Count -ne 1) {
            throw "FOREIGN_OR_AMBIGUOUS_PORT_OWNER port=$port pids=$($owners -join ',')"
        }
        if (-not (Test-ProcessDescendantOf ([int]$owners[0]) $EditorPid)) {
            throw "FOREIGN_OR_AMBIGUOUS_PORT_OWNER port=$port pid=$($owners[0]) editor_pid=$EditorPid"
        }
    }
}

function Read-PluginVersion([string]$RelativePath) {
    $path = Join-Path $Project ($RelativePath -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "PLUGIN_CFG_MISSING: $RelativePath"
    }
    $text = [IO.File]::ReadAllText($path)
    $match = [regex]::Match($text, '(?m)^version="([^"]+)"\s*$')
    if (-not $match.Success) { throw "PLUGIN_VERSION_UNRESOLVED: $RelativePath" }
    return $match.Groups[1].Value
}

function Get-ProjectSectionText([string]$ProjectText, [string]$SectionName) {
    $escaped = [regex]::Escape($SectionName)
    $header = [regex]::Match($ProjectText, "(?m)^\[$escaped\]\s*$")
    if (-not $header.Success) { throw "PROJECT_SECTION_MISSING: [$SectionName]" }
    $tailStart = $header.Index + $header.Length
    $tail = $ProjectText.Substring($tailStart)
    $next = [regex]::Match($tail, '(?m)^\[[^\]]+\]\s*$')
    $endIndex = $(if ($next.Success) { $tailStart + $next.Index } else { $ProjectText.Length })
    return $ProjectText.Substring($tailStart, $endIndex - $tailStart)
}

function Assert-ProjectToolchain {
    $projectFile = Join-Path $Project 'project.godot'
    $projectText = [IO.File]::ReadAllText($projectFile)
    $pluginsSection = Get-ProjectSectionText $projectText 'editor_plugins' # [editor_plugins]
    $autoloadSection = Get-ProjectSectionText $projectText 'autoload' # [autoload]

    foreach ($plugin in @('res://addons/godot_ai/plugin.cfg', 'res://addons/gut/plugin.cfg', 'res://addons/hera_agent_godot/plugin.cfg')) {
        if (-not $pluginsSection.Contains($plugin)) { throw "REQUIRED_EDITOR_PLUGIN_NOT_ENABLED: $plugin" }
    }
    foreach ($autoloadName in @('HeraGameInspector', '_mcp_game_helper')) {
        $pattern = '(?m)^\s*' + [regex]::Escape($autoloadName) + '\s*='
        if (-not ($autoloadSection -match $pattern)) {
            throw "REQUIRED_TOOLING_AUTOLOAD_NOT_PREBOUND_BOOTSTRAP_WOULD_MUTATE_PROJECT: $autoloadName"
        }
    }
    $godotAiVersion = Read-PluginVersion 'addons/godot_ai/plugin.cfg'
    if ($godotAiVersion -ne '3.1.4') { throw "GODOT_AI_VERSION_MISMATCH_EXPECTED_3_1_4: $godotAiVersion" }
    $gutVersion = Read-PluginVersion 'addons/gut/plugin.cfg'
    if ($gutVersion -ne '9.7.1') { throw "GUT_VERSION_MISMATCH_EXPECTED_9_7_1: $gutVersion" }
    $heraAddonVersion = Read-PluginVersion 'addons/hera_agent_godot/plugin.cfg'
    if ($heraAddonVersion -ne '1.0.0') { throw "HERA_ADDON_VERSION_MISMATCH_EXPECTED_1_0_0: $heraAddonVersion" }
    return [ordered]@{ godot_ai = $godotAiVersion; gut = $gutVersion; hera = $heraAddonVersion }
}

function Resolve-GodotSource {
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $directExe = Join-Path $downloads $GodotExeName
    if (Test-Path -LiteralPath $directExe -PathType Leaf) {
        return [ordered]@{ kind = 'exe'; path = (Resolve-Path -LiteralPath $directExe).Path }
    }
    if (Test-Path -LiteralPath $downloads -PathType Container) {
        $hit = Get-ChildItem -LiteralPath $downloads -Filter $GodotExeName -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $hit) { return [ordered]@{ kind = 'exe'; path = $hit.FullName } }
    }

    $directZip = Join-Path $downloads $GodotZipName
    if (Test-Path -LiteralPath $directZip -PathType Leaf) {
        return [ordered]@{ kind = 'zip'; path = (Resolve-Path -LiteralPath $directZip).Path }
    }
    if (Test-Path -LiteralPath $downloads -PathType Container) {
        $zipHit = Get-ChildItem -LiteralPath $downloads -Filter $GodotZipName -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $zipHit) { return [ordered]@{ kind = 'zip'; path = $zipHit.FullName } }
    }
    return $null
}

function Ensure-DedicatedGodot {
    New-Item -ItemType Directory -Force -Path $TargetGodot | Out-Null

    if (-not (Test-Path -LiteralPath $TargetGodotExe -PathType Leaf)) {
        $source = Resolve-GodotSource
        if ($null -eq $source) {
            throw "GODOT_4_7_1_SOURCE_NOT_FOUND: place $GodotExeName or $GodotZipName under $env:USERPROFILE\Downloads"
        }

        if ($source.kind -eq 'exe') {
            Copy-Item -LiteralPath $source.path -Destination $TargetGodotExe -Force
            $sourceConsole = Join-Path (Split-Path -Parent $source.path) $GodotConsoleName
            if (Test-Path -LiteralPath $sourceConsole -PathType Leaf) {
                Copy-Item -LiteralPath $sourceConsole -Destination (Join-Path $TargetGodot $GodotConsoleName) -Force
            }
        }
        elseif ($source.kind -eq 'zip') {
            $tempRoot = Join-Path $env:TEMP ("ten-paces-godot-" + [Guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
            try {
                Expand-Archive -LiteralPath $source.path -DestinationPath $tempRoot -Force
                $gui = Get-ChildItem -LiteralPath $tempRoot -Filter $GodotExeName -File -Recurse | Select-Object -First 1
                if ($null -eq $gui) { throw "GODOT_ARCHIVE_MISSING_EXACT_EXE: $($source.path)" }
                Copy-Item -LiteralPath $gui.FullName -Destination $TargetGodotExe -Force
                $console = Get-ChildItem -LiteralPath $tempRoot -Filter $GodotConsoleName -File -Recurse | Select-Object -First 1
                if ($null -ne $console) {
                    Copy-Item -LiteralPath $console.FullName -Destination (Join-Path $TargetGodot $GodotConsoleName) -Force
                }
            }
            finally {
                if (Test-Path -LiteralPath $tempRoot -PathType Container) {
                    Remove-Item -LiteralPath $tempRoot -Recurse -Force
                }
            }
        }
    }

    if (-not (Test-Path -LiteralPath $TargetGodotExe -PathType Leaf)) {
        throw "DEDICATED_GODOT_EXE_MISSING: $TargetGodotExe"
    }

    if (-not (Test-Path -LiteralPath $SelfContainedMarker -PathType Leaf)) {
        $runningTarget = @(Get-TargetGodotProcesses)
        if ($runningTarget.Count -gt 0) {
            throw "SELF_CONTAINED_MARKER_MISSING_WHILE_EDITOR_RUNNING pids=$($runningTarget.ProcessId -join ',')"
        }
        New-Item -ItemType File -Force -Path $SelfContainedMarker | Out-Null
    }

    $version = Invoke-Capture $TargetGodotExe @('--version') $Project
    if ($version.exit_code -ne 0 -or -not $version.output.Trim().StartsWith('4.7.1.stable')) {
        throw "GODOT_VERSION_MISMATCH: $($version.output)"
    }
    return $version.output.Trim()
}

function Read-SecretTokenFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return '' }
    try {
        return ([IO.File]::ReadAllText($Path)).Trim()
    }
    catch {
        return ''
    }
}

function Set-HeraTokenEnvironment([string]$Token) {
    if ([string]::IsNullOrWhiteSpace($Token)) {
        Remove-Item Env:HERA_AGENT_GODOT_TOKEN -ErrorAction SilentlyContinue
        return
    }
    $env:HERA_AGENT_GODOT_TOKEN = $Token
}

function Ensure-HeraToken([bool]$EditorAlreadyRunning) {
    # A running Hera plugin reads its token only once at plugin start. Do not
    # overwrite the current shell's auth assumption here; exact-instance auth
    # is resolved later against known token sources without exposing secrets.
    if ($EditorAlreadyRunning) { return }

    $token = Read-SecretTokenFile $HeraTokenFile
    if ([string]::IsNullOrWhiteSpace($token)) {
        $bytes = New-Object byte[] 32
        $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
        try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
        $token = ([BitConverter]::ToString($bytes)).Replace('-', '').ToLowerInvariant()
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [IO.File]::WriteAllText($HeraTokenFile, $token, $utf8NoBom)
    }
    Set-HeraTokenEnvironment $token
}

function Resolve-HeraAuthForExactInstance([string]$HeraExe, [int]$InstancePid) {
    $candidates = @()

    $currentEnvToken = ''
    if (Test-Path Env:HERA_AGENT_GODOT_TOKEN) {
        $currentEnvToken = ([string]$env:HERA_AGENT_GODOT_TOKEN).Trim()
    }
    if (-not ([string]::IsNullOrWhiteSpace($currentEnvToken))) {
        $candidates += [pscustomobject]@{ source = 'inherited_env'; token = $currentEnvToken }
    }

    $projectToken = Read-SecretTokenFile $HeraTokenFile
    if (-not ([string]::IsNullOrWhiteSpace($projectToken)) -and
        -not (@($candidates | Where-Object { $_.token -eq $projectToken }).Count -gt 0)) {
        $candidates += [pscustomobject]@{ source = 'project_token'; token = $projectToken }
    }

    $sharedToken = Read-SecretTokenFile $HeraSharedTokenFile
    if (-not ([string]::IsNullOrWhiteSpace($sharedToken)) -and
        -not (@($candidates | Where-Object { $_.token -eq $sharedToken }).Count -gt 0)) {
        $candidates += [pscustomobject]@{ source = 'shared_token'; token = $sharedToken }
    }

    if ($candidates.Count -eq 0) {
        $candidates += [pscustomobject]@{ source = 'no_token'; token = '' }
    }

    $lastAuthOutput = ''
    foreach ($candidate in $candidates) {
        Set-HeraTokenEnvironment ([string]$candidate.token)
        $status = Invoke-Capture $HeraExe @('--instance', [string]$InstancePid, 'status') $Project
        if ($status.exit_code -eq 0) {
            Write-Host "HERA_AUTH_SOURCE=$($candidate.source)"
            return $status
        }
        if ($status.output -match '(?i)unauthorized|wrong.*token|missing.*token') {
            $lastAuthOutput = $status.output
            continue
        }
        throw "HERA_STATUS_FAILED_FOR_EXACT_PROJECT_INSTANCE: $($status.output)"
    }

    throw "HERA_AUTH_UNRESOLVED_CLOSE_TEN_PACES_EDITOR_AND_RERUN: $lastAuthOutput"
}

function Invoke-HeadlessEditorTool(
    [string]$ToolScriptText,
    [string]$ExpectedMarker,
    [bool]$IncludeGodotAiAddon = $false
) {
    $toolRoot = Join-Path $env:TEMP ("TenPacesEditorTool-" + [Guid]::NewGuid().ToString('N'))
    $projectFile = Join-Path $toolRoot 'project.godot'
    $scriptFile = Join-Path $toolRoot 'bootstrap.gd'
    $sceneFile = Join-Path $toolRoot 'bootstrap.tscn'
    $stdoutFile = Join-Path $toolRoot 'stdout.txt'
    $stderrFile = Join-Path $toolRoot 'stderr.txt'
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false

    $projectText = @'
[application]

config/name="Ten Paces Local Executor Tool"

[rendering]

renderer/rendering_method="gl_compatibility"
'@

    $sceneText = @'
[gd_scene load_steps=2 format=3]

[ext_resource path="res://bootstrap.gd" type="Script" id="1"]

[node name="TenPacesBootstrap" type="Node"]
script = ExtResource("1")
'@

    New-Item -ItemType Directory -Force -Path $toolRoot | Out-Null
    try {
        [IO.File]::WriteAllText($projectFile, $projectText, $utf8NoBom)
        [IO.File]::WriteAllText($scriptFile, $ToolScriptText, $utf8NoBom)
        [IO.File]::WriteAllText($sceneFile, $sceneText, $utf8NoBom)

        if ($IncludeGodotAiAddon) {
            if (-not (Test-Path -LiteralPath $GodotAiAddonSource -PathType Container)) {
                throw "GODOT_AI_ADDON_SOURCE_MISSING: $GodotAiAddonSource"
            }
            $addonsRoot = Join-Path $toolRoot 'addons'
            New-Item -ItemType Directory -Force -Path $addonsRoot | Out-Null
            # Exact project addon copy: keeps Codex config rendering owned by the
            # current project's Godot AI 3.1.4 source without mutating the project.
            Copy-Item -LiteralPath $GodotAiAddonSource -Destination $addonsRoot -Recurse -Force
        }

        # The bootstrap scene is responsible for quitting the temporary editor after
        # it prints its marker. Do not use a low iteration-count auto-exit here:
        # the copied Godot AI addon can spend those iterations in the initial
        # filesystem scan before the bootstrap scene is entered.
        $proc = Start-Process `
            -FilePath $TargetGodotExe `
            -ArgumentList @(
                '--editor',
                '--headless',
                '--path',
                $toolRoot,
                'res://bootstrap.tscn'
            ) `
            -WorkingDirectory $toolRoot `
            -RedirectStandardOutput $stdoutFile `
            -RedirectStandardError $stderrFile `
            -PassThru

        $completed = $proc.WaitForExit(120000)
        if (-not $completed) {
            # This is the exact temporary bootstrap process created above, never
            # an unrelated editor/server. Bound a broken tool script to 120s.
            try { $proc.Kill() } catch { }
            try { $proc.WaitForExit() } catch { }
            $stdout = ''
            $stderr = ''
            if (Test-Path -LiteralPath $stdoutFile -PathType Leaf) {
                $stdout = [IO.File]::ReadAllText($stdoutFile)
            }
            if (Test-Path -LiteralPath $stderrFile -PathType Leaf) {
                $stderr = [IO.File]::ReadAllText($stderrFile)
            }
            return [ordered]@{
                exit_code = 124
                output = ($stdout + "`n" + $stderr + "`nHEADLESS_EDITOR_TOOL_TIMEOUT_120S").TrimEnd()
                marker_found = $false
            }
        }
        $proc.Refresh()

        $stdout = ''
        $stderr = ''
        if (Test-Path -LiteralPath $stdoutFile -PathType Leaf) {
            $stdout = [IO.File]::ReadAllText($stdoutFile)
        }
        if (Test-Path -LiteralPath $stderrFile -PathType Leaf) {
            $stderr = [IO.File]::ReadAllText($stderrFile)
        }
        $combined = ($stdout + "`n" + $stderr).TrimEnd()
        $markerFound = $combined.Contains($ExpectedMarker)
        if ($proc.ExitCode -eq 0 -and $markerFound) {
            Write-Host "HEADLESS_EDITOR_TOOL_CONTEXT=PASS marker=$ExpectedMarker"
        }
        return [ordered]@{
            exit_code = [int]$proc.ExitCode
            output = $combined
            marker_found = $markerFound
        }
    }
    finally {
        if (Test-Path -LiteralPath $toolRoot -PathType Container) {
            Remove-Item -LiteralPath $toolRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Set-GodotAiEditorSettings {
    $seed = @'
@tool
extends Node

func _enter_tree() -> void:
    if not Engine.is_editor_hint():
        return
    var settings := EditorInterface.get_editor_settings()
    if settings == null:
        push_error("TEN_PACES_EDITOR_SETTINGS_UNAVAILABLE")
        get_tree().quit(2)
        return
    settings.set_setting("godot_ai/http_port", 8003)
    settings.set_setting("godot_ai/ws_port", 9503)
    settings.set_setting("godot_ai/keep_server_on_exit", false)
    print("TEN_PACES_EDITOR_SETTINGS=8003,9503,false")
    get_tree().quit(0)
'@

    $readback = @'
@tool
extends Node

func _enter_tree() -> void:
    if not Engine.is_editor_hint():
        return
    var settings := EditorInterface.get_editor_settings()
    if settings == null:
        push_error("TEN_PACES_EDITOR_SETTINGS_UNAVAILABLE")
        get_tree().quit(2)
        return
    if not settings.has_setting("godot_ai/http_port"):
        push_error("TEN_PACES_HTTP_PORT_SETTING_MISSING")
        get_tree().quit(3)
        return
    if not settings.has_setting("godot_ai/ws_port"):
        push_error("TEN_PACES_WS_PORT_SETTING_MISSING")
        get_tree().quit(3)
        return
    if not settings.has_setting("godot_ai/keep_server_on_exit"):
        push_error("TEN_PACES_KEEP_SERVER_SETTING_MISSING")
        get_tree().quit(3)
        return
    var http_port := int(settings.get_setting("godot_ai/http_port"))
    var ws_port := int(settings.get_setting("godot_ai/ws_port"))
    var keep_server := bool(settings.get_setting("godot_ai/keep_server_on_exit"))
    print("TEN_PACES_EDITOR_SETTINGS_READBACK=%d,%d,%s" % [http_port, ws_port, str(keep_server).to_lower()])
    get_tree().quit(0)
'@

    $seedResult = Invoke-HeadlessEditorTool $seed 'TEN_PACES_EDITOR_SETTINGS=8003,9503,false' $false
    if ($seedResult.exit_code -ne 0 -or -not $seedResult.marker_found) {
        throw "EDITOR_SETTINGS_SEED_FAILED: $($seedResult.output)"
    }

    $readResult = Invoke-HeadlessEditorTool $readback 'TEN_PACES_EDITOR_SETTINGS_READBACK=8003,9503,false' $false
    if ($readResult.exit_code -ne 0 -or -not $readResult.marker_found) {
        throw "EDITOR_SETTINGS_READBACK_FAILED: $($readResult.output)"
    }

    if (-not (Test-Path -LiteralPath $SelfContainedData -PathType Container)) {
        throw "SELF_CONTAINED_EDITOR_DATA_NOT_CREATED: $SelfContainedData"
    }
}

function Configure-CodexGodotAi {
    $scriptText = @'
@tool
extends Node

const Configurator = preload("res://addons/godot_ai/client_configurator.gd")

func _enter_tree() -> void:
    if not Engine.is_editor_hint():
        return
    Configurator.ensure_settings_registered()
    Configurator.warm_env_snapshot()
    var context := Configurator.capture_launch_context()
    var result := Configurator.configure("codex", "http://127.0.0.1:8003/mcp", context)
    print("TEN_PACES_CODEX_CONFIG=" + JSON.stringify(result))
    get_tree().quit(0)
'@

    $result = Invoke-HeadlessEditorTool $scriptText 'TEN_PACES_CODEX_CONFIG=' $true
    if ($result.exit_code -ne 0 -or -not $result.marker_found) {
        throw "CODEX_GODOT_AI_CONFIGURE_FAILED: $($result.output)"
    }
    if (-not ($result.output -match '"status"\s*:\s*"ok"')) {
        throw "CODEX_GODOT_AI_CONFIGURE_NOT_OK: $($result.output)"
    }
}

function Assert-CodexGodotAiConfigText {
    $configPath = Join-Path $CodexHome 'config.toml'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "CODEX_GODOT_AI_CONFIG_MISSING: $configPath"
    }
    $text = [IO.File]::ReadAllText($configPath)
    $header = [regex]::Match($text, '(?m)^\[mcp_servers\.(?:"godot-ai"|godot-ai|godot_ai)\]\s*$')
    if (-not $header.Success) {
        throw 'CODEX_GODOT_AI_SECTION_MISSING'
    }
    $tailStart = $header.Index + $header.Length
    $tail = $text.Substring($tailStart)
    $next = [regex]::Match($tail, '(?m)^\[')
    $endIndex = $(if ($next.Success) { $tailStart + $next.Index } else { $text.Length })
    $section = $text.Substring($header.Index, $endIndex - $header.Index)
    foreach ($token in @('command', 'args', 'attach', '--port', '8003', '--ws-port', '9503')) {
        if (-not $section.Contains($token)) {
            throw "CODEX_GODOT_AI_CONFIG_MISMATCH missing=$token"
        }
    }
    if ($section -match '(?m)^\s*url\s*=') {
        throw 'CODEX_GODOT_AI_CONFIG_LEGACY_URL_ENTRY'
    }
}

function Get-ExactHeraInstance([int]$EditorPid) {
    if (-not (Test-Path -LiteralPath $HeraInstances -PathType Container)) { return $null }
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $matches = @()
    foreach ($file in @(Get-ChildItem -LiteralPath $HeraInstances -Filter '*.json' -File -ErrorAction SilentlyContinue)) {
        try {
            $data = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            if ($null -eq $data) { continue }
            $path = Normalize-PathText ([string]$data.project_path)
            $instancePid = [int]$data.pid
            $port = [int]$data.port
            $ts = [int64]$data.ts
            if ($path -ne (Normalize-PathText $Project)) { continue }
            if ($instancePid -ne $EditorPid) { continue }
            if ($port -lt 8770 -or $port -gt 8785) { continue }
            if (($now - $ts) -gt 5 -or ($now - $ts) -lt -2) { continue }
            if ($null -eq (Get-Process -Id $instancePid -ErrorAction SilentlyContinue)) { continue }
            $owners = @(Get-ListenOwner $port)
            if ($owners.Count -ne 1 -or [int]$owners[0] -ne $instancePid) { continue }
            $matches += [ordered]@{ pid = $instancePid; port = $port; ts = $ts; project_path = [string]$data.project_path }
        }
        catch {
            continue
        }
    }
    if ($matches.Count -gt 1) {
        throw "HERA_MULTIPLE_EXACT_PROJECT_INSTANCES: $($matches.pid -join ',')"
    }
    if ($matches.Count -eq 1) { return $matches[0] }
    return $null
}

function Resolve-HeraCli {
    foreach ($name in @('hera', 'hera.exe')) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $cmd) { return $cmd.Source }
    }
    foreach ($candidate in @(
        (Join-Path $env:USERPROFILE 'Downloads\hera.exe'),
        (Join-Path $env:USERPROFILE 'Downloads\hera-windows-amd64\hera.exe'),
        (Join-Path $env:USERPROFILE 'Desktop\hera.exe'),
        (Join-Path $env:USERPROFILE 'Desktop\hera-windows-amd64\hera.exe'),
        (Join-Path $env:USERPROFILE '.local\bin\hera.exe')
    )) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return (Resolve-Path -LiteralPath $candidate).Path }
    }
    return $null
}

function Resolve-CodexCli {
    foreach ($name in @('codex.cmd', 'codex')) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($null -ne $cmd) { return $cmd.Source }
    }
    return $null
}

function Ensure-CodexLogin([string]$CodexExe) {
    $loginHelp = Invoke-Capture $CodexExe @('login', '--help') $Project
    if ($loginHelp.exit_code -ne 0 -or -not ($loginHelp.output -match '(?im)\bstatus\b')) {
        throw "CODEX_LOGIN_STATUS_UNSUPPORTED: $($loginHelp.output)"
    }

    $loginStatus = Invoke-Capture $CodexExe @('login', 'status') $Project
    if ($loginStatus.exit_code -eq 0) {
        Write-Host 'CODEX_LOGIN_READY'
        return
    }

    # Windows PowerShell 5.1 wraps native stderr in a NativeCommandError record,
    # so `codex login status` may render `codex.cmd : Not logged in` plus metadata.
    # Treat the semantic Codex status text as the signal; do not require a clean line.
    if (-not ($loginStatus.output -match '(?i)\bNot\s+logged\s+in\b')) {
        throw "CODEX_LOGIN_STATUS_FAILED: $($loginStatus.output)"
    }

    Write-Host 'CODEX_DEDICATED_HOME_LOGIN_REQUIRED'
    Write-Host 'Starting official Codex login for this project-specific CODEX_HOME...'
    $oldPreference = $ErrorActionPreference
    try {
        # Keep the interactive login attached to this console. Native stderr is
        # allowed to render without turning an informational/login message into
        # a terminating PowerShell error; the Codex process exit code is authoritative.
        $ErrorActionPreference = 'Continue'
        $global:LASTEXITCODE = 0
        & $CodexExe login
        $loginExit = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $oldPreference
    }
    if ($null -ne $loginExit -and $loginExit -ne 0) {
        throw "CODEX_LOGIN_FAILED: $loginExit"
    }

    $verified = Invoke-Capture $CodexExe @('login', 'status') $Project
    if ($verified.exit_code -ne 0) {
        throw "CODEX_LOGIN_NOT_READY_AFTER_LOGIN: $($verified.output)"
    }
    Write-Host 'CODEX_LOGIN_READY'
}

function Get-CodexLaunchArgs([string]$CodexExe) {
    $version = Invoke-Capture $CodexExe @('--version') $Project
    if ($version.exit_code -ne 0) { throw "CODEX_VERSION_FAILED: $($version.output)" }
    $help = Invoke-Capture $CodexExe @('--help') $Project
    if ($help.exit_code -ne 0) { throw "CODEX_HELP_FAILED: $($help.output)" }

    $sandboxFlag = $null
    if ($help.output -match '(?m)--sandbox\b') { $sandboxFlag = '--sandbox' }
    elseif ($help.output -match '(?m)(?:^|\s)-s(?:,|\s)') { $sandboxFlag = '-s' }

    $approvalFlag = $null
    if ($help.output -match '(?m)--ask-for-approval\b') { $approvalFlag = '--ask-for-approval' }
    elseif ($help.output -match '(?m)(?:^|\s)-a(?:,|\s)') { $approvalFlag = '-a' }

    if ($null -eq $sandboxFlag -or $null -eq $approvalFlag -or -not $help.output.Contains('workspace-write') -or -not ($help.output -match '(?i)\bnever\b')) {
        $excerpt = ($help.output -split "`r?`n" | Select-Object -First 24) -join "`n"
        throw "CODEX_REQUIRED_FLAGS_UNSUPPORTED version=$($version.output)`n$excerpt"
    }

    Ensure-CodexLogin $CodexExe

    $mcpHelp = Invoke-Capture $CodexExe @('mcp', 'list', '--help') $Project
    if ($mcpHelp.exit_code -ne 0) {
        throw "CODEX_MCP_LIST_UNSUPPORTED: $($mcpHelp.output)"
    }
    $mcpList = Invoke-Capture $CodexExe @('mcp', 'list') $Project
    if ($mcpList.exit_code -ne 0) {
        throw "CODEX_CONFIG_PARSE_OR_MCP_LIST_FAILED: $($mcpList.output)"
    }
    if (-not ($mcpList.output -match '(?i)godot[-_]ai')) {
        throw "CODEX_GODOT_AI_NOT_VISIBLE_TO_CLI: $($mcpList.output)"
    }

    Write-Host 'CODEX_HELP_PREFLIGHT_COMPLETE'
    return [ordered]@{
        version = $version.output.Trim()
        args = @($sandboxFlag, 'workspace-write', $approvalFlag, 'never')
    }
}

function Start-Codex([string]$CodexExe, [string[]]$LaunchArgs) {
    Write-Host 'BOOTSTRAP_READY_FOR_CODEX'
    Write-Host 'LIVE_READINESS_MUST_BE_RECHECKED_IN_CODEX'
    & $CodexExe @LaunchArgs
    $code = $LASTEXITCODE
    if ($null -ne $code -and $code -ne 0) {
        throw "CODEX_EXITED_NONZERO: $code"
    }
}

# -----------------------------------------------------------------------------
# Bounded one-shot flow
# -----------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath (Join-Path $Project 'project.godot') -PathType Leaf)) {
    throw "PROJECT_NOT_FOUND: $Project"
}
if ($null -eq (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'GIT_NOT_FOUND'
}
$inside = Invoke-Capture 'git' @('rev-parse', '--is-inside-work-tree') $Project
if ($inside.exit_code -ne 0 -or $inside.output.Trim() -ne 'true') {
    throw "WRONG_PROJECT_NOT_GIT_WORKTREE: $Project"
}
$remote = Invoke-Capture 'git' @('remote', 'get-url', 'origin') $Project
if ($remote.exit_code -ne 0) { throw 'PROJECT_ORIGIN_UNRESOLVED' }
$normalizedRemote = $remote.output.Trim().TrimEnd('/')
$expectedRemoteNoGit = $ExpectedRemote.Substring(0, $ExpectedRemote.Length - 4)
$expectedSshRemote = 'git@github.com:alsdmlals4-eng/Ten-Paces-Hidden-Moves.git'
if ($normalizedRemote -ne $ExpectedRemote -and $normalizedRemote -ne $expectedRemoteNoGit -and $normalizedRemote -ne $expectedSshRemote) {
    throw "WRONG_PROJECT_ORIGIN: $normalizedRemote"
}

$toolchain = Assert-ProjectToolchain
$godotVersion = Ensure-DedicatedGodot
$existingEditor = Get-ExactGodotProcess
$editorAlreadyRunning = ($null -ne $existingEditor)

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
$env:CODEX_HOME = $CodexHome
$null = Ensure-HeraToken $editorAlreadyRunning

if (-not $editorAlreadyRunning) {
    foreach ($port in @($HttpPort, $WsPort)) {
        $owners = @(Get-ListenOwner $port)
        if ($owners.Count -gt 0) {
            throw "FOREIGN_OR_AMBIGUOUS_PORT_OWNER port=$port pids=$($owners -join ',')"
        }
    }
    Set-GodotAiEditorSettings
    Configure-CodexGodotAi
    Assert-CodexGodotAiConfigText
    Start-Process -FilePath $TargetGodotExe -ArgumentList @('--path', $Project, '--editor') -WorkingDirectory $Project | Out-Null
}
else {
    try {
        Assert-CodexGodotAiConfigText
    }
    catch {
        throw "CODEX_CONFIG_INVALID_WHILE_EDITOR_RUNNING_CLOSE_TEN_PACES_EDITOR_AND_RERUN: $($_.Exception.Message)"
    }
}

$deadline = (Get-Date).AddSeconds(45)
$exactEditor = $null
$hera = $null
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 500
    $exactEditor = Get-ExactGodotProcess
    if ($null -eq $exactEditor) { continue }
    $httpOwners = @(Get-ListenOwner $HttpPort)
    $wsOwners = @(Get-ListenOwner $WsPort)
    if ($httpOwners.Count -ne 1 -or $wsOwners.Count -ne 1) { continue }
    try {
        Assert-HiGodotPortOwnership ([int]$exactEditor.ProcessId)
    }
    catch {
        throw
    }
    $hera = Get-ExactHeraInstance ([int]$exactEditor.ProcessId)
    if ($null -ne $hera) { break }
}

if ($null -eq $exactEditor) { throw 'TEN_PACES_DEDICATED_GODOT_NOT_READY_AFTER_45S' }
Assert-HiGodotPortOwnership ([int]$exactEditor.ProcessId)
if ($null -eq $hera) { throw 'HERA_EXACT_PROJECT_NOT_READY_AFTER_45S' }

$heraExe = Resolve-HeraCli
if ($null -eq $heraExe) { throw 'HERA_CLI_NOT_FOUND_EXPECTED_V1_0_0' }
$heraVersion = Invoke-Capture $heraExe @('version') $Project
if ($heraVersion.exit_code -ne 0 -or -not $heraVersion.output.Contains($ExpectedHeraVersion)) {
    throw "HERA_VERSION_MISMATCH_EXPECTED_V1_0_0: $($heraVersion.output)"
}
$heraHelp = Invoke-Capture $heraExe @('--help') $Project
if ($heraHelp.exit_code -ne 0 -or -not ($heraHelp.output -match '(?m)--instance')) {
    throw "HERA_INSTANCE_SELECTOR_UNSUPPORTED: $($heraHelp.output)"
}
$heraStatus = Resolve-HeraAuthForExactInstance $heraExe ([int]$hera.pid)
Write-Host "HERA_EXACT_PROJECT_READY pid=$($hera.pid) port=$($hera.port)"

Set-Location -LiteralPath $Project

$codexExe = Resolve-CodexCli
if ($null -eq $codexExe) { throw 'CODEX_CLI_NOT_FOUND' }
$codex = Get-CodexLaunchArgs $codexExe

Write-Host "PROJECT=$Project"
Write-Host "GODOT=$TargetGodotExe"
Write-Host "GODOT_VERSION=$godotVersion"
Write-Host "GODOT_AI_VERSION=$($toolchain.godot_ai)"
Write-Host "GUT_VERSION=$($toolchain.gut)"
Write-Host "HERA_ADDON_VERSION=$($toolchain.hera)"
Write-Host "HIGODOT_HTTP=$HttpPort"
Write-Host "HIGODOT_WS=$WsPort"
Write-Host "HERA_PID=$($hera.pid)"
Write-Host "HERA_PORT=$($hera.port)"
Write-Host "CODEX_HOME=$env:CODEX_HOME"
Write-Host "CODEX_VERSION=$($codex.version)"

Start-Codex -CodexExe $codexExe -LaunchArgs $codex.args
