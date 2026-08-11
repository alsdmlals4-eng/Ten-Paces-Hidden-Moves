# TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01

## Status

`USER_APPROVED / WINDOWS_BOOTSTRAP_TO_CODEX_SESSION_PASS / IN_CODEX_FRESH_READINESS_PENDING / REPEAT_RUN_PENDING`

## Decision

Every local PowerShell implementation/review session for Ten Paces establishes the dedicated local execution environment before product BUILD work:

```text
dedicated Godot 4.7.1 self-contained
→ HiGodot/Godot AI HTTP 8003 / WS 9503
→ Hera v1.0.0 exact-project live instance
→ session-scoped CODEX_HOME=C:\Users\user\.codex-ten-paces
→ Codex from the exact Ten Paces project root
→ fresh HiGodot + Hera readiness receipt before persistent implementation
```

Every launcher invocation assumes the previous PowerShell was closed. It recreates shell-scoped state, creates the dedicated environment when absent, fails closed on foreign/ambiguous 8003/9503 ownership, does not kill unrelated processes, does not silently switch ports, and keeps Hera as active tooling rather than blanket-prohibiting it.

## Concrete Binding

```yaml
project_root: C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves
dedicated_godot_root: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1
dedicated_godot_exe: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\Godot_v4.7.1-stable_win64.exe
self_contained_marker: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\_sc_
higodot_http_port: 8003
higodot_ws_port: 9503
hera_version: 1.0.0
hera_bind_host: 127.0.0.1
hera_port_range: 8770-8785
hera_instance_discovery: C:\Users\user\.hera-agent-godot\instances\<pid>.json
hera_project_token_file: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\.hera-token
hera_shared_token_file: C:\Users\user\.hera-agent-godot\token
codex_home: C:\Users\user\.codex-ten-paces
codex_sandbox: workspace-write
codex_approval: never
project_launcher: tools/start_ten_paces_local_executor.ps1
```

## Corrected Editor-Context Mechanism

Observed Windows/Godot 4.7.1 evidence supersedes the original `--recovery-mode + --script` editor-context mechanism. The working mechanism is a temporary `%TEMP%` Godot project whose root scene carries an `@tool` script, launched as a headless editor. The script self-terminates with `SceneTree.quit()` after EditorSettings or Godot-AI Codex configuration work. No bootstrap files are placed in the product repository.

Observed probe:

```text
EXIT_CODE=0
TOOL_PROBE_ENTER_TREE=PASS
ENGINE_EDITOR_HINT=true
EDITOR_SETTINGS=AVAILABLE
HEADLESS_EDITOR_TOOL_CONTEXT=PASS
```

The failed standalone `--script` path is historical debugging evidence only and is not a current execution instruction.

## Windows Runtime Evidence — 2026-08-12 KST

Earlier v3 evidence established the dedicated Godot/Godot-AI/Hera path. Subsequent v4/v5 runs repaired Codex login and reused-editor Hera authentication without weakening the exact-project boundary.

Latest observed v5 checkpoint:

```yaml
launcher_v5_sha256: db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c
windows_powershell_download_hash: PASS
windows_powershell_install_hash: PASS
windows_powershell_parser: PASS
godot: 4.7.1.stable.official.a13da4feb
higodot_godot_ai: 3.1.4
higodot_http: 8003
higodot_ws: 9503
hera_auth_source_observed: shared_token
hera_exact_project: PASS
hera_pid_observed_historical: 29804
hera_port_observed_historical: 8773
hera_token_raw_value_saved_to_evidence: false
codex_dedicated_home_login: PASS_TO_INTERACTIVE_SESSION
codex_cli_observed: 0.147.0
codex_exact_project_directory: PASS
codex_sandbox_ready: PASS
in_codex_fresh_readiness: NOT_RUN
fresh_powershell_repeat_run: NOT_RUN
```

The observed PID and dynamic Hera port are historical evidence only. They must never be reused as current runtime authority in a later session.

## Recovery Lessons Incorporated in v5

### Editor context

Standalone `--script` did not execute the required editor context. Current code uses a real headless editor plus `@tool` scene and self-termination.

### Windows native stderr

Windows PowerShell 5.1 can wrap native stderr in a `NativeCommandError` record even when the text represents a normal semantic state. Codex login therefore classifies process exit status and semantic `Not logged in` content rather than treating the wrapper itself as the root failure.

### Reused Hera editor authentication

Hera reads its token at plugin start. A fresh shell reusing that editor may not share the same first auth assumption. v5 first selects the exact-project heartbeat/PID and then tries only supported auth sources against that exact instance:

```text
current process env token
→ dedicated Ten Paces .hera-token
→ Hera shared ~/.hera-agent-godot/token
→ no-token only when no token candidates exist
```

Only the source label may enter evidence; secret token values do not.

## Repository Persistence

The v5 launcher is now project-owned at `tools/start_ten_paces_local_executor.ps1` and protected by `tests/test_local_executor_bootstrap_contract.py`. Local live readiness is routed through the existing `ten-paces-verification` owner via `local-executor-readiness`; no duplicate broad Skill is created.

## Authority Snapshot

- Project default branch at this closeout baseline: `main@b9a9db62f4fd860131561a11d2ddebf3d496f39a`.
- Project open PR #162 remains read-only/reference for this goal; its Phase-B prose is stale relative to later user instructions and its changed files do not overlap the local-executor closeout.
- Base must always be freshly refetched because other project/BCP work may run concurrently.
- Same Decision ID is tracked in the project Google Sheet.

## Safety / Evidence Boundary

Bootstrap orchestration and a Codex window do not themselves prove live authoring readiness. Persistent product mutation must not be justified by this Decision until the in-Codex exact-project readiness gate is actually run and passes. No destructive Git cleanup, unrelated process termination, automatic port fallback, or token disclosure is authorized by this bootstrap.

## Current Handoff Gate

The user explicitly paused local readiness work to perform handoff/BCP closeout. Therefore the remaining local gates are persisted rather than fabricated as PASS:

```text
IN_CODEX_FRESH_READINESS_GATE
→ PROJECT_IDENTITY + CODEX_HOME
→ exact dedicated Godot
→ Godot AI 3.1.4 / HTTP 8003 / WS 9503
→ smallest read-only GODOT_AI_MCP_LIVE call
→ Hera v1.0.0 exact-project authenticated read-only status
→ GUT 9.7.1
→ REPO_NO_NEW_MUTATION
→ OVERALL PASS

then

FRESH_POWERSHELL_REPEAT_RUN_GATE
```

Only after both gates are observed may a later session promote this local-executor contract beyond the current checkpoint.
