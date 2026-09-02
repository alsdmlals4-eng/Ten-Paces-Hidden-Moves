# Modular Duel UI and Presentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Register four user-final-locked modular UI images and render them in the existing preparation and one-action-at-a-time duel surfaces without changing combat rules or hidden-information boundaries.

**Architecture:** Existing `CombatBoardPreview` remains the composition owner, while status, timing-slot, detail, and observation controls own their own image-backed visual shells and dynamic text. `CombatCharacterPlaceholder` keeps the locked v2 textures and exposes presentation-only motion methods; the board maps resolver events to these methods and a shared clash anchor without changing state.

**Tech Stack:** Godot 4 GDScript, existing Control scenes, JSON asset/provenance catalog, Godot headless verifiers, Windows-visible Godot capture.

**Spec:** `docs/decisions/2026-09-03_MODULAR_DUEL_UI_AND_PRESENTATION_MOTION_DECISION.md`

## Global Constraints

- Preserve the `3 → resolve → 3 → resolve → 4 → resolve` core, 10 logical slots, start distance 2, public-state AI boundary, and observation type-only rule.
- Preserve byte-identical `player_wanderer_battler_rgba_v2.png` and `enemy_masked_battler_rgba_v2.png`; no new character pose raster is added.
- Use the four locked PNGs only as dynamic-content frames; no text, values, or hidden information is baked into them.
- During `presenting_result`, hide lower planning/selection/detail controls and reveal only the current action, then restore preparation controls at `next_bundle_ready`.
- Record a RED run before source implementation and classify human/device/accessibility/release evidence separately from machine runtime capture.

---

### Task 1: Register final-locked modular source and runtime images

**Files:**
- Create: `docs/visual-assets/approved/TEN-MODULAR-DUEL-UI-20260903/*.png`, `assets/ui/duel/*.png`, four provenance records beneath `docs/visual-assets/approved/TEN-MODULAR-DUEL-UI-20260903/`
- Modify: `docs/ASSET_CATALOG.json`, `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`
- Test: `tests/verify_modular_duel_ui_presentation.gd`

**Interfaces:**
- Consumes: user lock on four `exec-*` PNGs and existing asset-catalog schema.
- Produces: four `res://assets/ui/duel/` texture paths with SHA-256, dimensions, true-alpha audit, approval phrase, and consumer list.

- [ ] **Step 1: Write the failing runtime consumer test**

```gdscript
_expect(ResourceLoader.exists("res://assets/ui/duel/status_hud_frame_01_v1.png"), "Status HUD needs its final-locked runtime frame.")
_expect(ResourceLoader.exists("res://assets/ui/duel/current_action_slot_frame_01_v1.png"), "Current action slot needs its final-locked runtime frame.")
```

- [ ] **Step 2: Run the verifier and confirm RED**

Run: `godot --headless --path . --script res://tests/verify_modular_duel_ui_presentation.gd`

Expected: fail only because the four runtime frame paths and their UI consumers do not yet exist.

- [ ] **Step 3: Copy exact locked PNG bytes and add provenance**

```powershell
Copy-Item <locked-status-source> assets/ui/duel/status_hud_frame_01_v1.png
Get-FileHash assets/ui/duel/status_hud_frame_01_v1.png -Algorithm SHA256
```

Record candidate identifier, user approval, SHA-256, true-alpha corners, width/height, source and runtime paths, explicit consumers, and a conditional release-rights statement. Do not copy rejected non-alpha pose sheets.

- [ ] **Step 4: Re-run the verifier**

Run: `godot --headless --path . --script res://tests/verify_modular_duel_ui_presentation.gd`

Expected: still RED because controls have not yet consumed the assets.

### Task 2: Add image-backed status, timing, detail, and type-only observation controls

**Files:**
- Create: `src/ui/observation_reveal_panel.gd`, `scenes/ui/observation_reveal_panel.tscn`
- Modify: `src/ui/combatant_status_panel.gd`, `src/ui/action_timing_slot.gd`, `src/ui/action_selection/action_detail_panel.gd`, `src/combat/combat_board_preview.gd`, `tests/verify_modular_duel_ui_presentation.gd`
- Test: `tests/verify_modular_duel_ui_presentation.gd`, `tests/verify_action_detail_panel.gd`

**Interfaces:**
- Consumes: the four asset paths from Task 1 and authoritative `combat_state` / action definitions.
- Produces: `ObservationRevealPanel.set_revealed_types(Array)`, `CombatantStatusPanel` with `show_enemy_values = false` for enemy, and `CombatBoardPreview.get_modular_duel_ui_snapshot()`.

- [ ] **Step 1: Extend the failing verifier with observable UI contracts**

```gdscript
var snapshot: Dictionary = board.get_modular_duel_ui_snapshot()
_expect(bool(snapshot.get("status_frame_loaded", false)), "Both combatant status panels must consume the locked HUD frame.")
_expect(snapshot.get("observation_values", []) == ["공격"], "Observation panel must show only allowed action types.")
_expect(not bool(snapshot.get("enemy_numeric_values_visible", true)), "Enemy health, stamina, and internal numbers must remain hidden.")
```

- [ ] **Step 2: Run the verifier and confirm RED**

Run: `godot --headless --path . --script res://tests/verify_modular_duel_ui_presentation.gd`

Expected: fail because `get_modular_duel_ui_snapshot`, the observation panel, and frame consumers are absent.

- [ ] **Step 3: Implement dynamic frame consumers**

```gdscript
func set_revealed_types(value: Array) -> void:
    _types = _sanitize_revealed_types(value)
    _refresh_rows()

func _sanitize_revealed_types(value: Array) -> Array[String]:
    var allowed := ["전조", "이동", "공격", "방어", "회피", "준비", "자원", "관찰"]
    # retain only literals in allowed; preserve no card name, target, damage, direction, or cost
```

Apply status frame as a non-input backplate, display player `current/max` values, hide enemy numeric labels, render exactly five momentum pips through the existing gauge, and retain status chips. Apply the slot and detail frames behind existing dynamic labels/content. Add only the observation panel to the board and replace the legacy free-floating label.

- [ ] **Step 4: Run focused GREEN checks**

Run: `godot --headless --path . --script res://tests/verify_modular_duel_ui_presentation.gd; godot --headless --path . --script res://tests/verify_action_detail_panel.gd`

Expected: both pass; detail rows contain action name, actual resource costs, action-slot count, actual effects, and range only where applicable.

### Task 3: Enforce preparation-versus-reveal visibility and correct card fact semantics

**Files:**
- Modify: `src/combat/combat_board_preview.gd`, `src/ui/combat_action_reveal_overlay.gd`, `src/ui/action_selection/action_choice_card.gd`, `tests/verify_combat_action_reveal.gd`, `tests/verify_modular_duel_ui_presentation.gd`
- Test: `tests/verify_combat_action_reveal.gd`, `tests/verify_action_card_source_unification.gd`

**Interfaces:**
- Consumes: `CombatBoardPreview._set_resolution_surface_visible(bool)` and the presentation-state machine.
- Produces: planning-only controls hidden during action reveal; a reveal overlay restricted to the top/middle duel area; action facts that omit a false range for self/utility actions.

- [ ] **Step 1: Write failing state-visibility assertions**

```gdscript
_expect(not board.basic_card_tray.visible and not board.card_detail_panel.visible, "Action reveal must remove lower planning and detail controls.")
_expect(board.get_duel_stage_rect().encloses(overlay.get_reveal_rect()), "Action reveal must remain within the top and middle combat presentation surfaces.")
_expect(not card_facts.contains("사거리 자신"), "Self-only utility cards must not invent a range fact.")
```

- [ ] **Step 2: Run the existing reveal verifier and confirm RED**

Run: `godot --headless --path . --script res://tests/verify_combat_action_reveal.gd`

Expected: fail on lower-detail visibility, reveal-rect scope, or false utility range before source changes.

- [ ] **Step 3: Implement minimal presentation-only visibility and fact formatting**

```gdscript
func _set_resolution_surface_visible(value: bool) -> void:
    for control_value in [action_timing_panel, combat_progress_button, basic_card_tray, card_detail_panel]:
        if is_instance_valid(control_value):
            (control_value as Control).visible = value
```

Configure the overlay with the current top/middle presentation rect and render action name/type/slot plus resolved result without reintroducing the lower selectable-card grid. Format range only for definitions with an actual range constraint.

- [ ] **Step 4: Run focused GREEN checks**

Run: `godot --headless --path . --script res://tests/verify_combat_action_reveal.gd; godot --headless --path . --script res://tests/verify_action_card_source_unification.gd; godot --headless --path . --script res://tests/verify_modular_duel_ui_presentation.gd`

Expected: all pass with no hidden future action, no planning surface during reveal, and no fake utility range.

### Task 4: Add grounded presentation-only state and clash motion

**Files:**
- Modify: `src/combat/combat_character_placeholder.gd`, `src/combat/combat_board_preview.gd`, `tests/verify_combat_character_art.gd`, `tests/verify_combat_action_reveal.gd`
- Test: `tests/verify_combat_character_art.gd`, `tests/verify_combat_action_reveal.gd`

**Interfaces:**
- Consumes: authoritative event `{actor, category, outcome, card_id}` and existing VFX paths.
- Produces: `play_evade_motion`, `play_block_motion`, `play_hit_motion`, `play_ultimate_motion`, `play_clash_motion(clash_anchor, duration)`, and a board clash-anchor snapshot.

- [ ] **Step 1: Write failing grounded-motion assertions**

```gdscript
_expect(character.has_method("play_clash_motion"), "Combatant must expose a shared-anchor clash motion.")
_expect(board.get_presentation_motion_snapshot().get("clash_anchor_valid", false), "A clash must compute one common center anchor.")
_expect(absf(player_foot.y - enemy_foot.y) <= 1.0, "Clash motion must remain on the shared floor line.")
```

- [ ] **Step 2: Run verifiers and confirm RED**

Run: `godot --headless --path . --script res://tests/verify_combat_character_art.gd; godot --headless --path . --script res://tests/verify_combat_action_reveal.gd`

Expected: fail because the specialized state-motion methods and common clash snapshot do not yet exist.

- [ ] **Step 3: Implement only presentation transforms**

```gdscript
func play_clash_motion(clash_anchor: Vector2, duration: float = 0.34) -> void:
    var start := position
    var target := Vector2(clash_anchor.x - size.x * 0.5, start.y)
    # tween horizontal position and visual scale; return exactly to start; never alter tile_index or combat state
```

Map successful attacks to lunge, blocked outcomes to guard, evade outcomes to evade, damaged outcomes to hit recoil, ultimate IDs to ultimate windup, and clash events to both actors toward the same anchor. On reduced motion, skip transforms but retain VFX/result labels. Restore original foot anchors after every non-reduced motion.

- [ ] **Step 4: Run focused GREEN checks**

Run: `godot --headless --path . --script res://tests/verify_combat_character_art.gd; godot --headless --path . --script res://tests/verify_combat_action_reveal.gd`

Expected: all motion-state, grounded-return, common-clash-anchor, result-order, and reduced-motion assertions pass.

### Task 5: Validate, capture, review, synchronize, and document exact evidence

**Files:**
- Modify: `docs/07_COMBAT_UI_SPEC.md`, `docs/ASSET_CATALOG.json`, `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`, `docs/operations/2026-09-03_MODULAR_DUEL_UI_AND_PRESENTATION_EXECUTION_REPORT.md`
- Create: `docs/evidence/runtime-captures/TEN-RVC-20260903-001.png`, `docs/evidence/runtime-captures/TEN-RVC-20260903-002.png`
- Test: project focused Godot/Python suite and Windows-visible captures

**Interfaces:**
- Consumes: Tasks 1–4, the exact source revision, and capture policy.
- Produces: preparation and locked-action-reveal machine runtime images with hashes, dimensions, diagnostics, source revision, and evidence ceiling.

- [ ] **Step 1: Run import and focused verifier suite**

```powershell
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/verify_modular_duel_ui_presentation.gd
godot --headless --path . --script res://tests/verify_combat_action_reveal.gd
godot --headless --path . --script res://tests/verify_combat_character_art.gd
python tests/check_combat_board_contract.py
```

- [ ] **Step 2: Run the full Python regression suite**

Run: `python -m unittest discover -s tests -p 'test_*.py' -v`

Expected: no new failures. Record test counts and any warnings separately from PASS.

- [ ] **Step 3: Capture both actual Godot states**

```text
TEN-RVC-20260903-001: initial preparation / current bundle 1 / status-frame and detail consumer visible
TEN-RVC-20260903-002: locked action reveal / lower planning hidden / one current action / state-motion or reduced-motion result visible
```

Use a fresh, exact-path visible Godot run. Hash the PNGs, register dimensions/diagnostics/consumers in the manifest, and retain no temporary capture harness in the repository.

- [ ] **Step 4: Run five adversarial review loops**

```text
1. Asset lineage and true-alpha / no rejected candidate import.
2. Dynamic data and enemy-hidden/observation-safe information boundary.
3. Preparation-versus-reveal surfaces, current-only bundle, no lower overflow.
4. Foot-line / shared clash anchor / resolver-state isolation / reduced-motion fallback.
5. Exact tests, capture provenance, clean task-only staging, remote PR head/readback.
```

- [ ] **Step 5: Update human-facing contract and synchronize current-task branch**

```powershell
git add -- <only verified task paths>
git commit -m "feat: integrate modular duel UI and grounded presentation"
git push origin codex/human-blueprint-additive-recovery-20260902
gh pr view 321 --json headRefOid,mergeStateStatus,statusCheckRollup,url
```

Expected: only this task's paths are staged; remote exact branch is updated; PR and CI state are reported without claiming merge or human/device approval.

## Execution Readback · 2026-09-03

| task | result | evidence ceiling |
| --- | --- | --- |
| 1. Four final-locked frames | `IMPLEMENTED / MACHINE_VERIFIED` | runtime source hashes, true-alpha audit, and active manifest-consumer contract pass |
| 2. Dynamic frame controls | `IMPLEMENTED / MACHINE_VERIFIED` | status value visibility, five-pip momentum, detail facts, and type-only observation verifier pass |
| 3. Preparation versus reveal | `IMPLEMENTED / MACHINE_VERIFIED` | lower surface hiding, no future action, and no false utility range verifier pass |
| 4. Grounded motions and clash | `IMPLEMENTED / MACHINE_VERIFIED` | shared clash anchor, return-to-floor, and resolver-state isolation verifier pass |
| 5. Validation, capture, and sync | `PARTIAL` | import, focused Godot, combat-contract, and 455 Python tests pass; current durable preparation/reveal PNG capture is not registered and task-branch commit/push/readback remains the next step |

The unchecked implementation-step boxes above remain the original pre-execution checklist rather than retroactive proof. Exact completed evidence, the two RED-to-GREEN reconciliations, diagnostics, and unverified screen-capture boundary are owned by `docs/operations/2026-09-03_MODULAR_DUEL_UI_AND_PRESENTATION_EXECUTION_REPORT.md`.

## Plan Self-Review

- Spec coverage: asset lock/provenance (Task 1), all four dynamic modules and data privacy (Task 2), preparation/reveal screen separation plus card facts (Task 3), all requested motion states and clash (Task 4), runtime capture/contract/report/sync (Task 5).
- Placeholder scan: no unassigned work, placeholder symbol, or unspecified file path remains.
- Type consistency: `ObservationRevealPanel.set_revealed_types`, `CombatBoardPreview.get_modular_duel_ui_snapshot`, and `CombatBoardPreview.get_presentation_motion_snapshot` are defined before their consuming tests in the task order.
