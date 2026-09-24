# PR363 수묵 화면·하단 결과·기존 이미지 폐기 승인 종료

Status: `ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY`.

PR363은 2026-09-24T19:49:31Z에 main `df3b7538f16e66208e29f4f4c04c85567c34ff5c`로 정상 병합됐다. 검토 HEAD `0af72791199b41bbefdcbdf2bd43de4920eb8f26`의 최신 workflow별 **34 SUCCESS/실패0/진행0**, 미해결 review thread0과 최신 main을 확인했다. 전체 tracked tree가 동일하다. push/ready 전환으로 대체된 옛 취소 실행은 성공으로 세지 않았다. Direct-main·force·admin 우회는 없다.

일회 승인 보호 경로 85개의 수명을 종료한다. 활성 manifest를 제거하고 보호 기준선을 정확한 병합 SHA로 갱신하며 채택 Base `23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef` 생성기로 파생 뷰를 갱신한다. 제품·자산·녹화 bytes는 이 closeout에서 변경하지 않는다.

CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE. 기존 PR361/362 승인 종료 owner와 lifecycle 검사를 재사용한다. 동일 승인 후보의 두 전체 검토와 이후 결함별 교정은 기존 실행 보고서가 소유한다. 이 기록은 새로운 실행 권한이 아니다.

문서 화면의 메인 예시는 촬영 실행마다 별도 임시 저장 경로를 사용하도록 교정해 새 여정 상태로 다시 촬영했다. 이전 촬영 과정에서 만든 호환성 오류 fixture가 메인 예시에 남지 않게 하는 캡처 도구/문서 교정이며, 실제 게임 저장·제품·영상은 변경하지 않는다.

검증: 전체 로컬602검사, 추가 HTML/저장 호환 회귀, Windows export50/50, native9화면 및3/3/4 녹화686프레임/28.583초, 인앱 브라우저 끝 재생/오류0. 새 이미지 최종 시각 품질·사람의 반복 관람 재미·Android·출시 성능/권리는 별도다. 실행 보고서: `docs/operations/2026-09-09_CLASH_DIRECTION_EXECUTION_REPORT.md`.

## 승인 원문

원본: `df3b7538f16e66208e29f4f4c04c85567c34ff5c:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`. 5782bytes, SHA-256 `04b081129df2e4a094088b5b23fa73dc8e70341c4f519062c2d910e78e725f00`. Base64는 마지막 LF까지 Git blob 그대로다.

```json
{
  "schema_version": 1,
  "artifact_role": "PROJECT_PROTECTED_CHANGE_APPROVAL",
  "status": "APPROVED",
  "protected_base_commit": "53b007e3ad1b1dd7eb3b1ef574a2391bb7abf8cb",
  "decision_ids": [
    "TEN-DEC-20260924-INK-WUXIA-STYLE-AND-FLOW-01"
  ],
  "approved_paths": [
    "assets/ASSET_MANIFEST.json",
    "assets/backgrounds/atlas_blue_ink_courtyard_v1.png",
    "assets/backgrounds/atlas_blue_ink_courtyard_v1.png.import",
    "assets/backgrounds/ink_wuxia/briefing.png",
    "assets/backgrounds/ink_wuxia/briefing.png.import",
    "assets/backgrounds/ink_wuxia/journey.png",
    "assets/backgrounds/ink_wuxia/journey.png.import",
    "assets/backgrounds/ink_wuxia/main.png",
    "assets/backgrounds/ink_wuxia/main.png.import",
    "assets/backgrounds/ink_wuxia/rest.png",
    "assets/backgrounds/ink_wuxia/rest.png.import",
    "assets/backgrounds/ink_wuxia/result.png",
    "assets/backgrounds/ink_wuxia/result.png.import",
    "assets/backgrounds/ink_wuxia/setup.png",
    "assets/backgrounds/ink_wuxia/setup.png.import",
    "assets/backgrounds/jianghu_blue_ink_landscape_v1.png",
    "assets/backgrounds/jianghu_blue_ink_landscape_v1.png.import",
    "assets/backgrounds/jianghu_rest_inn_v1.png",
    "assets/backgrounds/jianghu_rest_inn_v1.png.import",
    "assets/blueprint/APPROVED_ART_MANIFEST.json",
    "assets/characters/dogyeom_combat_battler_01_v1.png",
    "assets/characters/dogyeom_combat_battler_01_v1.png.import",
    "assets/characters/player_wanderer_battler_rgba_v2.png",
    "assets/characters/player_wanderer_battler_rgba_v2.png.import",
    "assets/characters/portraits/masked_baekmujin_ink_20260925.png",
    "assets/characters/portraits/masked_baekmujin_ink_20260925.png.import",
    "assets/characters/portraits/masked_baekmujin_portrait_v1.png",
    "assets/characters/portraits/masked_baekmujin_portrait_v1.png.import",
    "assets/characters/portraits/slot1_dogyeom_ink_20260925.png",
    "assets/characters/portraits/slot1_dogyeom_ink_20260925.png.import",
    "assets/characters/portraits/slot1_dogyeom_portrait_v1.png",
    "assets/characters/portraits/slot1_dogyeom_portrait_v1.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-0.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-0.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-1.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-1.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-2.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-2.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-3.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-3.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-4.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-4.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-5.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-5.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-6.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-6.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-7.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-7.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-8.png",
    "assets/combat/ink_wuxia/masked_baekmujin/enemy-8.png.import",
    "assets/combat/ink_wuxia/masked_baekmujin/hero-clash.png",
    "assets/combat/ink_wuxia/masked_baekmujin/hero-clash.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-0.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-0.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-1.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-1.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-2.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-2.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-3.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-3.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-4.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-4.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-5.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-5.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-6.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-6.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-7.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-7.png.import",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-8.png",
    "assets/combat/ink_wuxia/slot1_dogyeom/enemy-8.png.import",
    "data/presentation/dogyeom_ink_opponent.json",
    "data/presentation/masked_ink_opponent.json",
    "data/run/approved_opponent_stages_v2.json",
    "src/combat/battle_background.gd",
    "src/combat/combat_character_placeholder.gd",
    "src/run/vertical_slice_shell.gd",
    "src/run/run_checkpoint_codec.gd",
    "src/run/vertical_slice_shell_route_auto.gd",
    "src/ui/approved_blueprint_art.gd",
    "src/ui/bimu_constraint_panel.gd",
    "src/ui/ink/ink_combat_presentation.gd",
    "src/ui/ink/ink_combat_stage.gd",
    "src/ui/ink/ink_screen_art.gd",
    "src/ui/ink/ink_screen_art.gd.uid",
    "src/ui/main_title_screen.gd"
  ],
  "approval_source": "2026-09-25 user: 작업에 필요한 권한 승인할테니까 필요한 이미지 제작,게임에 연결,구현까지 진행하고 html에도 다 반영해놔; 이미지 변경하고 기존이미지 폐기",
  "approval_time": "2026-09-25T04:04:53+09:00",
  "scope_summary": "Six ink backgrounds; current masked opponent and Dogyeom poses/portraits; enlarged actual result HUD; read-only HTML update; verified replaced thirteen image files (ten used/source files and three identical copies) deleted. Existing planning controls, resolver, AI, stats, reward and save schema preserved. No other enemy art replaced."
}
```

```base64
ewogICJzY2hlbWFfdmVyc2lvbiI6IDEsCiAgImFydGlmYWN0X3JvbGUiOiAiUFJPSkVDVF9QUk9URUNURURfQ0hBTkdFX0FQUFJPVkFMIiwKICAic3RhdHVzIjogIkFQUFJPVkVEIiwKICAicHJvdGVjdGVkX2Jhc2VfY29tbWl0IjogIjUzYjAwN2UzYWQxYjFkZDdlYjNiMWVmNTc0YTIzOTFiYjdhYmY4Y2IiLAogICJkZWNpc2lvbl9pZHMiOiBbCiAgICAiVEVOLURFQy0yMDI2MDkyNC1JTkstV1VYSUEtU1RZTEUtQU5ELUZMT1ctMDEiCiAgXSwKICAiYXBwcm92ZWRfcGF0aHMiOiBbCiAgICAiYXNzZXRzL0FTU0VUX01BTklGRVNULmpzb24iLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9hdGxhc19ibHVlX2lua19jb3VydHlhcmRfdjEucG5nIiwKICAgICJhc3NldHMvYmFja2dyb3VuZHMvYXRsYXNfYmx1ZV9pbmtfY291cnR5YXJkX3YxLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9pbmtfd3V4aWEvYnJpZWZpbmcucG5nIiwKICAgICJhc3NldHMvYmFja2dyb3VuZHMvaW5rX3d1eGlhL2JyaWVmaW5nLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9pbmtfd3V4aWEvam91cm5leS5wbmciLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9pbmtfd3V4aWEvam91cm5leS5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvYmFja2dyb3VuZHMvaW5rX3d1eGlhL21haW4ucG5nIiwKICAgICJhc3NldHMvYmFja2dyb3VuZHMvaW5rX3d1eGlhL21haW4ucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2lua193dXhpYS9yZXN0LnBuZyIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2lua193dXhpYS9yZXN0LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9pbmtfd3V4aWEvcmVzdWx0LnBuZyIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2lua193dXhpYS9yZXN1bHQucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2lua193dXhpYS9zZXR1cC5wbmciLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9pbmtfd3V4aWEvc2V0dXAucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2ppYW5naHVfYmx1ZV9pbmtfbGFuZHNjYXBlX3YxLnBuZyIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2ppYW5naHVfYmx1ZV9pbmtfbGFuZHNjYXBlX3YxLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9qaWFuZ2h1X3Jlc3RfaW5uX3YxLnBuZyIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2ppYW5naHVfcmVzdF9pbm5fdjEucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2JsdWVwcmludC9BUFBST1ZFRF9BUlRfTUFOSUZFU1QuanNvbiIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvZG9neWVvbV9jb21iYXRfYmF0dGxlcl8wMV92MS5wbmciLAogICAgImFzc2V0cy9jaGFyYWN0ZXJzL2RvZ3llb21fY29tYmF0X2JhdHRsZXJfMDFfdjEucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvcGxheWVyX3dhbmRlcmVyX2JhdHRsZXJfcmdiYV92Mi5wbmciLAogICAgImFzc2V0cy9jaGFyYWN0ZXJzL3BsYXllcl93YW5kZXJlcl9iYXR0bGVyX3JnYmFfdjIucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvcG9ydHJhaXRzL21hc2tlZF9iYWVrbXVqaW5faW5rXzIwMjYwOTI1LnBuZyIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvcG9ydHJhaXRzL21hc2tlZF9iYWVrbXVqaW5faW5rXzIwMjYwOTI1LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jaGFyYWN0ZXJzL3BvcnRyYWl0cy9tYXNrZWRfYmFla211amluX3BvcnRyYWl0X3YxLnBuZyIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvcG9ydHJhaXRzL21hc2tlZF9iYWVrbXVqaW5fcG9ydHJhaXRfdjEucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvcG9ydHJhaXRzL3Nsb3QxX2RvZ3llb21faW5rXzIwMjYwOTI1LnBuZyIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvcG9ydHJhaXRzL3Nsb3QxX2RvZ3llb21faW5rXzIwMjYwOTI1LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jaGFyYWN0ZXJzL3BvcnRyYWl0cy9zbG90MV9kb2d5ZW9tX3BvcnRyYWl0X3YxLnBuZyIsCiAgICAiYXNzZXRzL2NoYXJhY3RlcnMvcG9ydHJhaXRzL3Nsb3QxX2RvZ3llb21fcG9ydHJhaXRfdjEucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9lbmVteS0wLnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9lbmVteS0wLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL21hc2tlZF9iYWVrbXVqaW4vZW5lbXktMS5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL21hc2tlZF9iYWVrbXVqaW4vZW5lbXktMS5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9tYXNrZWRfYmFla211amluL2VuZW15LTIucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9tYXNrZWRfYmFla211amluL2VuZW15LTIucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9lbmVteS0zLnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9lbmVteS0zLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL21hc2tlZF9iYWVrbXVqaW4vZW5lbXktNC5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL21hc2tlZF9iYWVrbXVqaW4vZW5lbXktNC5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9tYXNrZWRfYmFla211amluL2VuZW15LTUucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9tYXNrZWRfYmFla211amluL2VuZW15LTUucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9lbmVteS02LnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9lbmVteS02LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL21hc2tlZF9iYWVrbXVqaW4vZW5lbXktNy5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL21hc2tlZF9iYWVrbXVqaW4vZW5lbXktNy5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9tYXNrZWRfYmFla211amluL2VuZW15LTgucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9tYXNrZWRfYmFla211amluL2VuZW15LTgucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9oZXJvLWNsYXNoLnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvbWFza2VkX2JhZWttdWppbi9oZXJvLWNsYXNoLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3Nsb3QxX2RvZ3llb20vZW5lbXktMC5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3Nsb3QxX2RvZ3llb20vZW5lbXktMC5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9zbG90MV9kb2d5ZW9tL2VuZW15LTEucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9zbG90MV9kb2d5ZW9tL2VuZW15LTEucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvc2xvdDFfZG9neWVvbS9lbmVteS0yLnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvc2xvdDFfZG9neWVvbS9lbmVteS0yLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3Nsb3QxX2RvZ3llb20vZW5lbXktMy5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3Nsb3QxX2RvZ3llb20vZW5lbXktMy5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9zbG90MV9kb2d5ZW9tL2VuZW15LTQucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9zbG90MV9kb2d5ZW9tL2VuZW15LTQucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvc2xvdDFfZG9neWVvbS9lbmVteS01LnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvc2xvdDFfZG9neWVvbS9lbmVteS01LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3Nsb3QxX2RvZ3llb20vZW5lbXktNi5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3Nsb3QxX2RvZ3llb20vZW5lbXktNi5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9zbG90MV9kb2d5ZW9tL2VuZW15LTcucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9zbG90MV9kb2d5ZW9tL2VuZW15LTcucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvc2xvdDFfZG9neWVvbS9lbmVteS04LnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvc2xvdDFfZG9neWVvbS9lbmVteS04LnBuZy5pbXBvcnQiLAogICAgImRhdGEvcHJlc2VudGF0aW9uL2RvZ3llb21faW5rX29wcG9uZW50Lmpzb24iLAogICAgImRhdGEvcHJlc2VudGF0aW9uL21hc2tlZF9pbmtfb3Bwb25lbnQuanNvbiIsCiAgICAiZGF0YS9ydW4vYXBwcm92ZWRfb3Bwb25lbnRfc3RhZ2VzX3YyLmpzb24iLAogICAgInNyYy9jb21iYXQvYmF0dGxlX2JhY2tncm91bmQuZ2QiLAogICAgInNyYy9jb21iYXQvY29tYmF0X2NoYXJhY3Rlcl9wbGFjZWhvbGRlci5nZCIsCiAgICAic3JjL3J1bi92ZXJ0aWNhbF9zbGljZV9zaGVsbC5nZCIsCiAgICAic3JjL3J1bi9ydW5fY2hlY2twb2ludF9jb2RlYy5nZCIsCiAgICAic3JjL3J1bi92ZXJ0aWNhbF9zbGljZV9zaGVsbF9yb3V0ZV9hdXRvLmdkIiwKICAgICJzcmMvdWkvYXBwcm92ZWRfYmx1ZXByaW50X2FydC5nZCIsCiAgICAic3JjL3VpL2JpbXVfY29uc3RyYWludF9wYW5lbC5nZCIsCiAgICAic3JjL3VpL2luay9pbmtfY29tYmF0X3ByZXNlbnRhdGlvbi5nZCIsCiAgICAic3JjL3VpL2luay9pbmtfY29tYmF0X3N0YWdlLmdkIiwKICAgICJzcmMvdWkvaW5rL2lua19zY3JlZW5fYXJ0LmdkIiwKICAgICJzcmMvdWkvaW5rL2lua19zY3JlZW5fYXJ0LmdkLnVpZCIsCiAgICAic3JjL3VpL21haW5fdGl0bGVfc2NyZWVuLmdkIgogIF0sCiAgImFwcHJvdmFsX3NvdXJjZSI6ICIyMDI2LTA5LTI1IHVzZXI6IOyekeyXheyXkCDtlYTsmpTtlZwg6raM7ZWcIOyKueyduO2VoO2FjOuLiOq5jCDtlYTsmpTtlZwg7J2066+47KeAIOygnOyekSzqsozsnoTsl5Ag7Jew6rKwLOq1rO2YhOq5jOyngCDsp4TtlontlZjqs6AgaHRtbOyXkOuPhCDri6Qg67CY7JiB7ZW064aUOyDsnbTrr7jsp4Ag67OA6rK97ZWY6rOgIOq4sOyhtOydtOuvuOyngCDtj5DquLAiLAogICJhcHByb3ZhbF90aW1lIjogIjIwMjYtMDktMjVUMDQ6MDQ6NTMrMDk6MDAiLAogICJzY29wZV9zdW1tYXJ5IjogIlNpeCBpbmsgYmFja2dyb3VuZHM7IGN1cnJlbnQgbWFza2VkIG9wcG9uZW50IGFuZCBEb2d5ZW9tIHBvc2VzL3BvcnRyYWl0czsgZW5sYXJnZWQgYWN0dWFsIHJlc3VsdCBIVUQ7IHJlYWQtb25seSBIVE1MIHVwZGF0ZTsgdmVyaWZpZWQgcmVwbGFjZWQgdGhpcnRlZW4gaW1hZ2UgZmlsZXMgKHRlbiB1c2VkL3NvdXJjZSBmaWxlcyBhbmQgdGhyZWUgaWRlbnRpY2FsIGNvcGllcykgZGVsZXRlZC4gRXhpc3RpbmcgcGxhbm5pbmcgY29udHJvbHMsIHJlc29sdmVyLCBBSSwgc3RhdHMsIHJld2FyZCBhbmQgc2F2ZSBzY2hlbWEgcHJlc2VydmVkLiBObyBvdGhlciBlbmVteSBhcnQgcmVwbGFjZWQuIgp9Cg==
```
