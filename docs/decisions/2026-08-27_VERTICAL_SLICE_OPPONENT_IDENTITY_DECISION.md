# Vertical Slice Opponent Identity Display Decision

- Decision: `TEN-DEC-20260827-VERTICAL-SLICE-OPPONENT-IDENTITY-01`
- Status: `APPROVED_SCOPED_CORRECTION`
- Issue: [#227](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/issues/227)

## Decision

The locked Vertical Slice opponent's `working_name` and `martial_identity` are copied into the combat enemy display state. The same candidate ID continues to select portrait and Battler assets.

## Why

The briefing already identifies the locked opponent, but the combat HUD retained the generic preview enemy name and epithet. This created one combatant with inconsistent player-facing identity.

## Boundaries

No combat rule, AI behavior, loadout, generic fallback, asset, or platform contract changes. Windows visible screenshot inspection is an agent-observed runtime check, not Human usability or Android evidence.
