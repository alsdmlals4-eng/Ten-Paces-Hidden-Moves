# TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE

- Decision status: `APPROVED_RUNTIME_FOUNDATION`
- Authority: `RUNTIME_FOUNDATION`
- Date: `2026-08-06 KST`
- User approval: `권장안대로 진행`
- Parent Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`
- Working PR: `PR #92`
- Parent stacked PR: `PR #91`

## Decision

The approved ten-manual planning contract may enter product runtime as a compatibility foundation composed of:

1. `data/cards/martial_manual_cards.json` manifest;
2. ten focused files under `data/cards/martial_manuals/`;
3. `MartialManualRegistry` for mastery unlock and overlay composition;
4. `MartialEffectPipeline` for deterministic ordered effects;
5. `TenManualCombatResolutionEngine` as an opt-in adapter over the current combat engine.

This Decision does not replace the current basic cards, generic ultimates, action-selection UI, or AI policy. The default engine behavior remains unchanged until a martial loadout is explicitly configured.

## Stat assignment authority

No primary/secondary-stat book-count rule exists. No equal distribution, quota, minimum, or maximum may be inferred from the roster. Each manual keeps the stat pairing approved for its faction, martial philosophy, action, and damage method.

## Runtime completion boundary

`RUNTIME_FOUNDATION` means:

- all ten manuals are loadable;
- mastery 3·5·7·9·10 composition is executable;
- ordered structural effect operations are testable;
- special invariants for Zixia, Vajra, Returning Spear, Lingbo Footwork, and deterministic hidden-weapon multi-hit are enforced;
- existing PoC cards remain compatible.

It does not mean:

- final balance;
- final UI or presentation;
- AI adoption;
- human playtest approval;
- accessibility, performance, or Windows interaction approval.

## Non-merge boundary

PR #92 remains Draft and stacked on PR #91. This Decision does not authorize merging, undrafting, closing, or independently landing PR #92 before its parent lineage is explicitly approved.
