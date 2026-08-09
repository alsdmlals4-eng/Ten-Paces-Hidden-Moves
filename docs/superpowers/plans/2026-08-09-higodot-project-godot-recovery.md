# HiGodot `project.godot` Canon Recovery Plan — SUPERSEDED

> Execution status: `SUPERSEDED_DO_NOT_EXECUTE`
>
> **Do not disable or remove GUT or Hera based on this historical plan.**

## Why this plan was superseded

This branch was prepared under an incorrect reconciliation assumption: that the desired end state was the older protected baseline with GUT/Hera disabled.

The user subsequently clarified the intended toolchain direction and explicitly requires all three tools to remain in use:

- Godot AI / HiGodot `3.1.3` — sole persistent Godot authoring authority;
- GUT `9.7.1` — deterministic GDScript test authority;
- Hera Agent Godot `1.0.0` — live QA and observability only, with persistent authoring forbidden.

A later local HiGodot L0 observation of the isolated recovery checkout confirmed the existing active state:

- project: `C:/Users/user/AppData/Local/Temp/ten-paces-higodot-recovery/`
- session: `ten-paces-higodot-recovery@b62b`
- autoloads: `TenManualProductValidationBootstrap`, `HeraGameInspector`, `_mcp_game_helper`
- enabled editor plugins: Godot AI, GUT, Hera Agent Godot
- no persistent mutation was performed during that observation.

Therefore the correct remediation is **canon/protected-state reconciliation to the active toolchain**, not rollback to the old disabled state.

## Historical-only status

The earlier detailed rollback instructions remain available through Git history for audit purposes, but they have no execution authority.

Do not:

- remove `HeraGameInspector` because of this plan;
- disable GUT because of this plan;
- disable Hera because of this plan;
- restore `project.godot` to the older blob `50b7986bbfb43cf50ac7d01018b4ef67536632f1` because of this plan.

The active reconciliation must be performed through a new Decision and protected-change approval flow on a separate current-main branch.
