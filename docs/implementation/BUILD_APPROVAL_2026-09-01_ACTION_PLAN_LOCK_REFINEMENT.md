# Action Plan Lock · Execute CTA BUILD Approval

- **Decision / contract:** `TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01` and `docs/design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md`.
- **Approved on:** `2026-09-01 KST`.
- **Approval source:** user-directed continuation after explicit confirmation that the plan lock must fit its slot and action execution should show only the current action count; latest user instruction authorizes the recommended blueprint, benchmark, needed UI, and implementation continuation.
- **Implementation PR:** current `codex/blueprint-benchmark-ui-20260901` only.
- **Authority level:** `SCOPED_COMBAT_INTERACTION_CARRIER_REFINEMENT_ONLY`.

## Approved protected runtime paths

1. `src/combat/combat_board_preview_auto.gd`
2. `src/ui/combat_progress_button.gd`
3. `src/ui/action_selection/action_selection_dock.gd`

The first progress activation may enter only `plan_locked` with no resolver call. The second activation may use the pre-existing resolver path exactly once. Current action cards and timing slots become read-only while locked.

## Protected exclusions

The 10-cell logical core, opening distance, `3 → 3 → 4` cadence, combat calculations, saving, AI information boundary, observation payload, action data, approved image bytes, title screen, Android behavior, release work, and unrelated refactors remain out of scope. No new raster asset is approved or required.

## Required evidence

- product regression proves first activation has resolution count `0` and second activation has exact count `1`;
- existing combat/reveal/ultimate/terminal verifiers continue to pass;
- project-local contract and full Python suite remain green;
- safe project-bound visual capture remains separate from human UX approval.
