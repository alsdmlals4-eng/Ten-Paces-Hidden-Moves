# 도겸 상태 초상 · Codex 실행 보고 · 2026-08-26

## 실행 기록

```yaml
issue: 208
base_main_sha: b39e48547af9f045d3486ac24a5ae82edc848ac6
work_mode: BUILD
skills:
  - combat-implementation-handoff / BUILD
  - ten-paces-verification / BUILD
  - test-driven-development / RED_GREEN
performed:
  - 승인 PNG를 runtime portrait asset과 ASSET_MANIFEST에 등록
  - VerticalSliceCombatBridge가 enemy candidate_id를 combat_state에 보존하도록 최소 연결
  - CombatantStatusPanel이 slot1_dogyeom일 때만 승인 portrait를 선택하도록 연결
  - 다른 상대와 candidate_id 누락 상대의 generic fallback 유지
result: IMPLEMENTED_AUTOMATED_GODOT_VERIFIED
evidence:
  - res://tests/verify_dogyeom_status_portrait.gd PASS
  - res://tests/verify_vertical_slice_combat_bridge.gd PASS
  - python tests/check_combat_board_contract.py PASS
not_verified:
  - Windows visible human usability
  - Android actual device
  - Dogyeom battlefield battler routing
```

## 범위 경계

- 전투 규칙, AI, 저장 포맷, 행동 카드, 기존 generic portrait의 기본 동작은 변경하지 않았다.
- 상태 패널의 기존 `STRETCH_KEEP_ASPECT_COVERED` 표시는 유지한다.
- 다음 Visual은 자동 생산하지 않는다. concrete consumer와 사용자 결정이 필요하다.
