# Session Handoff Refresh Design

## Goal

Refresh the existing project continuation owners so a new session can resume from current repository truth without relying on stale PR #82-era state or on the current chat.

## Scope

- Modify the existing mutable-state owner: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
- Modify the existing session boundary owner: `[기획서]/00_프로젝트_허브/HANDOFF.md`.
- Keep project core, product code, Scene, Resource, data, save, export preset, Decision documents, and current planning JSON unchanged.
- After merge, synchronize the Google Sheet hub summary and change history only.
- Do not create a new continuation-state owner, new Decision, new project Skill, new Base Skill, or Base Change Proposal.

## Current truth to preserve

- Project main: `43841d3cc6667d821c10df75272b239f314f3df0` at design time; open project PRs: none.
- Base remote main observed: `637dad32c773c56a27d44d847518580848dee493`.
- Project Base release/Adapter authority remains pinned to the project contract; a newer remote Base observation does not silently replace the project pin.
- GUT 9.7.1 reconciliation, Hera v1 local live QA, HiGodot L2 export exclusion authoring, Windows export, and PCK regression are completed and verified in merged project canon.
- Current entry gate remains fail-closed: Android/device/human verification is pending and product implementation is not authorized.
- The latest local platform collector attempt reached exact clean project main and then failed during `GODOT_DISCOVERY` because the collector's native-output handling called a method on a null value. It did not produce an Android gate result and must not be recorded as an Android product failure.
- User explicitly deferred the platform/device/human preflight for later and requested handoff work now.

## Continuation model

`ACTIVE_CONTEXT.md` remains the single mutable-state router. It should contain only the current checkpoint, completed verified outcomes, deferred/in-progress work, evidence ceiling, protected boundaries, read order, and next executable step.

`HANDOFF.md` remains the session transfer snapshot. It should point back to `ACTIVE_CONTEXT.md`, record what the current session actually completed, classify the deferred collector as `BLOCKED_UNVERIFIED / DEFERRED_BY_USER`, and tell the next session to fresh-read Base/project/Sheet before resuming the platform gate.

## Resume contract

When platform work resumes:

1. Fresh-read Base root/latest/open PRs, project main/open PRs, and Sheet.
2. Confirm project main and current entry gate have not changed.
3. Do not reuse the V2 collector implementation.
4. Use a null-safe Windows PowerShell native-process capture approach based on `Start-Process -Wait -PassThru` with separately redirected stdout/stderr.
5. Re-run local Windows automated runtime plus Android SDK/ADB/device preflight.
6. Classify actual results, then recheck `WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`.
7. Human/physical checks remain `NOT_RUN` until actually performed.

## Validation

- `tests/test_project_governance.py` must remain compatible with the stable discovery tokens required for `ACTIVE_CONTEXT.md` and `HANDOFF.md`.
- Project operating-system and reference-freshness workflows must remain green at the exact PR head.
- Changed-file scope must be documentation-only and contain no protected product paths.
- Post-merge, read back new main and synchronize/read back Sheet status.
