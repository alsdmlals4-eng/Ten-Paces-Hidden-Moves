# 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

상대의 공개 상태와 반복 습관을 읽고, 서로의 현재 계획을 모른 채 10칸 전장에 `3수 → 3수 → 4수`로 수를 걸어 거리·`[합]`·대응·중단으로 한 수를 파훼하고, 그 이유를 복기해 다음 계획을 바꾸는 **1대1 무협 심리 전술 로그라이트**입니다.

> 미래를 미리 보는 게임이 아니라, 보이지 않는 상대의 수를 읽고 파훼하는 무협 결투.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [문서·Skill 지도]([기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md)
- [게임 기획·코어 계약](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [제품 로드맵](docs/04_ROADMAP.md)
- [테스트 체크리스트](docs/08_TEST_CHECKLIST.md)
- [시스템 아키텍처](docs/09_COMBAT_SYSTEM_ARCHITECTURE.md)
- [main 통합·재감사 결정](docs/decisions/2026-07-24_MAIN_STACK_INTEGRATION_AND_REASSESSMENT_START.md)
- [Base 적용 기준](docs/BASE_RULES_VERSION.md)
- [Base 동기화 감사]([기획서]/00_프로젝트_허브/BASE_MAIN_SYNC_AUDIT.md)
- [기획 책임 원본 Registry]([기획서]/DESIGN_DOCUMENT_REGISTRY.json)
- [프로젝트 Skill Registry]([기획서]/00_프로젝트_허브/SKILL_REGISTRY.json)

## 현재 기준

- 단일 제품·기획 기준: `main@8b4380da79029dee5e07aae2622846fcf62e9431`.
- 통합 PR: #41.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 역사적 T0 구현 기준: PR #7 `agent/t0-combat-poc-board@659c57e7ffa588ad6a6471ed9b5394985b159eaf`.
- 최신 전투 승인 계보: Issue #13과 2026-07-24 사용자 승인.
- REPEAT_POC 기술 Goal: Issue #16 `CLOSED / COMPLETED`.
- 프로젝트 코어: `CORE_CONFIRMED`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 실제 사람 STEP 14: `DEFERRED_BY_USER / UNVERIFIED`.
- 현재 단계: `PLANNING_IN_PROGRESS — 프로젝트 전면 재감사·뾰족한 재미 강화`.

## 프로젝트 코어

```text
대전 격투식 수읽기·파훼
> 전술 퍼즐식 거리·순서
> 로그라이트 성장
```

### 현재 뾰족한 재미 가설

간파한 위험에 수를 걸고, 공개 순간 거리·합·대응이 맞아 상대 계획을 끊은 뒤, 그 근거를 복기해 다음 수에서 더 정확해지는 쾌감입니다.

이 문장은 `CORE_CONFIRMED` 상태지만 실제 플레이어 재미·이해도·시장 차별화 증거는 없습니다. 통합된 main을 기준으로 C 전면 재감사에서 보존·증폭·변경·삭제·재검증 여부를 다시 판정합니다.

### 보호 계약

- 1대1 무협 라이벌 결투.
- 10칸 일자형 전장, 플레이어 4번·상대 7번 시작.
- 비공개 `3수 → 3수 → 4수`, 총 10수.
- AI는 플레이어의 미확정 계획을 보지 않음.
- 덱·손패 없이 항상 사용할 수 있는 소수 공용 행동.
- 위치·순서·대응·파훼가 원시 피해량보다 우선.
- 결과 이유를 복기하고 다음 계획을 변경.

보호 계약을 변경하려면 별도 `CHANGE_PROPOSAL / USER_DECISION_REQUIRED`가 필요합니다.

## 현재 전투 계약

- 같은 칸 최대 2인, 거리 0 `[밀착]`.
- 기초 행동 8종: 이동·보법·막기·회피·속공·강공·명상·`[준비]`.
- 절초 3종: 십보 유파·단악결·파공검기.
- 2·3슬롯 행동의 실행 전 점유 수는 `[전조]`.
- 같은 실행 수 공격은 `[합]`으로 원공격력 차이를 정산.
- 방어도 차감 뒤 같은 수 반감, 회피, 파공검기 `[필중]`.
- 같은 수 미실행 행동 중단과 `[준비]` 기반 `[강건]`.
- `[준비]` 뒤 이동·보법은 강화 상태를 소비하지 않음.
- `[준비]` 뒤 명상은 절초 기세 +1, 최대 5.
- 모든 기초 카드와 절초는 가장 앞의 유효 연속 빈 구간에 자동 배치.
- 절초는 진행 전 취소 시 기세 5를 반환.
- 비용은 행동 슬롯·기력·내력·절초 기세이며 덱·손패·행동력·내공은 없음.

상세 판정은 [전투 규칙서](docs/02_COMBAT_RULES.md)가 책임집니다.

## 현재 기술 구현

```text
STEP 0~13 기본 전장·UI·배치·판정·종료·재시작
+ 이동 목적지·공격 방향
+ 대응·자원 미리보기
+ 밀착·중단·강건·절초 3종·순차 연출
+ 공개 상태 기반 라이벌 복수 후보 AI
+ 플레이어 가설 snapshot
+ 권위 결과 기반 결정적 복기
+ 복기 review gate
+ [준비]·[전조]·카드/절초 자동 배치
```

기술 상태:

- PR #35 closeout PR Validation #686: `PASS`.
- 통합 PR #41 PR Validation #687: `PASS`.
- 동일 제품 tree Full Validation #21: `PASS`.
- main과 최종 제품 branch changed files: `0`.
- main push-triggered Full Validation: `NOT_OBSERVED_VIA_CONNECTOR`.

자동·개발자 기술 증거는 실제 플레이어의 규칙 이해·라이벌 성향 발견·보조기기 사용성·주관적 음향/모션·재미·시장 적합성을 대체하지 않습니다.

## 현재 제품 범위

- T0/REPEAT_POC 기술 구현: 완료.
- 사람 플레이 증거: 사용자 결정으로 미실행.
- T1: 미승인.
- T2 5전 데모: 가설.
- 전체판 10전·세력·1~10성: 장기 가설.

기술 완료를 T1·MVP·재미 검증 완료로 해석하지 않습니다.

## 운영체계

- Work Mode: `PLAN / BUILD / REVIEW`.
- Base 활성 Skill은 원본에서 trigger에 따라 조건부 라우팅.
- 프로젝트 고유 Skill 4개 유지.
- 기획 문서와 Skill Registry는 `source_only`.
- 정본·경로·ID·Schema·Base SHA·Skill 집합은 reference freshness로 검사.
- GitHub Actions는 PR scope-aware 검증과 main·nightly·수동 Full Validation을 분리.

## C 전면 재감사

현재 작업은 기능 추가가 아니라 다음 질문을 다시 푸는 기획 단계입니다.

1. 누구를 위한 어떤 플레이 맥락인가?
2. 실제로 반복되는 한 가지 쾌감은 무엇인가?
3. 거리·순서·대응·복기 중 무엇이 그 재미를 증폭하거나 방해하는가?
4. 라이벌 읽기와 로그라이트 성장은 같은 게임을 만들고 있는가?
5. 유사 게임과 비교해 십보강호만의 설명 가능한 차별 원리는 무엇인가?
6. 다음 최소 PoC가 제거해야 할 가장 큰 불확실성은 무엇인가?

사용자가 명시적으로 `기획 완료`라고 선언하기 전에는 새 제품 기능 구현이나 Codex 인계로 넘어가지 않습니다.

## 책임 원본

- [게임 기획](docs/01_GAME_DESIGN.md)
- [전투 규칙](docs/02_COMBAT_RULES.md)
- [콘텐츠](docs/03_CONTENT_CATALOG.md)
- [제품 로드맵](docs/04_ROADMAP.md)
- [전투 POC](docs/05_COMBAT_POC_SPEC.md)
- [무공·심법](docs/06_STARTING_FACTION_MASTERY_DATA.md)
- [전투 UI](docs/07_COMBAT_UI_SPEC.md)
- [테스트](docs/08_TEST_CHECKLIST.md)
- [아키텍처](docs/09_COMBAT_SYSTEM_ARCHITECTURE.md)
- [연출](docs/10_COMBAT_PRESENTATION_PLAN.md)
- [Base 적용·학습](docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md)
