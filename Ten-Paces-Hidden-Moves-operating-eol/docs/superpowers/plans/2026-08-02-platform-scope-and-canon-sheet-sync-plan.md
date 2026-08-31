# Platform Scope and Canon-Sheet Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Record the approved PC-first/mobile-consideration platform boundary and remove stale GitHub–Google Sheets operating-state drift without changing product runtime files.

**Architecture:** GitHub remains the canonical authority. A dedicated Decision and non-runtime planning JSON own the platform boundary; entry documents and the roadmap point to that authority; the Google Sheet mirrors the same Decision ID and exact branch commit with a truthful Draft-PR sync status.

**Tech Stack:** Markdown, JSON, GitHub branch and Draft PR, Google Sheets API.

## Global Constraints

- Primary platform is `PC`.
- Mobile is `CONSIDERATION_ONLY`; mobile implementation authority is `NONE`.
- Do not modify `data/`, `src/`, `scenes/`, `assets/`, `addons/`, or `project.godot`.
- Preserve the 10-cell, 3/3/4, public-information, non-cheating-AI combat core.
- Do not claim Windows runtime, device, accessibility, performance, store, or human validation unless executed.
- GitHub is authoritative; Sheet changes must retain the same Decision ID and commit reference.

---

### Task 1: Establish the platform Decision

**Files:**
- Create: `docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md`
- Create: `docs/planning-data/approved_20260802_platform_scope_contract.json`

**Interfaces:**
- Consumes: user instruction `PC, 이후 모바일(고려 중)`.
- Produces: `TEN-DEC-20260802-PLATFORM-SCOPE-01` and its non-runtime structured contract.

- [ ] **Step 1: Create the Decision document**

Record PC as the current product baseline, Mobile as consideration only, current exclusions, compatibility guardrails, and explicit reconsideration gates.

- [ ] **Step 2: Create the planning JSON**

Use `APPROVED_PLANNING`, `NON_RUNTIME_APPROVED_PLANNING`, `implementation_authority: NONE`, and explicit `NOT_RUN` validation fields.

- [ ] **Step 3: Validate the contract**

Read both files back from the branch. Confirm the same Decision ID, status, platform roles, next package, exclusions, and validation limits.

### Task 2: Repair canonical entry-point drift

**Files:**
- Modify: `README.md`
- Modify: `START_HERE.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `docs/04_ROADMAP.md`

**Interfaces:**
- Consumes: Base v9.4 adoption commit `c5771ddae40f58d88824d9319fc4ef6cd1053bba`, PR #65 post-merge state, and Task 1 Decision.
- Produces: one consistent cold-start route and next package contract.

- [ ] **Step 1: Update current-state metadata**

Set current main to `c5771ddae40f58d88824d9319fc4ef6cd1053bba`, Base to `9.4.0`, platform to PC with Mobile consideration only, and next package to `VERTICAL_SLICE_APP_FLOW_SHELL`.

- [ ] **Step 2: Remove completed work from active queues**

Remove PR #65 sync/merge and Base v9.3 migration from current work. Preserve them as completed history.

- [ ] **Step 3: Add platform responsibility links**

Point platform questions to `docs/decisions/2026-08-02_PLATFORM_SCOPE_DECISION.md` and list the structured planning contract.

- [ ] **Step 4: Validate cold start**

Read AGENTS→START_HERE→ACTIVE_CONTEXT→DOCUMENTATION_MAP→ROADMAP and confirm a new worker finds the same stage, platform, next package, exclusions, and validation gaps.

### Task 3: Record the adversarial audit and issue-state cleanup

**Files:**
- Create: `docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md`
- Update issue state: #60 and #63.
- Add current-state note: #54.

**Interfaces:**
- Consumes: Base main, project main, current canonical files, open issues, and Sheet readback.
- Produces: finding ledger, strength preservation map, next-work order, and truthful issue states.

- [ ] **Step 1: Record validated findings**

Classify Sheet v9.1/CONCEPT_APPROVAL/PR-open values and GitHub PR #65 current-work references as `MISSING_SYNC` or `STALE_REFERENCE`.

- [ ] **Step 2: Preserve strengths and evidence limits**

Record protected combat decisions and keep Windows/device/accessibility/performance/human evidence as `NOT_RUN`.

- [ ] **Step 3: Clean stale operational issues**

Close #60 and #63 as completed/superseded by PR #68 Base v9.4 adoption. Keep #54 open and note that it is now gated by App Flow Shell rather than concept approval.

### Task 4: Synchronize Google Sheets

**Files:**
- Update ranges in `00_프로젝트_허브`, `01_작업순서`, `02_현재_확정결정`, `04_누락_충돌_감사`, `05_GDD_요약`, `20_코어경험_데모목표`, `30_데모범위_품질기준_제작기반`, `80_데모_버티컬슬라이스_플레이테스트`, `90_본제작_출시_사업`, and `99_변경이력`.

**Interfaces:**
- Consumes: exact branch commit containing Tasks 1–3.
- Produces: Sheet rows with `TEN-DEC-20260802-PLATFORM-SCOPE-01`, GitHub path, commit SHA, and Draft-PR sync status.

- [ ] **Step 1: Preserve headers and existing user content**

Read target ranges immediately before writing and append or update only exact cells required by the validated findings.

- [ ] **Step 2: Correct current-state drift**

Replace stale Base v9.1, `CONCEPT_APPROVAL`, `PLAN`, and PR #65-open current summaries with current v9.4/App Flow Planning values.

- [ ] **Step 3: Add the platform Decision**

Append one current Decision row and corresponding audit/change-history rows using the same Decision ID and branch commit.

- [ ] **Step 4: Read back and compare**

Confirm Decision ID, status, summary, GitHub path, commit, platform scope, next package, and validation limitations match GitHub.

### Task 5: Draft PR and exact-HEAD verification

**Files:**
- GitHub Draft PR from `agent/2026-08-02-total-planning-audit-platform-sync` to `main`.

**Interfaces:**
- Consumes: all prior tasks.
- Produces: reviewable Draft PR, changed-file inventory, CI status, unresolved-thread status, and rollback branch.

- [ ] **Step 1: Open the Draft PR**

Summarize findings, protected scope, exact Decision ID, Sheet ranges, validation performed, and all `NOT_RUN` evidence.

- [ ] **Step 2: Verify exact HEAD**

Read PR metadata, changed filenames, diff, combined status, reviews, threads, and comparison to latest main.

- [ ] **Step 3: Run the final adversarial recheck**

Confirm no product paths changed, no mobile implementation was authorized, no stale current-work references remain in changed entry points, and Sheet readback matches the GitHub Decision.

- [ ] **Step 4: Report without merging**

Return the Draft PR number, exact HEAD, canonical paths, Sheet locations, tests/checks, blocked evidence, rollback branch, and next implementation package.
