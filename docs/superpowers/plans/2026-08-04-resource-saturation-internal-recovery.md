# Resource Saturation Internal Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace bundle-transition internal recovery `1` with `0` while preserving stamina and ultimate-momentum recovery, explicit internal recovery actions, authority lineage, and measurable starvation guardrails.

**Architecture:** Keep the existing combat-pricing contract as the parent authority for interruption, preparation, pricing, and resource budgets. Add a focused approved overlay that owns only effective bundle-transition recovery and measurement requirements; validators load both contracts, apply the overlay, and reject direct use of the historical internal-recovery value.

**Tech Stack:** Markdown canon documents, JSON approved planning contracts, Python 3.12 validators and `unittest`, GitHub Actions, Google Sheets planning mirror.

## Global Constraints

- Decision ID: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`.
- Bundle-transition recovery must be stamina `1`, internal `0`, ultimate momentum `1`.
- No separate round-start internal recovery.
- Prepared meditation internal recovery remains `1`.
- Existing action costs, resource caps, and individual technique effects are unchanged.
- Product code, Godot scenes, HTML PoC, and runtime data remain unchanged.
- Human, balance, Windows, accessibility, and performance validation remain `NOT_RUN`.
- The old parent file remains current for unaffected sections; only `bundle_transition_recovery.internal: 1` is `[대체됨]`.

---

### Task 1: Add RED contract regression tests

**Files:**
- Create: `tests/test_resource_saturation_internal_recovery_contract.py`
- Create: `.github/workflows/resource-saturation-internal-recovery-validation.yml`

**Interfaces:**
- Consumes: parent contract `docs/planning-data/approved_20260804_combat_pricing_interruption_recovery_contract.json`.
- Produces: test expectations for `validate(parent, overlay)` and effective recovery calculation.

- [ ] **Step 1: Write failing tests**

Create seven tests that require:

```python
EXPECTED_EFFECTIVE_RECOVERY = {
    "stamina": 1,
    "internal": 0,
    "ultimate_momentum": 1,
}
```

Tests must reject:

```python
# 1. overlay internal recovery drift
broken["effective_bundle_transition_recovery"]["internal"] = 1

# 2. separate round-start internal recovery
broken["round_start_recovery"]["internal"] = 1

# 3. prepared meditation internal recovery removal
parent["prepare"]["prepared_meditation_gain"]["internal"] = 0

# 4. parent transition-list drift
parent["bundle_transition_recovery"]["transitions"].pop()

# 5. false human validation claim
broken["validation_boundary"]["human_validation"] = "PASS"

# 6. missing soft-lock fallback categories
broken["softlock_guard"]["legal_at_internal_zero"] = []
```

The positive test must call the validator and assert exact effective recovery.

- [ ] **Step 2: Add a pull-request workflow**

Run:

```yaml
python -m unittest tests.test_resource_saturation_internal_recovery_contract -v
python tools/check_resource_saturation_internal_recovery_contract.py
```

- [ ] **Step 3: Open a Draft PR and verify RED**

Expected failure: validator module or overlay contract does not exist.

- [ ] **Step 4: Commit**

```bash
git add tests/test_resource_saturation_internal_recovery_contract.py .github/workflows/resource-saturation-internal-recovery-validation.yml
git commit -m "test: define internal recovery saturation contract"
```

### Task 2: Implement approved overlay and validator

**Files:**
- Create: `docs/planning-data/approved_20260804_resource_saturation_internal_recovery_contract.json`
- Create: `tools/check_resource_saturation_internal_recovery_contract.py`

**Interfaces:**
- Consumes: parent combat-pricing contract.
- Produces: `validate(parent: dict, overlay: dict) -> None` and `effective_bundle_transition_recovery(parent, overlay) -> dict[str, int]`.

- [ ] **Step 1: Create the overlay contract**

Required fields:

```json
{
  "decision_id": "TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01",
  "authority_status": "CURRENT_APPROVED_PLANNING",
  "parent_decision_id": "TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01",
  "superseded_parent_fields": ["bundle_transition_recovery.internal"],
  "effective_bundle_transition_recovery": {
    "stamina": 1,
    "internal": 0,
    "ultimate_momentum": 1,
    "caps_apply": true,
    "before_enemy_plan_lock": true
  },
  "round_start_recovery": {"internal": 0},
  "explicit_internal_recovery_paths": [
    "PREPARED_MEDITATION",
    "CLEAR_HEART_BREATH",
    "APPROVED_CONDITIONAL_INTERNAL_RECOVERY",
    "FUTURE_SEPARATELY_APPROVED_EFFECT"
  ],
  "softlock_guard": {
    "legal_at_internal_zero": [
      "FREE_BASIC_ACTION",
      "MOVE",
      "PREPARE",
      "MEDITATE",
      "CLEAR_HEART_BREATH",
      "NO_INTERNAL_COST_ACTION"
    ]
  }
}
```

Include KPI definitions, `MITIGATED_PENDING_HUMAN_MEASUREMENT`, and all validation boundaries as `NOT_RUN`.

- [ ] **Step 2: Implement validator**

The validator must load the parent and overlay, preserve the exact transition list, ensure prepared meditation internal gain remains `1`, apply the overlay, reject round-start internal gain, require soft-lock paths and measurement fields, and reject any false validation claim.

- [ ] **Step 3: Run regression tests**

Run:

```bash
python -m unittest tests.test_resource_saturation_internal_recovery_contract -v
python tools/check_resource_saturation_internal_recovery_contract.py
```

Expected: seven tests PASS and direct validation PASS.

- [ ] **Step 4: Commit**

```bash
git add docs/planning-data/approved_20260804_resource_saturation_internal_recovery_contract.json tools/check_resource_saturation_internal_recovery_contract.py
git commit -m "feat: approve internal recovery saturation overlay"
```

### Task 3: Synchronize canon and lifecycle markers

**Files:**
- Create: `docs/decisions/2026-08-04_RESOURCE_SATURATION_INTERNAL_RECOVERY_DECISION.md`
- Modify: `docs/decisions/2026-08-04_COMBAT_PRICING_INTERRUPTION_RECOVERY_DECISION.md`
- Modify: `docs/planning-data/approved_20260804_combat_pricing_interruption_recovery_contract.json`
- Modify: `docs/02_COMBAT_RULES.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`

**Interfaces:**
- Consumes: approved overlay and validator terminology.
- Produces: one unambiguous current authority chain.

- [ ] **Step 1: Add Decision**

Document resource identities, effective recovery, explicit recovery paths, soft-lock guard, KPI definitions, unresolved starvation risk, and runtime boundary.

- [ ] **Step 2: Mark only the old field as superseded**

Add to the parent Decision and contract:

```text
[대체됨] bundle_transition_recovery.internal: 1
→ TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01
```

Do not mark the entire parent Decision superseded.

- [ ] **Step 3: Update current canon surfaces**

Current rules must state:

```yaml
stamina_gain: 1
internal_gain: 0
ultimate_momentum_gain: 1
```

The lifecycle registry must classify the old field as `[대체됨]`, the new overlay as `[현행]`, and direct use of parent internal recovery as `CANON_CONFLICT`.

- [ ] **Step 4: Run all relevant validators**

Run the new validator plus existing lifecycle, Technique1, approved-action repricing, and project governance checks available in CI.

- [ ] **Step 5: Commit**

```bash
git add docs/decisions docs/planning-data docs/02_COMBAT_RULES.md docs/CANON_LIFECYCLE_REGISTRY.md "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md" docs/04_ROADMAP.md
git commit -m "docs: make internal recovery an explicit planning choice"
```

### Task 4: PR review, Sheet sync, and completion evidence

**Files:**
- Modify: Draft PR body
- Modify: Google Sheet tabs `00`, `01`, `02`, `04`, `12`, `15`, `40`, `41`, `99`

**Interfaces:**
- Consumes: exact PR head and CI results.
- Produces: synchronized authority evidence and next-risk pointer.

- [ ] **Step 1: Verify exact-head CI**

Require success for PR Validation, Full Validation, Base adoption, Technique1 validation, post-merge lifecycle validation, and the new resource-saturation workflow.

- [ ] **Step 2: Perform PR review checks**

Verify mergeability, no unresolved review threads, no comments requiring action, no stale active-PR tokens, and no use of `[대체됨]` internal recovery as current.

- [ ] **Step 3: Synchronize Google Sheet**

Use the same Decision ID and exact head. Record `MITIGATED_PENDING_HUMAN_MEASUREMENT`, the recovery triple `1/0/1`, explicit internal recovery paths, KPI requirements, and `CONDITION_CALIBRATION_RISK` as the next risk.

- [ ] **Step 4: Read back all edited ranges**

Confirm exact Decision ID, SHA, state, recovery values, and validation boundary.

- [ ] **Step 5: Update PR body and keep Draft unless the user explicitly requests merge**

Include exact-head evidence and note that product runtime remains unchanged.
