# 2026-09-02 Runtime Visual Capture Freshness Correction Report

## Scope and authority

- Tracker: `#314`
- Source main: `fba401848ff9d2a704e8f1e8e330e8f5ef67f3f3`
- Existing owner: `TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01`
- Base references: `RM-TOOL-004 · REPOSITORY_NATIVE_EVIDENCE_CAPTURE` and `FRESH_RUNTIME_ARTIFACT_GATE`
- Protected concurrent work: open PRs `#199` and `#200` remain read-only; their changed paths do not overlap this correction.

## Audited failure

The registrar already checked PNG structure, exact caller-supplied source commit format, repository consumers, copied bytes, and manifest identity. It did not prove that the supplied PNG came from the current capture run. An old PNG could therefore be registered after a current producer failure if the caller reused the old path.

This correction does not add a Base-wide capture application. It strengthens the existing project-local registrar.

## TDD receipt

### RED

The focused suite was extended before implementation. Against the source-main registrar:

- registration without a producer receipt still succeeded;
- the registrar did not understand producer receipt or run identity;
- failed-producer, stale-artifact, run/source mismatch, and post-receipt mutation cases did not reach the required fail-closed diagnostics;
- the policy did not contain the producer-run freshness contract.

Result: `10 tests / 11 failing assertions`, expected RED.

### GREEN

The candidate validates a versioned producer receipt and requires:

- `producer_status: PASS`;
- matching safe run ID and exact source commit;
- receipt-relative artifact path resolving to the supplied PNG;
- matching SHA-256, byte count, and `mtime_ns`;
- artifact modification time inside the producer start/completion window with a two-second filesystem-clock tolerance.

The registrar records only bounded receipt identity and its SHA-256, never the absolute local receipt path. Any failure happens before copied evidence or a manifest is created. The original source image and an approved baseline fixture are preserved.

Focused local result: `10 tests / PASS`. Python syntax compilation also passes. Exact-head repository CI and PR review are authoritative for integration status.

## Changed responsibility

| Path | Responsibility |
| --- | --- |
| `tools/register_runtime_visual_capture.py` | fail-closed producer receipt and artifact freshness validation |
| `tests/test_runtime_visual_capture_contract.py` | positive, stale, failed-producer, identity-mismatch, mutation, preservation regressions |
| `docs/decisions/2026-09-01_RUNTIME_VISUAL_CAPTURE_EVIDENCE_POLICY_DECISION.md` | current producer-run contract and claim ceiling |
| `.github/workflows/documentation-governance.yml` | executes the focused behavior suite on every PR |
| this report | bounded implementation and evidence receipt |

## Adversarial review lenses

1. **Owner and scope:** extend the project-local registrar; do not create a Base-wide CLI/schema/provider.
2. **False freshness:** hash alone is insufficient when an old file is reused; bind artifact time and identity to the run window.
3. **Failure closure:** failed or mismatched producer receipt must not create a copy or manifest.
4. **Preservation:** reject without deleting the source, historical captures, or approved golden/baseline artifacts.
5. **Claim ceiling:** coherent local receipt is not cryptographic producer authenticity, Human/device approval, visual quality, or release evidence.

## Unverified scope

- No live Godot or HERA screenshot was produced in the current execution environment.
- No Human UX, Windows physical-input, Android device, accessibility-user, release-performance, or final-user approval is claimed.
- Historical manifest entries are preserved and are not retroactively declared producer-bound.
- The two-second clock tolerance is a filesystem interoperability allowance, not permission to reuse materially older artifacts.

## Rollback

Revert this task's squash commit. Preserve historical manifest entries, registered image files, project assets, unrelated open PRs, and user-owned temporary capture locations.
