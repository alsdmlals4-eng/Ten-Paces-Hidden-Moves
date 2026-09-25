# PR365 전투 실행·삽화 선택·대각선 구도 승인 종료

Status: `ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY`.

PR365은 2026-09-25T00:54:47Z에 main `9f0ce7ddf3a7aad95e82b725d99bbd5248bdd60d`로 정상 병합됐다. 검토 HEAD `92be01fb1385ab8373f06ad27117268acc538fd7`의 최신 workflow별 33SUCCESS/실패0/진행0을 확인했다. 전체 tracked tree가 동일하다. 미해결 검토는 병합 직전 GitHub에서 별도로 확인했다. Direct main/force/admin 우회는 없다.

일회 승인 경로20개의 수명을 종료한다. 활성 승인을 제거하고 보호 기준선을 이 병합 SHA로 올린다. 채택 Base23ecad5a 생성기로 파생 뷰를 갱신하며 제품·자산·영상 bytes는 바꾸지 않는다.

CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE. 같은 계약의 두 전체 검토·집중 교정, 기존 PR363/364 승인 종료와 lifecycle 검사 재사용. 이 문서는 신규 실행 권한이 아니다.

검증: 저장 준비 상태의 RED/GREEN, Godot AI4.2.3 실제 입력·복사 저장 이어하기·3수 실행·도감/설정/종료, Windows export50/50, 실제 Godot11화면과30.125초3/3/4고정계획 영상, 브라우저 끝 재생/오류0, HTML UI/링크 검사. 전체 테스트와 원격 지표는 기존 실행 보고서에 실패 이력과 함께 누적한다. Human 시각/재미·적 전원 고유 자세·Android·출시 검증은 별도다.

## 승인 원문

원본 `9f0ce7ddf3a7aad95e82b725d99bbd5248bdd60d:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`. 1732bytes, SHA256 `72cb97b08d88c3a806cde082f886b37d2c3c7f1df2a04f5285ca4cfc980cfa66`. Base64는 Git blob의 마지막 LF까지 보존한다.

```json
{
  "schema_version": 1,
  "artifact_role": "PROJECT_PROTECTED_CHANGE_APPROVAL",
  "status": "APPROVED",
  "protected_base_commit": "df3b7538f16e66208e29f4f4c04c85567c34ff5c",
  "decision_ids": [
    "TEN-DEC-20260924-INK-WUXIA-STYLE-AND-FLOW-01"
  ],
  "approved_paths": [
    "assets/ASSET_MANIFEST.json",
    "assets/blueprint/APPROVED_ART_MANIFEST.json",
    "assets/characters/enemy_masked_battler_rgba_v2.png",
    "assets/characters/enemy_masked_battler_rgba_v2.png.import",
    "src/combat/combat_board_preview_auto.gd",
    "src/combat/combat_character_placeholder.gd",
    "src/run/combat_checkpoint_codec.gd",
    "src/run/vertical_slice_shell.gd",
    "src/ui/action_selection/action_choice_card.gd",
    "src/ui/action_selection/linked_action_block.gd",
    "src/ui/ink/ink_combat_stage.gd",
    "src/ui/ink/ink_manual_choice.gd",
    "src/ui/ink/ink_manual_choice.gd.uid",
    "src/ui/ink/ink_preferences.gd",
    "src/ui/ink/ink_preferences.gd.uid",
    "src/ui/ink/ink_settings_panel.gd",
    "src/ui/ink/ink_settings_panel.gd.uid",
    "src/ui/ink/ink_title_library.gd",
    "src/ui/ink/ink_title_library.gd.uid",
    "src/ui/main_title_screen.gd"
  ],
  "approval_source": "2026-09-25 user: actual battle execution fix; illustrated manual selection; continue/codex/settings/exit; diagonal preparation; continuous clash/counter/evade. Existing implementation and HTML approval reused. Use updated Godot AI.",
  "approval_time": "2026-09-25T08:17:32+09:00",
  "scope_summary": "Repair valid prepare status persistence without schema changes; illustrated setup; functional title menu; diagonal preparation preserving controls; continuous cinematic presentation; source-backed HTML and actual runtime verification."
}
```

```base64
ewogICJzY2hlbWFfdmVyc2lvbiI6IDEsCiAgImFydGlmYWN0X3JvbGUiOiAiUFJPSkVDVF9QUk9URUNURURfQ0hBTkdFX0FQUFJPVkFMIiwKICAic3RhdHVzIjogIkFQUFJPVkVEIiwKICAicHJvdGVjdGVkX2Jhc2VfY29tbWl0IjogImRmM2I3NTM4ZjE2ZTY2MjA4ZTI5ZjRmNGMwNGM4NTU2N2MzNGZmNWMiLAogICJkZWNpc2lvbl9pZHMiOiBbCiAgICAiVEVOLURFQy0yMDI2MDkyNC1JTkstV1VYSUEtU1RZTEUtQU5ELUZMT1ctMDEiCiAgXSwKICAiYXBwcm92ZWRfcGF0aHMiOiBbCiAgICAiYXNzZXRzL0FTU0VUX01BTklGRVNULmpzb24iLAogICAgImFzc2V0cy9ibHVlcHJpbnQvQVBQUk9WRURfQVJUX01BTklGRVNULmpzb24iLAogICAgImFzc2V0cy9jaGFyYWN0ZXJzL2VuZW15X21hc2tlZF9iYXR0bGVyX3JnYmFfdjIucG5nIiwKICAgICJhc3NldHMvY2hhcmFjdGVycy9lbmVteV9tYXNrZWRfYmF0dGxlcl9yZ2JhX3YyLnBuZy5pbXBvcnQiLAogICAgInNyYy9jb21iYXQvY29tYmF0X2JvYXJkX3ByZXZpZXdfYXV0by5nZCIsCiAgICAic3JjL2NvbWJhdC9jb21iYXRfY2hhcmFjdGVyX3BsYWNlaG9sZGVyLmdkIiwKICAgICJzcmMvcnVuL2NvbWJhdF9jaGVja3BvaW50X2NvZGVjLmdkIiwKICAgICJzcmMvcnVuL3ZlcnRpY2FsX3NsaWNlX3NoZWxsLmdkIiwKICAgICJzcmMvdWkvYWN0aW9uX3NlbGVjdGlvbi9hY3Rpb25fY2hvaWNlX2NhcmQuZ2QiLAogICAgInNyYy91aS9hY3Rpb25fc2VsZWN0aW9uL2xpbmtlZF9hY3Rpb25fYmxvY2suZ2QiLAogICAgInNyYy91aS9pbmsvaW5rX2NvbWJhdF9zdGFnZS5nZCIsCiAgICAic3JjL3VpL2luay9pbmtfbWFudWFsX2Nob2ljZS5nZCIsCiAgICAic3JjL3VpL2luay9pbmtfbWFudWFsX2Nob2ljZS5nZC51aWQiLAogICAgInNyYy91aS9pbmsvaW5rX3ByZWZlcmVuY2VzLmdkIiwKICAgICJzcmMvdWkvaW5rL2lua19wcmVmZXJlbmNlcy5nZC51aWQiLAogICAgInNyYy91aS9pbmsvaW5rX3NldHRpbmdzX3BhbmVsLmdkIiwKICAgICJzcmMvdWkvaW5rL2lua19zZXR0aW5nc19wYW5lbC5nZC51aWQiLAogICAgInNyYy91aS9pbmsvaW5rX3RpdGxlX2xpYnJhcnkuZ2QiLAogICAgInNyYy91aS9pbmsvaW5rX3RpdGxlX2xpYnJhcnkuZ2QudWlkIiwKICAgICJzcmMvdWkvbWFpbl90aXRsZV9zY3JlZW4uZ2QiCiAgXSwKICAiYXBwcm92YWxfc291cmNlIjogIjIwMjYtMDktMjUgdXNlcjogYWN0dWFsIGJhdHRsZSBleGVjdXRpb24gZml4OyBpbGx1c3RyYXRlZCBtYW51YWwgc2VsZWN0aW9uOyBjb250aW51ZS9jb2RleC9zZXR0aW5ncy9leGl0OyBkaWFnb25hbCBwcmVwYXJhdGlvbjsgY29udGludW91cyBjbGFzaC9jb3VudGVyL2V2YWRlLiBFeGlzdGluZyBpbXBsZW1lbnRhdGlvbiBhbmQgSFRNTCBhcHByb3ZhbCByZXVzZWQuIFVzZSB1cGRhdGVkIEdvZG90IEFJLiIsCiAgImFwcHJvdmFsX3RpbWUiOiAiMjAyNi0wOS0yNVQwODoxNzozMiswOTowMCIsCiAgInNjb3BlX3N1bW1hcnkiOiAiUmVwYWlyIHZhbGlkIHByZXBhcmUgc3RhdHVzIHBlcnNpc3RlbmNlIHdpdGhvdXQgc2NoZW1hIGNoYW5nZXM7IGlsbHVzdHJhdGVkIHNldHVwOyBmdW5jdGlvbmFsIHRpdGxlIG1lbnU7IGRpYWdvbmFsIHByZXBhcmF0aW9uIHByZXNlcnZpbmcgY29udHJvbHM7IGNvbnRpbnVvdXMgY2luZW1hdGljIHByZXNlbnRhdGlvbjsgc291cmNlLWJhY2tlZCBIVE1MIGFuZCBhY3R1YWwgcnVudGltZSB2ZXJpZmljYXRpb24uIgp9Cg==
```
