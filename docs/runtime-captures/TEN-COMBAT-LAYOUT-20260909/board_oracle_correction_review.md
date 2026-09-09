# PR337 board-verifier visible-ink oracle correction

## Diagnosis before mutation

Worktree G: `C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves/.worktrees/combat-layout-20260909`. Controller-supplied exact clean HEAD: `6433e1f44fa119535360b3ba1c09709713e9ba9d`. Scope proposal: only `tests/verify_combat_board.gd`; no product/canonical/Git/import/process changes.

Controller inspected exact CI run34313348268, job ubuntu-godot-headless: `verify_combat_board.gd` failed once at the comparable frontal-duel scale assertion (line482). This CI observation is controller-supplied evidence; this worker has not independently fetched that remote log.

Fresh-read G AGENTS/router/adopted route, current layout Decision/plan, actual board snapshot, character renderer and old verifier. `python tools/check_project_operating_system.py` returned exit0 and `project operating system: PASS` before routing. Used systematic-debugging and project contract-check/regression guidance; TDD and verification-before-completion references read for the proposed correction. Same ratified layout/source-alpha decision dimension and sources are reused explicitly; no new design, image or outside claim is introduced.

The source mismatch is direct:

- `tests/verify_combat_board.gd:479–489` compares snapshot player_size/enemy_size node heights and applies the52% cap to those node heights.
- `src/combat/combat_character_placeholder.gd:105–112` draws a square of node_height×1.08, with a role-specific source alpha extent. `117–140` applies visual scale/offset, mirroring and global transforms to actual occupied pixels.
- The ratified Decision explicitly normalizes visible ink rather than node size; plan§4.3 defines the source-alpha factor and46% default, peak1.12 and52% hard cap. Different transparent margins therefore require different node heights, so equal Control sizes are no longer the correct observable.
- Existing `tests/verify_frontal_duel_screen_partition.gd:203–228` independently reads source image alpha and transforms its four corners. This provides a working source-backed verification pattern; it is not necessary to change any production getter.

Recommended minimum: replace only scale/cap assertion inputs with independently computed global occupied ink bounds (idle comparison, current animated cap and idle×existing1.12 envelope cap), preserving SIZE_TOLERANCE0.01. Transform stage bounds into the same global coordinate space. Factor scale errors into a small test-only helper and prove it rejects real unequal visible heights by temporarily scaling the enemy y by0.8, then restoring exactly and rechecking; leave all anchor, HUD, domain and input assertions unchanged. Missing/empty art or nonpositive stage is a failure, not a vacuous skip.

No test edit or Godot execution yet: waiting for controller's explicit eleventh-path ratification and native-lane permission. No clean/CI/Human completion claim.

## Authorized implementation and local RED→GREEN

The controller subsequently ratified the additional eleventh test-only path in the Decision/plan and granted G's exclusive native lane. Those current ratification paragraphs were fresh-read before mutation. Controller restored the three required background import metadata files from its verified backup; this worker did not import or restore anything.

Only `tests/verify_combat_board.gd` was changed. Original hash: `67B7AD0C3ADDCE2C4D3B8C4D72B8FA40943AC04E5C869D6CFE8272C412D8EB39`. Final frozen hash: `AECACD5F879B703A4DD7F2F3DFEF0169C3B757EB1D69F77CBA035386E7A7D79D`.

Implementation: `_character_ink_scale_errors` replaces only the obsolete node-height scale/cap assertions; the rest of `_verify_character_anchors` is unchanged. `_independent_character_ink` reads the raw PNG alpha once per source and computes occupied corners using observed Control size, draw1.08/pivot/offset/mirroring and actual global transform. It never calls the production visible-bounds getter. Stage uses the board's global transform as well. Missing art/zero stage fail explicitly. SIZE_TOLERANCE0.01,52% cap and independent known existing peak1.12 are unchanged.

The actual scale0.8 negative control is synchronous with immediate exact restoration, no await or domain/timing mutation. It calls the same scale-error consumer, requires the comparable-scale error, verifies measured80% height and restoration, then verifies the restored ordinary case. Final observed values:

```text
INK_SCALE_NEGATIVE_CONTROL original=120.519996643066 scaled=96.4159927368164 mismatch_detected=true
```

Exact binary for every run:

`C:/Users/user/.cache/omenward-tools/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe`

Exact cwd: G. Command pattern: `<binary> --headless --path . --script res://tests/<filename>`. The diagnostic board rerun adds `--verbose` after `--headless`. Observed version: `4.7.1.stable.official.a13da4feb`. Stopwatch durations include process execution, not import or a full suite.

| Run | Exit | Seconds | Actual evidence |
|---|---:|---:|---|
| Untouched verify_combat_board.gd | 1 | 5.4536871 | Same comparable-frontal-duel-scale assertion; FAILED count=1; no warning text |
| Corrected verify_combat_board.gd | 0 | 5.4439082 | VERIFY_OK; ObjectDB2 teardown warning |
| Untouched verify_frontal_duel_screen_partition.gd | 0 | 20.7887381 | FRONTAL_DUEL_SCREEN_PARTITION_VERIFY_OK; bounded-motion negative controls printed; no ERROR/WARNING |
| Untouched verify_combat_layout_accessibility.gd | 0 | 5.8427054 | COMBAT_LAYOUT_ACCESSIBILITY_VERIFY_OK; actual settled-text bounds at five sizes; no ERROR/WARNING |
| Corrected board verbose diagnostic | 0 | 5.4559667 | VERIFY_OK; identifies leaked audio object classes below |
| Final board after adding measured negative-control diagnostic print | 0 | 5.9002316 | Actual120.52→96.416 mismatch detected; restored ordinary checks and all existing board assertions pass; ObjectDB2 warning remains |

The last change before final board execution was one diagnostic print; partition/accessibility files and all product inputs stayed byte-identical. No syntax-error iteration occurred. Local RED independently reproduces the controller-supplied CI failure; the negative control demonstrates real unequal ink remains rejected after correcting the stale observation unit.

## Teardown warning — preserved, not mislabeled as clean runtime

Both normal corrected board runs and the verbose run printed:

```text
WARNING: 2 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
```

Verbose allocation identity output:

```text
Leaked instance: AudioStreamWAV:9223372106211788918 - Reference count: 1
Leaked instance: AudioStreamPlaybackWAV:9223372195265252332 - Reference count: 1
Orphan StringName: Master (static: 0, total: 2)
StringName: 1 unclaimed string names at exit.
```

The leaked classes are verified. Their exact allocation/call-site and the difference from the RED run are **CAUSE_UNVERIFIED**; the generic engine hint about removed/unfreed nodes is not a proven root cause. This correction added no audio object or playback call, but that alone does not prove causation absent. No product/audio/teardown repair or warning suppression was attempted in this test-only scope. Native assertions passed with these teardown warnings; do not report warning-free board runtime.

## Frozen unchanged inputs / bounded review

Readback of all ten prior implementation paths matched the pre-edit hashes exactly:

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
```

Final readback attacked the corrected assertion, actual source-alpha/transform relation, fail-closed absence checks, negative mutation/restoration, unchanged anchor/HUD/domain consumers, cap/tolerance preservation, test-only bounded source cache and evidence ceiling. Retaining node-height checks or loosening tolerance were rejected; using only the production bounds getter was rejected as a self-confirming oracle. Independent raw-alpha corners are the minimum source-backed correction, not a new production framework. This is a scoped correction/recheck within the existing layout review lineage, not five new full-scope loops or self-approved independent review.

Frozen for controller review. Exclusive native lane explicitly returned after final board execution, before report writing. No further native run will occur without renewed lane permission. No Git/import/editor/process kill/full pytest/visible capture/canonical or product change. Exact Linux CI rerun, independent final review and publication remain controller-owned and NOT_RUN by this worker; Human/device/Blueprint completion is not claimed.

## Independent controller review and execution

The controller read the complete test diff and report, the renderer's actual source alpha/draw/global-transform ownership, the board verifier's full call order, and the existing Full Validation workflow. The corrected test remains a real native command after import in the unchanged ubuntu-godot-headless job. No workflow skip or tolerance change was introduced.

The earlier five full-scope source/capture reviews remain bound to the unchanged ten implementation inputs. This incremental review covers the eleventh test path, the explicit ratification, unchanged inputs and actual new failure/success evidence. It is not retrospectively relabeled as a new five-loop implementation review.

Controller independently ran the final frozen board test with the same exact Godot binary in G: exit0, 5.3382864 seconds. The real 120.519996643066 to 96.4159927368164 negative control was rejected and restored successfully. The same two ObjectDB teardown warnings were observed and retained; this is assertion PASS, not warning-free runtime PASS. No editor/import/product mutation or other worktree's native test was run concurrently.

Independent conclusions: raw image alpha and transformed corner math correctly use the approved visible-ink unit; same global coordinate space and unchanged motion envelope preserve the cap. The synchronous actual-transform negative cannot advance timing or gameplay and immediately restores the original scale. Missing image/positive-area checks fail closed. Source caching is local to the verifier, introduces no runtime frame cost and does not create another production geometry owner. Existing anchor, HUD, core, save, asset and input assertions remain untouched. The exact Linux CI rerun and main readback are still required; the audio teardown seam and previously documented visual quality limits remain explicit follow-up work.
