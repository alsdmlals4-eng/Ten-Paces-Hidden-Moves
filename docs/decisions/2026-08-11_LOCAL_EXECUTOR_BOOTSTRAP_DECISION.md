# TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01

## Status

`USER_APPROVED / WINDOWS_RUNTIME_PARTIAL_PASS / HERA_AUTH_RECOVERY_V5_PENDING / CODEX_DEDICATED_HOME_LOGIN_PENDING`

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
```

## Corrected Editor-Context Mechanism

Observed Windows/Godot 4.7.1 evidence supersedes the original `--recovery-mode + --script` implementation-plan mechanism. The working mechanism is a temporary `%TEMP%` Godot project whose root scene carries an `@tool` script, launched as a headless editor. The script self-terminates with `SceneTree.quit()` after EditorSettings or Godot-AI Codex configuration work. No bootstrap files are placed in the product repository.

Observed probe:

```text
EXIT_CODE=0
TOOL_PROBE_ENTER_TREE=PASS
ENGINE_EDITOR_HINT=true
EDITOR_SETTINGS=AVAILABLE
HEADLESS_EDITOR_TOOL_CONTEXT=PASS
```

## Windows Runtime Evidence — 2026-08-12 KST

v3 reached the persistent dedicated environment and established:

```yaml
windows_powershell_parser: PASS
godot: 4.7.1.stable.official.a13da4feb
godot_self_contained_editor: STARTED
higodot_godot_ai: 3.1.4
higodot_http: 8003
higodot_ws: 9503
higodot_server_pid_observed: 21664
hera_exact_project: PASS
hera_pid_observed: 27640
hera_port_observed: 8772
hera_token_raw_value_saved_to_evidence: false
codex_dedicated_home_login: NOT_LOGGED_IN
codex_launch: NOT_REACHED
```

v4 fixed the Windows PowerShell 5.1 `codex.cmd : Not logged in` wrapper by treating semantic `Not logged in` as the expected first-use authentication branch. On the next fresh-shell run v4 then failed earlier at Hera authentication while reusing the already-running exact Ten Paces editor:

```text
HERA_AUTH_MISMATCH_CLOSE_TEN_PACES_EDITOR_AND_RERUN
status: unauthorized: missing or wrong X-Hera-Token
```

This is not a port/project-identity failure. Hera's addon and CLI resolve authentication identically: non-empty `HERA_AGENT_GODOT_TOKEN` first, then `~/.hera-agent-godot/token`; the addon reads the token once at plugin start while the CLI re-reads on each invocation. Therefore a reused long-lived editor may legitimately retain a different supported token source from a later fresh PowerShell's first assumption.

## v5 Candidate

v5 keeps the project token for a newly launched Ten Paces editor, but when reusing an exact already-running editor it no longer assumes one auth source. After exact-project heartbeat/PID selection it probes known sources against that exact instance only, without printing secret values:

```text
current process env token
→ dedicated Ten Paces .hera-token
→ Hera shared ~/.hera-agent-godot/token
→ no-token only when no token candidates exist
```

The first successful candidate becomes the current shell's `HERA_AGENT_GODOT_TOKEN`. Unauthorized candidates are skipped; non-auth Hera failures stop immediately; if no known token source authenticates, the launcher fails closed and asks for the exact Ten Paces editor to be closed/restarted. No token value is written to evidence.

```yaml
launcher_v5_sha256: db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c
v5_targeted_red: 3/3 FAIL against v4 as expected
v5_targeted_green: 3/3 PASS
v5_static_adversarial_checks: 25/25 PASS
v5_windows_parser: NOT_RUN
v5_windows_runtime: NOT_RUN
```

## Authority Snapshot

- Base default branch: `main`; fresh latest commit: `1d6cc79ae95ffb67ba4de618f010a6540fc6e02c`.
- Base open PRs: 0 at this refresh.
- Project default branch: `main`; current main: `b9a9db62f4fd860131561a11d2ddebf3d496f39a`.
- Project open PR: draft #162, whose Phase-B blocking prose is stale relative to the user's later explicit Plan-C implementation authorization.
- Same Decision ID is tracked in the project Google Sheet.

## Safety / Evidence Boundary

Bootstrap orchestration does not itself prove live authoring readiness and does not authorize unrelated product changes, destructive Git cleanup, unrelated process termination, automatic port fallback, or token disclosure. Fresh exact-project HiGodot + Hera readiness remains required before persistent product mutation.

## Current Conflict Note

`docs/superpowers/plans/2026-08-11-local-executor-bootstrap.md` still contains the superseded `--recovery-mode + --script` seed description. This Decision is the current authority for the verified `@tool` headless-editor mechanism; the implementation plan must be reconciled before merge/finalization.

## Next Gate

Run v5 from a brand-new Windows PowerShell while reusing the currently running exact Ten Paces editor if possible. Require `HERA_AUTH_SOURCE=...` followed by `HERA_EXACT_PROJECT_READY`. Then complete the project-specific Codex login if requested, require `CODEX_LOGIN_READY`, launch Codex, and fresh-check exact project + Godot AI 3.1.4 on 8003/9503 + Hera exact-project readiness. A second brand-new PowerShell repeat run proves idempotency before final promotion.
