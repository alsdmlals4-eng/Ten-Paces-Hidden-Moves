# TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01

## Status

`USER_APPROVED_DESIGN / SPEC_REVIEW_PENDING / IMPLEMENTATION_NOT_STARTED`

## Decision

For local PowerShell implementation/review work, Ten Paces must bootstrap its dedicated local execution environment before game BUILD work:

```text
dedicated Godot self-contained
→ HiGodot/Godot AI on project ports HTTP 8003 / WS 9503
→ project-scoped CODEX_HOME
→ Codex from the exact Ten Paces project root
→ fresh project-authorized live readiness receipt before persistent mutation
```

The launcher is provided as one copy/paste PowerShell block. Every invocation assumes the previous PowerShell window has been closed, so shell-scoped state such as `CODEX_HOME` must be recreated each time.

If the dedicated environment does not exist, bootstrap creates it first from an exact Godot `4.7.1-stable` source. If exact project/editor/profile/port ownership cannot be established, bootstrap fails closed. It must not kill unrelated processes, reset/clean user work, silently change ports, or treat a listening port/process launch as live readiness proof.

## Concrete Binding

```yaml
project_root: C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves
dedicated_godot_root: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1
dedicated_godot_exe: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\Godot_v4.7.1-stable_win64.exe
self_contained_marker: C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\_sc_
http_port: 8003
ws_port: 9503
codex_home: C:\Users\user\.codex-ten-paces
codex_sandbox: workspace-write
codex_approval: never
```

## Authority / Evidence Boundary

- Consumes Base `ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP` at Base main `49e68f009e02e1774f54cbd14ae6758030753646`.
- Preserves HiGodot/Godot AI as the project's persistent Godot authoring authority.
- Does not change product/runtime files or player-facing behavior.
- Does not promote Godot AI 3.1.4 local acceptance from `NOT_RUN` until a real local run produces fresh evidence.
- Draft PR #162 contains earlier Phase-B state and must not override the user's later explicit Plan-C implementation instruction.

## Design Canon

`docs/superpowers/specs/2026-08-11-local-executor-bootstrap-design.md`

## Next Gate

User reviews the written design spec. After explicit review approval, create the implementation plan and then produce/validate the one-shot PowerShell launcher before first local execution.
