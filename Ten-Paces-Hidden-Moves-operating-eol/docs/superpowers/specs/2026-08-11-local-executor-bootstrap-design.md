# Ten Paces Local Executor Bootstrap Design

## Decision

Decision ID: `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`

User-approved operating improvement on 2026-08-11 KST.

Goal: every local PowerShell implementation/review session for Ten Paces starts by bringing up or reusing one isolated project-local execution environment before any game BUILD work:

```text
one PowerShell copy/paste block
→ exact Ten Paces project identity check
→ dedicated Godot self-contained environment create-or-reuse
→ project HiGodot/Godot AI ports validate-or-fail-closed
→ dedicated Godot/HiGodot start-or-reuse
→ Hera v1 local QA instance discover/verify for the exact Ten Paces editor
→ project-scoped CODEX_HOME set for this PowerShell session
→ Codex config/CLI preflight
→ Codex launch in the exact project root
→ fresh HiGodot + Hera project/session/readiness verification before implementation work
```

This is an operating/tooling decision. It does not change player-facing rules, data, scenes, or game content.

## Fresh Authority Snapshot

Design input was refreshed immediately before writing and again after the user added Hera as an active local tool:

- Base default branch: `main`.
- Base current main: `49e68f009e02e1774f54cbd14ae6758030753646` (`ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP`).
- Ten Paces default branch: `main`.
- Ten Paces current main at design entry: `b9a9db62f4fd860131561a11d2ddebf3d496f39a`.
- Ten Paces open PR at design entry: draft PR #162, stale Phase-B review state relative to the user's later Plan-C implementation instruction.
- Google Sheet current operating contract: `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`.
- Godot AI source/plugin 3.1.4 is current; 3.1.4 local editor acceptance remains `NOT_RUN` until real local evidence exists.
- Hera v1.0.0 local live-QA acceptance already exists. Current Hera addon binds localhost only, scans `8770-8785`, writes live editor discovery records under `~/.hera-agent-godot/instances/<pid>.json`, and records the exact `project_path` and bound port.

## Shared Base Contract Consumed

Base owns the generic `ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP` rule. Ten Paces owns only concrete project-local values and stricter failure behavior.

The launcher is orchestration, not readiness evidence. Editor process existence, an open TCP port, or a visible Codex UI must never be promoted to live project/tool readiness without fresh project-authorized receipts after startup.

`BOOTSTRAP_MINIMUM_PREFLIGHT_ONLY` applies: verify only what is necessary to prevent the wrong project/editor/profile/port from being used before Codex starts. Do not front-load broad repository scans, broad diffs, or long diagnostics merely to open the executor.

## Concrete Ten Paces Binding

```yaml
project_root: C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves
godot_version: 4.7.1-stable
dedicated_godot_root: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1
dedicated_godot_exe: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\Godot_v4.7.1-stable_win64.exe
self_contained_marker: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\_sc_
self_contained_data: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\editor_data
higodot_http_port: 8003
higodot_ws_port: 9503
hera_version: 1.0.0
hera_bind_host: 127.0.0.1
hera_port_range: 8770-8785
hera_instance_discovery: C:\Users\user\.hera-agent-godot\instances\<pid>.json
codex_home: C:\Users\user\.codex-ten-paces
codex_working_directory: C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves
codex_default_sandbox: workspace-write
codex_default_approval: never
```

Godot self-contained mode is required so Ten Paces EditorSettings do not share `%APPDATA%\Godot` with other projects.

## Tool Role Composition

The local environment uses both HiGodot/Godot AI and Hera.

- HiGodot/Godot AI provides the project's current persistent Godot authoring path and project-aware MCP workflow.
- Hera v1.0.0 is actively available for live editor QA, status, diagnostics, scene/game inspection, screenshots, game-feel checks, and other approved live-QA/observability work.
- Hera is not treated as a prohibited tool in this bootstrap. The launcher should discover and verify the exact Ten Paces Hera instance and make it available during implementation/review sessions.
- Tool roles may evolve through later user-approved decisions; this bootstrap records current composition without adding a new blanket Hera prohibition clause.

## PowerShell Lifecycle Contract

Assume every previous PowerShell window has been closed.

Therefore every provided local-work block must re-establish all shell-scoped state on every invocation. In particular:

- never rely on yesterday's `$env:CODEX_HOME`;
- set `$env:CODEX_HOME` before starting/reusing any workflow that may configure Codex;
- change into the exact Ten Paces project before launching Codex;
- do not set a machine-wide or user-wide permanent `CODEX_HOME` merely for convenience;
- the same block must be safe for first-run and repeat-run use.

## First-Run Create-Or-Reuse Contract

If the dedicated environment does not exist, bootstrap creates it before attempting game work.

Creation must:

1. verify the exact Ten Paces `project.godot` exists;
2. locate an exact Godot `4.7.1-stable` Windows editor source from approved local candidates or stop with one actionable missing-source error;
3. create `C:\Users\user\Tools\Godot-Ten-Paces-4.7.1`;
4. copy/extract the editor binaries without modifying another Godot installation;
5. create `_sc_` next to the dedicated editor binary while the dedicated editor is not running;
6. verify subsequent editor data resolves to the dedicated `editor_data` tree before treating isolation as established;
7. establish project-specific HiGodot/Godot AI ports `8003/9503` before normal implementation use;
8. allow the enabled Hera addon to start in the same exact editor and publish its project-scoped heartbeat/instance record.

The launcher must not download or replace a different Godot version silently. If the exact source cannot be found, it stops and reports the required filename/version.

## Editor Reuse Contract

Repeat-run behavior prefers exact editor reuse over duplicate startup.

An editor is reusable only when minimum process identity checks show the dedicated Ten Paces Godot executable and exact Ten Paces project path. A generic Godot process match is insufficient.

If no exact matching editor exists, the launcher starts the dedicated editor with the exact project root.

The launcher does not terminate unrelated Godot editors or other projects' servers as a normal recovery action.

## HiGodot Port Isolation and Failure Rules

Ten Paces owns:

```text
HTTP 8003
WS   9503
```

HiGodot/Godot AI port handling is fail-closed:

- a free required port is acceptable for a fresh dedicated startup;
- an occupied port is not automatically considered Ten Paces merely because the process name resembles Godot AI/HiGodot;
- if an exact matching Ten Paces editor/session can be established, reuse is allowed;
- if ownership is ambiguous or foreign, stop before Codex and report the occupied port/process information;
- do not auto-kill the occupying process;
- do not silently switch Ten Paces to a different HiGodot port;
- same-port use by another HiGodot/Godot-AI project is a blocking configuration error, not a recovery path.

`Keep Server on Exit` is not required for this operating contract. The implementation should prefer behavior that keeps repeat-run ownership unambiguous.

## Hera Discovery and Verification

Hera uses a different coexistence model from HiGodot.

The current addon binds `127.0.0.1` to the first available port in `8770-8785`, so the bootstrap must not hard-code Hera to `8770` when multiple projects are open.

Instead it should:

1. wait for a fresh Hera instance heartbeat under `C:\Users\user\.hera-agent-godot\instances\`;
2. select the live instance whose normalized `project_path` matches the exact Ten Paces project root;
3. read that instance's actual PID and bound port;
4. use the configured shared token when token auth is enabled, without printing the raw token into logs/evidence;
5. run a bounded Hera status/readiness check against the exact Ten Paces instance;
6. retain the resolved Hera PID/port only as session evidence, not a permanent project port assignment.

This permits Hera to coexist with other project editors without forcing a shared fixed port.

## CODEX_HOME Isolation

Ten Paces uses:

```text
C:\Users\user\.codex-ten-paces
```

The Codex executable remains the existing shared installation; only its configuration home is isolated.

The bootstrap sets `$env:CODEX_HOME` in the current PowerShell before Codex configuration or launch. Ten Paces Godot AI's current Codex client descriptor explicitly supports `CODEX_HOME` and resolves `config.toml` from that directory.

The launcher must not overwrite a malformed existing `config.toml` blindly. Existing project Codex configuration is preserved where possible; configuration mismatches are surfaced for bounded repair.

## Codex CLI Launch Contract

The launcher must not assume CLI flags forever.

Before launch it resolves `codex.cmd` and performs a minimal current CLI preflight. The desired policy is:

```text
approval: never
sandbox: workspace-write
working directory: exact Ten Paces project root
```

If the installed Codex build no longer supports the expected flag form, the bootstrap stops with the detected help/version information instead of guessing an alternative flag.

## Fresh Readiness Gate Inside Codex

After Codex starts and before implementation work, Codex must fresh-read the actual project/tool state using the project-authorized live tools.

Minimum receipt must distinguish:

- exact project root;
- exact Godot project/session identity;
- active Godot AI/HiGodot version;
- HiGodot HTTP/WS ports actually used;
- exact live Hera instance PID/port and project match;
- live tool/session readiness;
- current git branch/worktree identity when implementation requires it.

Only after this fresh receipt may the current implementation packet continue.

Godot process launch, TCP LISTEN, Hera heartbeat existence, and Codex startup are bootstrap evidence only and are not substitutes for fresh live receipts.

## Safety Boundaries

The one-shot bootstrap itself does not modify `src/`, `scenes/`, `data/`, `assets/`, `project.godot`, or player-facing behavior merely to establish the environment. It does not perform destructive Git cleanup or discard user work, and it does not terminate unrelated project processes as a convenience mechanism.

The bootstrap does not claim Godot AI 3.1.4 local acceptance before real local evidence is collected. Draft PR #162's older Phase-B state does not override the user's later Plan-C implementation instruction.

No new blanket prohibition is added against Hera; Hera remains part of the active local toolchain and is intentionally available during implementation/review.

## Error Reporting

Bootstrap failures should return one short actionable blocker and stop before Codex where wrong-target risk exists.

Priority errors:

```text
wrong/missing project
→ missing exact Godot 4.7.1 source
→ invalid/missing dedicated self-contained installation
→ foreign/ambiguous 8003 or 9503 ownership
→ no fresh Hera instance matching exact Ten Paces project
→ Hera authentication/status mismatch
→ missing Codex CLI
→ unsupported requested Codex launch flags
→ malformed/unusable project CODEX_HOME config
```

No automatic destructive recovery is used.

## Adversarial Review Loop

Before any launcher block is handed to the user, review it against:

1. exact project path and `project.godot`;
2. exact dedicated Godot path/version and `_sc_` placement;
3. first-run and repeat-run behavior;
4. PowerShell-closed-between-sessions assumption;
5. 8003/9503 foreign ownership and same-port HiGodot collision;
6. Hera exact-project heartbeat selection rather than hard-coded `8770`;
7. token redaction and exact Hera status target;
8. unrelated process non-interference;
9. `CODEX_HOME` set before Codex configuration/launch;
10. current Codex CLI flag support rather than stale assumptions;
11. absence of destructive Git/process cleanup;
12. separation between bootstrap evidence and fresh HiGodot/Hera readiness evidence.

After the local environment is actually run, perform a second adversarial pass over observed process/port/config/session evidence before moving into game implementation.

## Acceptance Criteria

- One pasteable PowerShell block can be used on a fresh PowerShell session.
- The same block creates the dedicated environment when absent and reuses it when valid.
- Dedicated Godot runs self-contained and does not depend on `%APPDATA%\Godot` project-shared EditorSettings.
- Ten Paces HiGodot uses only HTTP `8003` and WS `9503`; collisions fail closed without killing the owner or auto-changing ports.
- Hera v1.0.0 is available in the same local workflow and is resolved by exact project heartbeat/PID/actual port rather than a globally fixed Hera port.
- Hera shared-token values are never printed into evidence.
- `$env:CODEX_HOME` is recreated every PowerShell session as `C:\Users\user\.codex-ten-paces`.
- Codex is launched in the exact Ten Paces project root with the approved sandbox/approval policy only after current CLI support is checked.
- No product/runtime files are mutated merely by bootstrap.
- Fresh HiGodot and Hera project/session/readiness evidence is obtained before implementation proceeds.
- A real first local run is required before Godot AI 3.1.4 local acceptance can move from `NOT_RUN`.
