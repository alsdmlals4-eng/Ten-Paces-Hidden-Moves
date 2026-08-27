# Issue #227 Vertical Slice Opponent Identity Execution Report

- Baseline: `ab422dfb69f22caea7a2639b8bd294f19f8874ad`
- Work mode: `BUILD`
- Skill: `ten-paces-verification`
- Skill mode: `regression`, `runtime-validation`
- Decision: `TEN-DEC-20260827-VERTICAL-SLICE-OPPONENT-IDENTITY-01`

## Root cause

The bridge preserved only `candidate_id`, which correctly routed the approved Dogyeom portrait and Battler but left `name` and `epithet` from the generic HUD preview enemy.

## Change

The shell now supplies the locked opponent display identity; the bridge copies non-empty `name` and `epithet` into enemy combat state before the HUD refreshes.

## Evidence

- Test-first: `verify_vertical_slice_combat_bridge.gd` failed with Dogyeom versus generic HUD name/epithet, then passed after the minimal change.
- Related status portrait, Battler, action repositioning, and Vertical Slice shell regressions passed.
- Hera runtime flow reached Combat and showed `도겸` / `묵직한 권객` with the approved portrait and Battler; diagnostics were clean.

## Evidence ceiling

Windows visible Human usability, Android physical device, physical gamepad, accessibility-user validation, Human fun/readability, and release performance remain `NOT_RUN`.

## Derived operating views

The current Base checkout cannot regenerate the project's declared v9.4.3 adapter: its available release-lock map stops before that version. The canonical adapter baseline was updated for this protected change, then its four hash-consuming derived views were mechanically synchronized to the exact canonical SHA-256 and checked by their project consumers. No Base release identity or route was changed.

The existing v9.4 adoption test still asserted the superseded v9.4.0 version, release pin, and evidence pin although the canonical adapter and both generated views already declared v9.4.3. Its three stale identity expectations were reconciled to the existing declared identity; this does not change the adapter, routes, or release pin.
