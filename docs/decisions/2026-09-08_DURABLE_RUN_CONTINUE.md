# Durable run continuation — schema 1

Decision: TEN-DEC-20260908-DURABLE-RUN-CONTINUE-01
Status: SPECIFIED / BUILD_AUTHORIZED_BY_CURRENT_CONTINUOUS_IMPLEMENTATION_REQUEST; Human final NOT_RUN.
Parents: approved_20260806_windows_android_adapter_architecture_contract.json; current ten-duel campaign and one-free-retry owners. This supplies missing technical defaults under the user's approved implementation scope; it does not grant new retries or change game meaning.
Research: ../operations/2026-09-08_DURABLE_SAVE_RESEARCH_AND_FEASIBILITY.md.

## Player behavior

Title offers 새 여정 and 이어하기 when a validated active run exists. Continue shows the last durable position (duel and route/bundle), never an invented snapshot. Starting anew with an active run requires a clear replacement confirmation, which is a player interaction, not another development approval. No arbitrary quickload/save selection, reroll, cloud or additional retries. During a disk failure, block new irreversible gameplay commands and offer a retry with truthful Korean feedback; do not silently continue unsaved.

Save only stable logical boundaries, not every frame. Preserve run progress, pending effects/receipts and the committed battle. Restoring a resolved bundle applies the saved final result and continues without recalculating it. If a committed-but-unresolved bundle is the latest durable state, resolve its saved player plan against its saved enemy lock, never new player input. An uncommitted plan may be discarded on reopening to its last planning boundary; therefore its reserved momentum must NOT be taken from a later partially edited live state. Store a planning snapshot before placement/reservation edits, and clearly say the most recent confirmed progress is retained.

The game remains one core on Windows/Android. Pause/focus loss stops presentation and new commits and flushes the last stable checkpoint; resume restores UI before accepting commands. No background simulation. Android physical lifecycle is NOT_RUN until device testing.

## Storage contract

One active local run under user://, schema_version=1. Envelope includes save_id, written_at_utc, app_version, run_state, combat_checkpoint, integrity_hash, revision and content compatibility identity. Hash is corruption detection, not tamper/security protection. Unknown/future schemas or incompatible content fail closed, preserve original files and show a useful message. No fabricated migration from the old planning-only save sample. Test rejection and v1 roundtrip; future schema migrations need explicit fixtures.

The store owns only its narrowly named primary/temp/backup files. Read size/depth/node bounds; reject non-finite and unsupported JSON values. Validate the complete temporary file before replacement. Preserve at least one validated backup; never rotate a corrupt primary over a good backup. Inspect every write/flush/read/rename error. Keep the last acknowledged durable state on failure. Temp files are not blindly promoted. This is bounded tested fault recovery, not a universal power-loss guarantee.

New-run replacement/retirement must not allow recovery of a prior completed/abandoned run as active. Recommended minimal mechanism: write the new-generation initial checkpoint (or inactive tombstone) to both validated slots before acknowledging replacement, with backup-first then primary; if interrupted before acknowledgment, returning to the old valid primary is permitted. Do not silently load an old generation when a readable incompatible primary says a newer generation/schema owns the slot. Preserve incompatible/corrupt evidence when a player explicitly chooses a fresh run; do not delete it.

## Data and responsibility

- Explicit run snapshot covers every mutable run field, progression, pending route/reward/intel/constraints, retry/prebattle state, attempt/counters, current/next opponent and histories. Do not serialize model objects. Validate into a temporary candidate before applying to live objects; permissive casts/clamps are insufficient for file input.
- Preserve current catalog IDs and numeric rules, 10 duels, four node choices between duels, resource carry, reward values and one free retry. Do not change the four starter/loadout versus all-owned progression semantics in this package.
- Combat checkpoint phases: PLANNING, BUNDLE_COMMITTED, BUNDLE_RESOLVED. Stable identity includes save/run, duel/attempt, round/bundle and phase. Serialize complete combat state, timing context, exact enemy lock/key and content binding. Integer-key placement maps use entry arrays if present. No Node/Tween/callback/presentation object serialization.
- PLANNING is captured after initialization or after the next-bundle advance/AI lock/observation update, before reversible plan edits. Restore that validated baseline; no duplicate observation consumption.
- COMMITTED includes the locked plan, pre-resolution state (including already reserved ultimate momentum), context and reservation bookkeeping necessary for resolution. No second reservation or reroll on restore.
- RESOLVED includes resolver final state and summary captured immediately after synchronous resolve and before any animation await. Restore through common finalize once; no stale intermediate HP, duplicate next-bundle effects or duplicate terminal receipts.
- Run route selection applies effects immediately; save that effect and pending receipt together. Route advance consumes pending without reapplying. Result pending reward and confirmed reward/history/screens must be transactional. Whole-state restoration is not replay of recorded effects.
- UI consumes domain facts; it does not calculate rewards/combat or turn unknown values into zero.

## Evidence required

Prospective behavioral RED -> GREEN, strict malformed-input rejection with no live mutation, primary corruption/backup and failed-write survival, no previous-generation resurrection after acknowledged replacement, future-schema preservation, and isolated test paths. Fresh-process restore for run/route/result/retry and battle planning/committed/resolved; restored versus uninterrupted resources, statuses, AI lock, observation, ultimate cost and final receipts must match. Continue/recovery native UI capture, full ordinary-input ten-duel regression, CI binding and exact-head protected delivery. Static, automated runtime, visible capture, Human, Android and release states remain distinct.

