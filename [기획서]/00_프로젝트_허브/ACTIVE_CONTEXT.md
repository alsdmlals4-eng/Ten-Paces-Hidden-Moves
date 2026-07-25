# 십보강호 활성 컨텍스트

## 현재 기준

- Work Mode: `PLAN`.
- 현재 단계: `PLANNING_IN_PROGRESS / PROJECT_REASSESSMENT_AND_POINTED_FUN`.
- 단일 제품 기준 branch: `main`.
- main 통합 PR: #41.
- main merge commit: `8b4380da79029dee5e07aae2622846fcf62e9431`.
- 현재 기획 branch: `planning/project-reassessment-and-pointed-fun`.
- 현재 기획 PR: #42.
- 승인 기획 기준선: `docs/decisions/2026-07-25_PROJECT_REASSESSMENT_APPROVED_PLANNING_BASELINE.md`.
- 전투 규칙 현행 구현 원본: `docs/02_COMBAT_RULES.md`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 프로젝트 코어 과거 상태 전이: `CORE_REVIEW_PENDING → CORE_CONFIRMED`.
- 최신 전투 승인 계보: `Issue #13`과 PR #42의 2026-07-24~25 사용자 승인.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 신규 플레이어 STEP 14: `DEFERRED_BY_USER / UNVERIFIED`.
- 기획 종료 게이트: 사용자의 명시적 `기획 완료` 전까지 `PLANNING_IN_PROGRESS` 유지.

기존 문서·PR 댓글과 충돌하면 2026-07-25 승인 기획 기준선의 최신 승인 항목이 우선한다.

## 현재 프로젝트 코어

> 짧은 연속 비무를 통해 여러 무공을 습득·수련하고, 해금된 소수의 기술을 기초 행동과 자유롭게 조합하여 매 회차 자신만의 무학 체계를 완성하는 무협 전술 로그라이트.

```text
짧은 연속 비무
→ 무공 습득·수련·기술 해금
→ 기초 행동과 기술 조합
→ 현재 무학으로 적 계획 파훼
→ 복기로 다음 성장·운용 변경
```

우선순위:

1. 짧은 전투를 통한 빠른 성장 선택.
2. 무공 습득·수련도 상승·기술 해금.
3. 기초 행동과 해금 기술의 자유 조합.
4. 현재 무학으로 적 특징과 실제 계획을 읽고 파훼.
5. 복기를 통한 다음 수련·운용 변경.

상대 읽기는 각 조우의 전술 축이다. 장기 라이벌 학습은 거시 제품 전제에서 후순위다.

## main 통합 결과

```text
PR #5 Base 운영체계
→ PR #7 T0 STEP 0~13
→ PR #15 코어·REPEAT_POC 계획
→ PR #17 A0 계약 정렬
→ PR #19 A1 라이벌 후보 AI
→ PR #22 A2 가설·summary
→ PR #25 A3 복기 UI·review gate
→ PR #35 과거 [준비]·[전조]·자동 배치
→ PR #41 main 통합
```

- Issue #16: `CLOSED / COMPLETED`.
- 선택된 제품 스택 PR: `INTEGRATED_BY_PR_41`.
- 대안 A2/A3와 검증 전용 PR: `SUPERSEDED / CLOSE_WITHOUT_MERGE`.
- 구형 2수·기세 6·11-Skill-PDF·구형 CI 제안: `SUPERSEDED`.
- Git 이력과 branch는 삭제하지 않음.

통합 결정 기록: `docs/decisions/2026-07-24_MAIN_STACK_INTEGRATION_AND_REASSESSMENT_START.md`.

## 승인된 회차·성장 기준

- `10전`은 필수 주요 비무·강적 조우 10개이며 전체 전투 수가 아니다.
- 주요 비무 사이에 2~4개 분기 노드와 선택 일반전이 있다.
- 시작 무공서 4개를 3성으로 선택하고 기술 4개로 시작한다.
- 수련도 3·7성 기술, 5·9성 기술 강화, 10성 절초·진의.
- 주요 비무 5 이전 한 무공 10성 또는 동급 광역 빌드를 보장한다.
- 3→10성 총 수련포인트 비용은 38.
- 전투 수련포인트는 전투 유형 기본값 + 성과 등급 보너스.
- 일반전은 수련포인트·금전 중심, 무공서는 문파·기연·강적·사건 중심.
- 해금 기술은 덱·손패·장착 제한 없이 항상 사용 가능.

금전·문파 관계·공헌·살해 선택·정보 전파·관찰 규칙은 승인 기획 기준선을 따른다.

## 승인된 전투 기준

### 라운드와 자원

- 한 라운드 10수, `3 / 3 / 4` 행동묶음.
- 체력 0까지 라운드 반복. 강제 라운드 제한 없음.
- 일반전 대부분 3라운드 이내 종료는 밸런스 목표.
- 시작 체력 30, 기력 5, 내력 5, 절초 기세 0/5.
- 라운드 시작 기력 +1, 내력 자연 회복 없음.
- 일반 명상 기력 +1·내력 +1.
- 체력은 전투 사이 유지.
- 승리 후 `min(잃은 체력, 2 + [의료])` 회복.
- `[의료]` 시작 0, 최대 4.

### 기본 전투 수치

```yaml
maximum_health: 30
attack_power: 4
defense: 5
```

- 속공: 1슬롯·기력 1·피해 `[공격력]` = 4.
- 강공: 2슬롯·기력 1·내력 1·`전조 → 공격`·피해 `2×[공격력]+2` = 10.
- 막기: 기력 1·실행 시 방어도 5 누적.
- 방어도는 후속 피해를 흡수한 만큼 소모되고 라운드 종료 시 0.
- 회피: 기력 1·기본 회피 횟수 1·타격 1회 회피.
- 회피 횟수 N은 현재 수부터 N개의 행동 수 동안 유지.
- 같은 수의 유효 공격은 `[합]`으로 방어·회피 전 원공격력 차이를 판정.

### 상태와 다중 슬롯

- 과거 `[준비]` 상태명은 `[강화]`로 변경.
- 태세 사용 시 `[강화]`와 `[강건]` 획득.
- `[강화]`: 다음 공격 계산 결과 `×1.5`.
- `[강건]`: 체력 피해로 인한 중단 1회 방지.
- 다중 슬롯 행동은 첫 전조에서 자원과 `[강화]`를 전액 선지불.
- 중단 시 자원·`[강화]`·점유 슬롯 환불 없음.
- 슬롯 성능 예산: 1슬롯 `1.0`, 2슬롯 `2.5`, 3슬롯 `4.0`.

### 교착 방지

- 한 라운드 양측 체력 피해 0이면 교착.
- 연속 1회 후 AI 공격 단계 1.
- 연속 2회 후 단계 2: 가능한 경우 공격 행동 필수, 순수 지연 금지.
- AI 능력치 강화 없음.
- 라운드 수·교착은 성과 등급 직접 감점 없음.

## 현행 기술 구현과 기획 차이

현행 main은 과거 PoC 규칙을 구현한다.

- 과거 `[준비]` 표시와 공격 +2.
- 방어도 4·행동묶음 방어·같은 수 추가 반감.
- 속공 피해 6·강공 피해 8.
- 내력 시작 4.
- 명상 기력 2·내력 1.

승인 기획 기준은 이를 다음과 같이 대체한다.

- `[준비]` → `[강화]`, 공격 결과 ×1.5.
- 방어도 5 누적·피해 흡수 소모.
- 속공 4·강공 10.
- 내력 시작 5.
- 명상 기력 1·내력 1.

기획 완료 전에는 Godot 제품 동작을 새 규칙으로 변경하지 않는다.

## 기술 증거

- PR #35 closeout PR Validation run #686: `PASS`.
- 통합 PR #41 PR Validation run #687: `PASS`.
- 동일 제품 tree Full Validation run #21: `PASS`.
- main과 제품 branch 비교: changed files `0`.
- main push-triggered Full Validation: `NOT_OBSERVED_VIA_CONNECTOR`.

마지막 항목을 PASS로 추정하지 않는다.

## 열린 기획 항목

- 무공별 1·3·5·7·9·10성 실제 데이터.
- `[의료]` 제공 무공·사건 배치.
- 성과 평가 최종 가중치와 등급 경계.
- 슬롯 성능 예산의 효과별 환산표.
- 적별 체력·공격력·변초·패턴.
- 10개 주요 비무의 이름·세력·과제·보상.
- 실제 지도 전투 수·노드 분포.
- 사람 플레이 기반 규칙 이해·재미·사용성·시장 적합성.

## C 단계 보호 범위

- 승인 전 Godot 제품 동작 변경 금지.
- T1·주요 비무·세력·무공 콘텐츠 선제 제작 금지.
- AI의 미확정 계획 열람 금지.
- 덱·손패·행동력·내공·`[집중]` 재도입 금지.
- 사람 증거 없이 재미·이해도·시장성·T1·MVP 통과 금지.
- 기존 승인 규칙 변경은 `CHANGE_PROPOSAL / USER_DECISION_REQUIRED`로 분리.

## 다음 작업

1. 슬롯 성능 예산의 효과별 환산표를 설계한다.
2. 승인 기준선에서 열린 항목을 한 번에 하나씩 확정한다.
3. 기획 완료 선언 후 전체 정본 문서를 교차 갱신하고 검수 단계로 전환한다.
4. 검수 완료 선언 후에만 Codex 구현 계획을 작성한다.

## 책임 원본

- 최신 승인 기획: `docs/decisions/2026-07-25_PROJECT_REASSESSMENT_APPROVED_PLANNING_BASELINE.md`.
- 현행 구현 전투 규칙: `docs/02_COMBAT_RULES.md`.
- 현재 프로젝트 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.

## 증거 경계

```yaml
main_stack_integration: COMPLETE
repeat_poc_technical_goal: COMPLETE
approved_planning_data_consolidated: true
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

기술 검증은 실제 플레이어 이해·재미·조작 선호·시장 적합성을 대체하지 않는다.
