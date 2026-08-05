# Ten-Manual Runtime Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the approved ten martial manuals from planning-only authority into a tested Godot runtime registry and deterministic effect-step foundation without replacing the existing PoC UI, AI, or generic cards.

**Architecture:** Add a versioned martial-manual card catalog, load it through a focused `MartialManualRegistry`, and execute its ordered structural programs through `MartialEffectPipeline`. `CombatResolutionEngine` keeps its existing basic and generic ultimate cards and only merges martial cards when a loadout and mastery map are explicitly supplied.

**Tech Stack:** Godot 4.7.1 / GDScript, JSON runtime data, Python 3.11–3.12 contract tests, GitHub Actions.

## Global Constraints

- Parent Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`.
- Runtime gate: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`.
- Preserve `data/cards/basic_cards.json` and `data/cards/ultimate_cards.json` IDs and behavior.
- Do not enforce any primary/secondary-stat count, quota, equality, minimum, or maximum rule.
- Star 5 modifies only the star-3 card.
- Star 9 modifies only the star-7 card and adds exactly one branchless effect step with no extra input or resource cost.
- Movement that can change attack range requires a later `RECHECK_RANGE` before the dependent attack.
- State creation required by an action executes before the dependent attack, recovery, or counter.
- Human balance, Windows interaction, accessibility, performance, final VFX, and AI adoption remain `NOT_RUN` or out of scope.
- Do not merge or undraft PR #92; it remains stacked on PR #91.

---

## File Map

### Create

- `docs/implementation/BUILD_APPROVAL_2026-08-06.md` — explicit runtime-build gate and scope boundary.
- `data/cards/martial_manual_cards.json` — executable runtime catalog for ten manuals.
- `src/combat/martial_manual_registry.gd` — load, validate, unlock, and overlay card definitions.
- `src/combat/martial_effect_pipeline.gd` — deterministic ordered effect-step executor.
- `tools/check_ten_manual_runtime_foundation.py` — static cross-file contract validator.
- `tests/test_ten_manual_runtime_foundation.py` — negative and positive Python contract tests.
- `tests/verify_ten_manual_registry.gd` — Godot registry and overlay verification.
- `tests/verify_martial_effect_pipeline.gd` — Godot effect ordering and special-rule verification.
- `.github/workflows/validate-ten-manual-runtime-foundation.yml` — focused RED/GREEN workflow.
- `docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md` — runtime-foundation Decision evidence.

### Modify

- `src/combat/combat_resolution_engine.gd` — load registry and expose explicit loadout merge without altering legacy default behavior.
- `.github/workflows/full-validation.yml` — run the two new Godot verifiers and Python contract test when runtime validation is enabled.
- `.github/workflows/documentation-governance.yml` — run the Python runtime-foundation contract in PR Validation.
- `tests/check_canonical_combat_docs.py` — require the runtime-gate Decision and build approval without changing unrelated combat tokens.
- `docs/ACTIVE_CONTEXT.md`, `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`, `docs/04_ROADMAP.md`, `docs/06_STARTING_FACTION_MASTERY_DATA.md` — move current authority from planning-only to runtime-foundation implemented while preserving human-validation gaps.

---

### Task 1: RED runtime-foundation contract

**Files:**
- Create: `tests/test_ten_manual_runtime_foundation.py`
- Create: `tools/check_ten_manual_runtime_foundation.py`
- Create: `.github/workflows/validate-ten-manual-runtime-foundation.yml`

**Interfaces:**
- Consumes: approved semantic and budget contracts.
- Produces: `validate(root: Path) -> None` and focused workflow evidence.

- [ ] **Step 1: Write failing tests for missing runtime files**

```python
class TenManualRuntimeFoundationTests(unittest.TestCase):
    def test_current_repository_passes(self) -> None:
        validator.validate(ROOT)

    def test_requires_exact_ten_manual_roster(self) -> None:
        with mutated_root() as root:
            catalog = read_catalog(root)
            catalog["manuals"].pop(next(iter(catalog["manuals"])))
            write_catalog(root, catalog)
            with self.assertRaises(validator.RuntimeFoundationError):
                validator.validate(root)
```

The initial validator must require, and therefore fail on the absence of:

```text
data/cards/martial_manual_cards.json
src/combat/martial_manual_registry.gd
src/combat/martial_effect_pipeline.gd
docs/implementation/BUILD_APPROVAL_2026-08-06.md
```

- [ ] **Step 2: Run focused RED workflow**

```bash
python -m unittest tests.test_ten_manual_runtime_foundation -v
```

Expected: FAIL because runtime catalog and Godot runtime modules do not exist.

- [ ] **Step 3: Commit RED evidence**

```bash
git add tests/test_ten_manual_runtime_foundation.py tools/check_ten_manual_runtime_foundation.py .github/workflows/validate-ten-manual-runtime-foundation.yml
git commit -m "test: define ten-manual runtime foundation contract"
```

---

### Task 2: Runtime catalog and mastery overlays

**Files:**
- Create: `data/cards/martial_manual_cards.json`
- Create: `src/combat/martial_manual_registry.gd`
- Create: `tests/verify_ten_manual_registry.gd`

**Interfaces:**
- Produces:
  - `MartialManualRegistry.new(path := DEFAULT_PATH)`
  - `is_valid() -> bool`
  - `get_manual_ids() -> PackedStringArray`
  - `build_unlocked_cards(manual_id: String, mastery: int) -> Array[Dictionary]`
  - `build_loadout_cards(loadout: Array, mastery_by_manual: Dictionary) -> Dictionary`

- [ ] **Step 1: Write the failing Godot registry verifier**

```gdscript
var registry := REGISTRY_SCRIPT.new()
_assert(registry.is_valid(), "catalog must load")
_assert(registry.get_manual_ids().size() == 10, "exactly ten manuals")
_assert(registry.build_unlocked_cards("mount_hua_plum_blossom_sword", 3).size() == 1, "star3 unlock")
_assert(registry.build_unlocked_cards("mount_hua_plum_blossom_sword", 7).size() == 2, "star7 unlock")
_assert(registry.build_unlocked_cards("mount_hua_plum_blossom_sword", 10).size() == 3, "star10 unlock")
```

The verifier must also assert:

```text
mastery 4: no star5 overlay
mastery 5: star5 overlay exists only on star3
mastery 8: no star9 overlay
mastery 9: exactly one star9 step exists only on star7
repeated build calls do not mutate catalog data
```

- [ ] **Step 2: Verify RED**

```bash
godot --headless --path . --script res://tests/verify_ten_manual_registry.gd
```

Expected: parser or preload failure because `martial_manual_registry.gd` is absent.

- [ ] **Step 3: Add the runtime catalog**

Each manual entry must use this shape:

```json
{
  "faction": "화산파",
  "manual_name": "매화검결",
  "primary_stat": "신법",
  "secondary_stat": "외공",
  "cards": {
    "star3": {"unlock_star": 3, "effect_steps": []},
    "star7": {"unlock_star": 7, "effect_steps": []},
    "star10": {"unlock_star": 10, "effect_steps": []}
  },
  "overlays": {
    "star5": {"unlock_star": 5, "target": "star3", "effect_steps": []},
    "star9": {"unlock_star": 9, "target": "star7", "effect_steps": [{}]}
  }
}
```

The exact roster, names, stats, and action budgets must be copied from the approved semantic and budget contracts. Runtime balance values must be marked `PROVISIONAL_WITHIN_APPROVED_BUDGET`.

- [ ] **Step 4: Implement the minimal registry**

```gdscript
class_name MartialManualRegistry
extends RefCounted

const DEFAULT_PATH := "res://data/cards/martial_manual_cards.json"

func build_unlocked_cards(manual_id: String, mastery: int) -> Array:
    var manual: Dictionary = _manuals.get(manual_id, {})
    var result: Array = []
    for stage in ["star3", "star7", "star10"]:
        var card: Dictionary = (manual.get("cards", {}) as Dictionary).get(stage, {})
        if mastery >= int(card.get("unlock_star", 99)):
            result.append(_apply_unlocked_overlays(manual, stage, mastery, card.duplicate(true)))
    return result
```

- [ ] **Step 5: Verify GREEN**

```bash
godot --headless --path . --script res://tests/verify_ten_manual_registry.gd
python -m unittest tests.test_ten_manual_runtime_foundation -v
```

Expected: registry verifier PASS; static contract progresses to the next missing component only.

- [ ] **Step 6: Commit**

```bash
git add data/cards/martial_manual_cards.json src/combat/martial_manual_registry.gd tests/verify_ten_manual_registry.gd
git commit -m "feat: add ten-manual runtime registry"
```

---

### Task 3: Ordered martial-effect pipeline

**Files:**
- Create: `src/combat/martial_effect_pipeline.gd`
- Create: `tests/verify_martial_effect_pipeline.gd`

**Interfaces:**
- Produces:
  - `execute(definition: Dictionary, state: Dictionary, actor_key: String, context := {}) -> Dictionary`
  - result keys: `state`, `events`, `completed`, `failure_reason`, `actual_hp_hits`, `clash_won`, `evade_succeeded`.

- [ ] **Step 1: Write failing behavior tests**

The Godot verifier must exercise real pipeline code with minimal card fixtures and assert:

```gdscript
# State before attack
_assert(events[0]["op"] == "GAIN_STATUS", "fortitude must precede attack")

# Movement then range recheck
_assert(_event_ops(result) == ["ATTACK", "MOVE_AWAY", "RECHECK_RANGE", "ATTACK"], "returning spear order")
_assert(result["events"][-1]["status"] == "SKIPPED_OUT_OF_RANGE", "second strike cannot ignore range")

# Zixia use right
_assert(not result["state"]["player"]["battle_uses"].get("purple_mist_ultimate", true), "use right consumed at prelude")
_assert(_momentum(result) == 0, "interrupted program grants no completion momentum")

# Independent attacks
_assert(result["events"].filter(func(event): return event["op"] == "INDEPENDENT_ATTACK").size() == 4, "four deterministic projectiles")
```

- [ ] **Step 2: Verify RED**

```bash
godot --headless --path . --script res://tests/verify_martial_effect_pipeline.gd
```

Expected: preload failure because pipeline is absent.

- [ ] **Step 3: Implement minimal deterministic operations**

Implement only the approved allowlist. Unknown operations return `completed=false` and `failure_reason=UNKNOWN_EFFECT_OP` without mutating caller state.

State mutation rules:

```text
GAIN_STATUS -> write status before later dependent steps
CONSUME_ONCE_PER_BATTLE -> set use-right false immediately
MOVE_TOWARD/MOVE_AWAY -> clamp to board 1..tile_count
RECHECK_RANGE -> update context gate for the next dependent attack
ATTACK/INDEPENDENT_ATTACK -> deterministic preview damage with defense then health
REQUIRE_* -> skip only the guarded following step group, never invent a branch choice
GAIN_MOMENTUM_ON_COMPLETE -> execute only after all prior steps complete
```

- [ ] **Step 4: Verify GREEN**

```bash
godot --headless --path . --script res://tests/verify_martial_effect_pipeline.gd
python -m unittest tests.test_ten_manual_runtime_foundation -v
```

Expected: both PASS.

- [ ] **Step 5: Commit**

```bash
git add src/combat/martial_effect_pipeline.gd tests/verify_martial_effect_pipeline.gd
git commit -m "feat: execute ordered martial effect programs"
```

---

### Task 4: Combat engine compatibility integration

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `tests/verify_ten_manual_registry.gd`
- Modify: `tests/verify_martial_effect_pipeline.gd`

**Interfaces:**
- Adds:
  - `configure_martial_loadout(loadout: Array, mastery_by_manual: Dictionary) -> void`
  - `resolve_martial_card(card_id: String, state: Dictionary, actor_key: String, context := {}) -> Dictionary`

- [ ] **Step 1: Add failing integration assertions**

```gdscript
var engine := ENGINE_SCRIPT.new()
_assert(engine.cards_by_id.has("basic_move"), "legacy basic card preserved")
_assert(engine.cards_by_id.has("ultimate_ten_paces_wave"), "legacy generic ultimate preserved")
engine.configure_martial_loadout(["mount_hua_plum_blossom_sword"], {"mount_hua_plum_blossom_sword": 7})
_assert(engine.cards_by_id.has("mount_hua_plum_blossom_sword_star3"), "star3 merged")
_assert(engine.cards_by_id.has("mount_hua_plum_blossom_sword_star7"), "star7 merged")
_assert(not engine.cards_by_id.has("mount_hua_plum_blossom_sword_star10"), "locked star10 absent")
```

- [ ] **Step 2: Verify RED**

Run the registry verifier. Expected: missing `configure_martial_loadout`.

- [ ] **Step 3: Implement minimal integration**

```gdscript
const MartialManualRegistryScript := preload("res://src/combat/martial_manual_registry.gd")
const MartialEffectPipelineScript := preload("res://src/combat/martial_effect_pipeline.gd")

func configure_martial_loadout(loadout: Array, mastery_by_manual: Dictionary) -> void:
    _remove_loaded_martial_cards()
    for card_id in martial_registry.build_loadout_cards(loadout, mastery_by_manual):
        cards_by_id[card_id] = martial_cards[card_id]
```

Legacy default initialization must remain unchanged when this method is never called.

- [ ] **Step 4: Verify GREEN and regressions**

```bash
godot --headless --path . --script res://tests/verify_ten_manual_registry.gd
godot --headless --path . --script res://tests/verify_martial_effect_pipeline.gd
godot --headless --path . --script res://tests/verify_combat_board.gd
godot --headless --path . --script res://tests/verify_response_rules.gd
godot --headless --path . --script res://tests/verify_ultimate_interrupt_engagement.gd
```

Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add src/combat/combat_resolution_engine.gd tests/verify_ten_manual_registry.gd tests/verify_martial_effect_pipeline.gd
git commit -m "feat: integrate martial loadouts with combat engine"
```

---

### Task 5: Build approval, CI, and canonical synchronization

**Files:**
- Create: `docs/implementation/BUILD_APPROVAL_2026-08-06.md`
- Create: `docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md`
- Modify: `.github/workflows/full-validation.yml`
- Modify: `.github/workflows/documentation-governance.yml`
- Modify: `tests/check_canonical_combat_docs.py`
- Modify: current authority documents listed in the File Map.

**Interfaces:**
- Produces exact-head runtime-foundation evidence and a new Sheet synchronization checkpoint.

- [ ] **Step 1: Add the build approval**

It must state:

```text
approved scope: registry + ordered effect pipeline + explicit engine loadout integration
forbidden scope: UI replacement, AI adoption, final balance claim, PR merge
human validation: NOT_RUN
```

- [ ] **Step 2: Wire focused checks into CI**

PR Validation:

```yaml
- name: Run ten-manual runtime foundation regression tests
  run: python -m unittest tests.test_ten_manual_runtime_foundation -v
- name: Validate ten-manual runtime foundation
  run: python tools/check_ten_manual_runtime_foundation.py
```

Full Validation Godot job:

```yaml
- name: Verify ten-manual registry
  run: godot --headless --path . --script res://tests/verify_ten_manual_registry.gd
- name: Verify martial effect pipeline
  run: godot --headless --path . --script res://tests/verify_martial_effect_pipeline.gd
```

- [ ] **Step 3: Update current authority without erasing gaps**

Current state must become:

```text
TEN_MANUAL_RUNTIME_FOUNDATION_IMPLEMENTED
product authority: RUNTIME_FOUNDATION
UI/AI/full card presentation: DEFERRED
human/balance/accessibility/performance: NOT_RUN
```

- [ ] **Step 4: Run exact-head verification**

Required successful workflows:

```text
Validate Ten Manual Runtime Foundation
PR Validation
Full Validation
Validate Ten Recognizable Martial Manuals
Validate Ten Manual Growth Budget
```

- [ ] **Step 5: Adversarial review**

Check:

```text
No stat quota logic
No hidden plan access
No automatic clash win
No range bypass after movement
No Zixia use-right refund
No absolute fortitude immunity
No mutation of basic or generic ultimate card IDs
No false human or balance validation claim
```

- [ ] **Step 6: Synchronize Google Sheet only after final SHA**

Record the same new runtime Decision ID and exact head in:

```text
00_프로젝트_허브
01_작업순서
02_현재_확정결정
04_누락_충돌_감사
12_핵심루프
15_조작_게임규칙
40_핵심시스템_메인콘텐츠
41_성장_경제
99_변경이력
```

- [ ] **Step 7: Commit and update PR #92 body**

```bash
git add docs .github tests tools data src
git commit -m "feat: establish ten-manual runtime foundation"
```

Keep PR #92 Draft and stacked on #91.

---

## Self-Review

- Spec coverage: all ten manuals, 3/5/7/9/10 structure, quota removal, ordered effects, Zixia, fortitude, range recheck, compatibility, CI, and Sheet synchronization are assigned to tasks.
- Placeholder scan: no TBD/TODO/implement-later instruction is present; deferred scopes are explicit exclusions rather than unfinished steps.
- Type consistency: registry and pipeline signatures are defined once and reused by integration tasks.
- Scope control: UI, AI, final balance, and merge remain outside this plan.
