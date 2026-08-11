# Ten Paces Local Executor Bootstrap Implementation Plan

> **Status:** `SUPERSEDED_IN_PART_BY_VERIFIED_WINDOWS_EVIDENCE`  
> **Decision:** `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`  
> **Current executable:** `tools/start_ten_paces_local_executor.ps1`  
> **Current closeout plan:** `docs/superpowers/plans/2026-08-12-local-executor-handoff-closeout.md`

## Goal preserved

Build one idempotent Windows PowerShell launcher that creates or reuses the isolated Ten Paces local execution environment, binds Godot AI/HiGodot to HTTP `8003` / WS `9503`, discovers the exact-project Hera v1.0.0 instance, restores project-scoped `CODEX_HOME=C:\Users\user\.codex-ten-paces` for every fresh shell, and launches Codex in the exact project root without destructive Git cleanup or unrelated process termination.

The original plan's goal, safety boundary, exact project/Godot/port/CODEX_HOME bindings, Hera active-tooling role, minimum preflight, and “bootstrap is not readiness evidence” rule remain current.

## Corrected editor-context mechanism

The original draft instructed editor-setting/configuration work through a temporary `--recovery-mode + --script` path. Real Windows/Godot 4.7.1 evidence disproved that mechanism for this use case: the standalone script exited before its first editor-context marker.

The verified mechanism is:

```text
create temporary %TEMP% Godot project
→ create root scene with @tool script
→ start the exact dedicated Godot as --editor --headless --path <temp-project> res://bootstrap.tscn
→ use EditorInterface.get_editor_settings() or current Godot-AI configurator inside the actual editor context
→ script prints explicit marker
→ script self-terminates via SceneTree.quit()
→ PowerShell retains a bounded exact-child watchdog
→ delete temporary project
```

Observed proof:

```text
EXIT_CODE=0
TOOL_PROBE_ENTER_TREE=PASS
ENGINE_EDITOR_HINT=true
EDITOR_SETTINGS=AVAILABLE
HEADLESS_EDITOR_TOOL_CONTEXT=PASS
```

Therefore current implementation and regression tests explicitly reject `--recovery-mode` and standalone `--script` as the editor-context bootstrap mechanism. The failed approach is retained here only as troubleshooting history.

## Current implementation contract

`tools/start_ten_paces_local_executor.ps1` must preserve these invariants:

- exact project root `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves` and expected GitHub origin;
- dedicated self-contained Godot 4.7.1 under `C:\Users\user\Tools\Godot-Ten-Paces-4.7.1` with `_sc_`;
- exact Godot editor reuse requires explicit `--path` binding to Ten Paces and exactly one matching editor;
- project toolchain is already bound before start: Godot AI 3.1.4, GUT 9.7.1, Hera v1.0.0 plus required autoloads;
- Godot AI EditorSettings are `8003`, `9503`, `keep_server_on_exit=false` and are read back from a fresh editor context;
- Codex MCP configuration is rendered by the current project Godot AI 3.1.4 configurator, not by a guessed legacy TOML URL;
- 8003/9503 foreign or ambiguous owners fail closed; ports do not auto-increment and unrelated processes are not killed;
- Hera is selected by fresh exact-project heartbeat/PID and its dynamic localhost port in `8770..8785`;
- reused Hera editor authentication is reconciled only against supported sources for that exact instance, without exposing token values;
- Windows PowerShell 5.1 native stderr wrappers are separated from process exit/semantic status for Codex login;
- `$env:CODEX_HOME` is recreated on every invocation and official Codex login is used when the dedicated home is not authenticated;
- Codex help is checked before launching the required `workspace-write` / `never` policy form;
- no `git reset`, `git restore`, `git clean`, staging, unrelated process kill, product file bootstrap mutation, or automatic port fallback.

The executable contract is enforced by `tests/test_local_executor_bootstrap_contract.py`.

## Runtime evidence chronology

### v1

Failed during attempted EditorSettings seed. Godot emitted shutdown warnings and the expected marker was absent.

### Direct standalone probe

`--editor --headless --recovery-mode --script` exited `1` with no probe marker. This proved the seed architecture, not only stderr handling, was wrong.

### Headless editor `@tool` probe

Passed with real editor hint and available EditorSettings. This became the current mechanism.

### v2

EditorSettings set/readback passed. Godot-AI Codex configuration then aborted during initial filesystem scan because the draft used an iteration-count `--quit-after` assumption.

### v3

Bootstrap script self-termination plus a real-time PowerShell watchdog fixed that lifecycle. Dedicated Godot, Godot AI 3.1.4 on 8003/9503, and exact-project Hera were observed. The next failure was expected first-use Codex `Not logged in`, misclassified because Windows PowerShell 5.1 wrapped native stderr as `NativeCommandError`.

### v4

Codex semantic login handling was corrected. Reuse of the already-running exact Ten Paces editor then exposed Hera auth-source drift between a fresh shell and a plugin that had read its token at startup.

### v5

Exact-project Hera auth-source reconciliation was added. Observed checkpoint:

```yaml
launcher_sha256: db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c
windows_parser_install: PASS
godot_4_7_1: RUNTIME_OBSERVED
godot_ai_3_1_4_http_8003_ws_9503: RUNTIME_OBSERVED
hera_auth_source: shared_token
hera_exact_project: RUNTIME_OBSERVED
codex_dedicated_home_login: PASS_TO_INTERACTIVE_SESSION
codex_exact_project_sandbox_ready: PASS
in_codex_fresh_readiness: NOT_RUN
fresh_powershell_repeat_run: NOT_RUN
```

Token raw values are not evidence. Historical PIDs and dynamic ports are not current authority.

## Remaining execution gates

This implementation plan is not complete merely because Codex opened. The next local session must refetch project/Base/Sheet truth and use the existing `ten-paces-verification: local-executor-readiness` mode for:

```text
IN_CODEX_FRESH_READINESS_GATE
→ project/worktree/origin identity
→ CODEX_HOME identity
→ exact dedicated Godot
→ Godot AI 3.1.4 + unique 8003/9503 ownership
→ smallest read-only GODOT_AI_MCP_LIVE call
→ Hera v1.0.0 exact-project read-only status
→ GUT 9.7.1
→ pre/post REPO_NO_NEW_MUTATION
→ OVERALL PASS

then

FRESH_POWERSHELL_REPEAT_RUN_GATE
```

Until those gates are actually observed, their status is `NOT_RUN`. Do not turn launcher/process/port presence into a readiness PASS.

## Learning and handoff

Validated local recovery lessons live in `skills/SKILL_LEARNING_LOG.md`. Current semantic state and resume order live only in the existing `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` and `HANDOFF.md`; do not create a parallel progress owner.

Further closeout/merge work follows `docs/superpowers/plans/2026-08-12-local-executor-handoff-closeout.md`.
