# CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF — 행동 출처 공통 카드 통합

```yaml
handoff_id: TEN-HANDOFF-20260830-ACTION-CARD-SOURCE-UNIFICATION-01
status: COMPLETED_LOCAL_IMPLEMENTATION_PENDING_BRANCH_REVIEW
decision: TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01
design_spec: docs/superpowers/specs/2026-08-30-action-card-source-unification-design.md
implementation_plan: docs/superpowers/plans/2026-08-30-action-card-source-unification.md
baseline_branch: origin/main
baseline_sha: 0b2ab3fe64a8325b52b743c8d9da03cb23646b3f
work_branch: codex/action-card-source-unification-20260830
work_mode: BUILD
approval: USER_EXPLICIT_20260830_확정
human_play_comparison: NOT_RUN_DEFERRED_BY_USER
```

## Fresh-read boundary

Codex independently read the latest repository `AGENTS.md`, Base/adoption entrypoint, current `ACTIVE_CONTEXT.md`, current planning JSON, benchmark packet, current combat source/data/scenes/tests, and existing user-approved visual consumers from the exact `origin/main` baseline above. Open work outside this branch remains untouched.

## Authorized product change

Implement only the user-approved selection-surface correction:

1. Make `기초 / 무공 / 절초` use `ActionChoiceCard` as their shared action-card skeleton.
2. Keep the approved basic atlas only in basic cards; prohibit martial, ultimate, and semantic-intent card illustrations.
3. Replace player-facing tile destination/left-right direction picking with movement and attack semantic intent cards.
4. Remove the active `action_selection_poc.json` consumer/data source while preserving the resolver's internal compatibility coordinates and result keys.
5. Retain 10-tile logic, visible `거리 N`, 3/3/4 planning, resolver/AI public-state boundary, save meaning, reserve/refund, and existing reveal VFX.

No new visual asset, combat formula, AI private input, deck/hand/draw system, Android work, human-play claim, accessibility-user claim, or release claim is authorized by this handoff.

## Required evidence

- Record an expected RED for the absent shared-card/current-data contract and GREEN after the minimum implementation.
- Run focused data/contract checks, affected Godot verifiers, full Python discovery, and the project operating-system check.
- Use the exact worktree editor to observe all three source tabs and one movement intent selection. Record diagnostics separately from human usability.
- Perform five full-scope adversarial review loops and retain only evidence-backed findings.

## Process note

The approved Decision and implementation plan existed before the code change. This formal handoff record was found missing during the Task 5 owner refresh and added in the same isolated branch before delivery. The execution report records this as a process-recovery fact; it does not retroactively claim a different scope or evidence level.
