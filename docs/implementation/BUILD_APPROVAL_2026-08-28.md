# VisualReferenceStatus Copy Correction Build Approval

- Decision: `TEN-DEC-20260827-DEFAULT-SHELL-VISUAL-REFERENCE-STATUS-01`
- Approved on: `2026-08-28 KST`
- Approval source: current user instruction `진행해`, together with the standing approval for ordinary scoped corrections.
- Issue / PR: `#240` / `#241`
- Authority level: `SCOPED_DEFAULT_SHELL_STATUS_COPY_CORRECTION_ONLY`

## Approved scope

1. Replace only the stale `VerticalSliceShell/VisualReferenceStatus` copy so it states that the approved combat reference is confirmed.
2. Preserve `final_visual_reference_pending=false` and the distinction between reference approval and unperformed final visual integration.
3. Update the exact real-Label Godot regression and record focused validation.
4. Use the one-time protected-path approval lifecycle for `src/run/vertical_slice_shell.gd`, then archive the active approval after merge.

## Exclusions and evidence ceiling

No layout, scene hierarchy, combat or Route rule, asset approval/routing, image generation, or visual integration changes are authorized. Windows visible usability, Android actual device, accessibility-user, human readability/fun, and live-editor observation remain `NOT_RUN` until separately performed.
