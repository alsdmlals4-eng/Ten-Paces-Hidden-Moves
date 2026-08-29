# Windows-visible Godot 런타임 스모크 실행 보고

```yaml
report_id: TEN-OPS-20260830-WINDOWS-VISIBLE-GODOT-RUNTIME-SMOKE-01
work_mode: REVIEW
baseline_main: 89468c3dff712351c769ff23640020cd06802a7f
verified_runtime_head: 89468c3dff712351c769ff23640020cd06802a7f
scope: first-run start setup through slot1_dogyeom combat-screen rendering
environment:
  host: Windows local
  godot: 4.7.1.stable.official.a13da4feb
  project_identity: exact disposable worktree project.godot
  live_observability: HERA exact editor/session identity
skill_mode:
  - ten-paces-hidden-moves-workflow-router / REVIEW
  - ten-paces-verification / runtime-validation + evidence-report
  - hera-godot:live-editor / live UI inspection
  - systematic-debugging / diagnose-before-fix
result: PARTIAL
```

## 작업 전 문제

`DOGYEOM_COMBAT_BATTLER_01`과 `DOGYEOM_STATUS_PORTRAIT_01`은 자동 Godot verifier와 runtime route를 보유했지만, current owner에는 Windows에서 실제 Godot 화면으로 시작부터 전투까지 진입하여 두 이미지를 함께 관찰한 증거가 없었다. visual planning board와 실제 runtime asset의 상태가 섞이지 않도록 실화면 확인이 필요했다.

## 현재 출처 관련성·구현 가능성

- **CURRENT_SOURCE_RELEVANCE_CHECK: NOT_APPLICABLE.** 이 작업은 외부 기술·시장·권리·플랫폼 결정을 새로 내리지 않고, 저장소의 exact main·현재 Godot binary·실제 local editor session에서 이미 구현된 소비자를 관찰하는 검증이다. 외부 검색은 판단을 바꾸지 않는다.
- **FEASIBLE.** `project.godot`, `scenes/run/vertical_slice_shell.tscn`, `src/combat/combat_character_placeholder.gd`, `src/ui/combatant_status_panel.gd`, 도겸 두 runtime PNG, focused GDScript verifier, 현재 승인 Godot 4.7.1과 exact worktree/editor session을 대조했다.
- project-local router가 요구하는 이름의 `validate_operating_contract.ps1`은 저장소와 pinned Base checkout에서 발견되지 않았다. 현재 저장소가 채택한 fallback contract validator `python tools/check_project_operating_system.py`와 v9.1 router/adapter tests를 실행해 `PASS`를 확인했다. 이 사실은 product runtime PASS의 근거가 아니라 route integrity의 한계 기록이다.

## 관찰한 실제 실행 경로

```text
새 비무행
→ 시작 무공 6중 4 선택
→ 이 네 권으로 출발
→ 첫 상대 확인
→ 비무 1 · 도겸
→ 비무 시작
→ 10칸 전장 / 행동 계획 / 도겸 상태 초상화 / 도겸 전신 Battler
```

- 첫 상대 briefing은 `비무 1 · 도겸`, candidate `slot1_dogyeom`을 표시했다.
- 실제 전투 화면에서 **도겸 상태 초상화**는 우측 status panel에, **도겸 전신 Battler**는 10칸 전장 중앙의 enemy anchor에 표시됐다.
- 같은 화면에서 공개 거리 2, 10칸, `3수 → 3수 → 4수`, 행동계획 input UI를 확인했다. 사진의 planning board는 이 경로에 소비되지 않았으며, `PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2`는 계속 `USER_FINAL_LOCKED_PLANNING_ARTIFACT_ONLY`다.

## 자동·실행 검증 증거

| 층 | 수행 | 결과 |
|---|---|---|
| Project contract fallback | `check_project_operating_system.py`, v9.1 operating-contract/router tests | PASS |
| Godot bootstrap | `--headless --editor --path . --quit` | PASS; fresh disposable worktree의 initial class/import scan 완료 |
| Asset-focused Godot | `verify_dogyeom_combat_battler.gd`, `verify_dogyeom_status_portrait.gd`, `verify_vertical_slice_combat_bridge.gd` | 3 PASS |
| Affected Godot regression | opponent binding, catalog, setup briefing, AI rival tendency, Phase 2 combat resolution | 5 PASS |
| Live Windows runtime | HERA exact editor/session에서 시작→설정→briefing→도겸 전투 | PASS; runtime diagnostics error 0 / warning 0 |
| Screenshot UI analysis | 1280×800 runtime capture | nonblank; `possible_clipping: false`; edge content는 full-bleed HUD/background에 기인하므로 clipping 판정 아님 |
| Baseline preservation | source main와 test worktree의 제품 source diff | 없음; Godot가 생성한 `.import` cache artefact는 disposable worktree에만 발생하고 source PR에 포함하지 않음 |

초기 class cache가 없는 disposable worktree에서 direct `-s` verifier를 먼저 실행하면 global class resolve failure가 발생했다. 파일은 exact main에 존재했고, headless editor initial scan 뒤 동일 verifier가 PASS했다. 따라서 source defect나 runtime regression으로 승격하지 않고, fresh worktree에서는 editor scan을 먼저 수행하는 test-environment ordering으로 기록한다.

## 적대적 검토와 clean exit

1. **정본·이미지 상태:** approval·runtime route·planning board owner를 대조해 planning image를 shipping/runtime PASS로 승격하지 않았고, 도겸의 두 runtime asset만 관찰 범위로 제한했다.
2. **실제 consumer:** `slot1_dogyeom` guard, status portrait fallback, battler fallback, briefing candidate ID와 live screenshot을 교차 확인했다. 다른 14명은 generic fallback/미제작 상태로 남는다.
3. **자동 증거:** asset-focused 3개와 관련 regression 5개가 Godot 4.7.1에서 모두 PASS했으며, initial cache failure를 숨기지 않고 원인·재실행 결과를 기록했다.
4. **live runtime:** exact project/editor/session에서 normal input sequence로 combat scene에 도달했고, node tree·screenshot·diagnostics를 대조했다. debugger error/warning 0을 확인했다.
5. **evidence ceiling·장기 적합성:** Windows machine runtime smoke만 PASS로 올리고, human usability/player approval, Android actual device, 15명 식별성, VFX/audio, release performance를 그대로 `NOT_RUN`으로 유지했다. product source 혹은 protected path를 바꾸지 않았고 generated `.import`는 disposable test artifact로 분리했다.

`CLEAN_REVIEW_EXIT`: 이 관찰 범위에서 `MUST_FIX_REMAINING: 0`. 새 제품 결함은 발견되지 않았다.

## 미검증·남은 위험

- 이것은 **Codex machine-performed Windows visible runtime smoke**이지 독립적인 Human usability/player experience PASS가 아니다.
- Android actual device, assistive-technology user, release performance, audio/VFX 완성, 15명 개별 식별성은 실행하지 않았으며 `NOT_RUN`이다.
- 도겸 외 14명의 전용 portrait/battler, route/result icon, 추가 background는 정확한 future consumer가 선택될 때까지 `GAP_NONBLOCKING`; 이번 스모크로 제작 완료가 되지 않는다.
- 첫 run은 slot1 도겸을 확인했지만, 모든 opponent/fallback combination을 live exhaustive하게 순회한 것은 아니다.

## 자동화·학습 반영

- fresh disposable worktree의 standalone Godot verifier 전에 `--headless --editor --path . --quit` initial scan을 수행하는 절차를 execution evidence에 보존했다.
- machine runtime, human usability, device, release performance evidence를 별도 key로 분리하여 이후 검증이 낮은 증거 층을 덮어쓰지 않게 했다.
- 새 image generation·asset promotion·core combat/UI change는 하지 않았다. 다음 안전 작업은 사용자 또는 current contract가 특정 consumer를 선택할 때 그 asset family를 별도 scoped package로 다루는 것이다.
