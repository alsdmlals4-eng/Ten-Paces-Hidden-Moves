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

---

## 보정 계속 작업 · 거리 중심 대각선 전투와 기본기 카드 읽기성

```yaml
report_id: TEN-OPS-20260830-INK-PAPER-COMBAT-PRESENTATION-02
date: 2026-08-30
work_mode: BUILD
baseline_origin_main: 06378d3b56cd49de35f6234c9b01d3ba69f13621
implementation_branch: codex/ink-paper-combat-presentation-design-20260830
source_head_before_correction: baa2c53357c826d23d27b5e5674e2a8e0bc0ace7
scope: user-directed combat-screen composition and basic-action-card readability correction; no combat-rule, AI, save-schema, card-rule-data, or platform change
status: MACHINE_VERIFIED_AND_WINDOWS_VISIBLE_RUNTIME_VERIFIED
```

### 작업 전 문제

사용자는 실제 실행 화면에서 세 가지 불일치를 확인했다.

1. 휴지 상태에서도 하단의 논리 전투판이 보이는 것처럼 읽혔다.
2. 양쪽 battler가 전경/후경 대각선이 아니라 평면적인 수평 대치로 읽혔다.
3. 기초 행동은 5×2 카드 배열이어도 삽화가 약 25px 높이로 잘려, 제공된 수묵 전술 카드 Reference의 행동 판독성을 충족하지 못했다.

`scenes/combat/combat_board_preview.tscn`은 보정 중 PNG 바이트로 오염되어 Godot parse error(`Expected '['`)를 냈다. 이 파일은 이 package의 source 변경 대상이 아니며 branch `HEAD` object `a5866a1b543d65372a4ad9e0f34a5ef4bddfd638`과 worktree object가 다름을 확인했다. 사용자에게 허용된 자동 복구 범위에서 그 **한 파일만** `HEAD` byte로 복원했고, object equality 및 scene header readback을 확인했다.

### 조사·비교 결과

- **Repository contract:** 기본 전투 화면은 1~10 절대 타일을 상시 표시하지 않고 `거리 N`을 기본 판독값으로 사용한다. 타일은 targeting/focus에서만 문맥적으로 드러나야 한다.
- **Actual consumer:** `combat_board_preview_auto.gd`가 product board를 실제 구성하며, legacy `BasicCardTray`가 아니라 `ActionSelectionDock → BasicActionPanel`이 하단 기본기 UI를 소비한다.
- **Technical relevance: ADOPT.** Godot 공식 `Control` anchor/offset 및 `CanvasItem` visibility/z-order 문서를 확인했다. logical lane을 삭제하지 않고 parent target layer의 visibility를 resting/targeting 상태에 맞춰 분리하고, same live Control consumer의 anchors로 대각선 구성을 적용하는 방식이 현재 엔진 구현과 맞는다.
- **Feasibility: FEASIBLE.** layout, targeting, action placement, timing, keyboard focus, existing basic-card atlas consumer를 cross-read했다. 새 전투 규칙이나 save migration은 필요하지 않았다.

### 채택한 구조와 이유

1. **논리 10칸과 보이는 전장 분리:** resting state에서 `TileLayer`와 foot-anchor guide를 숨기고, targetable tile만 실제 target phase에 다시 보인다. 타일 인덱스·타격·이동·AI·저장 state는 그대로다.
2. **대각선 duel composition:** player는 좌하단의 더 큰 전경, enemy는 우상단의 더 작은 후경으로 고정한다. 중앙 `거리 N`은 두 캐릭터 사이의 살아 있는 combat state를 계속 표시한다.
3. **기초기술 카드:** 10개의 current basic action을 5×2 native card grid로 유지하되, 카드 최소 높이를 96px로 올리고 기존 `basic_illustrations_atlas.svg` region을 58px 이상의 상단 주 시각 영역으로 확장한다. 이름·행동 수·비용·사거리는 image가 아니라 localized Godot label이다.
4. **검증도 current consumer로 교정:** legacy equal-size/tile-foot-anchor/ultimate-menu focus assertions를 현재 product ActionSelectionDock와 distance-first diagonal contract로 교체했다. 논리 tile identity와 action-selection/keyboard routes는 별도 regression으로 보존했다.

### 실제 구현 또는 준비 결과

- `src/combat/combat_board_preview_auto.gd`
  - resting target layer/anchor guide hide, target phase reveal을 추가했다.
  - player-left foreground / enemy-right background / central distance composition, relative scale 및 z-order를 actual board layout에 적용했다.
- `src/ui/action_selection/basic_action_panel.gd`
  - 5×2 basic card grid의 각 native `Button`에 existing atlas `CardIllustration`, `CardName`, `CardFacts` child를 붙이고 illustration-dominant 96px card로 확장했다.
- `tests/verify_ink_paper_combat_presentation.gd`, `verify_basic_action_panel.gd`, `verify_combat_board.gd`, `verify_combat_character_art.gd`, `verify_combat_focus_visuals.gd`
  - resting hidden logical board, contextual target labels, diagonal foreground/background, full illustrated card height, actual ActionSelectionDock ultimate focus, and logical tile identity를 회귀 대상으로 갱신했다.

### TDD와 검증 증거

| 층 | 수행 | 결과 |
|---|---|---|
| Focused RED 1 | resting tile layer, flat battlers, equal scale, 4-column/text-only card expectation을 새 verifier로 실행 | 예상 6개 실패 확인 |
| Focused GREEN 1 | `verify_ink_paper_combat_presentation.gd` | PASS |
| Focused RED 2 | `verify_basic_action_panel.gd`에 full-card height / dominant illustration expectation 추가 | 예상 2개 실패 확인 |
| Focused GREEN 2 | existing atlas를 96px card / 58px+ illustration region으로 확장 | PASS |
| Legacy-contract correction | board/character/focus visual test가 old equal scale, old tile foot anchor, hidden ultimate menu를 요구함을 재현 | current consumer assertion으로 교체 후 PASS |
| Product Godot regression | ink-paper, combat board, basic panel, action dock, action-selection integration, layout accessibility, keyboard accessibility, character art, focus order, focus visuals | 각 script PASS |
| Contract/static | `python tests/check_action_selection_contract.py` | PASS |
| Python suite | `python -m unittest discover -s tests -p 'test_*.py'` | 421 tests PASS |
| Windows visible runtime | isolated worktree에서 `combat_board_preview.tscn`을 visible Godot window로 시작, screen inspection | 1282×832 actual frame: central `거리 2`, no persistent 1–10 lane, player lower-left/larger, enemy upper-right/smaller, 5×2 illustrated basic cards 확인 |

Godot multi-script batch runner는 pass를 낸 basic-panel/keyboard helper process를 남기는 환경 동작을 보였다. command line, worktree, script를 exact-match하여 current-task helper만 종료했고 다른 project process는 변경하지 않았다.

### 기술 이미지 후보 상태

```yaml
candidate_id: TEN-BASIC-TECHNIQUE-INK-ATLAS-01
state: GENERATED_CANDIDATE
generator: built-in image model
candidate_path: C:\Users\user\.codex\generated_images\01a04af4-16f3-7153-96fc-823b2094d386\exec-f2059649-fecd-4456-9557-fc0dbafd6667.png
planned_consumer: ActionSelectionDock → BasicActionPanel, current 10 basic action ids
content: 5×2 coherent full-body ink-wash action poses; no UI text, rules, numbers, logos, or watermark
runtime_integration: NOT_RUN
canon_registration: NOT_RUN
reason: user final lock required before repository copy, SHA-256/provenance record, card-id region map, and runtime reference change
```

현재 runtime에는 기존 canonical basic illustration atlas만 사용된다. 새 후보를 card data나 asset manifest에 아직 쓰지 않았으므로, generated candidate와 approved/canonical/runtime state는 명확히 분리된다.

### 적대적 검토와 clean exit

1. **Core preservation:** `data/`, resolution, AI, save, action IDs/values에 source diff가 없는지 확인했다.
2. **Targeting/input:** resting parent layer hide와 `_begin_targeting_for_anchor` reveal, `verify_combat_board.gd`의 movement/attack targeting flow를 함께 확인했다.
3. **Keyboard/accessibility:** tile label/focus, source tabs, full-momentum available ultimate action의 actual dock focus ring을 regression으로 확인했다.
4. **Visual/layout:** 1440×900 deterministic layout and 1282×832 visible Windows frame 모두에서 central distance, diagonal placement, 5×2 card structure를 readback했다.
5. **Asset/provenance:** existing atlas only runtime; new image stays outside repository as `GENERATED_CANDIDATE`, no false canon promotion.
6. **Diff/cache/recovery:** `.import`, `project.godot`, test logs and unrelated generated cache noise는 source commit에서 제외한다. corrupted scene has been restored byte-for-byte to HEAD before final verification.

`CLEAN_REVIEW_EXIT` for the code/test correction is **conditional**: code scope has no must-fix remaining; new generated technique art waits only for user final lock and then has a separate provenance/integration package.

### 미검증·남은 위험

- **NOT_RUN:** independent human usability/player judgement, accessibility-user review, Android actual-device/touch/back/safe-area/lifecycle, ultrawide and mobile-landscape visual QA, release-performance/release approval.
- The Windows visible frame is a machine runtime observation, not human UX approval.
- The newly shown basic-technique atlas is a candidate, not a shipping asset. It must not be copied or mapped to `data/cards/basic_cards.json` until final lock.
