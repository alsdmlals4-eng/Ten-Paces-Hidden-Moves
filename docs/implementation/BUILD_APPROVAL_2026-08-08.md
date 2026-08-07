# GUT 9.7.1 Reconciliation Build Approval

- Gate: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`
- Parent Decision: `TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01`
- Approved on: `2026-08-08 KST`
- Approval source: user instruction `권장안대로 진행해`
- PR: `#109`
- Authority level: `TOOLING_RECONCILIATION_ONLY`

## Approved scope

The build may repair and verify only the adopted GUT 9.7.1 tooling boundary:

1. restore `addons/gut/source_code_pro.fnt` to the exact official `bitwes/Gut@v9.7.1` binary blob;
2. preserve the existing vendored GUT text resources without authoring them;
3. record only observed first-line `load_steps` metadata variances that normalize to exact upstream semantic content;
4. update the dedicated reconciliation validator, tests, workflow, Decision and planning contract;
5. run Godot 4.7.1 import, GUT CLI, JUnit, clean-tree and production-hash invariance checks on the exact PR head;
6. synchronize the same Decision ID to Google Sheets after exact-head evidence is fixed.

## Required invariants

- Official GUT source remains `bitwes/Gut`, tag `v9.7.1`, commit `aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605`.
- `source_code_pro.fnt` must be Git blob `eb6b9b859954c85bc878e93e6893d6f552b01a9e` with expected SHA-256 `404094d0aae3de496a64fca1795bed8bd60c2411a3d992551f9e8f00789b71fe`.
- Text-resource variance is allowed only when removing one optional first-line `load_steps=<integer>` token makes the file byte-equivalent as UTF-8 text to official upstream.
- Missing, extra, semantic, binary, UID, property, connection or arbitrary text differences remain fail-closed.
- Product scope hash excludes `addons/gut/**` and must remain invariant during GUT execution.
- Hera remains separately governed by `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`; no Hera files belong to this PR diff.

## Forbidden scope

- product GDScript, Scene, Resource, combat data, save schema or `project.godot` changes;
- direct rewrite of vendored GUT `.tscn` or `.tres` files;
- platform adapter implementation;
- visual or audio asset changes;
- claiming local HiGodot, local Windows, Android, human, accessibility-user or production readiness evidence;
- claiming formal GUT adoption complete before the remaining HiGodot L1 export-exclusion gate.

## Validation disclosure

- dedicated reconciliation unit tests: required
- observed-variance manifest regression: required
- official GUT tree comparison: required
- Godot 4.7.1 import/headless: required
- GUT CLI + JUnit: required
- production hash invariance: required
- normal PR/Full/Base validation: required
- local HiGodot: NOT_RUN
- local Windows: NOT_RUN
- Android: NOT_RUN
- human validation: NOT_RUN
