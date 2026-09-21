# TEN-DEC-20260914-ACQUIRED-MANUAL-COMBAT-COMPATIBILITY-01

Status: APPROVED_IMPLEMENTATION_CONTINUATION. User: `좋아 권장안대로 작업진행해`, following P00–P14 preparation. Baseline: 0fb63dbd13d4e7124075f6ea9328ab4901a090c5. Work Mode: PLAN → BUILD → REVIEW.

The approved no-equipped-limit core requires earned manuals to be usable. P01 in `docs/implementation/REMAINING_GAME_IMPLEMENTATION_SPEC.md` owns the scope. This decision records its compatibility consequence; it does not approve P02 training allocation, new growth costs, images or release.

## Adopted contract

- Keep the four selected starters and their initial mastery immutable as provenance. `get_owned_player_manuals()` returns a copy of progression ownership. Current mastery remains progression-owned.
- Bind the full earned list into the combat bridge, action dock, reward targets, summaries and player manual seal selector. Validate reward history against ownership at each receipt, not eventual ownership.
- New combat checkpoints with more than four manuals include `binding.owned_binding_version=1`. Their loadout and mastery keys must exactly match earned ownership. Unknown, duplicate, unearned and truncated current bindings fail closed.
- Existing v1/v2 envelope and roster identities remain readable. For an unmarked historical combat checkpoint with more than four earned manuals, decode first validates the complete historical four-starter binding, run identity, mastery, state, plans, enemy lock, constraints and receipts. Only then replace the available player manual list with verified earned ownership and add the binding version. Validate the entire transformed checkpoint again.
- Preserve state, committed player plan, locked enemy actions, resources and reward/route history exactly. This enables earned choices on restored planning without replaying combat or reward effects. Invalid historical or transformed states remain CORRUPT.
- Decode does not write files. The returned normalized payload has a recomputed integrity hash. RunSaveStore retains the independently verified original envelope digest for immutable v2 filename/pointer matching and caching. Runtime payload identity never substitutes for physical source identity.
- A subsequent ordinary transaction writes the new checkpoint. v2 original immutable files remain preserved; v1 uses the existing source-text backup path. An old application cannot read the new optional binding field; rollback uses preserved old bytes, never silently strips newly available combat choices.

## Alternatives and evidence

ADOPT separate ownership view and strict historical decode conversion. REJECT overwriting starter history, accepting arbitrary shorter current loadouts, replaying rewards during import, or replacing the saved enemy/player plans. Reuse the same-day ten-game comparison in specification section20: identical growth efficacy/save compatibility dimension and unchanged product baseline. No new dependency or asset.

Baseline codec sources from `git show 0fb63dbd:src/run/{run_checkpoint_codec,combat_checkpoint_codec,vertical_slice_run_state}.gd` validated the two historical fixture envelopes in `tests/fixtures/acquired-legacy-v1.json` and `acquired-legacy-v2.json`. Their terminal history is synthetic; they prove compatibility boundaries, not actual campaign victories. Runtime source and test results are in `docs/operations/2026-09-14_ACQUIRED_MANUAL_IMPLEMENTATION.md`.

Human gameplay, Android/device/accessibility, four motion-sheet final locks and release remain separate and unverified. No core 3/3/4, public-information AI, equipment restriction, reward amount or roster policy changed.
