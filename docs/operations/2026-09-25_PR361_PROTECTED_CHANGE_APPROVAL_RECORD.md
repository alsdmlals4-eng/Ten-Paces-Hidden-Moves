# PR361 수묵 전투·먹 VFX 승인 종료

Status: `ARCHIVED_NOT_CURRENT_EXECUTION_AUTHORITY`.

PR #361은 2026-09-24T15:56:35Z에 main `53b007e3ad1b1dd7eb3b1ef574a2391bb7abf8cb`로 정상 병합됐다. 검토 HEAD `2bdf345f5110baccaab335994ec6475391be8602`의 원격 35개 SUCCESS, 실패/진행0과 검토 스레드0·최신main을 확인했다. 검수한 tracked tree와 병합본이 동일하다. Direct-main·force·admin 우회는 사용하지 않았다.

검사 수는 같은 HEAD에서 각 workflow의 최신 실행을 기준으로 한다. push 직후 ready 전환으로 대체된 이전 실행의 취소 9개는 성공으로 계산하지 않았으며, 원본·대체 실행 결과는 `output/ink-validation/pr361-verified-head.json`에 함께 남겼다.

이 기록은 보호 경로 64개 승인의 수명만 종료한다. 활성 manifest를 제거하고 `skills/PROJECT_BASE_ADAPTER.json`의 보호 기준선을 정확한 병합 SHA로 올린다. 채택 Base `23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef` 생성기로 파생 뷰를 갱신한다. 제품·이미지·녹화 bytes는 동일하게 유지하며 이 문서는 새로운 실행 권한이 아니다.

CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE. 기존 PR357 승인 종료 방식, lifecycle 검사, 채택 Base 생성기를 재사용한다. 같은 승인 후보의 두 전체 검토 이후 발견된 오래된 화면 consumer와 대기 한도는 집중 교정·회귀로 닫았다. 이 closeout은 승인 원문·보호 기준선·생성물·제품 불변의 확인이다.

실행·검증·미검증은 `docs/operations/2026-09-09_CLASH_DIRECTION_EXECUTION_REPORT.md`를 따른다. 600개 로컬 검사, Windows export 50/50, 실제 710프레임·29.58초 촬영, native full-validation31종 및 원격 검사를 확인했다. 고유 적·무기별 원화/안무, 사람의 자연스러움·Android·접근성 사용자·출시 성능/권리는 별도다.

## 승인 원문

원본: `53b007e3ad1b1dd7eb3b1ef574a2391bb7abf8cb:docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`. 3979bytes, SHA-256 `331e0555d5c1e6c3d9bbc39477b1561f919a96d0a04adc0d3234d32dc37bac5a`. Base64는 마지막 LF까지 Git blob 그대로다.

```json
{
  "schema_version": 1,
  "artifact_role": "PROJECT_PROTECTED_CHANGE_APPROVAL",
  "status": "APPROVED",
  "protected_base_commit": "27d1a3a94bd820d9ed840ca80f6175e090b1df05",
  "decision_ids": [
    "TEN-DEC-20260924-INK-WUXIA-STYLE-AND-FLOW-01"
  ],
  "approved_paths": [
    "assets/ASSET_MANIFEST.json",
    "assets/backgrounds/atlas_blue_ink_courtyard_v1.png.import",
    "assets/backgrounds/jianghu_blue_ink_landscape_v1.png.import",
    "assets/backgrounds/jianghu_rest_inn_v1.png.import",
    "assets/combat/ink_wuxia/background.png",
    "assets/combat/ink_wuxia/background.png.import",
    "assets/combat/ink_wuxia/enemy-0.png",
    "assets/combat/ink_wuxia/enemy-0.png.import",
    "assets/combat/ink_wuxia/enemy-1.png",
    "assets/combat/ink_wuxia/enemy-1.png.import",
    "assets/combat/ink_wuxia/enemy-2.png",
    "assets/combat/ink_wuxia/enemy-2.png.import",
    "assets/combat/ink_wuxia/enemy-3.png",
    "assets/combat/ink_wuxia/enemy-3.png.import",
    "assets/combat/ink_wuxia/enemy-4.png",
    "assets/combat/ink_wuxia/enemy-4.png.import",
    "assets/combat/ink_wuxia/enemy-5.png",
    "assets/combat/ink_wuxia/enemy-5.png.import",
    "assets/combat/ink_wuxia/enemy-6.png",
    "assets/combat/ink_wuxia/enemy-6.png.import",
    "assets/combat/ink_wuxia/enemy-7.png",
    "assets/combat/ink_wuxia/enemy-7.png.import",
    "assets/combat/ink_wuxia/enemy-8.png",
    "assets/combat/ink_wuxia/enemy-8.png.import",
    "assets/combat/ink_wuxia/hero-clash.png",
    "assets/combat/ink_wuxia/hero-clash.png.import",
    "assets/combat/ink_wuxia/ink-brush.png",
    "assets/combat/ink_wuxia/ink-brush.png.import",
    "assets/combat/ink_wuxia/player-0.png",
    "assets/combat/ink_wuxia/player-0.png.import",
    "assets/combat/ink_wuxia/player-1.png",
    "assets/combat/ink_wuxia/player-1.png.import",
    "assets/combat/ink_wuxia/player-2.png",
    "assets/combat/ink_wuxia/player-2.png.import",
    "assets/combat/ink_wuxia/player-3.png",
    "assets/combat/ink_wuxia/player-3.png.import",
    "assets/combat/ink_wuxia/player-4.png",
    "assets/combat/ink_wuxia/player-4.png.import",
    "assets/combat/ink_wuxia/player-5.png",
    "assets/combat/ink_wuxia/player-5.png.import",
    "assets/combat/ink_wuxia/player-6.png",
    "assets/combat/ink_wuxia/player-6.png.import",
    "assets/combat/ink_wuxia/player-7.png",
    "assets/combat/ink_wuxia/player-7.png.import",
    "assets/combat/ink_wuxia/player-8.png",
    "assets/combat/ink_wuxia/player-8.png.import",
    "data/presentation/combat_motion_presets.json",
    "data/presentation/ink_combat_stage.json",
    "src/combat/combat_board_preview.gd",
    "src/run/bimu_constraint_model.gd.uid",
    "src/run/frozen_opponent_catalog.gd.uid",
    "src/ui/bimu_constraint_panel.gd.uid",
    "src/ui/combat_motion_presets.gd",
    "src/ui/combat_motion_presets.gd.uid",
    "src/ui/combat_motion_sequence.gd",
    "src/ui/combat_motion_sequence.gd.uid",
    "src/ui/combat_presentation_profile.gd.uid",
    "src/ui/combat_sound_bank.gd.uid",
    "src/ui/ink/ink_combat_presentation.gd",
    "src/ui/ink/ink_combat_presentation.gd.uid",
    "src/ui/ink/ink_combat_stage.gd",
    "src/ui/ink/ink_combat_stage.gd.uid",
    "src/ui/ink/ink_resolution_model.gd",
    "src/ui/ink/ink_resolution_model.gd.uid"
  ],
  "approval_source": "2026-09-24 user: 좋아 지금 느낌으로 전투쪽 이미지,연출등을 변경하자. 먹 v.fx 연출도 연결하고. Earlier clarification preserves existing preparation and requires complete 3/3/4 bundles.",
  "approval_time": "2026-09-25T00:03:17+09:00",
  "scope_summary": "Approved ink art and result-driven combat resolution only. Existing planning UI, domain rules, AI, content IDs, resource calculation and saves stay unchanged. Reuse pure presentation modules from PR342 only. Normal guarded PR delivery. Includes generated import/UID metadata for eight existing runtime dependencies required by this fresh native checkout; no source or original image changes."
}
```

```base64
ewogICJzY2hlbWFfdmVyc2lvbiI6IDEsCiAgImFydGlmYWN0X3JvbGUiOiAiUFJPSkVDVF9QUk9URUNURURfQ0hBTkdFX0FQUFJPVkFMIiwKICAic3RhdHVzIjogIkFQUFJPVkVEIiwKICAicHJvdGVjdGVkX2Jhc2VfY29tbWl0IjogIjI3ZDFhM2E5NGJkODIwZDllZDg0MGNhODBmNjE3NWUwOTBiMWRmMDUiLAogICJkZWNpc2lvbl9pZHMiOiBbCiAgICAiVEVOLURFQy0yMDI2MDkyNC1JTkstV1VYSUEtU1RZTEUtQU5ELUZMT1ctMDEiCiAgXSwKICAiYXBwcm92ZWRfcGF0aHMiOiBbCiAgICAiYXNzZXRzL0FTU0VUX01BTklGRVNULmpzb24iLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9hdGxhc19ibHVlX2lua19jb3VydHlhcmRfdjEucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2JhY2tncm91bmRzL2ppYW5naHVfYmx1ZV9pbmtfbGFuZHNjYXBlX3YxLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9iYWNrZ3JvdW5kcy9qaWFuZ2h1X3Jlc3RfaW5uX3YxLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2JhY2tncm91bmQucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9iYWNrZ3JvdW5kLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTAucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS0wLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTEucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS0xLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTIucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS0yLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTMucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS0zLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTQucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS00LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTUucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS01LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTYucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS02LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTcucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS03LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2VuZW15LTgucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9lbmVteS04LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2hlcm8tY2xhc2gucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9oZXJvLWNsYXNoLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2luay1icnVzaC5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL2luay1icnVzaC5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9wbGF5ZXItMC5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3BsYXllci0wLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3BsYXllci0xLnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvcGxheWVyLTEucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvcGxheWVyLTIucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9wbGF5ZXItMi5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9wbGF5ZXItMy5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3BsYXllci0zLnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3BsYXllci00LnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvcGxheWVyLTQucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvcGxheWVyLTUucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9wbGF5ZXItNS5wbmcuaW1wb3J0IiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9wbGF5ZXItNi5wbmciLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3BsYXllci02LnBuZy5pbXBvcnQiLAogICAgImFzc2V0cy9jb21iYXQvaW5rX3d1eGlhL3BsYXllci03LnBuZyIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvcGxheWVyLTcucG5nLmltcG9ydCIsCiAgICAiYXNzZXRzL2NvbWJhdC9pbmtfd3V4aWEvcGxheWVyLTgucG5nIiwKICAgICJhc3NldHMvY29tYmF0L2lua193dXhpYS9wbGF5ZXItOC5wbmcuaW1wb3J0IiwKICAgICJkYXRhL3ByZXNlbnRhdGlvbi9jb21iYXRfbW90aW9uX3ByZXNldHMuanNvbiIsCiAgICAiZGF0YS9wcmVzZW50YXRpb24vaW5rX2NvbWJhdF9zdGFnZS5qc29uIiwKICAgICJzcmMvY29tYmF0L2NvbWJhdF9ib2FyZF9wcmV2aWV3LmdkIiwKICAgICJzcmMvcnVuL2JpbXVfY29uc3RyYWludF9tb2RlbC5nZC51aWQiLAogICAgInNyYy9ydW4vZnJvemVuX29wcG9uZW50X2NhdGFsb2cuZ2QudWlkIiwKICAgICJzcmMvdWkvYmltdV9jb25zdHJhaW50X3BhbmVsLmdkLnVpZCIsCiAgICAic3JjL3VpL2NvbWJhdF9tb3Rpb25fcHJlc2V0cy5nZCIsCiAgICAic3JjL3VpL2NvbWJhdF9tb3Rpb25fcHJlc2V0cy5nZC51aWQiLAogICAgInNyYy91aS9jb21iYXRfbW90aW9uX3NlcXVlbmNlLmdkIiwKICAgICJzcmMvdWkvY29tYmF0X21vdGlvbl9zZXF1ZW5jZS5nZC51aWQiLAogICAgInNyYy91aS9jb21iYXRfcHJlc2VudGF0aW9uX3Byb2ZpbGUuZ2QudWlkIiwKICAgICJzcmMvdWkvY29tYmF0X3NvdW5kX2JhbmsuZ2QudWlkIiwKICAgICJzcmMvdWkvaW5rL2lua19jb21iYXRfcHJlc2VudGF0aW9uLmdkIiwKICAgICJzcmMvdWkvaW5rL2lua19jb21iYXRfcHJlc2VudGF0aW9uLmdkLnVpZCIsCiAgICAic3JjL3VpL2luay9pbmtfY29tYmF0X3N0YWdlLmdkIiwKICAgICJzcmMvdWkvaW5rL2lua19jb21iYXRfc3RhZ2UuZ2QudWlkIiwKICAgICJzcmMvdWkvaW5rL2lua19yZXNvbHV0aW9uX21vZGVsLmdkIiwKICAgICJzcmMvdWkvaW5rL2lua19yZXNvbHV0aW9uX21vZGVsLmdkLnVpZCIKICBdLAogICJhcHByb3ZhbF9zb3VyY2UiOiAiMjAyNi0wOS0yNCB1c2VyOiDsoovslYQg7KeA6riIIOuKkOuCjOycvOuhnCDsoITtiKzsqr0g7J2066+47KeALOyXsOy2nOuTseydhCDrs4Dqsr3tlZjsnpAuIOuouSB2LmZ4IOyXsOy2nOuPhCDsl7DqsrDtlZjqs6AuIEVhcmxpZXIgY2xhcmlmaWNhdGlvbiBwcmVzZXJ2ZXMgZXhpc3RpbmcgcHJlcGFyYXRpb24gYW5kIHJlcXVpcmVzIGNvbXBsZXRlIDMvMy80IGJ1bmRsZXMuIiwKICAiYXBwcm92YWxfdGltZSI6ICIyMDI2LTA5LTI1VDAwOjAzOjE3KzA5OjAwIiwKICAic2NvcGVfc3VtbWFyeSI6ICJBcHByb3ZlZCBpbmsgYXJ0IGFuZCByZXN1bHQtZHJpdmVuIGNvbWJhdCByZXNvbHV0aW9uIG9ubHkuIEV4aXN0aW5nIHBsYW5uaW5nIFVJLCBkb21haW4gcnVsZXMsIEFJLCBjb250ZW50IElEcywgcmVzb3VyY2UgY2FsY3VsYXRpb24gYW5kIHNhdmVzIHN0YXkgdW5jaGFuZ2VkLiBSZXVzZSBwdXJlIHByZXNlbnRhdGlvbiBtb2R1bGVzIGZyb20gUFIzNDIgb25seS4gTm9ybWFsIGd1YXJkZWQgUFIgZGVsaXZlcnkuIEluY2x1ZGVzIGdlbmVyYXRlZCBpbXBvcnQvVUlEIG1ldGFkYXRhIGZvciBlaWdodCBleGlzdGluZyBydW50aW1lIGRlcGVuZGVuY2llcyByZXF1aXJlZCBieSB0aGlzIGZyZXNoIG5hdGl2ZSBjaGVja291dDsgbm8gc291cmNlIG9yIG9yaWdpbmFsIGltYWdlIGNoYW5nZXMuIgp9Cg==
```
