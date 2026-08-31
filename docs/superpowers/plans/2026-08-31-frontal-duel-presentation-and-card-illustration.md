# Frontal Duel Feedback and Readable Card Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ground the frontal duel, reveal attack/clash/ultimate feedback from only one resolved event, restore readable card facts for all sources, and replace the technical MAIN shell without changing combat rules.

**Architecture:** `CombatCharacterPlaceholder` owns visual grounding only. `CombatBoardPreview` renders feedback only after public resolution. `ActionViewModelAdapter` publishes facts while `ActionChoiceCard` lays them out identically. `MainTitleScreen` decorates the existing `VerticalSliceShell` and emits only its existing start route.

**Tech Stack:** Godot 4.7 GDScript, project PNG assets and JSON manifest, Godot headless scripts, HERA visible-editor observation.

**Spec:** `docs/superpowers/specs/2026-08-31-frontal-duel-presentation-and-card-illustration-design.md`

## Global Constraints

- Preserve the 10-tile logic, distance-first display, 3/3/4 planning, private-plan boundary, action IDs, save schema, and shared Windows/Android core.
- Presentation cannot calculate damage, alter resolution, expose future actions, or make animation completion authoritative.
- Keep the grid, opponent-intent hypothesis input, and immediate-complete player button absent from product UI.
- Basic, martial, and ultimate sources continue to use `ActionChoiceCard`; facts are published data rather than UI combat calculations.
- New raster art is `GENERATED_CANDIDATE` until provenance, user final lock, manifest registration, and consumer readback complete.
- Preserve Fast Replay, Reduced Motion, sound controls, sequential reveal, combat log, observation, review, and keyboard focus.
- Run RED before production code. Automated and visible Windows evidence never substitutes for Android, accessibility-user, human-play, release, or rights PASS.

---

### Task 1: Write focused RED contracts

**Files:**
- Modify: `tests/verify_ink_paper_combat_presentation.gd`
- Modify: `tests/verify_action_card_source_unification.gd`
- Modify: `tests/verify_combat_action_reveal.gd`
- Modify: `tests/verify_vertical_slice_shell.gd`

**Interfaces:**
- Consumes: `get_foot_anchor_global()`, board presentation metadata, `ActionChoiceCard` child nodes, and `VerticalSliceShell.start_new_run()`.
- Produces: failures for floating/debug feet, missing feedback, missing card facts, and technical MAIN copy.

- [x] **Step 1: Add grounding assertions.**

```gdscript
_check(absf(player.get_foot_anchor_global().y - enemy.get_foot_anchor_global().y) <= 1.0, "Both battlers must share one floor baseline.")
_check(player.visual_offset.y == 0.0 and enemy.visual_offset.y == 0.0, "Idle pose must not bob above the floor.")
```

- [x] **Step 2: Add one-event-feedback assertions.**

```gdscript
_check(board.get_meta("presentation_feedback_kind", "") in ["attack", "clash", "ultimate"], "Resolved action must publish one feedback kind.")
_check(not board.get_meta("presentation_future_action_exposed", false), "Feedback must not reveal a hidden future action.")
_check(board.get_meta("presentation_feedback_reduced_motion_safe", false), "Reduced Motion must retain a readable result.")
```

- [x] **Step 3: Add shared-card and MAIN assertions.**

```gdscript
_check(facts.text.contains("사거리") and facts.text.contains("기력") and facts.text.contains("내력"), "%s must show range and resource facts." % label)
_check(not effect.text.strip_edges().is_empty() and effect.text != "절초", "%s must have an actionable effect summary." % label)
_expect_true(shell.find_child("MainTitleScreen", true, false) != null, "MAIN must use the player-facing title screen.")
```

- [x] **Step 4: Run and retain RED output.**

```powershell
& $Godot --headless --path . --script res://tests/verify_ink_paper_combat_presentation.gd
& $Godot --headless --path . --script res://tests/verify_action_card_source_unification.gd
& $Godot --headless --path . --script res://tests/verify_combat_action_reveal.gd
& $Godot --headless --path . --script res://tests/verify_vertical_slice_shell.gd
```

Expected: source behavior fails, with all scenes still parsing.

### Task 2: Ground frontal battlers

**Files:**
- Modify: `src/combat/combat_character_placeholder.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `tests/verify_ink_paper_combat_presentation.gd`
- Modify: `tests/verify_combat_character_art.gd`

**Interfaces:**
- Consumes: `place_foot_at(anchor)`, the existing common `player_foot_y`, and approved battler textures.
- Produces: equal-foot placement, fixed shadow, no runtime debug crosses, and lunge that returns to zero visual offset.

- [x] **Step 1: Keep `place_foot_at()` and the shared `player_foot_y` as the only floor placement route.**
- [x] **Step 2: Replace the idle vertical sine movement with a stable zero offset, retaining attack lunge as temporary presentational motion.**
- [x] **Step 3: Draw a flattened fixed shadow before the texture and remove both sprite and fallback debug cross paths.**
- [x] **Step 4: Run grounding and frontal composition checks.**

```powershell
& $Godot --headless --path . --script res://tests/verify_ink_paper_combat_presentation.gd
& $Godot --headless --path . --script res://tests/verify_combat_character_art.gd
& $Godot --headless --path . --script res://tests/verify_frontal_duel_assets.gd
```

### Task 3: Add public-event attack, clash, and ultimate feedback

**Files:**
- Create after final visual lock: `assets/vfx/attack_clash_ink_gold_atlas_rgba_v1.png`
- Modify after final visual lock: `assets/ASSET_MANIFEST.json`
- Modify: `src/combat/combat_board_preview.gd`
- Modify only if required: `scenes/combat/combat_board_preview.tscn`
- Modify: `tests/verify_combat_action_reveal.gd`
- Modify: `tests/verify_combat_presentation_controls.gd`

**Interfaces:**
- Consumes: `_present_timing_duel(events_value, timing, phase)`, the existing ultimate VFX texture, and reduced-motion state.
- Produces: `presentation_feedback_kind` metadata and visual-only normal attack, clash, or ultimate presentation for one current public event.

- [x] **Step 1: Classify one resolved event as `attack`, `clash`, or `ultimate`, after it becomes public and without reading later events.**
- [ ] **Step 2: Route a short transparent normal-attack brush/impact at actor and target, and symmetric clash strokes at the centre. The new raster is quieter than ultimate feedback.**
- [x] **Step 3: Re-anchor the existing ultimate strip and action/result label to the current impact point; clear it after a bounded delay.**
- [x] **Step 4: Reduced Motion skips trails but preserves action/result and a static impact; Fast Replay shortens duration only.**
- [x] **Step 5: Run reveal, liveness, terminal, SFX, and keyboard checks.**

```powershell
& $Godot --headless --path . --script res://tests/verify_combat_action_reveal.gd
& $Godot --headless --path . --script res://tests/verify_combat_presentation_liveness.gd
& $Godot --headless --path . --script res://tests/verify_combat_terminal_presentation.gd
& $Godot --headless --path . --script res://tests/verify_combat_sfx_presentation.gd
& $Godot --headless --path . --script res://tests/verify_combat_keyboard_accessibility.gd
```

### Task 4: Restore common readable card facts

**Files:**
- Modify: `src/ui/action_selection/action_view_model_adapter.gd`
- Modify: `src/ui/action_selection/action_choice_card.gd`
- Modify: `src/ui/action_selection/action_selection_dock.gd`
- Modify only for common-card viewport: `src/ui/action_selection/basic_action_panel.gd`, `src/ui/action_selection/martial_action_panel.gd`, `src/ui/action_selection/ultimate_action_panel.gd`
- Modify: `tests/verify_action_card_source_unification.gd`
- Modify: `tests/verify_action_view_model_adapter.gd`
- Modify: `tests/verify_basic_action_panel.gd`
- Modify: `tests/verify_martial_action_panel.gd`
- Modify: `tests/verify_ultimate_action_panel.gd`

**Interfaces:**
- Consumes: `range_text`, `stamina_cost`, `internal_cost`, `action_slots`, `detail.effect_text`, ultimate `damage`, and `dash_before_attack`.
- Produces: visible range/기력/내력, one-line effect, and readable common-card bounds below the approved illustration.

- [x] **Step 1: Add an adapter-only ultimate summary such as `돌진 후 공격 · 기본 피해 8`; do not call combat resolution.**
- [x] **Step 2: Make `_facts_text()` always show `사거리`, `기력`, and `내력`, using data-backed `자신` or `제한 없음` semantics where appropriate.**
- [x] **Step 3: Increase common-card minimum height and reserve illustration/facts/effect regions so labels cannot overlap or clip.**
- [x] **Step 4: Keep the basic 5×2 grid; add a bounded scroll viewport only if martial/ultimate common cards need it.**
- [x] **Step 5: Run card/adaptor/panel checks and retain all ten basic actions.**

```powershell
& $Godot --headless --path . --script res://tests/verify_action_view_model_adapter.gd
& $Godot --headless --path . --script res://tests/verify_action_card_source_unification.gd
& $Godot --headless --path . --script res://tests/verify_basic_action_panel.gd
& $Godot --headless --path . --script res://tests/verify_martial_action_panel.gd
& $Godot --headless --path . --script res://tests/verify_ultimate_action_panel.gd
```

### Task 5: Build the actual MAIN title surface

**Files:**
- Create: `src/ui/main_title_screen.gd`
- Create: `scenes/ui/main_title_screen.tscn`
- Modify: `src/run/vertical_slice_shell.gd`
- Modify: `tests/verify_vertical_slice_shell.gd`
- Modify: `tests/verify_default_vertical_slice_entry.gd`

**Interfaces:**
- Consumes: existing approved courtyard and battler textures plus `_on_primary_button_pressed()`.
- Produces: a `MainTitleScreen` with one real `비무행 시작` action and no technical copy.

- [x] **Step 1: Build a full-rect title scene with the approved courtyard, low-opacity inward battlers, title, short promise, and start button.**
- [x] **Step 2: Connect only to the existing shell start route; do not add settings/store/records or a new run state.**
- [x] **Step 3: Show it only in `SCREEN_MAIN`; retain the existing content panel for all other shell screens.**
- [x] **Step 4: Remove visible technical/pending status copy and verify `MAIN → SETUP → INTRO → BRIEFING → COMBAT`.**

```powershell
& $Godot --headless --path . --script res://tests/verify_vertical_slice_shell.gd
& $Godot --headless --path . --script res://tests/verify_default_vertical_slice_entry.gd
```

### Task 6: Lock asset, clean only proven-unused variants, and verify the real screen

**Files:**
- Modify after final VFX lock: `assets/ASSET_MANIFEST.json`
- Delete after zero-reference proof: `assets/vfx/ultimate_ink_gold_sprite_sheet.png`
- Delete after zero-reference proof: `assets/vfx/ultimate_ink_gold_sprite_sheet_transparency_candidate.png`
- Modify: `docs/superpowers/specs/2026-08-31-frontal-duel-presentation-and-card-illustration-design.md`
- Create: `docs/operations/2026-08-31_FRONTAL_DUEL_FEEDBACK_EXECUTION_REPORT.md`

**Interfaces:**
- Consumes: user final lock, exact asset SHA-256, active consumer routes, and current PR baseline.
- Produces: one registered normal/clash atlas, one registered ultimate atlas, no unreferenced rejected binary variants, and evidence-bounded execution record.

- [ ] **Step 1: `rg` tracked code, scenes, data, docs, and manifest before deletion. Retain active `ultimate_ink_gold_sprite_sheet_rgba.png`; remove only zero-consumer variants and their imports.**
- [ ] **Step 2: Register the approved VFX with SHA-256, prompt, output ID, alpha audit, approval, consumer, and state.**
- [x] **Step 3: Run one Godot import after asset edits, focused tests, operating validation, static contracts, and `git diff --check` excluding PNG files.**
- [ ] **Step 4: Use HERA only when its project path equals this worktree. Capture MAIN and attack/clash/ultimate views; inspect equal foot Y and hidden tactical layer.**
- [x] **Step 5: Perform five evidenced adversarial review loops across asset authority, core boundaries, input/accessibility, runtime, and repository hygiene; write the outcomes.**

## Plan Self-Review

- **Spec coverage:** Tasks 2–5 cover grounding, three feedback states, card readability, and MAIN. Task 6 covers asset lifecycle, cleanup, runtime proof, and adversarial review.
- **No placeholders:** Every production file, test, command, and conditional asset-lock boundary is named.
- **Type consistency:** feedback metadata stays on `CombatBoardPreview`; the adapter feeds `ActionChoiceCard`; the title scene invokes the existing shell callback only.

## Execution Mode

The user approved the recommended scope and authorized screen verification. Execute inline in the existing isolated PR worktree, reporting only a genuine new asset-final-lock or correct-editor blocker.

## Execution record

Tasks 1, 2, 4, and 5 plus the non-raster portions of Task 3 are complete and machine-verified. Task 3 step 2 and Task 6 steps 1, 2, and 4 remain open: their conditions are the normal/clash VFX final lock, executable zero-consumer binary cleanup, and an active Godot session whose project path is exactly this worktree. The evidence, root-cause recovery, and five full-scope adversarial loops are recorded in `docs/operations/2026-08-31_FRONTAL_DUEL_FEEDBACK_EXECUTION_REPORT.md`.
