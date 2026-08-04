# Technique1 Conditional Rework and Star5 Design

## Status

- Approved by user on 2026-08-04.
- GrillMe bundle: 7/10.
- Parent authority: `TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01`.
- Runtime boundary: planning and validation only.

## Goal

Rework all six approved 3-star Technique1 actions into clear low-floor/high-ceiling conditional actions while preserving the effective slots and costs approved by the repricing overlay. Add a 5-star free role patch worth about 20% of each technique's effective available budget.

## Global Rules

1. Conditional effects only resolve when their exact condition succeeds.
2. A failed condition grants zero of the attached effect bundle, with no partial payout, carryover, substitution, or conversion.
3. A technique cannot create its own credited prerequisite and immediately claim condition discount from that prerequisite.
4. Multiple conditions use one composite difficulty coefficient; percentages are not added.
5. Condition pricing is applied to the complete conditional effect bundle, then rounded once.
6. Difficulty coefficients:
   - easy: 0.85
   - moderate: 0.70
   - hard: 0.55
   - very_hard: 0.40
   - extreme: 0.25
7. 5-star free patch budget is `round(effective_available_budget_ticks * 0.20)` and does not add resource or slot cost.
8. Structural effects such as slots, movement, range, hit count, sure hit, or cost reduction are allowed when their full price fits the approved budget and counterplay remains explicit.
9. Existing effective slots and costs remain owned by `approved_20260804_existing_action_reprice_contract.json`.

## Multi-hit Damage Rule

A multi-hit action calculates one total raw damage value, then divides it into fixed shares.

For a three-hit chain:

```text
hit1 = floor(total_damage * 0.40)
hit2 = floor(total_damage * 0.30)
hit3 = total_damage - hit1 - hit2
```

Cancelled or failed later hits lose their allocated damage. Damage is not redistributed or carried forward. Stat scaling and rounding occur once at total-damage calculation, not separately per hit.

## Approved Technique Designs

### Flowing Cloud Triple

- Effective structure: 2 slots, stamina1, internal1, range1.
- Total damage: `floor(10 + EXTERNAL * 1.00)`.
- Hit distribution: 40% / 30% / remainder.
- Hit2 requires Hit1 to deal real health damage.
- Hit3 requires Hit1 and Hit2 to deal real health damage.
- Fixed retreat1 requires all three hits to deal real health damage.
- Reference stat4 total damage: 14, distributed 5→4→5.
- Base priced cost: 58 ticks against 61 available, variance -3.
- 5-star patch budget: 12 ticks.
- 5-star patch: total damage +3 before distribution; reference stat4 becomes 17, distributed 6→5→6. Conditional tranche pricing is 11 ticks, variance -1.

### Vajra Guard

- Effective structure: 1 slot, stamina1, internal1, self.
- Always grants defense4.
- Before the user's next action, if a real enemy attack is fully absorbed for zero health damage, grant defense3, fortitude1, and stamina1.
- A miss, out-of-range action, cancelled attack, or attack that never threatened health does not satisfy the condition.
- Base priced cost: 31 ticks against 31 available, variance 0.
- 5-star patch budget: 6 ticks.
- 5-star patch: on the same successful full-absorb event, gain internal1. Priced 5 ticks, variance -1.

### Cloud Hand Return

- Effective structure: 1 response slot, stamina2, internal1.
- Always prepares evade1.
- On successful evade of a real effective attack, fixed retreat1, gain internal1, and gain defense3.
- No attack or failed evade grants none of the conditional bundle.
- Base priced cost: 38 ticks against 40 available, variance -2.
- 5-star patch budget: 8 ticks.
- 5-star patch: on successful evade, gain momentum1. Priced 7 ticks, variance -1.

### Pursuing Wind Thrust

- Effective structure: 1 slot, stamina1, internal3, fixed advance1, range1..2.
- Always performs fixed advance1 if legal, then attacks for base damage1.
- If full advance1 completed, the attack resolves at exact range2, and it deals real health damage, add damage6 and break defense2.
- If advance is blocked, range is not exactly2, or health damage is not dealt, the conditional bundle is zero.
- Base priced cost: 50 ticks against 45 available, variance +5.
- 5-star patch budget: 9 ticks.
- 5-star patch: on the same successful spear-tip condition, fixed retreat1 and gain defense2. Priced 9 ticks, variance 0.

### Clear Heart Breath

- Effective structure: 1 slot, no resource cost, once per bundle.
- Always gain internal1.
- Snapshot stamina+internal before any gain. If the sum is 1 or less, additionally gain stamina2, internal1, and defense3.
- The action's own internal gain cannot retroactively satisfy the condition.
- Base priced cost: 22 ticks against 24 available, variance -2.
- 5-star patch budget: 5 ticks.
- 5-star patch: on low-resource success, heal health2. Priced 5 ticks, variance 0.

### Iron Step Drift

- Effective structure: 1 slot, stamina3, internal2.
- Always fixed retreat1 and prepare evade1.
- If a real effective attack is successfully evaded and a second retreat tile is legally completed, gain the additional retreat1 and momentum1.
- If the second retreat is blocked, the entire conditional bundle fails; momentum is not granted alone.
- Base priced cost: 48 ticks against 46 available, variance +2.
- 5-star patch budget: 9 ticks.
- 5-star patch: on the same successful full escape, gain fortitude1 and defense1. Priced 8 ticks, variance -1.

## Validation Requirements

- Exactly six canonical Technique1 IDs.
- Exact effective slots and costs inherited from the repricing contract.
- Exact base effect cost, available budget, and variance values.
- Exact 5-star patch budgets and priced patch costs.
- All base variances and patch variances within ±5 ticks.
- Flowing Cloud Triple calculates total damage once and distributes 40/30/remainder.
- Every conditional bundle is all-or-nothing and bound to one trigger.
- Self-created prerequisite credit is forbidden.
- Failed conditions cannot grant partial, deferred, substituted, or converted rewards.
- Product runtime, HTML PoC, Godot scenes, and game data are unchanged.
