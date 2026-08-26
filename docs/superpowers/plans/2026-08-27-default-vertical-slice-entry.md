# Default Vertical Slice Entry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing first-five-duel Vertical Slice shell the default F5 launch path.

**Architecture:** Reuse the already-tested `VerticalSliceShell` scene as the application entry point. A focused Godot regression will load the configured main scene and verify its player-facing start capability, protecting the actual launch contract rather than merely checking configuration text; no combat, route, UI hierarchy, or asset routing code changes are needed.

**Tech Stack:** Godot 4.7.1, GDScript, project.godot configuration, headless Godot verification.

**Spec:** GitHub Issue #218; `docs/validation/TEN_PACES_UX_UI_VALIDATION_PACKET.md`; `docs/decisions/2026-08-20_PC_FIRST_VERTICAL_SLICE_IMPLEMENTATION_GATE_DECISION.md`.

## Global Constraints

- Preserve the 10-cell battlefield, 3/3/4 plan sequence, hidden-plan boundary, distance/clash/response/interrupt/review rules, and current `CombatBoardPreview` reuse.
- Do not generate or replace visual assets, alter routing, or claim Windows visible, Android, human, accessibility-user, physical-gamepad, 15-opponent, final presentation, or release-performance PASS.
- New or altered GDScript must retain a Korean role header on the first line.
- Keep all changes on the isolated `codex/issue-218-default-vertical-slice-entry` branch.

---

### Task 1: Protect and switch the default entry configuration

**Files:**
- Create: `tests/verify_default_vertical_slice_entry.gd`
- Modify: `project.godot:15-19`
- Create: `docs/operations/2026-08-27_ISSUE218_DEFAULT_VERTICAL_SLICE_ENTRY_EXECUTION_REPORT.md`

**Interfaces:**
- Consumes: `ProjectSettings.get_setting("application/run/main_scene")` and the configured PackedScene.
- Produces: F5 entry through `res://scenes/run/vertical_slice_shell.tscn`; user-facing title `십보강호: 첫 5전 Vertical Slice`.

- [x] **Step 1: Write the failing test**

```gdscript
# 기본 실행 진입점이 첫 5전 세로 슬라이스 Shell인지 검증한다.
extends SceneTree

func _initialize() -> void:
    var main_scene_path := str(ProjectSettings.get_setting("application/run/main_scene", ""))
    var packed := load(main_scene_path) as PackedScene
    assert(packed != null)
    var entry = packed.instantiate()
    assert(entry.has_method("start_new_run"))
    assert(entry.get_meta("technical_shell", false) == true)
    entry.free()
    quit(0)
```

- [x] **Step 2: Run the test to verify it fails**

Run: `Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_default_vertical_slice_entry.gd`

Expected: failure because `project.godot` still points at `res://scenes/combat/combat_board_preview.tscn`, which cannot begin the full run through `start_new_run`.

- [x] **Step 3: Make the minimal configuration change**

```ini
[application]
config/name="십보강호: 첫 5전 Vertical Slice"
run/main_scene="res://scenes/run/vertical_slice_shell.tscn"
```

- [x] **Step 4: Run focused regression checks**

Run:

```powershell
& $godot --headless --path . --script res://tests/verify_default_vertical_slice_entry.gd
& $godot --headless --path . --script res://tests/verify_vertical_slice_shell.gd
& $godot --headless --path . --script res://tests/verify_vertical_slice_combat_bridge.gd
```

Expected: all three print their success markers and exit 0.

- [x] **Step 5: Record the execution boundary and commit**

```powershell
git add project.godot tests/verify_default_vertical_slice_entry.gd docs/operations/2026-08-27_ISSUE218_DEFAULT_VERTICAL_SLICE_ENTRY_EXECUTION_REPORT.md docs/superpowers/plans/2026-08-27-default-vertical-slice-entry.md
git commit -m "feat: launch first five-duel vertical slice by default"
```

The execution report must record the base SHA, BUILD work mode, TDD evidence, exact Godot commands, and explicit `NOT_RUN` human/device evidence ceiling.

## Self-Review

- Spec coverage: the plan protects the default launch scene and title, preserves the existing combat bridge, and leaves every human/device gate untouched.
- Placeholder scan: no implementation step contains a deferred implementation placeholder.
- Type consistency: all production values are `String` ProjectSettings values and match the focused test constants.
