# TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01

## Decision

Every design or visual task that changes a player-visible runtime surface must leave a compact, repository-controlled screenshot record. The record pairs the runtime PNG with its exact product source commit, scene, visible state, entry route, consumers, diagnostics, SHA-256, run identity, and evidence ceiling so later review can see what the game actually rendered.

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

The canonical index is `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`; image bytes live under `docs/evidence/runtime-captures/`.

`PRIOR_ARTIFACT_EXISTENCE_IS_NOT_FRESH_EVIDENCE`: a PNG that already exists before the current run cannot be registered as proof of that run. Before launching the runtime producer, create a one-run receipt while the expected transient source path is absent:

```text
python tools/prepare_runtime_visual_capture.py \
  --project-root . \
  --source-image <expected-transient-png> \
  --freshness-receipt <temporary-receipt-json> \
  --capture-run-id TEN-RVC-RUN-YYYYMMDD-NNN \
  --source-commit <exact-project-source-sha>
```

The preparer fails closed when the source PNG or receipt already exists. It does not silently delete previous output; the task must remove or isolate stale transient output first. After preparation, run Godot/HERA/the approved producer and require that it creates the expected PNG. Then register the result:

```text
python tools/register_runtime_visual_capture.py \
  --project-root . \
  --source-image <expected-transient-png> \
  --freshness-receipt <temporary-receipt-json> \
  --capture-run-id TEN-RVC-RUN-YYYYMMDD-NNN \
  --capture-id TEN-RVC-YYYYMMDD-NNN \
  --source-commit <recorded-source-sha> \
  --expected-source-commit <trusted-caller-fresh-read-sha> \
  <existing scene/state/consumer/diagnostic arguments>
```

`--expected-source-commit` must come from the trusted caller's independent fresh read, not by copying the receipt value. The registrar rejects a missing/mismatched receipt, missing current-run PNG, project-root/path/run/commit mismatch, or a receipt nonce already consumed by another capture.

Each capture must include:

- `capture_id`, work item, exact committed `source_commit`, and SHA-256 of the copied PNG.
- `res://` scene, capture state, normal entry route, and all relevant repository consumer paths.
- image dimensions/byte count, diagnostic error/warning counts, and source-delta status when a live-QA tool was used.
- `freshness.mode = PREPARED_ABSENT_THEN_PRESENT`, run ID, receipt digest/nonce, preparation time, and trusted source-identity match.
- explicit `MACHINE_RUNTIME_CAPTURE` evidence level plus `NOT_RUN` Human usability, Android device, accessibility-user, and release-performance ceilings.

Temporary tool output such as an AppData HERA screenshot is acquisition input only. It becomes reviewable repository evidence only after the registrar verifies the one-run receipt, copies the PNG, hashes it, and records it in this manifest. The registrar never deletes a shared temporary source and never adds it to the game's runtime asset catalog.

Historical captures recorded before the freshness receipt was introduced remain historical evidence at their original ceiling; they are not retroactively presented as having passed this newer gate.

## Tool and authority boundaries

- HERA remains `LIVE_QA_AND_OBSERVABILITY_ONLY`. A state-changing diagnostic call is not the primary normal-route acceptance capture; restart or normal entry must be observed again.
- `tools/collect_godot_live_evidence.ps1` remains the broader read-only environment and source-delta collector. This policy supplements it with a captured visual artifact; it does not replace the collector.
- `PREPARED_ABSENT_THEN_PRESENT` proves that the declared source path was absent at preparation and present for the same recorded run identity. It does not prove producer authenticity, image meaning, or that the pixels came from an untampered runtime.
- A screenshot proves only the recorded machine artifact boundary. It does **not** prove Human comprehension, accessibility-user success, Windows physical-input usability, Android-device behavior, release performance, asset rights clearance, or user final approval.
- Existing assets remain governed by their asset manifest/provenance and user-lock rules. A capture cannot promote a candidate asset by itself.

## Future reusable tools, modules, and skills

For a needed helper, module, or Skill, the project uses `REUSE → ADAPT → BUILD_NEW` after checking the existing project implementation, current Base reuse registry, and direct consumer evidence. Project-specific work remains local unless it has a stable input/output boundary, real repeated consumers, validation evidence, and lower total cost than adapting the owner already in Base.

Potentially reusable lessons are first submitted through the Base Change Proposal lifecycle. They do not modify active Base Skills until the proposal has independent review and an approved implementation scope. This policy's Base proposal is therefore evidence-driven and does not claim immediate Base-wide adoption from one project capture.

## Verification and rollback

The preparer rejects pre-existing source output, reused receipt paths, malformed run IDs/source commits, and preparation races where the source appears before the receipt is safely established. The registrar rejects non-PNG input, unsafe paths, malformed IDs/source commits, duplicate IDs, missing metadata, unreasoned third captures, missing/mismatched freshness receipts, missing current-run output, trusted-source mismatch, and receipt reuse.

The focused contract runs the complete failure proof: pre-existing stale PNG rejected at preparation; prepared-but-uncreated PNG rejected at registration; normal prepare → produce → register accepted; copied hash and run/source identity recorded; one receipt cannot register two captures. These machine checks do not execute Godot or upgrade the evidence ceiling.

Rollback removes the dedicated freshness preparer and registrar changes, restores the prior policy/test contract, and removes only capture evidence introduced by the reverted work item. It does not delete production assets, historical visual decisions, or shared temporary capture locations.
