# 전투 화면 분리·원거리 정면 결투 결정 · 2026-09-02

> Decision ID: `TEN-DEC-20260902-SCREEN-PARTITION-AND-DISTANT-FRONTAL-DUEL-01`
> Status: `USER_APPROVED_CURRENT / IMPLEMENTED / MACHINE_RUNTIME_VERIFIED`
> Work mode: `BUILD + REVIEW`
> Product/runtime mutation authority: `USER_EXPLICIT_20260902_SCREEN_PARTITION_AND_DISTANT_DUEL_CONTINUATION`

## 사용자 결정

전투 화면은 하나의 배경 위에 HUD와 카드가 떠 있는 그림이 아니라, 아래의 서로 다른 세 표면으로 읽힌다.

```text
상단 · 상태 / 라운드 / 기세
중단 · 정면 석정 결투 / 거리 N / 원거리 전투원
하단 · 현재 행동 묶음 / 행동 원천 탭 / 카드 선택
```

1. 정면 석정 배경과 깃발 foreground는 오직 중단 결투 무대에만 보인다.
2. 상단은 독립된 먹빛 정보 표면, 하단은 독립된 먹빛·종이 계획 표면으로 분리한다.
3. 행동계획은 논리상 `3 → 3 → 4`를 보존하되, 한 번에 현재 묶음만 보인다. 즉, `1~3`, 다음 `4~6`, 마지막 `7~10`이다.
4. 전투원은 공유한 석재 바닥 발선에서 서로 충분히 멀리 떨어져 보이는 작은 정면 대치 구도를 사용한다. 근접 인물의 불필요한 세부·AI 생성 흔적이 화면 중심이 되지 않는다.

## 현재 source relevance와 벤치마크 재사용

```yaml
CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_BOUNDED_CONTINUATION
benchmark_packet:
  - docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md
  - docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md
same_decision_dimension:
  - combat information hierarchy
  - bounded plan commitment
  - readable distant frontal staging
project_state: CombatBoardPreview plus shared ActionSelectionDock and approved modular courtyard art
feasibility: FEASIBLE
```

기존 10개 이상 비교의 `ADAPT` 결과 가운데, 무대와 계획 표면의 분리·현재 행동 단위의 가독성·인물보다 거리와 전장이 앞서는 위계를 재사용한다. 덱/손패/드로우, 미래 묶음의 전체 미리보기, 상대의 숨은 계획 공개, 타사 UI·명칭·원화의 복사는 계속 `AVOID`다.

## 채택 계약

```yaml
combat_core:
  ten_cell_line: preserved
  opening_public_distance: 2
  bundle_cadence: [3, 3, 4]
  resolver_save_ai_information_boundary: preserved

screen_surfaces:
  top_hud: independent_ink_surface
  duel_stage: stage_only_background_and_banner
  planning: independent_ink_surface_with_paper_timing_and_cards
  background_outside_duel_stage: forbidden
  planning_controls_outside_planning_surface: forbidden

timing_visibility:
  bundle_1: [1, 2, 3]
  bundle_2: [4, 5, 6]
  bundle_3: [7, 8, 9, 10]
  logical_slot_storage: all_ten_preserved
  future_bundle_preview: forbidden
  keyboard_traversal: current_bundle_only

frontal_composition:
  profile: distant_frontal_duel
  shared_floor: BattleBackground.get_duel_floor_y
  initial_horizontal_foot_separation: at_least_42_percent_of_viewport_width
  battler_height: at_most_52_percent_of_duel_stage_height
  logical_board_default_visibility: hidden
```

`CombatScreenSurface`는 전투 규칙, 입력, 저장, 해상도 계산을 소유하지 않는 재사용 가능한 시각 컴포넌트다. `BattleBackground`와 `DuelForegroundBanner`는 stage rect를 받아 전투 소비처에서는 중단만 채우며, Title 소비처는 독립적으로 전체 rect를 사용할 수 있다.

## 기존 결정과의 관계

- `TEN-DEC-20260831-FRONTAL-DUEL-PRESENTATION-AND-ILLUSTRATED-CARD-POLICY-01`의 정면 공유 바닥·논리 전장 숨김·공통 카드 shell을 유지한다.
- `TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01`의 실제 바닥 접지, 이동만의 접근/후퇴, 비이동 public-opponent auto target, type-only 관찰 공개를 유지한다.
- `TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01`의 잠금 뒤 `N수 실행` 의미를 유지한다. 이 결정은 CTA transaction을 바꾸지 않고 배치 surface와 현재 묶음 표시만 교정한다.
- 2026-09-02에 user-final-locked 된 background, banner, player v2, enemy v2의 raster bytes를 다시 만들거나 바꾸지 않는다. 이 결정은 이미 잠긴 모듈의 실제 화면 구도 소비처만 갱신한다.

## 구현·검증과 evidence ceiling

| 관심사 | 소비처 | 기계 증거 |
|---|---|---|
| 3개 화면 표면 | `CombatBoardPreview`, `CombatScreenSurface` | `verify_frontal_duel_screen_partition.gd` |
| stage-only 배경/깃발 | `BattleBackground`, `DuelForegroundBanner` | 동일 verifier + visible capture |
| 현재 묶음만의 3/3/4 표시 | `ActionTimingPanel`, `ActionTimingPanelAuto` | 동일 verifier |
| 원거리 shared-floor 대치 | `CombatBoardPreviewAuto`, `CombatCharacterPlaceholder` | composition verifier + visible capture |

[`TEN-RVC-20260902-003.png`](../evidence/runtime-captures/TEN-RVC-20260902-003.png)는 1280×800 visible Godot runtime의 최초 3수 계획 상태다. 이는 실제 기록된 기계 렌더링 증거이며, Human UX·사람 플레이·접근성 사용자·실제 Android·게임패드·출시 성능·권리/출시는 여전히 `NOT_RUN`이다.
