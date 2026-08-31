# GitHub Actions 예산 부재 시 수동 exact-HEAD 검증 대체 결정

- Decision ID: `TEN-DEC-20260807-ACTIONS-BUDGET-MANUAL-VALIDATION-FALLBACK-01`
- 부모 Decision:
  - `TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01`
  - `TEN-DEC-20260806-GUT-HIGODOT-TEST-AUTHORITY-01`
  - `TEN-DEC-20260807-GUT-9-7-1-RECONCILIATION-01`
- 사용자 승인 시각: 2026-08-07 06:51 KST
- 적용 대상: PR #107 한정
- 상태: `APPROVED_BOUNDED_FALLBACK_PER_HEAD_EVIDENCE_REQUIRED`

## 1. 배경

현재 GitHub Actions 예산을 사용할 수 없어 PR #107의 새 workflow를 실행할 수 없다. 이 결정은 검증을 생략하거나 workflow를 제거하기 위한 것이 아니라, v4.3의 증거 우선 원칙을 유지하면서 현재 작업을 차단 없이 검토하기 위한 한정 대체 절차다.

```yaml
reason: GITHUB_ACTIONS_BUDGET_UNAVAILABLE
validation_route: CONTENT_ADDRESSED_EXACT_HEAD_STATIC_PLUS_RUNTIME_CLOSURE_EQUIVALENCE
allowed_claim: PARTIAL_VALIDATED_EXPORT_GATE_OPEN
product_implementation_effect: NONE
```

## 2. 허용 범위

이 대체 절차는 PR #107의 GUT 9.7.1 기존 설치 정합화 검증에만 적용한다.

- 새 제품 기능 구현을 승인하지 않는다.
- GUT 정식 채택 완료를 주장하지 않는다.
- export 제외 완료를 주장하지 않는다.
- branch protection·Ruleset·Required Check를 변경하거나 우회하지 않는다.
- 기존 workflow 파일을 비활성화하거나 삭제하지 않는다.
- PR HEAD가 바뀌면 모든 per-head 증거는 무효다.

## 3. 대체 검증 절차

현재 exact HEAD마다 다음을 새로 수행한다.

1. PR base·head·전체 changed-file inventory를 다시 읽는다.
2. 변경된 텍스트 파일을 GitHub API에서 내려받아 격리 디렉터리에 재구성한다.
3. 각 파일에 `git hash-object`를 적용하여 GitHub blob SHA와 일치하는지 검증한다.
4. Python 계약·validator 테스트를 재구성한 exact 파일에서 직접 실행한다.
5. current HEAD와 과거 Godot 4.7.1·GUT 성공 HEAD의 runtime closure를 Git tree/blob SHA로 비교한다.
6. 재사용하는 과거 실행 증거의 run·job·JUnit artifact를 다시 읽는다.
7. 과거 실행과 다른 파일은 재사용 증거에서 제외하고 `NOT_RUN` 또는 차단 상태로 남긴다.
8. 전체 diff, P0/P1 finding, review thread, mergeability, branch protection, Ruleset을 재확인한다.
9. 현재 exact HEAD와 증거 hash를 PR 본문·comment와 Google Sheet에 기록한다.

이 절차의 명칭은 다음과 같다.

```text
CONTENT_ADDRESSED_EXACT_HEAD_STATIC_PLUS_RUNTIME_CLOSURE_EQUIVALENCE
```

## 4. 재사용 가능한 객관 증거

과거 exact HEAD `2077732d308069d37e2391e3a8711c3215b07471`의 workflow run `31110086505`는 Godot 4.7.1 import와 GUT 실행을 성공했고, JUnit artifact `8971283702`는 대표 테스트 2건·실패 0건을 기록했다.

이 증거는 current HEAD의 다음 입력이 Git blob/tree SHA로 동일한 경우에만 제한적으로 재사용한다.

- `.gutconfig.json`
- `tests/gut/test_martial_manual_registry.gd`
- `project.godot`
- `addons/**`
- `src/**`
- `scenes/**`
- `data/**`
- `assets/**`

동일하지 않은 입력은 재사용하지 않는다.

## 5. 명시적 한계

```yaml
current_head_godot_execution: NOT_RUN_BUDGET_UNAVAILABLE
current_head_gut_execution: NOT_RUN_BUDGET_UNAVAILABLE
current_head_junit: NOT_GENERATED
export_presets_equivalence: NOT_CLAIMED_DIFFERENT_BLOB
export_exclusion: BLOCKED_PENDING_HIGODOT_L1
local_higodot: NOT_RUN_NO_LOCAL_ACCESS
local_windows: NOT_RUN_NO_LOCAL_ACCESS
android: NOT_RUN
human_validation: NOT_RUN
production_readiness: false
```

과거 성공 증거를 current HEAD에서 새로 실행한 것처럼 표현하지 않는다. 이 대체 절차가 통과해도 권위 상태는 `PARTIAL_VALIDATED_EXPORT_GATE_OPEN`을 넘지 않는다.

## 6. 병합 조건

PR #107은 다음이 모두 참일 때만 현재 대화의 자동 병합 권한을 적용할 수 있다.

- current exact HEAD의 모든 변경 blob이 재구성 manifest와 일치함
- fallback·reconciliation 정적 계약 테스트가 모두 통과함
- runtime closure 동일성이 증명됨
- 동일하지 않은 `export_presets.cfg`가 재사용 증거에서 명시적으로 제외됨
- GitHub required status check set이 비어 있음을 재확인함
- branch protection·Ruleset을 변경하지 않음
- unresolved review thread가 0개임
- P0/P1·blocking Important finding이 없음
- 전체 diff가 승인된 비제품 범위 안임
- PR이 Draft가 아니고 mergeable임
- per-head 증거가 PR과 Sheet에 같은 Decision ID로 기록됨

Actions가 실행되지 않은 사실은 성공으로 바꾸지 않고 `NON_REQUIRED_NOT_TREATED_AS_PASS`로 기록한다.

## 7. 무효화 조건

다음 중 하나가 발생하면 이 HEAD의 승인 증거는 즉시 무효다.

- PR HEAD 또는 base SHA 변경
- changed-file inventory 변경
- runtime closure SHA 변경
- 새 P0/P1 finding
- unresolved review thread 생성
- branch protection·Ruleset·required-check 정책 변경

새 HEAD에서 전 절차를 다시 수행한다.
