# 전장 접지·자동 대상·관찰 공개 결정 · 2026-09-01

> Decision ID: `TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01`
> Status: `USER_APPROVED_CURRENT / IMPLEMENTED / MACHINE_RUNTIME_VERIFIED`
> Work mode: `BUILD + REVIEW`
> Product/runtime mutation authority: `USER_EXPLICIT_20260901`
> Scope: 전투 대치 인물의 바닥 접지, 행동 카드 대상 입력, 연결 행동 블록 경계, 묶음 실행 CTA, 관찰 공개 surface

## 사용자 결정

다음 다섯 가지를 함께 확정한다.

1. 양 전투원은 전경 석재 바닥에 실제로 닿아 보인다.
2. 이동만 `접근 / 후퇴`를 선택한다. 공격·반격·절초를 포함한 모든 비이동 행동은 공개된 상대를 자동 대상으로 한다.
3. 연결된 행동 계획 블록은 자기 타이밍 슬롯의 시각 경계를 넘지 않는다.
4. 실행 CTA는 현재 묶음 수만 보이는 컴팩트 `N수 실행`이다.
5. 적 묶음이 잠긴 뒤 관찰 가능량이 있으면 적의 다음 행동 **종류**를 자동으로 알려 준다.

## 현재 source relevance와 벤치마크 재사용

```yaml
CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_BOUNDED_CONTINUATION
benchmark_packet: docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md
source_rechecked: 2026-08-31
same_decision_dimension:
  - card-based action selection
  - timing and spacing legibility
  - public-state information disclosure
project_state: same ActionSelectionDock and CombatBoardPreview runtime surface
feasibility: FEASIBLE
```

12개 비교 사례의 기존 판정을 이 범위에서만 재사용한다. `YOMI 2`의 행동 종류 가독성과 `Into the Breach`의 제한된 읽을 수 있는 의도는 **ADAPT**한다. 덱·손패·드로우, 적의 정확한 전체 계획 공개, 실시간 반응 조작, 타사 UI·명칭 복사는 계속 **AVOID**한다. 이 재사용은 사람 이해도·Android·접근성 사용자·출시 성능을 증명하지 않는다.

## 채택 계약

```yaml
logical_combat_core:
  ten_cell_line: preserved
  public_opening_distance: 2
  bundle_cadence: [3, 3, 4]
  resolver_and_save_keys: preserved

player_target_input:
  movement: move_intent
  movement_choices: [approach, retreat]
  every_non_movement_action: auto_target_public_opponent
  player_direction_for_non_move: 0
  resolver_direction: derive_relative_direction_at_resolution
  forbidden:
    - numbered_board_tile_targeting
    - left_right_direction_targeting
    - attack_aim_choice_cards

plan_and_execute:
  linked_block: clipped_to_timing_slot_bounds
  CTA_visible_copy: "{bundle_actions}수 실행"
  CTA_caption: none
  CTA_layout: compact_beside_timing_strip
  CTA_full_accessible_meaning: current_plan_execute

observation:
  trigger: enemy_bundle_locked
  reveal_order: locked_entries_front_to_back
  spend: one_available_player_observation_point_per_revealed_entry
  visible_payload: [action_type]
  forbidden_payload:
    - card_name
    - technique_or_manual_id
    - cost
    - range
    - target
    - direction
    - damage
    - future_bundle
    - ai_weights
  manual_reveal_button: retired

presentation:
  background: approved_frontal_courtyard
  floor_reference: foreground_stone_band
  character_feet: shared_background_floor_reference
  shadow: flattened_contact_shadow
```

## 동작 예

```text
[이동] 보법 선택
  → [접근 1칸] / [후퇴 1칸]만 표시

[공격] 속공 선택
  → 현재 빈 슬롯에 즉시 배치
  → 방향/노림 카드 없음
  → resolver가 공개된 상대 쪽의 내부 방향을 판정 시 계산

적 묶음 잠금 + 관찰점 2
  → 관찰 공개 · 상대 [이동→공격] / [공격]
  → 기술명, 사거리, 비용, 방향, 피해는 보이지 않음
```

## 기존 Decision과의 관계

- `TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01`의 공통 카드 shell·타일/좌우 선택 퇴역·이동 의미 카드 원칙은 유지한다.
- 같은 2026-08-30 Decision의 `attack_input: semantic_aim_cards`, 공격 `aim_intent`, `상대를 노림 / 반대 예측`은 **이 player-facing input 범위에서 SUPERSEDED**다.
- `TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01`의 “유효한 묶음을 commit하고 해결로 전환한다”는 의미는 유지한다. 보이는 CTA copy만 `행동계획 실행`에서 `N수 실행`으로 supersede한다.
- `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01`의 기초·무공·절초 공통 카드 삽화는 유지한다. 이 결정은 삽화 asset을 새로 만들거나 바꾸지 않는다.
- `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-DECISION`의 공개 정보 경계는 유지하고, 수동 버튼만 자동 type-only 공개로 바꾼다.

## 구현 소비처와 증거 경계

| 관심사 | 소비처 | 구현 상태 | 증거 경계 |
|---|---|---|---|
| 자동 대상 | `ActionViewModelAdapter`, `ActionTimingPanel`, `ActionPlacementController`, `CombatBoardPreviewAuto`, 카드 JSON | IMPLEMENTED | Godot/Python 기계 회귀 + live machine input |
| 접지 | `BattleBackground`, `CombatBoardPreviewAuto`, `CombatCharacterPlaceholder` | IMPLEMENTED | 배경 floor API, geometry test, live capture |
| 슬롯 경계 | `ActionTimingPanelAuto`, `LinkedActionBlock` scene | IMPLEMENTED | bounds regression + live capture |
| 실행 CTA | `CombatProgressButton`, progress data, CombatBoard layout | IMPLEMENTED | size/collision regression + live capture |
| 관찰 공개 | `CombatBoardPreview`, resolver type-only API | IMPLEMENTED | no-leak regression + runtime log/status |

Windows-visible machine capture는 화면·입력 증거일 뿐이다. 사람 UX, 접근성 사용자, 실제 Android, 게임패드, 출시 성능은 모두 `NOT_RUN`이다.
