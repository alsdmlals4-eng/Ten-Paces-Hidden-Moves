# TEN-DEC-20260827-DEFAULT-VERTICAL-SLICE-ENTRY-01

## Status

`APPROVED_SCOPED_BUILD`

## Decision

The already implemented `VerticalSliceShell` becomes the default application entry point. F5 now begins at `Main`, from which the existing `Setup → Briefing → Combat → Review → Result → Route` flow is reachable. The isolated `CombatBoardPreview` remains the shell's reusable combat implementation, not the app's default entry.

## Approval provenance

User execution contract pasted on 2026-08-27: resume the current project as an automatically executed, minimal, playable vertical slice; routine approval stops are not required. The change is the smallest consumer-facing completion of the existing PC-first first-five-duel slice.

## Scope

- `project.godot` application title and main scene only.
- Regression verification that the configured entry instantiates the existing shell and exposes run start.
- Current-state governance tests corrected to the already merged Dogyeom Battler runtime-routing facts.

## Exclusions

- No change to combat rules, AI information limits, route values, UI semantics, save behavior, asset routing, or visual assets.
- No Windows visible, Android, device, accessibility-user, player, 15-opponent, final-presentation, or release-performance PASS claim.

## Acceptance

1. The configured default main scene loads `VerticalSliceShell` and its `start_new_run` boundary.
2. The app title describes the first-five-duel Vertical Slice rather than an isolated combat POC.
3. Focused Godot shell/bridge tests and the affected governance tests pass.
4. The one-time protected-change lifecycle is followed and the approval is archived immediately after merge.
