# Board audio teardown — bounded read-only preflight

2026-09-09. Source-only follow-up to `layout-pr337-board-oracle-correction.md`. No new native execution/log, import, Git, process operation, product or test edit occurred. The board test remains frozen at SHA `AECACD5F879B703A4DD7F2F3DFEF0169C3B757EB1D69F77CBA035386E7A7D79D`.

## What is proved, and what is not

Existing corrected-board runs exit0 but emit two ObjectDB teardown warnings. The already-recorded verbose run identifies one `AudioStreamWAV` and one `AudioStreamPlaybackWAV`, each reference count1, plus orphan StringName `Master`. It does not identify the cue, owning player, C++ allocation stack or pending audio-server reference. That exact cause remains **UNVERIFIED**. The old RED run did not print the warning; this is not sufficient evidence that the new geometry test created an audio leak.

## Source-backed call chain

| Stage | Actual owner and behavior |
|---|---|
| Generate/cache | `src/ui/combat_sound_bank.gd:23–59`: `get_stream(kind)` creates `AudioStreamWAV` at54, sets PCM format/rate/data and retains it in static `_streams[kind]`. Subsequent requests reuse that stream. |
| Scene ownership | `src/combat/combat_board_preview.gd:426–434`: creates two child `AudioStreamPlayer`s, ordinary and momentum, then warms all12 cues. There is no separate explicit `AudioStreamPlaybackWAV.new()` in project source. Engine playback is requested by player.play. |
| Event playback | Board `1999–2017` chooses effect cue from actual event; `2067–2077` selects cached stream, assigns it to the ordinary or momentum player and invokes `play()`. Muted requests return before lookup/play. |
| Most likely final playback opportunity | Board `1158–1161` assigns final bundle state, detects a positive momentum change and requests momentum_charge; `2055–2065` selects that cue, whose authored duration is0.24s (`combat_sound_bank.gd:15`). It immediately finalizes the bundle. The last cue actually played in the observed warning run was not logged. |
| Ready transition | Board `1243–1253` calls `_advance_to_next_bundle` for a nonterminal result; `1280–1310` sets next context/UI and `next_bundle_ready`. It does not wait for sound completion, appropriately keeping gameplay/UI state independent from audio duration. |
| Test exit | `tests/verify_combat_board.gd:403–426` polls at0.05s intervals and returns as soon as the second bundle is `next_bundle_ready`. `_run:72–74` then queues the board for deletion, waits one process frame and calls `_finish`/quit. This wait is not proof that an audio backend has relinquished all references. |
| Existing cleanup | Board `153–159` already stops both players and nulls both streams in `_exit_tree`; no subclass `_exit_tree` override was found. Restart (`1857–1860`) and mute (`1889–1894`) also stop playback. Therefore “forgot to stop/free the board audio player” is not demonstrated and must not be stated as the cause. |

## Ranked explanations, explicitly hypotheses

1. **Short process lifetime versus asynchronous audio-reference release**, strongest source-consistent hypothesis. A0.24s charge cue can begin directly before ready, and the test quits after deletion plus one frame. Stop/null may be applied while the server still owns the playback/stream pair. The paired leaked classes and ready→quit sequence fit this, but current evidence does not prove backend scheduling or identify the final cue.
2. **Cache/script teardown ordering** could retain a stream alongside playback. The bank intentionally caches12 streams, whereas only one WAV/playback pair was reported; this weakens a simple “all cached streams leaked” explanation. Do not clear the product cache opportunistically or blame static caching alone.
3. **A separate unexpected retained reference or engine defect** is not ruled out. The new geometry helper stores only value-type bounds/dimensions, allocates temporary Image objects, never calls audio and restores scale synchronously. That limits its direct causal plausibility, not a proof of innocence; its extra work could alter timing.

The engine's generic removed-but-not-freed-node hint is not an allocation trace or verified project cause.

## Existing related evidence boundaries

- `tests/verify_combat_sfx_presentation.gd:41–65` exercises actual playback, mute and volume. Its teardown at67–70 waits a process frame **plus0.1s** after board deletion. This timing difference is a useful diagnostic control, not proof that0.1s is a universal correct delay. It was only read, not rerun here.
- `tests/verify_combat_outcome_feedback.gd:183–197` directly instantiates a victory playback, pulls a bounded number of mixer samples to natural completion, stops/releases the playback and clears the test's static bank cache. This proves a different low-level lifetime when executed, not AudioStreamPlayer/board/audio-server teardown. Its existing result is not reused as a fresh PASS in this preflight.

## Minimum discriminating follow-up, only after lane authorization

Use an ignored small harness or the existing audio verifier; do not alter the frozen board test merely to silence stderr.

1. Observe actual last cue, each player's playing/stream identity immediately at ready and prior to board deletion; retain only IDs/strings in diagnostics, not new stream/playback references that would perturb refcounts. Capture exact verbose teardown for the ordinary unmuted path.
2. Compare the same board path with audio muted before the final bundle, preserving identical plans, resulting state and assertions. Warning disappearance supports playback linkage, not yet cleanup correctness. Do not promote this muted variant as the final audio regression.
3. Compare natural sound completion before deletion, using a bounded predicate/deadline and explicit failure, with immediate deletion plus bounded post-free process drain. These separate active-playback stop from process exit/server-drain timing. Preserve actual cue lengths and do not introduce gameplay waits.
4. If warnings survive both, reduce to one real AudioStreamPlayer/cached cue with explicit stop/null/free and compare uncached locally-owned stream; only then consider engine/source allocation tracing or narrowly changing cleanup ownership.

All proposed probes are **NOT_RUN**. Any fix requires a reproducible before/after warning result and normal playback/mute/restart regression, not just an extra sleep or zero-warning assertion under disabled sound.

## Minimal future scope and disposition

- If the defect is solely harness shutdown: a bounded test-only teardown correction in `tests/verify_combat_board.gd` (and a matching diagnostic regression in the existing audio verifier only if needed). No changes to domain, PCM, cue cache or presentation timing.
- If real board destruction leaves audio ownership alive during normal runtime: only `src/combat/combat_board_preview.gd` audio lifecycle plus the existing focused SFX verifier, after controller ratifies scope and prospective RED. Do not expand to audio architecture or mutate sound-bank bytes without specific evidence.
- Current recommendation: preserve warning disclosure and the frozen oracle correction; collect the discriminating evidence in a separately authorized native lane. No proven product fix is available from this read-only pass.

Fresh-read relevant source hashes: board `791891121D2D13301AF0A0B5E6F50E47951702296FA5BE86D5D2938E942D1A8D`; sound bank `F7832BBCB307FAD7624F1457DEFA14D7ACAD4C7D5F239F17415BDA88BF194F34`. A few initial guessed audio/test paths and literal PowerShell wildcard path searches returned not-found; correct owners were found using `rg --files`. These were read-only discovery errors, not runtime failures.

## Authorized native diagnostic follow-up — 2026-09-09 15:19–15:20 local

The earlier NOT_RUN statements describe the preceding read-only stage and are retained. Controller explicitly granted six bounded native comparisons in G, after restoring required metadata, with no tracked edits/import/process kills. This is same-package teardown diagnosis, not a new player-facing design. Project AGENTS/router and actual verifier/cleanup/cache were fresh-read; `python tools/check_project_operating_system.py` returned PASS. A guessed local verification Skill path did not exist (read-only discovery failure). Actual Base `diagnosing-game-engine-runtime-failures` and `systematic-debugging` Skills were fully read and used in reproduce/isolate/form-hypotheses mode; they kept this work to controlled comparisons and prevented a speculative product fix. No external engine-source claim is made; current-source relevance is exact4.7.1 local reproduction, not a new architecture or gameplay benchmark dimension.

Only ignored helpers were created: `layout-audio-teardown-probe.gd` and `layout-audio-teardown-runner.py`. The probe extends the **unchanged** `tests/verify_combat_board.gd`, calls its original `_initialize`, awaits its original second-bundle verification, and calls its original `_finish`. Every original assertion and normal board deletion remain. It prints scalar player state/stream IDs just before deletion, without storing stream/playback references. The only controlled differences are:

- normal: Master bus explicitly unmuted; no extra finish wait;
- bus_mute: AudioServer Master bus muted from startup; product `_sound_muted` remains false and product playback remains enabled;
- drain: unmuted; after the original board queue_free + frame, before original finish/quit, await a0.3second SceneTreeTimer. Actual wall deltas were282ms and290ms, recorded honestly rather than asserting a measured300ms minimum.

This inherits the original test execution path, not a copied or weakened test. No success events, fake outcomes, altered cue data, extra stream stop, cache clearing or gameplay delay was introduced. Post-free drain changes only process shutdown timing. The helper observes the final player's0.24second stream and actual playing flag in all six executions.

Exact runner command from G: `python .superpowers/sdd/layout-audio-teardown-runner.py`. Each child used:

```text
C:/Users/user/.cache/omenward-tools/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe --headless --verbose --path C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves/.worktrees/combat-layout-20260909 --script res://.superpowers/sdd/layout-audio-teardown-probe.gd -- --audio-probe=<normal|bus_mute|drain>
```

Each condition ran twice in a fresh process, sequentially, with30second wall deadline. Hidden console processes were launched by the runner; no timeout occurred and no process was killed. The Windows console wrapper PID differs from the runtime PID printed by `OS.get_process_id`; both are retained below. The runner does not claim it collected a separate CIM parent/creation trace. Exact invocation and launch timestamps are in JSON, original startup/version and verbose output in six unfiltered logs. Actual backend was **Dummy**, not WASAPI/device audio.

Evidence directory: `.superpowers/sdd/audio-teardown-20260909-151931/`.

| Condition/run | Console PID / actual runtime PID | Start local | Seconds | Exit / errors | Warnings |
|---|---|---|---:|---|---|
|normal1|34656 /29544|15:19:31.923056|5.3049635|0 /0|2 ObjectDB instances|
|normal2|28704 /22524|15:19:37.229704|5.2088311|0 /0|2 ObjectDB instances|
|bus_mute1|28948 /33384|15:19:42.440275|5.3007489|0 /0|0|
|bus_mute2|27056 /18236|15:19:47.742450|5.3065364|0 /0|0|
|drain1|20232 /27388|15:19:53.050629|6.2634003|0 /0|0|
|drain2|18216 /5992|15:19:59.317081|6.0643622|0 /0|0|

All six printed the complete original `COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_STEP7_STEP8_STEP9_STEP10_TARGETING_10_5_START_4_6_VERIFY_OK`. All reached `next_bundle_ready`, bundle3, failures0, product_muted=false. Ordinary player was not playing, with length0.2; MomentumSfxPlayer was playing, length0.24. Thus bus mute did **not** remove the playback path or silently switch product mute on. Runner itself exited0. Native lane was immediately returned to the controller after the sixth completed process.

### New exact identity evidence

Both normal runs printed MomentumSfxPlayer `stream_id=-9223371967279658889`. Interpreted as the same64-bit unsigned ID, this is `9223372106429892727`, exactly the WAV ID in both verbose leak records. This now identifies the last momentum stream as the leaked WAV in this specific reproduction; it does not identify every historical warning's cue.

```text
normal1:
Leaked instance: AudioStreamWAV:9223372106429892727 - Reference count: 1
Leaked instance: AudioStreamPlaybackWAV:9223372196506766317 - Reference count: 1
normal2:
Leaked instance: AudioStreamWAV:9223372106429892727 - Reference count: 1
Leaked instance: AudioStreamPlaybackWAV:9223372196489989101 - Reference count: 1
both:
Orphan StringName: Master (static: 0, total: 2)
WARNING: 2 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
```

The generic cleanup location is **not an allocation trace**. We did not retain a playback reference to inspect its identity. The WAV identity, final active player and disappearance after post-free drain strongly support pending playback/server cleanup at immediate process exit. They do not independently prove a particular C++ queue, race or backend bug. Two clean mute runs cannot prove universal behavior and mute is not a fix: all runs used the Dummy driver, and timing nondeterminism remains possible. Controller also observed a separate clean ordinary ultimate run; historical five warning-bearing batch executions remain valid evidence.

### Minimal recommendation, not applied

Recommend the **test-process shutdown layer first**, not production audio architecture: if a retained correction is desired, independently ratify a bounded post-board-free teardown drain for this verifier and test its real playback/no-warning behavior without muting. Existing product `_exit_tree` stop + stream=null is already reached through ordinary deletion; keeping gameplay independent of audio duration remains correct. Do not add waits to bundle transition, change cues, clear the shared cache or suppress warnings. A fixed0.3timer is a useful demonstrated diagnostic control here, not a guaranteed universal synchronization API or proof that production has no lifetime issue.

Production board lifetime is not proven leaking during a continuing game: these tests only observe process exit. A future product-layer repair requires independent evidence of lingering references after board destruction in a sustained runtime, or exact engine/backend ownership tracing. Real device audio, long-session repeated board replacement, source-level allocation tracing and sanitizer evidence remain NOT_RUN. No fix was applied and no new warning-free whole-suite/CI/Human/release claim is made.

### Integrity

Before/after and final readback matched unchanged board verifier `AECACD5F879B703A4DD7F2F3DFEF0169C3B757EB1D69F77CBA035386E7A7D79D`, board `791891121D2D13301AF0A0B5E6F50E47951702296FA5BE86D5D2938E942D1A8D`, and sound bank `F7832BBCB307FAD7624F1457DEFA14D7ACAD4C7D5F239F17415BDA88BF194F34`.

- Probe SHA256 `8DAB3D66064BACA8CA0C65D4F81FC5061B08A1367381DF3F97B63C07DF6CAF64`.
- Runner SHA256 `32360E437C0491421D77EC9C97046A094603DF9B50225BADACFD01FA59504F3F`.
- Results JSON SHA256 `3869968AA221362082FAB48D3CA3B97BAC83C0EE4F6C34C9A350E5B47890A6BB`.

No tracked product/test/canon or Git state was edited by this diagnostic. No import, cleanup or unowned process operation occurred. The six raw logs and diagnostic helpers remain ignored for audit, not release assets.
