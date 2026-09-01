# TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01

## Decision

Every design or visual task that changes a player-visible runtime surface must leave a compact, repository-controlled screenshot record. The record pairs the runtime PNG with its exact product source commit, scene, visible state, entry route, consumers, diagnostics, SHA-256, and evidence ceiling so later review can see what the game actually rendered.

The policy responds to the user's direction that **design and visual work must always retain in-game capture image evidence for easy confirmation**. It governs runtime evidence only; it does not alter the project's combat rules, asset approval lifecycle, or Human/device release gates.

## Applicability and minimum capture set

| Change type | Required capture evidence |
| --- | --- |
| New player-visible screen, component, asset, or layout | One final normal/readable runtime state. |
| Change to an existing player-visible surface | A linked existing baseline when available, then one final normal/readable runtime state. If no valid baseline exists, capture one before state and one after state. |
| Motion, attack, clash, VFX, or staged reveal | The final normal/readable state plus one key impact/result state. |
| Design/visual planning with no actual runtime consumer yet | `CAPTURE_NOT_APPLICABLE_NO_RUNTIME_CONSUMER`; it is not runtime verified and the capture remains required before implementation completion. |
| Metadata-only, text-only, or non-rendering change | `CAPTURE_NOT_APPLICABLE_NO_PLAYER_VISIBLE_RENDER_CHANGE` with its reason in the execution report. |

Use the smallest representative set. Do not retain unbounded frame-by-frame images or video by default. A third capture for the same work item requires an explicit reason in the manifest because it must cover a distinct player-visible state, such as an otherwise unavailable baseline.

## Repository record contract

The canonical index is `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`; image bytes live under `docs/evidence/runtime-captures/`. The project-local registrar is:

```text
python tools/register_runtime_visual_capture.py --help
```

Each capture must include:

- `capture_id`, work item, exact committed `source_commit`, and SHA-256 of the copied PNG.
- the exact `issue54-human-validation-launch.json` produced for that commit, its SHA-256, launch timestamp, and source-image modification time. A source image older than the launch run is rejected as stale evidence.
- `res://` scene, capture state, normal entry route, and all relevant repository consumer paths.
- image dimensions/byte count, diagnostic error/warning counts, and source-delta status when a live-QA tool was used.
- explicit `MACHINE_RUNTIME_CAPTURE` evidence level plus `NOT_RUN` Human usability, Android device, accessibility-user, and release-performance ceilings.

Temporary tool output such as an AppData HERA screenshot is acquisition input only. It becomes reviewable repository evidence only after the registrar binds it to the exact launch manifest, rejects pre-run stale files, copies it, hashes it, and records it in this manifest. The registrar never deletes a shared temporary source and never adds it to the game's runtime asset catalog. The filesystem timestamp check blocks ordinary leftover-file reuse; it is not cryptographic producer attestation and does not prove visual quality.

## Tool and authority boundaries

- HERA remains `LIVE_QA_AND_OBSERVABILITY_ONLY`. A state-changing diagnostic call is not the primary normal-route acceptance capture; restart or normal entry must be observed again.
- `tools/collect_godot_live_evidence.ps1` remains the broader read-only environment and source-delta collector. This policy supplements it with a captured visual artifact; it does not replace the collector.
- A screenshot proves that the stated runtime surface was captured at the listed source identity. It does **not** prove Human comprehension, accessibility-user success, Windows physical-input usability, Android-device behavior, release performance, asset rights clearance, or user final approval.
- Existing assets remain governed by their asset manifest/provenance and user-lock rules. A capture cannot promote a candidate asset by itself.

## Future reusable tools, modules, and skills

For a needed helper, module, or Skill, the project uses `REUSE → ADAPT → BUILD_NEW` after checking the existing project implementation, current Base reuse registry, and direct consumer evidence. Project-specific work remains local unless it has a stable input/output boundary, real repeated consumers, validation evidence, and lower total cost than adapting the owner already in Base.

Potentially reusable lessons are first submitted through the Base Change Proposal lifecycle. They do not modify active Base Skills until the proposal has independent review and an approved implementation scope. This policy's Base proposal is therefore evidence-driven and does not claim immediate Base-wide adoption from one project capture.

## Verification and rollback

The registrar rejects non-PNG input, unsafe paths, malformed IDs/source commits, duplicate IDs, missing metadata, mismatched launch identity, source images older than the launch run, and unreasoned third captures. Its test contract verifies source/copy hash equality, dimensions, launch-manifest binding, stale-artifact rejection, evidence ceilings, and rejection behavior.

Rollback removes the dedicated policy, registrar, manifest records, and only the exact capture files introduced by the reverted work item. It does not delete production assets, historical visual decisions, or shared temporary capture locations.
