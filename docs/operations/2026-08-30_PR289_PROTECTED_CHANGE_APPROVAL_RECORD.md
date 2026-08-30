# PR #289 일회성 보호 변경 승인 아카이브

~~~yaml
record_role: IMMUTABLE_ARCHIVE_FOR_ONE_TIME_PROTECTED_CHANGE_APPROVAL
source_manifest: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
source_manifest_sha256: 7FDFA1ABAF5A726A820E7646129975721B867932D7B0D50AA527F06D39F07B60
protected_base_commit: 944cd8194152b3d2e31647b25dacd1bad90b7876
merged_main_commit: 7072c3b49130434d1bf213d2275004c4f91a789e
merged_pull_request: 289
decisions:
  - TEN-DEC-20260830-BALANCE-MEASUREMENT-POLICY-COVERAGE-EXTENSION-01
approval_source: USER_EXPLICIT_CONTINUATION_APPROVAL_2026-08-30_KST
approval_time: 2026-08-30T20:36:34+09:00
external_approval: GITHUB_PR_LABEL_APPROVED_PROTECTED_CHANGE
archive_intent: REMOVE_ACTIVE_MANIFEST_AND_PROMOTE_PROTECTED_BASELINE_TO_MERGED_MAIN
~~~

PR #289에서만 유효했던 active manifest를 이 immutable record로 보존한다. 이 문서는 새 보호 경로 변경을 승인하지 않으며, 이후 PR의 approval source로 재사용할 수 없다.

## 당시 승인된 정확한 경로

- `data/validation/vertical_slice_balance_instrumentation_matrix.json`
- `src/validation/vertical_slice_balance_instrumentation.gd`
- `src/validation/vertical_slice_balance_public_policy.gd`
- `src/validation/vertical_slice_balance_report_runner.gd`

## 범위와 증거 경계

승인 범위는 기존 공개 정책 세 개를 보존한 채 validation-only `public_evade_then_ultimate` 표본을 하나 추가하고, 실제 resolver matrix를 4,500 scenario와 schema 2 aggregate selection count로 확장하는 데 한정됐다. 전투 수식·card/profile 수치·AI 비공개정보 경계·Scene/UI·asset·save schema·platform·release는 변경하지 않았다.

PR #289은 remote CI 전체 통과 뒤 `7072c3b49130434d1bf213d2275004c4f91a789e`로 병합됐다. 이 cleanup은 active manifest를 제거하고 `skills/PROJECT_BASE_ADAPTER.json`의 protected baseline을 정확히 해당 merged-main commit으로 승격한다. Windows-visible, Human, accessibility-user, Android device, release performance, numerical balance PASS는 이 archive로 승격되지 않는다.
