# Star7/Star9 Mastery Budget Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Approve and validate a 7-star fixed +10-tick mastery allowance and a branchless 9-star allowance of `10 + floor(20% of the 7-star final budget)` without defining the six individual effects.

**Architecture:** Add a current planning overlay contract that reads the effective Technique2 budgets from the existing action repricing authority. A deterministic Python checker recalculates every allowance, enforces the no-branch single-effect template, and verifies planning-only scope. Canonical documents and the linked Sheet move to the 10/10 checkpoint under the same Decision ID.

**Tech Stack:** Markdown, JSON, Python 3.12 `unittest`, GitHub Actions, Google Sheets connector.

## Global Constraints

- Decision ID: `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01`.
- 7-star formula: `effective_existing_budget_ticks + 10`.
- 9-star bonus formula: `10 + floor(star7_final_budget_ticks * 0.20)`.
- Percentage rounding: `FLOOR_TO_INTEGER_TICKS`.
- Exactly one 9-star effect per Technique2; no branches, additional input, additional resource cost, or stacked bonus effects.
- Individual 7-star allocations and individual 9-star effects remain pending separate GrillMe Decisions.
- Product code, Godot scenes, HTML PoC, and runtime data remain unchanged.
- Runtime, Godot, Windows, accessibility, performance, human, and balance validation remain `NOT_RUN`.

---

### Task 1: RED mastery-budget contract regression

**Files:**
- Create: `tests/test_star7_star9_mastery_bonus_contract.py`
- Create: `docs/superpowers/specs/2026-08-05-star7-star9-mastery-budget-design.md`
- Create: `docs/superpowers/plans/2026-08-05-star7-star9-mastery-budget.md`

**Interfaces:**
- Consumes: effective Technique2 actions from `approved_20260804_existing_action_reprice_contract.json`.
- Produces: failing assertions for the missing approved contract, checker, Decision, and 10/10 operating state.

- [ ] **Step 1: Write the failing contract tests**

Assert the exact six source budgets, formulas, rounded totals, simplicity flags, pending allocation statuses, and current operating-state tokens.

- [ ] **Step 2: Commit only tests and approved design documents**

```bash
git commit -m "test: define star7 and star9 mastery budget contract"
```

- [ ] **Step 3: Verify RED in GitHub Actions**

Expected: the new test fails because `approved_20260805_star7_star9_mastery_bonus_contract.json` and `check_star7_star9_mastery_bonus_contract.py` do not exist and Active Context remains 9/10.

### Task 2: GREEN approved contract and checker

**Files:**
- Create: `docs/planning-data/approved_20260805_star7_star9_mastery_bonus_contract.json`
- Create: `tools/check_star7_star9_mastery_bonus_contract.py`
- Create: `docs/decisions/2026-08-05_STAR7_STAR9_MASTERY_BONUS_DECISION.md`
- Create: `docs/02_COMBAT_RULES_STAR7_STAR9_MASTERY_BONUS_AMENDMENT.md`
- Create: `.github/workflows/star7-star9-mastery-bonus-validation.yml`

**Interfaces:**
- Consumes: `actions[].available_budget_ticks` for `category == technique_2`.
- Produces: `STAR7_STAR9_MASTERY_BONUS_CONTRACT_PASS` or a stable conflict code.

- [ ] **Step 1: Add the approved JSON contract**

Include exact source budgets `{65,65,66,75,61,96}`, 7-star finals `{75,75,76,85,71,106}`, 9-star bonuses `{25,25,25,27,24,31}`, and total budgets `{100,100,101,112,95,137}`.

- [ ] **Step 2: Add deterministic validation**

The checker must independently load the repricing contract and reject:

```text
MASTERY_METADATA_CONFLICT
MASTERY_SOURCE_CONFLICT
STAR7_BONUS_CONFLICT
STAR9_FORMULA_CONFLICT
STAR9_SIMPLICITY_CONFLICT
ROLE_NONREPLACEMENT_CONFLICT
MASTERY_ALLOCATION_SCOPE_CONFLICT
MASTERY_SCOPE_CONFLICT
```

- [ ] **Step 3: Add Decision, amendment, and dedicated workflow**

The documents must explain value-superiority/role-nonreplacement and retain `PLANNING_ONLY` authority.

### Task 3: REFACTOR current-state ownership and canon

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`
- Modify: `docs/01_GAME_DESIGN.md`
- Modify: `tools/check_postmerge_canon_lifecycle.py`
- Modify: `tests/test_grade_farming_guardrails_contract.py`
- Modify: `.github/workflows/documentation-governance.yml`

**Interfaces:**
- Consumes: approved mastery contract metadata.
- Produces: one shared current state: `10/10`, `APPROVED_DRAFT_STAR7_STAR9_MASTERY_BONUS`, next `SIX_STAR7_MASTERY_BONUS_ALLOCATIONS`.

- [ ] **Step 1: Remove future-state ownership from the older grade test**

Retain grade-contract assertions but do not require the repository to remain at 9/10.

- [ ] **Step 2: Update operating-state validation**

Keep the 2026-08-04 audit contract as historical evidence while validating the current 10/10 checkpoint independently.

- [ ] **Step 3: Replace automatic-branch language**

Canonical current documents must say “single completion bonus” and must not require public triggers or priority branches.

- [ ] **Step 4: Add new checks to PR Validation**

```yaml
- run: python -m unittest tests.test_star7_star9_mastery_bonus_contract -v
- run: python tools/check_star7_star9_mastery_bonus_contract.py
```

### Task 4: GitHub and Sheet synchronization

**Files:**
- Update: PR #92 title/body
- Update Sheet tabs: `00`, `01`, `02`, `04`, `12`, `15`, `40`, `41`, `99`

**Interfaces:**
- Consumes: final exact-head SHA and Decision ID.
- Produces: matching GitHub/Sheet authority records and readback evidence.

- [ ] **Step 1: Write the final exact SHA and Decision ID to all target tabs**

Keep `99_변경이력` at eight columns.

- [ ] **Step 2: Read back the exact ranges**

Verify every tab contains `TEN-DEC-20260805-STAR7-STAR9-MASTERY-BONUS-01` and the same SHA.

- [ ] **Step 3: Update PR #92 without merging**

Record the 10/10 checkpoint, formulas, deferred individual allocations, scope, and stacked lineage.

### Task 5: Exact-head verification

**Files:**
- Verify only; no new product files.

**Interfaces:**
- Consumes: final head SHA.
- Produces: automated evidence separated from runtime/human evidence.

- [ ] **Step 1: Verify all exact-head workflows**

Required successful workflows: PR Validation, Full Validation, Base v9, Technique1, Wrong-Plan, Observation, Grade Farming, and Star7/Star9 Mastery Bonus.

- [ ] **Step 2: Verify changed-file boundary**

Confirm no changes under product code, Godot scene, HTML PoC, or runtime data paths.

- [ ] **Step 3: Stop at the 10/10 checkpoint**

Do not begin the six 7-star allocations or six 9-star effects without a new approval batch.
