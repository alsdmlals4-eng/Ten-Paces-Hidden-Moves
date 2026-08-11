# Ten Paces Local Executor Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build one idempotent PowerShell launcher that creates or reuses the isolated Ten Paces local execution environment, validates HiGodot/Godot AI on HTTP 8003 / WS 9503, discovers the exact-project Hera v1.0.0 instance, restores project-scoped CODEX_HOME for every new shell, and launches Codex in the exact project root.

**Architecture:** `tools/start_ten_paces_local_executor.ps1` is the single executable source of truth. It performs only bounded wrong-target preflight before Codex, uses Godot self-contained `_sc_` isolation, seeds Godot AI EditorSettings through a temporary recovery-mode Godot script rather than editing `editor_settings-4.tres` by text, discovers Hera from its project heartbeat instead of assuming port 8770, and fails closed on ambiguous/foreign HiGodot ports without killing processes. Python contract tests statically enforce the safety/identity contract; a PowerShell parser test catches syntax errors; real Windows/Godot/HiGodot/Hera readiness remains a user-local evidence step.

**Tech Stack:** Windows PowerShell 5.1-compatible PowerShell, Godot 4.7.1 stable editor, Godot AI/HiGodot 3.1.4, Hera Agent Godot/CLI v1.0.0, Codex CLI, Python `unittest`, existing `tools/collect_godot_live_evidence.ps1` for post-bootstrap evidence only.

## Global Constraints

- Decision ID: `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`.
- Exact project root: `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves`.
- Exact dedicated Godot root: `C:\Users\user\Tools\Godot-Ten-Paces-4.7.1`.
- Exact dedicated Godot executable: `C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\Godot_v4.7.1-stable_win64.exe`.
- Self-contained marker: `C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\_sc_`.
- HiGodot/Godot AI ports: HTTP `8003`, WS `9503`; never auto-change them.
- Hera is active tooling, not blanket-prohibited. Hera v1.0.0 binds dynamically in `8770..8785`; select it by fresh exact-project heartbeat/PID, not by a hard-coded port.
- Project Codex home: `C:\Users\user\.codex-ten-paces`; set `$env:CODEX_HOME` on every invocation before Codex configuration/launch.
- Desired Codex policy: `workspace-write` sandbox and `never` approval; verify the installed CLI's current help before using its flag form.
- Assume every previous PowerShell window was closed. No shell-scoped state may be reused implicitly.
- `BOOTSTRAP_MINIMUM_PREFLIGHT_ONLY`: no broad diff/repository dump before Codex.
- Do not `git reset`, `git restore`, `git clean`, stage, rewrite, or discard user work.
- Do not kill/restart unrelated Godot, HiGodot/Godot-AI, Hera, or Codex processes.
- Bootstrap process/port presence is not live readiness proof. Fresh HiGodot + Hera project/session/readiness is required before persistent mutation.
- Bootstrap must not modify `src/`, `scenes/`, `data/`, `assets/`, or `project.godot`.
- Existing `tools/collect_godot_live_evidence.ps1` is post-bootstrap evidence tooling only; do not invoke its broad collector before Codex merely to open the session.

---

### Task 1: RED Bootstrap Contract

**Files:**
- Create: `tests/test_local_executor_bootstrap_contract.py`
- Future implementation target: `tools/start_ten_paces_local_executor.ps1`

**Interfaces:**
- Consumes: approved design `docs/superpowers/specs/2026-08-11-local-executor-bootstrap-design.md`.
- Produces: a deterministic contract that fails until the launcher exists with the required project/port/Hera/Codex/safety tokens.

- [ ] **Step 1: Write the failing test**

Create `tests/test_local_executor_bootstrap_contract.py` with the following contract shape:

```python
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "start_ten_paces_local_executor.ps1"


class LocalExecutorBootstrapContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.assertTrue(SCRIPT.exists(), f"missing launcher: {SCRIPT}")
        self.text = SCRIPT.read_text(encoding="utf-8")

    def test_exact_ten_paces_binding(self) -> None:
        required = (
            r"C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves",
            r"C:\Users\user\Tools\Godot-Ten-Paces-4.7.1",
            "Godot_v4.7.1-stable_win64.exe",
            "8003",
            "9503",
            r"C:\Users\user\.codex-ten-paces",
            "CODEX_HOME",
        )
        for token in required:
            self.assertIn(token, self.text)

    def test_self_contained_and_editor_settings_are_programmatic(self) -> None:
        self.assertIn("_sc_", self.text)
        self.assertIn("--recovery-mode", self.text)
        self.assertIn("EditorInterface.get_editor_settings()", self.text)
        self.assertIn('godot_ai/http_port', self.text)
        self.assertIn('godot_ai/ws_port', self.text)
        self.assertIn('godot_ai/keep_server_on_exit', self.text)
        self.assertNotIn("editor_settings-4.tres' -replace", self.text)
        self.assertNotIn('editor_settings-4.tres\" -replace', self.text)

    def test_hera_is_exact_project_dynamic_port_tooling(self) -> None:
        for token in (
            ".hera-agent-godot",
            "instances",
            "project_path",
            "8770",
            "8785",
            "HERA_AGENT_GODOT_TOKEN",
            "hera",
            "status",
        ):
            self.assertIn(token, self.text)
        self.assertNotRegex(self.text, r"(?i)Hera.*FORBIDDEN")

    def test_ports_fail_closed_without_process_kill_or_auto_switch(self) -> None:
        self.assertIn("FOREIGN_OR_AMBIGUOUS_PORT_OWNER", self.text)
        self.assertIn("8003", self.text)
        self.assertIn("9503", self.text)
        forbidden = (
            r"Stop-Process\s+.*-Force",
            r"taskkill\b",
            r"Get-NetTCPConnection[^\n]+\|\s*Stop-Process",
            r"git\s+reset\b",
            r"git\s+restore\b",
            r"git\s+clean\b",
        )
        for pattern in forbidden:
            self.assertIsNone(re.search(pattern, self.text, re.IGNORECASE))

    def test_codex_help_preflight_precedes_launch(self) -> None:
        help_pos = self.text.find("--help")
        launch_pos = self.text.find("Start-Codex")
        self.assertGreaterEqual(help_pos, 0)
        self.assertGreater(launch_pos, help_pos)
        self.assertIn("workspace-write", self.text)
        self.assertIn("never", self.text)

    def test_bootstrap_distinguishes_launch_from_readiness(self) -> None:
        self.assertIn("BOOTSTRAP_READY_FOR_CODEX", self.text)
        self.assertIn("LIVE_READINESS_MUST_BE_RECHECKED_IN_CODEX", self.text)
        self.assertIn("HERA_EXACT_PROJECT_READY", self.text)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run RED**

Run:

```bash
python -m unittest tests.test_local_executor_bootstrap_contract -v
```

Expected: FAIL because `tools/start_ten_paces_local_executor.ps1` does not exist yet.

- [ ] **Step 3: Commit RED**

```bash
git add tests/test_local_executor_bootstrap_contract.py
git commit -m "test: require Ten Paces local executor bootstrap"
```

---

### Task 2: Implement the One-Shot PowerShell Launcher

**Files:**
- Create: `tools/start_ten_paces_local_executor.ps1`
- Test: `tests/test_local_executor_bootstrap_contract.py`

**Interfaces:**
- Produces PowerShell functions: `Invoke-Capture`, `Get-ListenOwner`, `Get-ExactGodotProcess`, `Resolve-GodotSource`, `Ensure-DedicatedGodot`, `Ensure-HeraToken`, `Set-GodotAiEditorSettings`, `Get-ExactHeraInstance`, `Resolve-HeraCli`, `Resolve-CodexCli`, `Start-Codex`.
- Exit behavior: nonzero/throw before Codex on wrong project, missing exact Godot source, self-contained failure, foreign/ambiguous 8003/9503, missing Hera v1 CLI/readiness, missing Codex, or unsupported Codex flag contract.

- [ ] **Step 1: Add exact constants and bounded native-command capture**

The launcher starts with Windows PowerShell 5.1-compatible constants and a native command helper. The exact values must be literal and must not come from previous-shell environment state:

```powershell
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Project = 'C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves'
$ExpectedRemote = 'https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves.git'
$TargetGodot = 'C:\Users\user\Tools\Godot-Ten-Paces-4.7.1'
$GodotExeName = 'Godot_v4.7.1-stable_win64.exe'
$GodotConsoleName = 'Godot_v4.7.1-stable_win64_console.exe'
$TargetGodotExe = Join-Path $TargetGodot $GodotExeName
$SelfContainedMarker = Join-Path $TargetGodot '_sc_'
$SelfContainedData = Join-Path $TargetGodot 'editor_data'
$HttpPort = 8003
$WsPort = 9503
$CodexHome = 'C:\Users\user\.codex-ten-paces'
$HeraHome = Join-Path $env:USERPROFILE '.hera-agent-godot'
$HeraInstances = Join-Path $HeraHome 'instances'
$HeraTokenFile = Join-Path $HeraHome 'token'

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
    finally {
        $ErrorActionPreference = $oldPreference
        Set-Location -LiteralPath $old.Path
    }
}
```

- [ ] **Step 2: Implement minimum exact-project identity check**

Validate only `project.godot`, Git worktree identity, and origin URL before startup. Do not front-load diff/status dumps.

```powershell
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
if ($normalizedRemote -ne $ExpectedRemote -and $normalizedRemote -ne $expectedRemoteNoGit) {
    throw "WRONG_PROJECT_ORIGIN: $normalizedRemote"
}
```

- [ ] **Step 3: Implement exact Godot 4.7.1 source resolution and isolated install**

`Resolve-GodotSource` searches only exact filenames in approved local locations and exact ZIP names under Downloads. It must not silently accept a different version. `Ensure-DedicatedGodot` copies/extracts only when the dedicated binary is absent, creates `_sc_`, then runs `--version` and requires a `4.7.1.stable` prefix.

Approved source candidates:

```text
$env:USERPROFILE\Downloads\Godot_v4.7.1-stable_win64.exe
$env:USERPROFILE\Downloads\**\Godot_v4.7.1-stable_win64.exe
$env:USERPROFILE\Downloads\Godot_v4.7.1-stable_win64.exe.zip
$env:USERPROFILE\Downloads\**\Godot_v4.7.1-stable_win64.exe.zip
```

When extracting a ZIP, expand to a temporary directory, locate the exact GUI and optional console executable by filename, copy them into `$TargetGodot`, then remove only that temporary extraction directory. Never modify/delete the source installation/archive.

After installation:

```powershell
New-Item -ItemType File -Force -Path $SelfContainedMarker | Out-Null
$version = Invoke-Capture $TargetGodotExe @('--version') $Project
if ($version.exit_code -ne 0 -or -not $version.output.StartsWith('4.7.1.stable')) {
    throw "GODOT_VERSION_MISMATCH: $($version.output)"
}
```

If the target executable is already running and `_sc_` is missing, fail with `SELF_CONTAINED_MARKER_MISSING_WHILE_EDITOR_RUNNING` rather than changing isolation underneath a live editor.

- [ ] **Step 4: Seed Godot AI ports through Godot EditorSettings, not text rewriting**

When the exact Ten Paces dedicated editor is not running, create a temporary GDScript outside the repository. Run the dedicated editor in `--editor --headless --recovery-mode` so editor plugins are disabled while settings are seeded:

```gdscript
extends SceneTree

func _init() -> void:
    var settings := EditorInterface.get_editor_settings()
    if settings == null:
        push_error("TEN_PACES_EDITOR_SETTINGS_UNAVAILABLE")
        quit(2)
        return
    settings.set_setting("godot_ai/http_port", 8003)
    settings.set_setting("godot_ai/ws_port", 9503)
    settings.set_setting("godot_ai/keep_server_on_exit", false)
    print("TEN_PACES_EDITOR_SETTINGS=8003,9503,false")
    quit(0)
```

Invoke:

```powershell
$r = Invoke-Capture $TargetGodotExe @(
    '--editor', '--headless', '--recovery-mode', '--path', $Project,
    '--script', $settingsScript
) $Project
```

Then run a second temporary readback GDScript in a new recovery-mode editor process which prints the three values from `EditorInterface.get_editor_settings()`. Require exact `8003,9503,false`. This cross-process readback is the persistence check. Verify `$SelfContainedData` exists. Delete only the temporary GDScript files after both runs.

- [ ] **Step 5: Implement fail-closed 8003/9503 handling and exact editor reuse**

`Get-ExactGodotProcess` must use `Get-CimInstance Win32_Process` and require both:

```text
ExecutablePath == $TargetGodotExe
CommandLine contains --path and the exact Ten Paces project path
```

`Get-ListenOwner` returns PID(s) listening on a required port using `Get-NetTCPConnection`; if unavailable, fall back to parsing `netstat -ano` without killing anything.

Rules:

```text
exact editor exists + expected ports listening
    → reuse candidate; continue to Hera/live checks
no exact editor + both ports free
    → safe to start dedicated editor
no exact editor + either required port occupied
    → throw FOREIGN_OR_AMBIGUOUS_PORT_OWNER with port/PID
exact editor exists + one/both expected ports missing after bounded wait
    → throw HIGODOT_EXPECTED_PORT_NOT_READY
```

Never choose 8004/9504 or any fallback port.

- [ ] **Step 6: Establish Hera token before fresh editor startup and discover Hera by heartbeat**

`Ensure-HeraToken`:

- create `$HeraHome` if missing;
- preserve any existing non-empty token file;
- if missing/empty, create one using `RandomNumberGenerator` with 32 random bytes rendered as lowercase hex;
- never print the token;
- set `$env:HERA_AGENT_GODOT_TOKEN` to the token before launching a new Godot editor.

`Get-ExactHeraInstance` scans `$HeraInstances\*.json`, parses JSON, and accepts only an entry where:

```text
project_path normalized == exact $Project
PID exists
heartbeat ts age <= 5 seconds
port >= 8770 and port <= 8785
```

The function must return PID + actual Hera port. It must not assume that Ten Paces owns 8770.

- [ ] **Step 7: Start or reuse the dedicated Godot and wait for both HiGodot and Hera**

For a fresh editor:

```powershell
Start-Process -FilePath $TargetGodotExe -ArgumentList @('--path', $Project, '--editor') -WorkingDirectory $Project | Out-Null
```

Poll for at most 45 seconds for:

- exact dedicated Ten Paces Godot process;
- HTTP 8003 listener;
- WS 9503 listener;
- fresh exact-project Hera heartbeat in 8770..8785.

Do not kill anything on timeout. Report one actionable blocker.

- [ ] **Step 8: Resolve and verify Hera CLI v1.0.0, then status the exact instance**

`Resolve-HeraCli` checks `Get-Command hera`, `hera.exe`, then exact common local filenames under Downloads/Desktop. Require `hera version` output to identify `v1.0.0` before using it.

Use the heartbeat PID with the stable v1 global instance selector:

```powershell
$heraStatus = Invoke-Capture $heraExe @('--instance', [string]$hera.pid, 'status') $Project
if ($heraStatus.exit_code -ne 0) {
    throw "HERA_STATUS_FAILED_FOR_EXACT_PROJECT_INSTANCE: $($heraStatus.output)"
}
Write-Host "HERA_EXACT_PROJECT_READY pid=$($hera.pid) port=$($hera.port)"
```

Never print the Hera token. If the installed CLI help does not expose `--instance`, stop and show the CLI version/help summary instead of guessing a different selector.

- [ ] **Step 9: Recreate CODEX_HOME every run and minimally verify Codex CLI flags**

```powershell
New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
$env:CODEX_HOME = $CodexHome
Set-Location -LiteralPath $Project
```

Resolve `codex.cmd` first, then `codex`. Capture `--version` and `--help`. Require current help to expose a sandbox flag supporting `workspace-write` and an approval flag supporting `never`. Prefer long-form flags when exposed:

```text
--sandbox workspace-write
--ask-for-approval never
```

If the installed build exposes only an equivalent short form, derive it from current help. If neither contract is exposed, throw `CODEX_REQUIRED_FLAGS_UNSUPPORTED` and include version + a short help excerpt. Do not guess a deprecated flag.

- [ ] **Step 10: Implement `Start-Codex` and final bootstrap marker**

`Start-Codex` launches interactively in the current exact project PowerShell so Codex inherits both `CODEX_HOME` and `HERA_AGENT_GODOT_TOKEN`:

```powershell
function Start-Codex([string]$CodexExe, [string[]]$LaunchArgs) {
    Write-Host 'BOOTSTRAP_READY_FOR_CODEX'
    Write-Host 'LIVE_READINESS_MUST_BE_RECHECKED_IN_CODEX'
    & $CodexExe @LaunchArgs
    $code = $LASTEXITCODE
    if ($null -ne $code -and $code -ne 0) {
        throw "CODEX_EXITED_NONZERO: $code"
    }
}
```

The launcher output before Codex should be compact: project root, dedicated Godot path/version, HiGodot ports, Hera PID/actual dynamic port, CODEX_HOME, Codex version, and the two readiness markers. Do not dump secrets or broad Git state.

- [ ] **Step 11: Run GREEN contract**

```bash
python -m unittest tests.test_local_executor_bootstrap_contract -v
```

Expected: PASS.

- [ ] **Step 12: Parse PowerShell syntax in CI-capable PowerShell**

When `pwsh` is available:

```powershell
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  (Resolve-Path 'tools/start_ten_paces_local_executor.ps1'),
  [ref]$null,
  [ref]$errors
) | Out-Null
if ($errors.Count -gt 0) { $errors | Format-List | Out-String | Write-Error; exit 1 }
```

Expected: no parser errors. This is syntax evidence only; it does not claim Windows/Godot/Hera readiness.

- [ ] **Step 13: Commit GREEN**

```bash
git add tools/start_ten_paces_local_executor.ps1 tests/test_local_executor_bootstrap_contract.py
git commit -m "tools: add isolated Ten Paces local executor bootstrap"
```

---

### Task 3: Adversarial Review and Regression Gate

**Files:**
- Review: `tools/start_ten_paces_local_executor.ps1`
- Review: `tests/test_local_executor_bootstrap_contract.py`
- Review: `tools/collect_godot_live_evidence.ps1`
- Review: `addons/godot_ai/client_configurator.gd`
- Review: `addons/godot_ai/clients/codex.gd`
- Review: `addons/hera_agent_godot/server/http_server.gd`
- Review: `addons/hera_agent_godot/server/heartbeat.gd`
- Review: `addons/hera_agent_godot/plugin.cfg`

**Interfaces:**
- Produces: adversarial disposition with P0/P1 findings resolved before the launcher is handed to the user.

- [ ] **Step 1: Attack wrong-target and collision cases**

Review concrete counterexamples:

```text
project.godot missing
origin points at another repo
another Godot project owns 8003
another Godot project owns 9503
Ten Paces dedicated editor is running but command line points at another worktree
Hera 8770 belongs to another project while Ten Paces Hera uses 8772
stale Hera heartbeat file exists for Ten Paces
Hera token file is missing/empty
Codex HOME exists with user settings
codex CLI changes flag spellings
PowerShell was closed since the prior run
```

For every case, verify the launcher either safely re-establishes state or fails before Codex with no unrelated process termination.

- [ ] **Step 2: Attack destructive/noisy behavior**

Search the launcher for:

```text
Stop-Process
taskkill
git reset
git restore
git clean
git add
git diff (broad preflight)
Get-ChildItem across the whole repository
printing token/config secret values
```

Any destructive or unnecessary broad-preflight occurrence is P1 and must be removed unless it is demonstrably limited to launcher-created temporary files.

- [ ] **Step 3: Re-run focused tests**

```bash
python -m unittest tests.test_local_executor_bootstrap_contract -v
python -m unittest tests.test_local_godot_evidence_collector_contract -v
python -m unittest tests.test_active_godot_toolchain_reconciliation -v
```

Expected: all PASS.

- [ ] **Step 4: Review untouched consumers**

Confirm the launcher does not alter product paths and remains consistent with current source contracts:

```text
Godot AI EditorSettings keys: godot_ai/http_port, godot_ai/ws_port, godot_ai/keep_server_on_exit
Codex client config home environment: CODEX_HOME
Hera localhost port behavior: first free 8770..8785
Hera heartbeat identity: pid, port, project_path, godot_version, scene, ts
Hera addon version: 1.0.0
```

- [ ] **Step 5: Record review result**

No launcher handoff until P0=0 and P1=0. Remaining real-local unknowns must be explicitly `NOT_RUN`, not PASS.

---

### Task 4: User-Local First Run and Repeat-Run Evidence

**Files:**
- Execute source: `tools/start_ten_paces_local_executor.ps1`
- Post-bootstrap evidence helper: `tools/collect_godot_live_evidence.ps1`
- Decision/sheet closeout only after real evidence: `docs/decisions/2026-08-11_LOCAL_EXECUTOR_BOOTSTRAP_DECISION.md`, Google Sheet `02_현재_확정결정` row for the same Decision ID.

**Interfaces:**
- Produces: first real Windows evidence for isolated Godot 4.7.1 + HiGodot 3.1.4 8003/9503 + exact-project Hera v1.0.0 + project-scoped Codex launch.

- [ ] **Step 1: Hand the user one copy/paste block**

The chat response must contain the full current contents of `tools/start_ten_paces_local_executor.ps1` in one PowerShell code block. The user should not need to run a separate setup block first.

- [ ] **Step 2: First-run observation**

Success requires the launcher to reach Codex and display compact bootstrap facts. This proves only startup orchestration.

Inside Codex, fresh-read:

```text
exact project/worktree
Godot project/session identity
Godot AI/HiGodot version 3.1.4
HTTP 8003 / WS 9503
Hera exact-project status/instance/version
live HiGodot + Hera readiness
```

Only then may persistent product implementation begin.

- [ ] **Step 3: Post-bootstrap live evidence**

After the environment is live, use the existing bounded project evidence tooling as appropriate. Do not treat prior 3.1.3 acceptance as 3.1.4 acceptance.

- [ ] **Step 4: Close PowerShell and repeat**

Explicitly close the PowerShell/Codex session, then paste the same block into a brand-new PowerShell window. Verify:

```text
CODEX_HOME is recreated
same dedicated Godot is reused or correctly started
8003/9503 are not auto-changed
exact-project Hera is rediscovered even if its dynamic port differs
no unrelated process is killed
Codex starts from exact Ten Paces root
```

- [ ] **Step 5: Adversarial post-run review**

Compare observed PID/port/project/config/session evidence against the spec. If any ownership is ambiguous, keep the gate open and fix the launcher before game BUILD.

- [ ] **Step 6: Same-Decision-ID closeout**

When real local evidence passes, update the Decision and Google Sheet with the same `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`, exact implementation commit, exact evidence level, and remaining `NOT_RUN` items. Do not claim device/human/export/product evidence that was not run.
