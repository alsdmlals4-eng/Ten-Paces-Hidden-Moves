# GUT 9.7.1 Product Export Exclusion Closeout

- Decision ID: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`
- Decision continuation: `2026-08-07_GUT_9_7_1_RECONCILIATION_VALIDATION_DECISION.md`
- Closeout date: 2026-08-10
- Project base main before authoring publication: `771ffe7d7ebe01a119a2bf8f0d91c37ef3fb2249`
- PR #133 exact head: `f355b1f9ef9376ee28ddc9b3c8473c97389a7bd9`
- PR #133 squash-merge main: `ffe45f57606812bed38458e9ce1d3cce4c92dcb5`
- Local acceptance record: `docs/planning-data/local_gut_product_export_exclusion_acceptance_20260810.json`
- Status: `CURRENT_APPROVED_RECONCILIATION_EXPORT_BOUNDARY_VALIDATED`

## 1. Supersession scope

This file continues the existing Decision ID; it does not create a new product or tooling decision. It supersedes only the **export-pending/current-next-step statements** in these earlier current records:

- `docs/decisions/2026-08-07_GUT_9_7_1_RECONCILIATION_VALIDATION_DECISION.md`
- `docs/decisions/2026-08-08_HERA_V1_LIVE_QA_RECONCILIATION_DECISION.md`
- `docs/decisions/2026-08-09_GODOT_AI313_GUT971_HERA100_ACTIVE_TOOLCHAIN.md`

Their provenance, role boundaries, historical runs, historical local evidence, and non-export claims remain authoritative. Their former statements that the product export exclusion is not implemented or still requires HiGodot L2/L1 are historical after this closeout.

## 2. Approved persistent authoring result

Persistent export-setting authoring was performed through the configured HiGodot/Godot AI MCP path under the already approved GUT reconciliation scope.

```yaml
authoring_authority: HIGODOT_ONLY
authoring_risk_class: L2_PERSISTENT_FILE_OR_PROJECT_SETTING_WRITE
target_file: export_presets.cfg
preset: Windows Desktop Product Validation
export_filter: all_resources
include_filter: ""
exclude_filter: "addons/gut/**,tests/**,.gutconfig.json"
changed_files:
  - export_presets.cfg
```

Approved semantic exclusion targets remain exactly:

- `addons/gut/**`
- `tests/**`
- `.gutconfig.json`

No other addon family is approved by this Decision. In particular, `addons/godot_ai/**`, `addons/hera_agent_godot/**`, and any guessed HiGodot addon family were not excluded.

## 3. HiGodot L1/readback and local export regression

The user supplied the final local PowerShell/JSON evidence produced after the HiGodot L2 save and L1/readback.

```yaml
godot_version: 4.7.1.stable.official.a13da4feb
windows_export_exit_code: 0
pck_probe_exit_code: 0
windows_exe_bytes: 109212160
windows_exe_sha256: 76269a403bb832599edeee4432a5b7a7e88c018eb5c9c798dfd8289359b0ec07
pck_bytes: 14074560
pck_sha256: 3f4be2e9b5b9d417e54b2ed31fea86dd635357aad653375fcb2229202c119d7c
gut_tree_excluded: true
tests_tree_excluded: true
gutconfig_excluded: true
required_runtime_path: res://addons/godot_ai/runtime/game_helper.gd
required_runtime_present: true
final_tracked_content_delta:
  - export_presets.cfg
verdict: PASS_HIGODOT_L2_AUTHORING_AND_EXPORT_REGRESSION
```

The Windows export and PCK probe are the acceptance evidence for the export boundary. The separate local Windows/device/human product-acceptance gates are not implied by this result.

## 4. PR #133 exact-head hosted validation

PR #133 contained one file with one insertion and one deletion. The exact diff changed only `exclude_filter` in `export_presets.cfg`.

Exact-head `f355b1f9ef9376ee28ddc9b3c8473c97389a7bd9` validation included:

```yaml
pr_validation_run: 31348734212
pr_validation: PASS
active_godot_toolchain_run: 31348734236
active_godot_toolchain: PASS
ten_manual_product_gate_run: 31348734244
hosted_windows_product_export_and_run: PASS
full_validation_run: 31348734266
full_validation: PASS_SCOPE_CLASSIFICATION
review_threads_unresolved: 0
mergeable_before_merge: true
```

The Product Gate executed Godot 4.7.1 setup/templates, project import, Windows product export, exported Windows product validation, and evidence validation successfully on the exact PR head.

## 5. Current claim ceiling

```yaml
gut_reconciliation_hosted: PASS
gut_local_471_junit: PASS
hera_local_live_qa: PASS
product_export_tooling_exclusion: PASS_HIGODOT_L2_AUTHORING_AND_L1_EXPORT_REGRESSION
local_windows_product_export_regression: PASS
android_device: BLOCKED_UNVERIFIED
human_validation: BLOCKED_NOT_RUN
windows_android_adapter_implementation: BLOCKED_BY_ENTRY_GATE
product_implementation_authorized: false
production_readiness: false
```

This closeout changes no gameplay, Scene, Resource, data, save, `project.godot`, or product asset. It closes only the approved GUT/test tooling product-export boundary.

## 6. Next gate

The completed actions are removed from the current entry sequence:

- `HIGODOT_L2_AUTHOR_APPROVED_GUT_TEST_PRODUCT_EXPORT_EXCLUSION` — COMPLETE
- `HIGODOT_L1_VALIDATE_PRODUCT_EXPORT_EXCLUSION_WITH_EXPORT_REGRESSION` — COMPLETE

The next current actions are:

1. `VERIFY_LOCAL_WINDOWS_ANDROID_DEVICE_AND_HUMAN_GATES`
2. `RECHECK_WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE`

Product implementation remains fail-closed until the remaining current Work Entry Completeness Gate permits it.
