# Active Godot Toolchain Reconciliation Design

## Decision direction

The project keeps the currently observed active toolchain instead of rolling it back to the older disabled baseline.

Target toolchain:

- Godot `4.7.x`
- Godot AI / HiGodot `3.1.3`
- GUT `9.7.1`
- Hera Agent Godot `1.0.0`

Authority boundaries remain strict:

- HiGodot is the sole persistent Godot authoring authority for Scene, Node, Resource, Script, project settings, autoload, and filesystem/project mutations.
- GUT is deterministic GDScript test authority and has no persistent authoring authority.
- Hera is `LIVE_QA_AND_OBSERVABILITY_ONLY`; persistent source/project mutation is forbidden and acceptance requires Hera-phase tracked source delta `NONE`.

## User-approved intent

The user explicitly corrected the earlier rollback direction with `헤라랑 gut 써야지 왜 없애`, then invoked `[연속작업] 진행해` to continue the same reconciliation scope.

This design therefore treats keeping GUT and Hera enabled as the approved project-tooling direction, not as an accidental state to remove.

## Fresh evidence

Remote current `main` already contains:

- `addons/godot_ai/plugin.cfg` version `3.1.3`;
- `project.godot` autoloads:
  - `TenManualProductValidationBootstrap`
  - `HeraGameInspector`
  - `_mcp_game_helper`
- `project.godot` enabled editor plugins:
  - `res://addons/godot_ai/plugin.cfg`
  - `res://addons/gut/plugin.cfg`
  - `res://addons/hera_agent_godot/plugin.cfg`.

The user also ran an isolated clean recovery checkout through Codex + Godot AI/HiGodot L0 using explicit session `ten-paces-higodot-recovery@b62b`. The L0 readback independently observed the same three autoloads and the same three enabled plugins without modifying files or project settings.

This is valid evidence of the existing enabled editor state. It is **not** evidence that Hera CLI pairing, `hera status`, `hera smoke --skip-game`, local GUT execution, Android, device, or human validation has passed.

## Canon conflict to resolve

Older canon still records:

- HiGodot/Godot AI `3.1.2` in the older test-authority decision;
- Hera `enabled_in_project_godot: false`;
- Hera adoption state `PRESENT_DISABLED_PAIR_UNVERIFIED`;
- `HIGODOT_L2_ENABLE_HERA_PLUGIN_IF_ADOPTION_CONTINUES` as an outstanding step;
- Sheet audit/history that incorrectly recommends rolling `project.godot` back to an older protected baseline.

Those status/configuration fields conflict with the approved current direction and actual L0 readback.

## New reconciliation Decision

Create one new Decision:

`TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`

It supersedes only stale tooling-state/version fields, not the historical decisions themselves.

The Decision will establish:

- Godot AI / HiGodot `3.1.3` as the current project authoring provider version;
- GUT `9.7.1` enabled and retained as deterministic test authority;
- Hera addon `1.0.0` enabled and retained as live-QA/observability-only;
- current `project.godot` three-plugin/three-autoload state as the desired protected toolchain state;
- no rollback to the old disabled protected baseline;
- no claim that Hera CLI/status/smoke has passed;
- no claim that local GUT suite has passed in the isolated recovery checkout;
- existing export-exclusion, platform, device, and human gates remain separate.

## Protected state approval

The Project Base Adapter uses a trusted protected baseline older than the currently desired `project.godot`. Its approved reconciliation path requires:

1. `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json` conforming to Base schema v1;
2. exact `protected_base_commit` equal to the adapter-selected baseline;
3. `approved_paths` exactly equal to the validator-detected protected paths;
4. at least one Decision ID;
5. external GitHub approval metadata via PR label `approved-protected-change`.

The current pinned validator detects `project.godot` as the protected path. The approval manifest therefore authorizes exactly `project.godot`, using the new Decision ID and the user's explicit active-toolchain instruction as approval provenance.

This protected approval is a governance reconciliation of an existing desired state. It does not pretend a new HiGodot L2 write occurred in this branch.

## Nested protected-path matcher blind spot

The current protected matcher may miss descendants of policy entries such as `addons/`, `src/`, and `tests/` because those entries are not expanded as descendant globs.

This design does not exploit that blind spot as approval.

Instead:

- the new toolchain contract and regression tests explicitly pin Godot AI `3.1.3`, GUT `9.7.1`, Hera `1.0.0`, and the expected `project.godot` state;
- `.gd.uid` files remain repository-tracked metadata and are not deleted or newly approved merely because the protected matcher misses them;
- repairing the shared Base matcher remains a separate Base-level task unless it becomes necessary to complete this project reconciliation safely.

## Hera adoption state after reconciliation

`HERA_ADOPTION_RECORD.json` should become truthful about the split between plugin enablement and live-QA readiness:

- `enabled_in_project_godot: true`
- enablement evidence: local HiGodot L0 observed existing enabled state
- `exact_local_cli_version`: still unverified
- adoption state: `PLUGIN_ENABLED_L0_OBSERVED_CLI_PAIR_UNVERIFIED`
- remove the already-satisfied/obsolete requirement to enable the plugin
- retain required gates:
  - exact Windows CLI archive SHA/version verification
  - full Editor restart when required for pair validation
  - localhost/shared-token check with secret redaction
  - `hera status` target-project verification
  - tracked source pre-Hera snapshot
  - `hera smoke --skip-game`
  - tracked source post-Hera delta `NONE`

Thus “enabled” does not become “Hera acceptance QA PASS”.

## Entry Gate update

Update current entry-gate state so it no longer claims Hera is disabled or needs future plugin enablement. It should state:

- Hera plugin enabled: `true`, L0 observed;
- HiGodot-authorized active state is now canonically reconciled through the new Decision/protected approval;
- Hera CLI exact local pair/status/smoke remain blocked/not run;
- GUT hosted reconciliation remains valid; local clean-checkout GUT run remains separate;
- product implementation authorization does not change merely because tooling state is reconciled.

## Collector PR #122 relationship

PR #122 is a separate bug fix for the local evidence collector.

Sequence:

1. merge this active-toolchain reconciliation only after exact-head protected gate and normal workflows pass;
2. archive/remove the one-time active protected approval after merge according to existing project precedent;
3. update/rebase PR #122 onto repaired canon;
4. rerun exact-head workflows;
5. merge #122 only if all gates are green and review/thread requirements are satisfied.

## Wrong recovery branch disposition

The earlier `recovery/higodot-project-godot-baseline` rollback plan is historical only and must remain marked `SUPERSEDED_DO_NOT_EXECUTE`.

It must never be used to disable GUT/Hera or restore the old `project.godot` blob.

## Non-goals

This reconciliation does not:

- alter combat gameplay;
- change card or martial-art effects;
- produce images;
- mutate Scene/Resource/product scripts;
- claim Hera CLI canary success;
- claim local GUT success;
- implement export exclusions;
- close Android/device/human gates;
- repair the Base protected-path matcher unless separately scoped.
