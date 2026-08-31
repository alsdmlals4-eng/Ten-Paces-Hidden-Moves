# Runtime Visual Capture Policy Execution Report · 2026-09-01

## Scope and authority

| Field | Readback |
| --- | --- |
| Work mode | `BUILD → REVIEW` |
| Baseline product source | `origin/main` / `a19de4b4a9f7979030c53591875f6be6cf6385b6` |
| Project contract | `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01` |
| Policy decision | `TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01` |
| User direction | Every design/visual task must leave in-game capture image evidence; reusable improvements may be proposed to Base. |
| Project-local owners read | `AGENTS.md`, `ACTIVE_CONTEXT.md`, visual-production gate, visual handoff JSON, evidence collector contract, active project Skill registry. |
| Base compatibility read | Base `origin/main` `48dd501a10913251c4107d723bb677dae3ab9898`; Fresh Runtime Artifact Gate and `RM-TOOL-004` project-native evidence-capture guidance. |

`CURRENT_SOURCE_RELEVANCE_CHECK: NOT_APPLICABLE`. This package defines a repository-local evidence record around the existing Godot/HERA runtime. Current external research would not change its input/output contract; the authoritative current sources were the project contract, existing runtime consumer, and adopted Base evidence guidance.

## Problem → adopted structure → expected benefit

| Current problem | Why it matters | Adopted, minimal structure | Expected benefit |
| --- | --- | --- | --- |
| A visual/runtime claim could reference a transient local screenshot without a durable repository record. | A reviewer cannot reliably compare the exact source, visible scene/state, image bytes, and diagnostics later. | Versioned manifest + copied PNG + SHA-256 under `docs/evidence/`, registered through one validated project-local command. | A visual change has a compact, inspectable evidence trail without adding an in-game asset or an extra capture application. |
| Screenshots can be mistaken for broader quality approval. | A local render is not Human UX, Android, accessibility, or release-performance proof. | Per-capture `MACHINE_RUNTIME_CAPTURE` level and explicit `NOT_RUN` ceilings. | Review remains truthful about what has and has not been demonstrated. |
| Motion/VFX work can need more than one static view, while retaining every frame would bloat the repository. | The project needs useful evidence without unchecked binary growth. | Normal/readable plus one impact/result key state; a third record for a work item requires a written reason. | Stronger visual review with bounded storage and a clear cleanup rule. |

The existing `tools/collect_godot_live_evidence.ps1` remains the environment/source-delta collector. The new registrar only copies and indexes a validated PNG; it does not replace that collector or introduce a separate GUI/app.

## Implementation readback

- Decision and applicability table: `docs/decisions/2026-09-01_RUNTIME_VISUAL_CAPTURE_EVIDENCE_POLICY_DECISION.md`.
- Repository index: `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`.
- Runtime image destination: `docs/evidence/runtime-captures/`.
- Validator/registrar: `tools/register_runtime_visual_capture.py`.
- Contract coverage: `tests/test_runtime_visual_capture_contract.py`.
- Thin current-state pointers: `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`, `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`, and `docs/planning-data/current_visual_production_handoff_20260826.json`.

The registrar rejects malformed capture IDs or source commits, unsafe paths, non-PNG input, duplicate IDs, nonexistent declared consumers, missing metadata, and an unreasoned third capture for one work item. It atomically writes the JSON manifest and removes only a copied output if the manifest update itself fails. It never removes the input screenshot, game assets, or a shared capture location.

## Runtime capture evidence

| Field | Recorded value |
| --- | --- |
| Capture | `TEN-RVC-20260901-001` |
| Product source | `a19de4b4a9f7979030c53591875f6be6cf6385b6` |
| Scene / state | `res://scenes/combat/combat_board_preview.tscn` / `initial_first_bundle_action_selection` |
| Entry route | `hera_run_scene_direct_no_state_injection` |
| Consumers observed | `src/combat/combat_board_preview.gd`, `src/combat/battle_background.gd` |
| Image | `1280×800` PNG, `914,908` bytes, SHA-256 `b31741b119e8d9ddf5890e979f29901e77ee781b42e5b71610e5696c29d07f5b` |
| HERA diagnostics | `0` errors, `0` warnings |
| Source delta | `HERA_SOURCE_DELTA_NONE` |

The actual runtime node readback showed the front-facing courtyard background, both combatants on the common ground baseline, the logical tile layer hidden, and `거리 2` at the initial action-selection state. Screenshot analysis reported a nonblank `1280×800` image with no possible clipping flag. This is a machine-observed runtime result, not a claim that a person judged the composition or controls usable.

## Verification evidence

1. The new registrar contract was run before implementation and failed in four expected places because the policy, registrar, and manifest did not yet exist (`RED`).
2. After implementation, `python -m unittest tests/test_runtime_visual_capture_contract.py` completed: `4 tests, OK` (`GREEN`).
3. Review then found that a declared consumer path was not required to exist. A new missing-consumer test failed (`RED`), then passed after the registrar enforced that boundary: `5 tests, OK`.
4. Relevant regression suite completed: `python -m unittest tests/test_runtime_visual_capture_contract.py tests/test_local_godot_evidence_collector_contract.py tests/test_visual_consumer_asset_production_policy.py` → `23 tests, OK`.
5. The exact worktree was launched through its own HERA editor instance; direct scene runtime UI/tree, screenshot analysis, diagnostics, the copied PNG, and SHA-256 readback were inspected.
6. `check_approved_project_operating_contract.py --check` completed before mutation against the project's pinned Base contract.

## Five-loop adversarial review and refinement

| Loop | Attack surface | Finding | Outcome |
| --- | --- | --- | --- |
| 1 | Evidence permanence | A HERA/AppData `latest.png` alone is non-reviewable and can be overwritten. | Copy + hash + manifest record made repository evidence explicit. |
| 2 | Duplicate tooling / Base overlap | A new generic capture app would duplicate Base `RM-TOOL-004` and the existing collector. | Rejected; a narrow project registrar supplements the existing collector. |
| 3 | Record integrity and storage growth | Arbitrary files, nonexistent consumer references, path traversal, duplicate IDs, or unlimited frames could weaken review and consume space. | Added PNG/consumer/metadata/path validation and the third-capture reason gate with tests. |
| 4 | Runtime claim boundary | A direct scene run could be misreported as full player-route or Human validation. | Stored the direct/no-injection route literally and preserved all Human/device/release ceilings as `NOT_RUN`. |
| 5 | Cleanup and untouched consumers | Godot regenerated tracked/untracked import artifacts during runtime observation. | Verified 55 tracked generated files had HEAD-equivalent content hashes, normalized their index state, and removed 15 verified untracked `.import`/`.uid` artifacts. No product code, production asset, or user-owned change is retained from that regeneration. The external AppData acquisition copy is not tracked and host policy prevented this worker from deleting that binary after its repository copy was hash-verified. |

`CLEAN_EXIT`: the retained diff contains only this evidence policy, its registrar/test, the initial repository capture, authoritative pointers, and this report. The exact worktree's Godot game/editor processes were stopped; no other project's process was targeted.

## Evidence ceiling, rollback, and Base learning path

- **Established:** the listed source revision rendered the listed scene/state; the copied artifact and manifest hash match; no HERA error/warning was reported for that observation.
- **Not established:** Human visual judgement, keyboard/mouse or controller usability, accessibility-user success, Android device behavior, release performance, asset-rights clearance, or new user final approval.
- **Rollback:** revert this work item's decision, tool/test, manifest record, exact PNG, pointers, and report. Do not remove production assets or historical visual decisions.
- **Base path:** this single project demonstrates a candidate practice only. A separate Base Change Proposal will reference the existing Fresh Runtime Artifact Gate and request review of the small manifest pattern; it will not change active Base Skills until independently reviewed and scoped.
