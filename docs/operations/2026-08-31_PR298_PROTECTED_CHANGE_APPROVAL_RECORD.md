# PR #298 일회성 보호 변경 승인 아카이브

~~~yaml
record_role: IMMUTABLE_ARCHIVE_FOR_ONE_TIME_PROTECTED_CHANGE_APPROVAL
source_manifest: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
source_manifest_sha256: 5B63D32E6DBADE50B15B2B52D5017D324B0A545948EF328BAD556855F49E75D5
protected_base_commit: 3575e0405001514b7b3bdfb5b1c23f9caa34eca0
merged_main_commit: 6663e6fc95feee2659d5325245203fa61a3398b7
merged_pull_request: 298
decisions:
  - TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01
  - TEN-DEC-20260831-FRONTAL-DUEL-PRESENTATION-AND-ILLUSTRATED-CARD-POLICY-01
  - TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01
approval_source: USER_EXPLICIT_FINAL_LOCK_ILLUSTRATION_TITLE_LOGO_ATTACK_CLASH_VFX_AND_IN_SCOPE_RECOVERY_APPROVAL_2026-08-31
approval_time: 2026-08-31T00:00:00+09:00
external_approval: GITHUB_PR_298_MERGED
archive_intent: REMOVE_ACTIVE_MANIFEST_AND_PROMOTE_PROTECTED_BASELINE_TO_MERGED_MAIN
~~~

PR #298에서만 유효했던 active manifest를 이 immutable record로 보존한다. 이 문서는 이후의 보호 경로 변경을 승인하지 않으며, 새 연출 패키지는 현재 `origin/main` 기준의 새 승인으로만 진행한다.

## 당시 승인된 정확한 범위

- user-final-locked 정면 결투 배경·인물 배치·카드 일러스트·제목 로고 및 평타/합 피드백의 복구
- 해당 consumer·회귀 검사·필수 import metadata·실행 증거

## 범위와 증거 경계

PR #298의 승인에는 전투 규칙, 10칸 논리, 3/3/4, AI 비공개 정보 경계, save schema, Android 런타임, Human UX, release 권한이 포함되지 않았다. 이 cleanup은 active manifest를 제거하고 `skills/PROJECT_BASE_ADAPTER.json`의 protected baseline을 정확한 병합 후 main commit으로 승격할 뿐이며, 그 증거 상태를 변경하지 않는다.
