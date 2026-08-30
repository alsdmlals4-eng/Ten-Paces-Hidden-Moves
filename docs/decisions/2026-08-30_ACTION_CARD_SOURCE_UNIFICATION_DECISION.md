# 행동 출처 공통 카드·의도 선택 통합 결정 · 2026-08-30

> Decision ID: `TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01`
> Status: `USER_APPROVED_CURRENT`
> Work mode: `BUILD`
> Product/runtime mutation authority: `true — USER_EXPLICIT_20260830: 확정`
> Scope: 전투 `기초 / 무공 / 절초` 선택 카드와 구형 타일·좌우 대상 선택 surface의 퇴역

## 사용자 결정

`USER_EXPLICIT_20260830`: 기초 행동과 다르게 보이는 무공·절초 선택 목록을 카드 방식으로 통일하고, 이전 버전의 이동 방향·타일 선택 잔재와 무공 삽화 consumer를 제거한다.

## 채택 계약

```yaml
selection_sources: [basic, martial, ultimate]
surface: shared_action_card_grid
basic_card_illustration: KEEP_APPROVED_BASIC_ATLAS_ONLY
martial_card_illustration: FORBIDDEN
ultimate_selection_card_illustration: FORBIDDEN
combat_reveal_vfx: UNCHANGED
movement_input: semantic_intent_cards
attack_input: semantic_aim_cards
forbidden_user_surface:
  - numbered_board_tile_targeting
  - left_right_direction_targeting
  - select_destination_board_tile
  - select_left_or_right_direction
  - active_legacy_basic_card_tray
  - active_legacy_ultimate_list
```

### 공통 카드 정보 위치

모든 행동 출처는 같은 카드 shell과 순서를 사용한다.

```text
행동명 · 점유 수
출처 · 행동 종류
비용
공격일 때만 사거리
핵심 효과 또는 태그
잠김 / 예약 / 사용 가능 상태
```

- 기초는 위 구조의 상단 art slot에 승인된 `TEN_BASIC_TECHNIQUE_INK_ATLAS_01`만 사용한다.
- 무공과 절초 선택 카드는 art slot을 생성하지 않는다. 이들은 종이 면, 테두리, 태그, 수치, 텍스트와 접근성 이름으로만 상태를 구분한다.
- 전투 중 `VS` 공개 overlay와 절초 VFX는 action-selection consumer가 아니므로 이 Decision으로 제거하거나 새 삽화를 추가하지 않는다.

### 의도 선택과 전투 규칙 경계

이 변경은 10칸 논리 전장, 공개 거리, 3/3/4, 합, AI 공개 정보 경계, 비용, 중단, 저장 의미를 바꾸지 않는다.

- 이동 행동은 현재 전장의 절대 타일이나 `좌 / 우`가 아니라 `접근 N칸` 또는 `후퇴 N칸` 의도 카드로 선택한다. 실제 선택지는 경계와 카드의 이동 범위를 반영한다.
- 공격·반격·절초의 노림은 `상대를 노림` 또는 `반대 예측` 의미 카드로 선택한다. 따라서 상대 이동을 읽는 선택지는 남고, 번호 타일·좌우 click surface만 제거된다.
- UI/placement DTO는 `move_intent`와 `aim_intent`를 소유한다. resolution 직전에만 current public state를 기준으로 내부 부호 계산으로 정규화한다.
- 기존 resolver의 internal `miss_direction` 결과 키는 저장/회귀 호환 범위에서 유지할 수 있으나, player-facing log와 복기 설명은 `예측 빗나감`으로 표시한다.

## 기존 정본과의 관계

- `TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01`의 무공 무삽화 원칙을 유지하고, 그 범위를 common action-card consumer까지 확장한다.
- `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`의 `ActionSelectionDock → ActionPlacementController → ActionTimingPanel → CombatResolutionEngine` 경로, 해금 기술 직접 배치 금지, 연결 블록, 절초 예약/환불을 유지한다.
- 해당 2026-08-01 Decision의 타일 목적지/좌우 방향 선택 표현은 이 Decision의 범위에서 `SUPERSEDED_FOR_PLAYER_INPUT_SURFACE`다.

## 연구·구현 가능성

```yaml
current_source_relevance_check: REUSED_BOUNDED_CONTINUATION
benchmark_packet: docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md
reuse_basis:
  decision_dimension: card-based action selection plus timing/spacing legibility
  project_state: ActionSelectionDock current runtime surface
  source_freshness: 2026-08-30 official product facts
comparables_reapplied:
  - Your Only Move Is HUSTLE
  - Toribash
  - Yomi 2
  - Fights in Tight Spaces
  - Into the Breach
  - Shogun Showdown
  - For Honor
  - Samurai Shodown
  - Hellish Quart
  - Nidhogg 2
  - Absolver
  - Die by the Blade
do_not_copy: [deck_hand_draw, realtime_reaction_controls, exact_opponent_plan_reveal, third_party_ui_art_names_values]
feasibility: FEASIBLE
existing_consumers:
  - scenes/ui/action_selection/action_selection_dock.tscn
  - src/ui/action_selection/basic_action_panel.gd
  - src/ui/action_selection/martial_action_panel.gd
  - src/ui/action_selection/ultimate_action_panel.gd
  - src/combat/combat_board_preview_auto.gd
  - src/ui/action_timing_panel.gd
```

The existing twelve-game packet is reused only for this bounded continuation: the same action-selection, timing, public-state and spacing presentation dimension is being corrected on the same current `ActionSelectionDock` surface. It does not validate the new runtime implementation, player understanding, Android, accessibility-user or release performance.

## Required evidence

1. Test-first RED for residual tile/left-right player targeting and disparate source panels.
2. Static and Godot coverage proving basic/martial/ultimate share the card grid while martial and ultimate selection cards create no `TextureRect` illustration.
3. Godot coverage for move intent, attack aim, multi-slot placement, ultimate reservation/refund, focus and no tactical tile layer during selection.
4. Windows-visible machine runtime capture/input readback for all three source tabs and one resolved bundle.
5. Human/player comparison, actual Android device, accessibility-user and release performance remain `NOT_RUN` unless independently performed.
