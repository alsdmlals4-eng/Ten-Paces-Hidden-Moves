# Combat Layout Correction Implementation Plan

> Current state: TASKS_1_3_SOURCE_COMMITTED / MACHINE_AND_BOUNDED_NATIVE_VERIFIED / PROTECTED_DELIVERY_PENDING. Exact source eda26a97f25a931ac02ba739d5c4921720512d41:499PASS and policy captures003–035, with failed/limited captures explicitly separated in the execution report and capture companion. Controller ratified sections3–5 and Tasks1–3 under TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01. Historical draft qualifiers below describe pre-ratification provenance, not an extra approval pause or unperformed implementation.
> Controller plan derived from the fully read and R1-corrected reviewed-working draft, SHA-256 `0626f2956be878d16837cfabcf04d388b774a8fc8962f0055eefb0b119e47a61`.
> Implementation base: `544fcbbaff0448edf265e381c70ad3d48fd61b7b`; protected baseline: `477697842bf14d95e670f01b0fe815e384b53658`.
> Decision: `docs/decisions/2026-09-09_COMBAT_LAYOUT_CORRECTION.md`.
> Execution route: controller-owned subagent-driven development, separate implementer/reviewer, test-first, one bounded package. The historical draft's no-dispatch sentence means the draft is not self-authorizing; it does not forbid controller task delegation.

# Combat Layout Correction — Ratified Implementation Specification

> Status: `CONTROLLER_RATIFIED_SCOPE_IMPLEMENTED_AND_BOUNDED_VERIFIED`. Separate independent review closed L1–5/R1 and a later final-source review completed five full-scope rounds. Task/evidence history is in `2026-09-09_COMBAT_LAYOUT_EXECUTION_REPORT.md`; final Human/asset approval is not implied.
>
> For agentic workers: use the controller-selected subagent-driven route. Controller dispatches one implementer and a different reviewer; no independent child dispatch, asset generation, push or merge. The 3-product/7-test-workflow scope and actual Task RED/GREEN gates apply.

**Goal:** restore the approved three-surface frontal duel, retain one state-derived execution stage and shared actor anchors, and separate current-action text from animated feedback without changing combat or assets.

**Architecture:** three existing product owners: auto-board composition, base-board presentation hooks/lanes, and character renderer geometry. No new layout service, state machine, scene, node, resource, image, sound, dependency or save field. Unimplemented sibling domain S0–S4 is not a dependency.

**Tech stack:** current Godot4.7.1/GDScript Control geometry and existing native/Python verification.

**Spec:** sections3–5 below, approved sources in section2, and a controller-owned explicit follow-up Decision before BUILD. Ratio/diagnostic/resize recommendations are not already user-final-approved preferences.

## 1. Baseline and global constraints

- Product sources fresh-read at D `8509813e0b0bb3df8f69ae5fb4baf410d02df7aa`; merged main `477697842bf14d95e670f01b0fe815e384b53658` has the same product. Controller reports docs-only closeout544 and prepared G `.worktrees/combat-layout-20260909`. Future implementer independently bootstraps G and records its full exact HEAD/owners/diff before mutation. This writer did not modify or run G.
- Preserve single CTA, current-only reveal, 3/3/4, logical positions/distance0/directions, actor-owned effects, hidden-plan AI boundary, reservations, reduced-motion/mute/skip, domain terminal ownership, and all v1 save/DTO/store/campaign behavior.
- Preserve source asset bytes, draw style, facing/mirroring, atlas regions, animation offsets/scales/durations, sound and import settings. Restoring existing background consumption to its approved stage-only scope is required; it is not a new image/style.
- Hard **visible-ink battler height** cap:52% of active duel height, including existing animation peak. Proposed deterministic **idle visible-ink target:46%**. Proposed tuning band is `[0.46, min(0.50, 0.52 / 1.12)]`, approximately46–46.428571%; default46% peaks at51.52%. No48% default or unconstrained46–50% idle band remains.
- Initial logical distance2 retains at least42% horizontal foot separation. Later existing distance mapping remains: distance0→38%, distance1→41.25%, distance2→44.5%, distance4+→51%. Existing presentation motions may transiently change separation; no always-42% rule.
- Reference viewports:1280×720,1280×800,1920×1080. Retain960×640 minimum and1440×900 compatibility. At960 require positive geometry, text/ink containment and52% cap; the reference lower target is not forced when it cannot fit. Failure is not permission to crop assets/hide text.
- Exactly3 allowed product files,5 native test files,1 Python test and1 workflow (section6). The old two-product-file restriction is superseded only for renderer-owned bounds/cache and the explicit MOVE-only resize hook. No new file split/general refactor.
- Ratification, independent review, native/full-suite/capture and delivery remain controller-owned. Draft writing is not product approval.

## 2. Authority, source relevance and evidence ceiling

Read first: AGENTS, BASE_RULES_VERSION, integrated work instruction, ACTIVE_CONTEXT/current planning owners, adapter/snapshot/Skill registry and actual adopted validator. D's existing approved wrapper was independently read-only PASS using its actual fe720 baseline/approval. Do not reuse that approval on G or confuse it with approval-free docs closeout.

Relevant owners:

- `docs/UX_UI_SYSTEM.md`, `docs/07_COMBAT_UI_SPEC.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `docs/10_COMBAT_PRESENTATION_PLAN.md`, `docs/18_VISUAL_ART_DIRECTION_DOT_INK_WASH_DECISION.md`.
- `docs/design/2026-09-01_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT.md`.
- `docs/decisions/2026-09-02_SCREEN_PARTITION_AND_DISTANT_FRONTAL_DUEL_DECISION.md`:18–21/50–54 require stage-only background/banner;67 says **initial**42% separation;68 owns52% cap. `BattleBackground.get_duel_floor_y` owns the floor.
- `docs/decisions/2026-09-04_THREE_BRANCH_FOUR_CHOICE_JIANGHU_AND_HUMAN_BLUEPRINT_DECISION.md`: three surfaces, single CTA closes planning, current-only compare, grounded presentation-only motion. Its narrow CTA/review supersession does not authorize full-viewport combat background.
- Existing visual/source owners and `docs/operations/2026-09-09_COMBAT_FEEDBACK_EXECUTION_REPORT.md`. Supplemental Peng screenshot shows narrow duel/black lower gap and impact/card overlap, not new-revision runtime evidence or Human acceptance.

`CURRENT_SOURCE_RELEVANCE_CHECK = REUSED_CURRENT_WITH_REPOSITORY_REFRESH`: reuse `docs/reviews/2026-09-01_FRONTAL_DUEL_REVEAL_AND_CARD_BENCHMARK.md` (10-case spatial/current-action dimension) and `docs/reviews/2026-09-09_COMBAT_FEEDBACK_BENCHMARK.md` (10-case outcome/identity/accessibility adjacency). No new outside claim. ADAPT distinct planning/execution and current-only comparison; AVOID future timelines, hidden plans, deck metaphors and foreign art/interface copying. Benchmarks do not approve46%, pixels or Human readability. Controller separately refreshed official CanvasItem/Tween/Image documentation; this writer makes no independent web-verification claim.

Writing-plans discipline is used within the requested ignored/no-product boundary. This is not a general theme or live-editor redesign. Machine geometry/capture remains separate from Human preference, physical input/audio, accessibility users, Android, rights and release.

## 3. Source facts versus corrections

| Boundary | Actual source fact | Correction / authority status |
|---|---|---|
| Execution stage | Auto layout restores planning50% after base timing snapshots. CTA hides planning without setting _plan_locked. | One mode derived from actual state/visibility; implementation correction. |
| Background scope | Base uses upper visual rect; auto expansion uses full viewport. | Both conflict with Sep02 stage-only owner. Active duel rect for background/banner/tint in both modes; source restoration. |
| Actor height | Control height is not visible art: draw uses×1.08, alpha used rect, mirrored pivot transform and visual_scale (max1.12). | Renderer-owned measured bounds/shared math. Idle46% is a proposed bounded ratio, not existing fact. |
| Ground/motion | Hidden timing y clamps feet; snapshot motion targets hidden tile anchors then snaps frontal. | Same pure frontal anchor calculation for layout and actual snapshot movement; no logical position change. |
| Feedback lanes | Independent overlay/label/VFX; show callers always enable VFX after placement. | Execution-only lanes, transformed-peak-safe fit and honored boolean placement result. |
| Separation | Initial distance2=44.5%; contact=38% with existing formula. | Initial-only42% assertion; later mapping unchanged. |

Original reviewed draft SHA `a0b6e0585e544b71d4da1de0d11ef7fd32cebf68e68b341b244941d0a26f1c15` was CHANGES_REQUIRED in `layout-independent-review.md` (L1–L5). This revision absorbs them and the controller's stage-only conflict. The writer was the previous reviewer; this revision does not self-approve.

## 4. State-derived stage, visible bounds and shared anchors

### 4.1 Single layout mode

In `combat_board_preview_auto.gd`:

```gdscript
func _uses_expanded_execution_layout() -> bool:
    var planning_is_visible := is_instance_valid(planning_surface) and planning_surface.visible
    return not planning_is_visible or _presentation_state not in ["planning", "next_bundle_ready"]
```

Add `_apply_state_derived_product_layout() -> void` with this exact order: validate ready nodes/positive size; select mode; run existing product-dock layout for planning or set expanded rect below; apply stage-only visual rects; compose measured actors/shared anchors; publish execution lanes or clear them for planning. It must not mutate combat state or re-enter `_layout_board`. Preserve dock visibility/focus semantics.

The auto-board owns only `_last_applied_active_duel_rect: Rect2` plus `_has_applied_active_duel_rect: bool` as a bounded geometry baseline. Compute and validate the intended final active duel rect independently of the transient post-`super` rect. Compare its position and size with the last successfully applied final rect component-wise using tolerance `0.01` board-local pixels. A real geometry change requires a valid prior final rect and at least one differing component beyond tolerance. Update this baseline only after the complete actor/stage/lane application succeeds; invalid/startup geometry neither cancels MOVE nor replaces the baseline. No timer, observer, process callback, history or additional product path.

```gdscript
var duel_y := top_hud.position.y + top_hud.size.y + 8.0 + 5.0
var expanded_duel_rect := Rect2(0.0, duel_y, size.x, size.y - duel_y)
```

Planning retains `planning_top = clampf(size.y * 0.50, 260.0, size.y - 242.0)` and existing duel-gap arithmetic. `_layout_board` calls super then the helper once; `_expand_locked_duel_stage` delegates without a second formula. Existing presentation-state/resolution-surface/plan-locked-surface callbacks request that helper after actual changes as needed. Do not re-show hidden controls or change lock semantics. Startup invalid nodes return; no manufactured positive stage. Deferred settling is allowed only for existing Control minimum-size behavior and must be checked both immediately and after settlement.

### 4.2 Stage-only visual binding and actual floor

Both common base `_layout_screen_surfaces` and auto expansion pass **active_duel_rect**, not viewport or upper-HUD rect, to existing background/banner `set_stage_rect`. Apply the identical board-local rect to the readability tint. Keep background/banner scripts/assets intact; Title's independent full-viewport consumer stays untouched. No blanket clipping or art crop workaround.

Only after setting actual stage rects, read `battle_background.get_duel_floor_y(size)`. This is the board-local floor derived from displayed background/crop. Remove hidden timing-panel/_plan_locked foot clamps. If ink cannot fit the active stage at an allowed size, return exact failed geometry for review; do not move feet off the source floor, crop actors or hide text.

### 4.3 Renderer-owned visible-ink bounds and bounded cache

Third product owner: `src/combat/combat_character_placeholder.gd`. Add bounded methods:

```gdscript
func get_idle_art_height_per_node_height() -> float
func get_visible_art_bounds_local(include_motion: bool = true) -> Rect2
func get_visible_art_bounds_global(include_motion: bool = true) -> Rect2
func get_existing_motion_peak_scale() -> float
func _sprite_rect_local() -> Rect2
```

The method declarations are interface signatures, not empty implementation bodies. Required algorithms:

1. `_sprite_rect_local`: current pre-motion node-local rect, `sprite_height = size.y*1.08`, origin `((size.x-sprite_height)/2, size.y-sprite_height*_sprite_foot_ratio)`, square size `sprite_height`. Existing `_draw` consumes the same rect relative to its ground pivot; no draw-style/value change.
2. Cache source dimensions/identity/alpha used rect when `_load_character_art` already obtains the new texture image to compute foot ratio. Reuse that same `Image.get_used_rect()` result. Bounded current-texture cache per actor, replaced on texture change; no unbounded dictionary or per-layout/per-frame image read/load.
3. Map the cached occupied image subrect proportionally into `_sprite_rect_local`. Transform its four corners around the existing ground pivot with enemy mirroring, current visual_scale and visual_offset. Form local AABB; global method applies node global transform to its corners. `include_motion=false` uses offset0/scale1 but preserves asset/mirror/node transform. Getters do not mutate render state.
4. Idle height factor is `1.08 * alpha_used_height / source_image_height`. Peak getter exposes existing maximum1.12 without changing any animation number. Tests enumerate/sample existing motion types; a future higher peak must invalidate the old bound.
5. Missing/empty art or invalid source dimensions returns empty bounds/factor0. Tests fail meaningfully; primitive fallback rendering remains as before but cannot count as asset-bound evidence.

Auto sizing:

```gdscript
var max_idle_ratio := minf(0.50, 0.52 / actor.get_existing_motion_peak_scale())
var idle_ratio := clampf(0.46, 0.46, max_idle_ratio)
var ink_factor := actor.get_idle_art_height_per_node_height()
# Require ink_factor > 0 and actor.character_height_ratio > 0 before division.
var node_height := active_duel_rect.size.y * idle_ratio / ink_factor
actor.set_dimensions(node_height / actor.character_height_ratio)
```

Invalid factor/ratio or `max_idle_ratio < 0.46` is a diagnostic/test failure, not a0.001 fallback. Idle visible ink becomes46% regardless of transparent margins; peak becomes51.52%. Measure actual transformed bounds, not node height. Test player v2, masked enemy v2 and Dogyeom candidate/mirroring. Preserve all existing nonmove offsets/scales/facing/contact behavior. At minimum960 compatibility a smaller target, if genuinely necessary, is a separately recorded bounded result below the reference lower band; never exceed52% or conceal failure at a required reference viewport.

### 4.4 Shared frontal anchor and actual timing movement

Add:

```gdscript
func _frontal_anchor_pair(player_tile: int, enemy_tile: int, floor_y: float) -> Dictionary
# Auto pure function: {"player": Vector2, "enemy": Vector2}, board-local.

func _presentation_anchor_for_actor(actor_key: String) -> Vector2
# Base presentation fallback preserves old tile-anchor/contact-offset result.
# Auto override returns the current shared frontal pair member.
```

Pure x formula remains exact: normalized distance `clamp(abs(enemy-player)/4,0,1)`; half separation `lerp(size.x*0.19,size.x*0.255,distance)`; center drift `clamp(((player+enemy)/2-5.5)*size.x*0.014,-size.x*0.05,size.x*0.05)`. Both y values equal the supplied background floor. No future-plan access or logical mutation.

CTA/layout/end/next planning use this pair. In base `_apply_timing_snapshot`, replace direct hidden tile targets and their separate contact offsets with the presentation hook. Preserve authoritative state application, _defer_character_snap, existing awaits, duration and scheduling. Compare board-local current feet to board-local targets. Base fallback applies its old contact adjustment once; auto adds none. Do not repurpose the gameplay/planning `get_tile_foot_anchor` globally.

**Controller-endorsed proposed resize default:** only an actual stage/viewport geometry change established against the last-successful final rect above (never the transient post-`super` planning rect) while an actor's `motion_state=="move"` cancels that existing MOVE tween, resets idle and places it on the new shared anchor. Add bounded `snap_move_for_relayout(anchor: Vector2)` in the existing character owner if needed: check MOVE; call existing stop helper; idle reset; place foot. It is a no-op for non-MOVE. Do not cancel on every layout, ordinary snapshot end or same-size routine callback; do not cancel other motion types. The timing coroutine keeps its original schedule/final snap; no second resolution, new timer, await or duplicate continuation. This resize-only presentation snap is explicit technical fill, not a pre-existing behavior claim.

## 5. Execution-only lanes and animated VFX envelope

### 5.1 Positive execution geometry and planning reset

Only expanded execution derives lanes. Planning calls `_clear_presentation_layout_lanes()`: invalidate stored rectangles and clear/hide transient overlay/label/VFX via existing stop/clear helpers. Never clear while a timing/review/terminal state is still active, hide executed required text to pass, or change when next planning becomes available. Planning does not attempt a270px comparison lane inside a204px stage.

```gdscript
var gap := clampf(size.y * 0.015, 10.0, 18.0)
var compare_height := clampf(active_duel_rect.size.y * 0.40, 270.0, 340.0)
var compare_rect := Rect2(active_duel_rect.position, Vector2(active_duel_rect.size.x, compare_height))
var inset := clampf(size.x * 0.04, 24.0, 72.0)
var impact_y := compare_rect.end.y + gap
var impact_height := active_duel_rect.end.y - gap - impact_y
var impact_rect := Rect2(active_duel_rect.position.x + inset, impact_y, active_duel_rect.size.x - 2.0 * inset, impact_height)
var label_height := clampf(impact_height * 0.20, 64.0, 96.0)
var label_rect := Rect2(impact_rect.position.x + impact_rect.size.x * 0.15, impact_y, impact_rect.size.x * 0.70, label_height)
var vfx_y := label_rect.end.y + 8.0
var vfx_rect := Rect2(impact_rect.position.x, vfx_y, impact_rect.size.x, impact_rect.end.y - vfx_y)
```

Before publication, require finite positive sizes, stage enclosure and pairwise nonintersection for compare/label/VFX. Do not convert negative remaining space to `max(1,...)`. Invalid execution geometry is an exact verifier/capture failure, not permission to hide required action/result text. VFX alone may fail closed.

Base methods:

```gdscript
func _apply_presentation_layout_lanes(compare_rect: Rect2, label_rect: Rect2, vfx_rect: Rect2) -> bool
func _clear_presentation_layout_lanes() -> void
func _place_feedback_vfx(event: Dictionary, kind: String) -> bool
```

Store board-local rectangles. Convert board-local corners through global space into overlay-local coordinates for existing `configure_presentation_rect`; set label geometry in its own parent space likewise. Expose lanes through the existing board layout snapshot as transient diagnostics, never DTO/event mutations. Preserve nodes/z30–31–32/content/mouse filters/texture choice. Overlay internals remain untouched; actual deferred container settlement must prove child/text containment.

### 5.2 Peak-safe fitting and boolean callers

Keep the event-derived preferred center and base effect size. First convert global current actor feet into board-local coordinates using inverse global transform; preserve self/target/clash anchor preference. Convert final geometry into VFX-parent space; never mix global feet with board-local safe rect.

Use complete centered animation envelope: existing peak `p=1.08` for ultimate, `p=1.0` for ordinary attack/clash. Preserve animator values/durations. Desired size d, safe size s:

```gdscript
var fit := minf(1.0, minf(s.x / (d.x * p), s.y / (d.y * p)))
var fitted_size := d * fit
var peak_half := fitted_size * p * 0.5
var fitted_center := Vector2(
    clampf(preferred_center.x, safe_rect.position.x + peak_half.x, safe_rect.end.x - peak_half.x),
    clampf(preferred_center.y, safe_rect.position.y + peak_half.y, safe_rect.end.y - peak_half.y)
)
```

Uniform fit preserves existing display aspect. Node rect is centered at fitted_center with centered pivot; atlas bytes/regions remain unchanged. Test parent/global transform effects. Visible resize re-fits from the existing retained event/kind without restarting alpha/scale tween or replaying audio. Invalid space stops/hides only VFX and records the finite diagnostic; no per-frame observer.

Both existing show callers honor the result before enabling/animating:

```gdscript
if not _place_feedback_vfx(event, kind):
    return
presentation_vfx.visible = true
```

Placement failure stops the existing VFX tween, hides it and sets finite metadata `presentation_vfx_layout_status="LANE_INVALID"`; success sets `"OK"`, planning clear `"INACTIVE"`. This is **new proposed technical metadata**, not an existing diagnostic (none exists). No unbounded history, repeated warning, new UI or resource load. It never suppresses required text. Resize/tween cannot resurrect cleared feedback.

### 5.3 Source-derived reference geometry

Arithmetic only, not live measurements. Floor column is the guaranteed lower bound `duel_y + duel_h*0.72`; actual background floor is authoritative if crop yields greater. Planning has no visible comparison/label/VFX lanes.

| Viewport | HUD h | Expanded duel y/h | Compare h / gap | Impact h / label h / VFX h | Idle46% / peak51.52% / cap52% | Stage floor lower bound | Planning top / duel h / idle46% |
|---|---:|---:|---:|---:|---:|---:|---:|
|1280×720|130.0|151.0 /569.0|270.0 /10.8|277.4 /64.0 /205.4|261.7 /293.1 /295.9|560.7|360.0 /204.0 /93.8|
|1280×800|144.0|165.0 /635.0|270.0 /12.0|341.0 /68.2 /264.8|292.1 /327.2 /330.2|622.2|400.0 /230.0 /105.8|
|1920×1080|162.0|183.0 /897.0|340.0 /16.2|524.6 /96.0 /420.6|412.6 /462.1 /466.4|828.8|540.0 /352.0 /161.9|

Require actual global positive rects, stage-only background/banner/tint, allowed idle ink ratio and≤52% throughout motion, feet on source floor, initial separation≥42%, unchanged later mapping, contained/nonoverlapping execution lanes, contained visible comparison children/result/label, and peak-safe VFX. Actors/background may visually underlie text lanes; that is not a Human-legibility claim. Unreadable imagery must be reported even if rectangles pass.

## 6. Exact future implementation surface and asset invariants

**Product files (3):**

1. `src/combat/combat_board_preview_auto.gd`: state-derived composition, stage-only rect, ink sizing, pure frontal pair/override, execution lanes.
2. `src/combat/combat_board_preview.gd`: common stage-only binding, snapshot anchor hook/base fallback, lane/snapshot methods, bool fit/callers and visible-resize VFX handling.
3. `src/combat/combat_character_placeholder.gd`: current-texture used-alpha cache, shared draw/bounds rect math, peak getter and bounded MOVE-only resize snap. No art/nonmove-animation values changed.

**Test/workflow files (7):**

4. `tests/verify_frontal_duel_screen_partition.gd`
5. `tests/verify_combat_action_reveal.gd`
6. `tests/verify_actor_ultimate_presentation.gd`
7. `tests/verify_combat_layout_accessibility.gd`
8. `tests/test_combat_feedback_correction.py`
9. `.github/workflows/validate-ten-manual-product-gate.yml`
10. `tests/verify_inline_combat_results.gd`: only current-visible-slot overlap guard plus positive/exact current visibility assertions, after actual six hidden-slot false positives were independently traced.

Untouched regressions: all other inline-result assertions, frontal plan lock, presentation controls/SFX/terminal, both scenes, reveal overlay, background/banner scripts, domain/AI/manuals/data, all save/store/codec/campaign paths and assets. Controller separately owns canon/Decision/report/protected-approval changes; they are not covertly assigned to this10-file implementation package.

Asset bytes below remain exact; status/rights are not upgraded:

| Asset under assets/ | SHA-256 |
|---|---|
|characters/player_wanderer_battler_rgba_v2.png|383fd9a62de43d1b9c5c6c38f1ad9d537d8f088c08e4f25e23e974b87dc08864|
|characters/enemy_masked_battler_rgba_v2.png|0841505d275ca970d7d085d7ab206788276517d2290a63960d829e657dfbe17f|
|characters/dogyeom_combat_battler_01_v1.png|064a8772406c743bbe6b252c138b4333c88b00b90a0ba905cce9ea18773539c9|
|vfx/attack_clash_ink_gold_atlas_rgba_v1.png|0859c714728608744b3f016e03c02f7b0e18d86b0b0ced191a2d5ec25ce2553f|
|backgrounds/atlas_blue_ink_courtyard_v1.png|608d67e244ab3bc0c579ff04b359682a20c5189236117ff5390b0d7182dd092c|
|foregrounds/frontal_courtyard_banner_overlay_01_v1.png|56667318d441f7e74accfc08f7038500e5d3b313bc68a15387f9c3c62608d7e2|

## 7. Prospective TDD execution plan

After controller ratification/handoff only. `godot` means the approved exact binary in a clean imported implementation environment. Syntax/import errors are setup failures, not behavioral RED. Preserve existing assertions unless a precisely documented obsolete assertion conflicts with this ratified source correction; never weaken unrelated coverage.

### Task1 — Measured actors, stage ownership and one motion-anchor path

**Files:** screen-partition native test first, then3 product files for sections4.1–4.4. **Consumes:** CTA, timing snapshots, source floor. **Produces:** renderer bounds/factor/peak, state-derived stage and presentation anchor.

- [x] Extend existing test across3 reference sizes, keeping planning/3/3/4/HUD checks. Exercise actual player/masked enemy plus separate actual Dogyeom configuration. Record immutable baseline domain snapshots and source hashes.
- [x] Before calling new getter, assert `has_method` and report descriptive missing-interface failure, not parse error. Independently derive expected occupied bounds from the loaded source once in test setup and compare with draw-transform math; do not use the same production helper as sole oracle.
- [x] Drive real plan fill/CTA and each actual timing. Check immediate expanded stage, stage/background/banner/tint global equality and separation from HUD/planning. Next planning returns50%, visible controls and empty hidden lanes.
- [x] Assert idle visible0.46 with rounding tolerance0.002, allowed upper `min(.50,.52/1.12)`, positive bounds and stage enclosure. Sample real nonzero-duration movement/attack/evade/block/hit/clash/ultimate frames, including peak/recovery, all≤52%. Also check the complete predicted envelope so a skipped sample cannot hide a violation.
- [x] Drive actual movement timing and verify common floor/targets before/during/after, not hidden tile anchors. Test initial distance2≥42%, distance1/contact mapping, reduced motion, shifted board origin and actual stage-size change during MOVE. Assert same final logical resources/positions, one resolution and unchanged skip/timing outcome.
- [x] Begin a real nonzero MOVE, then invoke same-size direct layout and separately the existing state/deferred-layout path. Both preserve the in-flight motion/sequence and ordinary completion. A true viewport or active-stage geometry change snaps only once, preserves logical state and one resolver invocation, creates no duplicate coroutine continuation, and the later snapshot-final callback stays stable.
- [x] RED: `godot --headless --path . --script res://tests/verify_frontal_duel_screen_partition.gd`. Expected actual failures: stage reset/full-background consumer, missing rendered-bound API, wrong visible ratio/floor/tile movement. Record actual output; prediction is not evidence.
- [x] Implement sections4.1–4.4 in existing owners. Preserve original nonmove motion numbers/gameplay methods. MOVE-only resize policy applies only to changed geometry, not routine layout.
- [x] GREEN: repeat screen-partition, then `godot --headless --path . --script res://tests/verify_frontal_duel_plan_lock.gd` and `godot --headless --path . --script res://tests/verify_inline_combat_results.gd`.
- [x] Independent task review, then only controller-authorized owned-path commit. No push/merge authority is implied.

Verifier assertion shape inside the actual event/viewport fixture:

```gdscript
var stage_global := board.duel_stage_surface.get_global_rect()
var ink_global: Rect2 = actor.get_visible_art_bounds_global(true)
_expect(ink_global.has_area(), "actual ink must be positive: %s" % ink_global)
_expect(stage_global.encloses(ink_global), "ink outside stage: %s / %s" % [ink_global, stage_global])
_expect(ink_global.size.y <= stage_global.size.y * 0.52 + 0.5, "animated ink exceeds52%: %s" % ink_global)
```

### Task2 — Execution-only text and animated VFX lanes

**Files:** action-reveal, actor-ultimate and layout-accessibility native tests first; base/auto section5 afterward. **Consumes:** Task1 active stage/anchors. **Produces:** lane methods/snapshot fields and bool peak-safe fit.

- [x] Extend actual ordinary CTA/timing and existing eligible Peng/legacy ultimate routes at all3 sizes. Use nonzero-duration impact/recovery and actual event/motion phase. Synthetic/factless response controls stay separately labelled; no success context injection.
- [x] Inspect actual transformed child/name/facts/outcome/result/label/VFX global bounds after existing overlay container settlement. Test concrete Korean result `파공검기 적중으로 상대의 다음 행동이 중단되어 전투 불능 직전입니다.` and name `창궁무애검법 연속 행동 조건과 방어 파괴 결과 확인`; wrap without truncation/font change. Check required minimum heights and child bounds, not just metadata.
- [x] Planning requires empty lanes/hidden transients, not270px minimum. Execution requires positive contained pairwise-disjoint lanes. Never hide executed required text to pass.
- [x] Assert same texture/atlas band/kind/cue and actual ultimate peak1.08 containment. Invalid lane must return false through both callers, stay hidden through resize/old tween, and record bounded status. Shift board origin for global/local coverage; resize visible effect without replayed audio or changed domain state.
- [x] Keep960×640 and1440×900; add720/800/1080. Mute changes no geometry/text; reduced motion retains identity; actual skip clears transients with identical domain snapshot and restores planning only at the ordinary flow boundary. Keyboard/current-only focus remains usable.
- [x] RED: `godot --headless --path . --script res://tests/verify_combat_action_reveal.gd`; `godot --headless --path . --script res://tests/verify_actor_ultimate_presentation.gd`; `godot --headless --path . --script res://tests/verify_combat_layout_accessibility.gd`.
- [x] Implement section5 in2 board files, both bool callers, conversions and finite status. Reuse overlay; no theme/font/atlas/overlay internals edit.
- [x] GREEN: same3 commands, then `godot --headless --path . --script res://tests/verify_combat_presentation_controls.gd`, `godot --headless --path . --script res://tests/verify_combat_sfx_presentation.gd`, `godot --headless --path . --script res://tests/verify_combat_terminal_presentation.gd`.
- [x] Independent review then controller-authorized owned-path commit.

### Task3 — Mandatory exact CI wiring

**Files:** Python test then existing workflow. **Consumes:** strengthened native scripts. **Produces:** same-job post-import wiring.

- [x] Add assertions that `automated-product-evidence` explicitly runs screen-partition and action-reveal exact script paths after import, without changing job/check/action pins/permissions. Existing ultimate/layout-accessibility steps remain.
- [x] RED: `python -m unittest tests.test_combat_feedback_correction -v`. Expected actual failure:2 exact native steps absent, not unrelated current-stage text.
- [x] Add2 steps after import and their exact paths to existing push-path filter for future test-only pushes. Do not alter permissions, timeouts or required-check identity.
- [x] GREEN: same Python module and `python tests/check_combat_board_contract.py`. Exact-head CI/full suite remain controller-owned.

### Task4 — Bounded final verification and handoff

- [ ] At final candidate repeat focused Tasks1–2 native and Task3 Python/checker commands; record exact commands/exits/time/Godot/actual warnings/failed assertions and candidate SHA. Never combine mixed revisions into one full PASS.
- [ ] Read back10 allowed paths, six listed hashes and unchanged untouched consumers. Future implementation checks include `git diff --check` and status; those commands here do not authorize writer Git mutations.
- [ ] Hand off for independent implementation review and controller capture/full suite. Preserve imported sidecars as environment state and exclude from product commits; controller-only exact-path cleanup after ownership/capture, never broad glob.

## 8. Untouched-consumer and failure matrix

| Surface | Required proof / boundary |
|---|---|
| Domain/AI/save | No data/engine/codec/store/AI changes. Ordinary/ultimate/movement/skip/terminal snapshots/resolve counts unchanged. No hidden future plan input to layout. Persistence suite controller-owned. |
| CTA/3/3/4/planning | Original current slots/selection/reservation/focus preserved. CTA immediately expanded; next planning50% restores existing controls only at its real boundary. |
| HUD/background/Title | Same HUD rect/content. Background/banner/tint equal combat stage; independent Title full-screen consumer untouched. |
| Renderer/cache | Draw/getter agree for all3 assets/mirroring. Read image only on texture change, no per-layout/per-frame loads. Empty art is failed proof. |
| Motion/resize | Nonmove offsets/scales/durations unchanged. Common MOVE anchors; actual-geometry-change-only MOVE snap; no duplicate coroutine continuation or skip outcome change. |
| Text/lanes | Positive settled execution bounds; no hidden overflow via max1/clipping/truncation. Planning clears only transient lanes. Exact long-copy/960 failures reported. |
| VFX/mute/reduced/skip | Original identity/band/audio; peak envelope contained, false honored, no resurrection/replayed sound. Text remains on reduced motion. |
| Cost/lifetime | Scalar/Rect2/four-corner math on existing callbacks; bounded current-texture cache. No new process loop, observer, resource load, timer, await or growing history. |

## 9. Controller capture and completion gates

After candidate commit/review only, follow current runtime-visual-capture prepare/register policy: source-absent receipt before producer, fresh trusted HEAD and exact project/editor/game identity. Never promote old supplemental screenshots retroactively.

1. Preserve unrelated editors/games. Controller imports exact candidate once, records every output and separates teardown warnings from clean runtime evidence.
2. Run focused verifiers; capture720/800/1080 planning, ordinary current-action/impact, actual movement and next planning. At800 add eligible ultimate actual peak/recovery, actual Dogyeom variance and both actor roles. Label seeded fixtures versus ordinary persisted-route evidence.
3. Bind capture to actual event/timing/motion state, not arbitrary sleep. Record global viewport/HUD/stage/background/banner/tint, occupied ink/feet, comparison children/result, label, VFX peak and input state. Include long copy, mute, reduced, skip and visible resize.
4. Re-read exact hashes/diff/identity. Helper geometry alone does not replace imagery. Controller owns whole suite/CI; implementer does not repeat or claim it.

Completion requires real behavioral RED before each product correction, focused GREEN on one candidate, independent review, actual CI wiring/execution, allowed10-file scope, unchanged assets/untouched consumers, and policy-registered captures at3 sizes. Controller canon/protected approvals/publication are separate prerequisites.

Human preference/readability, physical input/audio, accessibility users, Android/device, shipping rights and release/performance remain NOT_RUN. The46% technical ratio is controller-ratified for scoped implementation by the linked Decision; native geometry cannot user-final-lock its visual result. No whole Blueprint/Human/Android/release PASS.

## 10. Rollback, ratification and history

- Rollback exact layout commit only; no save/asset migration. Preserve capture failures/import environment according to ownership policy.
- Tune only within `[0.46,min(0.50,0.52/current_existing_peak)]` after ratification. Never change52% cap, existing motion peak, alpha threshold or measurement definition to manufacture PASS. A future changed peak must invalidate stale bounds.
- If actual geometry/motion/long text cannot fit, stop with exact bounds and minimal alternative. No asset crop/font/copy change, hidden required text, HUD occupation or expanded viewport contract.
- Source restorations: stage-only visuals, initial-only42%, original domain/input/save. Proposed technical fill: idle46%/mathematical ceiling, finite metadata, resize-only MOVE snap. No product authority until explicit main Decision/handoff.
- Original five labelled passes were draft self-checks. Independent L1–L5 rejected clean exit; controller added stage-only conflict. Preserve `layout-independent-review.md`; writer mapping goes in `layout-review-addendum.md`. These are not five independent implementation loops.
- `CLEAN_EXIT_FOR_DRAFT_REVIEW = INDEPENDENTLY_APPROVED_AFTER_R1`. The writer gives no independent verdict on its own revision.

## Task1 evidence-backed scope refinement

Actual untouched inline verifier reported six overlaps at720/800/1080, all on hidden previous-bundle TimingSlot02/03 (visible=false). Current src/ui/action_timing_panel.gd115–131 explicitly makes only current bundle slots visible. Controller independently read the real diagnostic and source, authorizing only the additional inline verifier path above: verify actual visibility equals current-index membership and exact positive count, then assert non-overlap on every visible slot. Existing timing panel/CTA/card checks remain unchanged. Never move hidden geometry or hide current slots to manufacture PASS. Three product paths, game behavior, fonts, assets and other scope remain unchanged. The old9-path plan hash remains independent-review history; actual tests and final full-scope review must cover this explicit10-path refinement.
