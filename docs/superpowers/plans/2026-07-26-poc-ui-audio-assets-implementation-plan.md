# PoC UI Audio Assets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 승인된 수묵 무협 컨셉과 전투 정보 구조에 맞는 UI·UX·사운드를 구축하고, 외부 에셋 검색·라이선스 감사·부족분 생성·접근성 검증을 완료한다.

**Architecture:** domain event stream을 `CombatPresentationController`와 `AudioEventRouter`가 소비한다. 시각·음향 에셋은 `asset_gap_map.json`과 `asset_ledger.json`에서 출처와 판정을 추적하며, 에셋이 없어도 텍스트·도형·무음 폴백이 작동한다. 외부 에셋 때문에 전투 계약을 변경하지 않는다.

**Tech Stack:** Godot 4.x Control/AudioServer, GDScript, JSON asset ledger, SVG/PNG/WebP/OGG/WAV, current asset stores and licensed libraries, approved image/audio generation tools.

## Global Constraints

- 첫 시선: 10칸·거리 → 양측 자원·상태 → 3/3/4 묶음 → 전조·실행 → 사용 가능 행동 → 진행 가능 이유.
- 색·이미지·모션·음향을 단독 정보 채널로 사용하지 않는다.
- 빠른 재생·즉시 완료·모션 감소에서 판정 결과와 event order는 동일하다.
- 합·방어·회피·필중·피해·효과·중단·잔여타의 원인을 텍스트로 복기할 수 있어야 한다.
- 외부 에셋은 출처 URL, 제작자, 버전, 가격, 라이선스, 취득일, 수정 여부, 적용 위치를 기록한다.
- 라이선스가 불명확한 자산은 사용하지 않는다.
- 적합한 후보가 없는 `GENERATE` 항목만 생성한다.
- 사람·상표·저작물 모방과 출처 불명 스타일 복제를 금지한다.

---

### Task 1: Event matrix and asset gap map

**Files:**
- Create: `docs/assets/p0_ui_audio_event_matrix.md`
- Create: `docs/assets/p0_asset_gap_map.json`
- Create: `docs/assets/p0_asset_ledger.json`
- Create: `tests/check_p0_asset_ledger.py`

**Interfaces:**
- Consumes stable runtime event IDs.
- Produces gap states `EXISTING_ACCEPT`, `EXISTING_ADAPT`, `STORE_CANDIDATE`, `GENERATE_REQUIRED`, `DEFER`.

- [ ] Enumerate screens: manual selection, campaign map, combat HUD, timing slots, action/ultimate list, review overlay, reward, defeat/retry, run result.
- [ ] Enumerate events: telegraph, action start, clash win/loss/tie, evade, sure-hit consume, guard absorb, HP damage, effect trigger, interruption, fortitude, ultimate, reward, retry payment, insufficient currency.
- [ ] For each item record functional purpose, fallback, dimensions/duration, format, priority, and current gap status.
- [ ] Write a failing Python test requiring source/license fields for adopted assets and prompt/tool/source fields for generated assets.
- [ ] Run `python -m unittest tests.check_p0_asset_ledger -v` and verify RED.
- [ ] Create valid empty ledgers with all required schema fields and verify GREEN.
- [ ] Commit as `docs: define PoC UI audio asset matrix`.

### Task 2: Current asset store and library search

**Files:**
- Modify: `docs/assets/p0_asset_ledger.json`
- Create: `docs/assets/p0_asset_search_report.md`

**Interfaces:**
- Each candidate includes `candidate_id`, source URL, creator, version, acquired_at, price, license, commercial_use, modification, attribution, redistribution, format, Godot import notes, style score, readability risk, performance risk, decision.

- [ ] Search current Godot Asset Library, itch.io, OpenGameArt, Kenney, Freesound and other reputable libraries relevant at execution time.
- [ ] Search separately for UI frames/icons, ink textures, combat VFX, UI SFX, weapon impacts, ambience, and BGM.
- [ ] Verify license terms from the original listing or creator license file; do not rely on aggregator summaries alone.
- [ ] Classify every candidate `ADOPT / ADAPT / REJECT / DEFER`; leave `GENERATE` for gaps with no acceptable candidate.
- [ ] Record current price and date; do not purchase paid assets without explicit user approval.
- [ ] Run asset ledger validation and commit as `docs: audit current UI and audio asset candidates`.

### Task 3: UI design tokens and fallback components

**Files:**
- Create: `src/ui/p0_ui_tokens.gd`
- Create: `themes/p0_ink_theme.tres`
- Create: `src/ui/components/status_badge.gd`
- Create: `src/ui/components/focus_ring.gd`
- Create: `src/ui/components/event_log_row.gd`
- Create: `tests/verify_p0_ui_tokens.gd`

**Interfaces:**
- Tokens expose spacing, minimum touch target, text sizes, border widths, semantic state names, and animation durations.
- Components accept data Dictionaries and never calculate combat outcomes.

- [ ] Write RED tests for minimum focus visibility, status label fallback, keyboard focus, and color-independent state names.
- [ ] Implement a low-contrast ink background with high-contrast text and explicit semantic borders; do not hard-code event colors inside combat logic.
- [ ] Ensure missing textures fall back to NinePatch/StyleBoxFlat/Label rendering.
- [ ] Run the UI token verifier at 1440×900, 1280×800, and 960×640 viewport overrides.
- [ ] Commit as `feat: add accessible ink UI foundation`.

### Task 4: Combat HUD and sequential result presentation

**Files:**
- Modify: `src/ui/top_combat_hud.gd`
- Modify: `src/ui/action_timing_panel.gd`
- Modify: `src/ui/combat_log_panel.gd`
- Create: `src/ui/combat_presentation_controller.gd`
- Modify: `scenes/combat/combat_board_preview.tscn`
- Create: `tests/verify_p0_ui_event_contract.gd`

**Interfaces:**
- `CombatPresentationController.enqueue(events: Array[Dictionary])`.
- Signals: `event_started(event)`, `event_completed(event)`, `queue_completed()`.

- [ ] Test HUD displays HP, stamina, internal, momentum, guard, evade charges, sure-hit stacks, empowerment, and fortitude.
- [ ] Test each hit displays `hit_index/total_hits`, raw clash values, guard absorption, HP damage, effect, interruption, and remaining-hit cancellation.
- [ ] Test skipped animation retains identical log rows and final state.
- [ ] Test sure-hit `-1` appears only on actual evade bypass and non-consumption reason appears for canceled/no-evade cases.
- [ ] Implement event-driven presentation and commit as `feat: present sequential combat events`.

### Task 5: Campaign, reward, and retry UX

**Files:**
- Modify: `src/ui/manual_selection_screen.gd`
- Modify: `src/ui/poc_campaign_screen.gd`
- Modify: `src/ui/major_duel_reward_screen.gd`
- Create: `scenes/run/defeat_retry_screen.tscn`
- Create: `src/ui/defeat_retry_screen.gd`
- Create: `tests/verify_p0_run_ui_contract.gd`

**Interfaces:**
- UI consumes service-generated options and emits selected IDs only.

- [ ] Test manual screen requires 4/6 unique selections and shows mastery 3.
- [ ] Test route UI compares node risk/reward before entry and does not expose future hidden data.
- [ ] Test reward UI shows free6, focused5+free3, and faction manual3 with restriction and total value.
- [ ] Test defeat UI shows snapshot rollback scope, retry count, next cost 1/2/3, balance, disabled state, abandon, and title return.
- [ ] Implement keyboard navigation and explicit focus restoration after modal close.
- [ ] Commit as `feat: add campaign reward and retry UX`.

### Task 6: Audio event router and bus policy

**Files:**
- Create: `src/audio/audio_event_router.gd`
- Create: `data/audio/p0_audio_event_map.json`
- Modify: `project.godot` audio buses or add `default_bus_layout.tres`.
- Create: `tests/verify_p0_audio_event_router.gd`

**Interfaces:**
- Buses: `Master`, `Music`, `SFX`, `UI`, `Ambience`.
- `play_event(event_id: StringName, payload: Dictionary) -> void`.
- Per-event policy: priority, polyphony limit, cooldown, bus, pitch range, fallback silence.

- [ ] Write RED tests for event-to-bus mapping, missing asset silent fallback, clash/HP/interruption priority, and multi-hit polyphony limits.
- [ ] Implement router independent from combat state mutation.
- [ ] Add user volume controls and mute persistence.
- [ ] Verify audio disabled does not alter event completion or input unlock.
- [ ] Commit as `feat: route combat events to accessible audio buses`.

### Task 7: Adapt or generate missing visual assets

**Files:**
- Modify: `docs/assets/p0_asset_gap_map.json`
- Modify: `docs/assets/p0_asset_ledger.json`
- Create under: `assets/ui/p0/`, `assets/vfx/p0/`, `assets/source/p0/`

**Interfaces:**
- Every generated visual stores prompt/spec metadata in the ledger and a source/edit trail.

- [ ] Freeze delivery specs: pixel dimensions, aspect ratio, transparent background, state variants, nine-slice margins, loop frames, import compression.
- [ ] Adapt `ADAPT` candidates only within license terms.
- [ ] Generate only `GENERATE_REQUIRED` items; use image generation for icons, panels, textures, and non-branded VFX where appropriate.
- [ ] Check visual consistency, silhouette, grayscale distinction, and 960×640 readability.
- [ ] Import into Godot with source files separated from runtime exports.
- [ ] Commit each coherent asset family separately with its ledger update.

### Task 8: Adapt or create missing audio assets

**Files:**
- Modify: `docs/assets/p0_asset_gap_map.json`
- Modify: `docs/assets/p0_asset_ledger.json`
- Create under: `assets/audio/p0/ui/`, `assets/audio/p0/combat/`, `assets/audio/p0/ambience/`, `assets/audio/p0/music/`

- [ ] Freeze event duration, peak level, loop points, sample rate, channel count, and variation count.
- [ ] Prefer licensed store/library candidates; trim, normalize, loop, and layer only when license permits modification.
- [ ] Create procedural/simple cues for remaining gaps; use an external audio-capable production pipeline for music or complex SFX when required.
- [ ] Ensure repeated multi-hit playback does not clip or mask interruption/defeat cues.
- [ ] Record source/edit chain and commit coherent audio families separately.

### Task 9: Accessibility, fatigue, and performance validation

**Files:**
- Create: `tests/verify_p0_accessibility_modes.gd`
- Create: `docs/decisions/<date>_P0_UI_AUDIO_ASSET_EVIDENCE.md`
- Modify: `docs/08_TEST_CHECKLIST.md`

- [ ] Run UI event contract, run UI contract, audio router, asset ledger, and viewport tests.
- [ ] Run with reduced motion, instant presentation, keyboard-only, muted audio, grayscale capture, and 960×640.
- [ ] Measure event queue duration, dropped frames, audio voice count, loaded texture memory, and package size.
- [ ] Conduct human tasks: explain a multi-hit clash, find next retry cost, compare reward options, identify why sure-hit consumed or did not consume.
- [ ] Record observed evidence separately from automated evidence.
- [ ] Return to REVIEW with `PASS / PARTIAL / FAIL / NOT_RUN` per category.
