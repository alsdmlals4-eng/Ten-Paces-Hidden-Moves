# HiGodot `project.godot` Canon Recovery Plan

> Execution status: `DEFERRED_EXTERNAL_EXECUTOR_HIGODOT_L2_REQUIRED`
>
> This plan prepares a bounded recovery target. It does **not** authorize GitHub/raw-text mutation of `project.godot`.

## Goal

Remove the inherited `project.godot` state that conflicts with the current Hera/GUT canon, without touching the user's dirty original checkout and without deciding the separate Godot AI 3.1.3 / tracked `.gd.uid` disposition.

## Evidence / authority

- Recovery branch base: `e8c7b96d99ec327a58edfb8d7054b982cd2d62f2`
- Inherited local-state commit: `e9cee9793616694a14ea574dd215beebce241313`
- Merge that brought that lineage to remote history: `60a5aff0a155fbe13b998f7d485cf7d95effbc08`
- Trusted protected baseline commit from `skills/PROJECT_BASE_ADAPTER.json`: `a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90`
- Trusted baseline `project.godot` Git blob: `50b7986bbfb43cf50ac7d01018b4ef67536632f1`
- Current inherited `project.godot` Git blob: `74dc86274f94c01611970b6027827fc5712bced0`
- Hera authority: `TEN-DEC-20260808-HERA-V1-LIVE-QA-RECONCILIATION-01`
- GUT authority: `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`
- GUT BUILD approval: `docs/implementation/BUILD_APPROVAL_2026-08-08.md`
- Entry Gate: `docs/planning-data/current_entry_gate_20260808.json`

The current canon says Hera is present but disabled and that any Hera plugin enable is a later HiGodot L2 step after local CLI/version verification. The GUT reconciliation BUILD approval explicitly forbids `project.godot` changes. Therefore the inherited Hera autoload plus GUT/Hera editor-plugin enablement cannot be treated as completed approved adoption.

`project.godot` is persistent Godot project state. The Base HiGodot authority requires its mutation to be performed by HiGodot as L2 persistent authoring. GitHub contents APIs, raw text editing, Hera, and ad-hoc scripts are not alternate authoring authorities.

## Isolation gate

Do not use the user's existing dirty checkout for this recovery.

Use a clean separate clone/worktree that checks out:

`recovery/higodot-project-godot-baseline`

Before opening Godot/HiGodot, record:

```text
git rev-parse HEAD
git status --short
git rev-parse --abbrev-ref HEAD
```

Required precondition:

```yaml
branch: recovery/higodot-project-godot-baseline
worktree: CLEAN
original_dirty_checkout_touched: false
```

## HiGodot L0 pre-observation

Using HiGodot read-only observation, confirm:

- target project is the isolated recovery checkout;
- current Hera autoload `HeraGameInspector` is present;
- editor plugins currently include:
  - `res://addons/godot_ai/plugin.cfg`
  - `res://addons/gut/plugin.cfg`
  - `res://addons/hera_agent_godot/plugin.cfg`
- no write has occurred yet.

If the observed target differs, stop this task and record the mismatch. Do not adapt the requested mutation spec by guesswork.

## HiGodot L2 bounded authoring

Create/record a rollback checkpoint first.

Through **HiGodot only**, restore `project.godot` to the trusted protected baseline state. The intended semantic delta is exactly:

1. remove autoload `HeraGameInspector`;
2. disable/remove `res://addons/gut/plugin.cfg` from `editor_plugins/enabled`;
3. disable/remove `res://addons/hera_agent_godot/plugin.cfg` from `editor_plugins/enabled`;
4. keep `res://addons/godot_ai/plugin.cfg` enabled;
5. keep `_mcp_game_helper` and `TenManualProductValidationBootstrap` autoloads;
6. change no other project setting.

Because the protected validator is content-sensitive, final `project.godot` must match the trusted baseline file exactly, not merely be semantically similar. The expected Git blob is:

`50b7986bbfb43cf50ac7d01018b4ef67536632f1`

If normal project-setting operations leave ordering/serialization drift, use HiGodot's authorized persistent filesystem/project-setting authoring capability to make the final file exact. Do not switch to an external raw-text editor.

## Explicit non-goals

Do **not** modify, delete, upgrade, downgrade, or approve in this recovery task:

- `addons/godot_ai/plugin.cfg` (current observed 3.1.3 stays untouched here);
- any tracked `src/**/*.gd.uid` or `tests/**/*.gd.uid` file;
- `addons/gut/**`;
- `addons/hera_agent_godot/**`;
- `export_presets.cfg`;
- scenes, resources, product scripts, combat data, assets;
- the Base protected-path matcher.

Godot AI 3.1.3 and the tracked `.gd.uid` files remain a separate observed-state reconciliation finding. Absence of a current validator error is not approval.

## Post-write readback

Immediately after the HiGodot L2 write, inspect the complete tracked diff.

Required result before commit:

```yaml
tracked_changed_paths:
  - project.godot
unexpected_tracked_paths: NONE
project_godot_blob: 50b7986bbfb43cf50ac7d01018b4ef67536632f1
```

Use Git only for observation/checkpoint/review, not as the authoring mechanism:

```text
git status --short
git diff -- project.godot
git diff --name-only
git hash-object project.godot
```

If any tracked path other than `project.godot` changes, stop and inspect before commit.

## Commit / validation sequence

After exact readback:

1. commit the HiGodot-authored recovery on the recovery branch;
2. ensure worktree is clean after commit;
3. run the approved local evidence collector from that clean branch if Godot executable discovery is available;
4. do not claim local Godot/GUT/Hera PASS for any command that was not actually executed;
5. push the recovery branch;
6. open a dedicated recovery PR;
7. require exact-head workflows, Project Base Adapter, review/thread checks, and full diff review;
8. merge only if all required evidence is GREEN;
9. read back the merged `main` `project.godot` blob and protected gate;
10. then rebase/update PR #122 on the repaired main and rerun its exact-head validation.

Suggested commit message:

`fix: restore protected Godot settings to canon`

## Claim ceiling

Until the external HiGodot L2 execution and its validation are actually completed:

```yaml
recovery_plan: READY
higodot_l0: NOT_RUN
higodot_l2: NOT_RUN
project_godot_restored: NOT_RUN
local_godot_parse: NOT_RUN
local_gut: NOT_RUN
local_hera: NOT_RUN
recovery_pr: NOT_CREATED
pr122_merge: BLOCKED
product_implementation: BLOCKED_BY_ENTRY_GATE
```
