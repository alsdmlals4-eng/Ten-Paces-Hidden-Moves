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
