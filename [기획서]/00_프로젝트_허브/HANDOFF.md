# 십보강호 세션 인수

## 현재 상태

```yaml
phase: PLANNING_IN_PROGRESS
technical_baseline_sha: 659c57e7ffa588ad6a6471ed9b5394985b159eaf
main_baseline: a1580a01f4499e49d6b6913a66ffd6f1edd81c4d
planning_branch: agent/poc-planning-baseline-and-legacy-audit
project_core: CORE_CONFIRMED
product_gate: REPEAT_POC
runtime: IMPLEMENTED_LEGACY
new_poc_implementation: NOT_STARTED
human_validation: UNVERIFIED
t1_greenlight: NOT_GRANTED
```

## 이번 작업

구형 검사 뒤 1~10 기획을 수행하고, 다음 PoC를 주요 비무 1~5로 확장했다. 주요 비무 1은 튜토리얼, 2~5는 스테이지 1 초반부이며, 각 주요 비무 사이에 중간 노드 2~3개를 둔다. 총 방문 노드는 13~17개이고 5번 승리 뒤 첫 `[절초]`가 열린다.

스테이지 2는 주요 비무 6~8, 스테이지 3은 9~10이다. 천마·무림맹주 같은 천하제일인 히든 배틀은 스테이지 3 이후 후속 추가이며 본편 결말 필수가 아니다.

## 반드시 읽을 파일

1. `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`.
2. `docs/02_COMBAT_RULES.md`.
3. `docs/planning-data/README.md`와 JSON 5종.
4. `docs/05_COMBAT_POC_SPEC.md`.
5. `docs/08_TEST_CHECKLIST.md`.

## 다음 행동

- 사용자가 `기획 완료`라고 하기 전에는 PLAN 유지.
- 이후 5회 검수 결과와 정본을 교차 확인한다.
- 사용자가 `검수 완료`라고 한 뒤에만 Codex 인계와 런타임 변경 계획을 작성한다.
- 첫 구현 범위는 주요 비무 1~5, 네 구간의 중간 노드 8~12개, 5번 뒤 첫 절초 해금이다.

## 금지

- main 구형 런타임을 최신 구현으로 오인.
- planning JSON을 검증 없이 런타임에서 직접 읽기.
- 주요 비무 6~10·스테이지 2·3·히든 전투 선제 구현.
- 사람 증거 없이 재미·밸런스·T1 통과 주장.
