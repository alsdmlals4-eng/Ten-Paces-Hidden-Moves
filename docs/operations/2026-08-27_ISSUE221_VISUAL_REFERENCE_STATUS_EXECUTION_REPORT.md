# Issue #221 · Default Shell Visual-Reference Status Execution Report

- 기준 SHA: `c403d76f20f5cd3a2a2e204eb143909ae563f0c1`
- Work Mode: `BUILD`
- Skill / Skill Mode: `ten-paces-verification` / `runtime-validation`; `hera-godot:live-editor` / runtime observation
- Issue: [#221](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/issues/221)

## 수행

Godot 기본 진입 화면을 실제로 열어 `VerticalSliceShell`의 상태 문구를 확인했다. 화면은 승인된 전투 레퍼런스가 존재함에도 “최종 시각 레퍼런스 대기 중”이라고 표시하고 있었으며, 현재 planning JSON과 Notion의 승인 상태와 충돌했다.

`final_visual_reference_pending`을 `false`로 교정하고, 첫 화면에 `VisualReferenceStatus` 노드를 추가했다. 문구는 승인 자체와 아직 미완료인 full visual integration을 분리한다. 전투 규칙, 시작 흐름, 소비처 자산, 플랫폼 상태는 변경하지 않았다.

## 결과와 증거

- RED: 변경 전 `verify_vertical_slice_shell.gd`는 승인 레퍼런스 상태와 상태 문구 검증에서 예상대로 실패했다.
- GREEN: `verify_vertical_slice_shell.gd` PASS.
- 인접 회귀: `verify_default_vertical_slice_entry.gd` PASS.
- 자동 흐름: 첫 5전 Shell, Setup/Briefing, Combat Bridge, Review/Result, Route, Completion, Opponent binding 회귀를 실행해 PASS를 확인했다.

## 미검증

- 화면 관찰은 unrelated running Godot game window가 겹쳐 전체 레이아웃 판정까지 진행하지 못했다. 그 외부 창에는 입력하지 않았다.
- Windows visible human usability, Android actual device, physical gamepad, accessibility user, Human fun/readability, fifteen-opponent identifiability, final VFX/audio, release performance는 계속 `NOT_RUN`이다.
