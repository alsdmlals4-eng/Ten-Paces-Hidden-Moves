# PR337 path12 test-only correction — prepared, native pending

Baseline G `508122f60e6b7ec46cc7deb44ef20754e120c900`. Ratified Decision and plan's second-CI paragraph were fresh-read. Sole tracked edited path: `tests/verify_ultimate_ui.gd`. Controller-owned Decision/plan dirty changes were not edited. Native/import/process actions are NOT_RUN in this preparation; H writer owns the lane.

## Prospective failure and correction

Controller-read exact CI34315801612/job102351681408 at508122 failed three planning-visible assertions after the board verifier passed. The full untouched verifier and actual lane/caller/profile/data were read before editing; source diagnosis is retained in `layout-pr337-ultimate-ui-diagnosis.md`. This is supplied actual CI RED, not a fabricated local RED. TDD/writing-good-tests informed the correction: a wrong planning visibility branch, wrong atlas band, absent actual execution, alpha0 or out-of-lane geometry must fail a behavioral assertion. No production code was changed.

- Planning reservation cases now explicitly confirm the planning state, call the same direct ultimate helper, and require hidden VFX, no positive execution lane, no live VFX tween. All reservation/debit/refund/span/cancellation/lock checks remain.
- The existing actual dock→CTA playback case is parameterized for all three canonical legacy ultimates, with literal timing/band pairs1/0,2/1,3/2 from their authored spans and approved atlas rows. Only unoccupied later slots receive the same meditation/prepare fillers.
- The observer requires the actual player/card execution event at its exact timing, visible-in-tree VFX and strictly positive alpha. It has320iteration and8000ms limits, with the original coroutine path retained. No synthetic success event, changed state to resolving, modified animation timing, custom tween stepping or skip is used.
- Positive checks inspect actual AtlasTexture source/region and independently transform all four effect/lane corners into global space, preserving0.01containment tolerance. The effect/lane must be finite and positive.
- Current default AI/locked enemy behavior is retained. If a multi-slot attack is genuinely interrupted or defended, that is a meaningful fixture outcome to inspect, not permission to force success or weaken the oracle. A separate explicitly controlled legal enemy-action fixture may require controller clarification; it is not currently added.

## Prepared batch (no execution yet)

Ignored `.superpowers/sdd/layout-ci-native-batch.py` defaults to list-only. It extracts the exact31commands from Full Validation's headless job and appends the product job's22distinct commands, enforcing53unique entries. List-only execution succeeded and printed all53; no Godot process launched. It preserves all existing arguments except converting the CI persisted-campaign directory token to a new isolated directory under that run's ignored evidence folder. Source command and exact effective invocation are both recorded.

On later explicit `--execute --godot <exactbinary> --project <exactG>` authorization it writes per-command full combined stdout/stderr, exit, elapsed time, source/workflow hashes, actual printed markers and all ERROR/WARNING lines. Runs use hidden Windows child creation. Default per-command wall timeout120seconds is bounded1..600; there is no `--quit-after`. Timeout records a failure and aborts the batch while reporting the launched PID, without killing it or any other process. Ordinary assertion failures are recorded and subsequent independent commands still execute. Exit0 is explicitly marked `EXIT0_REQUIRES_MARKER_REVIEW`, never silently promoted to runtime PASS. No log text is suppressed or deleted. No imports, baseline edits, native scene changes, workflow changes or generalized test framework are added.

## Preparation verification and freeze

`git diff --check -- tests/verify_ultimate_ui.gd` exited0; Git emitted its LF→CRLF advisory, not a verifier failure. GDScript parse/native is NOT_RUN pending lane grant. Current test hash: `6346F5E0D5D643A3BADDBE2C6BC6567C9E9F48B90CBCB3C6067A148A98840294`; pre-edit hash `26D8E8C865B6E3D07C77EBB257670D89398B2FA518F7E35245F7052327479822`.

The prior11paths independently read back unchanged against the preceding freeze:

```text
791891121D2D13301AF0A0B5E6F50E47951702296FA5BE86D5D2938E942D1A8D src/combat/combat_board_preview.gd
BF838422E70BB595EBF9E40021DFE253B73136AE2A9A2CAEBA4A843EE96BDC2A src/combat/combat_board_preview_auto.gd
17EEA94F124336617C6046AD1F6FD49084F005ADD64148439EDFD03E18F31FF4 src/combat/combat_character_placeholder.gd
AA3E72F24D3886637CD83A8633DA046EA0D98F4F65B07552B2FE97793BD1956C tests/verify_frontal_duel_screen_partition.gd
0A4456812F0E131D527F6B7CD76F4828C347A8A259407DFA9E68BCC944A7CC3B tests/verify_inline_combat_results.gd
605A08DF2B47AD665EB771A6147F7B01E4564216E29C492AEEE189B9932C8280 tests/verify_combat_action_reveal.gd
C42D6A4B19DF25E0865130E56E7A345D3AA9E6C5E22FCCE8B889F08CCFB470A7 tests/verify_actor_ultimate_presentation.gd
94EA2A95702FEFBC36A7C8B9747B4114E18D65E220AC468059A771114E093D56 tests/verify_combat_layout_accessibility.gd
9BCCDAFC520E58CC71B6850D9E25B0B4C99146F79BA5547CAB67363589B66BDC tests/test_combat_feedback_correction.py
948EDC95C3BBC5A1E8465922262E8ECEA01F86336EDF196D99A0399CF2102B53 .github/workflows/validate-ten-manual-product-gate.yml
AECACD5F879B703A4DD7F2F3DFEF0169C3B757EB1D69F77CBA035386E7A7D79D tests/verify_combat_board.gd
```

No new local GREEN/runtime/capture/Human/Blueprint/release assertion. Awaiting controller native-lane and metadata-readiness handoff.

## Granted native execution — ultimate focused correction

Controller restored the three owned background import metadata files from exact backups and granted G exclusive native execution after H completed. No import/editor/process kill was performed by this worker.

Exact focused command: `C:/Users/user/.cache/omenward-tools/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/verify_ultimate_ui.gd`, G cwd. Actual banner4.7.1.stable.official.a13da4feb.

First prepared-test run exited1 in10.469043seconds, `ULTIMATE_UI_RESERVATION_VERIFY_FAILED count=1`: cleave's observed texture was not its expected atlas band1. Wave/void reached positive-alpha observations. The initial observation did not gate feedback kind and did not print actual atlas region, so its printed `band=1` was the expected band, **not evidence that actual band1 was selected**. The specific initial opponent/feedback outcome was not separately logged; no production-defect or exact clash-cause claim is made from this output.

Controller had already permitted a clearly labeled lawful nonattacking opponent fixture when necessary. Only the actual-playback test now creates three canonical enemy `basic_meditate` actions, disables autonomous planning on this isolated test board, clears its initial lock and locks that legal fixture through the existing engine. It then uses unchanged actual dock reservation, actual product CTA, ordinary resolution and playback. No success/outcome event or damage is injected. Reservation/refund/cancel scenarios retain their original setup. The observation additionally requires actual ultimate feedback kind and current visible-event card identity. Production AI and source files remain untouched.

Second focused run exited0 in10.464802seconds and printed `ULTIMATE_UI_RESERVATION_VERIFY_OK`. Actual positive observations:

| Card | Actual timing | Expected band / actual AtlasTexture region | Actual alpha |
|---|---:|---|---:|
| ultimate_ten_paces_wave | 1 | 0 / origin(0,0), size(1774,295.6667) | 0.365714 |
| ultimate_cleave_peak | 2 | 1 / origin(0,295.6667), size(1774,295.6667) | 0.182857 |
| ultimate_void_sword_qi | 3 | 2 / origin(0,591.3333), size(1774,295.6667) | 0.391837 |

Each finite positive transformed effect rectangle was enclosed by its finite positive transformed execution lane with the existing0.01tolerance. This is actual CTA under an explicitly controlled legal opponent, not proof that every uncontrolled matchup should show success VFX.

Both focused runs emitted `WARNING: 2 ObjectDB instances were leaked at exit (run with --verbose for details).` Their cause is not re-investigated here; prior audio teardown preflight remains separate. GREEN is assertion success with warning, not warning-free runtime. No warning suppression or teardown/product repair was performed.

Frozen sole test SHA256 now `7D4BF552A0EE361DB1997178E65A176F4C81A88CCC00055C8615048C307EC2D8`. The53-command batch was started afterwards using the prepared runner with `--timeout 120 --execute`; evidence directory `.superpowers/sdd/layout-native-batch-20260909-150320-467eb847`. Results are still pending at this append; no blanket batch PASS is claimed.

## Final batch readback — all 53 commands completed, warning-bearing success

The preceding pending statements are historical. The authorized batch finished normally, runner exit0, with 53/53 actual command exits0, zero ERROR/SCRIPT ERROR lines and zero timeouts. Sum of individual measured command durations was304.390728800208seconds; this is not an independently measured overall wall-clock duration. Native lane was returned to the controller immediately after completion. No additional native execution follows this report.

Exact G command:

```text
python .superpowers/sdd/layout-ci-native-batch.py --project . --godot C:/Users/user/.cache/omenward-tools/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe --timeout 120 --execute
```

Evidence root: `.superpowers/sdd/layout-native-batch-20260909-150320-467eb847/`. All53 full combined logs and `results.json` are retained. JSON includes each source CI command, effective invocation, script SHA256, workflow hashes, PID, actual exit, duration, error/warning text and extracted markers. The persisted-campaign CI directory token alone was replaced with this run's isolated QA save directory; no production run store was used. No import, editor, process kill, `--quit-after`, log suppression or cleanup occurred.

| # | Script (tests/) | Seconds | Warnings |
|---:|---|---:|---:|
|1|verify_step0.gd|1.0171784|0|
|2|verify_combat_board.gd|5.2286461|1|
|3|verify_inline_combat_results.gd|4.8292784|0|
|4|verify_response_rules.gd|0.5141053|0|
|5|verify_ultimate_interrupt_engagement.gd|0.6140038|0|
|6|verify_ultimate_ui.gd|11.1444875|1|
|7|verify_combat_presentation_liveness.gd|5.0343810|1|
|8|verify_combat_terminal_presentation.gd|4.2251847|0|
|9|verify_combat_focus_order.gd|2.3202660|0|
|10|verify_combat_keyboard_accessibility.gd|2.5190971|0|
|11|verify_combat_layout_accessibility.gd|4.7269311|0|
|12|verify_ai_rival_tendency.gd|0.5132981|0|
|13|verify_vertical_slice_opponent_runtime_binding.gd|0.6135241|0|
|14|verify_vertical_slice_balance_public_policy.gd|0.6136346|0|
|15|verify_vertical_slice_balance_instrumentation.gd|0.8136795|0|
|16|verify_vertical_slice_balance_report_runner.gd|0.8134988|0|
|17|verify_combat_review_summary.gd|0.4124539|0|
|18|verify_combat_review_ui.gd|4.5290914|1|
|19|verify_prepare_momentum.gd|0.5153439|0|
|20|verify_auto_card_placement.gd|4.1238685|1|
|21|verify_action_view_model_adapter.gd|0.5127502|0|
|22|verify_action_selection_dock.gd|1.1146093|0|
|23|verify_basic_action_panel.gd|0.8145195|0|
|24|verify_martial_action_panel.gd|0.8138328|0|
|25|verify_ultimate_action_panel.gd|0.7127290|0|
|26|verify_action_placement_controller.gd|0.8141488|0|
|27|verify_linked_action_blocks.gd|0.8161338|0|
|28|verify_action_repositioning.gd|0.9144725|0|
|29|verify_action_detail_panel.gd|1.1165227|0|
|30|verify_integration_information_boundaries.gd|2.5255060|0|
|31|verify_combat_action_selection_integration.gd|3.4210300|0|
|32|verify_frontal_duel_screen_partition.gd|20.3655804|0|
|33|verify_combat_action_reveal.gd|11.4494524|0|
|34|verify_combat_outcome_feedback.gd|6.3256537|0|
|35|verify_actor_ultimate_presentation.gd|10.6434378|0|
|36|verify_ten_manual_product_gate.gd|0.4121338|0|
|37|verify_ten_manual_product_viewports.gd|1.6157370|0|
|38|probe_sequential_ten_duel_campaign.gd|0.9158579|0|
|39|probe_native_ten_duel_campaign.gd|111.9008818|0|
|40|verify_bimu_constraint_model.gd|0.4126562|0|
|41|verify_bimu_constraint_runtime.gd|3.6239780|0|
|42|verify_bimu_constraint_ui.gd|4.2238016|0|
|43|verify_ten_duel_campaign.gd|0.6135890|0|
|44|verify_vertical_slice_failure_retry.gd|0.6132331|0|
|45|verify_run_save_store.gd|4.2214745|0|
|46|verify_run_save_cache.gd|17.4506529|0|
|47|verify_martial_actor_binding.gd|0.7136401|0|
|48|verify_martial_effect_pipeline.gd|0.5140730|0|
|49|verify_combat_checkpoint_resume.gd|17.0615657|0|
|50|verify_durable_run_continue.gd|12.9443656|0|
|51|verify_action_card_summary.gd|3.0255745|0|
|52|verify_jianghu_rest_presentation.gd|3.6215916|0|
|53|verify_atlas_presentation_successor.gd|3.0235914|0|

Every table row has actual exit0 and zero errors. The five warning-bearing processes (#2,#6,#7,#18,#20) each emitted exactly ``WARNING: 2 ObjectDB instances were leaked at exit (run with `--verbose` for details).`` This is five separate warning-bearing executions, not a claim of only two leaked instances across the batch. Cause remains unverified in this batch. Assertion success does not mean warning-free teardown.

The runner intentionally retains `EXIT0_REQUIRES_MARKER_REVIEW`; manual review of actual final markers/structured summaries was completed rather than treating exit0 alone as proof. Final success markers matched their verifiers. Cases not selected by its generic marker substring were read explicitly: #30 `INTEGRATION_INFORMATION_BOUNDARIES_OK`; #36 `TEN_MANUAL_PRODUCT_GATE_50_SCENARIOS_OK`; #37 `TEN_MANUAL_PRODUCT_VIEWPORTS_OK`; #40 `BIMU_CONSTRAINT_MODEL_OK cases=45`; #41 `BIMU_CONSTRAINT_RUNTIME_OK`; #42 `BIMU_CONSTRAINT_UI_OK` plus ten identical updates/zero changed manual lists; #52 `JIANGHU_REST_PRESENTATION_OK`; #53 `ATLAS_PRESENTATION_SUCCESSOR_OK`. Authored diagnostic FAILED/PASSED text in #35 is not a failing verifier: its final marker is `ACTOR_ULTIMATE_PRESENTATION_VERIFY_OK`, exit0/errors0.

Campaign evidence is separated by execution surface:

- #38 ordinary sequential resolver summary: completed_duels10, attempt_count10, reward_history_count10, route_choice_count36, ultimate_use_count10. This is not actual shell/UI proof.
- #39 actual persisted native campaign summary: `complete=true`, `duels=10`, `activations=299`, `mode=ordinary_defaults`, outcomes win10/draw0, rewards10/routes36, failures empty; internal elapsed_ms109840, outer measured111.9008818seconds. It finished under the unchanged120second deadline, with no error/warning or timeout. Controller later noted another historical execution took162.57seconds and recommended300seconds for a future run of this individual slow command; that does not change this completed run or justify extending every command. No retry was needed or run.
- #43 explicitly prints `TEN_DUEL_CAMPAIGN_STATE_OK (synthetic terminal results; not full battle playthrough)` and remains a state test, never substituted for #39.

## Final integrity and handoff limits

Post-batch SHA256 readback retained test12 `7D4BF552A0EE361DB1997178E65A176F4C81A88CCC00055C8615048C307EC2D8`; all prior11 hashes listed above were independently read back unchanged, including all three product files. Final scoped `git diff --check -- tests/verify_ultimate_ui.gd` exited0 (Git's LF→CRLF advisory retained). No Git mutation/commit/push/merge was performed.

- Runner SHA256: `4E5BE0CD4541F6DEA61E6261E8A6F3E68E327C6EEB34F5C8141C73C80DB08DE1`.
- Results JSON SHA256: `666298F5662E1C0D813D84E4ACBF39C9E658889A5E0E8AF6C071410F83331F4B`.
- Full-validation workflow SHA256: `B63DC07CABE7AFF1816D0BF08C9D62D1E2D7942E5CB032BF73BD42B6017A1619`; product workflow hash remains the prior11 value above.

Final working status also contains controller-owned dirty Decision/plan, root-restored three untracked background `.import` metadata files, and native-generated untracked `artifacts/ten-manual-product-validation/` and `focus-order-report.txt`. They were preserved, not staged, deleted or claimed as this worker's owned source changes. The isolated QA save and all logs are retained. The sole owned tracked test is frozen for independent review.

This closes the authorized local test-only correction and exact53-command regression evidence, not a new CI result, whole Python suite, visual capture, physical-device/accessibility-user, Human/aesthetic acceptance, full Blueprint completion or release approval. No unsupported loop count or fresh-context claim is added. Controller retains integration, warning follow-up and final publication ownership.

## Independent controller readback

Controller read the complete correction, actual final test diff, both CI owners, source profile and all 53 result rows plus the actual persisted-campaign summary. The planning reservation test retains its original domain meaning. The execution cases explicitly use three legal meditation actions for the opponent and run the normal resolver through the actual dock/CTA, so interrupted or clash feedback is not falsely treated as the required ultimate-only atlas band.

Controller independently reran this exact final ultimate verifier: exit0, 11.3127669 seconds, all three actual timing/band/positive-alpha/global containment markers. That one execution emitted no ERROR/WARNING; earlier warning-bearing executions remain valid observations and are not reclassified. Existing 11 inputs and product sources remained unchanged. The test-only fixture does not assert default AI balance or every matchup's successful ultimate animation.

The raw command/readback/log companion is `native_ci_readbacks.json`. Five warning-bearing batch executions remain follow-up evidence. Linux CI at the final test-corrected head, protected delivery and postmerge main readback remain separate gates.
