# Combat Feedback Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 실제 승패·10성 절초 역할과 표시/동작/음향을 일치시킨다.

**Architecture:** 전투 도메인의 순수 outcome 함수와 actor-owned 정의/확정 사건을 소비하는 presentation helper를 사용한다. 기존 board·bridge·VFX·motion·synthesis에 연결하며 새 전투/저장 규칙을 만들지 않는다.

**Tech Stack:** Godot 4.7.1, GDScript, 기존 Python/Godot 회귀, Windows native QA.

**Spec:** `docs/decisions/2026-09-09_COMBAT_FEEDBACK_CORRECTION.md`

## Global Constraints

- 전투 판정·피해·기세·비용·무공서 수치·AI 정보 경계·3/3/4·10전/36행로는 불변이다.
- 저장 schema 1 및 `ten-duel-four-route-one-retry-bimu-actor-bound-save-v1`은 불변이다.
- 화면은 기존 상태/확정 사건을 소비한다. 승패 공식은 도메인 함수 한 곳이 소유하고 board와 run bridge가 함께 소비한다.
- 기존 승인 image/atlas/PDF bytes는 불변이다. 새 raster 생성/등록은 이 교정에 필요하지 않다.
- 모션 감소·음소거·skip·일시중단·COMMITTED/RESOLVED 복원은 기존 결과와 상태를 보존한다.
- Human/UX, 가청 선호, 실제 Android·보조기기·Release performance는 자동 검사로 승인하지 않는다.

## 환경과 파일 책임

프로젝트 convention에 따라 이 plan은 기존 `docs/operations/`에 둔다. root dirty main이나 다른 worktree를 수정하지 않는다. 현재 작업 branch의 one-time protected approval을 controller가 새 exact base에 등록한 뒤 product mutation한다. 에디터 import 전 global-class cache가 없는 fresh worktree에서 native test를 실행하면 setup 오류가 난다. 먼저 exact engine으로 import한다. cache/sidecar를 제품 diff에 포함하지 않는다.

engine은 기존 terminal 분기와 확정 이벤트 projection만, board는 기존 연출 연결만, bridge는 도메인 outcome 소비만, sound bank는 결정적 원본 cue만, 새 profile은 순수 표현 분류만 소유한다. tests는 RED/GREEN·비변경 상태 증거를 소유한다.

### Task 1: 도메인 승패와 종료 cue 일치

**Files:**
- Modify: `src/combat/combat_resolution_engine.gd`, `src/combat/combat_board_preview.gd`, `src/run/vertical_slice_combat_bridge.gd`, `src/ui/combat_sound_bank.gd`.
- Test: `tests/verify_combat_terminal_presentation.gd`, new `tests/verify_combat_outcome_feedback.gd`, new `tests/test_combat_feedback_correction.py`.

**Interfaces:**
- Consumes: 현재 `combat_state`, bridge `_build_vertical_slice_terminal_result()`, board `_finalize_resolved_bundle()`, `CombatSoundBank.get_stream(kind)`.
- Produces: `static func battle_outcome(state: Dictionary) -> String` on CombatResolutionEngine; `victory`, `draw`, `ultimate_release` cue keys on CombatSoundBank. Task 2는 release cue만 소비한다.

- [ ] **Step 1: failing behavioral tests.** 실제 기존 terminal scene에서 enemy 사망 후 `last_sfx_kind == victory`를 기대하게 하고 RED를 확인한다. 새 native test에서 현재 실제 board/bridge를 instantiate해 win/loss/draw 세 상태의 outcome·label·cue가 동일함을 확인한다. 단순 소스 문자열 검사로 대체하지 않는다. Native test는 명시적 실패 출력+nonzero quit이며 Python runner는 timeout을 설정한다.

```gdscript
var cases := [
    {"player": 8, "enemy": 0, "outcome": "win", "cue": "victory", "label": "승리 · 결전 종료"},
    {"player": 0, "enemy": 8, "outcome": "loss", "cue": "defeat", "label": "패배 · 결전 종료"},
    {"player": 0, "enemy": 0, "outcome": "draw", "cue": "draw", "label": "무승부 · 결전 종료"}
]
# Set valid existing state resource current values, preserve max; call existing terminal handoff.
# Assert engine function, board actual label/meta and bridge terminal DTO against each case.
```

- [ ] **Step 2: domain extraction and consumers.** Move the existing bridge calculation, preserving its else-draw semantics. Both consumers call it; board terminal guard remains unchanged. Match logs/labels to the returned outcome. Do not make a UI callback pay rewards or write saves.

The extracted helper must preserve the existing bridge's resource reading exactly: Array or PackedInt32Array health pairs read index0 when nonempty, otherwise0. Enemy<=0/player>0 returns win; player<=0/enemy>0 returns loss; otherwise draw. Test both supported resource shapes rather than copying an Array-only shortcut. Keep the existing terminal guard outside this pure classifier.

- [ ] **Step 3: authored sound cues.** Add the three spec tuples `victory=[0.46,523.25,0.03]`, `draw=[0.36,220.0,0.04]`, `ultimate_release=[0.30,165.0,0.26]`; victory ascending sweep, draw constant pitch, release existing descending sweep. Existing cue sample bytes must compare unchanged before/after. New PCM must be finite, nonempty, in range, distinct and cached by object identity. New cues total under 64KiB PCM. Preserve 22050Hz/16bit mono and original two-player/prewarm/mute/volume paths.

```gdscript
var victory = CombatSoundBank.get_stream("victory")
assert(victory != null and victory.mix_rate == 22050)
assert(victory == CombatSoundBank.get_stream("victory"))
assert(victory.data != CombatSoundBank.get_stream("defeat").data)
assert(CombatSoundBank.get_stream("unknown") == null)
```

- [ ] **Step 4: focused GREEN and regressions.** Run `python -m pytest tests/test_combat_feedback_correction.py -q`; run actual terminal-presentation native test and existing inline-result/terminal-bridge tests discovered from their runner. Test muted result still has identical label/outcome; restoring resolved checkpoint does not re-resolve or duplicate terminal receipt. Record commands/output, not expected outcomes. Do not rerun full durable suite per edit; run whole Python suite once after both tasks.
- [ ] **Step 5: self-review/commit/report.** Explicitly stage only own product/test paths. Full report includes RED/GREEN, exact base/head, all touched and intentionally untouched consumers, output warnings and any concerns. Controller provides independent review.

### Task 2: actor-owned 절초 분류와 실제 성공/방어/실패 표현

**Files:**
- Create: `src/ui/combat_presentation_profile.gd`.
- Modify: `src/combat/combat_board_preview.gd`; `src/combat/combat_resolution_engine.gd` only transient read-only presentation projection.
- Test: extend `tests/test_combat_feedback_correction.py`; new `tests/verify_actor_ultimate_presentation.gd`; adjust directly affected existing ultimate/feedback scene tests without weakening prior requirements.

**Interfaces:**
- Consumes: `resolution_engine.get_actor_card_definition(card_id: String, actor: String) -> Dictionary`; resolved event dictionaries; existing `play_ultimate_motion`, attack/clash/evade/block/hit methods; Task1 `ultimate_release` cue.
- Produces: `static func for_event(definition: Dictionary, event: Dictionary) -> Dictionary` with keys `is_ultimate: bool`, `kind: String`, `motion: String`, `band: int`, `anchor: String`; board `_presentation_profile_for_event(event: Dictionary) -> Dictionary` resolves actor definition before delegating. Profiles never read pending UI or mutate input.

- [ ] **Step 1: RED using actual actor definitions.** Configure TenManual engine using valid per-actor loadout/mastery. Enumerate ten owned star10 definitions, star7 controls, enemy-only ownership and fake prefix/suffix IDs. Run `for_event` with real emitted reachable action events. Separately label synthetic failure/defense counterexamples; test must fail on missing profile/current generic classification before product change. Assert same actor definitions/state/locks are unchanged. The real Xiaoyao resolver currently lacks evade_succeeded context and must be tested as condition-unmet; do not inject that context and call it real production success.

```gdscript
var definition := board.resolution_engine.get_actor_card_definition(card_id, actor)
var profile := CombatPresentationProfile.for_event(definition, resolved_event)
assert(profile.is_ultimate == (definition.get("source", "") == "ultimate" or definition.get("source_kind", "") == "ultimate"))
assert(CombatPresentationProfile.for_event({}, {"card_id": "fake_star10", "actor": "player"}).is_ultimate == false)
```

- [ ] **Step 2: one pure profile.** Implement spec priority: actual clash → failure/interrupt → actual evade/block → eligible successful ultimate → normal attack/utility. Known canonical source fields, not string prefix/suffix, establish identity. `kind` is one of `clash`, `ultimate`, `attack`, `outcome`, or empty. `outcome` retains label but hides VFX and suppresses success attack motion. Failures with actual damage retain existing hit response and text, not full-success bloom. `motion` is `clash`, `ultimate`, `attack`, or empty. Non-damaging recovery/response uses empty motion + self anchor. No new bespoke character motion function is needed.

Implement all spec branches and all thirteen explicit VFX mappings; unknown manual IDs keep band -1. `source=ultimate` must still be a nonempty actor-owned definition; never grant fake IDs ultimate by name. Use `kind`, `motion`, `band`, `anchor`, `is_ultimate` as the five return keys, with neutral values `""`, `""`, `-1`, `"impact"`, `false` for an unclassified event. Target defense outranks ultimate, but the acting response's own evade does not mean its counter target evaded. Completed mixed blocked+positive-damage programs retain ultimate emphasis and real hit; partial failed programs retain failure precedence and their actual hit. All attempted attacks blocked with zero aggregate damage gets block feedback. Internal SPECIAL_CLASH is not an outer clash. A failed requirement with skipped counter must not show attacking success; show condition-unmet while preserving already applied self effects.

- [ ] **Step 3: forward existing facts and wire every consumer.** Add deep-copy projection of existing `failure_reason`, `martial_events`, `actual_hp_hits`, `clash_won`, `evade_succeeded` when present; preserve absence on legacy events. Replace board's prefix checks in duration/windup/motion/feedback/VFX/SFX with the shared profile. VFX `outcome`/unknown-band hides image but keeps label; self anchor sits at actor foot area, not toward enemy. Preserve 0.70 ultimate/0.34 clash/fast/reduced limits. Actual defense/interrupt/clash sound outranks release; use release only for normal eligible ultimate execution. For `martial_failed`, show failure reason/actual damage rather than generic success. Do not execute martial steps to compute presentation.

- [ ] **Step 4: behavioral GREEN.** All ten definitions and three legacy ultimates classify; opposite actor low mastery cannot borrow the other actor's ultimate. Assert actual reachable attack/recovery/Wudang response and Xiaoyao condition-unmet visuals/placement; use explicitly synthetic pure-profile fixtures for currently unreachable self-evade+successful-counter combinations. Test mixed blocked+hit, failed partial hit, interrupted/miss/block/evade priorities, missing texture fallback, reduced-motion/skip/mute state equality, deep-copy of forwarded martial facts, and durable resolved restore no event replay. Native test timeouts bound failures. Run focused tests then one full `python -m pytest -q`; run existing native ultimate/game-feel/inline/actor-binding relevant tests. Controller performs visible captures and independent final review.
- [ ] **Step 5: self-review/commit/report.** Only intended product/test files; no import cache/UID churn, data, art, schema or progression edits. Return report with exact runnable evidence and any deferred concern.

## Controller closeout

Update existing presentation/asset provenance/current-state owners from actual test and visible results, preserving historical sections. Record exact five project full-scope review rounds without counting different lenses as rounds; current Base two-round drift is recorded in research. Run protected approval check, exact-head CI, normal authorized merge, detached-main checks and archive the one-time approval. Native captures are true runtime fixture evidence, not human approval or proof the normal campaign already unlocks higher growth. Continue the remaining growth/event/status/reward/art work after this correction.
