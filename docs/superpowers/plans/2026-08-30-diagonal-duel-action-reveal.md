# Diagonal Duel Characters and Per-Action Reveal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Promote the user-final-locked character/card art and make the live
combat screen reveal, duel, and resolve one authoritative timing at a time.

**Architecture:** Keep combat resolution as a single authoritative bundle call.
Expose only display-safe fields in resolved action records, build a dedicated
native Godot overlay from each existing timing snapshot, then apply that
snapshot only after its visual beat. Register one approved transparent master,
two deterministic battler crops, and the approved technique atlas without
deleting rollback assets.

**Tech Stack:** Godot 4.7 GDScript, native `Control`/`TextureRect`/`Tween`,
JSON asset data, PNG assets, PowerShell deterministic crop/readback, existing
headless Godot verifier scripts, Hera runtime QA.

**Spec:** `docs/superpowers/plans/2026-08-30-diagonal-duel-action-reveal-spec.md`

## Global Constraints

- Preserve ten-cell logical combat, public distance, `[3,3,4]`, resolver/AI
  ownership, save/schema compatibility, and no future-action visual leak.
- No UI, motion, SFX, skip, or card overlay may calculate or change combat.
- Keep generic enemy and status portrait routing unchanged; retain old player
  and Dogyeom battlers as rollback assets.
- Do not commit editor-generated `.import`, `project.godot`, or test-log noise.
- Record source/master/derivative hashes and keep human/device/release evidence
  separate from automatic and local runtime evidence.

---

### Task 1: Lock tests around the approved asset and display-safe event schema

**Files:**
- Create: `tests/verify_diagonal_duel_assets.gd`
- Modify: `tests/verify_combat_presentation_liveness.gd`
- Modify: `tests/verify_combat_character_art.gd`
- Modify: `tests/verify_dogyeom_combat_battler.gd`

**Interfaces:**
- Consumes: current combat scene, `CombatCharacterPlaceholder`, resolution
  results, approved asset constants from the specification.
- Produces: failing assertions for the new player/Dogyeom routes, approved
  master/crop/atlas paths, and a current-timing-only reveal contract.

- [ ] **Step 1: Write failing asset and reveal regressions**

  Assert all of the following before changing production code:

  ```gdscript
  _expect(player_art_path == "res://assets/characters/player_diagonal_duel_battler_01_v1.png")
  _expect(dogyeom_art_path == "res://assets/characters/dogyeom_diagonal_duel_battler_01_v1.png")
  _expect(board.action_reveal_overlay != null)
  _expect(board.action_reveal_overlay.get_snapshot().get("timing", 0) == 1)
  _expect(not board.action_reveal_overlay.get_snapshot().get("future_action_visible", true))
  ```

- [ ] **Step 2: Run the new focused scripts and observe RED**

  Run:

  ```text
  godot --headless --path . --script res://tests/verify_diagonal_duel_assets.gd
  godot --headless --path . --script res://tests/verify_combat_presentation_liveness.gd
  ```

  Expected: the current project fails because none of the new assets or overlay
  nodes exist, not because the test script is malformed.

- [ ] **Step 3: Preserve the RED output in the execution report**

  Record exact expected missing paths/nodes and baseline SHA. Do not modify
  production scripts in this task.

### Task 2: Promote approved art, deterministic battler derivatives, and atlas mapping

**Files:**
- Create: `docs/visual-assets/approved/COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_v1.png`
- Create: `docs/visual-assets/approved/COMBAT_DIAGONAL_DUEL_CHARACTER_PAIR_01_v1.md`
- Create: `assets/characters/combat_diagonal_duel_character_pair_01_v1.png`
- Create: `assets/characters/player_diagonal_duel_battler_01_v1.png`
- Create: `assets/characters/dogyeom_diagonal_duel_battler_01_v1.png`
- Create: `docs/visual-assets/approved/TEN_BASIC_TECHNIQUE_INK_ATLAS_01_v1.png`
- Create: `assets/ui/cards/basic_technique_ink_atlas_01_v1.png`
- Modify: `assets/ASSET_MANIFEST.json`
- Modify: `assets/ui/cards/card_asset_manifest.json`
- Modify: `data/cards/basic_cards.json`

**Interfaces:**
- Consumes: user-final-locked source PNG paths and SHA-256 values from the spec.
- Produces: exact canonical/runtime files, deterministic crops, manifest entries,
  and `definition.illustration` atlas references for all ten basic action IDs.

- [ ] **Step 1: Copy the reviewed masters without overwriting existing assets**

  Copy each final-locked generated PNG to its canonical and runtime destinations.
  Verify canonical/runtime master byte equality, dimensions, alpha channel for
  the character master, and SHA-256 before registration.

- [ ] **Step 2: Create deterministic transparent battler crops**

  Crop the approved master with source rectangles `[0,0,920,941]` and
  `[752,0,920,941]`. Preserve alpha; verify the two output dimensions, alpha,
  and non-empty pixel bounds. Do not crop or overwrite older battlers.

- [ ] **Step 3: Register provenance and atlas regions**

  Add master, derivatives, prompt scope, reference handling, user final lock,
  SHA-256, rights ceiling, and consumer paths. Map each basic card in its
  semantic 5-by-2 order using the actual atlas dimensions; keep labels/costs
  native and preserve every existing action ID/value.

- [ ] **Step 4: Run the asset test to verify GREEN**

  Run:

  ```text
  godot --headless --path . --script res://tests/verify_diagonal_duel_assets.gd
  ```

  Expected: exact paths load, crops retain alpha and foot-safe bounds, all ten
  basic cards point to the approved atlas, and manifests agree with bytes.

### Task 3: Add the current-timing action-reveal presentation component

**Files:**
- Create: `src/ui/combat_action_reveal_overlay.gd`
- Modify: `src/combat/combat_resolution_engine.gd`
- Modify: `src/combat/combat_board_preview.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `src/combat/combat_character_placeholder.gd`
- Test: `tests/verify_combat_presentation_liveness.gd`
- Test: `tests/verify_combat_presentation_controls.gd`

**Interfaces:**
- Consumes: `timing_results[*].events`, current `combat_state`, resolved
  display fields, and the approved illustration contract.
- Produces: `CombatActionRevealOverlay.present_timing(events, timing, context)`
  and `get_snapshot()`; the board invokes it before
  `_apply_timing_snapshot(timing_result.state)`.

- [ ] **Step 1: Keep the new liveness assertions RED**

  Confirm the tests fail before production changes because `action_reveal_overlay`
  is missing and the previous code applies snapshots before presenting the timing.

- [ ] **Step 2: Extend resolved records with display-safe fields only**

  In `_resolved_record`, duplicate these definition fields:

  ```gdscript
  "source_label", "category_label", "range_text", "action_slots",
  "stamina_cost", "internal_cost", "illustration"
  ```

  Do not add them to `public_resolution_history`, AI planner input, pre-commit
  preview, save data, or unlocked enemy action reveal.

- [ ] **Step 3: Implement the overlay as a presentation-only native Control**

  Build a round/bundle/timing header, left/right action cells, an outcome label,
  text/shape states for empty actions, and a snapshot with exactly the events
  visible for its active timing. Make cards non-interactive and set accessibility
  name/description from the active public actions. Use native labels and
  `TextureRect` assets; do not bake UI text into images.

- [ ] **Step 4: Reorder board playback and hide planning surfaces during the beat**

  For each `timing_result`: present the overlay and current result motion/SFX,
  then apply the authoritative snapshot. Hide the dock/timing/progress while
  presentation is active and restore them after the existing review-confirmed
  transition. Preserve one resolution call and existing review behavior.

- [ ] **Step 5: Route the two new battler derivatives**

  Use the player derivative for player role and Dogyeom derivative only for
  `slot1_dogyeom`; retain generic enemy routing and status portraits. Preserve
  inward facing, foot-anchor, idle, move, attack, reduced-motion, and diagonal
  foreground/background behavior.

- [ ] **Step 6: Run focused Godot scripts to verify GREEN**

  Run:

  ```text
  godot --headless --path . --script res://tests/verify_combat_presentation_liveness.gd
  godot --headless --path . --script res://tests/verify_combat_presentation_controls.gd
  godot --headless --path . --script res://tests/verify_combat_character_art.gd
  godot --headless --path . --script res://tests/verify_dogyeom_combat_battler.gd
  ```

  Expected: current timing only is visible, state follows the reveal, skip is
  prompt, no extra resolver invocation occurs, and routes/anchors remain valid.

### Task 4: Integrate, regress, and capture exact-worktree runtime evidence

**Files:**
- Modify: `tests/verify_basic_action_panel.gd`
- Modify: `tests/verify_combat_action_selection_integration.gd`
- Modify: `tests/verify_vertical_slice_combat_bridge.gd`
- Create: `docs/operations/2026-08-30_DIAGONAL_DUEL_ACTION_REVEAL_EXECUTION_REPORT.md`

**Interfaces:**
- Consumes: approved assets, overlay, board playback, vertical-slice default
  route, existing runtime session.
- Produces: full contract/regression results and separated machine/runtime/
  human evidence.

- [ ] **Step 1: Update affected current-consumer tests**

  Assert ten basic cards render the new atlas with aspect-preserving display,
  the real `ActionSelectionDock` stays locked during a reveal, and the vertical
  slice routes `slot1_dogyeom` to the new combat battler while retaining his
  existing status portrait.

- [ ] **Step 2: Run static and focused suites**

  Run the asset, board, presentation, character, Dogyeom, action dock, action
  selection, vertical bridge, and relevant engine tests; then run the project
  Python discovery suite. Inspect Godot output for errors rather than relying
  on process exit alone.

- [ ] **Step 3: Run the exact Godot worktree and inspect a completed timing**

  Use the already matched Hera editor/session. Navigate the normal start flow
  to `slot1_dogyeom`, complete a first bundle, capture the active first timing
  overlay and the post-timing state, inspect the UI tree/screenshot/diagnostics,
  and keep other-project sessions untouched.

- [ ] **Step 4: Perform five full-scope adversarial review loops**

  Review: (1) rule/AI/save ownership, (2) character and atlas provenance,
  (3) future-action leakage and skip/reduced-motion behavior, (4) actual
  visible consumer/layout/input/accessibility, and (5) changed/untouched
  reference propagation and rollback. Fix only validated scope findings.

- [ ] **Step 5: Write execution evidence and run reference freshness**

  Record baseline/head, paths, hashes, consumer routing, RED/GREEN evidence,
  runtime capture, review-loop outcomes, untouched consumers, and all evidence
  ceilings. Run the project reference-freshness check against the branch diff.

## Plan Self-Review

- **Spec coverage:** Task 1 establishes objective failure conditions; Task 2
  covers art/provenance/atlas mapping; Task 3 covers timing-only reveal and
  routing; Task 4 covers integration, runtime, evidence, and adversarial exit.
- **Type consistency:** The overlay's inputs are existing `Array` events and
  `Dictionary` context; output is a `Dictionary` snapshot. Board state still
  enters through `_apply_timing_snapshot(Dictionary)`.
- **Scope preservation:** No task changes card values, resolver decisions,
  public-history schema, AI inputs, saves, generic enemy behavior, or portraits.
