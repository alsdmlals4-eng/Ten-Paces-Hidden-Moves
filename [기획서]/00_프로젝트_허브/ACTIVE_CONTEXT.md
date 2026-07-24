# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `BUILD → REVIEW`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 제품 구현 원본: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정·계획: PR #15 `agent/project-core-confirmation`.
- A0 계약 정렬: PR #17 `agent/repeat-poc-a0-contract-alignment`.
- A1 라이벌 후보 AI: PR #19 `agent/repeat-poc-a1-rival-ai`.
- 최신 전투 승인: Issue #13.
- 현재 Goal: Issue #16.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 상태 전이: `CORE_REVIEW_PENDING → CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 현재 Task: `A2_HYPOTHESIS_AND_SUMMARY_READY`.
- 신규 플레이어 STEP 14: `DEFERRED_BY_USER / UNVERIFIED`.
- GitHub Actions: `AVAILABLE / FULL_VALIDATION_PASS`.

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

책임 원본은 `docs/01_GAME_DESIGN.md`, 판정·AI 원본은 `docs/02_COMBAT_RULES.md`, 구조 원본은 `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`다.

## 현재 구현

### T0 기반

- STEP 0~13.
- TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 기초 행동 8종·절초 3종.
- `[합]`·방어·회피·필중·중단·강건.
- 승패·무승부·완전 재시작.
- `timing_results`·`presentation_events`.
- 키보드·모션 감소·음향 제어 기술 증거.

### A0 계약 정렬

- board schema 17.
- `resolution_engine.enemy_plan_source = public_state_ai`.
- `fixed_enemy_preview_plan` 제거.
- fixture plan은 `ai_enabled == false`인 독립 회귀에서만 허용.
- 전투 정본 기준 SHA 정렬.
- 상태: `IMPLEMENTED_FULL_ACTIONS_PASS`.

### A1 라이벌 후보 AI

- 활성 라이벌 `rival_t0_midrange_pressure`.
- 공개 단서: 중거리 압박·안전한 강공 준비·저체력 대응.
- 최대 후보 3개, score window 2.0.
- 동일 공개 상태·seed 결정론.
- 다른 seed도 합리 후보 경계 안에서만 선택.
- `get_last_trace()` whitelist.
- 미확정 계획·UI 내부 상태 누출 차단.
- 상태: `IMPLEMENTED_FULL_ACTIONS_PASS`.

## REPEAT_POC 실행 계약

- Goal: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`.
- Codex: `plans/CODEX_GOAL_REPEAT_POC.md`.
- 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.
- 상태: `docs/decisions/2026-07-24_REPEAT_POC_IMPLEMENTATION_STATUS.json`.
- CI 정책: `docs/decisions/2026-07-24_CI_COST_OPTIMIZATION_AND_QUOTA_GATE.md`.
- 사람 테스트 자료: 보존, 현재 `DEFERRED_BY_USER / DO_NOT_RUN`.

```text
A0 정본 SHA·AI source·board schema — PASS
→ A1 라이벌 복수 후보 정책 — PASS
→ A2 가설 기록·결정적 summary — READY_NOT_STARTED
→ A3 복기 UI·접근성·기술 closeout — NOT_STARTED
```

## CI 구조와 증거

PR은 `.github/workflows/documentation-governance.yml`의 단일 Ubuntu job이 변경 경로를 분류한다.

- 문서 전용: Python 3.12 문서 validator.
- 코드·데이터·씬·워크플로: Python 3.12 전체 정적 계약과 PowerShell 파싱 1회.
- 중복 `.github/workflows/card-component-contract.yml` 삭제.
- `concurrency`와 `cancel-in-progress: true` 적용.

전체 검증은 `.github/workflows/full-validation.yml`이 소유한다.

- Ubuntu·Windows × Python 3.11·3.12.
- Godot 4.7 headless는 Ubuntu에서 1회.
- 각 계약·verifier를 독립 step으로 표시한다.
- main·nightly·수동에서만 실행한다.
- 저장소 변수 `ACTIONS_FULL_VALIDATION_ENABLED=true`가 필요하다.

최신 증거:

- PR #19 최종 PR Validation run #590: `PASS`.
- 검증 전용 PR #21 PR Validation run #589: `PASS`.
- Full Validation run #4: `PASS`.
- Ubuntu·Windows Python 3.11·3.12: 모두 `PASS`.
- Ubuntu Godot import·기존 회귀·신규 라이벌 verifier: 모두 `PASS`.
- 검증 전용 PR #20·#21: 병합 없이 종료.

`concurrency` 취소 설정은 적용됐지만 실제 진행 중 run의 취소 관찰은 아직 `NOT_OBSERVED`다.

## 다음 작업

A2의 Red 계약부터 시작한다.

1. `combat_hypothesis_poc.json` 가설 ID schema.
2. 플레이어가 직접 선택한 가설만 commit 직전 snapshot.
3. 미선택은 `none`이며 시스템 추정 금지.
4. 판정 결과·계획 snapshot·가설 snapshot·판정 전 상태만 소비하는 summary builder.
5. cause 우선순위: `clash > interrupted > defense > direction > range > resource > position > order`.
6. 판정 엔진 재호출·피해 재계산 금지.
7. A2 전용 PR·집중 verifier·Full Validation 증거.

## 증거 경계

```yaml
repeat_poc_planning: COMPLETE
a0_contract_alignment: IMPLEMENTED_FULL_ACTIONS_PASS
a1_rival_ai: IMPLEMENTED_FULL_ACTIONS_PASS
a2_hypothesis_and_summary: READY_NOT_STARTED
a3_review_ui: NOT_STARTED
pr_scope_routing: PASS
concurrency_cancellation: CONFIGURED_NOT_CANCELLATION_OBSERVED
full_validation: PASS
godot_headless: PASS
windows_python_matrix: PASS
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
- Actions 미실행을 PASS로 기록한다.
- 사람 증거 없이 T1·MVP·재미 검증을 완료 처리한다.
