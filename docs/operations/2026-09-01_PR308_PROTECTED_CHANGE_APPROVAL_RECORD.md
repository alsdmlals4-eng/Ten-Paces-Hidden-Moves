# PR 308 보호 변경 승인 Archive Record

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 308
implementation_pr_url: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/308
implementation_merge_commit: ef7a48d2769b17b4632b695191a293ee40524ac4
implementation_base_commit: 9b98bf153a8b59000ae526017e606a720fa2de27
decision_ids:
  - TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01
approved_protected_paths_exact:
  - src/combat/combat_board_preview_auto.gd
  - src/ui/action_selection/action_selection_dock.gd
  - src/ui/combat_progress_button.gd
approval_manifest_path: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
approval_manifest_sha256: 3332C34F88D85094D27AFBD7180FCB6E199F1DC1F18EC50EBECA95D1B4903B20
approval_lifecycle: ARCHIVE_RECORD_RETAINED_ACTIVE_MANIFEST_REMOVED_BY_THIS_CLEANUP_PR
remote_ci: PR308_APPROVED_PROTECTED_CHANGE_LABEL_AND_28_CURRENT_HEAD_CHECKS_SUCCESS_CONFIRMED
evidence_ceiling: PR308_MACHINE_AND_REMOTE_CI_EVIDENCE_ONLY_HUMAN_DEVICE_ACCESSIBILITY_RELEASE_NOT_RUN
```

PR #308's manifest was a single-PR authorization for the completed-bundle `행동계획 잠금` transition, the same compact CTA's `N수 실행` state, and the `ActionSelectionDock` read-only state while locked. Its first activation did not invoke the resolver; the second activation re-used the existing resolver transaction exactly once. The core 10-cell logic, `3 → 3 → 4` cadence, combat formulas, save schema, AI information boundary, observation payload, card data, asset bytes, and platform/release scope were excluded.

This immutable record preserves the exact three-path authorization and raw manifest SHA after normal PR #308 merge. It does not authorize any later protected-path change. This cleanup removes the active manifest and promotes the protected baseline to the merged main commit, so the next protected package must declare its own Decision, approval manifest, review, label, and current-head verification.
