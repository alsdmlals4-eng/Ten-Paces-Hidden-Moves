# 십보강호 활성 컨텍스트

## 현재 기준

```yaml
project: 십보강호
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
platform: PC
product_stage: CONCEPT_APPROVAL
work_mode: PLAN
execution_profile: PLANNING_ONLY_PROFILE
runtime_implementation: PROHIBITED_UNTIL_NEW_APPROVAL
current_integration_pr: 65
canonical_decision_ledger: docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
latest_user_decision: docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md
current_design_package: docs/superpowers/specs/2026-07-31-procedural-duel-pool-route-design.md
current_design_package_status: APPROVED_PLANNING
current_review_package: docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md
current_review_package_status: DESIGN_DRAFT_USER_REVIEW_PENDING
integration_review: docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md
human_step14: NOT_RUN
```

PR #45의 과거 BUILD 승인 선언은 최신 사용자 결정으로 대체됐다. 이번 단계는 계획 정본과 Google Sheets GDD를 동기화하는 작업이며 런타임 구현 인계가 아니다.

역사 추적: 현행 T0 구현 계보는 PR #7과 Issue #13이며 STEP 14 사람 검증은 아직 실행하지 않았다. 현행 구현은 플레이어 4번·상대 7번 시작과 공개 상태 기반 AI를 사용한다. 과거 상태 `CORE_REVIEW_PENDING`은 역사 토큰일 뿐 현재 제품 단계나 코어 권한이 아니다.

## 프로젝트 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 뾰족한 재미: 계획을 세워 상대의 숨은 수를 읽고 파훼한다.
- 판매 문구: `보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.`
- 성장은 더 다양하고 강력한 파훼 방법을 제공한다.
- 원시 수치 상승은 판단을 대체하지 않는다.
- 새 시스템·핵심 규칙·콘텐츠 구조·UX 흐름은 벤치마킹을 먼저 수행한다.

## 현재 주요 계약

- 한 라운드: `3수 → 3수 → 4수`, 각 묶음 뒤 해결.
- 전장: 10칸 일자형, 거리 0 `[밀착]`.
- 공격과 막기는 고정 최종값이 아니라 캐릭터 `[공격력]`·`[방어력]`과 기술 계수·보정에 비례한다.
- `[연격 N]`: 총피해를 N개의 피해 단위로 분할하고 현재 순번 피해 단위끼리 순차 `[합]`한다.
- 합 패배·동점은 현재 타격만 취소·상쇄한다. 별도 `[중단]`이 없으면 후속타는 계속한다.
- 연격 중 방어도 적용 후 체력이 1 이상 감소해 `[중단]`되면 미실행 후속타를 전부 취소한다.
- 방어도가 피해를 전부 막아 체력 감소가 0이면 중단하지 않는다.
- `[강건]`은 피해를 유지한 채 중단 이벤트 1회를 막고 후속타를 계속하게 한다.
- 방어·보호막은 통합 `[방어도]`; 피해 단위마다 고정 감산하고 피격으로 소모되지 않으며 라운드 종료 시 제거한다.
- PoC 방어도는 합산 중첩, 초기 상한 10을 사용한다.
- 절초: 무공서 10성, 절초기세 5, 동일 슬롯 일반 기술보다 약 50% 높은 예산.
- 수련 체크포인트: 전체 전투 5회 40~50, 10회 90~100의 표준 경로 중앙 목표.
- 전투 랭크: A +0, A+ +1, S +2, S+ +3.

최신 전투·회차 결정은 `docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md`, 절차형 비무·경로 결정은 `docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md`가 소유한다. `docs/02_COMBAT_RULES.md`는 세부 판정 책임 원본이며 충돌 시 최신 날짜의 승인 결정 문서가 우선한다.

## 데모·전체 회차 계약

```yaml
demo:
  major_duels: 5
  duel_candidates_per_slot: 3
  gaps: 4
  nodes_per_gap: 2
  intermediate_nodes: 8
  target_playtime: 15_to_22_minutes

full_run:
  major_duels: 10
  duel_candidates_per_slot: 3
  gaps: 9
  nodes_per_gap: 2
  intermediate_nodes: 18
  target_playtime: 30_to_40_minutes
```

- 주요 비무 슬롯은 학습 역할과 난이도 단계만 고정한다.
- 각 슬롯은 후보 3명을 보유한다.
- 첫 비무는 후보 3명 중 1명을 `run_seed`로 선정한다.
- 이후 비무는 후보 3명 중 2명을 경로 종착점으로 제시하고 플레이어가 선택한다.
- 비무 사이 첫 노드는 상태 회복·성장, 둘째 노드는 다음 비무 정보·대비 역할을 우선한다.
- 실제 노드·연결선·다음 상대 후보는 `run_seed`, `slot_id`, `gap_index`로 재현 가능하게 생성한다.
- 첫 데모 노드 유형은 휴식·수련·정보·짧은 사건으로 제한한다.
- 일반 전투 노드는 첫 데모 필수 범위에서 제외한다.

## 현재 상세 기획 패키지

`TEN-DEC-20260731-PROCEDURAL-DUEL-POOL-01`은 다음 구조를 승인한다.

```text
슬롯 1 후보 3명 중 1명
→ 절차 생성 1차 노드층
→ 절차 생성 2차 노드층
→ 슬롯 2 후보 3명 중 제시된 2명 가운데 선택
```

### 슬롯 1 — 합·거리 입문

- 연교 — 사문검객
- 백소령 — 유운검수
- 진무백 — 철선문도

### 슬롯 2 — 방어도·중단 입문

- 묵진 — 철벽승
- 하진강 — 진산권객
- 위청람 — 현문도객

기존 `TEN-PKG-20260731-DUEL01-02-ROUTE01`의 연교·묵진 상세 패턴은 후보 원형으로 재사용하지만, 고정 상대·고정 경로 표현은 최신 결정으로 대체된다.

## 상황별 인게임 화면 구현 명세 중간점검

`TEN-SIT-SPEC-20260731-01`은 프로젝트 문서와 실제 Godot 파일을 대조한 사용자 검토용 초안이다.

- 실제 시작 Scene은 `res://scenes/combat/combat_board_preview.tscn`이며 제품용 Main·Route·Result 흐름은 아직 확인되지 않았다.
- 실제 전투 PoC에는 10칸 전장, 상단 HUD, 3/3/4 슬롯, 카드 Tray, 상세, 로그, 상대 가설, 결정적 복기 UI가 존재한다.
- 전통적 인벤토리 대신 `무공 구성·성급·해금 기술·보유 자원·대비 효과` 화면을 대응 기준 화면으로 정의한다.
- P0 상황은 Main 진입, 시작 무공, Route, Node, Briefing, Combat Plan, Resolve, Review, Victory Reward, Defeat Retry로 분해한다.
- Route와 Combat은 별도 Scene, Combat Review는 같은 Scene Overlay, Duel Result는 별도 Scene을 권장한다.
- P0 Autoload 후보는 `RunSession`, `SaveService`로 최소화하며 CombatState는 Combat Scene이 소유한다.
- 현재 `CombatBoardPreview`의 판정 엔진과 UI 부품은 재사용하되 화면 조립·입력·연출·오디오·재시작 책임은 단계적으로 분리한다.
- 구조화 초안은 `docs/planning-data/draft_20260731_situation_screen_contract.json`에 기록한다.
- 상태는 `DESIGN_DRAFT_USER_REVIEW_PENDING`; 구현 승인·Codex 인계가 아니다.

## 천하제일인 후속 콘텐츠

본편 주요 비무 1~10과 일반 엔딩 후 플레이 성향에 대응하는 후보 한 명의 도전장이 열린다. 첫 승리 후 나머지 후보를 선택할 수 있고 `등록 전투 구성`의 `Champion Build Snapshot` 등록 자격을 획득한다.

초기 후보:

- 무림맹주 — 정석과 종합 능력
- 천마 — 압박과 주도권
- 개방 태상장로 — 경험·정보·변칙
- 만상기인 — 여러 무공 조합
- 천외일검 — 한 수의 합과 중단
- 무극도존 — 자원과 거리의 균형

천하제일인·비동기 챔피언 배틀은 첫 데모 범위가 아니다.

## `[보류]`

- Round 4 이후 전체 적대적 검토.
- 16권 절초의 개별 이름·효과·슬롯·태그·대응점.
- 주요 비무 6~10의 선제 구현.
- 천하제일인·서버·비동기 챔피언 배틀 구현.
- 2026-07-26 구현 계획 실행.
- Godot 런타임·데이터·씬·자산 변경.

`[보류]`는 결정 행에서는 `DEFERRED`, 게이트에서는 `HOLD`로 기록한다.

## PR #45 자산 지위

- 최신 권한 원장: `2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- 전투·강호행로 결정: `2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md`.
- 절차형 비무·경로 결정: `2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md`.
- 절차형 설계 명세: `docs/superpowers/specs/2026-07-31-procedural-duel-pool-route-design.md`.
- 화면·상황 구현 명세 중간점검: `docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md`; 사용자 검토 대기.
- 기존 고정 패키지: `2026-07-31_DUEL_01_02_ROUTE_PACKAGE_DRAFT.md`; 후보 원형 자료로 유지.
- 2026-07-26 기획·BUILD 진입 문서: `SUPERSEDED_REFERENCE`.
- 과거 적대적 검토·벤치마크·sanity: `HISTORICAL_EVIDENCE`.
- `docs/planning-data/`: `SOURCE_ONLY / HOLD`; 승인된 기획 데이터 동기화와 사용자 검토용 초안만 허용.
- 2026-07-26 구현 계획: `DEFERRED / REFERENCE_ONLY`.
- 제품 런타임: 이번 동기화에서 변경하지 않음.

## 다음 작업

먼저 `TEN-SIT-SPEC-20260731-01`의 필수 화면 4종, P0 상황, Scene 분리, 상태 소유권, Vertical Slice 순서를 사용자 검토한다. 승인 또는 수정 뒤 주요 비무 슬롯 3의 후보 3명과 슬롯 2→3 사이 절차형 노드 풀 상세화로 복귀한다. 사용자의 명시적 `기획 완료`와 `검수 완료` 전에는 Codex Build로 전환하지 않는다.
