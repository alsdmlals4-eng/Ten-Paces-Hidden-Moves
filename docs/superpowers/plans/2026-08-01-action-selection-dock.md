# Action Selection Dock Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the existing Godot combat PoC with a product-ready `기초 / 무공 / 절초` action-selection dock while preserving the current 10-cell battlefield, 3/3/4 timing model, automatic placement, targeting, ultimate reservation, resolution, and review behavior.

**Architecture:** Keep `CombatResolutionEngine`, `ActionTimingPanel`, the current automatic-placement path, and the existing combat review pipeline as authoritative. Introduce a normalized action ViewModel adapter, a dedicated `ActionSelectionDock`, focused source panels, and a common placement controller. Migrate responsibilities out of `CombatBoardPreview` incrementally so every task leaves the PoC runnable and testable.

**Tech Stack:** Godot 4.7, GDScript, JSON runtime fixtures, headless Godot verifier scripts, Python static contract tests, GitHub Actions.

## Global Constraints

- Work mode remains `PLAN` until explicit BUILD approval.
- Runtime implementation must begin only on an isolated worktree created at execution time.
- Preserve the executable entry scene `res://scenes/combat/combat_board_preview.tscn` until the final migration task.
- Preserve the round timing sequence `[3, 3, 4]` and 10 total timings.
- Preserve current-bundle-only editing and post-commit locking.
- Preserve the basic action set: 이동, 보법, 막기, 회피, 속공, 강공, 명상, 준비.
- Preserve automatic placement at the earliest valid contiguous timing range.
- Preserve move-tile and attack-direction targeting.
- Preserve shared ultimate momentum `0..5`, reservation on placement, refund before commit, and no refund after commit.
- Martial manuals are growth/grouping units and are never directly placeable.
- The placeable martial unit is an unlocked technique.
- Multi-timing actions render as one linked block with `[전조]` stages and a final `[실행]` stage.
- Do not expose opponent hidden plans or exact-answer recommendations.
- Do not load `docs/planning-data/*.json` directly at runtime.
- Product P0 removes virtual `준비+막기` and `준비+회피` cards; `준비` remains an independent action.
- Human validation is not replaced by automated validation.

---

## File Structure

### New files

- `src/ui/action_selection/action_view_model_adapter.gd` — normalizes basic, martial, and ultimate definitions into one UI-facing schema.
- `src/ui/action_selection/action_placement_controller.gd` — owns selection-to-placement, failure codes, targeting handoff, removal, movement, and ultimate reservation coordination.
- `src/ui/action_selection/action_selection_dock.gd` — owns source tabs, active panel, input locking, and outward signals.
- `src/ui/action_selection/basic_action_panel.gd` — renders the eight basic actions in a 4×2 grid.
- `src/ui/action_selection/martial_action_panel.gd` — renders owned manuals and the selected manual’s unlocked/locked techniques.
- `src/ui/action_selection/ultimate_action_panel.gd` — renders basic and mastery ultimates with momentum and lock states.
- `src/ui/action_selection/action_detail_panel.gd` — extends the current card-detail behavior with manual, mastery, telegraph, execution, hit, movement, and ultimate reservation fields.
- `src/ui/action_selection/linked_action_block.gd` — visual block spanning one or more timing slots.
- `scenes/ui/action_selection/action_selection_dock.tscn`
- `scenes/ui/action_selection/basic_action_panel.tscn`
- `scenes/ui/action_selection/martial_action_panel.tscn`
- `scenes/ui/action_selection/ultimate_action_panel.tscn`
- `scenes/ui/action_selection/action_detail_panel.tscn`
- `scenes/ui/action_selection/linked_action_block.tscn`
- `data/combat/action_selection_poc.json` — runtime PoC fixture containing four owned manuals, their visible technique states, and ultimate entries.
- `tests/verify_action_view_model_adapter.gd`
- `tests/verify_action_selection_dock.gd`
- `tests/verify_martial_action_panel.gd`
- `tests/verify_ultimate_action_panel.gd`
- `tests/verify_linked_action_blocks.gd`
- `tests/verify_action_repositioning.gd`
- `tests/check_action_selection_contract.py`

### Modified files

- `src/combat/combat_board_preview.gd` — replace direct tray/ultimate/detail assembly with `ActionSelectionDock`; retain combat orchestration.
- `src/combat/combat_board_preview_auto.gd` — delegate automatic placement and targeting to `ActionPlacementController`.
- `src/ui/action_timing_panel.gd` — expose placement move APIs and linked-block snapshots without recalculating rules.
- `src/ui/action_timing_slot.gd` — stop repeating action names per occupied slot; expose stage and geometry data to linked blocks.
- `src/ui/basic_card_tray.gd` — remove product-facing virtual combo creation from the new path; keep legacy compatibility until final cleanup.
- `src/ui/card_detail_panel.gd` — remain temporarily for legacy tests, then become a compatibility wrapper around `ActionDetailPanel`.
- `data/cards/basic_cards.json` — no balance changes; only add missing normalized fields if adapter tests prove necessary.
- `data/cards/ultimate_cards.json` — no balance changes; only add source/manual metadata required by the adapter.
- `docs/05_COMBAT_POC_SPEC.md`
- `docs/08_TEST_CHECKLIST.md`
- `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- `.github/reference-freshness.json`
- `.github/canonical-combat-impact-map.json`
- `.github/workflows/pr-validation.yml` only if the new static checker is not automatically discovered.

---

### Task 1: Normalize all action sources into one ViewModel

**Files:**
- Create: `src/ui/action_selection/action_view_model_adapter.gd`
- Create: `data/combat/action_selection_poc.json`
- Create: `tests/verify_action_view_model_adapter.gd`
- Modify: `data/cards/ultimate_cards.json`

**Interfaces:**
- Consumes: basic definitions from `data/cards/basic_cards.json`, ultimate definitions from `data/cards/ultimate_cards.json`, owned-manual state from `data/combat/action_selection_poc.json`.
- Produces:
  - `ActionViewModelAdapter.build_basic_actions() -> Array[Dictionary]`
  - `ActionViewModelAdapter.build_owned_manuals() -> Array[Dictionary]`
  - `ActionViewModelAdapter.build_ultimate_actions(momentum: int) -> Array[Dictionary]`
  - normalized action fields: `id`, `name`, `source_kind`, `source_id`, `source_label`, `category`, `action_slots`, `stamina_cost`, `internal_cost`, `momentum_cost`, `range_text`, `targeting_mode`, `telegraph_count`, `execution_count`, `locked`, `lock_reason`, `tags`, `detail`.

- [ ] **Step 1: Write the failing adapter verifier**

Create `tests/verify_action_view_model_adapter.gd` with assertions that:

```gdscript
extends SceneTree

func _init() -> void:
    var adapter_script := load("res://src/ui/action_selection/action_view_model_adapter.gd")
    assert(adapter_script != null)
    var adapter = adapter_script.new()

    var basics: Array = adapter.build_basic_actions()
    assert(basics.size() == 8)
    assert(str(basics[0].get("source_kind", "")) == "basic")

    var manuals: Array = adapter.build_owned_manuals()
    assert(manuals.size() == 4)
    for manual_value in manuals:
        var manual: Dictionary = manual_value
        assert(not str(manual.get("manual_id", "")).is_empty())
        assert((manual.get("techniques", []) as Array).size() >= 1)
        for technique_value in manual.get("techniques", []):
            var technique: Dictionary = technique_value
            assert(str(technique.get("source_kind", "")) == "martial")
            assert(str(technique.get("source_id", "")) == str(manual.get("manual_id", "")))

    var locked_ultimates: Array = adapter.build_ultimate_actions(4)
    assert(locked_ultimates.all(func(value): return bool((value as Dictionary).get("locked", false))))

    var ready_ultimates: Array = adapter.build_ultimate_actions(5)
    assert(ready_ultimates.any(func(value): return not bool((value as Dictionary).get("locked", true))))

    print("verify_action_view_model_adapter: PASS")
    quit(0)
```

- [ ] **Step 2: Run the verifier and confirm RED**

Run:

```bash
godot --headless --path . --script res://tests/verify_action_view_model_adapter.gd
```

Expected: FAIL because `action_view_model_adapter.gd` does not exist.

- [ ] **Step 3: Create the runtime PoC manual fixture**

Create `data/combat/action_selection_poc.json` with exactly four owned manuals. Each manual must contain:

```json
{
  "manual_id": "manual_flowing_cloud_sword",
  "name": "유운검결",
  "mastery": 3,
  "role_tags": ["연격", "이동"],
  "ultimate_unlocked": false,
  "techniques": [
    {
      "id": "technique_flowing_cloud_threefold",
      "name": "유운삼첩",
      "unlock_mastery": 3,
      "action_slots": 2,
      "stamina_cost": 1,
      "internal_cost": 1,
      "range_text": "1",
      "targeting_mode": "attack_direction",
      "category": "attack",
      "hits": 3,
      "tags": ["연격 3"]
    },
    {
      "id": "technique_falling_shadow_pursuit",
      "name": "낙영추검",
      "unlock_mastery": 7,
      "action_slots": 2,
      "stamina_cost": 1,
      "internal_cost": 2,
      "range_text": "1",
      "targeting_mode": "attack_direction",
      "category": "attack",
      "hits": 1,
      "tags": ["돌진", "필중 1"]
    }
  ]
}
```

The other three manuals may use PoC placeholder content, but every field above must be concrete and canonically formatted.

- [ ] **Step 4: Implement the adapter minimally**

Implement `class_name ActionViewModelAdapter` with strict file loading, typed return arrays, and helper methods:

```gdscript
func build_basic_actions() -> Array[Dictionary]
func build_owned_manuals() -> Array[Dictionary]
func build_ultimate_actions(momentum: int) -> Array[Dictionary]
func _normalize_action(definition: Dictionary, source_kind: String, source_id: String, source_label: String) -> Dictionary
```

`telegraph_count` must equal `maxi(0, action_slots - 1)` and `execution_count` must equal `1` for every placeable action.

- [ ] **Step 5: Run the verifier and confirm GREEN**

Run the command from Step 2.

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/ui/action_selection/action_view_model_adapter.gd data/combat/action_selection_poc.json data/cards/ultimate_cards.json tests/verify_action_view_model_adapter.gd
git commit -m "feat: normalize combat action sources"
```

---

### Task 2: Build the ActionSelectionDock shell and source-state contract

**Files:**
- Create: `src/ui/action_selection/action_selection_dock.gd`
- Create: `scenes/ui/action_selection/action_selection_dock.tscn`
- Create: `tests/verify_action_selection_dock.gd`

**Interfaces:**
- Consumes: `ActionViewModelAdapter` from Task 1.
- Produces:
  - signal `action_selected(definition: Dictionary)`
  - signal `detail_requested(definition: Dictionary, pinned: bool)`
  - signal `detail_cleared()`
  - `set_active_source(source: String) -> void`
  - `set_interaction_state(state: String) -> void`
  - `set_runtime_context(context: Dictionary) -> void`
  - `get_dock_snapshot() -> Dictionary`

- [ ] **Step 1: Write a failing dock verifier**

Verify the dock exposes three sources `basic`, `martial`, `ultimate`, defaults to `basic`, preserves the active source across `next_bundle_ready`, resets to `basic` on `new_combat`, and disables switching during `targeting`, `committed`, `resolving`, `presenting_result`, and `review`.

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_action_selection_dock.gd
```

Expected: FAIL because the scene and script do not exist.

- [ ] **Step 3: Build the scene shell**

Create a `Control` root with:

```text
ActionSelectionDock
├─ SourceTabs: HBoxContainer
│  ├─ BasicTab: Button
│  ├─ MartialTab: Button
│  └─ UltimateTab: Button
├─ ContentHost: Control
└─ DetailHost: Control
```

The three tab buttons must include both text and a non-color selected indicator.

- [ ] **Step 4: Implement source and lock state**

Use exact state constants:

```gdscript
const SOURCE_BASIC := "basic"
const SOURCE_MARTIAL := "martial"
const SOURCE_ULTIMATE := "ultimate"
const LOCKED_STATES := ["targeting", "committed", "resolving", "presenting_result", "review"]
```

Do not instantiate source panels yet; ContentHost may contain placeholders during this task.

- [ ] **Step 5: Run verifier and confirm GREEN**

Run the command from Step 2.

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/ui/action_selection/action_selection_dock.gd scenes/ui/action_selection/action_selection_dock.tscn tests/verify_action_selection_dock.gd
git commit -m "feat: add action selection dock shell"
```

---

### Task 3: Replace the legacy basic tray with a 4×2 BasicActionPanel

**Files:**
- Create: `src/ui/action_selection/basic_action_panel.gd`
- Create: `scenes/ui/action_selection/basic_action_panel.tscn`
- Create: `tests/verify_basic_action_panel.gd`
- Modify: `src/ui/action_selection/action_selection_dock.gd`
- Modify: `src/ui/basic_card_tray.gd`

**Interfaces:**
- Consumes: normalized basic actions from `ActionViewModelAdapter.build_basic_actions()`.
- Produces:
  - signal `action_selected(definition: Dictionary)`
  - signal `action_hovered(definition: Dictionary)`
  - signal `action_unhovered(action_id: String)`
  - `set_actions(actions: Array[Dictionary]) -> void`
  - `set_interactions_enabled(enabled: bool) -> void`
  - `get_panel_snapshot() -> Dictionary`

- [ ] **Step 1: Write failing basic-panel verifier**

Assert eight actions, exact 4×2 logical coordinates, no scroll container, each action has a focusable control, and selecting `basic_heavy_attack` emits an action with `action_slots == 2`.

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_basic_action_panel.gd
```

- [ ] **Step 3: Build BasicActionPanel**

Use `GridContainer.columns = 4`. Each item must show action name, slot count, stamina/internal cost, and range/move range. Full effects remain in the detail panel.

- [ ] **Step 4: Remove virtual combo creation from the product path**

Add a compatibility flag to `BasicCardTray`:

```gdscript
var virtual_combo_enabled := true
func set_virtual_combo_enabled(enabled: bool) -> void:
    virtual_combo_enabled = enabled
```

The new dock must set this behavior to `false`; legacy tests can continue using the old default until final cleanup.

- [ ] **Step 5: Wire BasicActionPanel into ActionSelectionDock**

Forward selection and detail signals without changing definitions.

- [ ] **Step 6: Run verifier and existing basic-card regressions**

```bash
godot --headless --path . --script res://tests/verify_basic_action_panel.gd
godot --headless --path . --script res://tests/verify_auto_card_placement.gd
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add src/ui/action_selection/basic_action_panel.gd scenes/ui/action_selection/basic_action_panel.tscn src/ui/action_selection/action_selection_dock.gd src/ui/basic_card_tray.gd tests/verify_basic_action_panel.gd
git commit -m "feat: add product basic action grid"
```

---

### Task 4: Add owned-manual and unlocked-technique navigation

**Files:**
- Create: `src/ui/action_selection/martial_action_panel.gd`
- Create: `scenes/ui/action_selection/martial_action_panel.tscn`
- Create: `tests/verify_martial_action_panel.gd`
- Modify: `src/ui/action_selection/action_selection_dock.gd`

**Interfaces:**
- Consumes: `ActionViewModelAdapter.build_owned_manuals()`.
- Produces:
  - signal `technique_selected(definition: Dictionary)`
  - signal `manual_focused(manual: Dictionary)`
  - `set_manuals(manuals: Array[Dictionary]) -> void`
  - `select_manual(manual_id: String) -> bool`
  - `get_selected_manual_id() -> String`
  - `get_panel_snapshot() -> Dictionary`

- [ ] **Step 1: Write failing martial-panel verifier**

Assert exactly four visible owned manuals, first manual selected by default, unlocked techniques enabled, locked techniques disabled but focusable for details, and manual controls never emit `technique_selected`.

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_martial_action_panel.gd
```

- [ ] **Step 3: Build manual list and technique list**

Use a fixed four-item manual row for P0. Each manual item shows name, mastery, role tags, unlocked technique count, and ultimate state. The lower technique region shows unlocked techniques first and locked techniques after them.

- [ ] **Step 4: Implement lock copy and detail behavior**

Locked technique text must use the exact pattern:

```text
{기술명} · {unlock_mastery}성 해금 · 현재 {current_mastery}성
```

Locked techniques must never emit `technique_selected`.

- [ ] **Step 5: Wire MartialActionPanel into ActionSelectionDock**

Forward unlocked technique selections to `action_selected`.

- [ ] **Step 6: Run verifier and confirm GREEN**

Run the command from Step 2.

- [ ] **Step 7: Commit**

```bash
git add src/ui/action_selection/martial_action_panel.gd scenes/ui/action_selection/martial_action_panel.tscn src/ui/action_selection/action_selection_dock.gd tests/verify_martial_action_panel.gd
git commit -m "feat: add martial manual technique navigation"
```

---

### Task 5: Integrate ultimate actions and reservation states

**Files:**
- Create: `src/ui/action_selection/ultimate_action_panel.gd`
- Create: `scenes/ui/action_selection/ultimate_action_panel.tscn`
- Create: `tests/verify_ultimate_action_panel.gd`
- Modify: `src/ui/action_selection/action_selection_dock.gd`

**Interfaces:**
- Consumes: `ActionViewModelAdapter.build_ultimate_actions(momentum)` and runtime reservation snapshots.
- Produces:
  - signal `ultimate_selected(definition: Dictionary)`
  - `set_momentum(current: int, maximum: int) -> void`
  - `set_reservations(reservations: Array[Dictionary]) -> void`
  - `get_panel_snapshot() -> Dictionary`

- [ ] **Step 1: Write failing ultimate-panel verifier**

Assert momentum `4/5` disables every ultimate with reason `기세 4/5`, momentum `5/5` enables unlocked ultimates, a mastery-locked ultimate remains disabled, and a reserved ultimate displays its timing range.

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_ultimate_action_panel.gd
```

- [ ] **Step 3: Build UltimateActionPanel**

Show shared momentum as text plus five segments. Render basic ultimates and mastery ultimates in one list, preserving their origin labels.

- [ ] **Step 4: Implement reservation display**

Reservation text must use:

```text
{start_timing}~{end_timing}수 예약
```

The panel must not mutate momentum itself; it only reflects controller state.

- [ ] **Step 5: Wire into ActionSelectionDock**

Forward enabled ultimate selections to `action_selected`.

- [ ] **Step 6: Run verifier and existing ultimate regression**

```bash
godot --headless --path . --script res://tests/verify_ultimate_action_panel.gd
godot --headless --path . --script res://tests/verify_ultimate_ui.gd
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add src/ui/action_selection/ultimate_action_panel.gd scenes/ui/action_selection/ultimate_action_panel.tscn src/ui/action_selection/action_selection_dock.gd tests/verify_ultimate_action_panel.gd
git commit -m "feat: integrate ultimate action source panel"
```

---

### Task 6: Extract a common ActionPlacementController

**Files:**
- Create: `src/ui/action_selection/action_placement_controller.gd`
- Create: `tests/verify_action_placement_controller.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `src/ui/action_timing_panel.gd`

**Interfaces:**
- Consumes:
  - `ActionTimingPanel.find_earliest_open_anchor(span: int) -> int`
  - `ActionTimingPanel.place_card(definition: Dictionary, start_index: int) -> bool`
  - ultimate reservation callbacks supplied by `CombatBoardPreview`.
- Produces:
  - signal `placement_succeeded(result: Dictionary)`
  - signal `placement_failed(code: String, message: String)`
  - signal `targeting_requested(anchor_index: int)`
  - `select_and_place(definition: Dictionary) -> bool`
  - `remove_at(timing_index: int) -> Dictionary`
  - `move_placement(anchor_index: int, new_anchor_index: int) -> bool`
  - `set_locked(locked: bool) -> void`

- [ ] **Step 1: Write failing controller verifier**

Cover:

```text
1-slot basic placement
2-slot martial placement
3-slot ultimate placement
NO_CONTIGUOUS_TIMINGS
MOMENTUM_INSUFFICIENT
TARGETING_IN_PROGRESS
removal refund before commit
no refund after commit
```

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_action_placement_controller.gd
```

- [ ] **Step 3: Implement controller with injected callbacks**

Use explicit callables:

```gdscript
func configure(
    timing_panel: ActionTimingPanel,
    can_reserve_ultimate: Callable,
    reserve_ultimate: Callable,
    refund_ultimate: Callable,
    begin_targeting: Callable
) -> void
```

The controller must not calculate combat outcomes.

- [ ] **Step 4: Delegate `combat_board_preview_auto.gd`**

Replace `_auto_place_selected_card` internals with controller calls. Preserve existing log text through `placement_succeeded` and `placement_failed` handlers.

- [ ] **Step 5: Run focused and legacy placement tests**

```bash
godot --headless --path . --script res://tests/verify_action_placement_controller.gd
godot --headless --path . --script res://tests/verify_auto_card_placement.gd
godot --headless --path . --script res://tests/verify_combat_pointer_lock.gd
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/ui/action_selection/action_placement_controller.gd src/combat/combat_board_preview_auto.gd src/ui/action_timing_panel.gd tests/verify_action_placement_controller.gd
git commit -m "refactor: centralize action placement control"
```

---

### Task 7: Render multi-timing actions as linked blocks

**Files:**
- Create: `src/ui/action_selection/linked_action_block.gd`
- Create: `scenes/ui/action_selection/linked_action_block.tscn`
- Create: `tests/verify_linked_action_blocks.gd`
- Modify: `src/ui/action_timing_panel.gd`
- Modify: `src/ui/action_timing_slot.gd`

**Interfaces:**
- Consumes: placement snapshots containing `anchor_index`, `span`, `indices`, and normalized definitions.
- Produces:
  - signal `block_activated(anchor_index: int)`
  - signal `block_drag_requested(anchor_index: int)`
  - `ActionTimingPanel.get_linked_block_snapshots() -> Array[Dictionary]`
  - `ActionTimingPanel.get_anchor_rect(anchor_index: int) -> Rect2`

- [ ] **Step 1: Write failing linked-block verifier**

Assert:

- a 1-slot action creates one block with `telegraph_count == 0`;
- a 2-slot action creates one block spanning two slots with stage labels `[전조, 실행]`;
- a 3-slot action creates one block spanning three slots with `[전조, 전조, 실행]`;
- occupied timing slots no longer repeat the action name;
- activating any block part resolves to the anchor index.

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_linked_action_blocks.gd
```

- [ ] **Step 3: Make timing slots stage-only**

For assigned slots, `ActionTimingSlot` must show only local timing and stage/status. The linked block owns the action name, source label, border, hover, focus, and drag surface.

- [ ] **Step 4: Add linked block layer to ActionTimingPanel**

Blocks must be laid out from actual slot rectangles and rebuilt on placement, removal, resize, and bundle advancement.

- [ ] **Step 5: Run verifier and timing regressions**

```bash
godot --headless --path . --script res://tests/verify_linked_action_blocks.gd
godot --headless --path . --script res://tests/verify_combat_board.gd
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/ui/action_selection/linked_action_block.gd scenes/ui/action_selection/linked_action_block.tscn src/ui/action_timing_panel.gd src/ui/action_timing_slot.gd tests/verify_linked_action_blocks.gd
git commit -m "feat: render linked multi-timing actions"
```

---

### Task 8: Add pre-commit linked-block repositioning

**Files:**
- Create: `tests/verify_action_repositioning.gd`
- Modify: `src/ui/action_selection/action_placement_controller.gd`
- Modify: `src/ui/action_timing_panel.gd`
- Modify: `src/ui/action_selection/linked_action_block.gd`

**Interfaces:**
- Consumes: placement controller and linked-block anchor events.
- Produces:
  - `ActionTimingPanel.can_move_placement(anchor_index: int, new_anchor_index: int) -> bool`
  - `ActionTimingPanel.move_placement(anchor_index: int, new_anchor_index: int) -> bool`
  - `ActionTimingPanel.get_valid_move_anchors(anchor_index: int) -> PackedInt32Array`

- [ ] **Step 1: Write failing repositioning verifier**

Cover moving a 2-slot action one timing earlier and later, rejection across bundle boundaries, collision rejection, original placement restoration after invalid movement, targeting lock rejection, commit lock rejection, and ultimate reservation preservation during valid movement.

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_action_repositioning.gd
```

- [ ] **Step 3: Implement atomic move behavior**

Movement must validate before mutation. Use this sequence:

```text
read original placement
calculate candidate indices
validate bundle/actionable/collision/lock
move placement atomically
revalidate target and resources
emit one placement_changed snapshot
```

- [ ] **Step 4: Add block move commands**

Provide mouse drag hooks and keyboard commands `move_previous`, `move_next`, and `remove`. Input mappings may use existing `ui_left`, `ui_right`, `ui_cancel`, and `ui_accept`; do not add custom mappings unless required by an existing conflict.

- [ ] **Step 5: Run verifier and regressions**

```bash
godot --headless --path . --script res://tests/verify_action_repositioning.gd
godot --headless --path . --script res://tests/verify_auto_card_placement.gd
godot --headless --path . --script res://tests/verify_ultimate_ui.gd
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/ui/action_selection/action_placement_controller.gd src/ui/action_timing_panel.gd src/ui/action_selection/linked_action_block.gd tests/verify_action_repositioning.gd
git commit -m "feat: reposition planned action blocks"
```

---

### Task 9: Expand the action detail panel

**Files:**
- Create: `src/ui/action_selection/action_detail_panel.gd`
- Create: `scenes/ui/action_selection/action_detail_panel.tscn`
- Create: `tests/verify_action_detail_panel.gd`
- Modify: `src/ui/action_selection/action_selection_dock.gd`
- Modify: `src/ui/card_detail_panel.gd`

**Interfaces:**
- Consumes: normalized action ViewModels and manual ViewModels.
- Produces:
  - `show_action(definition: Dictionary, pinned: bool) -> void`
  - `show_manual(manual: Dictionary, pinned: bool) -> void`
  - `clear_detail() -> void`
  - `get_detail_snapshot() -> Dictionary`

- [ ] **Step 1: Write failing detail-panel verifier**

Assert common fields for basic actions, manual/mastery/telegraph/execution/hits for martial techniques, momentum/reservation/refund fields for ultimates, and mastery lineage for manual details.

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_action_detail_panel.gd
```

- [ ] **Step 3: Implement ActionDetailPanel**

Retain hover preview, click pin, blank-click close, and scroll behavior. Use exact labels:

```text
출처
수 점유
전조
실행
기력
내력
절초기세
사거리
타격
이동 시점
해금 성급
현재 성급
```

Only display applicable rows.

- [ ] **Step 4: Add compatibility wrapper**

Make `CardDetailPanel` delegate to `ActionDetailPanel` for legacy callers without changing its public methods in this task.

- [ ] **Step 5: Run verifier and accessibility regression**

```bash
godot --headless --path . --script res://tests/verify_action_detail_panel.gd
godot --headless --path . --script res://tests/verify_combat_assistive_labels.gd
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/ui/action_selection/action_detail_panel.gd scenes/ui/action_selection/action_detail_panel.tscn src/ui/action_selection/action_selection_dock.gd src/ui/card_detail_panel.gd tests/verify_action_detail_panel.gd
git commit -m "feat: expand combat action details"
```

---

### Task 10: Integrate ActionSelectionDock into CombatBoardPreview

**Files:**
- Modify: `src/combat/combat_board_preview.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `scenes/combat/combat_board_preview.tscn`
- Create: `tests/verify_combat_action_selection_integration.gd`

**Interfaces:**
- Consumes: `ActionSelectionDock`, `ActionPlacementController`, existing combat state, timing panel, HUD, targeting, logs, and review panel.
- Produces: one integrated combat flow using all three action sources.

- [ ] **Step 1: Write failing integration verifier**

The verifier must instantiate the real combat scene and prove:

```text
entry source is basic
basic action can auto-place
martial technique can auto-place
ultimate locks below momentum 5
ultimate reserves at momentum 5
source tabs lock during targeting
source tabs lock during resolution and review
next bundle preserves active source
restart resets source to basic
```

- [ ] **Step 2: Run and confirm RED**

```bash
godot --headless --path . --script res://tests/verify_combat_action_selection_integration.gd
```

- [ ] **Step 3: Replace direct lower-panel assembly**

Instantiate `ActionSelectionDock` in `_build_structure()`. Remove product use of `BasicCardTray`, `ultimate_list_panel`, and the direct `CardDetailPanel` overlay while retaining compatibility nodes only if existing tests still require them.

- [ ] **Step 4: Bind runtime context**

On state updates, send:

```gdscript
{
    "interaction_state": _presentation_state,
    "round_number": int(combat_state.get("round_number", 1)),
    "bundle_index": int(combat_state.get("bundle_index", 1)),
    "momentum": int(((combat_state.get("player", {}) as Dictionary).get("momentum", [0, 5]) as Array)[0]),
    "momentum_max": 5,
    "reservations": _build_ultimate_reservation_snapshot()
}
```

- [ ] **Step 5: Update keyboard focus order and accessibility semantics**

Focus order must be:

```text
source tabs
active source list
active detail panel controls
linked timing blocks
progress button
playback/accessibility controls
```

- [ ] **Step 6: Run integration and full existing Godot verifier set**

At minimum:

```bash
godot --headless --path . --script res://tests/verify_combat_action_selection_integration.gd
godot --headless --path . --script res://tests/verify_combat_board.gd
godot --headless --path . --script res://tests/verify_auto_card_placement.gd
godot --headless --path . --script res://tests/verify_ultimate_ui.gd
godot --headless --path . --script res://tests/verify_combat_focus_order.gd
godot --headless --path . --script res://tests/verify_combat_keyboard_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_layout_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_presentation_liveness.gd
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add src/combat/combat_board_preview.gd src/combat/combat_board_preview_auto.gd scenes/combat/combat_board_preview.tscn tests/verify_combat_action_selection_integration.gd
git commit -m "feat: integrate product action selection dock"
```

---

### Task 11: Add static contracts and CI coverage

**Files:**
- Create: `tests/check_action_selection_contract.py`
- Modify: `.github/reference-freshness.json`
- Modify: `.github/canonical-combat-impact-map.json`
- Modify: `.github/workflows/pr-validation.yml` only if required.

**Interfaces:**
- Consumes: final file paths and metadata from Tasks 1–10.
- Produces: static CI failure for missing source tabs, direct manual placement, missing 3/3/4 linkage, missing adapter boundary, or reintroduced virtual combo product behavior.

- [ ] **Step 1: Write failing Python contract tests**

Check for:

```text
ActionSelectionDock sources basic|martial|ultimate
ActionViewModelAdapter runtime paths only
manual_is_not_directly_placeable marker
linked block stage labels telegraph|execution
ActionPlacementController common placement path
virtual_combo_enabled false in product integration
runtime does not reference docs/planning-data
```

- [ ] **Step 2: Run and confirm RED where markers are missing**

```bash
python tests/check_action_selection_contract.py
```

- [ ] **Step 3: Add exact metadata/markers to production files**

Use `set_meta` or constants only where they clarify a tested contract; do not add redundant markers for behavior already directly inspectable.

- [ ] **Step 4: Register freshness and impact-map consumers**

Register new UI, test, data, and documentation paths against `docs/02`, `docs/05`, `docs/08`, and `docs/09`.

- [ ] **Step 5: Run static validation**

```bash
python tests/check_action_selection_contract.py
python -m unittest tests.test_poc_planning_data -v
python tools/check_canonical_reference_freshness.py --root . --config .github/reference-freshness.json
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add tests/check_action_selection_contract.py .github/reference-freshness.json .github/canonical-combat-impact-map.json .github/workflows/pr-validation.yml
git commit -m "test: enforce action selection contracts"
```

---

### Task 12: Synchronize canonical documentation and close validation

**Files:**
- Modify: `docs/05_COMBAT_POC_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/superpowers/specs/2026-08-01-action-selection-dock-design.md` only for evidence/status fields.

**Interfaces:**
- Consumes: final implemented behavior and exact test evidence.
- Produces: synchronized canonical status and a Codex-ready handoff boundary.

- [ ] **Step 1: Update implementation status**

Record:

```yaml
action_selection_dock: IMPLEMENTED
basic_actions: 8
martial_flow: MANUAL_TO_UNLOCKED_TECHNIQUE
ultimate_source: SHARED_MOMENTUM_0_TO_5
auto_placement: EARLIEST_VALID_CONTIGUOUS
repositioning: CONNECTED_BLOCK_PRE_COMMIT
multi_timing_display: TELEGRAPH_TO_EXECUTION_LINKED_BLOCK
virtual_prepare_response_combo: DISABLED_IN_PRODUCT_P0
human_validation: NOT_RUN
```

- [ ] **Step 2: Add test checklist cases**

Include mouse, keyboard, gamepad, minimum viewport `960×640`, target-lock, momentum reservation, locked technique, source-tab persistence, linked-block movement, review lock, reduced motion, and color-independent state recognition.

- [ ] **Step 3: Run PR Validation on the exact final head**

Expected: all static and scope-aware checks PASS.

- [ ] **Step 4: Run Full Validation once on the exact final head**

Expected jobs:

```text
ubuntu-latest-python-3.11
ubuntu-latest-python-3.12
windows-latest-python-3.11
windows-latest-python-3.12
ubuntu-godot-headless
```

- [ ] **Step 5: Record machine evidence without claiming human approval**

Store workflow run IDs, final SHA, and verifier names. Keep `human_validation: NOT_RUN` until an actual playtest is completed.

- [ ] **Step 6: Commit documentation closeout**

```bash
git add docs/05_COMBAT_POC_SPEC.md docs/08_TEST_CHECKLIST.md docs/09_COMBAT_SYSTEM_ARCHITECTURE.md '[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md' docs/superpowers/specs/2026-08-01-action-selection-dock-design.md
git commit -m "docs: close action selection implementation evidence"
```

---

## Required Human Validation After Machine Green

Run the combat PoC at `1280×800` and `1440×900` with mouse and keyboard. Record observation separately from interview response.

Pass criteria:

- The player identifies `기초 / 무공 / 절초` without explanation.
- The player understands that a manual is selected first and a technique second.
- The player does not attempt to drag a manual into the timeline.
- The player recognizes a 2-slot or 3-slot technique as one action.
- The player distinguishes the basic action `[준비]` from a multi-timing `[전조]`.
- The player can remove and move a linked action before commit.
- The player understands why an ultimate is unavailable at momentum below 5.
- The player sees that removing a reserved ultimate before commit restores momentum.
- The player can complete one full `3 → resolve → 3 → resolve → 4 → resolve` round without hidden-plan leakage or input deadlock.

Failure evidence must produce a follow-up UX issue rather than silent acceptance.

## Plan Self-Review

- Spec coverage: all approved sections map to Tasks 1–12.
- Runtime boundary: planning JSON remains non-runtime; Task 1 uses a dedicated PoC runtime fixture.
- Type consistency: action source names are consistently `basic`, `martial`, `ultimate`.
- Placement consistency: every source uses `ActionPlacementController.select_and_place`.
- Timing consistency: every multi-slot action uses `telegraph_count = action_slots - 1` and one execution stage.
- Ultimate consistency: the panel reflects state; the controller owns reservation/refund coordination.
- Scope consistency: no balance, route, save, AI, or resolution-rule redesign is included.
- Placeholder scan: no TBD, TODO, or unspecified implementation steps remain.
