# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `BUILD → REVIEW`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 제품 구현 PR: PR #7 `agent/t0-combat-poc-board`.
- 제품 기준 SHA: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 코어 확정·계획 PR: PR #15 `agent/project-core-confirmation`.
- 현재 구현 PR: PR #17 `agent/repeat-poc-a0-contract-alignment`.
- 최신 전투 승인: Issue #13.
- 현재 Goal: Issue #16.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 상태 전이: `CORE_REVIEW_PENDING → CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 현재 Task: `CI_OPTIMIZATION_AND_A0_CLOSEOUT`.
- 신규 플레이어 STEP 14: `DEFERRED_BY_USER`.
- GitHub Actions 전체 검증: `BLOCKED_BY_ACTIONS_QUOTA`.

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

책임 원본은 `docs/01_GAME_DESIGN.md`, 판정 원본은 `docs/02_COMBAT_RULES.md`다.

## 현재 구현

- STEP 0~13.
- TARGETING 10.5, RESPONSE·RESOURCE PREVIEW 10.6.
- 기초 행동 8종·절초 3종.
- `[합]`·방어·회피·필중·중단·강건.
- 공개 상태 기반 결정적 최소 AI.
- 승패·무승부·완전 재시작.
- `timing_results`·`presentation_events`.
- 키보드·모션 감소·음향 제어 기술 증거.

## REPEAT_POC 실행 계약

- Goal: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`.
- Codex: `plans/CODEX_GOAL_REPEAT_POC.md`.
- 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`.
- 상태: `docs/decisions/2026-07-24_REPEAT_POC_IMPLEMENTATION_STATUS.json`.
- CI 비용·할당량 정책: `docs/decisions/2026-07-24_CI_COST_OPTIMIZATION_AND_QUOTA_GATE.md`.
- 플레이테스트 자료: 보존, 현재 `DEFERRED_BY_USER / DO_NOT_RUN`.

```text
A0 정본 SHA·AI source·board schema
→ A1 라이벌 복수 후보 정책
→ A2 가설 기록·결정적 summary
→ A3 복기 UI·접근성·기술 closeout
```

## A0 상태

- board schema 17.
- `resolution_engine.enemy_plan_source = public_state_ai`.
- `fixed_enemy_preview_plan` 제거.
- fixture plan은 `ai_enabled == false`인 독립 회귀에서만 허용.
- `docs/02`, `05`, `08`, `09` 기준 SHA를 `659c57e7...`로 정렬.
- Red 증거: Governance run #562에서 새 테스트가 `17 != 16`으로 실패.
- 기존 Green 증거: workflow 구조 변경 전 run #570 PASS.
- 최종 CI 구조 변경 후 검증: `BLOCKED_BY_ACTIONS_QUOTA`.

## CI 구조

PR은 `.github/workflows/documentation-governance.yml`의 단일 Ubuntu job이 변경 경로를 분류한다.

- 문서 전용: Python 3.12 문서 validator만 실행.
- 코드·데이터·씬·워크플로: Python 3.12 전체 정적 계약과 PowerShell 파싱 1회.
- 기존 중복 `.github/workflows/card-component-contract.yml` 삭제.
- `concurrency`와 `cancel-in-progress: true` 적용.

전체 검증은 `.github/workflows/full-validation.yml`이 소유한다.

- Ubuntu·Windows × Python 3.11·3.12.
- Godot 4.7 headless는 Ubuntu에서 1회.
- 저장소 변수 `ACTIONS_FULL_VALIDATION_ENABLED=true`일 때만 runner 할당.
- 현재 변수 활성 및 실행 결과는 `UNVERIFIED / BLOCKED_BY_ACTIONS_QUOTA`.

## 다음 작업

사용자가 Actions 사용 가능을 명시하기 전:

1. Actions 전체 검증을 요구하지 않는다.
2. A1 설계·코드 작업은 로컬 또는 정적 검증 가능한 단위만 진행한다.
3. Actions 의존 검증을 `BLOCKED_BY_ACTIONS_QUOTA`로 기록한다.

사용자가 Actions 사용 가능을 명시한 뒤:

1. `ACTIONS_FULL_VALIDATION_ENABLED=true` 확인.
2. PR #17 최신 head에서 `Full Validation` 수동 실행.
3. Python matrix와 Godot 결과를 Issue #16·PR #17·상태 JSON에 기록.
4. 실패 job만 원인 분석하고 중복 전체 재실행을 피한다.

## 증거 경계

```yaml
repeat_poc_planning: COMPLETE
a0_contract_alignment: IMPLEMENTED_PENDING_FULL_ACTIONS_VERIFICATION
ci_scope_routing: IMPLEMENTED_NOT_ACTIONS_VERIFIED
concurrency_cancellation: IMPLEMENTED_NOT_ACTIONS_VERIFIED
full_validation: BLOCKED_BY_ACTIONS_QUOTA
godot_headless: BLOCKED_BY_ACTIONS_QUOTA
windows_python_matrix: BLOCKED_BY_ACTIONS_QUOTA
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
