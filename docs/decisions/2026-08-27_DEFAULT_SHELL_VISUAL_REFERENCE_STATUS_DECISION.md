# TEN-DEC-20260827-DEFAULT-SHELL-VISUAL-REFERENCE-STATUS-01

## Status

`APPROVED_SCOPED_BUILD`

## Decision

The default `VerticalSliceShell` must distinguish an approved combat visual reference from full runtime visual integration. Its opening status no longer says the reference is pending; it states that the approved combat reference has not yet been fully applied to the functional UI.

## Approval provenance

The user authorized continued work and standing approval for ordinary scoped changes on 2026-08-27. This correction reconciles actual Godot copy with the already approved combat reference recorded in Project Notion and `current_visual_production_handoff_20260826.json`.

## Scope

- Correct only the shell's visual-reference metadata and first-screen status copy.
- Add a focused Godot regression that proves the approved-reference state and exact explanatory copy.

## Exclusions

- No combat behavior, action-plan semantics, asset creation, asset routing, scene topology, AI rule, platform claim, or human-validation claim.
- Full visual runtime integration remains unimplemented.

## Acceptance

1. `final_visual_reference_pending` is false.
2. The main screen exposes a named status node whose copy says the combat reference is approved but not yet fully applied.
3. The shell and configured default-entry Godot regressions pass.
