# Technique1 Conditional Rework and Star5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Canonicalize the approved low-floor/high-ceiling redesign of all six 3-star Technique1 actions and their free 5-star patches.

**Architecture:** Preserve the effective slots and costs owned by the 2026-08-04 repricing overlay. Add a new approved effect-and-milestone overlay contract that supersedes the old Technique1 effect fields, plus a focused validator and regression tests. Historical decisions remain evidence but are marked superseded for current effect authority.

**Tech Stack:** Markdown decisions, JSON planning contracts, Python 3.12 validators and unittest, GitHub Actions, Google Sheets canonical planning mirror.

## Global Constraints

- Decision ID: `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`.
- Exactly six canonical Technique1 IDs.
- Existing effective slots and resource costs are inherited unchanged from `approved_20260804_existing_action_reprice_contract.json`.
- Conditional failure grants zero attached reward and cannot carry, substitute, convert, or partially pay out.
- Multi-hit damage is calculated once, then split 40% / 30% / remainder.
- 5-star patch budget is `round(available_budget_ticks * 0.20)` with no new slot or resource cost.
- Condition bundle pricing is rounded once after multiplying by one composite coefficient.
- Product runtime, HTML PoC, Godot scenes, and runtime game data remain unchanged.

---

### Task 1: Add failing contract tests

**Files:**
- Create: `tests/test_technique1_conditional_star5_contract.py`

**Interfaces:**
- Consumes: planned contract path and validator module path.
- Produces: exact expected six-technique table and mutation regressions.

- [ ] **Step 1: Write tests before implementation**

Tests must assert:

```python
EXPECTED = {
    "flowing_cloud_triple": (58, 61, -3, 12, 11, -1),
    "vajra_guard": (31, 31, 0, 6, 5, -1),
    "cloud_hand_return": (38, 40, -2, 8, 7, -1),
    "pursuing_wind_thrust": (50, 45, 5, 9, 9, 0),
    "clear_heart_breath": (22, 24, -2, 5, 5, 0),
    "iron_step_drift": (48, 46, 2, 9, 8, -1),
}
```

Also assert that the validator rejects:

```python
partial_reward_on_condition_failure = True
multi_hit_damage_calculated_per_hit = True
self_created_prerequisite_credit_allowed = True
star5_patch_budget_ticks += 1
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
python -m unittest tests.test_technique1_conditional_star5_contract -v
```

Expected result: import or file-not-found failure because the validator and contract do not exist.

- [ ] **Step 3: Commit the RED test**

```bash
git add tests/test_technique1_conditional_star5_contract.py
git commit -m "test: require conditional technique1 star5 contract"
```

### Task 2: Add the approved contract and validator

**Files:**
- Create: `docs/planning-data/approved_20260804_technique1_conditional_rework_star5_contract.json`
- Create: `tools/check_technique1_conditional_star5_contract.py`

**Interfaces:**
- Consumes: repricing overlay effective costs and approved design values.
- Produces: `validate(data)` and command-line validation.

- [ ] **Step 1: Write the approved JSON contract**

The contract must contain:

```json
{
  "decision_id": "TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01",
  "condition_coefficients": {
    "easy": 0.85,
    "moderate": 0.70,
    "hard": 0.55,
    "very_hard": 0.40,
    "extreme": 0.25
  },
  "star5_bonus_ratio": 0.20,
  "conditional_bundle_all_or_nothing": true,
  "self_created_prerequisite_credit_allowed": false,
  "multi_hit_damage_calculated_once": true
}
```

Each technique must include effective slots/costs, base floor, conditional ceiling, trigger, coefficient, raw bundle ticks, priced bundle ticks, base effect cost, available budget, variance, 5-star patch budget, patch raw ticks, patch coefficient, patch priced ticks, and patch variance.

- [ ] **Step 2: Implement `validate(data)`**

The validator must:

```python
class Technique1ContractError(ValueError):
    pass


def validate(data: dict) -> None:
    ...
```

It must recalculate all budgets and variances, enforce exact canonical IDs, verify inherited costs, verify 20% patch budgets, reject partial/carryover/substitution flags, and verify the Flowing Cloud total-damage split at total14 and total17.

- [ ] **Step 3: Run focused tests and direct validation**

```bash
python -m unittest tests.test_technique1_conditional_star5_contract -v
python tools/check_technique1_conditional_star5_contract.py
```

Expected: all tests PASS and command exits 0.

- [ ] **Step 4: Commit GREEN implementation**

```bash
git add docs/planning-data/approved_20260804_technique1_conditional_rework_star5_contract.json tools/check_technique1_conditional_star5_contract.py
git commit -m "feat: approve conditional technique1 star5 contract"
```

### Task 3: Update canonical decisions and planning authority

**Files:**
- Create: `docs/decisions/2026-08-04_TECHNIQUE1_CONDITIONAL_REWORK_STAR5_DECISION.md`
- Modify: `docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md`
- Modify: `docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `ACTIVE_CONTEXT.md`
- Modify: `docs/planning-data/poc_balance_budget.json`

**Interfaces:**
- Consumes: approved overlay contract.
- Produces: one current effect authority and one historical superseded authority.

- [ ] **Step 1: Add the new Decision**

Document the exact six base designs, the 5-star patches, condition pricing table, all-or-nothing trigger rules, total-damage-first multi-hit rule, validation boundaries, and next GrillMe item.

- [ ] **Step 2: Mark the old Technique1 effect authority superseded**

Change its status to `SUPERSEDED` and point to `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`. Preserve all historical tables as evidence.

- [ ] **Step 3: Synchronize active canonical documents**

Update active context, combat rules, mastery data, roadmap, and central balance JSON so they reference the new Decision and contract. Set the next GrillMe item to `INDIVIDUAL_STAR_9_READ_BASED_BRANCHES` and active count to `7/10`.

- [ ] **Step 4: Run all relevant repository checks**

```bash
python -m unittest tests.test_technique1_conditional_star5_contract -v
python tools/check_technique1_conditional_star5_contract.py
python -m unittest tests.test_poc_planning_data -v
python tests/check_canonical_combat_docs.py
```

Expected: zero failures.

- [ ] **Step 5: Commit canonical documentation**

```bash
git add docs ACTIVE_CONTEXT.md
git commit -m "docs: canonicalize conditional technique1 star5 redesign"
```

### Task 4: Add CI, publish stacked PR, and mirror the Sheet

**Files:**
- Create: `.github/workflows/technique1-conditional-star5-validation.yml`

**Interfaces:**
- Consumes: exact branch head.
- Produces: dedicated GitHub Actions evidence and mirrored Sheet Decision rows.

- [ ] **Step 1: Add a dedicated workflow**

The workflow runs:

```bash
python -m unittest tests.test_technique1_conditional_star5_contract -v
python tools/check_technique1_conditional_star5_contract.py
```

- [ ] **Step 2: Open a stacked Draft PR**

Head:

```text
agent/2026-08-04-technique1-conditional-star5-rework
```

Base:

```text
agent/2026-08-04-combat-economy-authority-sync
```

- [ ] **Step 3: Verify all workflows on exact head**

Required conclusions:

```text
PR Validation: success
Full Validation: success
Validate Base v9 adoption: success
Validate approved action repricing: success
Validate Technique1 conditional Star5: success
```

- [ ] **Step 4: Update Google Sheet with the same Decision ID**

Update project hub, work order, current decisions, audit, core loop, game rules, main systems, and change history. Record exact head, PR number, CI evidence, runtime NOT_RUN boundary, and next GrillMe item.

- [ ] **Step 5: Read back all written ranges**

Confirm the exact Decision ID, six technique summary, 7/10 status, exact head, and next work are present without overwriting prior rows.
