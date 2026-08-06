# Godot Live-Editor Pilot Adoption

## Status

```yaml
adoption_mode: TEMPORARY_COPY_ONLY
legacy_source_policy: LEGACY_GODOT_AI_SOURCE_PRESERVED
legacy_workspace_policy: LEGACY_DISABLED_IN_DISPOSABLE_COPY_ONLY
mutation_authority_policy: DUAL_MUTATION_AUTHORITY_FORBIDDEN
main_scene_policy: MAIN_SCENE_READ_ONLY
mutation_policy: SCRATCH_SCENE_MUTATION_ONLY
source_integrity: SOURCE_TREE_UNCHANGED
base_pilot_commit: 2b595570bd237174b2b962a1eb54588b5ecc508d
evidence_bundle: SELF_CONTAINED_EVIDENCE_BUNDLE
PRODUCTION_ADAPTER_READY: NOT_READY
```

This repository adopts the immutable Base C0.2 Pilot commit `2b595570bd237174b2b962a1eb54588b5ecc508d` through four adoption files only.

## Legacy coexistence boundary

`LEGACY_GODOT_AI_SOURCE_PRESERVED` means the source repository keeps `res://addons/godot_ai/plugin.cfg`, the Godot AI addon bytes, and `_mcp_game_helper` unchanged. This PR does not uninstall or modify that existing workflow.

`LEGACY_DISABLED_IN_DISPOSABLE_COPY_ONLY` means the Base runner copies the project to a temporary workspace and removes only the declared plugin and Autoload entries from the copied `project.godot` before enabling the Base Pilot. The source `project.godot` remains byte-identical.

`DUAL_MUTATION_AUTHORITY_FORBIDDEN` means Godot AI and the Base transaction adapter are never active together in the Pilot workspace. An operation performed by the legacy addon does not count as Base v2 completion evidence.

## What the Pilot does

The workflow inventories the immutable source, creates a disposable full-project copy, disables the declared legacy Plugin and Autoload only in that copy, then performs a bounded Godot Editor import and parse. It runs `res://tests/verify_step0.gd` in the same prepared workspace so clean-checkout global classes are available without activating legacy mutation authority.

Only after import and the project behavior check pass does the runner materialize the Base Pilot addon. It opens `res://scenes/combat/combat_board_preview.tscn` only under `MAIN_SCENE_READ_ONLY`.

Rename, Editor Undo, save, ledger recording, and physical SHA-256 verification occur only in the runner-owned `res://.godot-live-editor-pilot/scratch.tscn` under `SCRATCH_SCENE_MUTATION_ONLY`.

The source Git-tracked bytes are inventoried before and after execution. Any source change violates `SOURCE_TREE_UNCHANGED` and fails the Pilot.

## Evidence bundle

`SELF_CONTAINED_EVIDENCE_BUNDLE` requires the downloaded artifact to contain:

```text
project-pilot-evidence.json
runtime-result.json
scratch.tscn
```

The runtime result and saved scratch Scene are physically rehashed after download. Their recomputed SHA-256 values must equal the values recorded in the evidence JSON.

## Protected product boundary

The Pilot does not change combat rules, routes, rewards, save behavior, UI, data, assets, planning Decisions, Google Sheets, `project.godot`, product Scenes, Resources, or GDScript. The real combat Scene is never a mutation target.

The Pilot does not install a permanent addon, open a network listener, create an MCP server, or provide arbitrary property, script, shell, or project mutation.

## Program B and Program C exclusions

Program B authenticated local STDIO MCP transport is not implemented. Program C opt-in runtime debugger is not implemented. Both require separate design, approval, TDD, adversarial review, and merge gates.

No physical-input, accessibility, performance, Windows production-operation, or human-editor-usability PASS is claimed. `PRODUCTION_ADAPTER_READY: NOT_READY` remains authoritative.

## Removal

Rollback is one revert of the four adoption files:

```text
.godot-live-editor/project-pilot.json
docs/GODOT_LIVE_EDITOR_ADOPTION.md
tests/test_godot_live_editor_adoption.py
.github/workflows/validate-godot-live-editor-pilot.yml
```

No product file must be edited to remove this Pilot.
