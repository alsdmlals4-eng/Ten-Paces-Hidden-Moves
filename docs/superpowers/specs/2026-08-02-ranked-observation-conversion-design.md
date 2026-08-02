# Ranked Observation Conversion Design

## Goal

Preserve competitive viability for observation-dependent martial arts while official ranked battles disable `[관찰]` for both sides.

## Approved approach

Use a deterministic, versioned ranked-only conversion table. The registered champion snapshot remains immutable; conversion occurs only when a ranked battle instance is created.

## Requirements

1. Both manual player and AI defender use the same conversion table.
2. The conversion applied to each affected technique is visible before battle.
3. No conversion may reveal hidden plans or read unconfirmed inputs.
4. No AI-only, opponent-specific, or hidden win-rate compensation is allowed.
5. Structural values such as action-slot count remain unchanged unless separately approved.
6. Conversion should preserve the original technique's role and budget through public resource, defense, position, or counter conditions.
7. The table is pinned to a game-data version for replay and ranking reproducibility.

## Data flow

```text
Champion Build Snapshot
+ ranked ruleset version
+ official observation conversion table
→ ranked battle instance
```

The snapshot stored in the champion registry is never rewritten.

## Failure handling

- Missing conversion entry: block official ranked entry for that snapshot and show the exact unsupported technique.
- Version mismatch: use an approved compatibility table or isolate the snapshot from official matchmaking.
- Ambiguous conversion: fail closed; do not improvise a substitute.

## Validation

- Static schema validation for every observation-dependent effect.
- Budget comparison between original and converted effects.
- Symmetry tests for manual and AI sides.
- Replay determinism at a pinned data version.
- Human playtests for dead-build prevention and unintended dominant conversions.

## Operational checkpoint

After this catch-up merge, count only new final user approvals. At 10/10, pause GrillMe and perform canonical consolidation, GitHub/Sheet reread, adversarial conflict review, PR review and exact-head CI before merging.

## Out of scope

- Exact technique-level conversion values
- Online service implementation
- Matchmaking and rating formulas
- Friendly/self-battle observation rules
