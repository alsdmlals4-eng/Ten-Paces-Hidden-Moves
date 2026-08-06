# Wrong-Plan Rescue and Derived Stats Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a machine-validated planning contract that links the five core stats to attack, defense, health, stamina, and internal-energy derivatives while measuring whether high stats erase wrong-plan consequences.

**Architecture:** Add one approved JSON contract as the sole authority for derived-stat formulas and counterfactual rescue classification. A focused Python validator reads that contract plus existing stat authorities, rejects structural stat scaling and legacy `attack_power` double scaling, and exposes deterministic helper functions used by regression tests. Canon documents and lifecycle records point to the new overlay without changing product runtime data.

**Tech Stack:** JSON planning contracts, Python 3 standard library, `unittest`, GitHub Actions YAML, Markdown canon documents.

## Global Constraints

- Parent branch is PR #91 exact head `ffdbd385abb75b0f314400601c7a3120acc616e9`.
- Decision ID is `TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01`.
- Core stats remain uncapped; legacy `1..15` remains a validation band, not a hard cap.
- Reference stat is `4`.
- `max_health = 26 + constitution`.
- `max_stamina = 4 + floor(agility / 4)`.
- `max_internal = 3 + floor(internal_power / 4)`.
- Increasing a maximum never fills current health, stamina, or internal energy.
- Range, movement distance, action slots, hit count, evade count, targeting permission, sure-hit, and hidden-plan access never scale continuously per stat point.
- Stat modifiers apply only after legality, distance/order/movement/interruption, and success gates.
- Legacy HUD `attack_power: 8` is historical PoC data and must not be added to stat-scaled formulas.
- Product code, Godot scenes, HTML PoC, and runtime data remain unchanged.
- Human, balance, Godot, Windows, accessibility, and performance validation remain `NOT_RUN`.

---

### Task 1: RED regression contract

**Files:**
- Create: `tests/test_wrong_plan_rescue_derived_stats_contract.py`
- Modify: `.github/workflows/documentation-governance.yml`

**Interfaces:**
- Consumes: future `tools/check_wrong_plan_rescue_derived_stats_contract.py` CLI.
- Produces: mutation-based regression coverage for formulas, normalization, rescue exclusivity, forbidden structural scaling, and legacy attack-power double scaling.

- [ ] **Step 1: Write the failing regression test**

```python
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "docs/planning-data/approved_20260805_wrong_plan_rescue_derived_stats_contract.json"
CHECKER = ROOT / "tools/check_wrong_plan_rescue_derived_stats_contract.py"


class WrongPlanRescueDerivedStatsContractTest(unittest.TestCase):
    def run_checker(self, contract_path: Path = CONTRACT) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(CHECKER), "--contract", str(contract_path)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

    def mutate(self, edit):
        data = json.loads(CONTRACT.read_text(encoding="utf-8"))
        edit(data)
        temp = tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8")
        json.dump(data, temp, ensure_ascii=False, indent=2)
        temp.write("\n")
        temp.close()
        return Path(temp.name)

    def test_approved_contract_passes(self):
        result = self.run_checker()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_reference_values_are_30_5_4(self):
        data = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(data["reference_outputs"], {"max_health": 30, "max_stamina": 5, "max_internal": 4})

    def test_rejects_continuous_range_scaling(self):
        mutated = self.mutate(lambda d: d["forbidden_continuous_structural_scaling"].remove("ATTACK_RANGE"))
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("ATTACK_RANGE", result.stdout + result.stderr)

    def test_rejects_current_resource_fill_on_max_growth(self):
        mutated = self.mutate(lambda d: d["max_change_policy"].update({"fill_current_on_max_increase": True}))
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("fill_current", result.stdout + result.stderr)

    def test_rejects_legacy_attack_power_double_scaling(self):
        mutated = self.mutate(lambda d: d["legacy_attack_power"].update({"may_add_to_stat_scaled_actions": True}))
        result = self.run_checker(mutated)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("DOUBLE_SCALING_CONFLICT", result.stdout + result.stderr)

    def test_outcome_reversal_and_major_rescue_are_exclusive(self):
        data = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertTrue(data["rescue_classification"]["outcome_reversal_precedes_major_rescue"])
        self.assertFalse(data["rescue_classification"]["allow_double_count"])

    def test_normalization_preserves_missing_and_spent_amounts(self):
        data = json.loads(CONTRACT.read_text(encoding="utf-8"))
        self.assertEqual(data["counterfactual_normalization"]["health"], "clamp(reference_max_health - missing_health, 0, reference_max_health)")
        self.assertEqual(data["counterfactual_normalization"]["stamina"], "clamp(reference_max_stamina - spent_stamina, 0, reference_max_stamina)")
        self.assertEqual(data["counterfactual_normalization"]["internal"], "clamp(reference_max_internal - spent_internal, 0, reference_max_internal)")
```

- [ ] **Step 2: Connect the test to PR Validation**

Add this command after the existing governance regressions:

```yaml
- name: Validate wrong-plan rescue and derived stats contract
  run: python -m unittest tests.test_wrong_plan_rescue_derived_stats_contract -v
```

- [ ] **Step 3: Run RED verification**

Run:

```bash
python -m unittest tests.test_wrong_plan_rescue_derived_stats_contract -v
```

Expected: FAIL because the approved contract and checker do not exist.

- [ ] **Step 4: Commit RED**

```bash
git add tests/test_wrong_plan_rescue_derived_stats_contract.py .github/workflows/documentation-governance.yml
git commit -m "test: define wrong-plan rescue derived stat contract"
```

### Task 2: GREEN approved contract and validator

**Files:**
- Create: `docs/planning-data/approved_20260805_wrong_plan_rescue_derived_stats_contract.json`
- Create: `tools/check_wrong_plan_rescue_derived_stats_contract.py`

**Interfaces:**
- Consumes: `approved_20260803_uncapped_core_stats_contract.json`, `approved_20260802_stat_reference_price_base4_contract.json`, `approved_20260802_basic_attack_formulas_slot_budget_contract.json`.
- Produces: `validate_contract(contract: dict) -> list[str]`, `max_health(stat: int) -> int`, `max_stamina(stat: int) -> int`, `max_internal(stat: int) -> int`, `normalize_pool(actual_max: int, actual_current: int, reference_max: int) -> int`, `classify_rescue(reference: dict, actual: dict) -> str`.

- [ ] **Step 1: Create the approved contract**

The JSON must contain these exact top-level sections:

```json
{
  "schema_version": 1,
  "decision_id": "TEN-DEC-20260805-WRONG-PLAN-RESCUE-DERIVED-STATS-01",
  "authority_status": "CURRENT_APPROVED_PLANNING_GOVERNANCE",
  "reference_stat": 4,
  "derived_stats": {
    "external_power": {"continuous_outputs": ["EXTERNAL_DAMAGE", "DECLARED_DEFENSE_BREAK"]},
    "constitution": {"continuous_outputs": ["DECLARED_DEFENSE_EFFECT", "MAX_HEALTH"], "max_health_formula": "26 + constitution"},
    "agility": {"continuous_outputs": ["DECLARED_AGILITY_NUMERIC_EFFECT"], "max_stamina_formula": "4 + floor(agility / 4)"},
    "internal_power": {"continuous_outputs": ["INTERNAL_DAMAGE", "DECLARED_HEAL", "DECLARED_GUARD", "DECLARED_STABILIZATION"], "max_internal_formula": "3 + floor(internal_power / 4)"},
    "insight": {"continuous_outputs": ["DECLARED_CLASH_POWER", "DECLARED_PUBLIC_READ_SUCCESS_REWARD"]}
  },
  "reference_outputs": {"max_health": 30, "max_stamina": 5, "max_internal": 4},
  "forbidden_continuous_structural_scaling": ["MOVE_DISTANCE", "ATTACK_RANGE", "ACTION_SLOTS", "HIT_COUNT", "EVADE_COUNT", "TARGETING_PERMISSION", "SURE_HIT", "HIDDEN_PLAN_ACCESS"],
  "max_change_policy": {"fill_current_on_max_increase": false, "preserve_missing_or_spent_amount": true},
  "resolution_order": ["LEGALITY", "DISTANCE_ORDER_MOVEMENT_INTERRUPTION", "SUCCESS_GATES", "STAT_NUMERIC_ADJUSTMENT", "COUNTERFACTUAL_REPLAY", "RESCUE_CLASSIFICATION"],
  "counterfactual_normalization": {
    "health": "clamp(reference_max_health - missing_health, 0, reference_max_health)",
    "stamina": "clamp(reference_max_stamina - spent_stamina, 0, reference_max_stamina)",
    "internal": "clamp(reference_max_internal - spent_internal, 0, reference_max_internal)"
  },
  "rescue_classification": {
    "outcome_reversal_precedes_major_rescue": true,
    "allow_double_count": false,
    "major_health_loss_reduction_ratio": 0.5,
    "major_severity_step_reduction": 2,
    "severity_scale": [0, 1, 2, 3, 4]
  },
  "legacy_attack_power": {
    "field": "data/combat/combat_hud_preview.json#player.attack_power",
    "lifecycle": "SUPERSEDED_HISTORICAL_POC_FIELD",
    "may_add_to_stat_scaled_actions": false,
    "conflict_code": "DOUBLE_SCALING_CONFLICT"
  }
}
```

- [ ] **Step 2: Implement deterministic helpers and contract validation**

```python
def max_health(constitution: int) -> int:
    return 26 + constitution


def max_stamina(agility: int) -> int:
    return 4 + agility // 4


def max_internal(internal_power: int) -> int:
    return 3 + internal_power // 4


def normalize_pool(actual_max: int, actual_current: int, reference_max: int) -> int:
    spent = actual_max - actual_current
    return max(0, min(reference_max, reference_max - spent))


def classify_rescue(reference: dict, actual: dict) -> str:
    if reference["outcome"] in {"FAILURE", "DEFEAT", "DEATH"} and actual["outcome"] in {"SUCCESS", "VICTORY", "SURVIVAL"}:
        return "OUTCOME_REVERSAL"
    reference_loss = max(0, reference.get("health_loss", 0))
    actual_loss = max(0, actual.get("health_loss", 0))
    loss_reduction = 0.0 if reference_loss == 0 else (reference_loss - actual_loss) / reference_loss
    severity_reduction = reference.get("severity", 0) - actual.get("severity", 0)
    if loss_reduction >= 0.5 or severity_reduction >= 2:
        return "MAJOR_RESCUE"
    return "NO_RESCUE"
```

The validator must also load the three parent authorities and reject a reference stat other than `4`, a hard cap reintroduced into the uncapped-stat authority, missing structural guardrails, or any legacy attack-power permission.

- [ ] **Step 3: Run GREEN tests**

```bash
python -m unittest tests.test_wrong_plan_rescue_derived_stats_contract -v
python tools/check_wrong_plan_rescue_derived_stats_contract.py
```

Expected: all tests PASS and checker exits `0`.

- [ ] **Step 4: Refactor diagnostics**

Return one stable line per error using these codes:

```text
DERIVED_STAT_FORMULA_CONFLICT
STRUCTURAL_SCALING_CONFLICT
CURRENT_RESOURCE_FILL_CONFLICT
DOUBLE_SCALING_CONFLICT
COUNTERFACTUAL_NORMALIZATION_CONFLICT
RESCUE_CLASSIFICATION_CONFLICT
PARENT_AUTHORITY_CONFLICT
```

- [ ] **Step 5: Commit GREEN**

```bash
git add docs/planning-data/approved_20260805_wrong_plan_rescue_derived_stats_contract.json tools/check_wrong_plan_rescue_derived_stats_contract.py
git commit -m "feat: validate wrong-plan rescue derived stats"
```

### Task 3: Canon Decision and lifecycle overlay

**Files:**
- Create: `docs/decisions/2026-08-05_WRONG_PLAN_RESCUE_DERIVED_STATS_DECISION.md`
- Create: `docs/02_COMBAT_RULES_DERIVED_STATS_AND_RESCUE_AMENDMENT.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`

**Interfaces:**
- Consumes: approved contract and PR #91 authorities.
- Produces: current canon pointer, explicit partial supersession of legacy HUD `attack_power`, and next decision `OBSERVATION_ANSWER_LEAK_RISK`.

- [ ] **Step 1: Write the Decision**

Document these conclusions exactly:

```text
CURRENT: five core stats and approved derived formulas
CURRENT: outcome reversal and major rescue as separate, non-overlapping metrics
CURRENT: stat adjustment only after structural success gates
SUPERSEDED FIELD: combat_hud_preview attack_power: 8 as formula authority
UNCHANGED: uncapped core stats, reference stat4 pricing, existing technique coefficients
NOT IMPLEMENTED: product runtime
```

- [ ] **Step 2: Write the combat-rule amendment**

Include formula tables for stat values `1, 4, 8, 12, 15, 20`:

```text
constitution health: 27, 30, 34, 38, 41, 46
agility stamina: 4, 5, 6, 7, 7, 9
internal maximum: 3, 4, 5, 6, 6, 8
```

Clarify that threshold jumps at `4, 8, 12, 16, 20...` continue because stats are uncapped.

- [ ] **Step 3: Update lifecycle and checkpoints**

Set:

```yaml
active_planning_pr: 92
active_planning_parent_pr: 91
active_decision_state: APPROVED_DRAFT_WRONG_PLAN_RESCUE_DERIVED_STATS
next_planning_decision: OBSERVATION_ANSWER_LEAK_RISK
planning_checkpoint: DRAFT_PR92_WRONG_PLAN_RESCUE_DERIVED_STATS
```

Add PR #92 to the lineage and list `combat_hud_preview.json attack_power` under `[대체됨]` as a formula authority only; the file itself remains historical runtime evidence.

- [ ] **Step 4: Run canon regressions**

```bash
python -m unittest tests.test_postmerge_canon_lifecycle -v
python -m unittest tests.test_wrong_plan_rescue_derived_stats_contract -v
```

Expected: PASS with Active Context and Roadmap synchronized.

- [ ] **Step 5: Commit canon**

```bash
git add docs/decisions/2026-08-05_WRONG_PLAN_RESCUE_DERIVED_STATS_DECISION.md docs/02_COMBAT_RULES_DERIVED_STATS_AND_RESCUE_AMENDMENT.md docs/CANON_LIFECYCLE_REGISTRY.md "[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md" docs/04_ROADMAP.md
git commit -m "docs: adopt derived stats and rescue canon"
```

### Task 4: Dedicated exact-head validation

**Files:**
- Create: `.github/workflows/wrong-plan-rescue-derived-stats-validation.yml`

**Interfaces:**
- Consumes: checker, contract, tests.
- Produces: named exact-head CI proof.

- [ ] **Step 1: Add the workflow**

```yaml
name: Validate Wrong-Plan Rescue Derived Stats
on:
  pull_request:
    paths:
      - "docs/planning-data/approved_20260805_wrong_plan_rescue_derived_stats_contract.json"
      - "tools/check_wrong_plan_rescue_derived_stats_contract.py"
      - "tests/test_wrong_plan_rescue_derived_stats_contract.py"
      - "docs/decisions/2026-08-05_WRONG_PLAN_RESCUE_DERIVED_STATS_DECISION.md"
      - "docs/02_COMBAT_RULES_DERIVED_STATS_AND_RESCUE_AMENDMENT.md"
      - ".github/workflows/wrong-plan-rescue-derived-stats-validation.yml"
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: python -m unittest tests.test_wrong_plan_rescue_derived_stats_contract -v
      - run: python tools/check_wrong_plan_rescue_derived_stats_contract.py
```

- [ ] **Step 2: Commit the workflow**

```bash
git add .github/workflows/wrong-plan-rescue-derived-stats-validation.yml
git commit -m "ci: validate wrong-plan rescue derived stats"
```

### Task 5: PR review, exact-head verification, and Sheet sync

**Files:**
- Modify: PR #92 body.
- Modify: Google Sheet tabs `00`, `01`, `02`, `04`, `12`, `15`, `40`, `41`, `99`.

**Interfaces:**
- Consumes: final PR #92 SHA and all CI conclusions.
- Produces: synchronized GitHub and Sheet checkpoint using the same Decision ID and exact head.

- [ ] **Step 1: Verify exact head**

Confirm all are successful:

```text
PR Validation
Full Validation
Validate Base v9 adoption
Validate Technique1 conditional Star5
Validate Wrong-Plan Rescue Derived Stats
```

- [ ] **Step 2: Adversarial PR check**

Verify:

```text
review_threads = 0
comments = 0
mergeable = true
base = PR #91 branch
product runtime files changed = false
```

- [ ] **Step 3: Synchronize the Sheet**

Append the Decision, formulas, rescue KPIs, superseded legacy attack-power field, validation boundary, and next risk using the exact PR #92 SHA. Do not overwrite historical rows.

- [ ] **Step 4: Read back every written range**

Confirm the Decision ID and SHA match GitHub exactly.

- [ ] **Step 5: Update the PR body**

Record TDD evidence, changed files, CI conclusions, Sheet readback, lifecycle status, and `OBSERVATION_ANSWER_LEAK_RISK` as the next Gate.

- [ ] **Step 6: Final verification**

Re-fetch PR metadata and exact-head workflow runs after the last commit. Do not report completion if any workflow is pending or failed.
