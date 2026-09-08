# PR 321 보호 변경 승인 보존 기록

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 321
implementation_merge_commit: 751f4ee07e84f810015cedaa9c9d77a93016c041
implementation_base_commit: 0afdef427257ae5f8bcc2f37b7c46e13bc00b44b
approval_manifest_sha256: BF47A15AA52C97BFBD7C4F83E7238F472B9377076764AC0C26D7DA6B1F3A94A9
approval_lifecycle: ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY
```

PR 321의 완료된 일회성 승인을 원문 전체와 Git blob 해시로 보존한다.
현재 승인 파일은 제거하고 보호 기준점을 해당 병합 커밋으로 옮긴다.
이 기록은 후속 제품 변경을 승인하지 않는다. 후속 PR 322는 별도 최신 사용자 지시,
정확한 보호 경로 승인, 검사와 정상 병합 절차를 거쳐야 한다.
Base 채택 버전 9.4.4와 보호 경로 정책은 변경하지 않는다.

## 원문 보존

```json
{"schema_version":1,"artifact_role":"PROJECT_PROTECTED_CHANGE_APPROVAL","status":"APPROVED","protected_base_commit":"ef7a48d2769b17b4632b695191a293ee40524ac4","decision_ids":["TEN-DEC-20260902-SCREEN-PARTITION-AND-DISTANT-FRONTAL-DUEL-01","TEN-DEC-20260903-MODULAR-DUEL-UI-AND-PRESENTATION-MOTION-01"],"approved_paths":["assets/ASSET_MANIFEST.json","assets/backgrounds/frontal_courtyard_duel_background_02_v1.png","assets/backgrounds/frontal_courtyard_duel_background_02_v1.png.import","assets/characters/enemy_masked_battler_rgba_v2.png","assets/characters/enemy_masked_battler_rgba_v2.png.import","assets/characters/player_wanderer_battler_rgba_v2.png","assets/characters/player_wanderer_battler_rgba_v2.png.import","assets/foregrounds/frontal_courtyard_banner_overlay_01_v1.png","assets/foregrounds/frontal_courtyard_banner_overlay_01_v1.png.import","assets/ui/duel/current_action_slot_frame_01_v1.png","assets/ui/duel/current_action_slot_frame_01_v1.png.import","assets/ui/duel/observation_reveal_frame_01_v1.png","assets/ui/duel/observation_reveal_frame_01_v1.png.import","assets/ui/duel/status_hud_frame_01_v1.png","assets/ui/duel/status_hud_frame_01_v1.png.import","assets/ui/duel/technique_detail_frame_01_v1.png","assets/ui/duel/technique_detail_frame_01_v1.png.import","data/combat/combat_board_poc.json","scenes/ui/action_selection/action_detail_panel.tscn","scenes/ui/action_selection/action_selection_dock.tscn","scenes/ui/action_selection/basic_action_panel.tscn","scenes/ui/action_selection/martial_action_panel.tscn","scenes/ui/action_selection/ultimate_action_panel.tscn","scenes/ui/action_timing_panel.tscn","scenes/ui/combat_progress_button.tscn","src/combat/battle_background.gd","src/combat/combat_board_preview.gd","src/combat/combat_board_preview_auto.gd","src/combat/combat_board_preview_ten_manuals_auto.gd","src/combat/combat_character_placeholder.gd","src/ui/action_timing_panel.gd","src/ui/action_timing_panel_auto.gd","src/ui/action_selection/basic_action_panel.gd","src/ui/action_selection/martial_action_panel.gd","src/ui/action_selection/ultimate_action_panel.gd","src/ui/combat_screen_surface.gd","src/ui/combat_screen_surface.gd.uid","src/ui/combatant_status_panel.gd","src/ui/action_timing_slot.gd","src/ui/action_selection/action_choice_card.gd","src/ui/action_selection/action_detail_panel.gd","src/ui/action_selection/action_selection_dock.gd","src/ui/combat_action_reveal_overlay.gd","src/ui/duel_foreground_banner.gd","src/ui/duel_foreground_banner.gd.uid","src/ui/main_title_screen.gd","src/ui/observation_reveal_panel.gd","src/ui/observation_reveal_panel.gd.uid","src/ui/round_hud_panel.gd","src/ui/top_combat_hud.gd","scenes/ui/observation_reveal_panel.tscn","scenes/ui/round_hud_panel.tscn"],"approval_source":"User explicitly final-locked the modular combat art, then directed the top/middle/bottom screen separation, current-only 3/3/4 action bundle display, distant frontal combatant framing, separately generated status/slot/detail/observation modules, and presentation-only attack/evade/block/hit/ultimate/clash motion. The user then wrote ‘확정’ on 2026-09-03 KST for the four final UI frames and retained v2 combatant originals. The user additionally approved necessary in-scope permissions and directed that work continue until the actual in-game preparation screen matches the supplied target composition, including corrected text cells, plan-lock geometry, and screen proportions.","approval_time":"2026-09-03T00:00:00+09:00","scope_summary":"PR #321 only: retain final-locked modular courtyard and v2 combatant art; render the four final-locked modular UI frames with dynamic public data through the top HUD, round HUD, plan timing, action-source panels, and compact progress control; keep current-only 3/3/4 preparation visibility; hide planning UI during per-action reveal; and add grounded presentation-only attack/evade/block/hit/ultimate/clash transforms. No combat rules, AI boundary, save schema, hidden information release, input policy, or replacement of approved combatant raster bytes is authorized."}
```

## 검증·검토

- Work Mode: REVIEW / Skill Mode: EXECUTE; baseline: 위 implementation_merge_commit.
- 수행: 일회성 승인 수명 검증기가 발견한 과거 승인 잔류를 기존 archive 절차로 교정.
- 회귀: 원문 JSON 전체·52개 승인 경로·원문 해시 보존 검사. 파일 부재 RED 확인 후 보존 기록 추가.
- 검토 1: PR 321 실제 병합 메타데이터와 Git 원문 대조. 후속 PR의 승인이 아님을 명시.
- 검토 2: 보호 경로는 유지, 제품 파일 변경 없음. 기준점만 exact merged main으로 이동.
- 검토 3: 원문을 요약 목록으로 대체하지 않고 전체 보존하여 승인 문구 누락 방지.
- 검토 4: 현재 채택 Base 버전은 유지하고 동일 CI validator로 파생본만 재생성.
- 검토 5: 후속 변경은 새 승인과 exact-head CI를 요구. 규칙 우회·직접 main push 없음.
- 외부 조사: NOT_APPLICABLE — 게임 설계 변경이 아닌 저장소 자체 승인 수명 복구이며,
  실제 lifecycle checker와 기존 PR 308 보존 검사 방식이 책임 원본이다.
- 미검증: 이 문서는 게임 runtime, Human UX, 기기, 권리, 출시 검증을 주장하지 않는다.
