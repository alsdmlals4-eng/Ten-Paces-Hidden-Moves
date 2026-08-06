# Ten Recognizable Martial Manuals Full Growth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Promote the approved ten-manual roster, 3·5·7·9·10-star growth packages, faction identities, stat-fit assignments, special resolution rules, and planning budgets into deterministic GitHub and Google Sheet authority without changing product runtime code.

**Architecture:** Add one semantic authority contract keyed by ten stable manual IDs and one budget overlay contract. Deterministic Python checkers validate faction/name/stat fit, stage completeness, role nonreplacement, resolution order, once-per-battle and Tenacity rules, legacy aliases, budget formulas, and planning-only scope. Canon documents, the player-readable catalog, PR #92, and the linked Sheet synchronize only after exact-head tests pass.

**Tech Stack:** Markdown, JSON, Python 3.12 `unittest`, GitHub Actions, GitHub connector, Google Sheets connector.

## Global Constraints

- Decision ID: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`.
- Active approval batch: `9/10` until the implementation checkpoint is closed.
- Authority remains `PLANNING_ONLY`; product code, Godot scenes, HTML PoC, and runtime data remain unchanged.
- Growth order is exactly `3성 기술1 → 5성 기술1 추가 효과 → 7성 기술2 → 9성 기술2 단일 완성 효과 → 10성 절초`.
- 9-star adds exactly one branchless effect with no new input, button, or resource cost.
- 7-star `+10 ticks` is integrated into Technique2 budget and is never a separate passive or runtime bundle.
- Every manual visibly records its faction or lineage and Korean/Chinese wuxia provenance class.
- Stat counts and equal quotas are not design rules. Each approved primary/secondary pair is validated only for faction, martial philosophy, action type, and effect fit.
- Shaolin `나한금강공` is `외공 / 내공`; Beggars’ Guild `강룡장결` is `내공 / 근골`.
- Emitted palm force, palm wind, and sword force use Internal as the default primary scaling direction; close-range strikes and weapon impacts use External unless an approved manual-specific rationale says otherwise.
- `자하신공` is once per battle, consumes its use at first prelude execution, never refunds on interruption, and restores Ultimate Momentum only on successful completion.
- Vajra attacks gain `[강건]` before their attack/prelude and use only the existing interruption-prevention rule.
- Existing six action budgets remain historical inputs through explicit aliases. Four new manuals and all ten ultimates require new planning budget rows.
- Runtime, Godot, Windows, accessibility, performance, human, and balance validation remain `NOT_RUN`.
- PR #92 stays Draft and stacked on PR #91; do not merge.

---

## File Structure

- Create `docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json`: names, factions, stats, provenance, stages, orders, and prohibitions.
- Create `tools/check_ten_recognizable_martial_manuals_contract.py`: deterministic semantic validator.
- Create `tests/test_ten_recognizable_martial_manuals_contract.py`: direct and mutation regression tests.
- Create `docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json`: six legacy aliases, four new manual actions, and ten ultimate planning budgets.
- Create `tools/check_ten_manual_growth_budget_overlay.py`: independent budget recalculation and alias validation.
- Create `tests/test_ten_manual_growth_budget_overlay.py`: pricing and mutation regression tests.
- Create `docs/decisions/2026-08-06_TEN_RECOGNIZABLE_MARTIAL_MANUALS_FULL_GROWTH_DECISION.md`: final Decision and supersession boundaries.
- Create `docs/02_COMBAT_RULES_TEN_RECOGNIZABLE_MARTIAL_MANUALS_AMENDMENT.md`: combat-facing resolution authority.
- Modify `docs/03_CONTENT_CATALOG.md`: player-readable ten-manual catalog.
- Modify `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`, `docs/04_ROADMAP.md`, `docs/06_STARTING_FACTION_MASTERY_DATA.md`, `docs/CANON_LIFECYCLE_REGISTRY.md`, documentation maps, PR #92, and linked Sheet tabs.

---

### Task 1: RED semantic authority

**Files:**
- Create: `tests/test_ten_recognizable_martial_manuals_contract.py`
- Consume: `docs/superpowers/specs/2026-08-06-ten-recognizable-martial-manuals-full-growth-design.md`
- Consume: `docs/superpowers/specs/2026-08-06-shaolin-beggars-primary-stat-authority-amendment.md`

**Interfaces:**
- Consumes approved display names, faction labels, stat pairs, stages, resolution orders, and special rules.
- Produces failing assertions for the missing semantic contract, checker, Decision, combat amendment, and catalog synchronization.

- [ ] **Step 1: Write exact roster expectations**

```python
EXPECTED_MANUALS = {
    "mount_hua_plum_blossom_sword": ("화산파", "매화검결", "신법", "외공", "이십사수매화검법"),
    "shaolin_arhat_vajra_art": ("소림사", "나한금강공", "외공", "내공", "여래신장"),
    "wudang_taiji_sword": ("무당파", "태극검결", "심안", "내공", "태극혜검"),
    "yang_family_spear": ("양가", "양가창결", "외공", "신법", "회마창"),
    "mount_hua_purple_mist_art": ("화산파", "자하심법", "내공", "근골", "자하신공"),
    "xiaoyao_lingbo_footwork": ("소요파", "소요보결", "신법", "심안", "능파미보"),
    "beggars_dragon_subduing_palm": ("개방", "강룡장결", "내공", "근골", "항룡십팔장"),
    "sichuan_tang_hidden_weapons": ("사천당문", "천기암기록", "심안", "신법", "만천화우"),
    "hebei_peng_five_tigers_saber": ("하북팽가", "팽가도결", "근골", "외공", "오호단문도"),
    "nangong_boundless_sky_sword": ("남궁세가", "창궁무애검법", "내공", "심안", "제왕검형"),
}
```

- [ ] **Step 2: Assert complete growth packages**

```python
for manual in contract["manuals"].values():
    assert set(manual["growth"]) == {"star3", "star5", "star7", "star9", "star10"}
    assert manual["growth"]["star9"]["effect_count"] == 1
    assert manual["growth"]["star9"]["branching_allowed"] is False
    assert manual["growth"]["star9"]["additional_input_allowed"] is False
```

- [ ] **Step 3: Assert exact special-rule tokens**

```text
STAT_QUOTA_RULES_DISABLED
STAT_FIT_RATIONALE_REQUIRED
SHAOLIN_EXTERNAL_PRIMARY
BEGGARS_INTERNAL_PRIMARY
EMITTED_FORCE_INTERNAL_DEFAULT
ZIXIA_ONCE_PER_BATTLE
ZIXIA_USE_CONSUMED_ON_FIRST_PRELUDE
ZIXIA_NO_REFUND_ON_INTERRUPT
ZIXIA_MOMENTUM_ON_COMPLETION_ONLY
VAJRA_TENACITY_BEFORE_ATTACK
VAJRA_NO_ABSOLUTE_INTERRUPT_IMMUNITY
```

- [ ] **Step 4: Add mutation rejection cases**

Require these stable conflict codes:

```text
MANUAL_ROSTER_CONFLICT
FACTION_SIGNATURE_CONFLICT
STAT_AUTHORITY_CONFLICT
STAT_FIT_RATIONALE_CONFLICT
STAT_QUOTA_POLICY_CONFLICT
GROWTH_STAGE_CONFLICT
STAR5_ROLE_CONFLICT
STAR9_SINGLE_EFFECT_CONFLICT
ULTIMATE_IDENTITY_CONFLICT
RESOLUTION_ORDER_CONFLICT
ZIXIA_ONCE_PER_BATTLE_CONFLICT
VAJRA_TENACITY_CONFLICT
PALM_FORCE_STAT_CONFLICT
ROLE_REPLACEMENT_CONFLICT
PROVENANCE_CONFLICT
TEN_MANUAL_SCOPE_CONFLICT
```

- [ ] **Step 5: Run RED and commit**

```bash
python -m unittest tests.test_ten_recognizable_martial_manuals_contract -v
```

Expected: FAIL because `approved_20260806_ten_recognizable_martial_manuals_contract.json` and its checker do not exist.

```bash
git add tests/test_ten_recognizable_martial_manuals_contract.py
git commit -m "test: define ten recognizable martial manuals contract"
```

---

### Task 2: GREEN semantic contract and checker

**Files:**
- Create: `docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json`
- Create: `tools/check_ten_recognizable_martial_manuals_contract.py`
- Create: `.github/workflows/ten-recognizable-martial-manuals-validation.yml`

**Interfaces:**
- Consumes: the two approved specs and existing combat status names.
- Produces: `TEN_RECOGNIZABLE_MARTIAL_MANUALS_CONTRACT_PASS` or one stable conflict code.

- [ ] **Step 1: Add the top-level authority metadata**

```json
{
  "schema_version": 1,
  "decision_id": "TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01",
  "authority_status": "CURRENT_APPROVED_PLANNING_GOVERNANCE",
  "implementation_authority": "PLANNING_ONLY",
  "approval_batch": "9/10",
  "stat_assignment_policy": "FACTION_MARTIAL_ACTION_FIT_ONLY",
  "stat_quota_rules_enabled": false,
  "manuals": {},
  "scope_boundary": {}
}
```

- [ ] **Step 2: Encode each manual with one clear responsibility per field**

Every manual entry must include:

```text
faction
manual_name
primary_stat
secondary_stat
stat_fit_rationale
provenance
martial_philosophy
core_role
forbidden_roles
growth.star3
growth.star5
growth.star7
growth.star9
growth.star10
resolution_order
counterplay
measurement_risks
```

- [ ] **Step 3: Implement deterministic checker functions**

```python
def load_contract(path: Path) -> dict: ...
def validate_metadata(data: dict) -> list[str]: ...
def validate_roster(data: dict) -> list[str]: ...
def validate_stat_fit(data: dict) -> list[str]: ...
def validate_growth(data: dict) -> list[str]: ...
def validate_special_rules(data: dict) -> list[str]: ...
def validate_scope(data: dict) -> list[str]: ...
def main(argv: list[str] | None = None) -> int: ...
```

The checker must compare exact approved stat pairs but must never count or enforce how many manuals use each stat.

- [ ] **Step 4: Add dedicated workflow**

```yaml
name: Validate Ten Recognizable Martial Manuals
on:
  pull_request:
  workflow_dispatch:
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: python -m unittest tests.test_ten_recognizable_martial_manuals_contract -v
      - run: python tools/check_ten_recognizable_martial_manuals_contract.py
```

- [ ] **Step 5: Run GREEN and commit**

```bash
python -m unittest tests.test_ten_recognizable_martial_manuals_contract -v
python tools/check_ten_recognizable_martial_manuals_contract.py
git add docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json \
  tools/check_ten_recognizable_martial_manuals_contract.py \
  .github/workflows/ten-recognizable-martial-manuals-validation.yml
git commit -m "feat: approve ten recognizable martial manuals"
```

---

### Task 3: RED/GREEN planning budget overlay

**Files:**
- Create: `tests/test_ten_manual_growth_budget_overlay.py`
- Create: `docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json`
- Create: `tools/check_ten_manual_growth_budget_overlay.py`
- Create: `.github/workflows/ten-manual-growth-budget-validation.yml`

**Interfaces:**
- Consumes: `approved_20260804_existing_action_reprice_contract.json`, `approved_20260805_star7_star9_mastery_bonus_contract.json`, and the ten-manual semantic contract.
- Produces: exact budget rows or `TEN_MANUAL_GROWTH_BUDGET_OVERLAY_PASS`.

- [ ] **Step 1: Write failing alias and formula tests**

Require these legacy mappings:

```python
LEGACY_ALIASES = {
    "falling_petal_chasing_sword": "mount_hua_plum_blossom_sword.star7",
    "rebounding_vajra_fist": "shaolin_arhat_vajra_art.star7",
    "four_ounces_move_thousand_pounds": "wudang_taiji_sword.star7",
    "chained_road_lock": "yang_family_spear.star7",
    "returning_qi_meridian": "mount_hua_purple_mist_art.star7",
    "ten_paces_position_reversal": "xiaoyao_lingbo_footwork.star7",
}
```

Require formulas:

```text
star7_final_budget_ticks = effective_technique2_available_budget_ticks + 10
star9_bonus_ticks = 10 + floor(star7_final_budget_ticks * 0.20)
star9_total_budget_ticks = star7_final_budget_ticks + star9_bonus_ticks
available_budget_ticks = slot_budget + stamina_allowance + internal_allowance - automatic_tolerance
variance_ticks = effect_cost_ticks - available_budget_ticks
```

- [ ] **Step 2: Define four new Technique2 planning profiles and ten ultimate profiles**

Each profile explicitly records:

```text
action_slots
stamina_cost
internal_cost
movement_tiles
max_range
base_effect_ticks_excluding_distance
distance_effect_ticks
condition_allowance_ticks
effect_cost_ticks
available_budget_ticks
variance_ticks
variance_status
```

No row may use `TBD`, `TODO`, `UNKNOWN`, or an omitted numeric field. Automatic tolerance is `5` ticks. Variance outside `[-5, +5]` fails.

- [ ] **Step 3: Implement independent budget recalculation**

```python
def calculate_available_budget(slots: int, stamina: int, internal: int, tolerance: int = 5) -> int: ...
def calculate_distance_ticks(max_range: int, movement_tiles: int) -> int: ...
def validate_legacy_aliases(data: dict, source: dict) -> list[str]: ...
def validate_new_profiles(data: dict) -> list[str]: ...
def validate_ultimate_profiles(data: dict) -> list[str]: ...
```

- [ ] **Step 4: Verify RED, then GREEN**

```bash
python -m unittest tests.test_ten_manual_growth_budget_overlay -v
python tools/check_ten_manual_growth_budget_overlay.py
```

- [ ] **Step 5: Commit budget authority**

```bash
git add tests/test_ten_manual_growth_budget_overlay.py \
  docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json \
  tools/check_ten_manual_growth_budget_overlay.py \
  .github/workflows/ten-manual-growth-budget-validation.yml
git commit -m "feat: price ten-manual growth packages"
```

---

### Task 4: Decision, combat amendment, and readable catalog

**Files:**
- Create: `docs/decisions/2026-08-06_TEN_RECOGNIZABLE_MARTIAL_MANUALS_FULL_GROWTH_DECISION.md`
- Create: `docs/02_COMBAT_RULES_TEN_RECOGNIZABLE_MARTIAL_MANUALS_AMENDMENT.md`
- Modify: `docs/03_CONTENT_CATALOG.md`
- Modify: `docs/06_STARTING_FACTION_MASTERY_DATA.md`

**Interfaces:**
- Consumes: final semantic and budget contracts.
- Produces: one Decision boundary, one combat resolution authority, and one user-readable catalog.

- [ ] **Step 1: Write the Decision supersession boundary**

The Decision must state that the 2026-08-06 contracts supersede old names, old faction associations, old stat pairs, and pending individual 7/9/10 effect status only for the ten approved manuals. Historical cost evidence remains readable.

- [ ] **Step 2: Write the combat amendment**

Include exact orders for all ten ultimates and these special clauses:

```text
자하신공 use token consumed at first prelude execution
자하신공 Ultimate Momentum +1 only on completion
나한금강공 Tenacity granted before attack/prelude
항룡십팔장 uses Internal for emitted-force damage and clash power
소림 여래신장 remains close-range External strike with capped stored-impact bonus
```

- [ ] **Step 3: Add the readable catalog in the approved format**

For every manual use:

```text
[문파] 무공서명 — 주능력치 / 보조능력치
(3성) 기술1 [이름] - 효과
5성 추가 효과 = 효과
(7성) 기술2 [이름] - 효과
9성 추가 효과 = 효과
(10성) 절초 [이름] - 효과
```

- [ ] **Step 4: Remove stale six-manual current wording**

Keep old names only in a clearly labeled historical alias table. Current sections must use all ten approved names.

- [ ] **Step 5: Run both contract suites and commit**

```bash
python -m unittest tests.test_ten_recognizable_martial_manuals_contract -v
python -m unittest tests.test_ten_manual_growth_budget_overlay -v
git add docs/decisions/2026-08-06_TEN_RECOGNIZABLE_MARTIAL_MANUALS_FULL_GROWTH_DECISION.md \
  docs/02_COMBAT_RULES_TEN_RECOGNIZABLE_MARTIAL_MANUALS_AMENDMENT.md \
  docs/03_CONTENT_CATALOG.md docs/06_STARTING_FACTION_MASTERY_DATA.md
git commit -m "docs: publish ten-manual growth authority"
```

---

### Task 5: Current-state ownership and regression wiring

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/04_ROADMAP.md`
- Modify: `docs/01_GAME_DESIGN.md`
- Modify: `docs/CANON_LIFECYCLE_REGISTRY.md`
- Modify: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `.github/workflows/documentation-governance.yml`
- Modify: `tests/test_postmerge_canon_lifecycle.py`
- Modify: `tests/test_project_governance.py`

**Interfaces:**
- Consumes: the approved Decision and both contracts.
- Produces: one current state across all authority documents and mandatory PR Validation coverage.

- [ ] **Step 1: Set current operating state**

```yaml
active_approval_count: 9/10
active_decision_state: APPROVED_DRAFT_TEN_RECOGNIZABLE_MARTIAL_MANUALS
active_decision: TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01
next_planning_decision: TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE
```

- [ ] **Step 2: Register supersession and document routes**

The lifecycle registry must point current martial manual authority to the two 2026-08-06 contracts and retain previous contracts as historical evidence.

- [ ] **Step 3: Wire both new suites into PR Validation**

```yaml
- run: python -m unittest tests.test_ten_recognizable_martial_manuals_contract -v
- run: python tools/check_ten_recognizable_martial_manuals_contract.py
- run: python -m unittest tests.test_ten_manual_growth_budget_overlay -v
- run: python tools/check_ten_manual_growth_budget_overlay.py
```

- [ ] **Step 4: Run full local validation**

```bash
python -m unittest discover -s tests -v
python tools/check_ten_recognizable_martial_manuals_contract.py
python tools/check_ten_manual_growth_budget_overlay.py
```

- [ ] **Step 5: Commit governance synchronization**

```bash
git add '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md' docs/04_ROADMAP.md \
  docs/01_GAME_DESIGN.md docs/CANON_LIFECYCLE_REGISTRY.md \
  '[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md' docs/DOCUMENTATION_MAP.md \
  .github/workflows/documentation-governance.yml \
  tests/test_postmerge_canon_lifecycle.py tests/test_project_governance.py
git commit -m "docs: synchronize ten-manual current authority"
```

---

### Task 6: Exact-head GitHub and Google Sheet synchronization

**Files and connected records:**
- Update: PR #92 title/body, keeping Draft state.
- Update Sheet tabs: `00_프로젝트_허브`, `01_작업순서`, `02_현재_확정결정`, `04_누락_충돌_감사`, `12_핵심루프`, `15_조작_게임규칙`, `40_핵심시스템_메인콘텐츠`, `41_성장_경제`, `99_변경이력`.

**Interfaces:**
- Consumes: final exact-head SHA and Decision ID.
- Produces: matching GitHub/Sheet records and readback evidence.

- [ ] **Step 1: Verify exact-head workflows**

Required successful workflows:

```text
PR Validation
Full Validation
Validate Base v9 adoption
Validate Technique1 conditional Star5
Validate Wrong-Plan Rescue Derived Stats
Validate Observation Answer Leak Guardrails
Validate Grade Farming Guardrails
Validate Star7 Star9 Mastery Bonus
Validate Ten Recognizable Martial Manuals
Validate Ten Manual Growth Budget
```

- [ ] **Step 2: Verify changed-file boundary**

Confirm no changed paths under product runtime code, Godot scenes, HTML PoC, or runtime data.

- [ ] **Step 3: Write the same Decision ID and final SHA to all nine Sheet tabs**

`99_변경이력` must retain exactly eight columns. Record the ten manual names, Shaolin/Beggars stat correction, disabled stat-quota rule, Zixia once-per-battle rule, Vajra Tenacity rule, verification state, and product boundary.

- [ ] **Step 4: Read back all nine target ranges**

Every target tab must contain:

```text
TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01
<same exact final head SHA>
```

- [ ] **Step 5: Update PR #92 without merging**

Record the Decision, final SHA, ten-manual catalog, stat-fit policy, special rules, workflow results, Sheet readback, stacked lineage, and all `NOT_RUN` human/runtime validations.

- [ ] **Step 6: Stop at runtime implementation gate**

Do not modify product code, Godot scenes, HTML PoC, or runtime data without the separate `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE` approval.
