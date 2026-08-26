# Issue #218 · Default Vertical Slice Entry Execution Report

## Execution identity

- Base SHA: `56581a01111d5109c4121029394aa02ac94765e6`
- Branch: `codex/issue-218-default-vertical-slice-entry`
- Work Mode: `BUILD`
- Skills: `ten-paces-hidden-moves-workflow-router` / `combat-implementation-handoff` / `ten-paces-verification` / `designing-vertical-slices` / `superpowers:writing-plans` / `superpowers:using-git-worktrees` / `superpowers:test-driven-development` / `superpowers:executing-plans`

## Intent and bounded result

The first-five-duel Vertical Slice already had a real `VerticalSliceShell` (`Main → Setup → Briefing → Combat → Review → Result → Route`) but F5 still opened the isolated `CombatBoardPreview` POC. This change makes the existing shell the default application entry and identifies it in the window title. It does not change combat, route, asset routing, or UI semantics.

## TDD evidence

1. Added `tests/verify_default_vertical_slice_entry.gd` before changing `project.godot`.
2. Against the pre-change entry point, the test failed because the combat POC did not expose `start_new_run` or the existing Vertical Slice shell boundary.
3. Changed only the application title and `run/main_scene` to reuse `res://scenes/run/vertical_slice_shell.tscn`.
4. Ran Godot editor import/parse before focused scripts because this fresh worktree required Godot's global class cache. This produced local `.import` refreshes only; they are not part of the intended change.

## Automated verification

Godot `4.7.1.stable.official.a13da4feb`:

- `res://tests/verify_default_vertical_slice_entry.gd` → `DEFAULT_VERTICAL_SLICE_ENTRY_VERIFY_OK`
- `res://tests/verify_vertical_slice_shell.gd` → `VERTICAL_SLICE_SHELL_VERIFY_OK`
- `res://tests/verify_vertical_slice_combat_bridge.gd` → `VERTICAL_SLICE_COMBAT_BRIDGE_VERIFY_OK`
- `Godot_v4.7.1-stable_win64_console.exe --headless --path . --quit-after 12` → exit `0` while running the configured default main scene.

Known pre-existing warning remains at `src/ui/action_timing_panel_auto.gd:228`: non-equal opposite anchors can override control size after `_ready()`. It did not fail the focused verification and is outside Issue #218 scope.

## Evidence ceiling

This is automated configuration and runtime-flow evidence only. The following remain unchanged: `Windows visible local usability`, `physical gamepad`, `Android actual device`, `accessibility user`, `Human fun/readability/immersion`, `15-opponent identifiability`, `final Visual/VFX/Audio acceptance`, and `release performance` are all `NOT_RUN` unless recorded by their corresponding actual validation session.

## Rollback

Restore the two `[application]` values in `project.godot` to the previous POC title and `res://scenes/combat/combat_board_preview.tscn`; the legacy combat scene itself remains unchanged and reusable.
