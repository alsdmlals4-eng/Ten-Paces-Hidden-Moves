# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `BUILD`.
- 단계: `BUILD_IN_PROGRESS / IMPLEMENTATION_PLAN_AUTHORED`.
- 단일 제품 기준: `main@48c26c02d53fe49a34b831f5bcf0924ae36f5dbd`.
- planning·review branch: `agent/poc-planning-baseline-and-legacy-audit`.
- 구현 branch 예정: `codex/p0-poc-runtime-foundation`.
- 최신 승인 기준: `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`.
- 전체 적대적 검토: `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md`.
- REVIEW 완료·BUILD 진입: `docs/decisions/2026-07-26_REVIEW_COMPLETE_AND_BUILD_ENTRY.md`.
- UI·UX·사운드 에셋 파이프라인: `docs/superpowers/specs/2026-07-26-ui-ux-audio-asset-pipeline-design.md`.
- 기획 완료 선언: `2026-07-26 USER_CONFIRMED`.
- 검수 완료 선언: `2026-07-26 USER_CONFIRMED`.
- 프로젝트 코어: `CORE_CONFIRMED`; 과거 `CORE_REVIEW_PENDING` 종료.
- 현행 런타임: `IMPLEMENTED_LEGACY`.
- 신규 PoC 런타임: `NOT_STARTED`.
- 에셋 검색·생성·통합: `NOT_STARTED`.
- 신규 플레이어 STEP 14: `NOT_RUN`.
- T1: `NOT_GRANTED`.

## REVIEW 완료 결과

- `TECHNICAL_REVIEW_PROPOSAL`: 14건 중 13건 planning BUILD 반영, 1건 `NO_CHANGE` 재분류.
- `USER_DECISION_REQUIRED`: 모두 해결.
- `BLOCKED_UNVERIFIED`: runtime·Godot·에셋·Windows·접근성·성능·사람 증거로 이관.
- `NO_CHANGE`: 코어·PoC 범위·확장 경계 보호.
- 최종 REVIEW 판정: `PASS_WITH_FOLLOWUP`.
- 사용자 `검수 완료`: 구현 인계 승인.

## 사용자 결정

1. 패배 시 전투 직전 `RunState`를 복원해 같은 seed로 재도전한다.
2. 같은 전투 재도전은 `[영구재화]` 1→2→3개, 상한 3, 다른 전투 진입 시 초기화한다.
3. `[필중]`은 실제 회피를 우회한 유효 타격마다 1스택 소비한다.
4. 주요 비무 보상은 자유6 / 지정 무공5+자유3 / 문파 무공3성이다.
5. 주요 비무5 진입 전 10성 경로는 집중32+노드6 또는 자유24+고효율 노드14다.
6. UI·UX·사운드는 컨셉 정의 → 에셋 검색·평가 → 부족분 생성 → 통합 검증 순서를 따른다.

## 구현 프로그램

1. `docs/superpowers/plans/2026-07-26-poc-implementation-program.md`.
2. `docs/superpowers/plans/2026-07-26-poc-runtime-foundation-implementation-plan.md`.
3. `docs/superpowers/plans/2026-07-26-poc-campaign-progression-implementation-plan.md`.
4. `docs/superpowers/plans/2026-07-26-poc-ui-audio-assets-implementation-plan.md`.

실행 순서:

```text
runtime foundation
→ REVIEW
→ campaign·progression
→ REVIEW
→ UI·audio asset search·integration
→ REVIEW
→ Full Validation·Windows·STEP 14
```

각 BUILD 구간은 TDD로 수행하고 종료 시 REVIEW로 복귀한다.

## UI·UX·사운드 제작 경계

```text
컨셉·정보 요구
→ event matrix·asset gap map
→ 최신 에셋 스토어·라이브러리 검색
→ 출처·라이선스·가격·Godot 적합성 평가
→ ADOPT / ADAPT / GENERATE / REJECT / DEFER
→ 부족분만 생성
→ Godot 통합
→ 가독성·접근성·사운드 피로·성능·사람 검증
```

실제 검색·구매·다운로드·생성·통합은 아직 `NOT_STARTED / NOT_RUN`이다. 유료 에셋 구매는 별도 사용자 승인 없이 수행하지 않는다.

## 구현 범위

- 주요 비무1은 튜토리얼, 2~5는 스테이지1 초반부.
- 각 주요 비무 사이 중간 노드2~3개, 총 방문13~17개.
- 시작 무공 6개 중 4개를 3성으로 선택.
- 기본 절초3종은 시작부터 사용 가능.
- 무공별 10성 절초는 해당 무공 10성 도달로 해금.
- 주요 비무6~10, 스테이지2·3, 히든은 구현 금지.

## 책임 원본

- 코어: `docs/01_GAME_DESIGN.md`.
- 전투: `docs/02_COMBAT_RULES.md`.
- 콘텐츠·지도·적: `docs/03_CONTENT_CATALOG.md` + `docs/planning-data/`.
- 성장: `docs/06_STARTING_FACTION_MASTERY_DATA.md`.
- PoC: `docs/05_COMBAT_POC_SPEC.md`.
- UI·UX: `docs/07_COMBAT_UI_SPEC.md`.
- QA: `docs/08_TEST_CHECKLIST.md`.
- 아키텍처: `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.
- 연출·사운드: `docs/10_COMBAT_PRESENTATION_PLAN.md`.

## 현재 구현 차이

main은 속공6·강공8·방어도4·내력4·명상2/1·구형 `[준비]`·구형 강건과 단일 전투 상태를 구현한다. 승인 PoC는 속공4·강공10·방어도5·내력5·명상1/1·`[강화]`×1.5·중단1회 강건·순차 연격·스택형 필중·RunState 유료 재도전을 요구한다.

## 다음 작업

1. planning/review head에서 `codex/p0-poc-runtime-foundation` branch와 격리 worktree를 만든다.
2. 기존 planning 24/24, validator, Godot parse 기준선을 확인한다.
3. runtime adapter RED 테스트부터 시작한다.
4. runtime foundation 완료 뒤 REVIEW로 복귀해 Godot·회귀 증거를 기록한다.
5. PR #45 병합은 별도 명시적 병합 작업으로 처리한다.
