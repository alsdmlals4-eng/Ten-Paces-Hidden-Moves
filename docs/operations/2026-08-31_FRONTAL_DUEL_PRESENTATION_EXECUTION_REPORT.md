# 2026-08-31 Frontal Duel Presentation and Card-Art Candidate · Execution Report

## Execution identity

- **Work mode:** `BUILD → REVIEW`.
- **Authority:** latest user direction; `AGENTS.md`; current repository visual/planning owners; `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01`.
- **Current-state relevance:** `FEASIBLE`. This is a bounded consumer-and-asset presentation update in the existing Godot combat board. Dynamic external research was not needed to decide whether a locally owned, user-final-locked image could replace the exact existing background consumer; current repository consumer/data/runtime evidence was inspected instead.
- **Evidence ceiling:** machine checks and a visible Godot runtime readback only. This report does not claim human usability, player fun, accessibility-user, Android-device, release-performance, store, or final asset-rights approval.

## Work-before problem

The active combat surface still conveyed a diagonal duel through legacy visual assets/names and had player-facing remnants the user rejected: `상대 의도 가설`, an `즉시 완료` control, and visual offsets that made the characters feel detached from a shared ground plane. Basic actions had an approved art atlas, but martial and ultimate cards were intentionally text-only under a now-superseded direction.

## Adopted structure and reason

1. `BattleBackground` now consumes one user-final-locked frontal stone-courtyard asset.
2. `CombatBoardPreviewAuto` gives both battlers the same size treatment and the same ground baseline, while the logical ten-space board stays hidden at rest and `거리 N` remains live in the centre.
3. `ActionChoiceCard` remains the single card renderer for basic, martial, and ultimate sources. This avoids three layout systems and protects card-level text, costs, locks, effects, focus handling, and assistive labels.
4. Martial/ultimate artwork is represented by one semantic 4×2 atlas candidate, not promoted to runtime before a separate final lock.
5. Exactly unused current-tree backgrounds, diagonal image files, and hypothesis UI/data/test files were removed only after consumer/reference scans. Historical provenance and recovery remain in Git history.

## Implemented result

- `FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1` is canon-registered in `docs/visual-assets/approved`, copied byte-for-byte into `assets/backgrounds`, referenced by `BattleBackground`, and listed as the active manifest asset.
- The locked background source/output identifier is `exec-e3ab08d2-ac38-48de-81b4-de02580ecafc`; SHA-256 is `27778369c3896d7d6237990ec70620c54ad0d636f660c9aa80322b0632262d06`.
- The opponent-intent hypothesis file/panel and player-facing skip button are retired. The sequential one-action-at-a-time reveal remains active.
- Historical diagonal verifier names are replaced by `verify_frontal_duel_assets.gd` and `verify_combat_action_reveal.gd`; their purposes remain covered.
- `MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1` is recorded only at `docs/visual-assets/candidates`. Its source output identifier is `exec-42629f32-87fa-457f-a6a5-5454b002c500`; SHA-256 is `227a0492399d287fec073d7bccb36dc84eae1dd0c6d11247302e24ca87c3750e`. It has no runtime path, manifest entry, or Godot consumer yet.

## Actual use and expected player result

At rest, the player sees two battlers confronting each other from left/right on the same visible stone floor, with the central `거리 2` readout and the action-plan UI. The internal ten-space model continues to drive range and resolution but does not appear as a floor board. On resolving a committed bundle, the game still exposes only the current timing's actions and result before later timings.

After the card-atlas candidate is separately final-locked, the same shared card surface can place semantically matched art above martial and ultimate labels without hiding the game-critical text.

## Verification evidence

- **TDD retirement check:** `tests/check_repeat_poc_a2_contract.py` first failed while the retired hypothesis data still existed, then passed after removal.
- **Current contract checks:** `tests/check_combat_board_contract.py`, `tests/test_current_discovery_contract.py`, `tests/test_visual_consumer_asset_production_policy.py`, `tests/test_gpt_work_handoff_20260826.py`, `tests/test_pc_first_vertical_slice_implementation_gate.py`, and `tests/test_integrated_work_contract_v48r54.py` passed.
- **Godot parse/import:** Godot `4.7.1` headless editor parse completed with exit code `0`; its end-of-process ObjectDB/resource cleanup warnings are engine shutdown diagnostics, not a parser/runtime error.
- **Focused Godot regressions:** combat board, ink-paper presentation, frontal duel assets, one-action reveal, character art, Dogyeom routing, focus order/visuals, assistive labels, review summary/UI, vertical-slice bridge, and review/result checks passed.
- **Visible runtime:** the exact Ten Paces editor instance (not the separately detected GRIMOIRE instance) ran `res://scenes/combat/combat_board_preview.tscn`. Runtime tree readback found `TileLayer visible=false`, `FootAnchorGuide visible=false`, player and enemy at `y=267` with equal height, and the central label `거리 2`. Runtime diagnostics reported `error_count=0`, `warning_count=0`.

## Five adversarial review loops

1. **Consumer attack:** verified the active background consumer, data record, manifest, and Godot resource path agree before deleting old images.
2. **Composition attack:** verified no logical floor grid/guide is visible and both battlers share the same ground baseline rather than a diagonal depth offset.
3. **Information-boundary attack:** verified retired hypothesis and player-facing skip references are absent while the ordered reveal path remains covered.
4. **UI consistency/accessibility attack:** verified the shared card surface preserves text facts, locks, tooltip/accessibility labels, focus behavior, and selected/disabled behavior.
5. **Retention/cleanup attack:** retained only active runtime assets, canonical provenance, candidate review material, and regression tests; transient screenshot/import outputs are removed after inspection and record capture.

## Automation and learning

The consumer contract now fails if retired hypothesis surfaces return, validates the frontal background as the active asset, and references current-frontal rather than diagonal regression names. Candidate generation is recorded separately from final-lock, runtime, and human evidence so a generated image cannot silently become a shipped game asset.

## Unverified and remaining risk

- The martial/ultimate atlas is **not final-locked and not integrated**. It requires explicit user final lock, then byte promotion, semantic atlas mapping, Godot card-layout verification, and visible runtime readback.
- Windows human usability, human player comparison, accessibility-user validation, Android device validation, release performance, and release/rights clearance remain `NOT_RUN` or conditional as recorded by their owners.
- The removed legacy files are recoverable from Git history but deliberately absent from the current tree.
