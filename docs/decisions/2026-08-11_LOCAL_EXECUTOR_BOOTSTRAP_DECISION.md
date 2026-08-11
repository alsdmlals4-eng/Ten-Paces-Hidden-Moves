# TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01

## Status

`USER_APPROVED_DESIGN / SPEC_REVIEW_PENDING / IMPLEMENTATION_NOT_STARTED`

## Decision

For local PowerShell implementation/review work, Ten Paces must bootstrap its dedicated local execution environment before game BUILD work:

```text
dedicated Godot self-contained
→ HiGodot/Godot AI on project ports HTTP 8003 / WS 9503
→ Hera v1.0.0 exact-project live QA instance discovery/readiness
→ project-scoped CODEX_HOME
→ Codex from the exact Ten Paces project root
→ fresh HiGodot + Hera project/session/readiness receipts before implementation proceeds
```

The launcher is provided as one copy/paste PowerShell block. Every invocation assumes the previous PowerShell window has been closed, so shell-scoped state such as `CODEX_HOME` must be recreated each time.

If the dedicated environment does not exist, bootstrap creates it first from an exact Godot `4.7.1-stable` source. If exact project/editor/profile/HiGodot-port ownership cannot be established, bootstrap fails closed. It does not use destructive recovery, does not kill unrelated processes, and does not treat a listening port/process launch as live readiness proof.

Hera is part of the active local workflow. No new blanket Hera prohibition is introduced by this Decision. Current use includes live QA, status, diagnostics, scene/game inspection, screenshots, and other approved observability/QA work.

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
codex_home: C:\Users\user\.codex-ten-paces
codex_sandbox: workspace-write
codex_approval: never
```

Hera's current addon does not require one globally fixed port. It binds the first available localhost port in `8770-8785` and publishes a heartbeat containing PID, actual port, exact `project_path`, Godot version, and scene. The bootstrap therefore resolves Hera by exact Ten Paces project identity rather than assuming port `8770`. Shared token material is used when enabled but is never emitted in evidence.

## Authority / Evidence Boundary

- Consumes Base `ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP` at Base main `49e68f009e02e1774f54cbd14ae6758030753646`.
- Uses HiGodot/Godot AI and Hera together in the local implementation/review workflow.
- Current HiGodot and Hera responsibilities remain as established by the active toolchain unless a later user-approved Decision changes them; this Decision adds no blanket Hera prohibition.
- Does not change product/runtime files or player-facing behavior merely by bootstrap.
- Does not promote Godot AI 3.1.4 local acceptance from `NOT_RUN` until a real local run produces fresh evidence.
- Existing Hera v1.0.0 live-QA acceptance remains valid historical/current evidence, while each new execution session still obtains a fresh exact-project Hera readiness receipt.
- Draft PR #162 contains earlier Phase-B state and must not override the user's later explicit Plan-C implementation instruction.

## Design Canon

`docs/superpowers/specs/2026-08-11-local-executor-bootstrap-design.md`

## Next Gate

User reviews the revised written design spec. After explicit review approval, create the implementation plan and then produce/validate the one-shot PowerShell launcher before first local execution.
