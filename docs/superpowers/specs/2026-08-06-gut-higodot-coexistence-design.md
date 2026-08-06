# GUT·HiGodot Coexistence Design

## Goal

Adopt GUT 9.7.1 for repeatable GDScript tests without creating a second Godot authoring authority, while making HiGodot 3.1.2 the explicit and actively used authoring path for future Godot implementation.

## Problem

`addons/gut/**` entered `main` without a PR, consumption path, exact adoption record, CI evidence, export boundary, or Google Sheet synchronization. At the same time, HiGodot was installed and enabled but its exact release, host verification state, safe operation levels, and relation to GUT were not recorded in project canon.

## Architecture

```text
User-approved design
→ HiGodot L0 inspection
→ HiGodot bounded L1 authoring
→ source diff and protected-path gate
→ GUT headless GDScript tests
→ Python repository/canon tests
→ exact-head CI evidence
```

### HiGodot

- Sole Scene, Node, Resource, project-setting and script authoring authority.
- Loopback-only MCP transport.
- Exact release `v3.1.2` and asset hash pin.
- L0 read, L1 reversible write, L2 protected/multi-file approval, L3 project-wide approval.
- Host registration remains `UNVERIFIED` until checked on the user’s Windows machine.
- DeepSeek has no HiGodot MCP registration or credentials.

### GUT

- GDScript unit/integration test runner and JUnit producer only.
- Exact upstream commit `aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605` from `godot_4_7`.
- Runs through `gut_cmdln.gd`; EditorPlugin remains disabled in `project.godot`.
- First consumer tests `MartialManualRegistry` load and mastery unlock boundaries.
- Excluded from product exports.

### Python

- Keeps current static, documentation, governance, protected-path and canonical contracts.
- Is not replaced by GUT.

## Data flow and ownership

GUT reads product GDScript and `res://data/**` through the normal Godot resource boundary. It writes only ignored test evidence under `build/test-results/`. It cannot modify Scene, Resource, product data or canon. HiGodot may perform approved product edits, but completion requires source diff plus GUT/Python regressions.

## Failure handling

- Missing exact version, license, consumption path or rollback: adoption fails closed.
- GUT test failure or absent JUnit: CI fails.
- HiGodot host registration unavailable: record `UNVERIFIED`; do not claim MCP operation.
- Second Godot mutation authority: reject or disable before authoring.
- Product export contains GUT test assets: release gate fails.
- Standalone Markdown `=======` underline: not a VCS conflict. A `<<<<<<<` start or `>>>>>>>` end remains a failure.

## Validation

Automated:

- Static authority contract.
- Godot 4.7.1 import/parse.
- GUT representative tests.
- JUnit evidence.
- Existing PR and full validation.

Manual and device work remains `NOT_RUN`: Windows interactive HiGodot L0/L1 operation, physical gamepad, Android export/device/lifecycle/performance, accessibility-user and human playtest.

## Rollback

Revert the adoption PR. Remove GUT consumers before removing `addons/gut`. Restore HiGodot only from exact `v3.1.2` release bytes after hash verification. No credentials or host-specific configuration are stored in the repository.
