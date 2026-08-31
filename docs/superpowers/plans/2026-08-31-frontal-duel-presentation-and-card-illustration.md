# Frontal Duel Presentation and Illustrated Card Policy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` or `superpowers:subagent-driven-development` task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Promote the final-locked frontal courtyard background and make the combat screen a same-ground-line frontal duel while removing the obsolete hypothesis and visible immediate-complete UI without changing combat rules.

**Architecture:** The background remains a data-free `TextureRect`; `CombatBoardPreviewAuto` changes only player-facing layout anchors; `CombatBoardPreview` retires only user-facing controls and their focus/summary plumbing. Action cards remain one shared component; a subsequent image-only gate supplies non-basic illustration content.

**Tech Stack:** Godot 4.7 GDScript, project-owned JSON/Markdown asset manifest, Godot headless regression scripts, visible Windows Godot/Hera runtime readback.

**Spec:** `docs/superpowers/specs/2026-08-31-frontal-duel-presentation-and-card-illustration-design.md`

## Global Constraints

- Preserve the 10-tile logical combat model, distance-first display, 3/3/4 planning, AI private-plan boundary, save schema, and Windows/Android shared core.
- Do not delete active or rollback assets merely because they are no longer the active presentation.
- Keep Fast Replay, Reduced Motion, sound controls, sequential reveal, combat log, observation, and review functional.
- Use RED→GREEN tests before production GDScript changes; do not mark Human, Android, accessibility-user, or release evidence as passed without its own run.

---

### Task 1: Write the presentation-regression contract before source changes

**Files:**
- Modify: `tests/verify_ink_paper_combat_presentation.gd`
- Modify: `tests/verify_combat_character_art.gd`
- Modify: `tests/verify_combat_focus_order.gd`
- Modify: `tests/verify_combat_review_ui.gd`

**Interfaces:**
- Consumes: `CombatBoardPreview.get_layout_snapshot()`, `CombatCharacterPlaceholder.get_foot_anchor_global()`, child-node names, `BattleBackground` metadata.
- Produces: failing checks for the promoted background route, a shared baseline, removed user-facing controls, and retained reveal/review routes.

- [ ] **Step 1: Replace diagonal and removed-control expectations with the desired contract.**

```gdscript
_expect(board.get_meta("duel_composition", "") == "player_left|enemy_right|shared_ground|distance_center", "Combat must use the frontal same-ground-line composition.")
_expect(absf(player_foot.y - enemy_foot.y) <= 1.0, "Both combatants must share the visible ground baseline.")
_expect(board.get_node_or_null("OpponentHypothesisPanel") == null, "Opponent hypothesis input must not be a runtime node.")
_expect(board.get_node_or_null("SkipPresentationButton") == null, "Immediate-complete must not be player-facing.")
```

- [ ] **Step 2: Run the four focused scripts and record expected RED failures.**

```powershell
& $Godot --headless --path . -s res://tests/verify_ink_paper_combat_presentation.gd
& $Godot --headless --path . -s res://tests/verify_combat_character_art.gd
& $Godot --headless --path . -s res://tests/verify_combat_focus_order.gd
& $Godot --headless --path . -s res://tests/verify_combat_review_ui.gd
```

Expected: failures identify the old active background, diagonal vertical offset, and hypothesis/skip focus nodes.

### Task 2: Promote the final-locked raster with rollback provenance

**Files:**
- Create: `docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.png`
- Create: `docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.md`
- Create: `assets/backgrounds/frontal_courtyard_duel_background_01_v1.png`
- Modify: `assets/ASSET_MANIFEST.json`
- Modify: `src/combat/battle_background.gd`

**Interfaces:**
- Consumes: candidate SHA-256 `27778369c3896d7d6237990ec70620c54ad0d636f660c9aa80322b0632262d06` and user final lock.
- Produces: active `BattleBackground` path and an inactive `ink_mist_valley_duel_01_v1` rollback record.

- [ ] **Step 1: Copy the candidate to canonical and runtime destinations without overwriting the previous background.**
- [ ] **Step 2: Write provenance with the candidate hash, generation output ID, user lock, intended consumer, reference boundary, and evidence ceiling.**
- [ ] **Step 3: Point `BACKGROUND_SOURCE_PATH` and preload at the new runtime PNG; set metadata to `original_frontal_courtyard_hanji_wuxia_duel`.**
- [ ] **Step 4: Verify byte equality of candidate, canonical, and runtime copies, then run the focused background regression.**

### Task 3: Replace the diagonal stage with a frontal same-ground-line stage

**Files:**
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `src/combat/combat_character_placeholder.gd`
- Modify: `tests/verify_ink_paper_combat_presentation.gd`
- Modify: `tests/verify_combat_character_art.gd`
- Modify: `tests/verify_diagonal_duel_assets.gd`

**Interfaces:**
- Consumes: existing `set_dimensions`, `place_foot_at`, HUD/timing bounds, and approved player/enemy battler paths.
- Produces: `duel_composition=player_left|enemy_right|shared_ground|distance_center`, equal foot Y, comparable dimensions, and the approved inward-facing player image route.

- [ ] **Step 1: Change `_apply_diagonal_duel_composition()` to one `shared_foot_y`, comparable widths, same z-order, left/right separation, and a centred range panel.**
- [ ] **Step 2: Route `PLAYER_ART_PATH` to `player_wanderer_battler_rgba_v1.png`; retain generic-enemy and candidate-specific Dogyeom routing until its own asset decision.**
- [ ] **Step 3: Run the Task 1 RED scripts until they turn GREEN, then run movement/attack-moment regressions to confirm logical tiles and anchors remain intact.**

### Task 4: Retire obsolete player-facing intent-hypothesis and immediate-complete UI

**Files:**
- Modify: `src/combat/combat_board_preview.gd`
- Delete only after zero-reference check: `src/ui/opponent_hypothesis_panel.gd`, `scenes/ui/opponent_hypothesis_panel.tscn`
- Modify: `src/combat/combat_review_summary_builder.gd` and `src/ui/combat_review_panel.gd` only if they still display the removed player-hypothesis field
- Modify: `tests/verify_combat_focus_order.gd`, `tests/verify_combat_review_ui.gd`, `tests/verify_diagonal_duel_action_reveal.gd`

**Interfaces:**
- Consumes: presentation state and review result only.
- Produces: no hypothesis selection/focus/copy and no visible skip button, with an internal deterministic completion helper retained for tests if required.

- [ ] **Step 1: Remove the preload, member, construction, layout, focus, reset/commit calls, metadata, and accessibility labels for `OpponentHypothesisPanel`.**
- [ ] **Step 2: Remove `SkipPresentationButton` construction/layout/focus/accessibility. Preserve `_skip_presentation()` only as non-player-facing test plumbing; do not bind it to a visible input.**
- [ ] **Step 3: Replace review expectations that require a user hypothesis with public result/reason expectations.**
- [ ] **Step 4: Run the focused focus/review/reveal scripts and verify fast replay, reduced motion, sound, sequential reveal, and review continue to work.**

### Task 5: Record card-art coverage honestly and prepare the next asset gate

**Files:**
- Modify: `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`
- Modify: `docs/decisions/2026-08-30_MARTIAL_MANUAL_TEXT_FIRST_PRESENTATION_DECISION.md` with superseded status only
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` and current planning status owner
- Create after generation: one candidate record under `docs/visual-assets/candidates/`

**Interfaces:**
- Consumes: active basic atlas and current shared `ActionChoiceCard` consumer.
- Produces: `BRIEF_READY`/`GENERATED_CANDIDATE` only for non-basic card art until a separate final lock.

- [ ] **Step 1: Record the user-approved all-card-illustration policy and mark non-basic runtime coverage as pending rather than falsely completed.**
- [ ] **Step 2: Generate exactly one text-free supplemental category-atlas candidate; preserve it outside runtime assets with its prompt, output ID, hash, and planned action-source mapping.**
- [ ] **Step 3: Present that candidate for a separate final lock before adding it to card data, manifest, or runtime panels.**

### Task 6: Full verification, adversarial review, and delivery hygiene

**Files:**
- Create: `docs/operations/2026-08-31_FRONTAL_DUEL_PRESENTATION_EXECUTION_REPORT.md`
- Modify: affected current status owners from Task 5

- [ ] **Step 1: Run project operating validation, affected static checks, focused Godot scripts, relevant Python discovery, and `git diff --check` (excluding binary PNGs).**
- [ ] **Step 2: Use Hera against the exact worktree editor session: open combat, inspect the node tree, select an action, run a sequential reveal, and capture/read the frontal screenshot.**
- [ ] **Step 3: Run five adversarial review loops across source/asset authority, unaffected combat core, focus/accessibility, runtime screen, and repository hygiene; correct real findings only.**
- [ ] **Step 4: Remove generated local test captures/import caches, commit only canonical source, create the current-task PR, and preserve the active worktree until merge and exact-main readback are complete.**
