# Preparation card summary implementation report

## Result

MACHINE_VERIFIED, ready for controller renderer capture and integration review.

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

The first post-implementation run found a real 720p failure: row two exceeded
the host by 2 px. The split was moved from 60% to 53.5%, the card height was
bounded at 88 px, and the regression then passed.

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
Panels skip rebuilding when magnitude inputs are unchanged.

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

Static owned-file diff check: PASS.

## Five adversarial loops

1. Truth/source: rejected UI calculation duplication; used resolver accessors
   and corrected the base-only detail label.
2. Information boundary: restricted context to current player magnitude inputs;
   no enemy private information is supplied.
3. State/interaction: proved preview purity and reran lock, placement, dock, and
   ultimate reservation regressions.
4. Viewport/accessibility: caught and fixed 720p overflow; retained art, native
   text, hover/focus detail, and the 11 px minimum.
5. Long-term consumer fit: centralized all source cards in the shared renderer,
   avoided unchanged-input rebuilds, and reran adjacent regressions.

CLEAN_REVIEW_EXIT: no unresolved finding remains in the owned machine scope.

## Preservation and evidence ceiling

No card JSON, combat rule/stat/cost/formula, scene, asset, import, UID, save,
AI, or hidden-information policy changed. Controller-owned route/state/docs/art
and pre-existing import/cache churn were not staged.

- Headless focused machine evidence: PASS
- Controller renderer capture: NOT_RUN here by explicit task boundary
- Windows visible input/render: NOT_RUN
- Android device: NOT_RUN
- Human readability/player comprehension: HUMAN_NOT_RUN
- Accessibility user and release: NOT_RUN

Rollback is the bounded card-summary commit only; reverting it restores the
prior hover-dependent card surface without changing definitions or combat state.
