# PR #280 보호 변경 승인 정리 실행 보고

```yaml
report_id: TEN-OPS-20260830-PR280-PROTECTED-CHANGE-CLEANUP-01
work_mode: REVIEW_POSTMERGE_CLEANUP
baseline_main: 83ad48a7b4388e249e5b40e19ad25f77a817d1a2
scope: REMOVE_ONE_TIME_ACTIVE_MANIFEST_ARCHIVE_APPROVAL_AND_PROMOTE_PROTECTED_BASELINE
source_pr: 280
source_decision: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
status: LOCAL_VALIDATION_PENDING
current_source_relevance_check: NOT_APPLICABLE_NO_EXTERNAL_PRODUCT_OR_POLICY_DECISION
```

## 작업 전 문제

PR #280은 remote CI 전체 통과 후 병합됐지만, 해당 PR에만 유효한 active protected-change approval manifest가 main에 남아 있었다. 이를 남기면 뒤의 보호 경로 변경이 종료된 승인 범위를 재사용할 수 있고 lifecycle validator도 fail-closed로 거부한다.

## 채택한 정리 구조

1. 병합 commit의 manifest raw SHA-256과 정확한 일곱 경로를 immutable archive에 보존한다.
2. active manifest를 제거한다.
3. canonical adapter의 protected baseline을 이 cleanup PR의 정확한 base `83ad48a7b4388e249e5b40e19ad25f77a817d1a2`로 승격하고 Base generated views를 재생성한다.
4. current planning owner를 branch/PR 대기 상태에서 merged-main 및 cleanup-pending 상태로 교정한다.

## RED 관찰과 증거 경계

변경 전 `python tools/check_one_time_protected_change_lifecycle.py --project-root . --base-sha 83ad48a7b4388e249e5b40e19ad25f77a817d1a2`는 active manifest가 PR base에서 carry되었다고 의도대로 실패했다. 이 cleanup은 runtime behavior, combat rule, AI, save, asset bytes를 바꾸지 않는다. Windows-visible, Human, accessibility-user, Android device, release performance 및 balance PASS는 `NOT_RUN`이다.

## 검증 및 적대 검토

최종 validator, generated-artifact check, lifecycle GREEN, current-owner consumer test, exact diff 및 remote CI 결과는 변경 후 이 보고서에 기록한다. 다섯 검토 loop는 권위·수명주기·정본/파생물·consumer·배포 위생을 각각 공격하며, 실제 결과 없는 PASS를 기록하지 않는다.
