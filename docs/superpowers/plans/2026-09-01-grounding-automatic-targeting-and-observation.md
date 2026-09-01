# Grounded Duel, Automatic Attack Targeting, and Observation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make combatants visibly contact the frontal-duel courtyard floor, keep intent choice only for movement, compact the bundle-execution control, keep locked action blocks inside their timing cells, and automatically disclose locked opponent action *types* when observation is available.

**Architecture:** The shared combat resolver keeps its existing zero-direction-to-opponent fallback. The selection UI therefore marks attacks target-ready immediately and opens semantic intent cards only for movement. The combat board resolves observation at the moment the enemy bundle becomes locked, recording only existing action-type payloads; the manual reveal button is retired from the player surface. A background-owned floor reference anchors both combatants and their shadows, while timing and progress controls use bounded geometry.

**Tech Stack:** Godot 4/GDScript, repository JSON data contracts, Godot headless verification scripts, Python static-contract checks, GitHub pull request, HERA live-editor runtime capture.

**Spec:** `AGENTS.md`; `docs/07_COMBAT_UI_SPEC.md`; `docs/decisions/2026-08-31_FRONTAL_DUEL_PRESENTATION_AND_ILLUSTRATED_CARD_POLICY_DECISION.md`; `docs/decisions/2026-08-02_OBSERVATION_STATS_MASTERY_DECISION.md`; latest user request dated 2026-09-01.

## Global Constraints

- Preserve the one-versus-one, ten-cell logical battlefield and the `3수 → 해결 → 3수 → 해결 → 4수 → 해결` cadence.
- Movement retains only explicit `접근` / `후퇴` semantic intent; attack, defense, response, and ultimate actions do not request a direction from the player.
- Automatic observation may disclose only locked opponent action *types*; names, IDs, costs, range, direction, damage, targets, and future bundles remain hidden.
- Do not reintroduce a visible tile grid, deck/hand/draw UI, opponent-hypothesis UI, or a separate manual observation-reveal button.
- Use the existing approved frontal courtyard and character/card assets; create no replacement imagery.
- Work only in `codex/grounding-automatic-targeting-20260901`; no direct `main` push, force push, or modification of unrelated worktrees.
- Tests must be written and observed failing before production code is changed. Runtime captures are `MACHINE_RUNTIME_CAPTURE`, never Human/Android/accessibility/release PASS.

---

### Task 1: Capture and specify the current visual and information boundary

**Files:**
- Read: `scenes/combat/combat_board_preview.tscn`
- Read: `src/combat/combat_board_preview.gd`
- Read: `src/combat/combat_board_preview_auto.gd`
- Read: `src/combat/battle_background.gd`
- Read: `src/combat/combat_character_placeholder.gd`
- Read: `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`
- Create: `docs/decisions/2026-09-01_GROUNDED_DUEL_AUTOMATIC_TARGETING_AND_OBSERVATION_DECISION.md`

**Interfaces:**
- Consumes: `BattleBackground.get_duel_floor_y(viewport_size: Vector2) -> float` to be introduced in Task 4.
- Produces: a scoped Decision that supersedes manual player attack-aim selection and manual observation reveal only; it does not change resolver direction or information-policy boundaries.

- [ ] **Step 1: Start the exact worktree scene without mutating tracked project sources**

Run: `godot --path . --editor` in the task worktree, attach HERA only to that exact project/editor instance, run `scenes/combat/combat_board_preview.tscn`, and capture the initial 1440×900 combat screen.

Expected: a labeled baseline `MACHINE_RUNTIME_CAPTURE` that shows the current combatant foot positions, timing cells, compact-control starting size, and any visible manual observation surface.

- [ ] **Step 2: Record the decision boundary**

Write the Decision with these exact product rules:

```markdown
- Player-originated movement opens `접근` / `후퇴` intent cards.
- Every non-movement selectable action locks directly against the public opposing combatant; its stored direction remains `0` and the resolver derives the relative direction at resolution.
- When the next enemy bundle has been locked, every available player observation point automatically reveals the next still-hidden locked enemy action type. The payload is `ACTUAL_ACTION_TYPES` only.
- The main CTA is rendered as `<N>수 실행`; it contains no explanatory caption and uses only the current bundle count.
```

- [ ] **Step 3: Register the baseline capture and verify source invariance during live observation**

Use `tools/register_runtime_visual_capture.py` to add the baseline image SHA-256, scene, revision, viewport, and `MACHINE_RUNTIME_CAPTURE` status to the manifest. Compare `git status --short` before and after the HERA session; the only allowed new tracked files are capture-evidence entries deliberately registered by this task.

### Task 2: Prove the new targeting and observation behavior is missing

**Files:**
- Modify: `tests/verify_combat_board.gd`
- Modify: `tests/verify_phase2_observation.gd`
- Modify: `tests/verify_ink_paper_combat_presentation.gd`
- Modify: `tests/test_action_card_source_unification_contract.py`

**Interfaces:**
- Consumes: current `ActionTimingPanel._targeting_mode_for_definition(definition: Dictionary) -> String`.
- Produces: failing regression coverage for automatic non-move targeting, observation auto-reveal, compact CTA geometry, bounded linked blocks, and background-derived grounded feet.

- [ ] **Step 1: Add an automatic attack targeting test**

Add a board assertion that places a `category == "attack"` card and verifies:

```gdscript
assert(timing_panel._targeting_mode_for_definition({"category": "attack"}) == "none")
assert(timing_slot.target_ready)
assert(board._targeting_anchor == 0)
```

Also retain the existing movement assertion:

```gdscript
assert(timing_panel._targeting_mode_for_definition({"category": "move"}) == "move_intent")
```

- [ ] **Step 2: Add a compact CTA and contained lock-block layout test**

Add assertions after a 1440×900 layout:

```gdscript
assert(board.combat_progress_button.get_button_text() == "3수 실행")
assert(board.combat_progress_button.size.x <= 104.0)
assert(board.combat_progress_button.size.y <= 72.0)
assert(board.action_timing_panel.is_linked_block_inside_timing_bounds())
```

- [ ] **Step 3: Add an observation auto-reveal test that checks only permitted fields**

At enemy-plan lock with one observation point, call the new board helper and assert:

```gdscript
var payload := board.reveal_available_locked_enemy_action_types()
assert(payload.get("ok", false))
assert(payload.get("reveal_level", "") == "ACTUAL_ACTION_TYPES")
assert(not payload.has("technique_id"))
assert(not payload.has("cost"))
assert(not payload.has("direction"))
assert(board.observation_reveal_button == null)
```

- [ ] **Step 4: Add a grounded-foot contract**

At 1440×900, assert both character anchors equal the background floor reference and their shadow contact is not below the anchor:

```gdscript
var floor_y := board.battle_background.get_duel_floor_y(board.size)
assert(is_equal_approx(board.player_character.get_foot_position().y, floor_y))
assert(is_equal_approx(board.enemy_character.get_foot_position().y, floor_y))
assert(board.player_character.get_shadow_contact_y() <= floor_y)
```

- [ ] **Step 5: Run the focused test scripts to verify RED**

Run:

```powershell
godot --headless --path . -s tests/verify_combat_board.gd
godot --headless --path . -s tests/verify_phase2_observation.gd
godot --headless --path . -s tests/verify_ink_paper_combat_presentation.gd
python tests/test_action_card_source_unification_contract.py
```

Expected: failure because attacks currently request `aim_intent`, the manual observation button still exists, the CTA says `행동계획 실행`, no timed-block bounds helper exists, and the background has no floor-contact API.

### Task 3: Remove manual non-movement direction selection and compact the execution CTA

**Files:**
- Modify: `src/ui/action_timing_panel.gd`
- Modify: `src/ui/action_timing_panel_auto.gd`
- Modify: `src/ui/action_selection/action_placement_controller.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `src/ui/combat_progress_button.gd`
- Modify: `src/ui/combat_progress_button.tscn`
- Modify: `data/combat/combat_board_poc.json`
- Modify: `data/combat/combat_resolution_preview.json`
- Modify: `data/combat/mastery_ultimate_poc.json`

**Interfaces:**
- Consumes: resolver convention that a zero `direction` means relative opponent direction at resolution.
- Produces: `ActionTimingPanel._targeting_mode_for_definition` returns `move_intent` only for movement, `CombatProgressButton.get_button_text() -> String`, and `ActionTimingPanel.is_linked_block_inside_timing_bounds() -> bool`.

- [ ] **Step 1: Implement direct readiness for every non-move action**

Change the targeting mode function to:

```gdscript
func _targeting_mode_for_definition(definition: Dictionary) -> String:
    if str(definition.get("category", "")) == "move":
        return "move_intent"
    return "none"
```

In the board, restrict `_begin_targeting_for_anchor` and semantic intent construction to `move_intent`; remove `aim_opponent` and `predict_away` entries from the player-facing intent UI.

- [ ] **Step 2: Make linked plan blocks clip and remain inside timing bounds**

Enable `clip_contents` on the linked-block root, calculate its top and bottom within the selected slots with a five-pixel bottom gutter, and add `is_linked_block_inside_timing_bounds()` that validates every visible `LinkedActionBlock.get_global_rect()` against the union of the timing slot rects.

- [ ] **Step 3: Replace the large explanatory control with current bundle count**

Implement:

```gdscript
func get_button_text() -> String:
    return "%d수 실행" % _current_bundle_action_count()
```

Hide the explanatory caption, keep keyboard focus and disabled feedback, set the control minimum size to `Vector2(88, 64)`, and lay it out vertically centered beside the timing strip at no more than 104×72 pixels.

- [ ] **Step 4: Synchronize POC and ultimate targeting data**

Replace semantic player attack-aim flags with `auto_target_public_opponent: true`; retain `move_intent` for movement. Update ultimate data so its player-facing targeting mode is automatic while its resolver data still carries a zero default direction.

- [ ] **Step 5: Run focused tests to verify GREEN**

Run the four commands from Task 2. Expected: every new targeting/layout/CTA contract passes without changing combat-resolver direction logic.

### Task 4: Ground both combatants to the frontal-courtyard floor

**Files:**
- Modify: `src/combat/battle_background.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `src/combat/combat_character_placeholder.gd`
- Modify: `tests/verify_ink_paper_combat_presentation.gd`

**Interfaces:**
- Produces: `BattleBackground.get_duel_floor_y(viewport_size: Vector2) -> float`, `CombatCharacterPlaceholder.get_foot_position() -> Vector2`, and `CombatCharacterPlaceholder.get_shadow_contact_y() -> float`.

- [ ] **Step 1: Determine the approved background’s visual floor line from the baseline capture**

Use the actual frontal-courtyard image and 1440×900 baseline capture. Record the normalized floor-contact ratio inside `BattleBackground` as a named constant with a comment that it refers to the foreground stone-band contact line, not to a logical tile coordinate.

- [ ] **Step 2: Implement aspect-covered floor conversion**

Add:

```gdscript
func get_duel_floor_y(viewport_size: Vector2) -> float:
    var rendered := _aspect_covered_texture_size(viewport_size)
    var top_crop := (rendered.y - viewport_size.y) * 0.5
    return FLOOR_CONTACT_IMAGE_RATIO * rendered.y - top_crop
```

The helper must calculate the covered texture size from the approved background texture, so crop changes at wide and mobile landscape viewports do not detach feet from the artwork.

- [ ] **Step 3: Anchor feet and contact shadows to the same background floor reference**

In `_apply_frontal_duel_composition`, derive the shared foot Y from `battle_background.get_duel_floor_y(size)` and clamp only against the HUD/timing safe bounds. In the character renderer, draw a flattened low-opacity contact shadow whose center is at or one pixel above the foot anchor; expose its contact Y for verification.

- [ ] **Step 4: Run the presentation and board tests to verify GREEN**

Run:

```powershell
godot --headless --path . -s tests/verify_ink_paper_combat_presentation.gd
godot --headless --path . -s tests/verify_combat_board.gd
```

Expected: both combatants share the background floor reference, no vertical idle offset is introduced, and timing controls remain clear of their feet.

### Task 5: Automate fair observation disclosure at enemy bundle lock

**Files:**
- Modify: `src/combat/combat_board_preview.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `tests/verify_phase2_observation.gd`
- Modify: `tests/test_observation_answer_leak_guardrails_contract.py`

**Interfaces:**
- Consumes: `CombatResolutionEngine.get_locked_enemy_action_type_entries` and `reveal_next_locked_enemy_action_types`.
- Produces: `CombatBoardPreview.reveal_available_locked_enemy_action_types() -> Dictionary`, invoked after the next enemy bundle is locked.

- [ ] **Step 1: Replace the player-facing reveal button with an automatic board helper**

Implement a loop that stops when either observation points or still-hidden entries end:

```gdscript
func reveal_available_locked_enemy_action_types() -> Dictionary:
    var revealed: Array = []
    while int(combat_state.get("player", {}).get("observation_points", 0)) > 0:
        var entries := resolution_engine.get_locked_enemy_action_type_entries(combat_state, current_bundle)
        var result := resolution_engine.reveal_next_locked_enemy_action_types(combat_state, entries)
        if not bool(result.get("ok", false)):
            break
        revealed.append_array(result.get("revealed_action_types", []))
    return {"ok": not revealed.is_empty(), "reveal_level": "ACTUAL_ACTION_TYPES", "revealed_action_types": revealed}
```

The implementation must preserve existing audit metadata and no-leak filtering.

- [ ] **Step 2: Invoke it only after the enemy bundle is locked**

In `_on_review_continue_requested`, call the helper immediately after `resolution_engine.lock_enemy_bundle(...)`, before the next player planning screen is presented. Add an information log in the form `[관찰 공개] 다음 상대 행동: [이동 → 공격]`.

- [ ] **Step 3: Remove the manual observation-reveal button surface**

Do not instantiate `ObservationRevealButton` for the player. Present the result only through the existing observation record/status text and combat log. Preserve keyboard/screen-reader clarity by labeling it `관찰 공개 · 잠긴 상대 행동 유형`.

- [ ] **Step 4: Run observation and no-leak tests**

Run:

```powershell
godot --headless --path . -s tests/verify_phase2_observation.gd
python tests/test_observation_answer_leak_guardrails_contract.py
```

Expected: a locked enemy action type becomes visible automatically when a point exists, while technique, range, cost, direction, and target details remain absent.

### Task 6: Synchronize canon, perform full review, and capture the corrected runtime

**Files:**
- Modify: `docs/07_COMBAT_UI_SPEC.md`
- Create: `docs/operations/2026-09-01_GROUNDED_DUEL_AUTOMATIC_TARGETING_EXECUTION_REPORT.md`
- Modify: `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`
- Create: `docs/evidence/runtime-captures/TEN-RVC-20260901-00N.png`

**Interfaces:**
- Consumes: implementation and focused tests from Tasks 2–5.
- Produces: a canon-synchronized runtime evidence record and a review-ready branch.

- [ ] **Step 1: Update only the affected canon sections**

In `docs/07_COMBAT_UI_SPEC.md`, replace player attack direction-card language with automatic opposing-combatant targeting, replace manual observation-button language with post-lock automatic type disclosure, specify `<N>수 실행`, and cite the existing 2026-08-31 illustrated-card Decision rather than the stale no-illustration statement.

- [ ] **Step 2: Run full repository validation appropriate to touched surfaces**

Run project adapter validation plus focused UI/data checks and the Godot verification suite discovered from the current project test entrypoints. Record each exact command and status in the execution report; label skipped human/device categories `NOT_RUN`.

- [ ] **Step 3: Run five full-scope adversarial review loops**

For each loop inspect canon, actual diff, untouched resolver/AI consumers, test output, visual capture, storage/compatibility, cost, and long-term fit. Record concrete findings and resolutions; stop only after a clean final loop. Do not create artificial findings to fill loops.

- [ ] **Step 4: Capture and register the corrected 1440×900 Godot scene**

Run the exact worktree scene through HERA, capture the corrected screen, inspect character feet/shadows against the courtyard stones, inspect no manual attack direction UI for attack placement, inspect compact `3수 실행`, and inspect the bounded plan block. Register the SHA-256 and `MACHINE_RUNTIME_CAPTURE` manifest row.

- [ ] **Step 5: Commit, synchronize, publish, and read back**

Run `git fetch --prune`, rebase/reconcile with latest `origin/main` if it advanced, run all required checks again, commit the scoped changes, push the task branch, open a non-draft pull request, and record PR checks/review state. Do not merge until required GitHub checks and applicable review/ruleset gates are actually satisfied.

## Self-Review

- Spec coverage: Task 4 covers visual grounding; Task 3 covers movement-only direction selection, plan-lock containment, and compact action count; Task 5 covers observation disclosure. Task 6 covers canon/evidence, review, remote synchronization, and PR handoff.
- Placeholder scan: every task has concrete paths, APIs, code snippets, commands, and expected outcomes; no deferred implementation instruction is present.
- Type consistency: `get_duel_floor_y`, `get_foot_position`, `get_shadow_contact_y`, `get_button_text`, `is_linked_block_inside_timing_bounds`, and `reveal_available_locked_enemy_action_types` use the same signatures in producer and consumer tasks.

## Execution Handoff

The user has already authorized the active project contract and requested continuation. Execute this plan inline in the current isolated worktree, keeping checkpoint evidence after each task and stopping only for an unapproved material scope change or an external blocker.
