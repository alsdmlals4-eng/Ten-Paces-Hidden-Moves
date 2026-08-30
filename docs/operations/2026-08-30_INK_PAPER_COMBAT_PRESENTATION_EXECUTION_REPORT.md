# 먹선·한지 전투 표현 실행 보고

```yaml
report_id: TEN-OPS-20260830-INK-PAPER-COMBAT-PRESENTATION-01
work_mode: BUILD
baseline_origin_main: 06378d3b56cd49de35f6234c9b01d3ba69f13621
implementation_branch: codex/ink-paper-combat-presentation-design-20260830
implementation_start_head: e6eecbe1391fffe7147c8915645d7a9812d80d2c
scope: combat and review presentation only; no combat-rule, AI-input, save-schema, or card-data semantic change
environment:
  host: Windows local
  godot: 4.7.1.stable.official.a13da4feb
  runtime_project_identity: exact isolated worktree
  live_observability: Godot AI exact editor session
skill_mode:
  - ten-paces-hidden-moves-workflow-router / BUILD
  - combat-implementation-handoff / implementation-boundary
  - combat-ux-and-accessibility / UI-readability
  - ten-paces-verification / runtime-validation + evidence-report
  - hera-godot:live-editor / live UI inspection
  - test-driven-development / focused RED-GREEN regression
result: MACHINE_VERIFIED_AND_RUNTIME_VERIFIED
```

## 작업 전 문제

현재 전투는 실제 10칸, 공개 거리, `3수 → 3수 → 4수`, `기초 / 무공 / 절초` 선택 consumer를 갖고 있었지만, 상시 노출된 절대 칸 번호와 짙은 기술 패널의 비중 때문에 승인 Reference의 저대비 수묵 전장과 종이 기반 전술 UI의 계층이 화면에 충분히 드러나지 않았다. 이 작업은 기존 규칙을 바꾸지 않고 실제 Combat 화면의 표시 계층만 조정한다.

## 현재 출처 관련성·구현 가능성

- **CURRENT_SOURCE_RELEVANCE_CHECK: NOT_APPLICABLE.** 외부 기술·시장·플랫폼·권리 결정을 새로 만들지 않고, repository의 현재 전투 UI consumer와 사용자가 제공한 스타일 Reference를 실제 Godot 화면에 적용하는 범위다. 외부 검색이 채택 구조를 바꾸지 않는다.
- **FEASIBLE.** `CombatBoardPreview`, `CombatBoardTile`, `ActionSelectionDock`, 세 action panel, action timing, progress control과 live `VerticalSliceShell → CombatBoardPreview`의 실제 node tree를 교차 확인했다.
- **Consumer correction.** 처음의 legacy `BasicCardTray`가 아니라, 현재 제품 화면이 실제로 소비하는 `ActionSelectionDock` 및 Basic/Martial/Ultimate panels에 표현을 적용했다. legacy tray는 derived board에서 숨겨져 있어 presentation consumer로 사용하지 않았다.

## 채택한 구조와 이유

1. 전장 중심은 절대 tile 번호가 아니라 `거리 N` 읽기값으로 만든다. `거리 0`에서만 `[밀착]` 상태를 별도로 표시한다.
2. tile 번호는 휴지 상태에서 숨기고 targetable, hover, keyboard focus 상태에서만 표시한다. 거리 판독과 target feedback이 서로 경쟁하지 않는다.
3. 실제 행동 dock과 모든 탭/카드에 따뜻한 한지 표면, 먹색 텍스트와 테두리, 절제된 금색 focus/선택 피드백을 적용한다. 잠긴 절초는 기존의 disabled 의미를 유지한다.
4. `3/3/4` timing strip은 한지 배경과 먹선 분리선을 사용하고, 실행 CTA만 금색 종이 표면으로 강조한다. CTA의 기존 enable/disable와 진행 규칙은 그대로다.

## 실제 구현 결과

- `src/combat/combat_board_preview.gd`
  - 중앙 `RangeReadoutPanel`과 `거리 N`/`[밀착]` 표시, accessibility 설명, layout snapshot을 추가했다.
- `src/combat/combat_board_tile.gd`
  - resting tile의 절대 번호를 숨기고 target/focus feedback일 때만 복원했다.
- `src/ui/action_selection/action_selection_dock.gd`
  - 실제 source tabs의 active/inactive/focus visual을 종이·먹·금색 토큰으로 통일했다.
- `src/ui/action_selection/basic_action_panel.gd`, `martial_action_panel.gd`, `ultimate_action_panel.gd`
  - 기초 행동, 무공서/기술, 사용 가능한 절초의 surface 및 keyboard focus visual을 같은 표현 체계로 연결했다.
- `src/ui/action_timing_panel.gd`, `src/ui/combat_progress_button.gd`
  - 계획 strip과 `행동계획 실행` control을 한지/먹선/절제 금색 계층으로 변경했다.
- `tests/verify_ink_paper_combat_presentation.gd`
  - 공개 거리 2, `[밀착]`, targetable tile label, 실제 dock 3탭, available ultimate, 3/3/4, CTA style을 live node/theme property로 확인하는 회귀를 추가했다.

## 이미지 후보 상태

```yaml
candidate: misty_ink_landscape_background_01
state: GENERATED_CANDIDATE
purpose: future combat background consumer candidate only
content: warm hanji mist, ink mountains, low sun, distant pavilion, open central combat space
excluded_content: people, weapons, UI, text, numerals, logos
repository_copy_or_runtime_integration: NOT_RUN
reason: user final lock has not yet been given
```

후보는 기존 배경을 교체하지 않았고, canonical asset manifest나 runtime import에도 등록하지 않았다. 이 보고의 code/runtime verification은 해당 후보의 승인·권리·정본 승격이나 runtime integration을 뜻하지 않는다.

## 검증 증거

| 층 | 수행 | 결과 |
|---|---|---|
| Focused RED | 새 presentation verifier를 implementation 전 실행 | 예상된 `RangeReadoutLabel` 부재 실패 확인 |
| Focused GREEN | `verify_ink_paper_combat_presentation.gd` | PASS (`INK_PAPER_COMBAT_PRESENTATION_VERIFY_OK`) |
| Affected Godot regression | combat board/layout/keyboard/focus-order/character-art, action dock/basic/martial/ultimate/integration | 11 PASS |
| Windows Godot runtime | isolated worktree editor → 새 비무행 → 6중4 선택 → 도겸 briefing → 전투 | PASS |
| Runtime interaction | running battle screen에서 기초 `이동` 선택 후 1수 계획 slot에 반영 | PASS |
| Runtime readback | live node tree: `RangeReadoutLabel=거리 2`, ActionTimingPanel, visible ActionSelectionDock with 10 Basic actions | PASS |
| Game diagnostics | current run game log | error 0; helper live |
| Editor diagnostics | current editor log | no errors; pre-existing GDScript warnings only |

실제 runtime capture는 1280×800 framebuffer에서 비어 있지 않고, 중앙 `거리 2`, 두 battler, 10칸 lane, `3수 → 3수 → 4수`, plan strip, 행동 dock이 함께 렌더링되는 것을 확인했다. 한 행동을 선택하면 first timing slot에 `이동`이 표시되고 해당 행동이 preview된다.

### 알려진 baseline 상태

`verify_combat_focus_visuals.gd`의 “ultimate menu must remain keyboard focusable” 실패는 이 branch의 visual change와 무관하게 detached exact `origin/main` (`06378d3b56cd49de35f6234c9b01d3ba69f13621`)에서도 동일하게 재현됐다. 현재 제품은 legacy ultimate menu를 숨기고 ActionSelectionDock를 사용하므로, 이 보고에서 unrelated scope 변경으로 고치거나 PASS로 가장하지 않는다.

## 적대적 검토와 clean exit

1. **정본/범위:** Reference 이미지를 UI 또는 runtime asset으로 복사하지 않았고, combat/review surface 외 화면·규칙·데이터 변경을 배제했다.
2. **실제 consumer:** hidden legacy tray 대신 runtime visible `ActionSelectionDock`를 확인하고 적용했다.
3. **상호작용:** targetable 절대 번호, keyboard focus, disabled ultimate, plan slot, CTA enable semantics을 focused regression과 real input으로 교차 확인했다.
4. **런타임:** exact isolated worktree editor/session에서 actual start flow와 screenshot/node tree를 대조했다. 다른 프로젝트 editor session은 읽거나 변경하지 않았다.
5. **장기 적합성/evidence ceiling:** generated background candidate를 non-canonical 상태로 유지하고, human usability, accessibility-user, Android device, release performance를 PASS로 승격하지 않았다.

`CLEAN_REVIEW_EXIT`: presentation 범위에서 `MUST_FIX_REMAINING: 0`.

## 미검증·남은 위험

- 이 결과는 **Codex가 수행한 Windows local runtime smoke**이며, 독립 Human usability/player approval, accessibility-user 검수, Android actual device, release performance는 `NOT_RUN`이다.
- UI는 기존 1280×800 runtime viewport에서만 live 확인했다. ultrawide와 mobile landscape는 이번 범위에서 실제 실행하지 않았다.
- 새 배경 이미지는 `GENERATED_CANDIDATE`다. 사용자의 final lock 뒤에만 provenance, SHA-256, asset manifest, repository destination readback, real runtime replacement을 별도 수행할 수 있다.
- legacy focus visual verifier failure는 baseline issue이며 ActionSelectionDock의 keyboard navigation과 별도다. 더 넓은 accessibility correction은 fresh scoped package가 필요하다.

### Postscript · 2026-08-30 user final lock

The later explicit final lock, `확정하자`, was handled in the separate bounded record `2026-08-30_INK_MIST_VALLEY_BACKGROUND_PROMOTION_EXECUTION_REPORT.md`. It records the candidate's canon promotion, active runtime replacement, actual Godot combat-screen evidence, and the retained evidence ceiling without rewriting the pre-lock facts above.

## 자동화·학습 반영

- visual UI 작업도 실제 hidden/visible consumer를 먼저 찾아 적용하도록 execution evidence를 남겼다.
- focused test가 theme token과 real child hierarchy를 읽도록 해, 단순 문서/이미지 주장만으로 presentation 완료를 표시하지 않는다.
- initial Godot worktree import scan 뒤 exact project session을 활성화해 runtime test를 수행했다. unrelated `.import` cache artefact는 source commit에 포함하지 않는다.
