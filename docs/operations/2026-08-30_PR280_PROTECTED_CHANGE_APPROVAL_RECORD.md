# PR #280 일회성 보호 변경 승인 아카이브

```yaml
record_role: IMMUTABLE_ARCHIVE_FOR_ONE_TIME_PROTECTED_CHANGE_APPROVAL
source_manifest: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
source_manifest_sha256: 272a6f5133e8c90cdbaf4a5593546d12bff17a52bf4f96d75d9b167afd3e710f
protected_base_commit: f1d0a33203b7e80d538481f5d23b56afc1dd5d98
merged_main_commit: 83ad48a7b4388e249e5b40e19ad25f77a817d1a2
merged_pull_request: 280
decisions:
  - TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
approval_source: USER_EXPLICIT_SCOPE_APPROVAL_2026-08-30_KST_PR280
approval_time: 2026-08-30T17:26:01+09:00
archive_intent: REMOVE_ACTIVE_MANIFEST_AND_PROMOTE_PROTECTED_BASELINE_TO_MERGED_MAIN
```

PR #280에서만 유효했던 active manifest를 이 기록으로 보존한다. 이 문서는 새 protected-path 변경을 승인하지 않으며, 미래 작업의 approval source로 재사용할 수 없다.

## 당시 승인된 정확한 경로

- `data/validation/vertical_slice_balance_instrumentation_matrix.json`
- `src/validation/vertical_slice_balance_instrumentation.gd`
- `src/validation/vertical_slice_balance_instrumentation.gd.uid`
- `src/validation/vertical_slice_balance_public_policy.gd`
- `src/validation/vertical_slice_balance_public_policy.gd.uid`
- `src/validation/vertical_slice_balance_report_runner.gd`
- `src/validation/vertical_slice_balance_report_runner.gd.uid`

## 범위와 증거 경계

승인은 첫 5전 후보, 합법 시작 무공 조합, 공개 정보만 읽는 세 플레이어 정책, 명시 AI seed를 현재 resolver에 투입하는 validation-only deterministic balance instrumentation으로 한정됐다. 전투 수치·타이밍·hidden-plan/AI privacy 경계·save schema·UI/Scene·asset·route/campaign·Android·release와 범위 밖 리팩터링은 승인하지 않았다.

PR #280은 remote CI를 통과한 뒤 `83ad48a7b4388e249e5b40e19ad25f77a817d1a2`로 병합됐다. 이 archive cleanup은 active manifest를 제거하고 `skills/PROJECT_BASE_ADAPTER.json`의 protected baseline을 해당 merged-main commit으로 승격한다. Windows-visible, Human, accessibility-user, Android device, release performance와 balance PASS는 이 archive로 승격되지 않는다.
