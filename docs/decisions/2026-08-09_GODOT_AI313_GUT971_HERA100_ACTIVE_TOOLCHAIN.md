# Godot AI 3.1.3 + GUT 9.7.1 + Hera 1.0.0 Active Toolchain Reconciliation

- Decision ID: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`
- Status: `CURRENT_APPROVED_RECONCILIATION`
- Approval source: user correction `헤라랑 gut 써야지 왜 없애` followed by `[연속작업] 진행해`
- Fresh Base main: `2a6ced23f6d6de1fb6e0a281c7138beb03f1a13b`
- Project main before reconciliation PR: `e8c7b96d99ec327a58edfb8d7054b982cd2d62f2`
- Product/runtime feature change: `NONE`

## Decision

Keep and canonically adopt the currently observed active Godot toolchain state:

```yaml
godot: 4.7.x
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

GUT and Hera are retained and enabled. The earlier proposal to restore `project.godot` to an old state with GUT/Hera disabled is incorrect for the user's intended toolchain and is `SUPERSEDED_DO_NOT_EXECUTE`.

## Current desired protected `project.godot` state

The desired state keeps these autoloads:

- `TenManualProductValidationBootstrap`
- `HeraGameInspector`
- `_mcp_game_helper`

The desired state keeps these editor plugins enabled:

- `res://addons/godot_ai/plugin.cfg`
- `res://addons/gut/plugin.cfg`
- `res://addons/hera_agent_godot/plugin.cfg`

This Decision reconciles governance to an already-existing desired state. This PR does not pretend to perform a new HiGodot L2 write and must not rewrite `project.godot` merely to create authoring evidence.

## Local HiGodot L0 evidence

The user opened an isolated recovery checkout and used Codex + Godot AI/HiGodot read-only operations with explicit session:

`ten-paces-higodot-recovery@b62b`

Observed project:

`C:/Users/user/AppData/Local/Temp/ten-paces-higodot-recovery/`

Observed without persistent mutation:

- Godot `4.7-stable (official)`
- current scene `res://scenes/combat/combat_board_preview.tscn`
- all three expected autoloads present
- Godot AI, GUT, Hera editor plugins enabled

Evidence state:

```yaml
local_higodot_l0: PASS_OBSERVED_EXISTING_STATE
persistent_write_during_observation: NONE
```

## Superseded fields, not erased history

This Decision supersedes only stale configuration/status fields in earlier records:

- older HiGodot/Godot AI `3.1.2` current-version references;
- `enabled_in_project_godot: false` for Hera;
- `PRESENT_DISABLED_PAIR_UNVERIFIED` as the current Hera plugin state;
- future action `HIGODOT_L2_ENABLE_HERA_PLUGIN_IF_ADOPTION_CONTINUES`;
- rollback-oriented audit/handoff text that treated GUT/Hera enablement itself as an unwanted state.

Historical Decisions remain historical evidence and are not deleted.

## Hera claim ceiling

Plugin enablement is not equivalent to live-QA adoption completion.

```yaml
hera_cli_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
exact_local_cli_version: NOT_RUN
hera_status: NOT_RUN
hera_smoke_skip_game: NOT_RUN
hera_phase_source_delta: NOT_RUN
```

Before Hera acceptance QA can be claimed, still require:

1. exact Windows CLI archive SHA/version verification;
2. full Editor restart as required for exact-pair validation;
3. localhost/shared-token verification with secret redaction;
4. `hera status` targeting the exact Ten Paces project;
5. tracked source pre-Hera snapshot;
6. `hera smoke --skip-game`;
7. tracked source post-Hera snapshot with Hera-phase delta `NONE`.

Hera never gains persistent authoring authority from this Decision.

## GUT claim ceiling

Hosted GUT 9.7.1 reconciliation evidence remains valid from its prior Decision. This Decision does not claim a new local clean-checkout GUT run:

```yaml
local_gut_clean_checkout: NOT_RUN
```

## Protected change governance

Current Project Base Adapter compares protected paths to trusted baseline:

`a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90`

The pinned validator detects `project.godot` as the protected changed path. The reconciliation PR therefore uses the existing one-time external-approval mechanism:

- `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`
- `approved_paths: [project.godot]`
- GitHub PR label `approved-protected-change`
- this same Decision ID.

The one-time approval must be archived/removed after merge so it cannot authorize unrelated future PRs.

The known Base trailing-slash matcher blind spot for nested `addons/`, `src/`, and `tests/` is not treated as approval. Nested-tool/version state is instead pinned by a dedicated reconciliation contract and regression test; Base matcher repair remains a separate shared-Base task.

## Entry Gate effect

This Decision closes only the stale "Hera plugin is disabled / must later be enabled" status conflict.

It does **not** authorize product implementation or close:

- Hera CLI/status/smoke/source-delta gates;
- GUT/export exclusion authoring and validation;
- local Windows/Android/device/human gates;
- product asset promotion;
- gameplay/card/martial-effect implementation.

```yaml
product_implementation_authorized_by_this_decision: false
```
