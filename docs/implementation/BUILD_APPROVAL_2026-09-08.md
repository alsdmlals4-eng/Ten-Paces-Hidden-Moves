# Ten-duel campaign and Atlas presentation continuation

- Decision reference: `TEN-DEC-20260908-TEN-DUEL-CAMPAIGN-IMPLEMENTATION-01`
- Approval source: current user's explicit instructions to implement the complete planned
  Godot game, ten duels and four next-node choices per interval; recreate/connect assets,
  sound and motion as needed; investigate, correct and verify continuously without repeat approval.
- Integration authority: `TEN-DEC-20260908-STANDING-PR-INTEGRATION-01`.
- Scope: PR 322's campaign state/route/catalog, native card/resource UI, original/reused
  background consumers, original procedural sound cache and regression/CI corrections.
- Records: `docs/operations/2026-09-08_TEN_DUEL_CAMPAIGN_IMPLEMENTATION.md` and its linked captures.

This is a new scoped BUILD approval record, not reuse of PR 321's one-time manifest.
Existing approved binaries are preserved. No force/direct-main/ruleset bypass, no hidden
AI information, no deck/hand/draw, no save-schema expansion or new reward formula.
Core opening distance and 3/3/4 sequence are unchanged. Historical five-duel/two-node
limits in the 2026-08-20 approval remain history and do not override this user direction.

Mechanical checks, visible captures, Human play, Android, rights and release are distinct.
The completed public-policy headless campaign does not mean every Blueprint feature or
Human playtest is finished. Exact protected-path approval must match the final PR diff.

## Separate continuation: inline combat results

- Decision: `TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01`, sections 1.2/1.3.
- Scope: remove the active standalone review overlay/click, retain the real resolved cause inline, hand the terminal receipt through the existing internal REVIEW state to RESULT exactly once, and size reveal callouts/results from actual minimum content height.
- Existing resolver, 3/3/4 bundles, public-only AI, rewards/resources, save schema, audio, engine and approved assets remain unchanged. Existing resolved raw power/cost fields may be displayed; UI does not recompute combat values.
- Machine/headless evidence does not supply Windows visible Human, physical input, accessibility-user, Android-device, release-performance or shipping acceptance.

## Separate continuation: bimu constraints runtime

- Decision: `TEN-DEC-20260908-BIMU-CONSTRAINT-RUNTIME-01`.
- Same latest explicit user implementation authority, separately bounded to nine
  specified optional constraints, current-duel selection/freeze/retry, authoritative
  engine enforcement, native briefing/preparation feedback and touched-panel rebuild
  reduction. No new reward formula, save schema, scouting thresholds or core changes.
- Source: `docs/operations/2026-09-08_BIMU_CONSTRAINT_RUNTIME_PLAN.md` and the new
  runtime catalog `data/run/bimu_constraints.json`; historical candidate status remains
  historical, not silently promoted to implemented.
- PR322's one-time manifest is archived and is not authorization for this new diff.
  A fresh exact protected-path manifest is required before delivery of this package.
- Implementation and review are in progress. Visible/Human/Android/release acceptance
  is not supplied by this BUILD approval or the pure model tests.

## Separate continuation: single `행동 실행` Blueprint transition

- Decision: `TEN-DEC-20260904-THREE-BRANCH-FOUR-CHOICE-JIANGHU-AND-HUMAN-BLUEPRINT-01`, section 1.2; this CTA-only supersession replaces the player-facing two-step branch of `TEN-DEC-20260901-ACTION-PLAN-LOCK-AND-EXECUTE-CTA-01`.
- Approval source: the current user's approved single-execute Blueprint implementation continuation and exact Codex handoff.
- Scope: the active combat progress control uses exactly `행동 실행`; one complete and target-ready activation closes private planning and starts exactly one existing authoritative bundle resolution. Incomplete, target-incomplete, and repeated resolving inputs remain rejected.
- Protected product paths are limited to `src/combat/combat_board_preview.gd`, `src/combat/combat_board_preview_auto.gd`, and `src/ui/combat_progress_button.gd`; the exact one-time manifest remains mandatory.
- Preserve 3/3/4 private commitments, reservations, public-only AI, resolver mechanics, rewards, numerical rules, save schema, routes, audio, engine and existing approved assets. Standalone review removal is a separate gap.
- Machine tests and the native ordinary-default campaign do not provide physical-input, Human UX, accessibility-user, Android-device or release acceptance.

### Measured action-dock optimization within the same continuation

- Additional protected product path: `src/ui/action_selection/action_selection_dock.gd`; tests and reports are the adjacent evidence paths.
- Scope is limited to owned-copy invalidation of identical `martial_loadout` / `martial_mastery_by_manual` inputs. Resource preview, constraint locks, momentum, reservations, source/detail, targeting and interaction updates remain live on every relevant context call.
- No adapter-wide/global cache, deferred frame, gameplay/numerical/reward/save/route/audio/engine change, or FPS/device claim is approved.

## Separate continuation: durable local run checkpoint

- Decision: `TEN-DEC-20260908-DURABLE-RUN-CONTINUE-01`; same current continuous implementation authority and independent Codex handoff.
- Merged-main baseline: `27f7d922e8ec36e038c6dc943b069161b8b53536`. Task 1 owns explicit run/progression DTO validation/import and recoverable local storage; its exact four protected paths are in the new one-time `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`.
- The trusted protected baseline remains the adapter's `bf161025b63edd7eb441b2c4f2ae9da5155f68da`; its product diff through the merged-main source baseline is empty. Source revision and protected authority are distinct. No adapter/adoption pin change is needed.
- No UI connection or combat checkpoint implementation is claimed by this task. Nonempty combat checkpoints reject until the next bounded task implements their validation. The July planning-only save sample has no migration authority over this schema.
- Test paths are injected unique temporary/cache directories. No actual player save is touched. Windows physical input, Android lifecycle/device, Human UX and release acceptance remain `NOT_RUN`.
