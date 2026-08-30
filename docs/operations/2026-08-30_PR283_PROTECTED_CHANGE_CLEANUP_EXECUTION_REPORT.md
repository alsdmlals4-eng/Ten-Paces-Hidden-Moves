# PR #283 보호 변경 승인 정리 실행 보고

```yaml
report_id: TEN-OPS-20260830-PR283-PROTECTED-CHANGE-CLEANUP-01
work_mode: REVIEW_POSTMERGE_CLEANUP
baseline_main: 944cd8194152b3d2e31647b25dacd1bad90b7876
scope: REMOVE_ONE_TIME_ACTIVE_MANIFEST_ARCHIVE_APPROVAL_AND_PROMOTE_PROTECTED_BASELINE
source_pr: 283
source_decision: TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01
status: LOCAL_VALIDATION_PASS_AWAITING_PR_CI_AND_POSTMERGE_READBACK
current_source_relevance_check: NOT_APPLICABLE_NO_EXTERNAL_PRODUCT_OR_POLICY_DECISION
```

## 작업 전 문제

PR #283이 remote CI 전체 통과 후 병합됐지만, 해당 PR 전용 active protected-change approval manifest가 `main`에 남아 있었다. 이 파일을 유지하면 종료된 정책 복구 범위를 이후 보호 경로 작업이 재사용할 위험이 있고, lifecycle validator는 carry-over를 fail-closed로 거부한다.

## 채택한 정리 구조

1. merged main의 manifest raw SHA-256와 정확한 승인 경로를 immutable archive에 보존한다.
2. active manifest를 제거한다.
3. canonical adapter의 protected baseline을 cleanup PR의 exact base인 `944cd8194152b3d2e31647b25dacd1bad90b7876`로 승격하고 Base generator로 파생 뷰를 재생성한다.

## RED 관찰과 증거 경계

정리 전 `python tools/check_one_time_protected_change_lifecycle.py --project-root . --base-sha 944cd8194152b3d2e31647b25dacd1bad90b7876`는 active manifest가 PR base에서 carry되었다고 의도대로 실패했다. 이 정리는 runtime behavior, combat rule, AI, save, asset bytes를 바꾸지 않는다. Windows-visible, Human, accessibility-user, Android device, release performance 및 balance PASS는 `NOT_RUN`이다.

## 다섯 차례 적대 검토 계획

1. **권위와 범위:** exact merged `origin/main`, PR #283, source manifest SHA와 사용자 승인 범위를 대조한다.
2. **수명주기:** cleanup 전 carry-manifest RED와 archive·active-delete·baseline-promotion GREEN을 비교한다.
3. **정본과 파생물:** canonical adapter의 한 기준점과 Base-generated adapter views/dashboard hash를 readback한다.
4. **consumer:** protected product path가 이 cleanup diff에 전혀 없는지, current decision/result owner가 원래 recovery evidence를 보존하는지 검사한다.
5. **배포 위생:** Base contract, generated artifact, canonical checks, whitespace, remote CI, merge와 post-merge `origin/main` readback으로 종료한다.

`CLEAN_REVIEW_EXIT`는 local must-fix 0, remote CI, safe merge, exact main readback이 모두 끝난 뒤에만 기록한다.

## 실제 local 검증

| 검증 | 결과 | 근거와 한계 |
|---|---|---|
| cleanup 전 lifecycle | EXPECTED_RED | `check_one_time_protected_change_lifecycle.py`가 PR base carry-over active manifest를 fail-closed로 거부했다. |
| Base generated artifact | PASS | canonical adapter baseline을 `944cd8194152b3d2e31647b25dacd1bad90b7876`로 올린 뒤 generator `--check`가 일치했다. |
| Base operating contract | PASS | project-local adapter와 adopted Base contract validator가 exact protected baseline으로 통과했다. |
| lifecycle cleanup contract | PENDING_COMMIT_READBACK | lifecycle 검사기는 committed `HEAD` diff를 판정하므로, archive/addition·active delete·baseline promotion을 commit한 뒤 재실행한다. |
| focused governance regressions | PASS | protected-change lifecycle/adapter/adoption/governance 대상 Python tests 27개가 통과했다. |
| protected product consumer | PASS | 이 cleanup diff에는 `src/`, `data/`, `scenes/`, `assets/`, `addons/`, `project.godot` 변경이 없다. |
| Godot visible/Human/Android/release | NOT_RUN | 문서·운영 lifecycle cleanup은 이 증거들을 생성하거나 대체하지 않는다. |

### Commit readback 결과

`9296f1fb` commit 뒤 `check_one_time_protected_change_lifecycle.py --base-sha 944cd8194152b3d2e31647b25dacd1bad90b7876`는 PASS했다. 같은 committed tree에서 Base operating contract, Base generated artifact `--check`, canonical reference freshness, project operating system 및 archive governance도 모두 PASS했다. 전체 Python unit suite는 `421 tests / 25.150s / OK`였다. `944cd819..HEAD` 경로 목록에는 product-protected 경로가 없고 whitespace error도 없었다.

## 다섯 차례 적대 검토 결과

1. **권위와 범위 — PASS:** exact `origin/main` 병합 commit과 archive의 source SHA·한정 경로를 대조했고, 새 protected-product 권한이 생기지 않음을 확인했다.
2. **수명주기 — PASS (commit readback 대기):** active manifest는 삭제하고 immutable record를 추가했으며 canonical protected baseline은 cleanup base로 올렸다.
3. **정본과 파생물 — PASS:** Base generator가 adapter hash를 다시 계산해 four generated views를 동기화했다.
4. **consumer — PASS:** 보호된 게임 경로와 combat/AI/save/asset consumer를 이 cleanup에서 건드리지 않았다.
5. **배포 위생 — PASS (remote 대기):** focused tests, adapter validation, generator check 및 whitespace check를 local에서 통과했다. PR CI, safe merge, post-merge remote readback만 남았다.
