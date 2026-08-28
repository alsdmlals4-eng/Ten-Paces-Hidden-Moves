# 십보강호 · 현재 화면별 시각 커버리지 인벤토리

> Issue: [#243](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/issues/243)
> 기준 main: `44386b2019aa45d48c11f5e8e59c9c505648d575`
> 구조화 정본: `docs/planning-data/current_screen_visual_coverage_inventory_20260828.json`
> 범위: `res://scenes/run/vertical_slice_shell.tscn`의 첫 5전 PC-first Vertical Slice

## 결론

현재 P0 흐름에서 새 이미지가 없어서 막힌 화면은 **0개**다. Main·Setup·Intro·Briefing·Result·Route·Completion은 Godot UI와 텍스트를 실제 소비처로 쓰며, 전투와 Review는 이미 연결된 배경·배틀러·상태 초상·카드 atlas·VFX를 쓴다.

이는 이미지 소비처의 coverage 판정일 뿐 최신 전투 규칙 반영이나 Windows visible/Human Player Experience PASS가 아니다.

따라서 이 인벤토리는 미래 이미지 목록을 자동 제작 대기열로 만들지 않는다. 새 결과물은 `실제 소비처 → scoped brief → 정확히 1개 생성 → adversarial review → 사용자 final lock`을 통과한다. pre-generation 승인은 현행 cadence가 아니다.

## 구분

| 구분 | 현행 owner / 소비처 | 현재 판정 |
|---|---|---|
| Runtime image | `assets/`와 실제 Godot preload/load | 전투 asset family는 연결됨 |
| Production-planning visual | Notion Visual Bible·Asset Library, `docs/visual-assets` | 정본·후보·reference이며 runtime 승격 아님 |
| Release / marketing | 출시 profile 및 향후 store/trailer workspace | 아직 제품 범위 밖이며 `RELEASE_BLOCKED_UNVERIFIED` |

## P0 화면 판정

| Screen | 실제 소비처 | 이미지 필요 | 상태 |
|---|---|---|---|
| Main / Setup / Intro | `src/run/vertical_slice_shell.gd` | 필요 없음 | `COVERED_BY_CODE_RENDERING` |
| Briefing | `VerticalSliceShell._render_briefing` | 필요 없음 | `COVERED_BY_CODE_RENDERING` |
| Combat | `src/combat/combat_board_preview.gd` | 기존 배경·배틀러·초상·카드·VFX | `COVERED_BY_EXISTING_RUNTIME_ASSETS` |
| Review | `src/ui/combat_review_panel.gd` | Combat asset 재사용 | `COVERED_BY_REUSE` |
| Result | `src/run/vertical_slice_shell_result_auto.gd` | 필요 없음 | `COVERED_BY_CODE_RENDERING` |
| Route Growth / Info | `src/run/vertical_slice_shell_route_auto.gd` | 필요 없음 | `COVERED_BY_CODE_RENDERING` |
| Completion | `src/run/vertical_slice_shell_completion_auto.gd` | 필요 없음 | `COVERED_BY_CODE_RENDERING` |

`DOGYEOM_STATUS_PORTRAIT_01`는 `src/ui/combatant_status_panel.gd`에서, 도겸 배틀러는 `src/combat/combat_character_placeholder.gd`에서 `slot1_dogyeom`으로 실제 라우팅된다. 다른 적은 승인된 일반 fallback을 계속 사용한다. 그 자체가 14개 신규 자산을 자동 요구하지 않는다.

## 의도적으로 제작하지 않은 항목

- Pause/Settings, Failure/Retry, Codex/Help: 현재 Slice에 screen state·Scene·consumer가 없어 `NOT_APPLICABLE_CURRENT_VERTICAL_SLICE`.
- Boot/Loading/Error/Credits/Store assets: release scope와 권리·플랫폼 증거가 없어 `RELEASE_BLOCKED_UNVERIFIED`.
- Warm-dusk v2: `USER_APPROVED_PLANNING_ANCHOR_ONLY_NON_RUNTIME`이며 runtime asset으로 승격하지 않음.

## 교정

Issue #240의 UI copy correction은 PR #241을 통해 main `d9ae822`에 병합됐다. 이전 visual handoff의 `PENDING_PR_MERGE` 표기는 이 문서와 JSON에서 `ISSUE_240_MERGED_MAIN_D9AE822`로 교정한다. 이 교정은 새 art·새 runtime route·새 플랫폼 검증을 주장하지 않는다.
