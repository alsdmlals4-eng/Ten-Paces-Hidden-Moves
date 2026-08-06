# GUT 9.7.1 and HiGodot 3.1.2 Adoption Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans or superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Make GUT a real GDScript test consumer and HiGodot the explicit sole Godot authoring authority, with exact pins, CI evidence, export isolation, rollback and no product behavior change.

**Architecture:** HiGodot owns approved editor mutations; GUT owns headless GDScript tests and JUnit only; Python owns repository and canon contracts. All three feed exact-head PR validation without overlapping authority.

**Tech Stack:** Godot 4.7.1, HiGodot/Godot AI 3.1.2, GUT 9.7.1, GDScript, Python 3.12 unittest, GitHub Actions, JSON/Markdown canon.

---

### Task 1: Establish RED evidence

**Files:**
- Create: `tests/test_gut_higodot_adoption.py`
- Create: `tests/test_conflict_marker_detection.py`
- Create: `.github/workflows/validate-gut-higodot-adoption.yml`

- [x] Write missing-contract, missing-consumer, stale-entry and export-boundary tests.
- [x] Run PR CI and record run `31104521577`.
- [x] Add structural conflict-marker regression and record run `31104805445`.

### Task 2: Repair conflict-marker detection

**Files:**
- Modify: `tests/check_combat_board_contract.py`
- Test: `tests/test_conflict_marker_detection.py`

- [x] Add `find_conflict_markers` regression contract.
- [x] Ignore standalone Markdown heading underlines.
- [x] Continue failing on conflict starts, conflict ends and separators inside a conflict block.

### Task 3: Add exact adoption authority

**Files:**
- Create: `docs/decisions/2026-08-06_GUT_9_7_1_TEST_FRAMEWORK_ADOPTION_DECISION.md`
- Create: `docs/planning-data/approved_20260806_gut_higodot_test_authority_contract.json`
- Create: `docs/planning-data/HIGODOT_ADOPTION_RECORD.json`
- Create: `docs/superpowers/specs/2026-08-06-gut-higodot-coexistence-design.md`

- [x] Record GUT upstream commit, license, consumption path and rollback.
- [x] Record HiGodot exact release, hash, loopback policy and operation levels.
- [x] Set host and interactive validation to `UNVERIFIED/NOT_RUN` rather than overclaiming.

### Task 4: Add GUT runtime consumption

**Files:**
- Create: `.gutconfig.json`
- Create: `tests/gut/test_martial_manual_registry.gd`
- Modify: `.github/workflows/validate-gut-higodot-adoption.yml`

- [x] Configure `tests/gut` discovery and deterministic exit.
- [x] Test 10-manual registry load and 3/7/10-star unlock boundaries.
- [ ] Generate `build/test-results/gut.xml` on exact-head CI.
- [ ] Upload the JUnit artifact.

### Task 5: Enforce product and canon boundaries

**Files:**
- Modify: `export_presets.cfg`
- Modify: `START_HERE.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/planning-data/current_operating_state.json`
- Modify: `docs/04_ROADMAP.md`

- [ ] Exclude GUT config, addon and tests from product export.
- [ ] Replace stale PC-only entry text with current Windows+Android authority.
- [ ] Route active PR #104 and approval batch 2/10 without replacing the next product package.

### Task 6: Verify and synchronize

- [ ] Run focused adoption and conflict-marker tests.
- [ ] Run Godot 4.7.1 import and GUT suite.
- [ ] Confirm JUnit artifact exists.
- [ ] Confirm PR Validation, Full Validation and adjacent regressions pass on one exact head.
- [ ] Perform adversarial review and resolve P0/P1 findings.
- [ ] Mark the PR ready only after exact-head evidence is complete.
- [ ] Synchronize the approved Decision to Google Sheets as `APPROVED_PENDING_MERGE`, then use final main SHA after merge for `SYNCED_TO_MAIN`.

## Claim boundaries

Do not claim local Windows interactive HiGodot use, MCP host registration, physical input, Android runtime/device, accessibility-user, Release performance, human playtest or production readiness unless those checks are actually executed.
