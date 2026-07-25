# 십보강호 세션 인수

## 현재 상태

```yaml
phase: PLANNING_IN_PROGRESS
main_baseline: a1580a01f4499e49d6b6913a66ffd6f1edd81c4d
planning_branch: agent/poc-planning-baseline-and-legacy-audit
project_core: CORE_CONFIRMED
runtime: IMPLEMENTED_LEGACY
new_poc_implementation: NOT_STARTED
human_validation: UNVERIFIED
t1_greenlight: NOT_GRANTED
```

## 이번 작업

구형 검사 뒤 1~10 PoC 기획을 수행했다. 편집 가능한 budget/manual/duel/map JSON, 최신 전투 규칙, 3전 PoC, UI·QA·아키텍처·연출, 벤치마크·적대적 검토·sanity 기록을 작성했다.

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
- 첫 구현 범위는 주요 비무 1~3과 성장 선택 2회다.

## 금지

- main 구형 런타임을 최신 구현으로 오인.
- planning JSON을 검증 없이 런타임에서 직접 읽기.
- 4~10 주요 비무·전체 지도 선제 구현.
- 사람 증거 없이 재미·밸런스·T1 통과 주장.
