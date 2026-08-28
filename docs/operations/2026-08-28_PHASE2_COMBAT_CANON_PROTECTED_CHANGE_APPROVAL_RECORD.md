# Phase 2 Combat Canon — Protected Change Approval Record

## Historical approval

- active manifest path: `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`
- protected base of the originating Phase 2 PR: `18eea743a941a2669222708917ba4756a6301ef9`
- merged product baseline: `6baf817b5f86baa3fe7df193832bd4f7bc4b2abf` (PR #261)
- decision: `TEN-IMP-20260828-PHASE2-COMBAT-CANON-RECONCILIATION-01`
- approved scope: public distance 2 mapping, ten basic actions, public-only AI guardrail, execution CTA, and first-five same-seed retry.

## Lifecycle closeout

The Phase 2 protected-change manifest was carried into the later repository-only GDD work with no protected runtime changes. The one-time lifecycle validator correctly rejected that carry-over. This record archives the approval after its merged PR, removes the active manifest, and advances `skills/PROJECT_BASE_ADAPTER.json#/protected_baseline/commit` to the exact PR #262 base SHA (`6baf817b5f86baa3fe7df193832bd4f7bc4b2abf`).

No protected runtime file, Scene, Resource, asset, or gameplay rule was changed by this cleanup. A future protected change requires a new scoped approval rather than reuse of this historical record.
