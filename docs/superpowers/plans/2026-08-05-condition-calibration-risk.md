# Condition Calibration Risk Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a stable condition-difficulty calibration authority that preserves current technique values, defines valid-attempt measurement, prevents statistical abuse, and gates all future 9-star conditional branches.

**Architecture:** Keep the approved Technique1 contract as the effect and current five-coefficient parent authority. Add a focused condition-calibration overlay that adds the quasi-certain band, exact measurement denominators, failure taxonomy, warning/reclassification gates, and anti-gaming rules; validators load both contracts and reject drift or automatic repricing.

**Tech Stack:** Markdown canon documents, JSON approved planning contracts, Python 3.12 validators and `unittest`, GitHub Actions, Google Sheets planning mirror.

## Global Constraints

- Decision ID: `TEN-DEC-20260805-CONDITION-CALIBRATION-01`.
- Parent effect authority: `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`.
- Current six Technique1 effects, costs, slots, declared difficulties, and coefficients remain unchanged.
- Add `quasi_certain` success band `[0.85, 1.00]` with coefficient `1.00`.
- Reclassification uses valid-attempt success rate for rules-literate general players.
- Publicly impossible attempts are excluded from price calibration denominator and retained as misuse diagnostics.
- Hidden opponent counterplay failures remain valid failures.
- No automatic or live repricing.
- Product code, Godot, HTML PoC, and runtime data remain unchanged.
- Human, balance, Godot, Windows, accessibility, and performance validation remain `NOT_RUN`.

---

### Task 1: Add RED calibration regression tests

**Files:**
- Create: `tests/test_condition_calibration_contract.py`
- Create: `.github/workflows/condition-calibration-validation.yml`

**Interfaces:**
- Consumes: `docs/planning-data/approved_20260804_technique1_conditional_rework_star5_contract.json`.
- Produces: test expectations for `validate(parent, calibration)` and `difficulty_for_success_rate(rate)`.

- [ ] **Step 1: Write failing tests**

Create tests that require:

```python
EXPECTED_BANDS = [
    ("extreme", 0.00, 0.15, 0.25),
    ("very_hard", 0.15, 0.30, 0.40),
    ("hard", 0.30, 0.50, 0.55),
    ("moderate", 0.50, 0.70, 0.70),
    ("easy", 0.70, 0.85, 0.85),
    ("quasi_certain", 0.85, 1.00, 1.00),
]
```

Tests must reject:

```python
# quasi-certain receives a discount
broken["difficulty_bands"]["quasi_certain"]["coefficient"] = 0.95

# gap or overlap in rate coverage
broken["difficulty_bands"]["hard"]["max_exclusive"] = 0.49

# parent coefficient drift
broken_parent["condition_coefficients"]["hard"] = 0.50

# publicly impossible attempt counted in calibration denominator
broken["valid_attempt_contract"]["publicly_impossible_in_calibration_denominator"] = True

# hidden counterplay failure removed from denominator
broken["valid_attempt_contract"]["hidden_opponent_counterplay_failure_is_valid_failure"] = False

# automatic repricing enabled
broken["reclassification_contract"]["automatic_repricing"] = True

# warning/reclassification samples reduced
broken["warning_gate"]["min_valid_attempts"] = 10
broken["reclassification_gate"]["min_valid_attempts"] = 50

# failure taxonomy or anti-double-counting removed
broken["failure_taxonomy"] = []
broken["shared_trigger_counting"]["one_success_event_per_condition_group"] = False

# false human validation claim
broken["validation_boundary"]["human_validation"] = "PASS"
```

Positive tests must verify exact boundary classifications at `0`, `0.15`, `0.30`, `0.50`, `0.70`, `0.85`, and `1.00`.

- [ ] **Step 2: Add pull-request workflow**

Run:

```yaml
python -m unittest tests.test_condition_calibration_contract -v
python tools/check_condition_calibration_contract.py
```

- [ ] **Step 3: Open a stacked Draft PR and verify RED**

Base branch: `agent/2026-08-04-resource-saturation-internal-recovery`.

Expected failure: calibration validator or approved contract does not exist.

- [ ] **Step 4: Commit**

```bash
git add tests/test_condition_calibration_contract.py .github/workflows/condition-calibration-validation.yml
git commit -m "test: define condition calibration authority"
```

### Task 2: Implement approved contract and validator

**Files:**
- Create: `docs/planning-data/approved_20260805_condition_calibration_contract.json`
- Create: `tools/check_condition_calibration_contract.py`

**Interfaces:**
- Consumes: parent Technique1 condition coefficients and declared technique conditions.
- Produces: `validate(parent: dict, calibration: dict) -> None` and `difficulty_for_success_rate(rate: float) -> str`.

- [ ] **Step 1: Create calibration contract**

The contract must contain exact band boundaries and coefficients, cohort definition, overall-use and valid-attempt formulas, failure taxonomy, warning/reclassification gates, anti-gaming exclusions, current condition groups, required Star9 template fields, runtime boundary, and validation boundary.

- [ ] **Step 2: Implement validator**

The validator must:

```text
load parent Technique1 contract
→ verify existing five coefficients unchanged
→ verify six calibration bands cover 0..1 exactly
→ classify boundary rates deterministically
→ require valid-attempt and failure contracts
→ require current condition groups without changing their declarations
→ reject automatic repricing and false validation claims
```

- [ ] **Step 3: Run regression tests**

Run:

```bash
python -m unittest tests.test_condition_calibration_contract -v
python tools/check_condition_calibration_contract.py
```

Expected: all tests PASS and direct validation PASS.

- [ ] **Step 4: Commit**

```bash
git add docs/planning-data/approved_20260805_condition_calibration_contract.json tools/check_condition_calibration_contract.py
git commit -m "feat: approve condition calibration contract"
```

### Task 3: Synchronize canon and lifecycle

**Files:**
- Create: `docs/decisions/2026-08-05_CONDITION_CALIBRATION_DECISION.md`
- Modify: `docs/decisions/2026-08-04_TECHNIQUE1_CONDITIONAL_REWORK_STAR5_DECISION.md`
- Modify: `docs/planning-data/approved_20260804_technique1_conditional_rework_star5_contract.json`
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`

**Interfaces:**
- Consumes: approved calibration contract terminology.
- Produces: one unambiguous current condition-authoring and reclassification chain.

- [ ] **Step 1: Add Decision**

Document the six bands, valid-attempt denominator, failure taxonomy, warning/reclassification gates, anti-abuse rules, current-technique freeze, and Star9 required fields.

- [ ] **Step 2: Add parent amendment pointer**

Do not supersede the Technique1 effect contract. Add a pointer stating that future difficulty classification and reclassification governance are owned by `TEN-DEC-20260805-CONDITION-CALIBRATION-01`; existing six technique declarations remain unchanged.

- [ ] **Step 3: Update current canon surfaces**

The lifecycle registry must classify the new Decision and contract as `[현행]`. Active context and roadmap must place `CONDITION_CALIBRATION_RISK` before `STAR9_PUBLIC_READ_BRANCH_TEMPLATE` and mark it `MITIGATED_PENDING_HUMAN_MEASUREMENT` after approval.

- [ ] **Step 4: Connect new validator to PR Validation**

Run the new unit tests and direct validator whenever condition calibration, Technique1 condition authority, active context, roadmap, or lifecycle files change.

- [ ] **Step 5: Commit**

```bash
git add docs/decisions docs/planning-data docs/02_COMBAT_RULES.md docs/CANON_LIFECYCLE_REGISTRY.md "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md" docs/04_ROADMAP.md .github/workflows

git commit -m "docs: make condition difficulty evidence-calibrated"
```

### Task 4: PR review, Sheet sync, and completion evidence

**Files:**
- Modify: stacked Draft PR body
- Modify: Google Sheet tabs `00`, `01`, `02`, `04`, `12`, `15`, `40`, `41`, `99`

**Interfaces:**
- Consumes: exact PR head and CI results.
- Produces: synchronized authority evidence and next-risk pointer.

- [ ] **Step 1: Verify exact-head CI**

Require success for PR Validation, Full Validation, Base adoption, Technique1 validation, resource-saturation validation, post-merge lifecycle validation, and the new condition-calibration workflow.

- [ ] **Step 2: Perform adversarial PR review**

Verify:

- no existing technique value changed
- no band gaps or overlaps
- no duplicate shared-trigger success counting
- no automatic repricing path
- no publicly impossible attempts in price denominator
- no hidden-counterplay failures excluded
- no unresolved review comments or stale authority tokens

- [ ] **Step 3: Synchronize Google Sheet**

Use the same Decision ID and exact head. Record six bands, valid-attempt basis, warning `30/10/10%p`, reclassification `100/30`, risk state, unchanged current technique values, and next risk `WRONG_PLAN_RESCUE_RISK`.

- [ ] **Step 4: Read back all edited ranges**

Confirm exact Decision ID, SHA, state, band boundaries, gates, and validation boundary.

- [ ] **Step 5: Update PR body and keep Draft**

The stacked PR must not merge before PR #89. Product runtime remains unchanged.
