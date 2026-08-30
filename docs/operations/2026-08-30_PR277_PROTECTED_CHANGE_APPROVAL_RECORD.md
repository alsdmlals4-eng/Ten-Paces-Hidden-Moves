# PR #277 일회성 보호 변경 승인 아카이브

```yaml
record_role: IMMUTABLE_ARCHIVE_FOR_ONE_TIME_PROTECTED_CHANGE_APPROVAL
source_manifest: docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
source_manifest_sha256: dc3835d03550c041ebcad54c1e698b100dd24df655db1daf4c9caf3b6c1ecfd2
protected_base_commit: 48b20da2948e6be7d3543c43814e865b975436a5
merged_main_commit: f1d0a33203b7e80d538481f5d23b56afc1dd5d98
merged_pull_request: 277
decisions:
  - TEN-DEC-20260801-SITUATION-SCREEN-01
  - TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
  - TEN-DEC-20260828-ACTION-PLAN-EXECUTION-CTA-01
approval_source: USER_EXPLICIT_FINAL_LOCK_AND_ALL_REQUIRED_APPROVALS_2026-08-30
approval_time: 2026-08-30T12:58:40+09:00
archive_intent: REMOVE_ACTIVE_MANIFEST_AND_PROMOTE_PROTECTED_BASELINE_TO_MERGED_MAIN
```

PR #277에서만 유효했던 active manifest를 이 기록으로 보존한다. 이 문서는 새 protected-path 변경을 승인하지 않으며, 미래 작업의 approval source로 재사용할 수 없다.

## 당시 승인된 정확한 경로

- `assets/ASSET_MANIFEST.json`
- `assets/backgrounds/ink_mist_valley_duel_01_v1.png`
- `assets/characters/combat_diagonal_duel_character_pair_01_v1.png`
- `assets/characters/combat_diagonal_duel_character_pair_01_v1.png.import`
- `assets/characters/dogyeom_diagonal_duel_battler_01_v1.png`
- `assets/characters/dogyeom_diagonal_duel_battler_01_v1.png.import`
- `assets/characters/player_diagonal_duel_battler_01_v1.png`
- `assets/characters/player_diagonal_duel_battler_01_v1.png.import`
- `assets/ui/cards/README.md`
- `assets/ui/cards/basic_technique_ink_atlas_01_v1.png`
- `assets/ui/cards/basic_technique_ink_atlas_01_v1.png.import`
- `assets/ui/cards/card_asset_manifest.json`
- `data/cards/basic_cards.json`
- `data/combat/combat_board_poc.json`
- `src/combat/battle_background.gd`
- `src/combat/combat_board_preview.gd`
- `src/combat/combat_board_preview_auto.gd`
- `src/combat/combat_board_tile.gd`
- `src/combat/combat_character_placeholder.gd`
- `src/combat/combat_resolution_engine.gd`
- `src/ui/action_selection/action_selection_dock.gd`
- `src/ui/action_selection/basic_action_panel.gd`
- `src/ui/action_selection/martial_action_panel.gd`
- `src/ui/action_selection/ultimate_action_panel.gd`
- `src/ui/action_timing_panel.gd`
- `src/ui/combat_action_reveal_overlay.gd`
- `src/ui/combat_action_reveal_overlay.gd.uid`
- `src/ui/combat_progress_button.gd`

## 범위와 증거 경계

승인은 ink-paper 대결 연출 한 묶음으로만 한정됐다: 최종 잠금된 배경, 좌하단 대형 플레이어와 우상단 소형 도겸 전투 이미지, 5×2 기초 기술 아틀라스, 그리고 이미 해결된 현재 수만 순서대로 보여 주는 `VS` 공개. 전투 수치와 타이밍 규칙, AI/private-plan 경계, public history, save schema, 플랫폼·Android·출시 범위와 무관한 리팩터링은 승인하지 않았다.

PR #277은 remote CI를 통과한 뒤 `f1d0a33203b7e80d538481f5d23b56afc1dd5d98`로 병합됐다. 이 archive cleanup은 active manifest를 제거하고 `skills/PROJECT_BASE_ADAPTER.json`의 protected baseline을 해당 merged-main commit으로 승격한다. Windows-visible, Human, accessibility-user, Android device, release performance와 store/release evidence는 이 archive로 승격되지 않는다.
