# PR #280 보호 변경 승인 정리 실행 보고

```yaml
report_id: TEN-OPS-20260830-PR280-PROTECTED-CHANGE-CLEANUP-01
work_mode: REVIEW_POSTMERGE_CLEANUP
baseline_main: 83ad48a7b4388e249e5b40e19ad25f77a817d1a2
scope: REMOVE_ONE_TIME_ACTIVE_MANIFEST_ARCHIVE_APPROVAL_AND_PROMOTE_PROTECTED_BASELINE
source_pr: 280
source_decision: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
status: LOCAL_VALIDATION_REMOTE_CI_AND_POSTMERGE_LIFECYCLE_PASSED
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

## 실제 local 검증

- 변경 전 lifecycle validator는 carried active manifest를 정확히 거부하는 `RED`를 재현했다.
- archive·manifest removal·baseline promotion commit 뒤, 같은 lifecycle validator는 `PASS`했다.
- Base `check_approved_project_operating_contract.py`는 active approval 및 external approval 없이 `protected-base=83ad48a7b4388e249e5b40e19ad25f77a817d1a2`로 `PASS`했다.
- Base `build_project_operating_artifacts.py --check`는 regenerated Dashboard 및 세 generated adapter view가 current라고 확인했다.
- `python -m unittest discover -s tests -p 'test_*.py'`는 `421 PASS`였다.
- canonical combat docs, canonical reference freshness, project operating system과 `git diff --check 83ad48a7...HEAD`도 `PASS`였다.
- diff는 current owner, generated views, archive/lifecycle, 상태 소비자 회귀만 포함하며 `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot` 변경은 없다.
- PR #281은 remote checks 전체 통과 후 `8d941de9c19ef529ae8b3e21cc810446c654c123`로 병합됐다. exact `origin/main` readback에서 active manifest 부재, archive 원문 hash, baseline `83ad48a7b4388e249e5b40e19ad25f77a817d1a2`, standard Base contract 및 lifecycle validator `PASS`를 확인했다.

## 다섯 차례 적대 검토

1. **권위와 범위:** exact merged `origin/main` readback, PR #280 merge commit, manifest blob SHA-256 및 사용자 승인 범위를 대조했다.
2. **수명주기:** cleanup 전 carry-manifest `RED`를 재현하고, archive 추가·active 삭제·adapter baseline promotion의 commit-diff `GREEN`을 확인했다.
3. **정본과 파생물:** canonical adapter의 commit 한 개만 변경하고 Base generator가 만든 Dashboard 및 세 skill view의 hash readback을 확인했다.
4. **consumer:** current planning owner의 merged-main 상태가 old PR-pending expectation과 충돌하는 것을 regression `RED`로 확인한 뒤 최소 expectation 갱신 후 `421 PASS`로 교정했다.
5. **배포 위생:** Base contract, generated artifact, canonical checks, whitespace, no-product-path diff와 worktree cleanliness를 확인했다.

`CLEAN_REVIEW_EXIT`: local must-fix는 0개이며, remote CI·merge·post-merge `origin/main` readback도 완료했다.
