# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `PLAN`.
- 현재 단계: `PROJECT_REASSESSMENT_AND_POINTED_FUN`.
- 단일 제품·기획 기준 branch: `main`.
- main 통합 PR: #41.
- main merge commit: `8b4380da79029dee5e07aae2622846fcf62e9431`.
- 현재 기획 branch: `planning/project-reassessment-and-pointed-fun`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 과거 상태 전이: `CORE_REVIEW_PENDING → CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 신규 플레이어 STEP 14: `DEFERRED_BY_USER / UNVERIFIED`.
- 사용자 지시: A main 통합·정본 정상화 뒤 C 프로젝트 전면 재감사.
- 기획 종료 게이트: 사용자의 명시적 `기획 완료` 전까지 `PLANNING_IN_PROGRESS` 유지.

## 현재 프로젝트 코어

> 상대의 공개 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·`[합]`·대응·중단으로 한 수를 파훼하고, 그 이유를 복기해 다음 계획을 바꾸는 1대1 무협 심리 전술 로그라이트.

```text
대전 격투식 수읽기·파훼
> 전술 퍼즐식 거리·순서
> 로그라이트 성장
```

현재 코어는 확정 상태지만 C 단계에서 **보존할 핵과 수정할 표현·루프·제품 범위**를 적대적으로 재검토한다. 코어를 자동 폐기하거나 T1을 선승인하지 않는다.

## main 통합 결과

```text
PR #5 Base 운영체계
→ PR #7 T0 STEP 0~13
→ PR #15 코어·REPEAT_POC 계획
→ PR #17 A0 계약 정렬
→ PR #19 A1 라이벌 후보 AI
→ PR #22 A2 가설·summary
→ PR #25 A3 복기 UI·review gate
→ PR #35 [준비]·[전조]·자동 배치
→ PR #41 main 통합
```

- Issue #16: `CLOSED / COMPLETED`.
- 선택된 제품 스택 PR: `INTEGRATED_BY_PR_41`로 종료.
- 대안 A2/A3와 검증 전용 PR: `SUPERSEDED / CLOSE_WITHOUT_MERGE`.
- 구형 2수·기세 6·11-Skill-PDF·구형 CI 제안: `SUPERSEDED`.
- Git 이력과 branch는 삭제하지 않음.

통합 결정 기록: `docs/decisions/2026-07-24_MAIN_STACK_INTEGRATION_AND_REASSESSMENT_START.md`.

## 현행 기술 구현

### 전투 기반

- 10칸, 플레이어 4번·상대 7번, 시작 거리 3.
- 비공개 `3수 → 3수 → 4수`.
- 기초 행동 8종·절초 3종.
- `[합]`·방어·회피·필중·중단·강건.
- 승리·패배·무승부·4/7 완전 재시작.
- `timing_results`·`presentation_events`.
- 키보드·모션 감소·음향 제어 기술 증거.

### REPEAT_POC A0~A3

- A0 정본 SHA·AI source·board schema 17: `PASS`.
- A1 공개 상태 기반 라이벌 복수 후보·seed 결정론·trace whitelist: `PASS`.
- A2 플레이어가 직접 고른 가설 snapshot·순수 결정적 summary: `PASS`.
- A3 복기 UI·review gate·terminal 재시작·접근성: `PASS`.

### `[준비]`·`[전조]`·자동 배치

- 내부 ID `basic_stance`, 표시명 `[준비]`.
- 다중 슬롯 행동의 실행 전 점유 수 `[전조]`.
- `[준비]` 뒤 이동·보법·이동 실패·제자리 이동은 준비 상태 비소모.
- `[준비]` 뒤 명상은 기존 회복과 절초 기세 +1, 최대 5.
- 공격은 +2와 `[강건]` 적용 뒤 준비 상태 소비.
- 모든 기초 카드·절초는 가장 앞의 유효 연속 빈 구간에 자동 배치.
- 절초 예약은 진행 전 취소 가능하며 기세 5 반환.
- committed 이후 실패·중단에는 환불하지 않음.

## 기술 증거

- PR #35 closeout PR Validation run #686: `PASS`.
- 통합 PR #41 PR Validation run #687: `PASS`.
- 동일 제품 tree Full Validation run #21: `PASS`.
  - Ubuntu·Windows × Python 3.11·3.12.
  - Ubuntu Godot 4.7 import.
  - 기존 전투·절초·재시작·접근성·AI·A2·A3 회귀.
  - 신규 준비 기세·자동 배치 verifier.
- main과 제품 branch 비교: changed files `0`; 제품 branch `0 ahead / 1 behind`.
- main push-triggered Full Validation: `NOT_OBSERVED_VIA_CONNECTOR`.

마지막 항목을 PASS로 추정하지 않는다. 동일 tree의 Full Validation #21과 통합 PR Validation #687을 현재 증거로 사용한다.

## C 전면 재감사 범위

1. 대상 플레이어·플레이 맥락·세션 기대.
2. 한 문장 가치 제안과 프로젝트 코어의 선명도.
3. 한 수·한 묶음·한 전투에서 반복되는 뾰족한 재미.
4. 상대 읽기→가설→비공개 계획→공개→파훼→복기→다음 계획 루프.
5. 거리·순서·대응·자원·절초가 만드는 선택 밀도와 불필요한 복잡도.
6. 라이벌 성향·정보 공개·공정성 신뢰.
7. 로그라이트 성장과 전투 수읽기의 정렬 또는 충돌.
8. 벤치마크·플레이어 반응·시장 차별화.
9. 제작 범위·콘텐츠 부채·UI 접근 장벽.
10. 가장 위험한 미검증 가설과 다음 최소 PoC.

## C 단계 보호 범위

- 승인 전 Godot 제품 동작 변경 금지.
- T1·5전·10전·세력·무공·성장 콘텐츠 선제 제작 금지.
- AI의 미확정 계획 열람 금지.
- 덱·손패·행동력·내공·`[집중]` 재도입 금지.
- 사람 증거 없이 재미·이해도·시장성·T1·MVP 통과 금지.
- 기존 승인 규칙 변경은 `CHANGE_PROPOSAL / USER_DECISION_REQUIRED`로 분리.

## 다음 작업

1. main 책임 원본과 실제 코드·데이터·테스트를 전수 대조한다.
2. 현재 코어·뾰족한 재미·루프를 `AMPLIFY / SUPPORT / CONFLICT / UNPROVEN`으로 분류한다.
3. 벤치마크와 플레이어 증거는 결정을 바꿀 질문만 조사한다.
4. 프로젝트 방향 대안 2~3개를 비용·위험·검증 방법과 함께 제시한다.
5. 사용자 결정은 한 번에 하나씩 확인한다.
6. 승인된 설계를 `docs/superpowers/specs/`에 작성하고 사용자 검토를 받는다.
7. 사용자의 `기획 완료` 선언 전에는 Codex 구현 인계로 넘어가지 않는다.

## 먼저 읽을 책임 원본

1. `README.md`.
2. `docs/01_GAME_DESIGN.md`.
3. `docs/02_COMBAT_RULES.md`.
4. `docs/04_ROADMAP.md`.
5. `docs/05_COMBAT_POC_SPEC.md`.
6. `docs/08_TEST_CHECKLIST.md`.
7. `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`.

## 증거 경계

```yaml
main_stack_integration: COMPLETE
repeat_poc_technical_goal: COMPLETE
technical_implementation_complete: true
planning_phase: PLANNING_IN_PROGRESS
project_reassessment: IN_PROGRESS
main_push_full_validation: NOT_OBSERVED_VIA_CONNECTOR
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
subjective_usability: UNVERIFIED
market_fit: UNVERIFIED
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

기술 검증은 실제 플레이어 이해·성향 발견·재미·조작 선호·시장 적합성을 대체하지 않는다.