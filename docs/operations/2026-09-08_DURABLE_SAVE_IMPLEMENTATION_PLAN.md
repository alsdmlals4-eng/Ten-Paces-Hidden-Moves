# Durable save and continue implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. The current user authorizes continuous implementation and normal protected integration; no routine execution-choice question.

**Goal:** Persist the actual ten-duel run and deterministic combat boundaries and connect safe Continue/recovery to the existing game.
**Spec:** `docs/decisions/2026-09-08_DURABLE_RUN_CONTINUE.md`.
**Architecture:** Explicit run codec, validated local store, combat checkpoint producer and one shell session coordinator. Existing resolver/run/progression remain rule owners. No generic Node serialization.
**Tech Stack:** Godot 4.7.1/GDScript, FileAccess/DirAccess/JSON/HashingContext, current native SceneTree and Python contracts.
**Base:** `27f7d922e8ec36e038c6dc943b069161b8b53536`.

## Global constraints

- Preserve all existing combat, AI public-information, scouting, reward, retry, manual loadout and 10-duel/36-route rules. No new assets, cloud, paid dependencies or engine changes.
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

## Controller delivery and self-review

Task interfaces are sequential: codec/store -> deterministic combat DTO -> shell/lifecycle -> measured store optimization. Shared codec/report/approval/CI files are edited by only one implementer at a time. Tasks cannot ship as disconnected completion; all four must finish before this save feature is described as implemented and its measured bottleneck corrected.

Controller conducts an independent full-scope preflight, each task spec+quality review, controller executable/capture review and final full-branch review. Each loop covers current authority, actual changes, untouched consumers, validation evidence, cost and maintainability. Five is a minimum, not five invented findings. Complete related current-state correction, exact-head CI, normal protected PR merge and detached-main readback. Existing PR332 is already merged as base. One-time product approval is closed out only after merged verification, with exact original bytes archived.

User-visible examples: reopening during a combat animation resumes its settled result; reopening after selecting rest does not heal twice; confirmation of a result never grants its training reward twice. These must be tested, not inferred from screenshots.
