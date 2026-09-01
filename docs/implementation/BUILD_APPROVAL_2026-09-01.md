# Grounded Duel, Automatic Targeting, and Observation BUILD Approval

- **Decision / contract:** `TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01`, retaining the applicable boundaries of `TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01` and `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01`.
- **Approved on:** `2026-09-01 KST`.
- **Approval source:** the user's explicit 2026-09-01 five-part request (grounded combatants; movement-only approach/retreat; bounded locked plan blocks; compact current-bundle execution; type-only opponent observation), plus standing in-scope continuation and required-approval authorization.
- **Issue / PR:** implementation continuation / `#305`.
- **Authority level:** `SCOPED_COMBAT_PRESENTATION_AND_INPUT_RECONCILIATION_ONLY`.

## Approved scope

1. Place both frontal-duel characters at the approved courtyard floor reference with only a flattened contact shadow; do not alter approved raster bytes or combat geometry.
2. Keep explicit player targeting only for movement's `접근 / 후퇴`. Auto-place every non-movement action against the already public opponent and derive internal relative direction only when resolving.
3. Constrain linked action blocks to their own timing slots; compact the visible execution control to the current bundle's `N수 실행` without changing commit semantics.
4. Spend only available observation points after the enemy bundle locks to disclose each locked enemy **action type**. Keep card name, technique/manual ID, cost, range, target, direction, damage, future bundle, and AI weights hidden.
5. Keep a multi-slot 절초 reservation atomic: source switching stays locked only while its reservation is active and returns after the player removes the reserved timing slot.
6. Update only the exact protected paths in `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`, focused regressions, machine runtime evidence, and the execution report required for PR #305.

## Exclusions and evidence ceiling

The 10-cell logical battlefield, opening distance, `3 → 3 → 4` cadence, resolver formulas, save schema, public-only AI boundary, deck/hand/draw prohibition, approved raster assets, platform architecture, Android behavior, release work, and unrelated refactors are not approved by this record.

Automated checks and a visible Windows Godot machine capture are evidence only. Human usability, human play, accessibility-user, Android actual-device, gamepad, release-performance, remote CI completion, merge, and post-merge main readback remain separate gates.

---

# Action Plan Lock · Execute CTA BUILD Approval Addendum

- **Decision / contract:** `TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01` and `docs/design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md`.
- **Approved on:** `2026-09-01 KST`.
- **Approval source:** user-directed continuation after explicit confirmation that the plan lock must fit its slot and action execution should show only the current action count; latest user instruction authorizes the recommended blueprint, benchmark, needed UI, and implementation continuation.
- **Implementation PR:** current `codex/plan-lock-execution-20260901` only.
- **Authority level:** `SCOPED_COMBAT_INTERACTION_CARRIER_REFINEMENT_ONLY`.

## Addendum approved protected runtime paths

1. `src/combat/combat_board_preview_auto.gd`
2. `src/ui/combat_progress_button.gd`
3. `src/ui/action_selection/action_selection_dock.gd`

The first progress activation may enter only `plan_locked` with no resolver call. The second activation may use the pre-existing resolver path exactly once. Current action cards and timing slots become read-only while locked.

## Addendum exclusions

The 10-cell logical core, opening distance, `3 → 3 → 4` cadence, combat calculations, saving, AI information boundary, observation payload, action data, approved image bytes, title screen, Android behavior, release work, and unrelated refactors remain out of scope. No new raster asset is approved or required.

## Addendum required evidence

- product regression proves first activation has resolution count `0` and second activation has exact count `1`;
- existing combat/reveal/ultimate/terminal verifiers continue to pass;
- project-local contract and full Python suite remain green;
- safe project-bound visual capture remains separate from human UX approval.
