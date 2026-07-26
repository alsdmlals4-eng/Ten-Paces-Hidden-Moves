# 십보강호: 숨은 수의 비무
## Ten Paces: Hidden Moves

짧은 연속 비무를 통해 여러 무공을 습득·수련하고, 해금된 소수의 기술을 기초 행동과 자유롭게 조합하여 매 회차 자신만의 무학 체계를 완성하는 **무협 전술 로그라이트**입니다.

> 짧은 비무에서 수를 읽고, 전투 사이에 무학을 키우며, 이번 회차만의 무공 체계를 완성한다.

## 시작

- [작업 시작](START_HERE.md)
- [현재 상태]([기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md)
- [통합 기획 기준선](docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md)
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

- 현재 기획·검수 PR: #45 `agent/poc-planning-baseline-and-legacy-audit`.
- 현재 기획 기준: `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`.
- 전체 적대적 검토: `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md`.
- Base: `41a20584dd2ee51d917e5c9d7cab6838e1ceba7e`.
- 제품 게이트: `REPEAT_POC`.
- T1 진입: `NOT_GRANTED`.
- 실제 사람 STEP 14: `NOT_RUN / UNVERIFIED`.
- 현재 단계: `REVIEW_IN_PROGRESS`.
- REVIEW BUILD 범위: 정본·planning Schema·validator·회귀 테스트만 교정; 제품 런타임 미변경.

사용자의 명시적 `검수 완료` 전에는 Codex 런타임 인계나 새 제품 기능 구현으로 넘어가지 않습니다.

## 프로젝트 코어

```text
짧은 연속 비무
→ 무공 습득·수련·기술 해금
→ 기초 행동과 기술 조합
→ 현재 무학으로 적 계획 파훼
→ 복기로 다음 성장·운용 변경
```

상대의 공개 상태와 실제 전투 결과를 읽는 과정은 각 조우의 전술 축이며, 장기 라이벌 학습은 거시 제품 전제에서 후순위입니다.

### 보호 계약

- 1대1 무협 비무.
- 10칸 일자형 전장, 플레이어 4번·상대 7번 시작.
- 한 라운드는 비공개 `3수 → 3수 → 4수`, 총 10수.
- 같은 수의 유효 공격은 `[합]`으로 원공격력 차이를 판정.
- AI는 플레이어의 미확정 계획을 보지 않음.
- 덱·손패 없이 기초 행동과 해금 기술을 항상 사용 가능.
- 위치·순서·대응·파훼가 원시 피해량보다 우선.
- 전투 사이 무공 습득·수련·기술 해금으로 회차 빌드 진화.
- 결과 이유를 복기하고 다음 계획과 수련을 변경.

보호 계약을 변경하려면 별도 `CHANGE_PROPOSAL / USER_DECISION_REQUIRED`가 필요합니다.

## 승인된 회차 구조

- `10전`은 총 전투 10회가 아니라 필수 주요 비무·강적 조우 10개.
- 연속한 주요 비무 사이에 실제 방문 중간 노드 2~3개를 배치.
- 실제 총 전투 수는 경로에 따라 10보다 많음.
- 주요 비무 5 이전에 한 무공 10성 또는 동급 광역 빌드 가능.
- 시작 무공서 4개를 3성으로 선택해 기술 4개로 시작.
- 수련도 3·7성에서 기술, 5·9성에서 기존 기술 강화, 10성에서 절초·진의.
- 해금 기술은 덱·손패·장착 제한 없이 항상 사용 가능.

세부 성장·보상·금전·문파·관찰 기준은 [통합 기획 기준선](docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md)과 `docs/planning-data/`가 책임집니다. 주요 비무 보상은 자유 수련6, 지정 무공5+자유3, 문파 무공3성 중 하나이며 자유도가 낮을수록 총 가치가 높습니다.

## 승인된 전투 기준

### 라운드와 자원

- 승패가 날 때까지 `3수 → 3수 → 4수` 라운드 반복.
- 강제 라운드 제한·3라운드 판정승·피로 피해 없음.
- 일반전 대부분 3라운드 이내 종료는 밸런스 목표.
- 체력은 전투 사이 유지.
- 전투 시작 기력 5, 내력 5, 절초 기세 0/5.
- 라운드 시작 기력 +1, 내력 자연 회복 없음.
- 일반 명상: 기력 +1·내력 +1.
- 승리 후 체력 회복: `min(잃은 체력, 2 + [의료])`, `[의료]` 0~4.

### 기본 능력치와 행동

```yaml
maximum_health: 30
attack_power: 4
defense: 5
```

- 속공: 1슬롯, 기력 1, 피해 `[공격력]` = 4.
- 강공: 2슬롯, 기력 1·내력 1, `전조 → 공격`, 피해 `2×[공격력]+2` = 10.
- 막기: 기력 1, 실행 시 `[방어도]`만큼 방어도 5 누적.
- 방어도는 피해를 흡수한 만큼 감소하고 라운드 종료 시 0.
- 회피: 기력 1, 기본 1회, 타격 1회 회피.
- 회피 횟수 N은 현재 수부터 N개의 행동 수 동안 유지.

### 상태와 다중 슬롯

- 태세 사용 시 `[강화]`와 `[강건]` 획득.
- `[강화]`: 다음 공격 계산 결과 `×1.5`.
- `[강건]`: 체력 피해로 인한 중단 1회 방지.
- 다중 슬롯 행동은 첫 전조에서 자원과 `[강화]`를 전액 선지불.
- 중단 시 자원·`[강화]`·점유 슬롯 환불 없음.
- 슬롯 성능 예산: 1슬롯 `1.0`, 2슬롯 `2.5`, 3슬롯 `4.0`.

상세 최신 판정은 [전투 규칙서](docs/02_COMBAT_RULES.md)가 책임지고, 수치·ID·Schema는 `docs/planning-data/`가 소유합니다.

## 승인된 실패·보상 계약

- 전투 패배 시 전투 직전 `RunState`를 복원해 같은 seed로 재도전할 수 있다.
- 같은 전투 재도전 비용은 `[영구재화]` 1→2→3개이며 3에서 상한, 다른 전투 진입 시 1로 초기화한다.
- `[영구재화]` 부족 시 회차 포기 또는 타이틀 복귀만 허용한다.
- `[필중]`은 스택형이다. 실제 회피 판정에서 회피를 무시한 유효 타격마다 1스택을 소비하며 취소·중단·대상 부재·사거리 실패·회피 부재에는 소비하지 않는다.
- 주요 비무 1~4에서 지정 무공5+자유3을 같은 무공에 투자하면 32, 중간 노드 최소 집중 수련6을 더해 주요 비무5 진입 전에 38을 확보할 수 있다.

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
+ 과거 [준비]·[전조]·카드/절초 자동 배치 구현
```

기술 구현은 최신 승인 기획보다 앞선 PoC 규칙을 포함합니다. `검수 완료` 전에는 제품 코드를 새 규칙으로 변경하지 않습니다.

기술 상태:

- PR #35 closeout PR Validation #686: `PASS`.
- 통합 PR #41 PR Validation #687: `PASS`.
- 동일 제품 tree Full Validation #21: `PASS`.
- main과 최종 제품 branch changed files: `0`.
- main push-triggered Full Validation: `NOT_OBSERVED_VIA_CONNECTOR`.

자동·개발자 기술 증거는 실제 플레이어의 규칙 이해·재미·사용성·시장 적합성을 대체하지 않습니다.

## 운영체계

- Work Mode: `PLAN / BUILD / REVIEW`.
- Base 활성 Skill은 원본에서 trigger에 따라 조건부 라우팅.
- 프로젝트 고유 Skill 4개 유지.
- 기획 문서와 Skill Registry는 `source_only`.
- 정본·경로·ID·Schema·Base SHA·Skill 집합은 reference freshness로 검사.
- GitHub Actions는 PR scope-aware 검증과 main·nightly·수동 Full Validation을 분리.

## 책임 원본

- [승인 기획 기준선](docs/decisions/2026-07-25_PROJECT_REASSESSMENT_APPROVED_PLANNING_BASELINE.md)
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
