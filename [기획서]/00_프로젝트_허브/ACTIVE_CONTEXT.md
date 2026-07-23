# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `PLAN → BUILD_HANDOFF` — Issue #16 REPEAT_POC 구현 준비 완료, 제품 구현 미시작.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 제품 구현 PR: #7 `agent/t0-combat-poc-board`.
- 제품 기준 SHA: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정·계획 PR: #15 `agent/project-core-confirmation`.
- 현재 Goal Issue: #16 `REPEAT_POC: 가설 기록·결정적 복기·라이벌 성향·STEP 14`.
- 최신 전투 승인: Issue #13 STEP 12~14.
- 제품 단계: T0 Prototype.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 구현 상태: `NOT_STARTED`.

## 확정된 프로젝트 코어

> 상대의 공개된 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·`[합]`·대응·중단으로 한 수를 파훼하고, 그 이유를 복기해 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

```text
대전 격투식 수읽기·파훼
> 전술 퍼즐식 거리·순서
> 로그라이트 성장
```

### 코어 보호 경계

- 1대1 무협 라이벌 결투.
- 10칸 일자형 전장, 플레이어 4번·상대 7번·거리 3.
- 비공개 `3수 → 3수 → 4수`, 총 10수 계획.
- 공개 정보와 반복 습관에 기반한 상대 읽기.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패 없이 항상 사용할 수 있는 소수 공용 행동.
- 위치·순서·대응·파훼가 원시 피해량보다 우선.
- 결과 이유를 복기하고 다음 계획을 변경한다.

책임 원본은 `docs/01_GAME_DESIGN.md`, 확정 과정은 `docs/decisions/2026-07-23_PROJECT_CORE_DECISION_RECORD.md`가 기록한다.

## 현재 구현

- STEP 0~13 구현.
- TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 10칸·4/7·거리 3·거리 0 `[밀착]`.
- `3수 → 3수 → 4수`.
- 기초 행동 8종·절초 3종.
- `[합]`·순차 방어·회피·필중·중단·강건.
- 공개 상태 기반 결정적 최소 AI.
- 승패·무승부·4/7 완전 재시작.
- 수별 `timing_results`·`presentation_events` 연출.
- 키보드 포커스·모션 감소·음향 제어·UI Automation 기술 증거.

세부 판정은 `docs/02_COMBAT_RULES.md`, 범위는 `docs/05_COMBAT_POC_SPEC.md`, 증거는 `docs/08_TEST_CHECKLIST.md`, 실제 상태는 `data/`, `src/`, `scenes/`, `assets/`, `tests/`가 책임진다.

## REPEAT_POC 실행 계약

- GitHub Issue: #16.
- Codex 시작: `plans/CODEX_GOAL_REPEAT_POC.md`.
- 상세 구현 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.
- Goal 계약: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`.
- 상태 JSON: `docs/decisions/2026-07-24_REPEAT_POC_IMPLEMENTATION_STATUS.json`.
- 사람 테스트 초안: `docs/research/STEP14_REPEAT_POC_PROTOCOL_DRAFT.md`.
- 결과 템플릿: `docs/research/STEP14_REPEAT_POC_RESULTS_TEMPLATE.md`.

### 실행 순서

```text
A0 정본 SHA·AI source·board schema 정렬
→ A1 데이터 기반 라이벌 복수 후보 정책
→ A2 플레이어 가설 기록·결정적 summary
→ A3 복기 UI·접근성 흐름
→ A4 동일 SHA 신규 플레이어 STEP 14
```

PR-A0~A4는 독립 스택형 PR로 수행한다. 한 거대 PR로 합치지 않는다.

## 다음 첫 행동

Codex는 `plans/CODEX_GOAL_REPEAT_POC.md`를 읽고 Task 1의 Red 검사부터 시작한다.

```text
Task 1 — docs/02·05·08·09의 기준 SHA
+ combat_board_poc.fixed_enemy_preview_plan
+ public_state_ai
+ board schema 17
정렬
```

Task 1의 Red가 예상 이유로 실패하기 전 제품 코드를 변경하지 않는다.

## 포함·제외

### 포함

- 현행 SHA·AI source·Schema 정렬.
- 라이벌 1명의 공개 단서와 복수 합리 후보.
- 플레이어 가설 6개 선택지.
- 결정적 원인 summary와 최소 복기 UI.
- 키보드·모션 감소 정보 보존.
- 고정 SHA 신규 플레이어 5명 STEP 14.

### 제외

- 새 기초 행동·절초.
- 합·피해·방어·필중·중단·강건 공식 변경.
- 12세력·10성·10전 캠페인.
- 무공·심법·성장·경제·저장.
- 다중 라이벌·난이도·머신러닝.
- 승률·예측률·정답 행동 추천.

## GitHub·검증 상태

- PR #14 정본·Skill·Governance 최신화: PR #7에 병합 완료.
- PR #7 HEAD: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- PR #15: Open·Draft·mergeable.
- 최종 마감 기준 head `b39e1e75...` Documentation Governance run #478: `PASS`.
- REPEAT_POC 계획 변경 최신 head의 Governance: `PENDING`.
- Issue #16: Open, assignee `alsdmlals4-eng`.
- REPEAT_POC 계획 diff: 정본 7개 + 이 Active Context·Documentation Map 소비자 갱신.
- 제품 코드·데이터·씬·자산 변경: 0건.
- Branch protection Required Check 강제: `UNVERIFIED`.
- 저장소 등록 문서·Skill Registry 발행 정책: `source_only`.

## 증거 경계

```yaml
step_0_to_13_implementation: IMPLEMENTED
repeat_poc_planning: COMPLETE
codex_goal: READY
repeat_poc_implementation: NOT_STARTED
mechanical_step14_scenarios: RECORDED
human_rule_comprehension: NOT_RUN
opponent_tendency_discovery: NOT_RUN
assistive_technology_user_validation: NOT_RUN
subjective_audio_motion_readability: NOT_RUN
external_playtest: NOT_RUN
release_performance_budget: NOT_RUN
branch_protection_required_checks: UNVERIFIED
local_uncommitted_state: UNVERIFIED
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

기계 시나리오와 계획 문서는 실제 플레이어 이해·성향 발견·계획 변경을 대체하지 않는다.

## STEP 14 사전 고정 통과 신호

- 5명 중 4명 이상 치명적 차단 없이 한 판 완료.
- 5명 중 4명 이상 3/3/4와 결정적 원인 하나 설명.
- 5명 중 3명 이상 안내 없이 라이벌 성향 하나 발견.
- 5명 중 3명 이상 재도전에서 계획을 실질적으로 변경.
- 5명 중 3명 이상 자발적 재도전 또는 구체적 다음 수 제시.
- 핵심 정보가 색·모션·음향 하나에만 의존한 참가자 0명.

## 중단 조건

- PR #7 또는 실행 base가 예상과 다르게 이동했다.
- private player plan이 AI snapshot·trace에 들어간다.
- 복기 UI가 전투 판정을 재계산한다.
- 플레이어가 기록하지 않은 가설을 시스템이 추정한다.
- 라이벌 성향을 근거 없는 완전 랜덤으로 구현한다.
- 사람 증거 없이 STEP 14·T1·MVP를 통과 처리한다.
- 콘텐츠·성장 범위가 코어 검증보다 커진다.
