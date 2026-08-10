# Session Handoff Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace stale PR #82-era continuation text with a verified current-state router and handoff snapshot, then synchronize the project Sheet after merge.

**Architecture:** Reuse the project's existing `ACTIVE_CONTEXT.md` and `HANDOFF.md` owners. No new continuation authority is created. Repository changes are documentation-only; Google Sheet synchronization is post-merge and records the same repository truth without becoming the implementation authority.

**Tech Stack:** Markdown, GitHub pull requests, existing project governance tests, Google Sheets connector.

## Global Constraints

- Current target project: `alsdmlals4-eng/Ten-Paces-Hidden-Moves` only; Base is read-only authority/comparison for this change.
- Baseline project main at plan creation: `43841d3cc6667d821c10df75272b239f314f3df0`.
- Base remote main observed at plan creation: `637dad32c773c56a27d44d847518580848dee493`.
- Do not modify product code, Scene, Resource, data, save, `project.godot`, or `export_presets.cfg`.
- Do not create a new Decision, Skill, continuation-state owner, or Base proposal.
- Human/physical validation remains `NOT_RUN`; product implementation remains unauthorized.
- The deferred platform collector failure is a collector implementation failure at `GODOT_DISCOVERY`, not an Android product failure.

---

### Task 1: Refresh mutable active context

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Test: `tests/test_project_governance.py`

**Interfaces:**
- Consumes: `docs/planning-data/current_operating_state.json`, `docs/planning-data/current_entry_gate_20260808.json`, merged PR #133/#134 state, latest uploaded collector evidence.
- Produces: the single mutable project-state router used by `START_HERE.md`, `DOCUMENTATION_MAP.md`, Roadmap, and Handoff.

- [ ] **Step 1: Preserve governance-required stable tokens**

Keep `VERTICAL_SLICE_APP_FLOW_PLANNING`, `runtime_work_mode: REVIEW`, `runtime_integration_pr: 65`, current operating-state tokens, existing core Decision identifiers, `automated_validation: PASS`, `human_validation: NOT_RUN`, and the v6 ledger reference.

- [ ] **Step 2: Replace stale mutable state**

Record current project main, no active project PR, export-boundary completion, Android/device/human pending state, deferred collector failure classification, current Base remote observation, and exact next resume sequence.

- [ ] **Step 3: Validate governance contract**

Run the project governance/operating-system workflow on the exact branch head. Expected: no stale-state or required-token failures.

### Task 2: Refresh session handoff

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/HANDOFF.md`
- Test: `tests/test_project_governance.py`

**Interfaces:**
- Consumes: refreshed `ACTIVE_CONTEXT.md` and current entry gate.
- Produces: the new-session read order, completed outcomes, deferred work, stop conditions, and first executable action.

- [ ] **Step 1: Remove obsolete PR #82 active-state claims**

The handoff must not claim PR #82 is active or pending merge.

- [ ] **Step 2: Record current checkpoint and evidence ceiling**

Record merged main `43841d3c...` as the pre-handoff baseline, open PR none, export boundary PASS, platform collector `BLOCKED_UNVERIFIED / DEFERRED_BY_USER`, Android actual result `NOT_RUN`, and human validation `NOT_RUN`.

- [ ] **Step 3: Record resume-first algorithm**

Require fresh Base/project/Sheet readback before any platform collector retry and prohibit reuse of the V2 null-unsafe collector implementation.

### Task 3: Exact-head PR verification and merge

**Files:**
- Review all changed files from this branch.

**Interfaces:**
- Consumes: Tasks 1-2.
- Produces: one merge commit on project main containing only handoff/status documentation plus this approved design/plan record.

- [ ] **Step 1: Open a PR against current main**

PR body must state that no product or Decision authority changed and that platform verification is deferred by user.

- [ ] **Step 2: Verify exact head**

Check changed files, diff, mergeability, review threads, required workflow results, and main advancement.

- [ ] **Step 3: Squash merge only if exact-head checks pass**

Use expected head SHA. Do not merge on old-head evidence.

- [ ] **Step 4: Post-merge readback**

Confirm new main includes refreshed `ACTIVE_CONTEXT.md` and `HANDOFF.md`; confirm open project PR count and current entry gate.

### Task 4: Synchronize Google Sheet continuation summary

**Files:**
- Update Sheet `00_프로젝트_허브` current status row.
- Append one row to `99_변경이력`.

**Interfaces:**
- Consumes: post-merge project main SHA and latest Base remote main SHA.
- Produces: user-facing status synchronized with GitHub continuation truth.

- [ ] **Step 1: Update hub summary**

Record latest Base remote observation, post-merge project main, `PLATFORM_PREFLIGHT_DEFERRED_BY_USER`, the completed export boundary, Android/device/human pending/not-run status, and next executable sequence.

- [ ] **Step 2: Append change history**

Record that handoff owners were refreshed without a new Decision and that platform collector retry is intentionally deferred.

- [ ] **Step 3: Read back Sheet ranges**

Verify the Sheet reflects the same post-merge main and continuation state as GitHub.

## Self-review

- Spec coverage: all approved B-scope surfaces are covered; no product implementation is included.
- Placeholder scan: no TODO/TBD placeholders.
- Ownership consistency: `ACTIVE_CONTEXT.md` remains mutable-state owner; `HANDOFF.md` remains session-boundary owner; Sheet remains user-facing mirror.
