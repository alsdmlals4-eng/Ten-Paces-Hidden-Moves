# PR 305 보호 변경 승인 Archive Record

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 305
implementation_pr_url: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/305
implementation_merge_commit: ab180360da27c163b7da4dc3c17789fa29bc1a14
implementation_base_commit: 8d0f401f42431e78f78f26067f3dfc0309ddda9e
decision_ids:
  - TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01
approved_protected_paths:
  - data/cards/martial_manuals/*
  - data/cards/ultimate_cards.json
  - data/combat/*
  - scenes/ui/action_selection/linked_action_block.tscn
  - scenes/ui/combat_progress_button.tscn
  - src/combat/*
  - src/ui/action_selection/*
  - src/ui/action_timing_panel*.gd
  - src/ui/combat_progress_button.gd
  - src/validation/vertical_slice_balance_public_policy.gd
approval_manifest_path: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
approval_manifest_sha256: 3E6A8D75883F39FCB81817D3893D6F88500776DB8BFA244C35579CA3FA72C045
approval_lifecycle: ARCHIVE_RECORD_RETAINED_ACTIVE_MANIFEST_REMOVED_BY_THIS_CLEANUP_PR
remote_ci: PR305_APPROVED_PROTECTED_CHANGE_LABEL_AND_NORMAL_MERGE_CONFIRMED
evidence_ceiling: PR305_MACHINE_AND_REMOTE_CI_EVIDENCE_ONLY_HUMAN_DEVICE_ACCESSIBILITY_RELEASE_NOT_RUN
```

PR #305's manifest was a single-PR authorization for grounded frontal presentation, movement-only intent, non-movement public-opponent auto target, bounded timing blocks, compact execution control, type-only observation, and atomic ultimate reservation. The PR was normally merged at the exact commit above with the required `approved-protected-change` label.

This immutable record preserves the original authorization after removing the active manifest. It prevents a later protected change from silently inheriting PR #305's larger path set or approval source. The next protected baseline is PR #305's merge commit; this new plan-lock refinement must use its own Decision, BUILD approval, review, and exact-PR label.
