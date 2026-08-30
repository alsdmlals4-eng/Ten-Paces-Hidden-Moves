# PR #283 일회성 보호 변경 승인 아카이브

```yaml
record_role: IMMUTABLE_ARCHIVE_FOR_ONE_TIME_PROTECTED_CHANGE_APPROVAL
source_manifest: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
source_manifest_sha256: CF43C594B9E5FCFCD33D7B7FD1536065912452E6BC625BA8D4C6A5479B44657D
protected_base_commit: 83ad48a7b4388e249e5b40e19ad25f77a817d1a2
merged_main_commit: 944cd8194152b3d2e31647b25dacd1bad90b7876
merged_pull_request: 283
decisions:
  - TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
approval_source: USER_EXPLICIT_IN_SCOPE_RECOVERY_APPROVAL_2026-08-30_KST
approval_time: 2026-08-30T18:14:46+09:00
archive_intent: REMOVE_ACTIVE_MANIFEST_AND_PROMOTE_PROTECTED_BASELINE_TO_MERGED_MAIN
```

PR #283에서만 유효했던 active manifest를 이 immutable record로 보존한다. 이 문서는 새로운 보호 경로 변경을 승인하지 않으며, 이후 PR의 approval source로 재사용할 수 없다.

## 당시 승인된 정확한 경로

- `src/validation/vertical_slice_balance_public_policy.gd`

## 범위와 증거 경계

승인 범위는 `public_approach_pressure`가 공개 공격을 현재 거리에서 쓸 수 없을 때 기존의 합법 공개 이동으로 접근하도록 복구하는 validation-only 정책 보완으로 한정됐다. 후보·기초/무공 카드 수치, shared resolver, AI 비공개 정보 경계, Scene/UI, asset, save schema, Android, release와 범위 밖 리팩터링은 승인하지 않았다.

PR #283은 remote CI 전체 통과 뒤 `944cd8194152b3d2e31647b25dacd1bad90b7876`로 병합됐다. 이 cleanup은 active manifest를 제거하고 `skills/PROJECT_BASE_ADAPTER.json`의 protected baseline을 정확히 해당 merged-main commit으로 승격한다. Windows-visible, Human, accessibility-user, Android device, release performance와 balance PASS는 이 archive로 승격되지 않는다.
