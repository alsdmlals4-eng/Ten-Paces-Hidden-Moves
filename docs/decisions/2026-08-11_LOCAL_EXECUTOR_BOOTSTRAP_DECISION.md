# TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01

## Status

`USER_APPROVED / WINDOWS_RUNTIME_PARTIAL_PASS / CODEX_DEDICATED_HOME_LOGIN_PENDING`

## Decision

Every local PowerShell implementation/review session for Ten Paces must establish the dedicated local execution environment before product BUILD work:

```text
dedicated Godot 4.7.1 self-contained
→ HiGodot/Godot AI HTTP 8003 / WS 9503
→ Hera v1.0.0 exact-project live instance
→ session-scoped CODEX_HOME=C:\Users\user\.codex-ten-paces
→ Codex from the exact Ten Paces project root
→ fresh HiGodot + Hera readiness receipt before persistent implementation
```

The operator is assumed to close PowerShell after a work session. Therefore shell-scoped state is recreated on every invocation. If the dedicated environment does not exist, the launcher creates it first. Foreign/ambiguous 8003/9503 ownership fails closed; the launcher does not kill unrelated processes or silently switch ports. Hera remains active tooling and is not blanket-prohibited.

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
codex_home: C:\Users\user\.codex-ten-paces
codex_sandbox: workspace-write
codex_approval: never
```

## Corrected Editor-Context Mechanism

The original implementation-plan mechanism `--recovery-mode + --script` is superseded by observed Windows/Godot 4.7.1 evidence.

A standalone `--script` probe exited 1 before its first marker. A temporary headless editor project whose scene root carries an `@tool` script produced:

```text
EXIT_CODE=0
TOOL_PROBE_ENTER_TREE=PASS
ENGINE_EDITOR_HINT=true
EDITOR_SETTINGS=AVAILABLE
HEADLESS_EDITOR_TOOL_CONTEXT=PASS
```

Therefore EditorSettings seeding/readback and Godot-AI-owned Codex configuration use a temporary `%TEMP%` Godot project with a headless editor `@tool` scene. The bootstrap script self-terminates via `SceneTree.quit()` after its work. It does not use `--recovery-mode` or standalone `--script` for editor-context work and does not place bootstrap files in the product repository.

## Windows Runtime Evidence — 2026-08-12 KST

The v3 launcher passed its Windows PowerShell parser gate and reached the persistent dedicated local environment. Observed evidence:

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

The first remaining failure was not Godot/HiGodot/Hera readiness. Windows PowerShell 5.1 wrapped Codex native stderr as a `NativeCommandError`, rendering the semantic status as `codex.cmd : Not logged in`. v3 incorrectly required a clean whole-line `Not logged in` match and therefore treated the expected first-use authentication state as an error instead of entering the interactive login flow.

## v4 Candidate

v4 changes only the Codex authentication transition:

- match semantic `Not logged in` text even when Windows PowerShell 5.1 wraps native stderr with error-record metadata;
- keep interactive `codex login` attached to the current console;
- temporarily allow native stderr during the interactive login without converting it into a terminating PowerShell error;
- continue to use the Codex process exit code and a post-login `codex login status` verification as authoritative gates;
- do not copy global Codex auth material into the dedicated home.

```yaml
launcher_v4_sha256: 08a723966e97198eaba7bb26e464504db2eb97e31e0880fad49145bfa22b6db7
v4_static_adversarial_checks: 19/19 PASS
v4_windows_parser: NOT_RUN
v4_windows_runtime: NOT_RUN
```

## Authority Snapshot

- Base default branch: `main`; fresh latest commit observed before v4 work: `1d6cc79ae95ffb67ba4de618f010a6540fc6e02c`.
- Project default branch: `main`; current main remains `b9a9db62f4fd860131561a11d2ddebf3d496f39a`.
- Project open PR: draft #162, whose earlier Phase-B blocking state is stale relative to the user's later explicit Plan-C implementation authorization.
- Google Sheet row for this Decision must carry the same runtime-partial/Codex-login-pending state until v4 is observed locally.

## Safety / Evidence Boundary

This bootstrap does not itself authorize unrelated product changes, destructive Git cleanup, unrelated process termination, automatic port fallback, or token disclosure. A launched process/listening socket is bootstrap evidence; fresh tool/project readiness is still required before persistent product mutation.

## Current Conflict Note

`docs/superpowers/plans/2026-08-11-local-executor-bootstrap.md` still describes the failed `--recovery-mode + --script` seed path. This Decision is the current authority for the corrected editor-context mechanism. The implementation plan must be reconciled to the verified `@tool` headless-editor path before this bootstrap work is finalized/merged.

## Next Gate

Run v4 from a brand-new Windows PowerShell session while reusing the exact Ten Paces dedicated Godot if it is still running. On first use of `C:\Users\user\.codex-ten-paces`, complete the official interactive Codex login. Require post-login `CODEX_LOGIN_READY`, then launch Codex with the verified sandbox/approval flags. Inside Codex, fresh-check exact project, Godot AI 3.1.4 on 8003/9503, and exact-project Hera readiness. A later second fresh-PowerShell run proves repeat-run isolation/idempotency before final promotion.
