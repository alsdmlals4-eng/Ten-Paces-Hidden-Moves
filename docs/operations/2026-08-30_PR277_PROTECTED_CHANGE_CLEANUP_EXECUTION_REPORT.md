# PR #277 보호 변경 승인 정리 실행 보고

```yaml
report_id: TEN-OPS-20260830-PR277-PROTECTED-CHANGE-CLEANUP-01
work_mode: REVIEW_POSTMERGE_CLEANUP
baseline_main: f1d0a33203b7e80d538481f5d23b56afc1dd5d98
scope: REMOVE_ONE_TIME_ACTIVE_MANIFEST_ARCHIVE_APPROVAL_AND_PROMOTE_PROTECTED_BASELINE
source_pr: 277
status: LOCAL_VALIDATION_PASSED_REMOTE_PR_PENDING
current_source_relevance_check: NOT_APPLICABLE_NO_EXTERNAL_PRODUCT_OR_POLICY_DECISION
```

## 작업 전 문제

PR #277은 병합됐지만, 그 PR의 one-time protected-change approval manifest가 active 경로에 남아 있었다. 이를 계속 두면 후속 보호 경로 변경이 종료된 승인 범위를 재사용할 수 있고, lifecycle validator도 cleanup PR을 요구한다.

## 채택한 정리 구조

1. active manifest를 삭제한다.
2. 원문 SHA-256, 승인 범위, 기준 commit, merge commit을 가진 immutable archive를 남긴다.
3. protected baseline을 병합된 `main` commit으로 승격하고 Base 파생 view를 재생성한다.

## 의도한 증거 경계

이 정리는 runtime behavior, 게임 규칙, AI, save, asset bytes를 바꾸지 않는다. lifecycle RED 재현 뒤, Base 파생 산출물, lifecycle validator, Base contract validator, Python regression과 remote CI를 별도로 검증한다. Windows-visible, Human, accessibility-user, Android device, release performance 및 store/release evidence는 `NOT_RUN`이다.

## 실제 local 검증

- 변경 전 `python tools/check_one_time_protected_change_lifecycle.py --project-root . --base-sha f1d0a33203b7e80d538481f5d23b56afc1dd5d98`는 active manifest가 PR base에서 carry되었다고 의도대로 `RED`였다.
- 변경 뒤 같은 lifecycle validator는 `PASS`였다. immutable archive 추가와 adapter baseline이 PR base SHA와 정확히 같은지를 commit diff로 확인했다.
- Base `2828a74f60c1ed09546171040f4178c8848ea686`의 `check_approved_project_operating_contract.py`를 `protected-base=f1d0a33203b7e80d538481f5d23b56afc1dd5d98`, external approval 없이 실행해 `PASS`했다.
- `python -m unittest discover -s tests -p "test_*.py"`는 421 tests `PASS`였다.
- `f1d0a332…...HEAD`의 whitespace check는 `PASS`였고, diff는 dashboard / generated adapter views / active-manifest archive lifecycle 문서만 포함했다. `data/`, `src/`, `scenes/`, `assets/`, `addons/`, `project.godot`는 변경하지 않았다.

## 다섯 적대 검토 루프

1. **권위와 범위:** 병합된 PR #277의 `main` readback, active manifest 원문 SHA, 사용자 승인 출처와 runtime 미변경 범위를 대조했다.
2. **수명주기:** cleanup 전 carry-manifest `RED`를 먼저 재현하고, archive 추가·active 삭제·baseline promotion의 세 조건을 commit 단위 `PASS`로 대조했다.
3. **정본과 파생물:** canonical adapter의 한 commit 변경만 허용하고 Base generator가 만든 dashboard 및 세 skill view의 해시 갱신을 readback했다.
4. **계약 소비자:** pinned Base validator와 lifecycle/adapter Python 소비자 테스트를 실행해, 새 PR이 active approval 또는 외부 label에 의존하지 않는 것을 확인했다.
5. **배포 위생:** exact diff, whitespace, worktree cleanliness, 421 Python 회귀를 검토했다. product path / 실행중 게임 / 다른 worktree에는 변경이 없었다.

`CLEAN_REVIEW_EXIT`: local 기준의 must-fix는 0개다. remote CI와 merge/readback은 아직 별도 증거 게이트다.
