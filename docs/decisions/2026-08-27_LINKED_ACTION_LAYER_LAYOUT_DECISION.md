# Linked-Action Layer Layout Decision

- Decision ID: `TEN-DEC-20260827-LINKED-ACTION-LAYER-LAYOUT-01`
- Status: `APPROVED_SCOPED_BUILD`
- Issue: `#224`
- Baseline: `9c273499d3a63d9a689ebde9ecc9712ce230ac2f`

## Decision

The `LinkedActionBlockLayer` remains a full-rect anchored child of `ActionTimingPanel`. Its size is owned by those anchors; the duplicate manual `size` assignment is removed.

## Rationale

Godot reported that manual sizing conflicts with the layer's non-equal opposite anchors. The layer already uses `Control.PRESET_FULL_RECT`, so keeping both mechanisms adds no behavior and causes a runtime warning.

## Protected behavior

The linked blocks still calculate their own rectangles from timing slots. Placement, drag/drop, move, remove, focus, accessibility, combat rules, and visual assets are unchanged.

## Evidence boundary

Focused automated Godot regressions verify the correction. Windows visible human usability, Android actual-device validation, physical gamepad, accessibility-user, and Human gameplay/readability remain `NOT_RUN`.
