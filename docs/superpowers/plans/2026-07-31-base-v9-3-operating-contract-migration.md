# Base v9.3 Operating Contract Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate Ten Paces: Hidden Moves from the Base v9.1 project operating contract to the released Base v9.3 line and Vertical Slice v9 execution contract without changing project canon or protected Godot product paths.

**Architecture:** Keep `skills/PROJECT_BASE_ADAPTER.json` as the machine-readable source of the Base pin, protected paths, Sheet state, and shared/local routing. Regenerate `skills/PROJECT_SKILL_SNAPSHOT.json` and the workflow router as derivatives, then align active entry documents and validation contracts. Preserve v6 product decisions and treat v8/v9.1 artifacts as compatibility or historical evidence.

**Tech Stack:** GitHub Markdown/JSON, Python unittest/pytest governance checks, Godot 4.7 project metadata (read-only in this migration), Google Sheets GDD (read-only until merged main is verified).

## Global Constraints

- Repository: `alsdmlals4-eng/Ten-Paces-Hidden-Moves`.
- Baseline: `main@bf60548cb461523ff655ce50951f1636808c5c02`.
- Base release line: `v9.3.0`.
- Base release commit: `30ca6c7b5f93521f0eb0eed42d01437cd43c50ae`.
- Base evidence commit: `462a86db192d23d0f386281a1eb54b0a8cbad62e`.
- Base Registry SHA-256: `9847bb2b225c776ad7916930f0f48c490bc2a898bea8e02ea1fdd0e6caac60c1`.
- Active execution contract: `templates/prompts/VERTICAL_SLICE_INTEGRATED_EXECUTION_PROMPT_v9.md`, contract version `9.1`, release line `Base v9.3`.
- Work profile: `RECONCILIATION_PLANNING_PROFILE`; product stage remains `CONCEPT_APPROVAL`; product Work Mode remains `PLAN`.
- Preserve the four project-local Skills and all v6 decision authority.
- Do not modify `data/`, `src/`, `scenes/`, `assets/`, `addons/`, or `project.godot`.
- Do not write to Google Sheets before the migration PR is merged and the merged main SHA is re-read.
- Runtime, Windows, accessibility-user, performance, and human-play evidence remain `NOT_RUN` unless actually executed.

---

### Task 1: Bind the Base v9.3 operating contract

**Files:**
- Modify: `skills/PROJECT_BASE_ADAPTER.json`
- Modify: `skills/PROJECT_SKILL_SNAPSHOT.json`
- Modify: `.agents/skills/ten-paces-hidden-moves-workflow-router/SKILL.md`
- Modify: `docs/PROJECT_OPERATING_HEALTH.json`
- Modify: `docs/PROJECT_OPERATING_DASHBOARD.html`

**Interfaces:**
- Consumes: Base v9.3 release/evidence pins, Base Registry hash, project Registry hash, protected-path policy.
- Produces: One machine-readable adapter and deterministic generated views with 27 Base shared routes and 4 project-local routes.

- [ ] **Step 1:** Update the adapter release line, release/evidence pins, Base Registry hash, baseline main SHA, and explicit Vertical Slice v9 execution-contract metadata.
- [ ] **Step 2:** Regenerate the snapshot from the adapter and `skills/SKILL_REGISTRY.json`; preserve the local-first precedence and all 31 effective routes.
- [ ] **Step 3:** Update the workflow router description so it resolves Base v9.3 / Vertical Slice v9 contracts and fails closed on pin mismatch.
- [ ] **Step 4:** Regenerate operating health/dashboard provenance while retaining `NOT_RUN` critical gates.
- [ ] **Step 5:** Validate JSON parsing, exact pins, route counts, local Skill IDs, and adapter/snapshot provenance hashes.

### Task 2: Align active entry documents and authority maps

**Files:**
- Modify: `AGENTS.md`
- Modify: `START_HERE.md`
- Modify: `README.md`
- Modify: `docs/BASE_RULES_VERSION.md`
- Modify: `docs/BASE_SHARED_SKILL_INTEGRATION.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`

**Interfaces:**
- Consumes: Task 1 adapter paths and current v6 authority ledger.
- Produces: Active documents that name only Base v9.3 and Vertical Slice v9 as current operating authority while retaining legacy evidence as non-authoritative.

- [ ] **Step 1:** Replace active v8 authority references with the Base v9.3 application-binding order.
- [ ] **Step 2:** Make `skills/SKILL_REGISTRY.json` the current project Registry and label the hub Registry compatibility/history only.
- [ ] **Step 3:** Preserve product stage, v6 decision authority, protected paths, T0 implementation facts, and human validation state.
- [ ] **Step 4:** Record PC-first and future-mobile platform direction without introducing implementation scope.
- [ ] **Step 5:** Re-scan active entry documents for stale current-authority references.

### Task 3: Update validation contracts

**Files:**
- Modify: `.github/reference-freshness.json`
- Modify: `tests/test_base_v9_adoption.py`
- Modify: `tests/test_base_v91_operating_contract.py`
- Modify: `tests/test_bca_visual_sheet_adoption.py`

**Interfaces:**
- Consumes: Task 1 pins and Task 2 active-document tokens.
- Produces: Governance tests that reject v8/v9.1 as active authority and verify the blocked Sheet policy.

- [ ] **Step 1:** Change expected Base commit, Registry path, and required active tokens to Base v9.3 / Vertical Slice v9.
- [ ] **Step 2:** Add stale active-token rejection for the v8 prompt and old Base SHA while allowing archived compatibility paths.
- [ ] **Step 3:** Assert adapter release/evidence/Registry pins, four local Skills, and `SHEET_GITHUB_CONFLICT / BLOCKED` state.
- [ ] **Step 4:** Run the focused Python governance tests and the repository operating checks.
- [ ] **Step 5:** Record any unavailable runtime or human checks as `NOT_RUN`, not PASS.

### Task 4: Review, merge, and post-merge synchronization

**Files:**
- Create after merge: GitHub/Sheet synchronization evidence through Issue comments and contracted Sheet rows.
- Do not modify product paths.

**Interfaces:**
- Consumes: Reviewed PR head and merged main SHA.
- Produces: Merged Base v9.3 operating contract, reconciled Sheet status, and a clean handoff to Issue #64.

- [ ] **Step 1:** Compare the branch with baseline and prove zero changes under protected paths.
- [ ] **Step 2:** Review the complete PR patch for stale pins, duplicate authority, accidental product changes, and overclaimed evidence.
- [ ] **Step 3:** Confirm required GitHub checks on the final PR head.
- [ ] **Step 4:** Merge only after the final diff and checks are acceptable.
- [ ] **Step 5:** Re-read merged `main`, then update only contracted Google Sheet cells with the merged SHA and reconciled status.
- [ ] **Step 6:** Continue Issue #64 as a planning-only canon update; do not implement server or mobile runtime.
