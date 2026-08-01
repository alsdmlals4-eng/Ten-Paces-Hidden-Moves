# 십보강호 활성 컨텍스트

## 현재 기준

```yaml
project: 십보강호: 숨은 수의 비무
repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
platform: PC
engine: Godot 4.7
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
current_integration_pr: 65
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
latest_implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
latest_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
action_selection_automated_validation: PASS
situation_screen_architecture: APPROVED_PLANNING
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
base_release_pinned: 9.1.0
base_remote_reviewed: a82976a3a42450ea413cdc5d4aebf701678110d8
base_v9_3_migration: SEPARATE_FOLLOWUP
```

## 현재 프로젝트 코어

> 상대의 다음 행동 단서를 모아 가설을 세우고 여러 수의 계획으로 의도를 무너뜨리는 무협 전술 로그라이트.

- 뾰족한 재미: 계획을 세워 상대의 숨은 수를 읽고 파훼한다.
- 판매 문구: `보이지 않는 상대의 수를 읽고, 준비한 계획으로 꺾는다.`
- 1대1 10칸 일자형 전장과 거리 0 `[밀착]`.
- 한 라운드: `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 상대 AI는 플레이어의 미확정 계획을 읽지 않는다.
- 덱·손패·드로우·장착 기술 제한을 사용하지 않는다.
- 성장은 판단을 대체하지 않고 더 다양한 파훼 수단을 제공한다.

## 최신 승인·구현

### 행동 선택 Dock

Decision: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`

```text
[기초]
[무공] → 무공서 → 현재 해금 기술
[절초]
→ 가장 앞 유효 연속 수 자동 배치
→ 대상·방향 지정
→ 진행 전 연결 블록 이동·제거
→ 진행 후 잠금·해결
```

- 무공서는 성장·분류 단위이며 직접 배치하지 않는다.
- 2수·3수 행동은 `[전조] → [실행]` 하나의 연결 블록이다.
- 절초기세는 공유 `0~5`; 배치 성공 시 예약하고 진행 전 제거·이동 시 환불·재예약한다.
- 제품 P0에서 가상 `준비+막기/회피` 카드를 사용하지 않는다.
- 실제 경로: `ActionSelectionDock → ActionPlacementController → ActionTimingPanelAuto → CombatResolutionEngine`.
- 포인터 Drop 누락은 RED 회귀 뒤 수정됐다.
- 검증 구현 HEAD `673c209017ffe3e1c7ef2a89849ca4ea0846d1c5`: PR Validation #993, Base v9 #106, Full Validation #73 `PASS`.
- Windows 실제 Godot·실물 게임패드·사람 이해도는 `NOT_RUN`이다.

상세:

- `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`
- `docs/superpowers/specs/2026-08-01-action-selection-dock-design.md`
- `docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`

### 상황별 화면·제품 흐름

Decision: `TEN-DEC-20260801-SITUATION-SCREEN-01`

- 필수 기준 화면: 메인 / 비무 / 무공 구성·자원 / 결과·복기·보상.
- P0 상황: Main, Run Setup, Route, Node, Briefing, Combat Plan, Resolve, Review, Victory Reward, Defeat Retry.
- Route와 Combat은 별도 Scene이다.
- Combat Review는 같은 Combat Scene Overlay다.
- Duel Result는 별도 Scene이다.
- P0 Autoload 후보는 `RunSession`, `SaveService`; `CombatState`는 Combat Scene 소유다.
- 전체 제품 흐름 런타임은 아직 시작하지 않았다.

상세:

- `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`
- `docs/superpowers/specs/2026-07-31-situation-screen-implementation-spec.md`
- `docs/planning-data/approved_20260801_situation_screen_contract.json`

## 전투·회차 계약

- 공격과 막기는 캐릭터 `[공격력]`·`[방어력]`과 기술 계수·보정에 비례한다.
- `[연격 N]`은 현재 순번 피해 단위끼리 순차 `[합]`한다.
- 합 패배·동점은 현재 타격만 취소·상쇄한다.
- 방어도 적용 후 체력이 1 이상 감소해 `[중단]`되면 미실행 후속타를 취소한다.
- 방어도가 피해를 전부 막으면 중단하지 않는다.
- `[강건]`은 중단 이벤트 1회를 막는다.
- 방어·보호막은 통합 `[방어도]`; 피해 단위마다 감산하고 피격으로 소모되지 않으며 라운드 종료 시 제거한다.
- PoC 방어도는 합산, 초기 상한 10이다.

```yaml
demo:
  major_duel_slots: 5
  candidates_per_slot: 3
  gaps: 4
  nodes_per_gap: 2
  intermediate_nodes: 8
  target_playtime: 15_to_22_minutes
full_run:
  major_duel_slots: 10
  candidates_per_slot: 3
  gaps: 9
  nodes_per_gap: 2
  intermediate_nodes: 18
  target_playtime: 30_to_40_minutes
```

- 첫 비무는 후보 3명 중 1명을 seed 기반 선정한다.
- 이후 비무는 후보 3명 중 2명을 경로 종착점으로 제시한다.
- 생성 결과는 `run_seed`, `slot_id`, `gap_index`로 재현 가능해야 한다.
- 15명 전체 계약은 유지하되 첫 파이프라인 구현은 슬롯별 대표 후보 1명으로 제품 흐름을 먼저 증명한다.

## 현재 다음 작업

### `VERTICAL_SLICE_APP_FLOW_SHELL`

1. App Root와 화면 상태 전환.
2. Main Menu 저충실도 Shell.
3. `RunSession`·`SaveService` 최소 계약.
4. 시작 무공 6중4 선택 Shell.
5. Route→Node→Briefing 저충실도 흐름.
6. 기존 Combat PoC 진입·복귀.
7. Result/Reward/Retry transaction Shell.
8. 중복 입력·저장 실패·same-seed 재진입 회귀.

후속 순서:

```text
App Flow Shell 자동 검증
→ 실제 화면·입력·사람 검증
→ 두 번째 후보·노드 반복 제작 증명
→ 슬롯별 후보 풀 확장
→ Base v9.3 별도 migration
```

## 적대적 감사 결과

- 감사: `docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md`.
- 행동 선택 구현·정본·Sheet 누락을 수정 중이다.
- 상위 시작 문서의 PR #45·PLAN·Base v8 drift를 현재 기준으로 교체한다.
- Base v9.3 adoption은 현재 대형 PR에 섞지 않는다.
- `CombatBoardPreview` 책임 분리는 App Flow Shell 이후 단계적으로 수행한다.

## `[보류]`

- 16권 절초의 개별 이름·효과·슬롯·태그·대응점.
- 주요 비무 6~10 런타임.
- 천하제일인·서버·비동기 챔피언 배틀.
- 최종 아트·오디오 폴리싱.

## 역사·호환 기준

- PR #7과 Issue #13은 현행 T0 `STEP 0~13` 구현 계보다.
- PR #45와 v6 원장은 재설계·승인 이력이며 최신 날짜별 Decision이 우선한다.
- 과거 `c987647d01ad2baa028a16e03d85ddfc1572a727` Base v8 기준은 `HISTORICAL_COMPATIBILITY_BASELINE`이다.
- `docs/planning-data/*.json`은 직접 런타임 입력이 아니다.

## 완료 경계

자동 검증 통과는 Windows 실제 Godot 조작, 게임패드, 접근성 보조기술, 해상도별 시각 품질, 성능, 사람 플레이 재미·이해도를 증명하지 않는다.
