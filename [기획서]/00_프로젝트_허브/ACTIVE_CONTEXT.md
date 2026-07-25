# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `PLAN`.
- 단계: `PLANNING_IN_PROGRESS / POC_PLANNING_BASELINE_AUTHORED`.
- 단일 제품 기준: `main@a1580a01f4499e49d6b6913a66ffd6f1edd81c4d`.
- 작업 branch: `agent/poc-planning-baseline-and-legacy-audit`.
- 최신 승인 기준: `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`.
- 프로젝트 코어: `CORE_CONFIRMED`; 과거 `CORE_REVIEW_PENDING` 종료.
- 현행 런타임: `IMPLEMENTED_LEGACY`.
- 신규 플레이어 STEP 14: `NOT_RUN`.
- T1: `NOT_GRANTED`.

## 완료한 기획 작업

1. 구형 규칙·소비자 감사.
2. 정수 틱 예산.
3. 순차 연격 합·중단·강건·효과 계약.
4. 시작 무공 6개와 1~10성 표본.
5. 의료·성과 등급·보상.
6. 공개 상태 적 문법.
7. 주요 비무 10개 표본.
8. 3전+2선택 노드 PoC 지도.
9. 비런타임 sanity model.
10. UI·복기·아키텍처·QA 계약.

## 다음 플레이 가능한 범위

주요 비무 1~3, 성장 선택 2회, 시작 무공 4개 선택. 4~10 주요 비무는 데이터 표본이며 구현 범위가 아니다.

## 책임 원본

- 코어: `docs/01_GAME_DESIGN.md`.
- 전투: `docs/02_COMBAT_RULES.md`.
- 콘텐츠·지도·적: `docs/03_CONTENT_CATALOG.md` + `docs/planning-data/`.
- 성장: `docs/06_STARTING_FACTION_MASTERY_DATA.md`.
- PoC: `docs/05_COMBAT_POC_SPEC.md`.
- UI·QA·아키텍처·연출: `docs/07~10`.

## 구현 차이

main은 속공6·강공8·방어도4·내력4·명상2/1·`[준비]`+2·구형 강건을 구현한다. 신규 기획은 속공4·강공10·방어도5·내력5·명상1/1·`[강화]`×1.5·행동 중단1회 강건과 순차 연격을 요구한다.

기획 완료 전 제품 동작을 바꾸지 않는다.

## 다음 작업

1. 사용자 기획 확인.
2. 명시적 `기획 완료` 뒤 REVIEW 전환.
3. 검수 완료 뒤 Codex 구현계획·연속 인계.
4. 새 자동·Godot·Windows·사람 검증은 모두 `NOT_RUN`에서 시작.
