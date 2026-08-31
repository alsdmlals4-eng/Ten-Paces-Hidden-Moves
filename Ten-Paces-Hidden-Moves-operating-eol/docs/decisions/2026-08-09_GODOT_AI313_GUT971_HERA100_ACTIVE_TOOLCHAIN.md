# Godot AI 3.1.3 + GUT 9.7.1 + Hera 1.0.0 Active Toolchain Reconciliation

- Decision ID: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`
- Status: `CURRENT_APPROVED_RECONCILIATION_EXACT_471_GUT_JUNIT_AND_HERA_LOCAL_ACCEPTED`
- Approval source: user correction `헤라랑 gut 써야지 왜 없애` followed by continuous-work execution and user-provided local acceptance evidence
- Fresh Base main for this acceptance sync: `2a6ced23f6d6de1fb6e0a281c7138beb03f1a13b`
- Local Hera acceptance source main: `ce81eeba1af293061c17e4547fdd2364ec33f8c9`
- Product/runtime feature change: `NONE`

## Decision

Keep and canonically adopt the active Godot toolchain:

```yaml
godot:
  family: 4.7.x
  local_acceptance_target: 4.7.1
godot_ai_higodot:
  version: 3.1.3
  role: SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY
gut:
  version: 9.7.1
  role: DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY
  persistent_authoring: false
hera:
  addon_version: 1.0.0
  role: LIVE_QA_AND_OBSERVABILITY_ONLY
  persistent_mutation: FORBIDDEN
```

GUT and Hera remain enabled. The earlier rollback proposal that disabled GUT/Hera remains `SUPERSEDED_DO_NOT_EXECUTE`.

## Approved protected `project.godot` state

Keep these autoloads:

- `TenManualProductValidationBootstrap`
- `HeraGameInspector`
- `_mcp_game_helper`

Keep these editor plugins enabled:

- `res://addons/godot_ai/plugin.cfg`
- `res://addons/gut/plugin.cfg`
- `res://addons/hera_agent_godot/plugin.cfg`

HiGodot remains the sole persistent Godot authoring authority. GUT tests and Hera live QA do not gain persistent authoring authority.

## Local HiGodot L0 evidence

The user previously observed the correct Ten Paces project, the three expected autoloads, and Godot AI/GUT/Hera enabled in explicit HiGodot session `ten-paces-higodot-recovery@b62b`. No persistent write occurred during that observation.

```yaml
local_higodot_l0: PASS_OBSERVED_EXISTING_STATE
persistent_write_during_observation: NONE
```

## Exact Godot 4.7.1 + GUT/JUnit local acceptance

Canonical evidence record:

`docs/planning-data/local_godot_471_gut_junit_acceptance_20260810.json`

The user reran the hardened collector from a fresh isolated checkout. Accepted facts remain:

```yaml
godot_version: 4.7.1.stable.official.a13da4feb
godot_import_parse: PASS
gut_version: 9.7.1
gut_status: PASS
gut_test_execution_status: PASS
gut_junit_status: PASS
canonical_gut_xml_exists: true
evidence_gut_xml_exists: true
final_content_clean: true
final_porcelain_clean: false
stat_only_status_possible: true
```

The porcelain/stat-only `.import` behavior was reconciled by PR #129; acceptance is based on actual tracked/staged/untracked content cleanliness.

```yaml
local_godot_import_acceptance_471: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_gut_acceptance_471: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_gut_test_execution_471: PASS
local_gut_junit_471: PASS
local_gut_evidence_xml_present: PASS
local_godot_gut_core_windows_gate: PASS
```

## 2026-08-10 Hera v1.0.0 local live-QA acceptance

Canonical evidence record:

`docs/planning-data/local_hera_v1_live_qa_acceptance_20260810.json`

The user supplied `UPLOAD_THIS_HERA_V1_RECOVERY_EVIDENCE.zip`. The archive contains the final recovery JSON plus captured status/smoke/wrong-token outputs. The evidence establishes:

```yaml
checkout: C:/Users/user/AppData/Local/Temp/ten-paces-hera-v1-20260810-005834/project
head: ce81eeba1af293061c17e4547fdd2364ec33f8c9
origin_main: ce81eeba1af293061c17e4547fdd2364ec33f8c9
godot_version: 4.7.1.stable.official.a13da4feb
hera_windows_asset: hera-windows-amd64.zip
hera_windows_sha256: 9ae181741c2e8a3f57bbb2a2e4c61ac2c9c7c844fad21c88ae3890c55a5cc66b
hera_cli_version: v1.0.0
hera_addon_version: 1.0.0
localhost_only: true
shared_token: ENFORCED_REDACTED
normal_status_exit: 0
status_exact_target: true
wrong_token_exit: 1
wrong_token_result: UNAUTHORIZED_EXPECTED
smoke_skip_game_exit: 0
smoke_result: PASS_3_OF_3_STATUS_DIAGNOSTICS_SCENE
pre_content_clean: true
post_content_clean: true
hera_phase_source_delta: HERA_SOURCE_DELTA_NONE
verdict: PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE
```

The wrong-token rejection is positive security evidence, not a Hera failure. The token value itself is never recorded; canonical evidence stores only `[REDACTED]` and the enforcement result.

The post-run porcelain output still showed Windows/Godot stat-only `M` markers for tracked `.import` files and `project.godot`. This does not lower acceptance because the recovery evidence separately reports actual pre/post tracked/staged/untracked content clean, and the source-delta verdict is `HERA_SOURCE_DELTA_NONE`.

Therefore the Hera claim ceiling is promoted to:

```yaml
hera_cli_pair: PASS_EXACT_V1_0_0_USER_LOCAL_EVIDENCE
exact_local_cli_version: v1.0.0
hera_status: PASS_EXACT_TARGET
hera_shared_token: PASS_ENFORCED_REDACTED
hera_smoke_skip_game: PASS
hera_phase_source_delta: HERA_SOURCE_DELTA_NONE
hera_live_qa_gate: PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE
hera_persistent_mutation: FORBIDDEN
```

This acceptance grants Hera **live QA and observability only**. It does not authorize persistent Scene/Node/Script/Resource/Theme/project-setting mutation. HiGodot remains the sole persistent Godot authoring authority.

## Historical collector lineage

The first isolated collector run used Godot `4.7.stable`, not exact 4.7.1, and remains historical only. PR #127 fixed exact version/native-exit/Git postcheck behavior; PR #129 separated stat-only porcelain touches from real content changes; PR #130 required GUT JUnit evidence. Those historical defects do not reduce the later exact 4.7.1/GUT/Hera evidence.

## Protected change governance

The active-toolchain one-time protected-state approval remains historical and archived. No active approval manifest is reintroduced by this acceptance sync. This work does not change `project.godot`, addon source, Scene, Resource, gameplay, combat data, or product assets.

## Entry Gate effect

The exact Godot 4.7.1, GUT/JUnit, and Hera local live-QA gates are now closed. Product implementation still remains blocked by independent gates:

- tooling export exclusion requires HiGodot L2 authoring followed by L1/export regression validation;
- Android/device validation remains unverified;
- human validation remains not run;
- any other current product-specific Work Entry Completeness Gate blockers remain authoritative.

```yaml
exact_godot_471_local_gate: PASS
local_gut_971_junit_gate: PASS
hera_live_qa_gate: PASS_HERA_V1_0_0_EXACT_PAIR_LIVE_QA_SOURCE_DELTA_NONE
tooling_export_exclusion: BLOCKED_REQUIRES_HIGODOT_L2_AUTHORING_THEN_L1_VALIDATION
local_android_device: BLOCKED_UNVERIFIED
human_validation: BLOCKED_NOT_RUN
full_local_platform_acceptance: BLOCKED_REMAINING_GATES
product_implementation_authorized_by_this_decision: false
```
