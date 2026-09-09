# Task12 delivery — independent bounded review

```yaml
review_mode: READ_ONLY_FINAL_TEST_ORACLE_AND_NATIVE_RECEIPT_REVIEW
reviewer_context: REUSED_AGENT_CONTEXT_NOT_FRESH_CONTEXT
review_rounds_performed_here: 1
prior_five_full_scope_source_review: RETAINED_EXISTING_EVIDENCE_ONLY_NOT_RECOUNTED_HERE
parent_supplied_current_head: 508122f60e6b7ec46cc7deb44ef20754e120c900
implementation_base: 544fcbbaff0448edf265e381c70ad3d48fd61b7b
protected_baseline: 477697842bf14d95e670f01b0fe815e384b53658
retained_product_source_commit: eda26a97f25a931ac02ba739d5c4921720512d41
product_test_canon_mutation_by_reviewer: NONE
native_import_process_or_git_by_reviewer: NOT_RUN
verdict: ACCEPT_BOUNDED_TEST12_DELIVERY_EVIDENCE_NO_NEW_SOURCE_BLOCKER
```

## Read boundary and evidence ceiling

This is one new read-only delivery pass, not a claimed sixth full-scope loop and
not a replacement for the existing five full-scope source-review rounds.  It
did not run Godot, import, CI, Python regressions, Git commands, or process
operations.  The project operating-system validator was read-only run and
returned `project operating system: PASS`.

The supplied current HEAD is the test-oracle follow-up `508122f...`; the
retained three-product implementation source remains `eda26a...`.  This is
intentional rather than a source conflict: the 499-Python result belongs to
the earlier `eda26a...` source, while the final native-command receipt is
explicitly bound to `508122f...` and `tests/verify_ultimate_ui.gd`.  The
current execution report preserves that distinction at lines 67 and 119--131;
it does not claim that 499 Python tests include the later native test-oracle
correction.

Fresh-read current owners included the layout Decision, ratified plan, current
execution/current-planning records, human-facing Active Context, current
`README.md`, the board and ultimate correction reports, both workflow owners,
the raw native readback, actual source/test consumers, and the actual ordinary
campaign probe.  Review-bound current hashes were:

| Owner / evidence | SHA-256 |
|---|---|
| Decision | `7D97B0F6F962AB7FCB8B349361D2503320DF7276A39B53EC3418D22191A571C5` |
| Implementation plan | `EA536FE64C9072963EC47D5C683CA437DC49EE66440CFB3E217C48B6231509F5` |
| Current execution report | `6F5C61F79EAFF90C749E6B1E8D7D8213D515CDDA108034C9C003747EE944A01E` |
| Native CI readbacks | `057F6863EB01AD736568D969A4DDB626746870B5243F104A2BC59BFE32EA8231` |
| Ultimate-ui correction review | `D7E9303B5C0356D444A7812BA5D6F312322810892A42F839F12440168F5C7C01` |
| Board-oracle correction review | `81A74601960B3A48C0F9BCFA395FA131C8772D03F6157BBAD2ED6607B8AF4F94` |

`ACCEPT` below is restricted to the frozen local source/test evidence and its
truthful records.  It is not remote CI, merge/main readback, Human readability
or preference, physical input/audio, accessibility-user, Android, asset-rights,
release/performance, or whole-Blueprint acceptance.

## Current 12-path and asset integrity

The final test-only correction is correctly the twelfth allowed path.  The
current eleven previously frozen implementation inputs match the correction
receipt, while the sole new path matches the native receipt's
`dirty_test_sha256` exactly.

| # | Current path | SHA-256 |
|---:|---|---|
| 1 | `src/combat/combat_board_preview.gd` | `791891121D2D13301AF0A0B5E6F50E47951702296FA5BE86D5D2938E942D1A8D` |
| 2 | `src/combat/combat_board_preview_auto.gd` | `BF838422E70BB595EBF9E40021DFE253B73136AE2A9A2CAEBA4A843EE96BDC2A` |
| 3 | `src/combat/combat_character_placeholder.gd` | `17EEA94F124336617C6046AD1F6FD49084F005ADD64148439EDFD03E18F31FF4` |
| 4 | `tests/verify_frontal_duel_screen_partition.gd` | `AA3E72F24D3886637CD83A8633DA046EA0D98F4F65B07552B2FE97793BD1956C` |
| 5 | `tests/verify_combat_action_reveal.gd` | `605A08DF2B47AD665EB771A6147F7B01E4564216E29C492AEEE189B9932C8280` |
| 6 | `tests/verify_actor_ultimate_presentation.gd` | `C42D6A4B19DF25E0865130E56E7A345D3AA9E6C5E22FCCE8B889F08CCFB470A7` |
| 7 | `tests/verify_combat_layout_accessibility.gd` | `94EA2A95702FEFBC36A7C8B9747B4114E18D65E220AC468059A771114E093D56` |
| 8 | `tests/test_combat_feedback_correction.py` | `9BCCDAFC520E58CC71B6850D9E25B0B4C99146F79BA5547CAB67363589B66BDC` |
| 9 | `.github/workflows/validate-ten-manual-product-gate.yml` | `948EDC95C3BBC5A1E8465922262E8ECEA01F86336EDF196D99A0399CF2102B53` |
| 10 | `tests/verify_inline_combat_results.gd` | `0A4456812F0E131D527F6B7CD76F4828C347A8A259407DFA9E68BCC944A7CC3B` |
| 11 | `tests/verify_combat_board.gd` | `AECACD5F879B703A4DD7F2F3DFEF0169C3B757EB1D69F77CBA035386E7A7D79D` |
| 12 | `tests/verify_ultimate_ui.gd` | `7D4BF552A0EE361DB1997178E65A176F4C81A88CCC00055C8615048C307EC2D8` |

The three product hashes are unchanged from the Task1--3 freeze.  All six
approved source assets also match the ratified-plan values: player battler
`383FD9A62DE43D1B9C5C6C38F1AD9D537D8F088C08E4F25E23E974B87DC08864`,
masked enemy `0841505D275CA970D7D085D7AB206788276517D2290A63960D829E657DFBE17F`,
Dogyeom `064A8772406C743BBE6B252C138B4333C88B00B90A0BA905CCE9EA18773539C9`,
clash atlas `0859C714728608744B3F016E03C02F7B0E18D86B0B0CED191A2D5EC25CE2553F`,
courtyard `608D67E244AB3BC0C579FF04B359682A20C5189236117FF5390B0D7182DD092C`,
and banner `56667318D441F7E74ACCFC08F7038500E5D3B313BC68A15387F9C3C62608D7E2`.
This proves byte preservation only; it does not upgrade visual status or rights.

## Test12 and prior board-oracle review

`tests/verify_ultimate_ui.gd` preserves the original disabled/momentum,
reservation, contiguous-slot, refund, removal, and post-progress-cancellation
checks (lines 26--153).  Its planning regression now calls the same product
ultimate helper only after proving `presentation_state == "planning"`, and
requires all of: no visible VFX, no positive VFX lane, and no live VFX tween
(lines 126--133).  This matches the ratified execution-only-lane contract;
it does not hide a required result during actual execution.

The positive path is not a synthetic result injection.  For each existing
ultimate it supplies a disclosed legal three-`basic_meditate` enemy bundle,
disables autonomous planning only on that freshly instantiated test board,
relocks the normal engine bundle, reserves through the actual dock, and
requests the existing product CTA (lines 155--204).  It then requires the
actual player/card/timing/execution event, actual ultimate feedback kind,
visible-in-tree VFX, and positive alpha before examining the real
`AtlasTexture` region and transformed global lane containment (lines 198--220).
The `320` frame / `8000ms` dual deadline makes a lost completion fail rather
than hang.  It does **not** claim default-AI balance, every matchup's outcome,
or a Human-visible success animation; that is the correct fixture boundary.

The prior eleventh-path correction remains soundly anti-vacuous.  Current
`verify_combat_board.gd:495--551` independently reads raw PNG alpha and uses
four transformed corners rather than the production getter, checks both the
52% cap and the unchanged 1.12 envelope, and uses the same global coordinate
space as the stage.  Lines 559--577 apply an actual 0.8 enemy-y-scale negative
control, require the comparable-ink failure, restore synchronously, and rerun
the ordinary check.  This is an oracle-unit correction, not a relaxation of
the product geometry; the three product files and six assets above stayed
unchanged.

## Workflow projection and 53-command receipt

The current workflow/source projection exactly matches the retained receipt:

- `full-validation.yml` `godot-headless` has 31 distinct native script paths
  after import (lines 182--245).
- `validate-ten-manual-product-gate.yml` `automated-product-evidence` has 27
  paths after import (lines 87--142); five duplicate Full Validation paths
  are `verify_inline_combat_results`, `verify_combat_focus_order`,
  `verify_combat_keyboard_accessibility`, `verify_combat_layout_accessibility`,
  and `verify_combat_action_selection_integration`.
- Its 22 non-overlapping additions plus the Full Validation 31 form exactly
  53 unique script paths.  The receipt's first 31 and its following 22 are in
  the same respective order; neither workflow has an unrecorded current native
  command and the receipt has no command outside those workflows.

I recomputed every retained script SHA from the current filesystem: **53/53**
match each result's `source_sha256`.  Both current workflow hashes match the
receipt (`full-validation.yml`
`B63DC07CABE7AFF1816D0BF08C9D62D1E2D7942E5CB032BF73BD42B6017A1619`,
Product Gate `948EDC95C3BBC5A1E8465922262E8ECEA01F86336EDF196D99A0399CF2102B53`).
All 53 embedded full-log SHA-256 values also recompute exactly.

The retained local native result is therefore internally reproducible at the
source-record level:

| Receipt check | Actual result |
|---|---|
| Commands / indexes / PIDs | 53 / contiguous 1--53 / 53 distinct PIDs |
| Engine / project / mode | one recorded Godot 4.7.1 stable official `a13da4feb` console binary, this G worktree, all `--headless` |
| Script exit / timeout / ERROR or SCRIPT ERROR lines | 53 exit 0 / 0 / 0 |
| Sum of individual durations | `304.3907288002s`; explicitly not batch wall-clock |
| Slowest command | ordinary native campaign, `111.9008818s` |
| Warnings | five separate processes, each `2 ObjectDB instances were leaked at exit` |

The five warning-bearing receipt entries are `verify_combat_board`,
`verify_ultimate_ui`, `verify_combat_presentation_liveness`,
`verify_combat_review_ui`, and `verify_auto_card_placement`.  They are not
silently converted to warning-free PASS.  The current bounded audio diagnostic
ties the reproduced board warning to a final active momentum WAV in an
immediate Dummy-backend process exit, and observes clean mute/post-free-drain
controls; it expressly does not prove a product leak, device-audio behavior,
or a production repair.  No warning suppression or product audio mutation is
part of this test12 delivery verdict.

The ten records without a generic marker were checked against their retained
structured success output instead of being accepted on exit code alone.  This
includes the non-synthetic sequential campaign summary and the explicitly
labeled synthetic terminal-state verifier; the latter was not used as a
substitute for the actual UI campaign.

## Ordinary UI campaign and CI/fixture limits

The actual campaign evidence is materially stronger than a terminal fixture
but remains a machine test.  `tests/probe_native_ten_duel_campaign.gd` creates
the real shell, uses visible focused `ui_accept` input events, asserts the
single actual press signal, operates title/setup/briefing/action tabs/cards,
uses the real execute button, reward UI, and four route choices (lines 55--149
and 159--239).  It explicitly requires normal animation defaults and an
isolated QA save directory.  Its recorded `NATIVE_CAMPAIGN_SUMMARY` is:

```json
{"activations":299,"complete":true,"duels":10,"elapsed_ms":109840,"failures":[],"mode":"ordinary_defaults","outcomes":{"draw":0,"win":10},"rewards":10,"routes":36}
```

This supports a real native UI automation route for that ordinary, successful
policy run.  It is still neither physical keyboard/mouse evidence nor Human
play.  Its action selection is an authored public-policy test input; it does
not prove every AI matchup, every save/device/backend, accessibility-user
experience, or release behavior.  Similarly, test12's legal meditation bundle
proves actual resolver/CTA/atlas routing under a controlled opponent, not
uncontrolled-AI animation frequency or balance.

The local 53-command execution is not remote Ubuntu CI.  `verify_ultimate_ui`
is present in the Full Validation headless job after import, while the
Product-Gate workflow has its own path/filter and command boundary.  Current
records accurately retain final exact-head remote CI, protected PR delivery,
merge, and main readback as pending rather than inferring them from this local
batch.

## Untouched consumers, findings, and disposition

Read-only consumer review found no new regression in the test correction:

- The actual board uses `_place_feedback_vfx` fail-closed before making VFX
  visible, keeps the execution-only lane metadata, and clears transient VFX on
  planning; test12's planning negative exercises that existing consumer path.
- The actual board auto subclass's CTA path closes planning and delegates to
  the authoritative resolver; test12 does not set a resolving state or inject
  a successful outcome.
- The engine's documented `clear_locked_enemy_bundle` then
  `lock_enemy_bundle` uses a duplicated state to build the test fixture.  The
  fixture lives only on each discarded Board instance and leaves saved,
  production AI, data, and the ordinary campaign untouched.
- Title/HUD/background/banner, overlay, domain/AI/save/store/codec/campaign
  owners, existing timing/reveal/terminal/SFX consumers, and approved assets
  are outside the test12 mutation and were not found to require a new change.

No blocking code/test/canonical conflict was found.  Retain the following as
real, non-blocking follow-up or delivery gates:

1. exact-head remote CI, protected delivery, merge, and main readback;
2. the five historical warning-bearing local processes and their bounded
   process-teardown diagnostic, without treating it as a proven product defect;
3. already documented visual quality debt, the missing-lane robustness seam,
   and all Human/device/accessibility/release gates.

**Bounded decision:** accept the final test12 source/oracle, the preserved
board-oracle correction, and the internally hash-bound 53-command local native
receipt for continued protected delivery.  Do not promote this to remote CI,
warning-free runtime, Human/visual approval, or release acceptance.
