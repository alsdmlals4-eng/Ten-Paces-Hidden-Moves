# Godot AI 3.1.4 Active Toolchain Freshness Overlay

- Decision ID: `TEN-DEC-20260811-GODOT-AI314-ACTIVE-TOOLCHAIN-FRESHNESS-01`
- Parent toolchain Decision: `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`
- Status: `CURRENT_APPROVED_TOOLCHAIN_VERSION_FRESHNESS_OVERLAY`
- Approval/evidence source: user informed that Godot AI is updated to 3.1.4; project `main` `97ef1a4c25f59e30a095b75361e14b411651e445` contains `addons/godot_ai/plugin.cfg` version `3.1.4`; upstream official release `hi-godot/godot-ai` latest release is `v3.1.4` published 2026-08-10.
- Product/runtime gameplay change: `NONE`
- Product implementation authority: `false`

## Decision

The effective active toolchain version of Godot AI / HiGodot is updated from source version `3.1.3` to source version `3.1.4`.

This overlay changes **only the Godot AI source-version freshness layer** of the parent Decision. It does not change the established roles of GUT or Hera and does not grant product BUILD authority.

```yaml
godot:
  family: 4.7.x
  accepted_local_version: 4.7.1.stable.official.a13da4feb
godot_ai_higodot:
  source_version: 3.1.4
  previous_source_version: 3.1.3
  role: SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY
  repository_source_state: REPO_MAIN_CONFIRMED
  upstream_release_state: OFFICIAL_V3_1_4_CONFIRMED
  upstream_release_asset_sha256: 77d5bc7f8e0062f88aef08f3471cc6e4546a0d71d18813752781689ab6ce4848
  current_repo_copy_exact_release_archive_integrity: NOT_VERIFIED
  local_editor_acceptance_for_3_1_4: NOT_RUN
gut:
  version: 9.7.1
  role: DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY
hera:
  version: 1.0.0
  role: LIVE_QA_AND_OBSERVABILITY_ONLY
  persistent_mutation: FORBIDDEN
product_implementation_authorized: false
```

## Evidence ceiling

The existing Godot 4.7.1 + GUT 9.7.1 + Hera 1.0.0 local acceptance evidence remains valid for what it actually observed. It **does not become Godot AI 3.1.4 local acceptance evidence retroactively**.

Therefore:

```yaml
godot_ai_3_1_4_repo_source_version: CONFIRMED
godot_ai_3_1_4_upstream_release: CONFIRMED
godot_ai_3_1_4_local_editor_acceptance: NOT_RUN
godot_ai_3_1_4_release_archive_match_to_current_repo_copy: NOT_VERIFIED
human_validation: NOT_RUN
android_device_validation: NOT_RUN
product_implementation_authorized: false
```

This distinction is intentional: repository source freshness and local editor/runtime validation are separate evidence classes.

## Upstream benchmark / industry check

Official upstream `hi-godot/godot-ai` release `v3.1.4` lists three bounded changes: GridMap/CSG authoring tools, an Antigravity Windows launcher compatibility fix, and a startup-handshake worker-slot fix. These are tool capabilities/compatibility changes, not Ten Paces game design rules.

Project application:

- `ADOPT`: recognize the repository's actual Godot AI source version as 3.1.4.
- `ADAPT`: retain existing HiGodot/GUT/Hera authority separation.
- `DO_NOT_COPY`: do not turn new GridMap/CSG capability into a project requirement; Ten Paces does not gain 3D map requirements from the tool release.
- `TEST`: local Godot AI 3.1.4 editor acceptance remains a later toolchain validation item if/when that evidence is needed.

## Parent Decision preservation

The parent Decision remains historical authority for the accepted toolchain roles and prior local evidence. Its literal `3.1.3` statements describe the version accepted at that time and are not rewritten as if the old evidence had tested 3.1.4.

Effective current interpretation:

```text
parent roles/evidence
+ this source-version freshness overlay
= Godot AI 3.1.4 + GUT 9.7.1 + Hera 1.0.0 current toolchain contract
```

No Godot Scene/Resource/script/gameplay mutation is authorized by this overlay.
