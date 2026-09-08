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
- Add this package's scoped `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json` and append `docs/implementation/BUILD_APPROVAL_2026-09-08.md` against the base above, listing only actual protected paths. Do not modify the adoption pin or historical retired approval archives.

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
- Extend Task 1 codec to strict current combat DTO; add `tests/verify_combat_checkpoint_resume.gd`, bind actual CI runners and Python binding assertions. Extend approval/report only actual owned paths.

**Hooks / semantics**
- Emit/request BUNDLE_COMMITTED after `_committed_player_plan_snapshot` and `_committed_state_before` are complete in `_on_progress_requested`, before resolver. Persistence failure can synchronously veto resolution while keeping commitment frozen for retry.
- Capture BUNDLE_RESOLVED from resolver result.state plus real review summary immediately after synchronous `resolve_bundle`, before animation awaits. Keep an immutable last-stable DTO for lifecycle flush. Do not read the animated board state for disk flush.
- Capture PLANNING only after initial configuration or `_advance_to_next_bundle` has updated round/bundle, AI lock and observation. Snapshot baseline before any reversible plan placement/reservation. Unsaved partial plans are intentionally discarded on process restart, as the spec says.
- Restore a committed snapshot by importing exact state/context/plan/enemy lock, then resolving once. Restore a resolved snapshot by common finalize using authoritative final state/summary, without rerunning resolver or animations. Terminal receipt handoff remains exactly once and uses final resources.
- Internal REVIEW is not durable: terminal ready/confirmed are one coordinator transaction publishing only RESULT/FAILURE_RETRY. A crash between the two signals restores the prior durable RESOLVED checkpoint and completes once; a delayed callback sees the applied boundary and does nothing. Test both victory and defeat in that exact gap.
- Restore a planning snapshot without another observation reveal, reservation or AI redecision. Preserve full player/enemy statuses, modifiers, martial preparation, metrics, public history, observation state and existing AI seed. Do not connect run_seed or change current AI seed behavior.
- No runtime object serialization. Rebuild binding/loadout/model dependencies first; verify saved identity. Keep integer-key maps as entry arrays when serialized. Do not call ultimate reserve again on committed restore.

**Steps**
- [ ] Read Task 1 report/API, actual board/engine/bridge/timing and existing terminal/ultimate/observation regressions.
- [ ] Prospective native RED for planning, committed and resolved roundtrip, both nonterminal and terminal. Assert lock equality, resource/status/metrics equality, no double ultimate spend, no duplicate observation, one terminal receipt and no UI future-action disclosure. Add corrupt-state rejection cases.
- [ ] Implement checkpoint producer/export/import and explicit persistence veto/ack interface. Existing standalone board and tests with no coordinator must retain current behavior.
- [ ] GREEN focused plus existing inline, ultimate, AI public boundary, bridge/result regressions; full pytest once. Report exact tests and compile/native exit. Commit. Shell/title disk integration is next task, not claimed here.

## Task 3: Connect real Continue, lifecycle and transactional progression

**Files / responsibility**
- Add `src/run/run_session_coordinator.gd` for last durable DTO, store errors, stable run/combat transactions, continuation orchestration and test storage injection.
- Modify `src/run/vertical_slice_shell.gd`, `vertical_slice_shell_result_auto.gd`, `vertical_slice_shell_route_auto.gd`, `vertical_slice_shell_completion_auto.gd`, `src/ui/main_title_screen.gd` and existing main scene only if necessary.
- Add `tests/verify_durable_run_continue.gd` and a fresh-process driver/helper under tests. Extend actual CI bindings, human-facing flow owner, current state/Active Context, scoped approval and report.

**Important untouched consumer**
Route shell `_ensure_combat_view` currently reapplies run resources even after super returns an existing board. Restore only after initial new-view setup, and prevent later ensure calls from resetting already restored live resources. Do not rewrite initialization globally or alter existing resource-carry semantics.

**Steps**
- [ ] Prospective RED: title Continue presence, complete restored shell scene, route effect applied once, pending/confirmed reward once, defeat/retry state once, completion persists, unsupported/corrupt feedback, input blocked on save failure and Retry actually recovers. Default test scripts must not touch user:// production save.
- [ ] Connect new run, starter selection, briefing constraints, combat entry, route selection+advance, growth, result pending/confirmation, retry, completion/retirement to one durable coordinator. Save complete transaction snapshots, not replayed commands. If write fails, freeze further irreversible input and retry the same pending DTO until acknowledged; no silently unsaved continuation.
- [ ] Suppress/queue screen_changed render and nested board checkpoint callbacks during transaction and restore; after complete DTO validation/write acknowledgment, publish/render once. Test BRIEFING -> COMBAT IO failure, FAILURE_RETRY -> COMBAT IO failure, restore signal reentrancy, and terminal-ready-before-deferred-confirmed crash. Reuse a small transaction guard, not a new shell framework.
- [ ] Build title buttons/confirmation/recovery notice using existing style/art. Retain valid save until the player confirms replacement. If invalid/incompatible data requires a fresh run, preserve source evidence to a bounded diagnostic file first and report failure if preservation fails. Do not delete user save evidence. Continue reads validated payload once and initializes actual subclass chain before enabling input.
- [ ] Lifecycle focus/pause/close flush last stable DTO and stop presentation/commit; resume restores UI/input order. Keep explicit pause separate from active combat calculation. No background simulation or Android completion claims.
- [ ] Fresh process terminate/relaunch tests for PLANNING/COMMITTED/RESOLVED/route-pending/RESULT/retry/completion, using isolated dirs and real process exits. Compare interrupted/uninterrupted receipts and resources; do not inject terminal results into the full campaign path.
- [ ] Run whole pytest and native ordinary-default 10-duel flow with production persistence explicitly configured to a temporary path. Expect 10 wins, 10 rewards, 36 node advances; use actual activation count. Fresh-launch Continue should restore actual checkpoint. Fault tests cover truncated primary -> backup, both corrupt, future schema, failed replacement, and no effect replay on repeated reopen.
- [ ] Update human-facing owner with short readable save/continue rules (no AI-only IDs in Blueprint-facing prose); keep approved historical PDF bytes unchanged. Update current routing/status with bounded implementation evidence, not whole-Blueprint completion. Record five actual full-scope review loops across preflight/task reviews/controller/final review, plus exact commands and NOT_RUN. Commit only owned files.

## Controller delivery and self-review

Task interfaces are sequential: codec/store -> deterministic combat DTO -> shell/lifecycle. Shared codec/report/approval/CI files are edited by only one implementer at a time. Tasks cannot ship as disconnected completion; all three must finish before this save feature is described as implemented.

Controller conducts an independent full-scope preflight, each task spec+quality review, controller executable/capture review and final full-branch review. Each loop covers current authority, actual changes, untouched consumers, validation evidence, cost and maintainability. Five is a minimum, not five invented findings. Complete related current-state correction, exact-head CI, normal protected PR merge and detached-main readback. Existing PR332 is already merged as base. One-time product approval is closed out only after merged verification, with exact original bytes archived.

User-visible examples: reopening during a combat animation resumes its settled result; reopening after selecting rest does not heal twice; confirmation of a result never grants its training reward twice. These must be tested, not inferred from screenshots.
