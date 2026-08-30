# 행동 출처 공통 카드·의도 선택 통합 실행 보고 · 2026-08-30

```yaml
report_id: TEN-OPS-20260830-ACTION-CARD-SOURCE-UNIFICATION-01
baseline_branch: origin/main
baseline_sha: 0b2ab3fe64a8325b52b743c8d9da03cb23646b3f
work_branch: codex/action-card-source-unification-20260830
work_mode: BUILD
skill: ten-paces-hidden-moves-workflow-router, combat UX/accessibility, Godot live editor, verification
skill_mode: CURRENT_SOURCE_RELEVANCE_CHECK + CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF + MACHINE_RUNTIME_OBSERVATION
decision: TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01
feasibility: FEASIBLE
status: IMPLEMENTED_LOCAL_MACHINE_RUNTIME_OBSERVED_READY_TO_COMMIT
```

## 작업 전 문제

현재 전투 화면에는 기초 카드, 무공 목록, 절초 목록이 서로 다른 구조로 남아 있었고, 이동·공격 뒤에는 구형 논리 타일 또는 좌우 방향 선택이 이어졌다. 사용자에게 보이는 무공/절초 카드의 정보 위계와 기초 카드의 선택 방식이 일관되지 않았으며, 더 이상 active consumer가 아니어야 할 `data/combat/action_selection_poc.json`도 남아 있었다.

## 조사·비교 결과

동일 프로젝트의 12종 사전 벤치마크 패킷을 이 작업에만 재사용했다. 채택한 것은 행동 선택, 수 순서, 공개 거리와 예측 표현의 결정 차원이고, 외부 UI·아트·덱/손패·실시간 반응을 복사하지 않았다. current source/data/scene readback 결과, `ActionSelectionDock`와 현재 ten-manual loadout 경로가 기존 10칸 resolver를 바꾸지 않고 공통 카드와 의미 카드를 수용할 수 있었다.

## 채택한 구조와 이유

- `ActionChoiceCard`를 기초·무공·절초·의도 카드의 공통 버튼 shell로 사용한다.
- 기본 행동만 승인된 `TEN_BASIC_TECHNIQUE_INK_ATLAS_01` crop을 consumer로 가진다.
- 무공·절초·의도 카드는 `TextureRect`를 생성하지 않으며, 이름·점유 수·출처·비용·사거리·태그·상태를 같은 카드 골격으로 읽는다.
- 이동은 `접근 N칸 / 후퇴 N칸`, 공격은 `상대를 노림 / 반대 예측`으로 선택한다. engine resolver에는 검증·저장 호환을 위한 내부 direction/target tile만 정규화해 전달한다.
- player-facing 실패 문구는 internal `miss_direction` key를 보존하되 `예측 빗나감`으로 바꾼다.

## 실제 구현 또는 준비 결과

- `BasicActionPanel`, `MartialActionPanel`, `UltimateActionPanel`, `ActionIntentPanel`을 공통 카드 surface에 연결했다.
- `ActionSelectionDock`은 targeting 상태에서 source 탭 대신 의미 카드만 보이고, logical `TileLayer`와 tile focus는 숨긴다.
- `CombatBoardPreviewAuto`가 최이른 합법 slot 자동 배치 뒤 semantic intent를 열고, 선택 후 현재 묶음 readiness를 갱신한다.
- active selection POC를 삭제하고 combat board/resolution/ultimate/martial data를 current semantic contract로 갱신했다.
- 기초 카드의 user-facing target/effect text도 좌·우/지정 방향 표현에서 접근·후퇴/노림·예측 표현으로 바꿨다.

## 사용 예

`이동` 카드를 누르면 가장 앞 빈 수에 자동 배치되고 `접근 1칸`과 `후퇴 1칸` 카드가 나타난다. 하나를 누르면 해당 수에 선택한 문구가 확정된다. `강공`·`장풍`·무공 공격·절초는 같은 위치에서 `상대를 노림` 또는 `반대 예측`을 선택한다. 어떤 단계에도 플레이어가 클릭할 1~10 타일이나 좌우 선택기는 표시되지 않는다.

## TDD·회귀 관찰

- 새 Python contract는 구현 전 shared surface와 semantic target fields가 없어 기대 RED를 기록했다. 구현 뒤 `tests.test_action_card_source_unification_contract`가 GREEN이 됐다.
- 새 Godot verifier는 common-card/무삽화/semantic intent surface가 구현 전 여섯 항목에서 RED였고, `ActionChoiceCard`·`ActionIntentPanel` 연결 뒤 GREEN이 됐다.
- runtime observation 중 카드 클릭 직후 slot을 다시 누르면 자동 배치를 제거하는 현상을 재현했다. 이는 구형 수동 slot click을 같은 입력 흐름에 섞은 결과이며, 카드 클릭만으로 자동 배치 후 의미 카드가 열리는 현재 설계의 오류가 아니었다. 실제 카드 → 의미 카드 → 확정 순서로 재검증했다.
- 독립 read-only review의 three findings를 받아들여 공통 카드의 출처·계열·효과 행, 숨은 사거리 없는 accessibility description, 퇴역 fixture의 현행 문서 참조를 보완했다. 기초 삽화 면적을 과도하게 줄인 첫 수정은 visual verifier에서 RED였고, 50px 이상의 상단 삽화 면적을 유지한 채 정보 행을 재배치해 GREEN으로 복구했다.

## 다섯 차례 적대 검토와 독립 코드 검토

1. **정본/범위:** user-approved Decision, design, data, scene, current consumers를 대조했다. basic atlas와 diagonal characters/reveal VFX는 그대로 남고, 무공·절초의 illustration consumer만 금지됐다.
2. **규칙 경계:** 10칸 resolver/AI/save payload의 internal direction/target tile과 `miss_direction` key를 유지했다. player surface와 DTO만 `move_intent`/`aim_intent`로 바꿨다.
3. **입력·가독성:** focusable shared cards와 intent cards, targeting 중 tile hidden, 1280×800 실제 runtime snapshot, 1440×900 layout tree를 읽었다. OS-level physical keyboard ergonomics는 실행하지 않았다.
4. **untouched consumer:** basic approved atlas, diagonal pair, `VS` timing reveal, ultimate VFX, reservation/refund, current ten-manual loadout tests를 재확인했다. martial/ultimate live tree의 visible `TextureRect` count는 각각 0이었다.
5. **delivery/evidence:** active POC reference grep, JSON/data check, 19개 Godot verifier, final diff, evidence ceiling을 다시 읽었다. process-recovery로 handoff owner가 Task 5 refresh 때 새로 기록된 사실을 보존하며, branch review 전 merge/CI PASS라고 쓰지 않는다.
6. **독립 code review closure:** common card의 사실/효과 행 누락, new card assistive description, deleted fixture의 active documentation pointer를 모두 수정했다. basic card illustration height regression은 focused visual verifier와 1280×800 runtime capture로 다시 확인했다.

## 검증 증거

| 검증 | 결과 | 한계 |
| --- | --- | --- |
| `tests.test_action_card_source_unification_contract` | PASS | Active data/source contract만 검증한다. |
| action-selection/combat-board static checks | PASS | JSON·consumer relationship을 검증한다. |
| Godot `verify_action_card_source_unification.gd` | PASS | common card, no-art, semantic target, hidden tiles, current-bundle readiness를 자동 검증한다. |
| Godot `verify_combat_board.gd` | PASS | semantic move/aim이 existing resolver 결과와 연결됨을 검증한다. |
| Godot affected source/focus/ultimate/manual/reveal verifiers | PASS | 19개 verifier: source/dock/manual/ultimate/auto placement/focus/keyboard/layout/assistive/combat board/prepare/linked/ultimate UI/ten-manual/reveal/presentation/assets/viewport가 모두 exit 0, `SCRIPT ERROR` 없음으로 통과했다. |
| Windows-visible exact worktree runtime | MACHINE_RUNTIME_OBSERVED | 새 비무행 → 무공 4권 → 첫 상대 → 전투 진입 뒤, basic/martial/ultimate tabs와 movement·attack intent cards를 실제 game input으로 읽었다. final 1280×800 capture에서 기본 카드의 atlas 상단 50px, `기초 · 이동 · 비용 없음`, effect 행을 확인했고, 무공 카드에는 `매화삼첩 · [화산파] 매화검결 · 공격 · 기1 내1 · 거리 1 · 연속 공격 3회`가 text-only card로 표시되며 illustration node가 0개였다. `속공 → 상대를 노림`은 1수에 자동 확정됐고, 관찰·명상으로 3수 묶음을 채운 뒤 실행하면 각 수를 공개하는 `CombatActionRevealOverlay`가 실제 표시됐다. TileLayer는 hidden, distance readout는 `거리 2`, diagnostics error는 0이었다. 사람 UX PASS는 아니다. |
| Human player / accessibility user / Android device / release performance | NOT_RUN | 사용자 지시에 따라 사람 플레이 대조는 보류했고, 다른 evidence로 대체하지 않는다. |

## Local final verification

- `python tools/check_project_operating_system.py`: PASS.
- `python -m unittest discover -s tests -p "test_*.py" -v`: **431 tests, 15.960s, OK**.
- `python tests/check_action_selection_contract.py` 및 `python tests/check_combat_board_contract.py`: PASS.
- exact Godot 4.7.1 headless: `verify_action_card_source_unification`, `verify_action_selection_dock`, `verify_martial_action_panel`, `verify_ultimate_action_panel`, `verify_combat_action_selection_integration`, `verify_auto_card_placement`, `verify_combat_focus_order`, `verify_combat_keyboard_accessibility`, `verify_combat_layout_accessibility`, `verify_combat_assistive_labels`, `verify_combat_board`, `verify_prepare_momentum`, `verify_linked_action_blocks`, `verify_ultimate_ui`, `verify_ten_manual_ui_ai_adoption`, `verify_diagonal_duel_action_reveal`, `verify_ink_paper_combat_presentation`, `verify_diagonal_duel_assets`, `verify_ten_manual_product_viewports`: **19/19 PASS**.
- `git grep -n -E "select_destination_board_tile|select_left_or_right_direction|action_selection_poc\\.json" -- data src scenes`: active product reference 없음.
- JSON parse, relevant diff whitespace check, and final scoped diff inspection: PASS. Godot import scan이 만든 tracked `.import` line-ending status와 untracked local import/runtime captures는 product diff가 아니며 staging 대상에서 제외했다.

## Incident · solution · lesson

Visible runtime inspection 뒤 임시 runtime captures와 untracked Godot import artifacts를 product diff에서 제거하려다, `ink_mist_valley_duel_01_v1.png.import`이 local loader에 필요한 생성 메타파일임을 확인했다. 그 파일이 없으면 background preload가 `unrecognized file extension`으로 실패했다. exact worktree Godot import scan으로 복구한 뒤 same verifier를 다시 실행해 PASS했다. **Lesson:** Godot-generated `.import` files are not canonical product changes in this repository, but an untracked import may still be required for a fresh local verification cache; do not delete it merely because Git does not track it. Preserve it outside staged delivery and verify the renderer after cache cleanup.

## 자동화·학습 반영

새 verifier와 Python contract는 구형 POC data reference, common card surface, martial/ultimate `TextureRect` 부재, semantic intent, logical-tile hiding 및 target readiness를 앞으로 재검증한다. 공통 카드에는 Korean category, effect/tag, accessibility description과 hidden-range omission contract도 추가했다. 이번 runtime readback은 카드 클릭 뒤 수동 slot click을 덧붙이지 않는 product flow를 고정했다.

## 미검증·남은 위험

- branch commit/PR/remote CI/exact-main readback은 아직 수행하지 않았다. 이 보고서는 local branch evidence만 소유하며, 그 단계를 완료한 것처럼 쓰지 않는다.
- Human player comparison, physical keyboard/mouse usability, gamepad, accessibility-user, Android install/touch/back/safe-area/lifecycle, release performance는 `NOT_RUN`이다.
- base `CombatBoardPreview`에는 engine/test compatibility용 historical tile handlers가 남아 있다. active `CombatBoardPreviewAuto` player flow, active data, focused product sources는 이를 선택 surface로 소비하지 않는다.
