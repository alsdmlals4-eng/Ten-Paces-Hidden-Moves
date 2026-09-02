# 2026-09-02 · Frontal Duel Screen Partition Execution Report

## Execution receipt

| field | record |
|---|---|
| baseline source commit | `ef7a48d2769b17b4632b695191a293ee40524ac4` |
| product source commit captured | `801f29a82451c9a9e5ae6ddb86d1c11b17f2494f` |
| Work Mode | `BUILD → REVIEW` |
| Skill / Skill Mode | `ten-paces-hidden-moves-workflow-router / project-local build and verification route`; `systematic-debugging / layout root-cause analysis`; `test-driven-development / RED → GREEN` |
| current source relevance | `REUSED_BOUNDED_CONTINUATION`; the existing 10+ game packets remain relevant to the unchanged information-hierarchy and plan-commitment dimension |
| user authority | top/middle/bottom separation, current-only 3/3/4 bundle visibility, and distant frontal combatants were explicitly requested; in-scope continuation was already authorized |
| new raster | none; the user-final-locked modular art pack was reused unchanged |

## 작업 전 문제 → 채택 구조와 이유

이전 runtime capture에서 하나의 전투 background가 전체 viewport를 덮고 있어, 상단 HUD와 하단 행동 탭/카드가 풍경 위에 떠 보였다. 동시에 10개의 타이밍 슬롯을 한 줄로 모두 노출해 현재 판단과 미래 묶음의 경계가 희미했고, 새 v2 전신 인물은 이 작은 stage에서 상대적으로 가까워 보였다.

`CombatScreenSurface`를 도입해 상단 `TopHudSurface`, 중단 `DuelStageSurface`, 하단 `PlanningSurface`의 세 영역을 별도 surface로 만들었다. 배경·깃발은 중단 rect에만 crop하고, 행동계획·카드는 하단 surface에만 배치했다. 논리 slot은 보존하면서 `ActionTimingPanel`은 현재 묶음의 slots만 보여 준다. 인물은 shared stone-floor anchor에서 더 작은 width와 더 넓은 foot separation을 사용한다.

이 구조는 전투 규칙을 UI에 복제하지 않는다. 시각 surface는 입력을 가로채지 않고, background/battler 배치는 resolver·저장·AI와 분리되어 있다. Title 화면의 banner consumer도 full rect을 계속 독립적으로 사용할 수 있다.

## 실제 구현과 사용 예

```text
전투 시작
  상단: 양측 상태 · 라운드 · 기세
  중단: 석정/깃발 · 작은 양측 전투원 · 중앙 거리 2
  하단: 현재 행동 묶음 1묶음/3수 · 슬롯 1~3 · 기초/무공/절초 카드

첫 묶음 해결
  → 2묶음/3수와 슬롯 4~6만 표시

두 번째 묶음 해결
  → 3묶음/4수와 슬롯 7~10만 표시
```

## 검증 증거

| verification | result |
|---|---|
| RED | 신규 `verify_frontal_duel_screen_partition.gd`가 세 surface, current-only indices, distant profile/separation이 없다는 6개 assertion으로 먼저 실패 |
| GREEN | 같은 verifier가 `FRONTAL_DUEL_SCREEN_PARTITION_VERIFY_OK`로 통과 |
| root-cause correction | `ActionSelectionDock` scene의 legacy minimum height `350`이 planning surface보다 커 overflow를 만들던 것을 `272` 및 내부 `232`로 맞춤 |
| focused Godot | `verify_combat_board`, `verify_ink_paper_combat_presentation`, `verify_combat_character_art`, `verify_action_repositioning`, `verify_action_card_source_unification`, `verify_combat_layout_accessibility`, `verify_frontal_duel_assets`, `verify_duel_foreground_banner`, `verify_combat_focus_order`, `verify_frontal_duel_screen_partition` passed |
| core contract | `python tests/check_combat_board_contract.py` passed |
| full Python | `python -m unittest discover -s tests -p 'test_*.py' -v` — 455 tests, `OK` |
| visible Godot runtime | [`TEN-RVC-20260902-003.png`](../evidence/runtime-captures/TEN-RVC-20260902-003.png), `1280×800`, errors `0`, warnings `0`, source SHA `801f29a8…` |

## Five adversarial review loops

1. **Floating surface attack:** inspected capture for landscape leaking behind planner/HUD. Separate opaque top/planning surfaces and stage-only clipping remove the overlap.
2. **Future-information and input attack:** verified 3/3/4 storage persists but UI exposes only `[1,2,3]`, then `[4,5,6]`, then `[7,8,9,10]`. After remote CI exposed a legacy Tab-chain expectation, hidden future slots were set to `FOCUS_NONE` and the product chain now enumerates current indices only; no future plan preview or invisible input stop remains.
3. **Distant-composition attack:** required initial horizontal foot separation at least 42% of viewport width and each battler at most 52% of stage height; shared floor and contact shadow assertions remain active.
4. **Layout-overflow attack:** caught the 350px dock minimum that exceeded the computed planning region; corrected the actual scene constraints rather than hiding or clipping input.
5. **Rule/asset scope attack:** reviewed changed consumers to ensure no combat formula, AI, save, input policy, or locked raster bytes changed. No Base promotion is proposed: one project-specific combat layout consumer set is not cross-project evidence.

## 기대효과

- 전장의 배경은 중단 무대에만 남아 정보·계획 영역의 허공 느낌을 없앤다.
- 한 번에 판단할 행동 수를 제한해 현재 묶음의 커밋 의미가 더 또렷해진다.
- 원거리 정면 구도는 중앙 `거리 N`과 결투 공간을 우선시하면서 작은 인물 원화의 세부 불안정을 줄인다.
- `CombatScreenSurface`, stage rect API, current-bundle visibility API는 title/other combat state와 결합하지 않아 이 프로젝트 안에서 재사용할 수 있다.

## 미검증·남은 위험

이 capture는 recorded Windows-visible machine render를 입증한다. Human UX/사람 플레이, 실제 물리 입력, 접근성 사용자, Android 실제 device, release performance, remote CI, PR merge, post-merge `main` readback은 `NOT_RUN` 또는 아직 진행 전이다. 인물의 최종 미학·거리감에 대한 사람 승인도 capture를 본 사용자 판단과 분리한다.
