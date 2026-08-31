# PR #123 Active Toolchain Protected Change Approval Record

```yaml
record_type: MERGED_PROTECTED_CHANGE_APPROVAL_EVIDENCE
status: HISTORICAL_MERGED
product_pr: 123
product_head: 6029bf5e8f7801ba894552ad61dd0193684626a9
product_merge_commit: 00a5502f1e40db77dce9495a57292b77bf4e3a5a
protected_base_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90
promoted_protected_baseline: 00a5502f1e40db77dce9495a57292b77bf4e3a5a
approved_paths: [project.godot]
decision_ids: [TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01]
approval_source: USER_EXPLICIT_KEEP_GUT_HERA_AND_CONTINUOUS_WORK_2026-08-09
external_approval: GITHUB_PR_LABEL_APPROVED_PROTECTED_CHANGE
```

This is the historical audit record for the one-time protected approval used by PR #123.

The approved state keeps Godot AI / HiGodot 3.1.3, GUT 9.7.1, and Hera Agent Godot 1.0.0 enabled under the authority split defined by `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01`.

The active `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json` is removed after merge so this approval cannot authorize unrelated future PRs. The project adapter protected baseline is promoted to the merged PR #123 commit so future PRs compare against the approved active-toolchain state without inheriting a reusable approval manifest.

This record does not claim Hera CLI pairing, `hera status`, `hera smoke --skip-game`, local clean-checkout GUT, export exclusion, Android/device, or human validation PASS.
