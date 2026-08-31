# 십보강호 v4.8 Current Authority Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 십보강호의 current operating authority를 v4.8 r2 + Notion/repository domain split으로 승격하고, v4.5/Google Sheets current-authority 퇴행을 회귀 테스트로 차단한다.

**Architecture:** v4.8은 프로젝트-specific thin adapter로 유지하고 Base 상세 절차는 latest Base owner로 progressive-load한다. mutable state는 `ACTIVE_CONTEXT`/current JSON/GitHub live metadata/exact Notion에만 두고 stable router는 owner와 불변식만 보유한다. v4.5와 legacy Sheet 자료는 삭제하지 않고 historical/migration compatibility로 낮춘다.

**Tech Stack:** Markdown, JSON, Python `unittest`, GitHub Actions, Notion readback.

**Spec:** `docs/superpowers/specs/2026-08-24-v48-current-authority-migration-design.md`

## Global Constraints

- Baseline main: `b35112592e608cd974411bafe07ef5e37ab866b2`.
- Current Decision ID: `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`.
- Uploaded v4.8 source SHA-256: `6f0541048e084746f6777223521361d0339dbfb2e223c70947f694f1c050f508`.
- `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` 변경 금지.
- Google Sheets는 `MIGRATION_ONLY_UNTIL_REMOVAL`; unique unmigrated material 확인 전 삭제 금지.
- v4.5 r2 Decision/JSON/body는 historical evidence로 보존.
- Human/Android/local Windows evidence ceiling은 기존 `NOT_RUN`을 유지.
- 모든 저장소 변경은 current-task branch/PR에서만 수행하고 force/direct-main을 금지한다.

---

### Task 1: RED — current authority regression

**Files:**
- Create: `tests/test_integrated_work_contract_v48r2.py`
- Modify: `tests/test_integrated_work_contract_v45r2.py`
- Modify: `.github/workflows/documentation-governance.yml`

**Interfaces:**
- Consumes: current canonical contract and cold-start files.
- Produces: failing tests that require v4.8 current authority while preserving v4.5 historical integrity.

- [ ] Add tests asserting `contract_version: '4.8'`, revision `2026-08-24-r2`, new Decision ID, Notion/repository domain split, and `MIGRATION_ONLY_UNTIL_REMOVAL`.
- [ ] Convert v4.5 tests so they verify retained historical Decision/JSON/body integrity rather than current routing.
- [ ] Add v4.8 test invocation to PR validation workflow.
- [ ] Open current-task PR and observe the expected RED failure on the unchanged v4.5 current entrypoint.

### Task 2: GREEN — bind v4.8 thin adapter

**Files:**
- Modify: `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`
- Create: `docs/decisions/2026-08-24_INTEGRATED_WORK_CONTRACT_V4_8_R2_BINDING_DECISION.md`
- Create: `docs/planning-data/approved_20260824_integrated_work_contract_v4_8_r2_binding.json`

**Interfaces:**
- Consumes: approved v4.8 source hash and current project authority.
- Produces: stable project current operating contract + structured binding.

- [ ] Replace the current entrypoint with a concise v4.8 r2 project adapter containing authority order, domain split, open-PR safety, evidence ceilings, continuous-work rule, visual approval rule, completion rule, and historical v4.5 pointer.
- [ ] Create the binding Decision with supersession and non-product-mutation boundary.
- [ ] Create structured JSON with source hash, canonical path, superseded Decision, Notion/repository/Sheet roles, and protected product paths.

### Task 3: GREEN — cold-start and Sheet authority consumers

**Files:**
- Modify: `AGENTS.md`
- Modify: `START_HERE.md`
- Modify: `README.md`
- Modify: `docs/BASE_RULES_VERSION.md`
- Modify: `docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md`
- Modify: `[기획서]/00_프로젝트_허브/START_HERE.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- Modify: `skills/PROJECT_BASE_ADAPTER.json`
- Modify: `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`

**Interfaces:**
- Consumes: v4.8 canonical adapter.
- Produces: cold-start routes that no longer promote mutable snapshots or Sheets to current authority.

- [ ] Route default startup through v4.8 canonical adapter → Active Context → current JSON/GitHub/Notion → domain owner.
- [ ] Remove `current_sheet_authority` and `USER_FACING_GDD_WORKSPACE` from active/current semantics; keep Sheet ID/tabs only as migration locators.
- [ ] Do not default-load legacy project Skill registry; retain it as compatibility-only.
- [ ] Remove mutable PR/SHA/stage/next-package duplication from stable routers and README.

### Task 4: GREEN — governance/freshness regression

**Files:**
- Modify: `tests/test_current_discovery_contract.py`
- Modify: `tests/test_project_governance.py`
- Modify: `tests/test_development_gates_stable_contract.py`
- Modify: `tests/test_bca_visual_sheet_adoption.py`
- Modify: `.github/reference-freshness.json`

**Interfaces:**
- Consumes: corrected current consumers.
- Produces: tests/config that forbid regression to Sheet-current or stale mutable snapshots.

- [ ] Replace positive assertions for `GOOGLE_SHEET_00_02_04_99` with negative assertions and Notion/GitHub authority markers.
- [ ] Require stable routers to omit mutable state keys and old current Decision ID.
- [ ] Retain historical baseline/SHA checks only in explicitly historical artifacts.
- [ ] Make Sheet adoption test assert migration-only compatibility rather than user-facing current workspace.

### Task 5: Verify, review, merge, readback

**Files:** no product files.

**Interfaces:**
- Consumes: exact PR head.
- Produces: verified merge + postmerge authority/readback evidence.

- [ ] Inspect PR diff and confirm protected product paths untouched.
- [ ] Run/observe exact-head PR validation and required checks.
- [ ] Run five full adversarial review loops on the resulting branch state; fix only validated current-scope findings.
- [ ] Confirm unresolved review threads = 0 and head is still exact.
- [ ] Squash merge current-task PR.
- [ ] Refetch new `main`, canonical contract, cold-start route, Active Context, and Notion Home/Core System/Production pages.
- [ ] Record the accidental direct-main probe incident and prevention rule in the project learning surface if not already covered by the design note.
- [ ] Recalculate required work; completion requires zero actionable current-scope work and no new blocking finding.
