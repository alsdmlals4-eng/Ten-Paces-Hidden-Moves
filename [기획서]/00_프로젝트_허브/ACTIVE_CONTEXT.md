# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `BUILD → REVIEW`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 제품 구현 PR #7: `agent/t0-combat-poc-board`.
- 제품 기준 SHA: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정·계획 PR: #15 `agent/project-core-confirmation`.
- 최신 전투 승인: Issue #13.
- 현재 Goal Issue: #16.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 상태 전이: `CORE_REVIEW_PENDING → CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 현재 Task: `A0_CONTRACT_ALIGNMENT`.
- 기술 구현: `NOT_STARTED`.
- 신규 플레이어 STEP 14: `DEFERRED_BY_USER`.

## 프로젝트 코어

> 상대의 공개 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·`[합]`·대응·중단으로 한 수를 파훼하고, 그 이유를 복기해 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

```text
대전 격투식 수읽기·파훼
> 전술 퍼즐식 거리·순서
> 로그라이트 성장
```

보호 경계:

- 10칸, 플레이어 4번·상대 7번·거리 3.
- 비공개 `3수 → 3수 → 4수`.
- AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패 없는 소수 공용 행동.
- 위치·순서·대응·파훼 우선.
- 결과 이유를 복기하고 다음 계획을 변경한다.

책임 원본은 `docs/01_GAME_DESIGN.md`다. 세부 전투 판정과 AI 계약은 `docs/02_COMBAT_RULES.md`가 책임진다.

## 현재 구현

- STEP 0~13.
- TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 기초 행동 8종·절초 3종.
- `[합]`·방어·회피·필중·중단·강건.
- 공개 상태 기반 결정적 최소 AI.
- 승패·무승부·완전 재시작.
- `timing_results`·`presentation_events`.
- 키보드·모션 감소·음향 제어 기술 증거.

## 실행 계약

- Goal: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`.
- Codex: `plans/CODEX_GOAL_REPEAT_POC.md`.
- 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.
- 상태: `docs/decisions/2026-07-24_REPEAT_POC_IMPLEMENTATION_STATUS.json`.
- 플레이테스트 자료: 보존, 현재 `DEFERRED_BY_USER / DO_NOT_RUN`.

```text
A0 정본 SHA·AI source·board schema
→ A1 라이벌 복수 후보 정책
→ A2 가설 기록·결정적 summary
→ A3 복기 UI·접근성·기술 closeout
```

PR-A0~A3는 독립 스택형 PR로 수행한다.

## 다음 작업

`agent/repeat-poc-a0-contract-alignment`에서 Red 검사부터 시작한다.

- `docs/02`, `05`, `08`, `09` 기준 SHA 정렬.
- `fixed_enemy_preview_plan`과 `public_state_ai` 충돌 제거.
- board schema 17.

## 범위

포함:

- 계약 정렬.
- 라이벌 1명.
- 가설 6개.
- 결정적 복기.
- 키보드·모션 감소.
- 자동·Godot·Windows 기술 검증.

제외:

- 신규 플레이어 테스트.
- 새 행동·절초.
- 판정 공식 변경.
- 세력·성장·경제·저장 확장.
- 정답 행동·승률·예측률.

## 증거 경계

```yaml
repeat_poc_planning: COMPLETE
codex_goal: READY
repeat_poc_implementation: NOT_STARTED
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
technical_implementation_complete: false
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

기술 검증은 실제 플레이어 이해·성향 발견·재미를 대체하지 않는다.

## 중단 조건

- 기준 branch 또는 SHA가 예상과 다르다.
- AI 입력에 미확정 계획이 포함된다.
- 복기 UI가 판정을 재계산한다.
- 미선택 가설을 시스템이 추정한다.
- 근거 없는 완전 랜덤을 사용한다.
- 사람 증거 없이 T1·MVP·재미 검증을 완료 처리한다.
