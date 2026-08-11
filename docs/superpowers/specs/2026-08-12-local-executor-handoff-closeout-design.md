# Local Executor Handoff Closeout Design

**Date:** 2026-08-12 KST  
**Decision:** `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`  
**Status:** USER-DIRECTED CONTINUATION / NO NEW PRODUCT DECISION

## Goal

Close the current local-executor work at a resumable project checkpoint without claiming the not-yet-run in-Codex fresh readiness gate. Persist the exact v5 launcher and its validated recovery lessons, route future verification through the existing project verification owner, synchronize the existing Active Context/Handoff owners, and merge the project-only learning closure before any Base proposal uses it as source evidence.

## Authority and scope

- Project authority: latest user instruction, `AGENTS.md`, existing Decision, GitHub current truth, Sheet current decisions.
- Current project main at design entry: `b9a9db62f4fd860131561a11d2ddebf3d496f39a`.
- Working branch: `docs/local-executor-bootstrap-20260811`, based directly on current main.
- Existing open project PR #162 is read-only/reference for this goal; its changed files do not overlap this closeout.
- Base active implementation is out of scope. Any reusable lesson may be recorded only under Base `[수정제안서]/**` in a separate proposal-only branch/PR after the project merge.

## Existing Solution First

### Project

`ten-paces-verification` already owns project-specific observable evidence and runtime verification. Therefore the local executor does **not** become a new broad Skill. Add one bounded mode/contract to the existing Skill and keep the executable implementation under `tools/`.

`[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` and `HANDOFF.md` already own live/resume state. Do not create a parallel progress file.

### Base

Base already implements `ONE_SHOT_LOCAL_EXECUTOR_BOOTSTRAP` and `PROJECT_DEDICATED_LOCAL_EXECUTION_ENVIRONMENT_FIRST`. Reusable findings therefore target an ABSORB-style proposal to those existing owners, not a new broad Base Skill. Base active files remain unchanged in this stage.

## Project changes

1. Persist the exact v5 launcher as `tools/start_ten_paces_local_executor.ps1`.
2. Update the launcher contract test to the observed Windows/Godot 4.7.1 mechanism:
   - temporary headless editor project with `@tool` scene;
   - no standalone `--script`/`--recovery-mode` editor-context seed;
   - Godot AI 3.1.4 on HTTP 8003 / WS 9503;
   - exact-project Hera v1.0.0 heartbeat plus supported auth-source reconciliation;
   - project-specific `CODEX_HOME` and official Codex login flow;
   - no unrelated process termination, destructive Git, or automatic port fallback.
3. Extend `skills/qa/ten-paces-verification/SKILL.md` with `local-executor-readiness`, requiring fresh project/CODEX_HOME/editor/port/MCP/Hera/GUT/no-new-mutation evidence and separating bootstrap orchestration from readiness PASS.
4. Add concise validated lessons to `skills/SKILL_LEARNING_LOG.md` rather than creating a new Skill.
5. Reconcile `ACTIVE_CONTEXT.md` and `HANDOFF.md` with the current checkpoint:
   - v5 parser/install and Hera exact-project auth selection observed;
   - dedicated Godot/Godot AI 3.1.4 8003/9503 and Hera evidence observed in the preceding local runs;
   - Codex session opened in the exact project with sandbox ready;
   - in-Codex fresh readiness and repeat-run idempotency remain `NOT_RUN`;
   - product implementation remains stopped until that gate is completed in a future session.

## Learning closure

- `LRN-TEN-LOCAL-001` — editor-context bootstrap must execute inside an actual headless editor `@tool` context. Classification: `SPLIT`; project application is launcher + regression, Base candidate is owner-absorb proposal.
- `LRN-TEN-LOCAL-002` — native stderr text is not itself process failure; exit-code/semantic classification must be preserved, especially in Windows PowerShell 5.1. Classification: `BASE_CANDIDATE`; project application is launcher capture/login handling.
- `LRN-TEN-LOCAL-003` — a fresh shell may not know the auth source retained by a reused live editor; select the exact project instance first, probe supported secret sources without disclosure, and fail closed if none authenticate. Classification: `SPLIT`; project application is v5 Hera auth recovery.
- `LRN-TEN-LOCAL-004` — a generated/manual launcher artifact is not resumable until the executable and regression contract live in the repository. Classification: `PROJECT_ONLY` with possible Base reuse covered by existing one-shot owner; project application is repository persistence.

## Verification

Project merge gate requires:

- Python launcher contract GREEN against the persisted v5 script.
- Project operating/skill validators covering the modified Skill remain GREEN.
- Changed-file review confirms no `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` mutation.
- Exact PR head checks are terminal-success or explicitly `NOT_RUN/BLOCKED_UNVERIFIED`; no old-head success reuse.
- Handoff claims only evidence actually observed in this conversation and labels the remaining live gates `NOT_RUN`.

## Merge and continuation

Merge the project closeout once exact-head review is clean. Re-read new main, PR #162, and the Sheet. Do not create a self-referential Handoff PR only to record its own merge SHA. The next session always refetches latest main before use.

After project new-main verification, evaluate a single Base proposal against latest Base main + open proposal-only PRs. Reuse an existing BCP if the goal is already covered; otherwise create one current-schema `SUBMITTED` proposal with Ten Paces source commit/evidence. Never edit Base active implementation in this stage.
