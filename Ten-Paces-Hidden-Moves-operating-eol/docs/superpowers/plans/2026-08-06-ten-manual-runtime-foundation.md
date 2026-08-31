# Ten-Manual Runtime Foundation Implementation Plan

> Required execution route: `executing-plans → test-driven-development → verification-before-completion`

## Goal

Move the approved initial ten martial manuals into a tested Godot runtime foundation while preserving the current basic cards, generic ultimates, PoC UI, and AI as compatibility boundaries.

## Authority

- Parent Decision: `TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01`
- Runtime gate: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`
- Build approval: `docs/implementation/BUILD_APPROVAL_2026-08-06.md`
- Working PR: `#92`, Draft and stacked on PR `#91`

## Non-negotiable constraints

- Do not use primary/secondary-stat count, equality, quota, minimum, or maximum rules.
- Keep each manual's approved faction and stat fit.
- Star 5 modifies only the star-3 card.
- Star 9 modifies only the star-7 card and adds exactly one branchless step with no new input or resource cost.
- State creation precedes dependent attacks, recovery, or counters.
- Movement that can change range requires a later `RECHECK_RANGE` before the dependent attack.
- Zixia consumes its once-per-battle right at program start, never refunds it, and grants momentum only on full completion.
- Vajra fortitude prevents only the currently approved interruption instance; it is not invulnerability.
- Existing basic and generic-ultimate IDs remain unchanged and available by default.
- UI replacement, AI adoption, final balance, human validation, accessibility, performance, and Windows interaction remain outside this implementation.

## Adopted architecture

### Split runtime catalog

A single oversized JSON was rejected because it would be difficult to review and conflict-resolve. The final structure is:

```text
data/cards/martial_manual_cards.json
└─ manifest, compatibility policy, exact ten-file map

data/cards/martial_manuals/*.json
└─ one focused file for each of the ten manuals
```

Each manual file contains:

```text
faction and manual identity
primary and secondary stat
star3, star7, star10 executable cards
star5 → star3 overlay
star9 → star7 single-step overlay
ordered effect_steps
provisional approved-budget disclosure
```

### Runtime components

- `src/combat/martial_manual_registry.gd`
  - loads the manifest and ten manual files;
  - validates the runtime roster;
  - builds mastery 3·5·7·9·10 card views using deep copies;
  - merges only explicitly selected loadouts.
- `src/combat/martial_effect_pipeline.gd`
  - executes the approved effect-step allowlist deterministically;
  - preserves caller-owned state on invalid operations;
  - records stable result and failure codes.
- `src/combat/combat_resolution_engine_ten_manuals.gd`
  - inherits the current combat engine;
  - preserves basic cards and generic ultimates;
  - adds martial cards only through `configure_martial_loadout`;
  - delegates martial-card programs to `MartialEffectPipeline`.

The base combat engine is intentionally not rewritten. This adapter boundary keeps legacy regression failures separate from ten-manual runtime failures.

## TDD sequence

### Task 1 — Static contract RED

Files:

- `tools/check_ten_manual_runtime_foundation.py`
- `tests/test_ten_manual_runtime_foundation.py`
- `.github/workflows/validate-ten-manual-runtime-foundation.yml`

Required RED:

```text
runtime manifest absent
registry absent
effect pipeline absent
build approval absent
```

Recorded RED workflow: `31049328495`.

### Task 2 — Registry RED/GREEN

Verifier: `tests/verify_ten_manual_registry.gd`

Assertions:

```text
exactly ten manuals
mastery 2 → no card
mastery 3 → star3
mastery 5 → star5 overlay only on star3
mastery 7 → star3 + star7
mastery 9 → exactly one star9 step only on star7
mastery 10 → star3 + star7 + star10
repeated builds do not mutate source data
Shaolin retains 외공/내공
Beggars retains 내공/근골
```

### Task 3 — Effect pipeline RED/GREEN

Verifier: `tests/verify_martial_effect_pipeline.gd`

Assertions:

```text
Vajra defense and fortitude occur before attack
Returning Spear resolves attack → retreat → range recheck → attack
out-of-range second spear attack is skipped
Zixia interrupted after prelude keeps use right consumed
interrupted Zixia grants no completion momentum
Myriad Heavens Rain resolves four independent attacks
Lingbo counter resolves before retreat
unknown effect operation is atomic and returns UNKNOWN_EFFECT_OP
```

### Task 4 — Compatibility adapter RED/GREEN

Assertions:

```text
basic_move remains available
ultimate_ten_paces_wave remains available
no martial card appears before explicit loadout configuration
mastery-appropriate martial cards merge after configuration
locked cards stay absent
reconfiguration removes only previously loaded martial cards
```

### Task 5 — Exact-head validation and synchronization

Required successful workflows:

```text
Validate Ten Manual Runtime Foundation
PR Validation
Full Validation
Validate Ten Recognizable Martial Manuals
Validate Ten Manual Growth Budget
```

The dedicated runtime workflow owns the new Python and Godot checks. Full Validation owns existing product regression. Duplicating the same runtime commands in the protected general workflows was rejected as unnecessary CI duplication.

After all checks pass:

1. update current authority documents to `TEN_MANUAL_RUNTIME_FOUNDATION_IMPLEMENTED`;
2. preserve `NOT_RUN` disclosures for human and balance validation;
3. record the exact final head and runtime Decision in the same nine Google Sheet authority tabs;
4. read back every synchronized row;
5. update PR #92 body while keeping it Draft and stacked.

## Adversarial completion checklist

- [ ] No stat quota or distribution logic.
- [ ] No hidden-plan access or automatic correct counter.
- [ ] No automatic clash victory.
- [ ] No attack bypasses range after movement.
- [ ] No Zixia use-right refund.
- [ ] No absolute fortitude immunity.
- [ ] No mutation or removal of legacy card IDs.
- [ ] No false human, balance, accessibility, performance, or Windows validation claim.
- [ ] No PR merge, undraft, or lineage bypass.
