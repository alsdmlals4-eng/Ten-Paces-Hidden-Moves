# Ten Paces Local Executor Bootstrap Design

## Decision

Decision ID: `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`

User-approved operating improvement on 2026-08-11 KST.

Goal: every local PowerShell implementation/review session for Ten Paces starts by bringing up or reusing one isolated project-local execution environment before any game BUILD work:

```text
one PowerShell copy/paste block
→ exact Ten Paces project identity check
→ dedicated Godot self-contained environment create-or-reuse
→ project ports validate-or-fail-closed
→ dedicated Godot/HiGodot start-or-reuse
→ project-scoped CODEX_HOME set for this PowerShell session
→ Codex config/CLI preflight
→ Codex launch in the exact project root
→ fresh HiGodot/session/readiness verification inside Codex before persistent mutation
```

This is an operating/tooling decision. It does not change player-facing rules, data, scenes, or game content.

## Fresh Authority Snapshot

Design input was refreshed immediately before writing:

- Base default branch: `main`.
- Base current main: `49e68f009e02e1774f54cbd14ae6758030753646` (`ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP`).
- Ten Paces default branch: `main`.
- Ten Paces current main at design entry: `b9a9db62f4fd860131561a11d2ddebf3d496f39a`.
- Ten Paces open PR at design entry: draft PR #162, stale Phase-B review state relative to the user's later Plan-C implementation instruction.
- Google Sheet current operating contract: `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`.
- Google Sheet Godot AI freshness: source/plugin 3.1.4 current; 3.1.4 local editor acceptance remains `NOT_RUN` until real local evidence exists.

## Shared Base Contract Consumed

Base owns the generic `ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP` rule. Ten Paces owns only concrete project-local values and stricter failure behavior.

The launcher is orchestration, not readiness evidence. Editor process existence, an open TCP port, or a visible Codex UI must never be promoted to live HiGodot/session readiness without a fresh project-authorized receipt inside Codex.

`BOOTSTRAP_MINIMUM_PREFLIGHT_ONLY` applies: verify only what is necessary to prevent the wrong project/editor/profile/port from being used before Codex starts. Do not front-load broad repository scans, broad diffs, or long diagnostics merely to open the executor.

## Concrete Ten Paces Binding

```yaml
project_root: C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves
godot_version: 4.7.1-stable
dedicated_godot_root: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1
dedicated_godot_exe: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\Godot_v4.7.1-stable_win64.exe
self_contained_marker: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\_sc_
self_contained_data: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\editor_data
http_port: 8003
ws_port: 9503
codex_home: C:\Users\user\.codex-ten-paces
codex_working_directory: C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves
codex_default_sandbox: workspace-write
codex_default_approval: never
```

Godot self-contained mode is required so Ten Paces EditorSettings do not share `%APPDATA%\Godot` with other projects.

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
7. establish project-specific Godot AI/HiGodot ports `8003/9503` before normal implementation use.

The launcher must not download or replace a different Godot version silently. If the exact source cannot be found, it stops and reports the required filename/version.

## Editor Reuse Contract

Repeat-run behavior prefers exact editor reuse over duplicate startup.

An editor is reusable only when minimum process identity checks show the dedicated Ten Paces Godot executable and exact Ten Paces project path. A generic `Godot.exe` process match is insufficient.

If no exact matching editor exists, the launcher starts the dedicated editor with the exact project root.

The launcher must not kill or restart unrelated Godot editors or other projects' servers.

## Port Isolation and Failure Rules

Ten Paces owns:

```text
HTTP 8003
WS   9503
```

Port handling is fail-closed:

- a free required port is acceptable for a fresh dedicated startup;
- an occupied port is not automatically considered Ten Paces merely because the process name resembles Godot AI/HiGodot;
- if an exact matching Ten Paces editor/session can be established, reuse is allowed;
- if ownership is ambiguous or foreign, stop before Codex and report the occupied port/process information;
- never auto-kill the occupying process;
- never silently switch Ten Paces to a different port because another project has taken 8003/9503;
- same-port use by another HiGodot/Godot-AI project is a blocking configuration error, not a recovery path.

`Keep Server on Exit` is not required for this operating contract. The implementation should prefer behavior that does not leave ambiguous orphan servers on 8003/9503 after the dedicated editor is intentionally closed. Any later decision to persist the server across editor exit requires explicit evidence that repeat-run ownership remains unambiguous.

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

After Codex starts and before persistent Godot mutation, Codex must fresh-read the actual project/tool state using the project-authorized live authority.

Minimum receipt must distinguish:

- exact project root;
- exact Godot project/session identity;
- active Godot AI/HiGodot version;
- HTTP/WS ports actually used;
- live tool/session readiness;
- current git branch/worktree identity when implementation requires it.

Only after this fresh receipt may the current implementation packet continue.

Godot process launch, TCP LISTEN, and Codex startup are bootstrap evidence only and are not a substitute for this receipt.

## Safety Boundaries

The one-shot bootstrap itself must not:

- modify `src/`, `scenes/`, `data/`, `assets/`, `project.godot`, or product runtime behavior;
- use shell/GitHub text editing as a bypass around HiGodot persistent Godot authoring authority;
- `git reset`, `git restore`, `git clean`, stage, rewrite, or discard user work;
- kill/restart unrelated editors, HiGodot/Godot-AI servers, Codex sessions, or other project processes;
- claim Godot AI 3.1.4 local acceptance before real local evidence is collected;
- treat draft PR #162's older Phase-B state as higher authority than the user's later Plan-C instruction.

## Error Reporting

Bootstrap failures should return one short actionable blocker and stop before Codex where wrong-target risk exists.

Priority errors:

```text
wrong/missing project
→ missing exact Godot 4.7.1 source
→ invalid/missing dedicated self-contained installation
→ foreign/ambiguous 8003 or 9503 ownership
→ missing Codex CLI
→ unsupported requested Codex launch flags
→ malformed/unusable project CODEX_HOME config
```

No automatic destructive recovery is allowed.

## Adversarial Review Loop

Before any launcher block is handed to the user, review it against:

1. exact project path and `project.godot`;
2. exact dedicated Godot path/version and `_sc_` placement;
3. first-run and repeat-run behavior;
4. PowerShell-closed-between-sessions assumption;
5. 8003/9503 foreign ownership and same-port HiGodot collision;
6. unrelated process non-interference;
7. `CODEX_HOME` set before Codex configuration/launch;
8. current Codex CLI flag support rather than stale assumptions;
9. absence of destructive Git or process cleanup;
10. separation between bootstrap evidence and fresh HiGodot readiness evidence.

After the local environment is actually run, perform a second adversarial pass over observed process/port/config/session evidence before moving into game implementation.

## Acceptance Criteria

- One pasteable PowerShell block can be used on a fresh PowerShell session.
- The same block creates the dedicated environment when absent and reuses it when valid.
- Dedicated Godot runs self-contained and does not depend on `%APPDATA%\Godot` project-shared EditorSettings.
- Ten Paces uses only HTTP `8003` and WS `9503`; collisions fail closed without killing the owner or auto-changing ports.
- `$env:CODEX_HOME` is recreated every PowerShell session as `C:\Users\user\.codex-ten-paces`.
- Codex is launched in the exact Ten Paces project root with the approved sandbox/approval policy only after current CLI support is checked.
- No product/runtime files are mutated by bootstrap.
- Fresh HiGodot/project/session/version/readiness evidence is obtained inside Codex before persistent Godot authoring.
- A real first local run is required before Godot AI 3.1.4 local acceptance can move from `NOT_RUN`.
