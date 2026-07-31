# 십보강호 활성 컨텍스트

## 현재 기준

```yaml
project: 십보강호
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
platform: PC
product_stage: COMBAT_UX_BUILD
work_mode: BUILD
execution_profile: IMPLEMENTATION_PROFILE
runtime_implementation: ACTION_SELECTION_DOCK_BUILD_PR
current_integration_pr: 66
integration_base_pr: 65
canonical_decision_ledger: docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md
latest_user_decision: docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md
current_design_package: docs/superpowers/specs/2026-08-01-action-selection-dock-design.md
current_design_package_status: IMPLEMENTED_BUILD_PR_VALIDATION_PENDING
current_implementation_plan: docs/superpowers/plans/2026-08-01-action-selection-dock.md
current_implementation_branch: agent/2026-08-01-action-selection-dock-build
current_review_package: docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md
current_review_package_status: DESIGN_DRAFT_USER_REVIEW_PENDING
integration_review: docs/decisions/2026-07-28_V6_PR45_INTEGRATION_REVIEW.md
static_pr_validation: PASS
base_v9_validation: PASS
godot_full_validation: PENDING
windows_validation: NOT_RUN
human_step14: NOT_RUN
```

PR #45의 과거 BUILD 승인 선언과 PR #65의 PLAN 전용 상태는 최신 사용자 BUILD 승인으로 대체됐다. 현재 구현 범위는 전투 PoC의 행동 선택 Dock과 수 배치 UX이며, 전체 5전 회차·강호행로·성장·보상 구현 승인을 의미하지 않는다.

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

### 행동 선택·수 배치 제품 계약

- 전투 행동 출처는 `[기초] [무공] [절초]` 세 범주다.
- 기초 행동 8종은 무공서와 독립된 공용 행동군이다.
- 무공서는 성장·분류 단위이며 직접 수에 배치하지 않는다.
- 무공서에서 현재 해금된 기술만 실제 행동으로 배치한다.
- 세 출처 모두 현재 묶음의 가장 앞 유효 연속 수에 자동 배치한다.
- 2수·3수 행동은 슬롯별 중복 카드가 아니라 `[전조] → [실행]` 하나의 연결 블록이다.
- 진행 전 연결 블록 전체를 이동·제거할 수 있고 묶음 경계를 넘지 않는다.
- 절초기세는 공유 `0~5`; 배치 성공 시 예약하고 진행 전 제거 시 환불한다.
- 제품 P0에서는 `준비+막기/회피` 가상 카드를 생성하지 않는다.
- `docs/planning-data/*.json`은 런타임에서 직접 읽지 않는다.

최신 전투·회차 결정은 `docs/decisions/2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md`, 절차형 비무·경로 결정은 `docs/decisions/2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md`, 행동 선택 결정은 `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`가 소유한다. `docs/02_COMBAT_RULES.md`는 세부 판정 책임 원본이며 충돌 시 최신 날짜의 승인 결정 문서가 우선한다.

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
- 실제 전투 PoC에는 10칸 전장, 상단 HUD, 3/3/4 슬롯, 로그, 상대 가설, 결정적 복기 UI가 존재한다.
- 제품 전투 행동 영역은 PR #66에서 `ActionSelectionDock`으로 전환 중이며 레거시 카드 Tray·독립 절초 목록·상세 패널은 숨김 호환 경로다.
- 전통적 인벤토리 대신 `무공 구성·성급·해금 기술·보유 자원·대비 효과` 화면을 대응 기준 화면으로 정의한다.
- P0 상황은 Main 진입, 시작 무공, Route, Node, Briefing, Combat Plan, Resolve, Review, Victory Reward, Defeat Retry로 분해한다.
- Route와 Combat은 별도 Scene, Combat Review는 같은 Scene Overlay, Duel Result는 별도 Scene을 권장한다.
- P0 Autoload 후보는 `RunSession`, `SaveService`로 최소화하며 CombatState는 Combat Scene이 소유한다.
- 현재 `CombatBoardPreview`의 판정 엔진과 UI 부품은 재사용하되 화면 조립·입력·연출·오디오·재시작 책임은 단계적으로 분리한다.
- 구조화 초안은 `docs/planning-data/draft_20260731_situation_screen_contract.json`에 기록한다.
- 상황별 전체 화면 명세는 `DESIGN_DRAFT_USER_REVIEW_PENDING`; 행동 선택 Dock만 별도 승인·BUILD 상태다.

## 행동 선택 Dock 구현 패키지

```yaml
spec: docs/superpowers/specs/2026-08-01-action-selection-dock-design.md
plan: docs/superpowers/plans/2026-08-01-action-selection-dock.md
build_approval: docs/implementation/BUILD_APPROVAL_2026-08-01.md
branch: agent/2026-08-01-action-selection-dock-build
pull_request: 66
status: IMPLEMENTED_BUILD_PR_VALIDATION_PENDING
static_contract: PASS
pr_validation: PASS
base_v9_validation: PASS
godot_full_validation: PENDING
windows_validation: NOT_RUN
human_validation: NOT_RUN
```

실제 제품 입력 경로는 `ActionSelectionDock → ActionPlacementController → ActionTimingPanelAuto → CombatResolutionEngine`이다. 무공서 직접 배치와 제품 경로의 가상 `준비+대응` 카드는 정적 계약으로 차단한다.

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
- 전체 5전 회차·강호행로·성장·보상·저장 구현.
- 행동 선택 Dock 외 제품 Scene·자산 변경.

`[보류]`는 결정 행에서는 `DEFERRED`, 게이트에서는 `HOLD`로 기록한다.

## PR 자산 지위

- 최신 권한 원장: `2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`.
- 전투·강호행로 결정: `2026-07-31_COMBAT_ROUTE_AND_CHAMPION_DECISION.md`.
- 절차형 비무·경로 결정: `2026-07-31_PROCEDURAL_DUEL_POOL_AND_ROUTE_DECISION.md`.
- 행동 선택 결정: `2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`.
- 절차형 설계 명세: `docs/superpowers/specs/2026-07-31-procedural-duel-pool-route-design.md`.
- 행동 선택 설계·구현: `docs/superpowers/specs/2026-08-01-action-selection-dock-design.md`, PR #66.
- 화면·상황 구현 명세 중간점검: `docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md`; 사용자 검토 대기.
- 기존 고정 패키지: `2026-07-31_DUEL_01_02_ROUTE_PACKAGE_DRAFT.md`; 후보 원형 자료로 유지.
- 2026-07-26 기획·BUILD 진입 문서: `SUPERSEDED_REFERENCE`.
- 과거 적대적 검토·벤치마크·sanity: `HISTORICAL_EVIDENCE`.
- `docs/planning-data/`: `SOURCE_ONLY / HOLD`; 승인된 기획 데이터 동기화와 사용자 검토용 초안만 허용.
- 2026-07-26 구현 계획: `DEFERRED / REFERENCE_ONLY`.
- 제품 런타임: 행동 선택 Dock 범위만 PR #66에서 변경 중.

## 다음 작업

PR #66의 정확한 최종 HEAD에서 Full Validation을 실행해 Godot 4.7.1 import·기존 회귀·새 행동 선택 검증 10종을 확인한다. 실패 시 해당 Task 범위에서 수정하고, 통과 후 Windows 1280×800 수동 확인과 STEP 14 사람 플레이를 별도 실행한다. 전체 5전 회차·강호행로·성장 구현은 별도 승인 전 시작하지 않는다.
