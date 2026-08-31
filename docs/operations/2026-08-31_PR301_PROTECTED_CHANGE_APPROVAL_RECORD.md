# PR 301 보호 변경 승인 Archive Record

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 301
implementation_pr_url: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/pull/301
implementation_merge_commit: 8d0f401f42431e78f78f26067f3dfc0309ddda9e
implementation_base_commit: b0b676450fe0a097bcccb38de51912b523dcd2ec
decision_ids:
  - TEN-DEC-20260831-FRONTAL-DUEL-PRESENTATION-AND-ILLUSTRATED-CARD-POLICY-01
approved_protected_paths:
  - src/combat/combat_board_preview.gd
approval_manifest_path: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
approval_manifest_sha256: 5B556EC5B6E8870030354A439E6F41A6BA01FA1CE68FBF37FBB5F4410764B4F9
approval_lifecycle: ARCHIVE_RECORD_RETAINED_ACTIVE_MANIFEST_REMOVED_BY_THIS_CLEANUP_COMMIT
scope: PUBLIC_RESOLVED_EVENT_WINDUP_IMPACT_SETTLE_PRESENTATION_ONLY
remote_ci: PR301_ALL_REPORTED_CHECKS_PASS
evidence_ceiling: REMOTE_CI_AND_HEADLESS_GODOT_PASS_VISIBLE_TEN_PACES_HUMAN_DEVICE_ACCESSIBILITY_USER_RELEASE_NOT_RUN
```

PR #301 changed only the existing `CombatBoardPreview` presenter among protected paths. Its manifest was valid only for that implementation PR. This record preserves the approval source, exact scope, hash, base, and merge while the active manifest is removed, so later protected work cannot silently reuse it.

The next protected baseline is the PR #301 merge commit. Any later protected change requires a new explicit manifest, a fresh approval source, and its own archive lifecycle.
