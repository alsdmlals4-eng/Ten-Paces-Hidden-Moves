# Ink-paper Combat Presentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Make the real Godot Combat/Review presentation read as a restrained ink-paper duel while preserving the ten-step combat interaction, 거리 N state, 3/3/4 planning, and all existing combat ownership boundaries.

**Architecture:** CombatBoardPreview remains the composition owner. It gains a live native range readout derived only from authoritative combat state, while CombatBoardTile changes only its resting visual treatment: the ten logical tiles remain interactive in targeting but do not compete with the relative-distance readout at rest. Existing HUD, timing, confirmation, tray, card, log, hypothesis, and review components are retuned in place rather than replaced with a baked mockup.

**Tech Stack:** Godot 4.7 GDScript, existing .tscn scenes, repository raster assets, project headless GDScript verifiers, Hera live-editor runtime QA.

**Spec:** docs/superpowers/specs/2026-08-30-ink-paper-combat-presentation-design.md

## Global Constraints

- Preserve combat rules, resolution, AI information boundaries, save data, action definitions, and the shared Windows/Android core.
- The UI displays supplied state only; it must not calculate combat or expose hidden player intent.
- Keep all ten logical board tiles and their targeting, pointer, keyboard, and accessibility routes.
- Resting combat reads 거리 N; distance zero visibly adds [밀착].
- Keep live native Godot labels, cards, controls, and detail surfaces. Do not render a static screenshot/mockup as product UI.
- The user reference is a style reference only. A generated background is a candidate until a separate user final lock and asset/provenance readback.
- Scope is Combat/Review; do not reskin unrelated screens.
- Runtime machine evidence does not become human usability, accessibility-user, Android-device, release-performance, or user-approval evidence.

---

## File Structure and impact map

| File | Responsibility |
| --- | --- |
| tests/verify_ink_paper_combat_presentation.gd | Live board integration regression for range output, engaged state, resting/contextual tile labels, retained controls, and layout containment. |
| src/combat/combat_board_preview.gd | Adds and lays out the native central range/engaged overlay, refreshes it from authoritative combat state, and records accessible presentation snapshot data. |
| src/combat/combat_board_tile.gd | Makes absolute tile numerals contextual: hidden at rest, shown when targetable, hovered, or focused; keeps target input intact. |
| src/ui/top_combat_hud.gd and src/ui/combatant_status_panel.gd | Retune status framing only; preserve current data sources, portraits, and status values. |
| src/ui/action_timing_panel.gd and src/ui/combat_progress_button.gd | Retune the existing live plan strip and confirmation CTA only; preserve placement/progress state. |
| src/ui/basic_card_tray.gd and src/ui/basic_card_tray_item.gd | Retune the existing native card-dock surfaces only; preserve card order, selection, keyboard activation, and signals. |
| Current execution-report/status owner | Record evidence after it exists; do not mark unrun evidence as PASS. |

Untouched in this package: resolution, AI planning, game/save schema, action data, background-asset binding, opponent catalog, portrait/battler registrations, and the planning-only warm-dusk candidate.

### Task 1: Establish the observable presentation contract (RED)

**Files:**
- Create: tests/verify_ink_paper_combat_presentation.gd
- Reference: scenes/combat/combat_board_preview.tscn, src/combat/combat_board_preview.gd, src/combat/combat_board_tile.gd

**Interfaces:**
- Consumes: CombatBoardPreview.combat_state, CombatBoardPreview._apply_combat_state_to_view(), CombatBoardPreview.tiles, and live CombatBoardTile instances.
- Produces: INK_PAPER_COMBAT_PRESENTATION_VERIFY_OK only when initial distance is 거리 2, same-tile state displays [밀착], resting absolute numerals are hidden, targetable numerals appear, and existing planning/confirmation/tray controls remain live.

- [ ] **Step 1: Write the failing test**

~~~gdscript
extends SceneTree
const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
var failures: Array[String] = []

func _run() -> void:
    var board := BOARD_SCENE.instantiate() as CombatBoardPreview
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _frame in range(6):
        await process_frame
    _expect(board.range_readout_label.text == "거리 2", "Initial range must be 거리 2.")
    _expect(not board.range_engagement_label.visible, "Engaged badge must be hidden while range is non-zero.")
    _expect(not board.tiles[0]._number_label.visible, "Resting tiles must not show persistent absolute numerals.")
    board.tiles[0].set_interaction_state("movable")
    _expect(board.tiles[0]._number_label.visible, "Targetable tile must expose its contextual numeral.")
    var player: Dictionary = board.combat_state.get("player", {})
    var enemy: Dictionary = board.combat_state.get("enemy", {})
    enemy["tile"] = int(player.get("tile", 4))
    board.combat_state["enemy"] = enemy
    board._apply_combat_state_to_view()
    for _frame in range(3):
        await process_frame
    _expect(board.range_readout_label.text == "거리 0", "Shared tile must display distance zero.")
    _expect(board.range_engagement_label.visible and board.range_engagement_label.text == "[밀착]", "Shared tile must display the engaged state.")
    _expect(is_instance_valid(board.action_timing_panel) and is_instance_valid(board.combat_progress_button) and is_instance_valid(board.basic_card_tray), "Live planning, confirmation, and tray consumers must remain present.")
    _finish()
~~~

- [ ] **Step 2: Run the verifier to verify RED**

Run: godot --headless --path . --script res://tests/verify_ink_paper_combat_presentation.gd

Expected: a clear missing-range-overlay failure. It must not fail from an unrelated parse error. Do not make a normal deliverable commit with a failing repository test; preserve the command output and continue directly to Task 2.

### Task 2: Implement live relative-range presentation (GREEN)

**Files:**
- Modify: src/combat/combat_board_preview.gd — fields, _build_structure(), _layout_board(), _configure_accessibility_semantics(), _apply_combat_state_to_view(), and get_layout_snapshot().
- Modify: src/combat/combat_board_tile.gd — _refresh_visuals() and resting draw treatment.
- Test: tests/verify_ink_paper_combat_presentation.gd.

**Interfaces:**
- Consumes: combat_state["player"]["tile"] and combat_state["enemy"]["tile"] supplied by CombatResolutionEngine; no new state authority.
- Produces: range_readout_label: Label, range_engagement_label: Label, and get_layout_snapshot()["range_readout"] with text, engaged flag, and rect. CombatBoardTile.tile_clicked(tile_index) remains unchanged.

- [ ] **Step 1: Add the smallest native range overlay**

~~~gdscript
var range_readout_panel: PanelContainer
var range_readout_label: Label
var range_engagement_label: Label

func _refresh_range_readout() -> void:
    if not is_instance_valid(range_readout_label):
        return
    var distance := absi(_enemy_tile - _player_tile)
    range_readout_label.text = "거리 %d" % distance
    range_engagement_label.visible = distance == 0
    range_engagement_label.text = "[밀착]"
    set_meta("player_facing_distance", distance)
~~~

Create the panel and labels after the character layer, ignore mouse input, call the method after state updates and after layout, and use live paper/ink/gold contrast instead of image-baked text.

- [ ] **Step 2: Lay out and describe the overlay**

~~~gdscript
var range_size := Vector2(clampf(size.x * 0.16, 152.0, 220.0), 72.0)
var range_y := clampf(_board_top + _tile_height * 0.16, presentation_y + 36.0, timing_row_y - range_size.y - 12.0)
range_readout_panel.position = Vector2((size.x - range_size.x) * 0.5, range_y)
range_readout_panel.size = range_size
_set_accessibility_semantics(range_readout_panel, "현재 거리", "두 인물의 공개 거리입니다. 거리 0에서는 밀착 상태입니다.")
~~~

Expose actual text, engaged flag, and rect in get_layout_snapshot().

- [ ] **Step 3: Make absolute tile numbers contextual without changing input**

~~~gdscript
var show_contextual_number := is_targetable() or _hovered or has_focus()
if is_instance_valid(_number_label):
    _number_label.text = str(tile_index)
    _number_label.visible = show_contextual_number
~~~

Keep mouse_filter, focus_mode, gui_input, tile_clicked, tile indices, and targetability states unchanged. Reduce only resting tile opacity/line weight; occupied/targeted/focused state keeps non-colour state marks.

- [ ] **Step 4: Run GREEN and adjacent regressions**

~~~powershell
godot --headless --path . --script res://tests/verify_ink_paper_combat_presentation.gd
godot --headless --path . --script res://tests/verify_combat_board.gd
godot --headless --path . --script res://tests/verify_combat_layout_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_keyboard_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_focus_order.gd
~~~

If a fresh worktree cannot resolve a global class, run godot --headless --editor --path . --quit, then rerun the same verifier; do not change source to conceal the environment condition.

- [ ] **Step 5: Commit the tested relative-range composition**

~~~powershell
git add tests/verify_ink_paper_combat_presentation.gd src/combat/combat_board_preview.gd src/combat/combat_board_tile.gd
git commit -m "feat: present combat range as ink-paper duel"
~~~

### Task 3: Retune existing native HUD, plan, CTA, and card-dock surfaces

**Files:**
- Modify: src/ui/top_combat_hud.gd, src/ui/combatant_status_panel.gd, src/ui/action_timing_panel.gd, src/ui/combat_progress_button.gd, src/ui/basic_card_tray.gd, src/ui/basic_card_tray_item.gd.
- Test: tests/verify_ink_paper_combat_presentation.gd plus existing UI/card regressions.

**Interfaces:**
- Consumes: existing HUD dictionaries, timing snapshot/placements, progress runtime context, and card definitions.
- Produces: identical public methods, signal payloads, control names, accessibility metadata, and selection/progress states with presentation-only changes.

- [ ] **Step 1: Extend the focused verifier before component-style changes**

~~~gdscript
_expect(board.top_hud.get_hud_snapshot().get("round_number", 0) == 1, "Ink-paper HUD must retain the live opening round.")
_expect(board.action_timing_panel.get_timing_snapshot().get("timing_sequence", []) == [3, 3, 4], "Ink-paper plan strip must retain 3/3/4.")
_expect(not board.combat_progress_button.progress_enabled, "Ink-paper CTA must remain disabled before placement.")
_expect(board.basic_card_tray.get_tray_snapshot().get("card_count", 0) == 10, "Ink-paper dock must retain the registered card set.")
~~~

- [ ] **Step 2: Verify RED for a new observable presentation-surface snapshot**

Add a small presentation_surface: "paper_ink_r1" value to each existing snapshot only when it describes the actual rendered component. Run the focused verifier and confirm it fails because that live snapshot value does not yet exist. Do not test source text or a literal colour definition.

- [ ] **Step 3: Retune each component in place**

~~~gdscript
const PAPER_SURFACE := Color("d9ccb1")
const CHARCOAL_INK := Color("211c17")
const RESTRAINED_GOLD := Color("b99254")
# Change only draw/style colours, divider weight, padding, and focus contrast.
# Do not change dynamic text, state flow, signal routing, or data lookups.
~~~

Use paper surfaces, charcoal ink edges, restrained gold separators, and explicit selected/disabled/focus borders. Do not create a global theme subsystem for this single screen.

- [ ] **Step 4: Verify GREEN and relevant consumers**

~~~powershell
godot --headless --path . --script res://tests/verify_ink_paper_combat_presentation.gd
godot --headless --path . --script res://tests/verify_combat_board.gd
godot --headless --path . --script res://tests/verify_action_detail_panel.gd
godot --headless --path . --script res://tests/verify_combat_focus_visuals.gd
godot --headless --path . --script res://tests/verify_combat_layout_accessibility.gd
~~~

- [ ] **Step 5: Commit the tested native-surface retune**

~~~powershell
git add src/ui/top_combat_hud.gd src/ui/combatant_status_panel.gd src/ui/action_timing_panel.gd src/ui/combat_progress_button.gd src/ui/basic_card_tray.gd src/ui/basic_card_tray_item.gd tests/verify_ink_paper_combat_presentation.gd
git commit -m "feat: style combat controls as ink-paper surfaces"
~~~

### Task 4: Generate and review the single background candidate

**Files:**
- No tracked product asset or source change before user final lock.
- Candidate source: the approved reference and the brief in docs/superpowers/specs/2026-08-30-ink-paper-combat-presentation-design.md.

**Interfaces:**
- Consumes: the visual direction and existing BattleBackground consumer.
- Produces: one GENERATED_CANDIDATE image outside runtime canon, presented to the user with purpose and exclusions.

- [ ] **Step 1: Generate exactly one landscape-only candidate using the image model**

Prompt constraints: wide misty mountain valley; black/charcoal brush ink, aged warm hanji/parchment, pale low sun, distant pavilion silhouettes, quiet centre; opaque background; no people, weapons, cards, UI, labels, numbers, glyphs, logos, border, watermark, readable/pseudo-readable text.

- [ ] **Step 2: Inspect the candidate and show it to the user**

Report only GENERATED_CANDIDATE, its planned BattleBackground consumer, and that the game has not changed. Ask for explicit final lock or revision.

- [ ] **Step 3: Stop asset integration until final lock**

Do not write assets/, manifest/provenance, battle_background.gd, or release records. Existing twilight_ink_duel_v1.png remains the runtime background during this wait.

### Task 5: Runtime verification, evidence, and delivery

**Files:**
- Modify only after evidence exists: the execution-report/status owner selected by ACTIVE_CONTEXT.md.

**Interfaces:**
- Consumes: branch diff, actual Godot binary/editor/session, new-game/manual/opponent combat flow, and Hera readback.
- Produces: separate automated, runtime, Windows-visible, human, Android, accessibility-user, and release-performance statuses.

- [ ] **Step 1: Run all affected deterministic checks**

~~~powershell
godot --headless --editor --path . --quit
python -m unittest discover -s tests -p "test_*.py"
godot --headless --path . --script res://tests/verify_ink_paper_combat_presentation.gd
godot --headless --path . --script res://tests/verify_combat_board.gd
godot --headless --path . --script res://tests/verify_combat_layout_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_keyboard_accessibility.gd
godot --headless --path . --script res://tests/verify_combat_focus_order.gd
godot --headless --path . --script res://tests/verify_combat_focus_visuals.gd
godot --headless --path . --script res://tests/verify_action_detail_panel.gd
godot --headless --path . --script res://tests/verify_vertical_slice_combat_bridge.gd
~~~

- [ ] **Step 2: Use the live-editor workflow for visible runtime evidence**

Run hera status, then hera guidance ui. With the exact branch open in the matching Godot session, reach 새 비무행 → four manual selections → 이 네 권으로 출발 → 첫 상대 확인 → 비무 1 · 도겸 → 비무 시작. Use semantic UI tree/click readback and hera screenshot --runtime --analyze; then inspect diagnostics/errors. Record tested worktree and screen resolution.

- [ ] **Step 3: Run five adversarial review loops**

1. Relative range/contextual tile labels did not remove targeting, keyboard focus, or accessibility naming.
2. 3/3/4 timing, cards, confirmation, log, hypothesis, review, skip/reduced-motion/audio controls remain live and ordered.
3. No combat calculation, AI/private-plan exposure, rule/data/schema/save change, or background asset promotion exists.
4. 960×640 and 1440×900 containment plus long-Korean labels and selected/disabled/focus states remain readable.
5. Branch diff, untouched consumers, evidence ceilings, and accidental import/cache mutation are clean.

- [ ] **Step 4: Record evidence and prepare a normal review branch**

~~~powershell
git diff --check
git status --short
git log --oneline origin/main..HEAD
~~~

State exact PASS/FAIL/NOT_RUN values. Keep human, Android device, accessibility-user, and release-performance evidence not-run unless separately executed. Create a normal PR only after all required verification is complete; do not directly mutate main, force-push, or bypass rulesets.

## Plan self-review

### Spec coverage

- Combat/Review-first scope: Tasks 1–3 change only the existing combat composition and retain the existing review route.
- 거리 N/[밀착] first: Tasks 1–2 create a live tested overlay and contextual-only absolute numbers.
- Native controls, not static mockup: Tasks 2–3 retain existing child consumers and signals; Task 5 uses the real flow.
- Image lifecycle: Task 4 forbids runtime promotion before a separate user final lock.
- Accessibility/responsiveness: Tasks 2 and 5 retain semantics and run keyboard/focus/layout checks at two viewport sizes.
- Evidence separation: Task 5 defines exact ceilings and report timing.

### Placeholder scan

No incomplete-placeholders or vague cross-task references are present.

### Interface consistency

The new range fields are declared by Task 2 before Task 1's verifier becomes GREEN. Existing public fields and methods are not renamed. The verifier mutates the existing authoritative combat_state and reapplies the existing view method; it does not introduce a test-only production API.
