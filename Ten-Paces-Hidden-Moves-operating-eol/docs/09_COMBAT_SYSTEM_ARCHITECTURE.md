# 십보강호 전투 시스템 아키텍처

> 책임: 실제 파일·상태·AI·판정·표현·재시작 경계와 최신 기획 데이터 인수 구조  
> 규칙 원본: `docs/02_COMBAT_RULES.md`  
> 현재 기술 계보 기준: `659c57e7ffa588ad6a6471ed9b5394985b159eaf`

## 1. 아키텍처 원칙

10칸·4/7 시작 위치와 비공개 3/3/4 계획 구조를 공용 엔진 계약으로 유지한다.

```text
런타임 JSON·입력
→ 계획·대상·자원 검증
→ CombatAiPlanner 공개 후보
→ CombatResolutionEngine 단일 판정
→ state + timing_results + presentation_events + logs
→ CombatBoardPreview·HUD·VFX·SFX 표현
```

계산은 도메인, 표현은 UI에 둔다. 현재 구현은 Dictionary 기반이며 새 PoC 기획 JSON을 직접 읽지 않는다.

## 2. 실제 파일 책임

- `data/cards/basic_cards.json`, `ultimate_cards.json`: 현재 구형 런타임 행동.
- `data/combat/*.json`: 전장·HUD·판정·AI preview 계약.
- `src/combat/combat_resolution_engine.gd`: 상태·비용·합·피해·중단·기세·이벤트.
- `src/combat/combat_ai_planner.gd`: `CombatAiPlanner` 공개 snapshot·후보·seed·trace.
- `src/combat/combat_board_preview.gd`: 씬·입력·순차 표현·`restart_combat()`.
- `src/ui/`: 슬롯·HUD·로그·포커스.
- `tests/`: 현재 구현 회귀.

## 3. 편집 가능한 기획 데이터

`docs/planning-data/*.json`은 `NON_RUNTIME_POC_PLANNING`이다. 후속 구현은 다음 adapter를 명시적으로 만든다.

```text
planning budget/manual/duel/map/run-state JSON
→ schema validation
→ runtime card/status/enemy/run data
→ engine consumers
```

기획 파일을 런타임에서 암묵적으로 직접 읽지 않는다.

## 4. 현재 `CombatState`와 `RunState`

`RunState`는 회차 생존과 진행을 소유한다: run ID/seed, 현재·방문 노드, 이월 체력, 금전, 무공별 성급, 해금 기술, `[의료]`, 현재 전투 ID, 같은 전투 재도전 횟수. `[영구재화]`는 `RunState` 밖의 permanent profile이 소유한다.

`CombatState`는 한 전투의 판정만 소유한다: round/bundle, 위치, 체력, 기력, 내력, 기세, 누적 방어도, 회피 스택, 필중 스택, 강건 스택, 임시 상태, 확정 행동·타격 진행·효과 소비 기록.

```text
RunState + BattleDefinition
→ PRE_BATTLE_RUN_STATE snapshot
→ CombatState 생성
→ 승리: 체력·회복·보상·노드 진행을 RunState에 1회 commit
→ 패배 재도전: 영구재화 결제 후 snapshot 복원·동일 seed 재생성
```

전투 진입 시 기력·내력은 최대, 기세0, 임시 상태 clear, 위치는 battle definition을 사용한다. 패배 전투의 피해·임시 자원·미획득 보상은 롤백하지만 영구재화 결제는 permanent profile에 남는다.

## 5. 공개 상태 라이벌 후보 AI 경계

현재 시그니처 `CombatAiPlanner.build_bundle_actions(...)`와 결정적 seed 원칙을 유지한다. 입력 whitelist만 사용하고 미확정 계획을 금지한다. 적 데이터의 public_tells·phase_change·candidate_actions를 runtime profile로 변환한다.

현행 운영 토큰: `enemy_plan_source=public_state_ai`. `enemy_bundles` fixture는 `ai_enabled == false`인 명시적 테스트 경로에서만 허용한다.

## 5.1 정규화 card·AI 계약

무공 행동 adapter는 `category`, `resolution_phase`, `targeting_mode`, `attack.damage_model/raw_powers/range`, `movement.timing/mode/max_tiles`를 필수 입력으로 받는다. 중앙 `price_id × quantity` ledger를 다시 계산해 위조된 tick을 거부한다.

AI profile은 숫자 score window·weights·조건 modifier·정확히 3수인 bundle template·timing/targeting·fallback을 소유한다. 현행 한 행동 반환 구현은 새 adapter에서 template 전체를 action 배열로 변환해야 하며 미확정 플레이어 계획을 읽지 않는다.

## 6. 묶음 판정과 반환 구조

각 공격 행동은 `hits[]`를 가진다. 같은 수 공격은 hit index별로 짝짓고 다음 이벤트를 만든다.

```text
attack_action_started
action_start_effect_triggered
hit_pair_clash | unmatched_hit
clash_win_effect_triggered
hit_evaded
evade_success_effect_triggered
defense_absorbed
health_damage_applied
hit_effect_triggered | health_damage_effect_triggered
interrupt_attempted
fortitude_consumed
action_followups_cancelled
combatant_defeated
action_end_effect_triggered
attack_action_finished | non_attack_action_resolved
```

`timing_results`는 각 이벤트 뒤 snapshot을 제공하고, `presentation_events`는 동일 ID와 순서를 사용한다.

## 7. 순차 표현 상태

`planning → committed → resolving → presenting_result → next_bundle_ready | combat_ended`. 빠른 재생·즉시 완료는 큐 대기만 줄이고 결과를 바꾸지 않는다.

## 8. 종료·재시작과 유료 재도전

현행 `restart_combat()`은 T0 개발용 완전 초기화로 유지한다. PoC 회차에서는 노출하지 않고 `RunState` retry service가 전투 직전 snapshot·영구재화 1/2/3 결제·동일 seed 복원을 담당한다. 반복 재도전에서 보상·노드 진행·signal·로그·효과 소비가 중복되거나 영구재화가 롤백되면 실패다.

## 9. 검증 경계

- planning JSON 정적 검증.
- runtime adapter 단위 테스트.
- 단일·연격·중단·강건·7개 효과 trigger 반례.
- 기본 절초 시작 가용성과 무공 10성 절초의 성급 기반 해금.
- `timing_results`와 `presentation_events` 순서 일치.
- AI 비공개 입력 부재.
- 유료 재도전 snapshot 복원·영구재화 비롤백·보상 1회 commit.
- T0 개발용 재시작과 PoC 회차 재도전 분리.

전체 다음 PoC 아키텍처는 아직 `AUTHORED_NOT_IMPLEMENTED`다. 단, 행동 선택·수 배치 제품 UX는 아래 범위로 PR #66에서 구현 중이다.

## 10. 행동 선택 Dock 구현 경계

```text
ActionSelectionDock
├─ BasicActionPanel
├─ MartialActionPanel
│  └─ 무공서 → 해금 기술
├─ UltimateActionPanel
└─ ActionDetailPanel
        │
        ▼
ActionPlacementController
        │
        ▼
ActionTimingPanelAuto
├─ earliest valid contiguous placement
├─ linked `[전조] → [실행]` block
├─ connected-block repositioning
└─ target/direction handoff
        │
        ▼
CombatResolutionEngine
```

### 10.1 책임

- `ActionViewModelAdapter`: 기초·무공·절초 런타임 정의를 하나의 UI schema로 정규화하고 원본 판정 필드를 보존한다.
- `ActionSelectionDock`: `[기초] [무공] [절초]` 탭, 활성 패널, 입력 잠금, 상세 패널을 소유한다.
- `MartialActionPanel`: 무공서를 탐색하지만 `technique_selected`만 배치 요청으로 방출한다. 무공서는 직접 배치하지 않는다.
- `ActionPlacementController`: 선택→자동 배치→대상 지정, 실패 코드, 제거·재배치, 절초 예약·환불 조정을 소유한다.
- `ActionTimingPanelAuto`: 기존 3/3/4 배치 Dictionary를 유지하면서 연결 블록 표현과 원자적 이동 API를 제공한다.
- `LinkedActionBlock`: 기술명·출처·전조·실행·Focus·키보드 이동·제거 요청을 표시한다.
- `CombatBoardPreviewAuto`: 전투 오케스트레이션을 유지하고 제품 Dock과 Controller를 연결한다.

### 10.2 데이터 경계

```text
data/cards/basic_cards.json
+ data/cards/ultimate_cards.json
+ data/combat/action_selection_poc.json
+ data/combat/mastery_ultimate_poc.json
→ ActionViewModelAdapter
→ ActionSelectionDock
```

- `docs/planning-data/*.json`은 런타임에서 직접 읽지 않는다.
- `data/cards/ultimate_cards.json`은 canonical 기본 절초 3종만 유지한다.
- 무공 10성 절초 UI 검증 자료는 별도 PoC runtime fixture에 둔다.
- UI adapter는 원본 행동 Dictionary를 복제한 뒤 표시 필드를 추가하므로 판정 필드를 제거하지 않는다.

### 10.3 상태·잠금 경계

- 새 전투: `기초` 탭으로 초기화.
- 다음 묶음: 마지막 탭과 선택 무공서를 유지.
- 대상 지정·확정·해결·결과 연출·복기: Dock 편집 잠금.
- 진행 전: 연결 블록 전체 이동·제거 가능.
- 진행 후: 이동·제거·절초 환불 불가.
- 절초 재배치: 기존 예약 환불 후 새 anchor에 즉시 재예약해 최종 기세 상태를 유지.

### 10.4 레거시 호환

기존 `BasicCardTray`, 독립 절초 목록, `CardDetailPanel`은 기존 회귀 소비자를 위해 남겨두지만 제품 전투 화면에서는 숨긴다. `CardDetailPanel`은 `ActionDetailPanel`의 호환 wrapper다. 제품 경로에서는 `준비+막기/회피` 가상 카드를 생성하지 않는다.

### 10.5 검증 상태

```yaml
implementation_branch: agent/2026-08-01-action-selection-dock-build
pull_request: 66
static_contract: PASS
pr_validation: PASS
base_v9_validation: PASS
godot_full_validation: PENDING
windows_validation: NOT_RUN
human_validation: NOT_RUN
```
