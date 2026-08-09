# Godot AI 3.1.3 + GUT 9.7.1 + Hera 1.0.0 Active Toolchain Reconciliation

- Decision ID: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`
- Status: `CURRENT_APPROVED_RECONCILIATION_EXACT_471_GUT_JUNIT_LOCAL_ACCEPTED_HERA_PENDING`
- Approval source: user correction `헤라랑 gut 써야지 왜 없애` followed by `[연속작업] 진행해`
- Fresh Base main at reconciliation: `2a6ced23f6d6de1fb6e0a281c7138beb03f1a13b`
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

GUT and Hera remain enabled. The earlier rollback proposal that disabled GUT/Hera is `SUPERSEDED_DO_NOT_EXECUTE`.

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

The user used Codex + Godot AI/HiGodot read-only operations against explicit session `ten-paces-higodot-recovery@b62b` and observed the correct Ten Paces project, the three expected autoloads, and Godot AI/GUT/Hera enabled. No persistent write occurred during that observation.

```yaml
local_higodot_l0: PASS_OBSERVED_EXISTING_STATE
persistent_write_during_observation: NONE
```

## 2026-08-10 exact Godot 4.7.1 + GUT/JUnit local acceptance

The user reran the PR #130 merged collector from a fresh isolated checkout and supplied the complete PowerShell transcript. The collector implementation requires a successful GUT process and an actually-created `build/test-results/gut.xml` before setting `gut.status=PASS` and `gut.junit_status=PASS`, and copies the XML into the timestamped evidence directory.

Canonical evidence record:

`docs/planning-data/local_godot_471_gut_junit_acceptance_20260810.json`

Observed transcript facts:

```yaml
checkout: C:/Users/user/AppData/Local/Temp/ten-paces-pr130-gut-junit-20260810-002755
head: 1ecfb77eca6df0731c74f89ffe6d5dd16c6466d6
origin_main: 1ecfb77eca6df0731c74f89ffe6d5dd16c6466d6
initial_worktree: CLEAN
sync_status: LOCAL_SYNC_CURRENT
godot_executable: C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64.exe
godot_version: 4.7.1.stable.official.a13da4feb
godot_status: PASS
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
hera_cli: HERA_CLI_NOT_FOUND_OR_PATH_UNSET
collector_status: COMPLETE_WITH_BLOCKERS
core_result: PASS
```

The `porcelain_clean=false` / `stat_only_status_possible=true` combination does not lower this acceptance because the hardened collector separately checks actual tracked/staged/untracked content and reported `working_tree_clean=true`. The earlier stat-only `.import` observation was already reconciled by PR #129.

Therefore the exact-4.7.1 local claims are promoted to:

```yaml
local_godot_import_acceptance_471: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_gut_acceptance_471: PASS_USER_LOCAL_COMMAND_TRANSCRIPT
local_gut_test_execution_471: PASS
local_gut_junit_471: PASS
local_gut_evidence_xml_present: PASS
local_godot_gut_core_windows_gate: PASS
```

This promotion is limited to Godot 4.7.1 import/parse and GUT 9.7.1 deterministic test/JUnit evidence. It does not imply Hera acceptance, export-exclusion acceptance, Android/device acceptance, or human acceptance.

## Hera claim ceiling

Plugin enablement is not live-QA acceptance completion.

```yaml
hera_cli_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
exact_local_cli_version: NOT_RUN
hera_status: NOT_RUN
hera_smoke_skip_game: NOT_RUN
hera_phase_source_delta: NOT_RUN
```

Before Hera acceptance QA can be claimed, require the exact Windows CLI archive SHA/version, exact Ten Paces editor target, localhost/shared-token verification with secret redaction, tracked source pre-snapshot, `hera smoke --skip-game`, and post-snapshot delta `NONE`.

## GUT and local Windows evidence history

### Historical Godot 4.7 run — not acceptance

The first isolated collector run used Godot `4.7.stable.official.5b4e0cb0f`, not the exact 4.7.1 target. It also exposed Windows native-stderr and final Git-state defects in the collector. That run remains historical evidence only.

```yaml
local_gut_historical_execution: PASS_EXIT_0_UNDER_GODOT_4_7
local_gut_clean_checkout: HISTORICAL_PASS_GODOT_4_7_REVALIDATED_BY_EXACT_471_RUN
historical_import_claim: SUPERSEDED_BY_EXACT_471_ACCEPTANCE
```

### Collector hardening lineage

PR #127 fixed exact 4.7.1 preference, real native `$LASTEXITCODE`, post-runtime Git rechecks, fail-closed runtime sequencing, and import status blocking.

PR #129 separated actual content cleanliness from Windows/Godot stat-only `.import` touches while continuing to fail closed on real tracked, staged, or untracked content changes.

PR #130 aligned local GUT validation with the canonical hosted GUT/JUnit gate by preparing `build/test-results`, using explicit `-gconfig=res://.gutconfig.json`, requiring a newly-created `gut.xml`, exposing separate test/JUnit statuses, and copying successful XML into the evidence directory.

```yaml
collector_pr127_merge: 0f34d5543ee946a06bd2ad0bb9e86f7b4e3920c5
collector_pr129_merge: 5233ec87a5aa5ef5d64280b8abe8d26c4c16c5e2
collector_pr130_merge: 1ecfb77eca6df0731c74f89ffe6d5dd16c6466d6
collector_exact_471_gut_junit_local_rerun: PASS
```

No collector hardening PR changed `project.godot`, addon source, Scene, Resource, product script, gameplay, combat data, or product asset.

## Protected change governance

The active-toolchain protected-state approval is historical and archived. The one-time manifest is not active. The promoted protected baseline remains the PR #123 merge state recorded in `docs/operations/2026-08-09_ACTIVE_TOOLCHAIN_PROTECTED_CHANGE_APPROVAL_RECORD.md`.

## Entry Gate effect

The exact Godot 4.7.1 + GUT/JUnit local rerun gates are now closed. This Decision still does **not** open product implementation.

Remaining gates include:

- Hera exact v1.0.0 Windows CLI archive SHA/version and CLI/addon pair verification;
- Hera target/status, localhost/shared-token, smoke `--skip-game`, and Hera-phase tracked source delta `NONE`;
- tooling export exclusion HiGodot authoring/validation;
- Android/device/human validation gates;
- any other current product-specific Work Entry Completeness Gate blockers.

```yaml
exact_godot_471_local_gate: PASS
local_gut_971_junit_gate: PASS
hera_live_qa_gate: BLOCKED_UNVERIFIED
full_local_platform_acceptance: BLOCKED_REMAINING_GATES
product_implementation_authorized_by_this_decision: false
```
