# Preparation card summary implementation report

## Result

MACHINE_VERIFIED after actual-render correction, ready for controller recapture
and integration review.

Preparation cards now keep slot cost, stamina/internal cost, range, movement
when present, and one truthful primary magnitude/effect visible without hover.
Basic, martial, and ultimate cards retain the shared ActionChoiceCard, existing
illustrations, source tabs, placement semantics, interaction locks, and atomic
ultimate reservation.

## Baseline, route, and feasibility

- Baseline: 2904c9e99616d6304d394306eeef7e5f704b7059
- Worktree: .worktrees/ten-duel-campaign-20260908
- Work mode: BUILD
- Skills: combat-implementation-handoff/build,
  combat-ux-and-accessibility/ui-contract, and
  ten-paces-verification/regression/evidence-report
- Operating-contract fallback validator: project operating system PASS
- Current-source relevance: REUSED_EVIDENCE. This is a bounded continuation
  of the same preparation-card decision dimension and current Godot Control
  consumer covered by docs/operations/2026-09-08_TEN_DUEL_CAMPAIGN_IMPLEMENTATION.md.
  No new platform fact, rule, external asset, or rights claim changes the choice.
- Feasibility: FEASIBLE. The live consumer, current player state, structured
  definitions, resolver calculation, 5 by 2 grid, and focused tests exist.

## TDD evidence

RED was established before implementation:

    res://tests/verify_action_card_summary.gd
    Parse Error: Too many arguments for configure_action()
    Expected at most 3 but received 4
    exit 1

The regression covers changed player stats changing attack magnitude, unknown
actor fallback, no state mutation, slot/resource/range/primary effect presence,
illustration retention, 128 px text fit, the ten-card 5 by 2 grid, 1280x720 and
1280x800 containment, and separation from HUD and battlefield.

The first post-implementation run found a 720p host failure. The initial
rectangle-only fix moved the split to 53.5% and used an 88 px card, but the
controller's actual 1280x800 renderer capture then proved the test incomplete:
the three 11 px labels require a 48 px content height, so the third line crossed
the card border and rows visually collided. A second RED now checks each label
rectangle against its card and checks line-to-line overlap. The final fix uses
a 98 px card and a 50% planning split; both 720p and 800p pass the stricter test.

## Adopted implementation

CombatResolutionEngine.preview_attack_damage exposes the same raw magnitude
used by the existing resolver calculation. It refuses a number when required
actor stats are absent and identifies clash, guard, evade, range, and
interruption as unresolved. preview_action_magnitude keeps movement, guard,
evade, stance, restore, and observation magnitudes under the domain owner.
Both accessors are read-only.

CombatBoardPreview passes only current player stats and attack_power to the
dock. The dock propagates that snapshot to all three source panels and detail.
No enemy state, hidden plan, or unrevealed intent enters the preview path.
Panels skip rebuilding when magnitude inputs are unchanged. ActionChoiceCard
also shares one lazy resolver preview instance, avoiding JSON/AI initialization
once per card; the detail panel retains its separate single instance.

The retained card composition is existing illustration, native name, and three
native 11 px summary rows: slot/resources, range/movement, and primary effect.
Attack cards say 예상 위력 rather than resolved damage. Missing actor data says
위력식 기본..., while compound/conditional fallback says 조건부 · 상세 확인.
Richer focus/hover detail remains.

ActionDetailPanel no longer labels damage_formula.base alone as 위력. With an
actor it says 예상 위력 N · 방어/합 전; without one it gives the formula baseline.

## Verification

Python:

    check_action_selection_contract.py
    check_card_component_contract.py
    test_action_card_source_unification_contract.py
    3 passed

Godot 4.7.1 headless:

    verify_action_card_summary: PASS
    verify_action_card_source_unification: PASS
    FRONTAL_DUEL_SCREEN_PARTITION_VERIFY_OK
    verify_action_selection_dock: PASS
    verify_ultimate_action_panel: PASS
    AUTO_CARD_PLACEMENT_VERIFY_OK
    verify_combat_action_selection_integration: PASS
    ULTIMATE_UI_RESERVATION_VERIFY_OK
    FRONTAL_DUEL_PLAN_LOCK_VERIFY_OK

Static owned-file diff check: PASS. The controller's first actual renderer
capture is retained as failure evidence, not a final visual PASS.

## Five adversarial loops

1. Truth/source: rejected UI calculation duplication; used resolver accessors
   and corrected the base-only detail label.
2. Information boundary: restricted context to current player magnitude inputs;
   no enemy private information is supplied.
3. State/interaction: proved preview purity and reran lock, placement, dock, and
   ultimate reservation regressions.
4. Viewport/accessibility: actual renderer evidence exposed a false-positive
   parent-only geometry check. The regression now verifies every label bottom
   and sibling non-overlap; art, three lines, and 11 px minimum remain.
5. Long-term consumer fit: centralized all source cards in the shared renderer,
   avoided unchanged-input rebuilds, and reran adjacent regressions.

CLEAN_REVIEW_EXIT: no unresolved finding remains in the owned machine scope.

## Preservation and evidence ceiling

No card JSON, combat rule/stat/cost/formula, scene, asset, import, UID, save,
AI, or hidden-information policy changed. Controller-owned route/state/docs/art
and pre-existing import/cache churn were not staged.

- Headless focused machine evidence: PASS
- Controller corrected renderer recapture: NOT_RUN after final fix
- Windows visible input/render: NOT_RUN
- Android device: NOT_RUN
- Human readability/player comprehension: HUMAN_NOT_RUN
- Accessibility user and release: NOT_RUN

Rollback is the bounded card-summary commit only; reverting it restores the
prior hover-dependent card surface without changing definitions or combat state.

## 2026-09-08 martial preview correction

Independent runtime review found that martial attacks expressed only through
`effect_steps[].power` were reported as `예상 위력 0`. The regression now walks
every mastery-10 attack definition from all ten real manual files. A preview may
publish a number only for one unconditional `ATTACK`/`INDEPENDENT_ATTACK` step
with positive raw power. Conditional, clash and multi-hit programs instead show
`조건·다단 위력 · 상세 확인`; the UI does not invent an aggregate across range,
defense, hit-count or clash gates.

RED produced 43 failures across the real catalog, including
`mount_hua_plum_blossom_sword_star3`. A second RED proved that the hover detail
still constructed a new engine. GREEN uses the engine-owned lazy
`shared_preview_engine()` in both the card and hover detail, so card JSON, rules
and the AI planner are initialized once for these read-only previews.

Fresh verification after the correction:

- `verify_action_card_summary.gd`: PASS.
- `verify_action_card_source_unification.gd`: PASS.
- `verify_combat_board.gd`: PASS.
- `verify_ten_manual_registry.gd`: PASS.
- `verify_martial_effect_pipeline.gd`: PASS.
- `verify_ten_manual_ui_ai_adoption.gd`: PASS.
- Python discovery suite: `461/461` PASS.

The failed attempt to invoke nonexistent `tests/verify_ten_manual_runtime.gd`
was an operator path error, not product evidence; it was replaced by the three
existing focused manual verifiers above. Visible/Human/Android/accessibility and
release-performance evidence remain `NOT_RUN`.
