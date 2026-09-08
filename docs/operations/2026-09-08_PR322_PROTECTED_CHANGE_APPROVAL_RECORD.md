# PR 322 보호 변경 승인 보존 기록

```yaml
artifact_role: PROTECTED_CHANGE_APPROVAL_ARCHIVE_RECORD
implementation_pr: 322
implementation_merge_commit: 81ef0f0b2ede9cd63d6a2aba521a645efc1d4e5f
implementation_base_commit: a0d4d967b81ab4a6ce8dc4623546fecceceb4307
approval_manifest_sha256: 6621F6FD0ABB197B1DF064095FF35FE97B4D3488CBDB59504F01A1D64354C3C3
approval_lifecycle: ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY
active_authority: false
implementation_authority: NONE
```

PR 322의 완료된 일회성 승인을 원문 전체와 Git blob 해시로 보존한다.
현재 승인 파일은 제거하고 보호 기준점을 정확한 병합 커밋으로 옮긴다. 이 기록은
후속 제약 시스템 구현을 승인하지 않는다. Base 채택 버전과 보호 경로는 변경하지 않는다.

## 원문 보존

```json
{"schema_version":1,"artifact_role":"PROJECT_PROTECTED_CHANGE_APPROVAL","status":"APPROVED","protected_base_commit":"751f4ee07e84f810015cedaa9c9d77a93016c041","decision_ids":["TEN-DEC-20260908-TEN-DUEL-CAMPAIGN-IMPLEMENTATION-01","TEN-DEC-20260908-STANDING-PR-INTEGRATION-01"],"approved_paths":["assets/backgrounds/atlas_blue_ink_courtyard_v1.png","assets/backgrounds/jianghu_blue_ink_landscape_v1.png","assets/backgrounds/jianghu_rest_inn_v1.png","project.godot","scenes/ui/action_selection/action_selection_dock.tscn","scenes/ui/action_selection/martial_action_panel.tscn","src/combat/battle_background.gd","src/combat/combat_board_preview.gd","src/combat/combat_board_preview_auto.gd","src/combat/combat_resolution_engine.gd","src/run/vertical_slice_completion_model.gd","src/run/vertical_slice_opponent_catalog.gd","src/run/vertical_slice_route_model.gd","src/run/vertical_slice_run_state.gd","src/run/vertical_slice_shell.gd","src/run/vertical_slice_shell_completion_auto.gd","src/run/vertical_slice_shell_result_auto.gd","src/run/vertical_slice_shell_route_auto.gd","src/ui/action_selection/action_choice_card.gd","src/ui/action_selection/action_detail_panel.gd","src/ui/action_selection/action_selection_dock.gd","src/ui/action_selection/basic_action_panel.gd","src/ui/action_selection/martial_action_panel.gd","src/ui/action_selection/ultimate_action_panel.gd","src/ui/combat_sound_bank.gd","src/ui/combatant_status_panel.gd","src/ui/main_title_screen.gd"],"approval_source":"Latest user explicitly directs complete planned Godot implementation, ten duels and four sequential next-node choices per interval, needed image/sound/motion production and connection, research/correction/verification without intermediate approval. Scope recorded in docs/implementation/BUILD_APPROVAL_2026-09-08.md. Related PR integration is explicitly standing-authorized; no bypass.","approval_time":"2026-09-08T00:00:00+09:00","scope_summary":"PR322 only: ten-duel campaign and route state, cumulative public intel, native resource/card UI with shared truthful previews, original/reused background consumers and original sound caching. Preserve approved originals, 10-cell logic, opening distance2, 3/3/4, private-plan boundary. No save schema, reward formula, release/rights or Human acceptance promotion."}
```

## 검증·검토

- Work Mode: REVIEW / Skill Mode: EXECUTE; baseline: 위 implementation_merge_commit.
- PR 322는 32개 exact-head 검사를 통과하고 병합됐다. detached-main pytest 472건과 실제 resolver/RunState 순차 probe의 10승·36 route 선택·정확 자원 handoff가 통과했다.
- 검토 1: 병합 Git blob과 원문 JSON·SHA-256을 byte 기준으로 대조한다.
- 검토 2: 제품 파일은 바꾸지 않고 active manifest만 수명 종료하며 보호 기준점을 병합 SHA로 이동한다.
- 검토 3: 27개 승인 경로와 승인 문구 전체를 minified JSON으로 보존한다.
- 검토 4: 채택 Base exact source로 파생 운영 뷰를 재생성하고 validator로 대조한다.
- 검토 5: 다음 제약 패키지는 별도 구현 권위가 필요하며 이 기록을 재사용하지 않는다.
- 외부 조사: NOT_APPLICABLE — 게임 설계 변경이 아닌 저장소 승인 수명 closeout이다.
- 미검증: Human UX, Android 실기기, 접근성 사용자, 권리 및 출시는 NOT_RUN이다.
