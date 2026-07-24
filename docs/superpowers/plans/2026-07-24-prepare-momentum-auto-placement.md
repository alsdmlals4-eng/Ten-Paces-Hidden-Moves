# Prepare Momentum and Auto Placement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the stance card to `[준비]`, display multi-slot lead-in timings as `[전조]`, make preparation persist through movement and empower meditation, and auto-place every selected card—including ultimates—into the earliest valid contiguous timing range with pre-commit refund support.

**Architecture:** `ActionTimingPanel` owns earliest-range discovery and placement validity. `CombatBoardPreview` owns card-selection UX, ultimate reservation, cancellation and target handoff. `CombatResolutionEngine` owns preparation-state lifetime, meditation momentum reward and user-facing resolution logs. Card data remains the source of display names while internal IDs remain stable.

**Tech Stack:** Godot 4.7 GDScript, JSON card data, Python static contract checks, GitHub Actions Ubuntu/Windows Python matrix, Godot headless verifier suite.

## Global Constraints

- Base branch is `agent/repeat-poc-a3-review-ui-closeout`.
- Internal card ID `basic_stance` must not change.
- Ultimate momentum maximum and reservation requirement remain exactly 5.
- Movement and footwork do not consume preparation, including invalid or zero-distance movement.
- All non-movement action attempts consume preparation; meditation grants +1 momentum only when it executes.
- Multi-slot internal `action_stage = preparation` remains unchanged; only user-facing label becomes `[전조]`.
- Existing A1 AI, A2 hypothesis/summary and A3 review-gate behavior must remain intact.
- Human STEP 14 remains deferred.

---

### Task 1: Lock the new behavior with failing contracts

**Files:**
- Create: `tests/check_prepare_auto_placement_contract.py`
- Create: `tests/verify_prepare_momentum.gd`
- Create: `tests/verify_auto_card_placement.gd`
- Modify: `.github/workflows/documentation-governance.yml`
- Modify: `.github/workflows/full-validation.yml`

**Interfaces:**
- Consumes: existing `CombatResolutionEngine.resolve_bundle`, `ActionTimingPanel.place_card`, `CombatBoardPreview` card selection handlers.
- Produces: executable contracts for Tasks 2–4.

- [ ] **Step 1: Write the failing Python contract**

```python
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def main() -> None:
    cards = json.loads(read("data/cards/basic_cards.json"))["cards"]
    stance = next(card for card in cards if card["id"] == "basic_stance")
    assert stance["name"] == "준비"

    timing = read("src/ui/action_timing_panel.gd")
    assert "func find_earliest_open_anchor(span: int) -> int:" in timing

    board = read("src/combat/combat_board_preview.gd")
    assert "find_earliest_open_anchor" in board
    assert "_auto_place_selected_card" in board

    engine = read("src/combat/combat_resolution_engine.gd")
    assert "[전조]" in engine
    assert "prepare_active" in engine
    assert "prepare_meditate_momentum" in engine

    print("prepare and auto placement contract: PASS")


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Write Godot verifier cases**

`verify_prepare_momentum.gd` must assert:

```gdscript
# 준비 -> 명상
# 준비 -> 이동 -> 명상
# 준비 -> 이동 -> 공격
# 준비 -> 비이동 실행 실패
# momentum 5 cap
```

`verify_auto_card_placement.gd` must assert:

```gdscript
# earliest 1-slot
# skip occupied slot
# earliest contiguous 2-slot
# fail without contiguous range
# ultimate auto reservation consumes 5
# cancel reservation restores 5
```

- [ ] **Step 3: Add each verifier as its own workflow step**

Add to PR static validation:

```yaml
- name: Validate prepare and auto placement contract
  run: python tests/check_prepare_auto_placement_contract.py
```

Add to Full Validation Godot job:

```yaml
- name: Verify prepare momentum
  run: godot --headless --path . --script res://tests/verify_prepare_momentum.gd
- name: Verify auto card placement
  run: godot --headless --path . --script res://tests/verify_auto_card_placement.gd
```

- [ ] **Step 4: Run PR validation and confirm Red**

Expected: `check_prepare_auto_placement_contract.py` fails because the card is still named `태세` and the new methods/state tokens are absent.

- [ ] **Step 5: Commit**

```bash
git add tests/check_prepare_auto_placement_contract.py tests/verify_prepare_momentum.gd tests/verify_auto_card_placement.gd .github/workflows/documentation-governance.yml .github/workflows/full-validation.yml
git commit -m "test: define prepare and auto placement contracts"
```

---

### Task 2: Rename the card and change preparation display to omen

**Files:**
- Modify: `data/cards/basic_cards.json`
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `docs/02_COMBAT_RULES.md`
- Test: `tests/check_prepare_auto_placement_contract.py`

**Interfaces:**
- Consumes: stable internal ID `basic_stance` and existing multi-slot action records.
- Produces: display name `준비` and user-facing `[전조]` preparation logs.

- [ ] **Step 1: Update the card definition without changing its ID**

```json
{
  "id": "basic_stance",
  "name": "준비",
  "effect_text": "다음 비이동 행동을 강화한다. 이동과 보법은 준비를 소비하지 않는다. 준비 후 명상을 실행하면 절초 기세를 1 얻는다.",
  "tags": ["준비"]
}
```

Preserve source badges, category, costs and illustration fields.

- [ ] **Step 2: Change multi-slot lead-in logs**

Replace the user-facing preparation log with:

```gdscript
logs.append("[%d수 · 전조] %s이(가) %s의 실행을 예고한다." % [timing, _actor_name(preparation_actor), str(preparation_definition.get("name", "행동"))])
```

Keep:

```gdscript
preparation_record["action_stage"] = "preparation"
```

- [ ] **Step 3: Update canonical combat rules**

Document:

```text
[준비]는 카드 이름이며, 다중 슬롯 행동의 실행 전 점유 수는 [전조]다.
```

- [ ] **Step 4: Run the static contract**

Run:

```bash
python tests/check_prepare_auto_placement_contract.py
```

Expected: still FAIL because preparation state and auto-placement methods are not yet implemented; card-name and omen assertions pass.

- [ ] **Step 5: Commit**

```bash
git add data/cards/basic_cards.json src/combat/combat_resolution_engine.gd docs/02_COMBAT_RULES.md
git commit -m "feat: rename stance to prepare and label multi-slot omens"
```

---

### Task 3: Implement preparation lifetime and meditation momentum

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `data/combat/combat_resolution_preview.json`
- Test: `tests/verify_prepare_momentum.gd`

**Interfaces:**
- Consumes: actor dictionaries, `_base_card_id`, `_resource_pair`, `_set_resource`, action category and execution outcome.
- Produces: actor field `prepare_active: bool`, rule `prepare_meditate_momentum: 1`, preparation consumption helpers.

- [ ] **Step 1: Initialize explicit preparation state**

In `make_initial_state`:

```gdscript
player["prepare_active"] = false
enemy["prepare_active"] = false
```

- [ ] **Step 2: Add rule value**

In `combat_resolution_preview.json`:

```json
"prepare_meditate_momentum": 1
```

- [ ] **Step 3: Set preparation when `basic_stance` executes**

```gdscript
elif card_id == "basic_stance":
    actor["prepare_active"] = true
    actor["next_attack_bonus"] = int(rules.get("stance_attack_bonus", 2))
    actor["fortitude_next_attack"] = true
    _sync_dynamic_statuses(actor)
    logs.append("[%d수 · 준비] %s이(가) 다음 비이동 행동을 준비했다." % [timing, _actor_name(actor)])
```

- [ ] **Step 4: Preserve preparation through movement**

Do not clear `prepare_active`, `next_attack_bonus`, or `fortitude_next_attack` in `_execute_move_phase`, including invalid movement.

- [ ] **Step 5: Grant meditation momentum and consume preparation**

Inside the executed meditation branch:

```gdscript
if bool(actor.get("prepare_active", false)):
    var momentum := _resource_pair(actor, "momentum")
    _set_resource(actor, "momentum", momentum.x + int(rules.get("prepare_meditate_momentum", 1)), momentum.y)
    _clear_prepare_state(actor)
    logs.append("[%d수 · 준비 강화] %s이(가) 명상으로 절초 기세 1을 얻었다." % [timing, _actor_name(actor)])
```

- [ ] **Step 6: Consume preparation on attack and other non-movement attempts**

Add:

```gdscript
func _clear_prepare_state(actor: Dictionary) -> void:
    actor["prepare_active"] = false
    actor["next_attack_bonus"] = 0
    actor["fortitude_next_attack"] = false
    _sync_dynamic_statuses(actor)
```

Attack execution uses the stored bonus once and then calls `_clear_prepare_state(actor)`. Response/general non-movement action attempts clear preparation after their attempt, including insufficient-resource and interruption outcomes. `basic_stance` itself replaces the state with a fresh preparation instead of clearing it.

- [ ] **Step 7: Run focused Godot verifier**

Run:

```bash
godot --headless --path . --script res://tests/verify_prepare_momentum.gd
```

Expected: PASS for all preparation lifetime and momentum-cap cases.

- [ ] **Step 8: Commit**

```bash
git add src/combat/combat_resolution_engine.gd data/combat/combat_resolution_preview.json tests/verify_prepare_momentum.gd
git commit -m "feat: let prepare empower meditation and persist through movement"
```

---

### Task 4: Auto-place all selected cards and preserve ultimate refunds

**Files:**
- Modify: `src/ui/action_timing_panel.gd`
- Modify: `src/combat/combat_board_preview.gd`
- Test: `tests/verify_auto_card_placement.gd`

**Interfaces:**
- Produces: `ActionTimingPanel.find_earliest_open_anchor(span: int) -> int` and `CombatBoardPreview._auto_place_selected_card(definition: Dictionary) -> bool`.
- Consumes: `place_card`, `_can_reserve_ultimate`, `_reserve_ultimate_at`, `_refund_ultimate_reservation`, `_begin_targeting_for_anchor`.

- [ ] **Step 1: Add earliest contiguous range discovery**

```gdscript
func find_earliest_open_anchor(span: int) -> int:
    var required := maxi(1, span)
    for start_value in get_current_bundle_indices():
        var start := int(start_value)
        var fits := true
        for offset in range(required):
            var timing_index := start + offset
            if not is_index_actionable(timing_index) or has_assignment_at(timing_index):
                fits = false
                break
        if fits:
            return start
    return 0
```

- [ ] **Step 2: Add a single automatic placement path**

```gdscript
func _auto_place_selected_card(definition: Dictionary) -> bool:
    var span := maxi(1, int(definition.get("action_slots", 1)))
    var anchor := action_timing_panel.find_earliest_open_anchor(span)
    if anchor <= 0:
        _log_auto_placement_failure()
        return false

    var is_ultimate := str(definition.get("source", "")) == "ultimate"
    if is_ultimate and not _can_reserve_ultimate(definition):
        _log_ultimate_reservation_failure()
        return false

    if not action_timing_panel.place_card(definition, anchor):
        _log_auto_placement_failure()
        return false

    if is_ultimate:
        _reserve_ultimate_at(anchor)

    _append_placement_log(definition, anchor, span, is_ultimate)
    _clear_action_selection()
    _clear_card_detail()
    if not _begin_targeting_for_anchor(anchor):
        _begin_next_pending_target()
    return true
```

- [ ] **Step 3: Call automatic placement from basic-card selection**

After duplicate-selection cancellation checks:

```gdscript
_selected_action_definition = definition.duplicate(true)
_auto_place_selected_card(_selected_action_definition)
```

Do not require a timing-slot click for placement.

- [ ] **Step 4: Call the same path from ultimate selection**

Replace “select then click a slot” behavior with:

```gdscript
var definition := _ultimate_definitions[index].duplicate(true)
_auto_place_selected_card(definition)
```

- [ ] **Step 5: Keep slot clicks for removal and refunds**

The occupied-slot branch remains authoritative:

```gdscript
var removed := action_timing_panel.remove_at(timing_index)
if was_ultimate and not removed.is_empty():
    _refund_ultimate_reservation(removed)
```

Empty-slot clicks perform no placement when no targeting interaction is active.

- [ ] **Step 6: Run focused verifier**

Run:

```bash
godot --headless --path . --script res://tests/verify_auto_card_placement.gd
```

Expected: PASS for earliest placement, contiguous-range rejection, ultimate consumption and refund.

- [ ] **Step 7: Commit**

```bash
git add src/ui/action_timing_panel.gd src/combat/combat_board_preview.gd tests/verify_auto_card_placement.gd
git commit -m "feat: auto place cards in earliest open timings"
```

---

### Task 5: Synchronize contracts and run the full stack

**Files:**
- Modify: `tests/check_canonical_combat_docs.py`
- Modify: `.github/reference-freshness.json`
- Modify: `.github/canonical-combat-impact-map.json`
- Modify: `docs/05_COMBAT_POC_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`

**Interfaces:**
- Consumes: final product behavior from Tasks 2–4.
- Produces: canonical documentation and complete CI evidence.

- [ ] **Step 1: Register changed consumers in freshness and impact-map contracts**

Add the new tests and changed engine/UI/data paths with consumers `docs/02`, `docs/05`, `docs/08`, and `docs/09`.

- [ ] **Step 2: Update canonical docs**

Document:

```text
카드 선택 즉시 가장 앞의 유효 연속 빈 수에 배치한다.
절초 예약은 진행 전 취소 가능하며 기세 5를 반환한다.
[준비]는 이동을 건너 유지되고 명상을 강화해 절초 기세 1을 준다.
다중 슬롯 실행 전 점유 수는 [전조]다.
```

- [ ] **Step 3: Run PR Validation**

Expected: all static contracts PASS on the final product head.

- [ ] **Step 4: Run Full Validation once on the exact final head**

Expected jobs:

```text
ubuntu-latest-python-3.11
ubuntu-latest-python-3.12
windows-latest-python-3.11
windows-latest-python-3.12
ubuntu-godot-headless
```

- [ ] **Step 5: Confirm all new and existing Godot verifier steps pass**

Required new steps:

```text
Verify prepare momentum
Verify auto card placement
```

Required regressions include existing combat, ultimate, accessibility, AI, hypothesis, summary and review-gate verifiers.

- [ ] **Step 6: Commit documentation/status closeout**

```bash
git add .github/reference-freshness.json .github/canonical-combat-impact-map.json tests/check_canonical_combat_docs.py docs/02_COMBAT_RULES.md docs/05_COMBAT_POC_SPEC.md docs/08_TEST_CHECKLIST.md docs/09_COMBAT_SYSTEM_ARCHITECTURE.md '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md'
git commit -m "docs: synchronize prepare and automatic placement contracts"
```

- [ ] **Step 7: Open a stacked Draft PR**

Base: `agent/repeat-poc-a3-review-ui-closeout`

Title:

```text
feat: 준비 강화와 카드 자동 배치
```

The PR body records Red/Green run numbers, final head SHA, full validation jobs, ultimate refund behavior and the unchanged human-validation boundary.
