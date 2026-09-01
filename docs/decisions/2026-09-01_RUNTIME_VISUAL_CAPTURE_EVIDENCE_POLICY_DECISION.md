# TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01

## Decision

Every design or visual task that changes a player-visible runtime surface must leave a compact, repository-controlled screenshot record. The record pairs the runtime PNG with its exact product source commit, producer run, scene, visible state, entry route, consumers, diagnostics, SHA-256, and evidence ceiling so later review can see what the game actually rendered.

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

Each new capture must include:

- `capture_id`, work item, exact committed `source_commit`, and SHA-256 of the copied PNG.
- a `TEN_RUNTIME_VISUAL_CAPTURE_PRODUCER_RECEIPT` with a successful producer status, exact run ID, source commit, run timestamps, artifact-relative path, artifact SHA-256, byte count, and file modification identity.
- `res://` scene, capture state, normal entry route, and all relevant repository consumer paths.
- image dimensions/byte count, diagnostic error/warning counts, and source-delta status when a live-QA tool was used.
- explicit `MACHINE_RUNTIME_CAPTURE` evidence level plus `NOT_RUN` Human usability, Android device, accessibility-user, and release-performance ceilings.

Temporary tool output such as an AppData HERA screenshot is acquisition input only. It becomes reviewable repository evidence only after the registrar validates the current producer receipt, copies the PNG, hashes it, and records it in this manifest. The registrar never deletes a shared temporary source and never adds it to the game's runtime asset catalog.

### Fresh producer-run gate

`PRIOR_ARTIFACT_EXISTENCE_IS_NOT_FRESH_EVIDENCE`

`PRODUCER_RECEIPT_REQUIRED`

A PNG already existing at a familiar path is not evidence that the current run produced it. Before the capture command or live-QA action, the caller establishes a unique bounded run identity. The producer receipt is written only after that run finishes and identifies the exact output that run observed.

The registrar fails closed before copying or mutating the manifest when any of the following is true:

- the producer receipt is missing, malformed, or not `PASS`;
- the caller run ID or source commit differs from the receipt;
- the receipt artifact path does not resolve to the supplied source image;
- artifact SHA-256, byte count, or modification identity differs;
- the image predates the producer run or is timestamped later than producer completion beyond the bounded filesystem-clock tolerance.

The receipt's absolute local path is not stored in the repository manifest. Only its content hash and bounded producer/run fields are retained. Existing approved golden/baseline files and the temporary source image are never deleted by rejection. Historical captures registered before this correction remain historical machine-capture records; they are not retroactively promoted to producer-bound freshness evidence.

`PRODUCER_RECEIPT_CONSISTENCY_IS_NOT_PRODUCER_AUTHENTICITY`: this is a deterministic local evidence-coherence gate, not a cryptographic attestation system. A caller able to fabricate the file and receipt can still fabricate matching local evidence. Human/device/release approval and independent runtime observation remain separate.

## Tool and authority boundaries

- HERA remains `LIVE_QA_AND_OBSERVABILITY_ONLY`. A state-changing diagnostic call is not the primary normal-route acceptance capture; restart or normal entry must be observed again.
- `tools/collect_godot_live_evidence.ps1` remains the broader read-only environment and source-delta collector. This policy supplements it with a captured visual artifact; it does not replace the collector.
- A producer-bound screenshot proves only that the stated artifact, receipt, run identity, and source identity were mutually consistent when registered. It does **not** prove Human comprehension, accessibility-user success, Windows physical-input usability, Android-device behavior, release performance, asset rights clearance, producer authenticity, or user final approval.
- Existing assets remain governed by their asset manifest/provenance and user-lock rules. A capture cannot promote a candidate asset by itself.

## Future reusable tools, modules, and skills

For a needed helper, module, or Skill, the project uses `REUSE → ADAPT → BUILD_NEW` after checking the existing project implementation, current Base reuse registry, and direct consumer evidence. Project-specific work remains local unless it has a stable input/output boundary, real repeated consumers, validation evidence, and lower total cost than adapting the owner already in Base.

Potentially reusable lessons are first submitted through the Base Change Proposal lifecycle. They do not modify active Base Skills until the proposal has independent review and an approved implementation scope. This policy's Base proposal is therefore evidence-driven and does not claim immediate Base-wide adoption from one project capture.

## Verification and rollback

The registrar rejects non-PNG input, unsafe paths, malformed IDs/source commits, missing or failed producer receipts, run/source/artifact identity mismatch, stale artifacts, duplicate IDs, missing metadata, and unreasoned third captures. Its test contract verifies source/receipt/copy hash equality, run and timestamp binding, dimensions, evidence ceilings, rejection behavior, and preservation of source and approved baseline files.

Rollback removes this correction's producer-receipt requirement, focused tests, CI route, and execution report as one reviewed change. It does not delete production assets, historical visual decisions, registered capture files, approved baselines, or shared temporary capture locations.
