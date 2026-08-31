# Grounded Duel, Automatic Targeting, and Observation BUILD Approval

- **Decision / contract:** `TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01`, retaining the applicable boundaries of `TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01` and `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01`.
- **Approved on:** `2026-09-01 KST`.
- **Approval source:** the user's explicit 2026-09-01 five-part request (grounded combatants; movement-only approach/retreat; bounded locked plan blocks; compact current-bundle execution; type-only opponent observation), plus standing in-scope continuation and required-approval authorization.
- **Issue / PR:** implementation continuation / `#305`.
- **Authority level:** `SCOPED_COMBAT_PRESENTATION_AND_INPUT_RECONCILIATION_ONLY`.

## Approved scope

1. Place both frontal-duel characters at the approved courtyard floor reference with only a flattened contact shadow; do not alter approved raster bytes or combat geometry.
2. Keep explicit player targeting only for movement's `접근 / 후퇴`.  Auto-place every non-movement action against the already public opponent and derive internal relative direction only when resolving.
3. Constrain linked action blocks to their own timing slots; compact the visible execution control to the current bundle's `N수 실행` without changing commit semantics.
4. Spend only available observation points after the enemy bundle locks to disclose each locked enemy **action type**.  Keep card name, technique/manual ID, cost, range, target, direction, damage, future bundle, and AI weights hidden.
5. Keep a multi-slot 절초 reservation atomic: source switching stays locked only while its reservation is active and returns after the player removes the reserved timing slot.
6. Update only the exact protected paths in `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`, focused regressions, machine runtime evidence, and the execution report required for PR #305.

## Exclusions and evidence ceiling

The 10-cell logical battlefield, opening distance, `3 → 3 → 4` cadence, resolver formulas, save schema, public-only AI boundary, deck/hand/draw prohibition, approved raster assets, platform architecture, Android behavior, release work, and unrelated refactors are not approved by this record.

Automated checks and a visible Windows Godot machine capture are evidence only.  Human usability, human play, accessibility-user, Android actual-device, gamepad, release-performance, remote CI completion, merge, and post-merge main readback remain separate gates.
