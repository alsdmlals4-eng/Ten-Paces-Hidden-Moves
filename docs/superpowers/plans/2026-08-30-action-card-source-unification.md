# Action Card Source Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every selectable action source use a shared card grid, remove player-facing board-tile/left-right targeting, and retain martial/ultimate selection without illustrations.

**Architecture:** `ActionChoiceCard` becomes the shared visual and accessibility surface for basic, martial, ultimate and follow-up intent choices. `ActionSelectionDock` owns the active source and temporary intent choice; `ActionTimingPanel` continues to own placement readiness; the resolver receives normalized internal direction values only after the player selects an intent card. Old hidden tray/menu consumers and their active POC contract are retired after current consumers and tests move to the dock.

**Tech Stack:** Godot 4.7 GDScript, `.tscn` Controls, JSON product data, Python `unittest`, Godot headless regression scripts, Hera visible runtime QA.

**Spec:** `docs/superpowers/specs/2026-08-30-action-card-source-unification-design.md`

## Global Constraints

- Preserve the 10-cell logical battlefield, public opening distance 2, `3 → resolve → 3 → resolve → 4 → resolve`, public-state AI boundary, combat formulas, resources, save semantics and ultimate reservation/refund.
- Keep `TEN_BASIC_TECHNIQUE_INK_ATLAS_01` only on basic action cards; martial and ultimate selection cards must have no illustration data dependency or `TextureRect` illustration node.
- Use Korean player-facing copy, with semantic `접근/후퇴` and aim cards instead of numbered target tiles or left/right direction prompts.
- Do not add generated assets or third-party UI/art; keep existing diagonal duel, reveal and VFX consumers unchanged.
- Run RED before every product implementation cycle and keep human, Android, accessibility-user and release performance evidence separately `NOT_RUN`.

---

### Task 1: Lock the current user-approved contract and RED regression

**Files:**
- Create: `tests/test_action_card_source_unification_contract.py`
- Create: `tests/verify_action_card_source_unification.gd`
- Modify: `docs/07_COMBAT_UI_SPEC.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/planning-data/current_user_planning_status.json`

**Interfaces:**
- Consumes: `ActionSelectionDock`, current source panels and `combat_board_poc.json`.
- Produces: executable assertions for card parity, no martial/ultimate art and no active tile-direction targeting contract.

- [ ] **Step 1: Write the failing Python contract test.**

```python
def test_active_combat_contract_uses_card_intents_not_board_tile_direction_picker(self):
    self.assertIn("shared_action_card_grid", read("data/combat/combat_board_poc.json"))
    self.assertNotIn("select_left_or_right_direction", read("data/combat/combat_board_poc.json"))
    self.assertNotIn("select_destination_board_tile", read("data/combat/combat_board_poc.json"))
```

- [ ] **Step 2: Run the new Python test and verify RED.**

Run: `python -m unittest tests.test_action_card_source_unification_contract -v`
Expected: FAIL because current POC data still declares `select_destination_board_tile` and `select_left_or_right_direction`.

- [ ] **Step 3: Write the failing Godot action-card contract.**

```gdscript
_expect(dock.basic_panel.get_panel_snapshot().get("card_surface", "") == "shared_action_card_grid", "Basic must use the shared card grid.")
_expect(dock.martial_panel.get_panel_snapshot().get("card_surface", "") == "shared_action_card_grid", "Martial must use the shared card grid.")
_expect(dock.ultimate_panel.get_panel_snapshot().get("card_surface", "") == "shared_action_card_grid", "Ultimate must use the shared card grid.")
```

- [ ] **Step 4: Run the Godot test and verify RED.**

Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_card_source_unification.gd`
Expected: FAIL because no panel currently exposes the shared-card surface or intent-card path.

- [ ] **Step 5: Record current contract links and approval without claiming runtime completion.**

Update the UI spec and current planning owners to point to `TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01`, state that source-card/runtime implementation is in progress, and retain human evidence as `NOT_RUN`.

### Task 2: Build the shared action-card renderer and source grids

**Files:**
- Create: `scenes/ui/action_selection/action_choice_card.tscn`
- Create: `src/ui/action_selection/action_choice_card.gd`
- Modify: `src/ui/action_selection/basic_action_panel.gd`
- Modify: `src/ui/action_selection/martial_action_panel.gd`
- Modify: `src/ui/action_selection/ultimate_action_panel.gd`
- Modify: `scenes/ui/action_selection/martial_action_panel.tscn`
- Modify: `scenes/ui/action_selection/ultimate_action_panel.tscn`
- Test: `tests/verify_action_card_source_unification.gd`

**Interfaces:**
- Consumes: normalized dictionaries from `ActionViewModelAdapter`.
- Produces: `ActionChoiceCard.configure_action(definition, presentation)` and `ActionChoiceCard.configure_intent(intent)`.

- [ ] **Step 1: Extend the failing Godot test for art and field parity.**

```gdscript
_expect(basic_card.get_node_or_null("CardIllustration") != null, "Basic card must retain its approved atlas crop.")
_expect(martial_card.get_node_or_null("CardIllustration") == null, "Martial card must not create illustration UI.")
_expect(ultimate_card.get_node_or_null("CardIllustration") == null, "Ultimate selection card must not create illustration UI.")
```

- [ ] **Step 2: Run the focused Godot test and verify RED.**

Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_card_source_unification.gd`
Expected: FAIL because martial and ultimate still create source-specific text-list buttons instead of `ActionChoiceCard` instances.

- [ ] **Step 3: Implement `ActionChoiceCard` with explicit art policy.**

```gdscript
func configure_action(value: Dictionary, presentation: Dictionary) -> void:
    _definition = value.duplicate(true)
    _art_mode = str(presentation.get("art_mode", "none"))
    _render_identity(value)
    _render_cost_and_range(value)
    _render_state(presentation)
    _render_basic_atlas_only(value) if _art_mode == "basic_atlas" else _remove_illustration()
```

- [ ] **Step 4: Replace panel-local button construction with shared card grids.**

The basic panel passes `art_mode: "basic_atlas"`; martial and ultimate panels pass `art_mode: "none"`. Each panel exposes `card_surface: "shared_action_card_grid"`, preserves its action signals and keeps locked/reserved controls disabled.

- [ ] **Step 5: Run shared-card and existing panel regressions.**

Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_card_source_unification.gd`
Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_ten_manual_ui_ai_adoption.gd`
Expected: both PASS with martial data and nodes art-free.

### Task 3: Replace tile/direction input with semantic intent cards

**Files:**
- Modify: `src/ui/action_selection/action_selection_dock.gd`
- Modify: `src/ui/action_selection/action_placement_controller.gd`
- Modify: `src/ui/action_timing_panel.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `src/combat/combat_review_summary_builder.gd`
- Test: `tests/verify_action_card_source_unification.gd`
- Test: `tests/verify_action_placement_controller.gd`
- Test: `tests/verify_combat_board.gd`

**Interfaces:**
- Consumes: an auto-placed action requiring `move_intent` or `aim_intent`.
- Produces: `intent_selected(anchor_index: int, intent: Dictionary)` and a placement that is target-ready without opening the tactical tile layer.

- [ ] **Step 1: Add failing intent-behavior assertions.**

```gdscript
_expect(not board._tile_layer.visible, "Planning must not expose the tactical tile layer.")
_expect(dock.get_intent_choice_ids().has("move_approach_1"), "Move must offer an approach intent card.")
_expect(dock.get_intent_choice_ids().has("move_retreat_1"), "Move must offer a retreat intent card.")
```

- [ ] **Step 2: Run the targeted tests and verify RED.**

Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_card_source_unification.gd`
Expected: FAIL because the current auto preview calls the base tile-targeting implementation.

- [ ] **Step 3: Implement intent-card generation and normalization.**

```gdscript
func build_move_intents(origin_tile: int, enemy_tile: int, max_steps: int) -> Array[Dictionary]:
    return _bounded_intents(origin_tile, enemy_tile, max_steps, ["approach", "retreat"])

func normalize_aim_intent(intent: String, origin_tile: int, enemy_tile: int) -> int:
    var toward_enemy := signi(enemy_tile - origin_tile)
    return toward_enemy if intent == "toward_enemy" else -toward_enemy
```

`CombatBoardPreviewAuto` opens intent cards instead of `super._begin_targeting_for_anchor`; it never shows `_tile_layer` while planning. The resolver receives the normalized sign at its existing internal boundary, preserving the current miss/range semantics.

- [ ] **Step 4: Update player-facing copy and review mapping.**

Use `접근`, `후퇴`, `상대를 노림`, `반대 예측`, and `예측 빗나감`; remove active target-tile number and left/right prompt strings.

- [ ] **Step 5: Run normal, boundary and wrong-prediction regressions.**

Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_card_source_unification.gd`
Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_combat_board.gd`
Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_placement_controller.gd`
Expected: move, aim, boundary and wrong-prediction paths PASS without a tile picker.

### Task 4: Retire active legacy selection contracts and reconcile consumers

**Files:**
- Modify: `data/combat/combat_board_poc.json`
- Modify: `data/combat/combat_resolution_preview.json`
- Modify: `src/ui/action_selection/action_view_model_adapter.gd`
- Delete: `data/combat/action_selection_poc.json`
- Modify: `tests/check_combat_board_contract.py`
- Modify: `tests/test_phase2_combat_canon_data.py`
- Modify: `tests/test_poc_planning_data.py`
- Modify: `tests/test_visual_consumer_asset_production_policy.py`

**Interfaces:**
- Consumes: current ten-manual loadout and normalized selection actions.
- Produces: no active product fallback to legacy `action_selection_poc.json` or board-direction POC values.

- [ ] **Step 1: Add a failing static active-reference test.**

```python
def test_product_sources_do_not_reference_legacy_action_selection_poc(self):
    for path in PRODUCT_SOURCES:
        self.assertNotIn("action_selection_poc.json", read(path))
    self.assertFalse((ROOT / "data/combat/action_selection_poc.json").exists())
```

- [ ] **Step 2: Run the contract test and verify RED.**

Run: `python -m unittest tests.test_action_card_source_unification_contract -v`
Expected: FAIL because the adapter still loads the old action-selection POC fallback.

- [ ] **Step 3: Move every current consumer to the active ten-manual/loadout route.**

Remove `_build_legacy_owned_manuals`, make missing runtime loadout fail closed with an empty martial source and an explicit UI fallback message, then remove the old POC data only after `git grep` reports no active product reference.

- [ ] **Step 4: Replace POC descriptions and tests with the current dock contract.**

Set `action_targeting` to semantic intent-card modes, identify `ActionSelectionDock` as the sole active selector, and update asset-consumer assertions so the approved basic atlas is consumed by `BasicActionPanel` through `ActionChoiceCard`.

- [ ] **Step 5: Run static suite and reference-freshness checks.**

Run: `python -m unittest tests.test_action_card_source_unification_contract tests.check_combat_board_contract tests.test_phase2_combat_canon_data tests.test_poc_planning_data tests.test_visual_consumer_asset_production_policy -v`
Run: `git grep -n -E "select_destination_board_tile|select_left_or_right_direction|action_selection_poc.json" -- data src scenes`
Expected: tests PASS; grep has no active product result.

### Task 5: Integrate, review and validate the complete combat surface

**Files:**
- Modify: `docs/07_COMBAT_UI_SPEC.md`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `docs/planning-data/current_user_planning_status.json`
- Create: `docs/handoffs/2026-08-30_ACTION_CARD_SOURCE_UNIFICATION_CODEX_GODOT_IMPLEMENTATION_HANDOFF.md`
- Create: `docs/operations/2026-08-30_ACTION_CARD_SOURCE_UNIFICATION_EXECUTION_REPORT.md`

**Interfaces:**
- Consumes: completed common card, intent and migration regressions.
- Produces: exact change evidence and remaining evidence ceiling.

- [ ] **Step 1: Add a final failing end-to-end assertion.**

```gdscript
_expect(board.action_selection_dock.visible, "The unified selection dock must be visible in combat.")
_expect(not board._tile_layer.visible, "The logical tile layer must remain hidden during all selection states.")
_expect(board.action_timing_panel.are_current_bundle_targets_ready(), "Resolved intent cards must satisfy current-bundle readiness.")
```

- [ ] **Step 2: Run it and verify RED before final wiring.**

Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_card_source_unification.gd`
Expected: any incomplete integration path fails with the relevant card/intention assertion.

- [ ] **Step 3: Finish minimal integration, then run focused and full verification.**

Run: `python -m unittest discover -s tests -p "test_*.py" -v`
Run: `Godot_v4.7.1-stable_win64_console.exe --editor --headless --path . --quit`
Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_action_card_source_unification.gd`
Run: relevant existing Godot source-selection, ultimate, focus, reveal and bridge verifiers.

- [ ] **Step 4: Conduct the five full-scope adversarial review loops.**

1. Compare Decision/spec/data/documentation against actual source cards and no-art consumer paths.
2. Challenge resolver/AI/save compatibility and wrong-prediction behavior.
3. Challenge focus, keyboard, mouse, Korean text and 1280×800/1440×900/1920×1080 layouts.
4. Challenge untouched VFX/reveal, basic atlas provenance and legacy active-reference removal.
5. Re-read exact diff, test output, Godot runtime diagnostics and evidence ceilings; record only real findings.

- [ ] **Step 5: Run visible machine runtime QA and record evidence honestly.**

Open the exact worktree Godot project, use the approved local runtime observer to select all three source tabs, make a move/aim selection, resolve a bundle, capture the visible frame and diagnostics, and write `NOT_RUN` for human, Android, accessibility-user and release performance evidence that was not performed.

## Plan self-review

- **Spec coverage:** Task 1 records approval and regression scope; Task 2 implements common cards/no-art; Task 3 replaces tile/left-right input while preserving tactical intent; Task 4 removes active legacy contracts; Task 5 validates runtime, evidence and review loops.
- **Placeholder scan:** No task relies on TBD work; each includes target paths, interfaces, concrete failure behavior and commands.
- **Type consistency:** `ActionChoiceCard.configure_action`, `ActionChoiceCard.configure_intent`, `ActionSelectionDock.intent_selected`, `move_intent`, and `aim_intent` are the only new cross-task interfaces.

## Execution selection

The user has approved continuous implementation and this task must remain isolated from unrelated work. Execute inline in this worktree with test-first checkpoints; do not dispatch parallel workers.
