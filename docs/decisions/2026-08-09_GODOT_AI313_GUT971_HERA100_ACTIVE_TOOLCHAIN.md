# Godot AI 3.1.3 + GUT 9.7.1 + Hera 1.0.0 Active Toolchain Reconciliation

- Decision ID: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`
- Status: `CURRENT_APPROVED_RECONCILIATION_EXACT_471_LOCAL_RERUN_PENDING`
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

The user ran the merged collector in isolated checkout:

`C:/Users/user/AppData/Local/Temp/ten-paces-live-validation-20260809-213134`

Initial console evidence showed HEAD == origin/main, initial clean worktree, `LOCAL_SYNC_CURRENT`, GUT exit 0, Godot import recorded FAIL, and Hera CLI unresolved. PR #126 originally promoted the GUT observation to `PASS_USER_LOCAL_COMMAND_READBACK` while keeping the whole Windows gate blocked.

### 2026-08-09 uploaded-file correction — supersedes the local acceptance promotion

The subsequently uploaded fresh evidence files establish facts that the earlier console summary did not expose:

```yaml
actual_godot_executable: C:/Users/user/Downloads/Godot_v4.7-stable_win64.exe/Godot_v4.7-stable_win64.exe
actual_godot_version: 4.7.stable.official.5b4e0cb0f
project_windows_ci_target: 4.7.1
import_log: WARNING_45_OBJECTDB_INSTANCES_LEAKED_AT_EXIT_ONLY
collector_recorded_import_exit: -1
post_run_tracked_state: DIRTY_TRACKED_IMPORT_METADATA
gut_exit: 0
hera_cli: NOT_FOUND
```

Therefore the previous local acceptance promotion is corrected without erasing the historical run:

```yaml
local_gut_historical_execution: PASS_EXIT_0_UNDER_GODOT_4_7
local_gut_clean_checkout: HISTORICAL_PASS_GODOT_4_7_REVALIDATION_REQUIRED
local_gut_acceptance_471: BLOCKED_REQUIRES_EXACT_GODOT_4_7_1_RERUN
local_godot_import_acceptance_471: NOT_RUN_EXACT_GODOT_4_7_1_RERUN_REQUIRED
local_windows: BLOCKED_GODOT_4_7_1_RERUN_HERA_CLI_UNRESOLVED
```

The GUT 9.7.1 authority/adoption is not revoked. Only the **local exact-4.7.1 acceptance claim** is lowered until rerun.

## Collector PR #127 consequence

The uploaded files also proved collector defects rather than a confirmed project import failure:

- broad discovery selected Godot `4.7` before exact `4.7.1`;
- Windows PowerShell native stderr warning could be caught as a failure under `$ErrorActionPreference="Stop"` and yield artificial exit `-1`;
- runtime-generated tracked `.import` modifications were visible in final short status but `final_git.working_tree_clean` retained the initial `true` value;
- `godot.import_parse=FAIL` was omitted from `blocking_statuses`;
- GUT/Hera runtime phases could continue using only the initial clean check.

PR #127 fixed these by preferring exact Godot 4.7.1, using real native `$LASTEXITCODE`, rechecking Git state after runtime phases, blocking later mutation-capable checks after tracked changes, and including import status in blockers.

```yaml
collector_pr: 127
collector_exact_head: 38e849dcd3eab610618b798597c0b62a80e16a62
collector_merge_main: 0f34d5543ee946a06bd2ad0bb9e86f7b4e3920c5
collector_hardening: MERGED
local_hardened_rerun: NOT_RUN
```

No `project.godot`, addon, Scene, Resource, product script, gameplay, combat data, or product asset was changed by PR #127.

## Protected change governance

The active-toolchain protected-state approval is historical and archived. The one-time manifest is not active. The promoted protected baseline remains the PR #123 merge state recorded in `docs/operations/2026-08-09_ACTIVE_TOOLCHAIN_PROTECTED_CHANGE_APPROVAL_RECORD.md`.

## Entry Gate effect

This Decision keeps Godot AI 3.1.3 + GUT 9.7.1 + Hera 1.0.0 active, but does **not** open product implementation. Remaining gates include:

- exact Godot 4.7.1 hardened collector rerun;
- local GUT acceptance rerun under exact 4.7.1;
- Hera CLI/status/smoke/source-delta;
- tooling export exclusion HiGodot authoring/validation;
- local Windows/Android/device/human gates.

```yaml
product_implementation_authorized_by_this_decision: false
```
