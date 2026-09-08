# Durable save and continue implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. The current user authorizes continuous implementation and normal protected integration; no routine execution-choice question.

**Goal:** Persist the actual ten-duel run and deterministic combat boundaries and connect safe Continue/recovery to the existing game.
**Spec:** `docs/decisions/2026-09-08_DURABLE_RUN_CONTINUE.md`.
**Pre-publication corrective spec:** `docs/decisions/2026-09-09_MARTIAL_ACTOR_BINDING_CORRECTION.md` (Task5 only).
**Architecture:** Explicit run codec, validated local store, combat checkpoint producer and one shell session coordinator. Existing resolver/run/progression remain rule owners. No generic Node serialization.
**Tech Stack:** Godot 4.7.1/GDScript, FileAccess/DirAccess/JSON/HashingContext, current native SceneTree and Python contracts.
**Base:** `27f7d922e8ec36e038c6dc943b069161b8b53536`.

## Global constraints

- Preserve all existing combat, AI public-information, scouting, reward, retry, manual loadout and 10-duel/36-route rules. No new assets, cloud, paid dependencies or engine changes.
- Task5 explicitly corrects actor-specific mastery/stat consumer defects before first save publication. It preserves authored numbers/IDs and schema shape1 while changing semantic compatibility to `ten-duel-four-route-one-retry-bimu-actor-bound-save-v1`. Task4 preserves domain rules, schema and content semantics; its demonstrated transport-validation exception is the encoder upper-bound/exact JSON roundtrip guard recorded in the reviewed execution report, not a new save format or gameplay rule.
- Save stable domain boundaries, never intermediate animated combat_state. UI must not recalculate combat/reward.
- Restore must fail closed without partial live mutation or destroying primary/backup evidence. No silent sanitization of malformed data.
- Preserve unrelated worktrees, dirty files, Draft PRs, approved PDFs and image originals. Do not stage generated .godot/import/UID churn.
- Tests must use a unique injected storage directory, never the user's actual production save. Script-launched test processes default persistence OFF unless explicitly configured with a test directory; normal project launch defaults ON. This is an execution-entry adapter, not headless-dependent gameplay.
- Follow prospective TDD: first executable tests fail on missing behavior, not just parse/import errors; minimal implementation then focused regressions. Controller owns review/capture/PR/merge; implementers commit only, no push/merge or subagents.
- Record actual evidence and remaining NOT_RUN gates in `docs/operations/2026-09-08_DURABLE_SAVE_EXECUTION_REPORT.md`. Project minimum five real full-scope review loops governs over newer generic Base drift; no fictitious counts.

## Task 1: Explicit run snapshot and validated recoverable store

**Files / responsibility**
- Modify `src/run/vertical_slice_run_state.gd`, `src/run/vertical_slice_progression_state.gd`: export/validate/import explicit snapshots. Validation must finish before any live assignment; reconstruct models rather than serialize objects.
- Add `src/run/run_checkpoint_codec.gd`: bounded JSON-safe and strict domain validation, content compatibility identity and schema envelope/hash. Keep file IO out of this codec.
- Add `src/run/run_save_store.gd`: injected-root file IO, temp/readback validation, revision, validated backup, recovery status, generation replacement/tombstone. No UI or combat calculations.
- Add `tests/verify_run_save_store.gd`, `tests/test_durable_save_contract.py`; bind focused native test in `.github/workflows/validate-ten-manual-product-gate.yml` and its actual invoked runner if it owns the list (fresh-read before editing).
- Add this package's scoped `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json` and append `docs/implementation/BUILD_APPROVAL_2026-09-08.md`, listing only actual protected paths. Source main remains the base above; the adopted validator's protected comparison baseline is `bf161025b63edd7eb441b2c4f2ae9da5155f68da` from the current adapter. Its diff to source main contains no protected product changes. Keep that protected baseline in the manifest/checker rather than bypassing or changing the adoption pin. Preserve historical retired approval archives.

**Interface for subsequent tasks**
- Run state exports a deep JSON-safe dictionary; strict validate/import reports success/error and restores every mutable field, including progression, pending receipts, frozen constraints, prebattle retry snapshot, attempt/counters/history.
- Store saves and loads an envelope with run_state plus optional combat_checkpoint; pure validation rejects unknown schema/content. Public result dictionaries distinguish absent, valid primary, recovered backup, incompatible, corrupt, IO failure; expose validated payload only.
- Store is configured with a path. No production IO on construction, no autoload. Same logical checkpoint identity can be saved idempotently. New-run/retire operations acknowledge only after both generations' recovery slots are consistent. A failed replace never reports success.
- Idempotency additionally requires equal generation AND normalized payload hash. Same route/result position with new pending data must write a new revision. Failed-write retries reuse the identical pending revision/payload. Test route pre/post selection, RESULT pending selection, and retry invariance.
- Combat payload validation extension is owned in Task 2; until then reject nonempty unsupported combat payload, not arbitrary dictionaries.

**Steps**
- [ ] Read actual run/progression fields and their mutation consumers, approved adapter save contract, package spec/research. Run project operating validator first.
- [ ] Write focused behavioral tests using dynamic load/has_method to turn missing APIs into explicit assertions and exit 1. Test fresh run roundtrip, training/route pending/results/retry fields, strict fractional/string/bool numeric rejection, wrong pairs/IDs/counters, no partial mutation, primary and backup statuses, failed temp/rename, unknown schema preserved, malformed/bounded JSON, generation replacement/retirement. Record executable RED before implementing.
- [ ] Implement the smallest explicit API, sharing authoritative current catalog checks. Numeric JSON representation must remain hash-stable after stringify/parse (integers may parse as floats); hash canonical serialized normalized supported values, not unstable Variant type rendering. Reject NaN/Infinity. Hash excludes integrity_hash itself. 8 MiB input bound, depth 64 and 100000 nodes are conservative technical defaults.
- [ ] Do not rely on permissive `restore_snapshot` casts/clamps as validation. Ensure full run snapshot is internally consistent, not merely key-present. Stored prebattle receipt gets validated in the fresh full-run context.
- [ ] File faults use an injected bounded test seam, not production special-case success. Preserve corrupt primary evidence and known-good backup. New generation/retire must not resurrect the prior run after acknowledgment. Incompatible readable primary must not silently downgrade via older backup.
- [ ] GREEN focused native and Python, existing progression/route/result/retry tests, full pytest once. Update active approval exact owned paths, report test output, self-review and commit. Report DONE_WITH_CONCERNS if codec extensibility or incompatible-save handling remains unresolved; do not claim Continue is wired yet.

## Task 2: Deterministic combat boundary export and restore

**Files / responsibility**
- Modify `src/combat/combat_board_preview.gd`, `src/combat/combat_board_preview_auto.gd` only where active presentation state needs it.
- Modify `src/combat/combat_resolution_engine.gd` for exact enemy lock snapshot/restore, without changing AI decisions.
- Modify `src/run/vertical_slice_combat_bridge.gd`, `src/ui/action_timing_panel.gd` (verify actual path first) for checkpoint/finalize/timing interfaces.
- Add `src/run/combat_checkpoint_codec.gd` for the strict combat DTO and delegate to it from Task 1 codec, keeping domain validation focused rather than growing the file-store class. Add `tests/verify_combat_checkpoint_resume.gd`, bind actual CI runners and Python binding assertions. Extend approval/report only actual owned paths.

**Hooks / semantics**
- Emit/request BUNDLE_COMMITTED after `_committed_player_plan_snapshot` and `_committed_state_before` are complete in `_on_progress_requested`, before resolver. Persistence failure can synchronously veto resolution while keeping commitment frozen for retry.
- Capture BUNDLE_RESOLVED from resolver result.state plus real review summary immediately after synchronous `resolve_bundle`, before animation awaits. Keep an immutable last-stable DTO for lifecycle flush. Do not read the animated board state for disk flush.
- Capture PLANNING only after initial configuration or `_advance_to_next_bundle` has updated round/bundle, AI lock and observation. Snapshot baseline before any reversible plan placement/reservation. Unsaved partial plans are intentionally discarded on process restart, as the spec says.
- Restore a committed snapshot by importing exact state/context/plan/enemy lock, then resolving once. Restore a resolved snapshot by common finalize using authoritative final state/summary, without rerunning resolver or animations. Terminal receipt handoff remains exactly once and uses final resources.
- Internal REVIEW is not durable: terminal ready/confirmed are one coordinator transaction publishing only RESULT/FAILURE_RETRY. A crash between the two signals restores the prior durable RESOLVED checkpoint and completes once; a delayed callback sees the applied boundary and does nothing. Test both victory and defeat in that exact gap.
- Restore a planning snapshot without another observation reveal, reservation or AI redecision. Preserve full player/enemy statuses, modifiers, martial preparation, metrics, public history, observation state and existing AI seed. Do not connect run_seed or change current AI seed behavior.
- Preserve the original lazy/eager enemy-lock timing: an initial PLANNING baseline may have an empty lock after bridge reconfiguration; do not force an earlier AI decision. Before COMMITTED capture obtain the lock at the same point the resolver would use it. If the player explicitly reveals observation while planning, persist the changed observation fields and actual lock in the stable planning baseline while excluding reversible placements/reserved momentum. Test observe -> reopen and partial plan -> observe -> reopen: no point refund, no new lock, no second reveal, no retained unsent ultimate spend.
- No runtime object serialization. Rebuild binding/loadout/model dependencies first; verify saved identity. Keep integer-key maps as entry arrays when serialized. Do not call ultimate reserve again on committed restore.

**Steps**
- [ ] Read Task 1 report/API, actual board/engine/bridge/timing and existing terminal/ultimate/observation regressions.
- [ ] Prospective native RED for planning, committed and resolved roundtrip, both nonterminal and terminal. Assert lock equality, resource/status/metrics equality, no double ultimate spend, no duplicate observation, one terminal receipt and no UI future-action disclosure. Add corrupt-state rejection cases.
- [ ] Implement checkpoint producer/export/import and explicit persistence veto/ack interface. Existing standalone board and tests with no coordinator must retain current behavior.
- [ ] GREEN focused plus existing inline, ultimate, AI public boundary, bridge/result regressions; full pytest once. Report exact tests and compile/native exit. Commit. Shell/title disk integration is next task, not claimed here.

## Task 3: Connect real Continue, lifecycle and transactional progression

**Files / responsibility**
- Add `src/run/run_session_coordinator.gd` for last durable DTO, store errors, stable run/combat transactions, continuation orchestration and test storage injection.
- Modify `src/run/vertical_slice_shell.gd`, `vertical_slice_shell_result_auto.gd`, `vertical_slice_shell_route_auto.gd`, `vertical_slice_shell_completion_auto.gd`, `src/ui/main_title_screen.gd`, `src/ui/bimu_constraint_panel.gd` and existing main scene only if necessary.
- Touch `src/combat/combat_board_preview.gd` only for the lifecycle adapter's pause-aware presentation waits/input guard, preserving Task 2 checkpoint semantics and combat rules.
- Add `tests/verify_durable_run_continue.gd` and a fresh-process driver/helper under tests. Extend actual CI bindings, human-facing flow owner, current state/Active Context, scoped approval and report.

**Important untouched consumer**
Route shell `_ensure_combat_view` currently reapplies run resources even after super returns an existing board. Restore only after initial new-view setup, and prevent later ensure calls from resetting already restored live resources. Do not rewrite initialization globally or alter existing resource-carry semantics.

`BimuConstraintPanel._submit()` directly mutates run constraints; route it through a narrow shell transaction callback when configured, preserving standalone behavior without a coordinator. `selection_changed` is also emitted by configure/refresh/invalid proposals and is not a mutation-only autosave event. Do not create new writes from rendering or restoring the selection. Initialize continuation only after the complete Completion -> Route -> Result -> Base shell `_ready` chain has built its containers. Guard same-screen route signals and direct route/result renders, and reapply visual input blocking after render because `_set_content` and rebuilt buttons otherwise re-enable input. Retry/end must not discard the previous board before the pending durable transition is safely staged. Keep the existing script-entry storage isolation boundary independent of headless/visible rendering.

**Steps**
- [ ] Prospective RED: title Continue presence, complete restored shell scene, route effect applied once, pending/confirmed reward once, defeat/retry state once, completion persists, unsupported/corrupt feedback, input blocked on save failure and Retry actually recovers. Default test scripts must not touch user:// production save.
- [ ] Connect new run, starter selection, briefing constraints, combat entry, route selection+advance, growth, result pending/confirmation, retry, completion/retirement to one durable coordinator. Save complete transaction snapshots, not replayed commands. If write fails, freeze further irreversible input and retry the same pending DTO until acknowledged; no silently unsaved continuation.
- [ ] Suppress/queue screen_changed render and nested board checkpoint callbacks during transaction and restore; after complete DTO validation/write acknowledgment, publish/render once. Test BRIEFING -> COMBAT IO failure, FAILURE_RETRY -> COMBAT IO failure, restore signal reentrancy, and terminal-ready-before-deferred-confirmed crash. Reuse a small transaction guard, not a new shell framework.
- [ ] Build title buttons/confirmation/recovery notice using existing style/art. Retain valid save until the player confirms replacement. If invalid/incompatible data requires a fresh run, preserve source evidence to a bounded diagnostic file first and report failure if preservation fails. Do not delete user save evidence. Continue reads validated payload once and initializes actual subclass chain before enabling input.
- [ ] Lifecycle focus/pause/close flush last stable DTO and stop presentation/commit; resume restores UI/input order. Keep explicit pause separate from active combat calculation. Signals and default SceneTree timers keep running despite paused nodes: make the board movement delay pause-aware and guard frame/deferred continuation so phase/resource/receipt counters cannot advance while suspended. Recovery UI must remain usable. No background simulation or Android completion claims.
- [ ] Fresh process terminate/relaunch tests for PLANNING/COMMITTED/RESOLVED/route-pending/RESULT/retry/completion, using isolated dirs and real process exits. Compare interrupted/uninterrupted receipts and resources; do not inject terminal results into the full campaign path.
- [ ] Run whole pytest and native ordinary-default 10-duel flow with production persistence explicitly configured to a temporary path. Expect 10 wins, 10 rewards, 36 node advances; use actual activation count. Fresh-launch Continue should restore actual checkpoint. Fault tests cover truncated primary -> backup, both corrupt, future schema, failed replacement, and no effect replay on repeated reopen.
- [ ] Update human-facing owner with short readable save/continue rules (no AI-only IDs in Blueprint-facing prose); keep approved historical PDF bytes unchanged. Update current routing/status with bounded implementation evidence, not whole-Blueprint completion. Record five actual full-scope review loops across preflight/task reviews/controller/final review, plus exact commands and NOT_RUN. Commit only owned files.

## Task 4: Remove measured repeated save validation without weakening recovery

**Files / responsibility**
- Modify `src/run/run_save_store.gd` only for raw-byte validated memoization, exact expected-payload readback and safe idempotency ordering. Leave domain codecs, schema, content identity and game rules unchanged unless a prospective regression demonstrates a necessary transport validation fix.
- Add `tests/verify_run_save_cache.gd`, extend the actual native CI runner and existing `tests/test_durable_save_contract.py` binding/focused execution. Extend the execution report with exact before/after workload and fault evidence. Existing package approval already owns the store path; add no speculative protected paths.
- Read Task3 report/current store consumers first; only one implementer may mutate product code. Do not edit shell/coordinator for caching.

**Measured problem / preflight**
Controller profiled the actual configured first-duel PLANNING checkpoint on reviewed a14ccea5 store/domain bytes: repeated changed checkpoint IDs take592–609ms, nine decodes/ten full domain validations per save; domain-inclusive535–553ms. First write376–382ms, idempotent172–178ms. This is a measured function-time stall, not FPS or a whole-game performance verdict. Task3 supplies later-run integrated measurements. The existing ten-game save/recovery benchmark still covers this exact decision dimension; current official Godot performance guidance and independent raw-byte/primary-status preflight extend feasibility, without copying unrelated game mechanics.

**Contract**
- Keep a per-RunSaveStore cache of at most3 successful validated entries, aggregate cached source UTF-8 bytes at most CODEC.MAX_BYTES. Deterministic eviction, no static/global cache, no invalid/incompatible/error-result cache. Cache owns copies of raw PackedByteArray, content context and validated normalized payload; every return owns a deep copy.
- Always execute actual filesystem existence/directory/io_guard/open/length/full read/error checks before lookup. Compare exact raw bytes, never decoded String, timestamp, file size or digest alone. A changed byte must miss and undergo full validation. Reject non-roundtrippable UTF-8 bytes as CORRUPT before accepting a decoded JSON payload; different invalid bytes must not alias a legitimate U+FFFD string. Do not treat expected malformed-input diagnostics as clean normal-runtime output.
- Bind entries to the codec's schema/semantic version/computed content identity context. Do not silently broaden current content identity or introduce catalog hot-reload semantics. A new/different context cannot reuse prior validation.
- Seed cache only after a fully successful codec.encode or full decode. Own copies before returning exposed encoded/loaded values. In `_write_slot`, use an already validated expected payload rather than decoding the in-memory text again; still perform real temporary-file readback and exact comparison before rename, and actual destination readback after rename.
- Early idempotency is allowed only with no pending operation, freshly validated physical primary provenance, same generation/checkpoint/active flag and exact normalized full run+combat equality. An active run exposes VALID_PRIMARY; a valid primary tombstone deliberately exposes ABSENT, so preserve its existing repeated-retirement idempotency using actual primary proof rather than a status-string-only guard. Do not acknowledge RECOVERED_BACKUP or backup-only tombstone as repaired without writing/validating primary. Replacement/retirement still require both freshly read slots to agree before acknowledgment. Do not skip failure-preservation checks, change pending identity/revision, or replay a gameplay command on retry.
- No worker threads, new libraries, weaker validation, wider schema acceptance, UI hiding delays, or asset change. If removing redundant work still leaves material stalls, report measured next bottleneck; do not invent an acceptable-performance claim.

**Steps**
- [ ] Prospective executable RED using an instrumented codec to prove duplicate full-domain calls plus recovery/cache requirements before implementation. No parser-error-only RED.
- [ ] Add exact raw-byte change/invalid UTF-8, same-length content edit, read guard failure, deleted/directory slot, deep-copy input/output isolation, context separation, deterministic cache count/byte eviction, invalid/future/incompatible non-caching, changed payload at same checkpoint, recovered-backup primary repair, failed repair, pending immutable retry and both-slot generation/retirement regressions.
- [ ] Implement minimal bounded store optimization, GREEN focused cache and full existing store/combat/Continue fresh-process fault suites. Tests must inspect actual file operations; a fake successful store is insufficient.
- [ ] Repeat controller workload with cold and warm samples separately and measure representative later-run integrated checkpoints. Compare identical input/source conditions; report measured timings and method, not guessed FPS or platform-wide claims. Wall-time thresholds must not become flaky CI assertions: count exact avoided domain work deterministically instead.
- [ ] Run full pytest once, native persisted ordinary campaign regression when integrated changed consumers warrant it, relevant operating/approval checks, record real self-review and exact commands, commit only owned files. Independent task review and whole-branch review remain controller gates.

## Task 5: Correct actor-owned martial effects before first save publication

**Spec:** `docs/decisions/2026-09-09_MARTIAL_ACTOR_BINDING_CORRECTION.md`.
**Research:** `docs/operations/2026-09-09_MARTIAL_ACTOR_BINDING_RESEARCH.md`.
This is one coupled execution/restore correction, not growth implementation. Begin only after Task4 review is complete. Capture old semantic fixture before changing product code.

**Files / responsibility**
- Modify `src/combat/combat_resolution_engine.gd`: small virtual actor-definition lookup preserving base/basic/generic behavior; route existing fallback lookup through it.
- Modify `src/combat/combat_resolution_engine_prepare.gd`: player/enemy attempt reconstruction uses actor lookup, without duplicating prepare resolution or changing its state lifetime.
- Modify `src/combat/combat_resolution_engine_ten_manuals.gd`: separate effective actor maps, actor lookup override, canonical player construction and enemy/AI/direct/pipeline consumers; preserve legacy union discovery and clear all old derived entries on reconfiguration.
- Modify `src/combat/martial_effect_pipeline.gd`: explicit authored-stat mapping and pre-execution validation; no new numerical rules.
- Modify `src/run/vertical_slice_metrics_combat_resolution_engine.gd`: Bimu action lock uses player definition, and rejected plan returns unchanged before metrics accumulation.
- Modify `src/run/combat_checkpoint_codec.gd`, `src/run/vertical_slice_combat_bridge.gd`: strict player canonical definition and enemy lock use actor map. Existing saved definitions are not sanitized.
- Modify `src/run/run_checkpoint_codec.gd`: exact semantic string only, no DTO field or validation weakening. Store Task4 cache stays unchanged unless a new regression demonstrates a direct context bug.
- Add `tests/verify_martial_actor_binding.gd`; extend `tests/verify_martial_effect_pipeline.gd`, `tests/verify_combat_checkpoint_resume.gd`, fresh-process driver `tests/test_durable_save_contract.py` and helper `tests/durable_continue_process.gd`. Add `tests/fixtures/pre_publication_save_v1_actor_shared.json` plus provenance note. Existing unrelated fixtures remain protected.
- Correct directly exposed validation fixtures only: `tests/verify_bimu_constraint_runtime.gd` explicitly starts a fresh lock lifetime before its separate reconfiguration scenario; `src/validation/ten_manual_product_scenario_validator.gd` supplies canonical English keys in each actor.stats instead of ignored context.stats and rejects INVALID_STAT_REFERENCE as structural failure. Preserve authored values and the scenario validator's structural-only evidence ceiling.
- Unequal-player-mastery fresh-process scenarios use the actual dock and strict CombatCheckpointCodec persisted DTO in independent processes. Full run envelopes still enforce legal starter mastery3; do not fabricate progression or weaken run validation to fit a standalone combat test. Report these distinct evidence scopes alongside actual full-shell continuation and campaign tests.
- Bind new native verifier in `.github/workflows/validate-ten-manual-product-gate.yml` (path trigger and actual Godot step), beside the existing save/cache verifier. Do not add a duplicate CI framework.
- Update `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json` and `docs/implementation/BUILD_APPROVAL_2026-09-08.md` with only actual additional protected paths; regenerate adopted operating artifacts using current project tool. Update execution report, current operating state/Active Context, related mastery/architecture/test/roadmap status with this bounded correction. Preserve historical factual evidence and approved PDF/image bytes.

**Interfaces / required behavior**
Base engine introduces virtual owned-copy APIs; TenManual overrides for actor maps:

```gdscript
func get_actor_card_definition(card_id: String, actor_key: String) -> Dictionary:
    if actor_key not in ["player", "enemy"]:
        return {}
    return (cards_by_id.get(card_id, {}) as Dictionary).duplicate(true)

func get_actor_cards_by_id(actor_key: String) -> Dictionary:
    if actor_key not in ["player", "enemy"]:
        return {}
    return cards_by_id.duplicate(true)
```

TenManual owns `_player_martial_cards` and `_enemy_martial_cards`, each from `_build_normalized_loadout_cards`. Its override looks up own martial ID; a martial ID known only to the other actor returns empty. Non-martial definitions delegate to base. Aggregate lookup copies non-martial cards plus the selected actor's effective map. `get_enemy_ai_cards_by_id()` delegates to enemy aggregate; shared `cards_by_id` is discovery-only union with player precedence on overlap. IDs/`get_loaded_*` sets remain stable. External mutation of returned maps cannot affect engine/registry/other actor. Reconfigure removes all prior martial union entries and both maps, but preserves basic/generic cards.

Route base fallback construction and preparation reconstruction through virtual actor lookup. For real martial player placements, use current player effective definition before span/cost/execute (preserve intent, anchor, direction, target and reservations). Existing inline test-only non-martial supplied definitions remain supported. Reject unavailable actor martial IDs instead of using the opposite side. Direct martial pipeline lookup uses actor API. Never implement a second per-actor rules engine.

Apply canonical martial lookup even when an incoming placement already contains `definition`: both player construction and prepare `_placement_attempts` must agree. Recognize IDs from registry/actor maps, never trust `source` metadata. In TenManual `preview_player_plan` and `resolve_bundle`, preflight every martial placement before delegating to existing resolution: unavailable actor ID or disagreeing placement.card_id/definition.id rejects the whole plan with `MARTIAL_ACTOR_DEFINITION_MISMATCH`, unchanged input/output state and enemy lock, no costs/effects/metrics, valid=false (and rejected=true for resolve). Do not silently skip bad actions. Domain execution owns canonical definitions by ID; exact UI-decorated producer validation remains in the bridge (no UI adapter import into engine). Existing non-martial inline fixtures retain their current behavior. The metrics subclass checks rejection before accumulation; Bimu lock lookup uses the player actor API.

Both configure APIs now return bool. Build candidate effective maps first. With a nonempty enemy lock, equal current effective maps are true/no-op; different maps return false before clearing or replacing anything. With no lock, replace maps/union as usual. Never clear a revealed lock during reconfigure. Existing fresh-engine make_initial_state and codec construction order are preserved; check bool at actual bridge/codec configuration boundaries. Regression: lock→changed mastery configure rejected/maps and lock byte-equivalent; same binding succeeds/no reroll; fresh engine configuration still succeeds.

Stat boundary:

```gdscript
const STAT_KEYS := {
    "외공": "external", "근골": "constitution", "신법": "agility",
    "내공": "internal_power", "심안": "insight",
    "external": "external", "constitution": "constitution", "agility": "agility",
    "internal_power": "internal_power", "insight": "insight"
}
```

Preflight all SPECIAL_CLASH steps before the effect loop. If stat nonempty: require String reference in STAT_KEYS, Dictionary actor.stats, canonical-key presence and finite int/float value (not bool/String). Require finite int/float coefficient. If reference empty, only numeric coefficient0 is legal. Invalid program returns `_failure(original_state, [], "INVALID_STAT_REFERENCE")`. Valid `_execute_clash` reads the mapped key and preserves fixed power + floor(stat×coefficient), event structure and conditions. Update old Korean-only direct-pipeline actor fixture to canonical engine keys; no Korean shadow keys in product state.

**Steps / executable checks**
- [ ] Read the spec, research, actual engine/prepare/bridge/codec/test consumers and Task4 report. Run operating validator. Record exact BASE. Preserve a real old-codec envelope from an isolated configured first-duel fixture and record source SHA, old semantic string, fixture SHA and generation command. Never read production user:// for this fixture.
- [ ] Create `verify_martial_actor_binding.gd` with dynamic method checks so missing APIs cause behavioral assertions, not parse-only failure. Add the following direct regression against current public APIs before implementation:

```gdscript
var engine = preload("res://src/combat/combat_resolution_engine_ten_manuals.gd").new()
var manual := "shaolin_arhat_vajra_art"
engine.configure_martial_loadouts([manual], {manual: 3}, [manual], {manual: 7})
var state := engine.make_initial_state({"player": {"health": [30,30], "stamina": [5,5], "internal": [4,4]}, "enemy": {"health": [30,30], "stamina": [5,5], "internal": [4,4]}}, 4, 6)
state.player.internal = [0, 4]
state.enemy.internal = [0, 4]
var result: Dictionary = engine.resolve_martial_card(manual + "_star3", state, "player", {"full_absorb": true})
_assert(result.state.player.internal[0] == 0, "player3 must not receive enemy7 star5 recovery")
engine.configure_martial_loadouts([manual], {manual: 5}, [manual], {manual: 3})
result = engine.resolve_martial_card(manual + "_star3", state, "player", {"full_absorb": true})
_assert(result.state.player.internal[0] == 1, "player5 must retain own star5 recovery")
```

- [ ] Add mirrored enemy calls, player7/enemy9 and player9/enemy7 overlay comparisons to registry, missing/foreign actor ID, deep-copy mutation and reconfigure cleanup. Assert whole-plan preview/resolve rejection (including spoofed source and disagreeing IDs) preserves state/lock/metrics, and lock-preserving reconfiguration boundaries above. Add exact definition equality between native UI-adapter-decorated placement export, actor canonical map and strict saved player plan; enemy lock must match enemy mastery. Run native tests and record numeric/effect assertion RED.
- [ ] Extend pipeline test with actual canonical state and `SPECIAL_CLASH {power:8,stat:"내공",coefficient:1.0}`. At internal_power4 expect event.power12. Table-test all five aliases/English references with nonuniform values and1/4/15 boundaries, fractional coefficient0.25 floor, fixed-only0, unknown name, absent canonical stat, String/bool/nonfinite coefficient/value. Prepend defense gain to invalid programs and assert both input/output unchanged and no applied events; conditional invalid step must still reject. Record RED before code changes.
- [ ] Implement the small lookup API, two effective maps and consumer routing described above. Implement stat preflight/mapping; do not change data JSON numeric values. Run new actor verifier plus existing registry/UI-AI/pipeline/prepare/resolution suites to GREEN. A newly revealed unrelated combat defect is reported to controller, not silently expanded into a rewrite.
- [ ] Change semantic string to `ten-duel-four-route-one-retry-bimu-actor-bound-save-v1`. Update strict bridge/codecs to actor lookup, preserving exact comparison. Use pre-change fixture in injected directory: old identity→INCOMPATIBLE and same bytes after repeated open; no automatic migration. Context-cache tests must still pass.
- [ ] Extend fresh-process committed fixtures with shared manual at unequal mastery (both orientations) and actual dock placement. Restored and uninterrupted final state, effect events, enemy lock, resources, reservation count and receipt count must match. Persisted RESOLVED must not invoke resolver. Tampered same-ID opposite-mastery definition must be rejected with no live mutation; legitimate UI-only metadata projection must be accepted through the exact producer adapter.
- [ ] Execute focused native/Python save suites, whole pytest, and ordinary persisted10-duel native campaign with actual inputs/default resolver: record actual wins/rewards/36routes/input count and checkpoint timings, no injected victories. CI includes new verifier. No hard wall-time assertion or fabricated performance claim.
- [ ] Update exact protected-path approval, regenerate/validate adopted artifacts, append report with commands, outputs, RED/GREEN, source/semantic fixture hash and limitations. Reconcile current routing/roadmap/test/mastery/architecture owners with implemented status only after evidence. Self-review actual diff plus untouched costs/AI/lock/prepare consumers, commit owned paths only. Return short report contract; no push, merge or subagents.

Commands use the verified local executable `C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe` with `--headless --path . --script res://tests/verify_martial_actor_binding.gd`, analogous affected verifier paths, and `python -m pytest -q`. Fresh import only if needed. Controller owns final whole-branch review, visible capture, CI and protected delivery.

## Controller delivery and self-review

Task interfaces are sequential: codec/store -> deterministic combat DTO -> shell/lifecycle -> measured store optimization -> pre-publication actor/stat semantic correction. Shared codec/report/approval/CI files are edited by only one implementer at a time. All five must finish before initial save publication; Task5 runs only after Task4's independent review. The added correction is covered by its named successor spec and fresh ten-case research, not silently treated as save-neutral.

Controller conducts an independent full-scope preflight, each task spec+quality review, controller executable/capture review and final full-branch review. Each loop covers current authority, actual changes, untouched consumers, validation evidence, cost and maintainability. Five is a minimum, not five invented findings. Complete related current-state correction, exact-head CI, normal protected PR merge and detached-main readback. Existing PR332 is already merged as base. One-time product approval is closed out only after merged verification, with exact original bytes archived.

User-visible examples: reopening during a combat animation resumes its settled result; reopening after selecting rest does not heal twice; confirmation of a result never grants its training reward twice. These must be tested, not inferred from screenshots.
