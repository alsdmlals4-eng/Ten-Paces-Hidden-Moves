# Durable save and Continue execution evidence

Status: LOCAL_MACHINE_VERIFIED / CONTROLLER_REVIEW_PENDING. Final whole Python suite: 487 passed in391.40s. Not merged; Human, Android physical lifecycle, accessibility users, release performance and whole Blueprint completion NOT_RUN.

## Before / research / implementation

The baseline had an in-memory campaign but no real Continue. Reviewed Tasks 1–2 supplied explicit strict run/storage and combat checkpoint APIs. Task 3 baseline: `a14ccea575bf706b1d07d268eafabe3ef83e2624`; branch `codex/durable-save-continue-20260908`; source main `27f7d922e8ec36e038c6dc943b069161b8b53536`. Protected approval baseline remains intentionally distinct at `bf161025b63edd7eb441b2c4f2ae9da5155f68da`.

CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE. The same approved decision dimension, ten-game comparison, current Godot lifecycle references and practical ownership analysis in [research](2026-09-08_DURABLE_SAVE_RESEARCH_AND_FEASIBILITY.md) remain applicable. FEASIBLE on exact Godot 4.7.1 `a13da4feb`. No new rules, paid service, cloud, engine, art or dependency was needed. Existing title art/styles are reused; preserved historical PDFs are not regenerated.

`RunSessionCoordinator` owns the small transaction/restore guard, immutable pending DTO, last acknowledged durable payload and store errors. Domain models continue to calculate route, reward, retries and battle. The most-derived shell initializes before a validated Continue is consumed. A retry stages a new board while retaining the previous board until disk acknowledgment. Existing route ensure calls apply carried resources only to a new board. Constraint submission uses a narrow optional callback; configure/refresh signals never save. Terminal ready and REVIEW-to-RESULT/failure advancement are one transaction; deferred confirmation is ignored once that boundary was handled.

Lifecycle flushes the last stable payload, keeps explicit pause separate from application suspension, pauses the combat host and guards frame/timer continuation. Recovery controls process while paused; gameplay commands reject while busy, suspended or blocked. Script entry defaults persistence OFF independently of headless/visible rendering; only an explicit unique test directory enables it. Normal project entry enables the local store. The title confirms replacement, shows backup/incompatible/corrupt/read-failure feedback and can reread a temporarily inaccessible location. Source evidence must be preserved before a corrupt/incompatible replacement is acknowledged.

Examples: reopening during a settled battle resumes its result; reopening a selected rest does not heal again; pending/confirmed rewards do not grant twice. Completion remains a durable summary, and ending a failed run writes an inactive generation to both slots.

## Evidence and corrections

- Prospective initial native RED, exit1: `actual shell must expose isolated durable storage`; `title must offer validated Continue`. Initial integrated GREEN, exit0: `DURABLE_CONTINUE PASS`.
- Real native-button RED found `Combat state or timing context malformed`: ProgressButton includes UI flags absent from the strict five-field timing domain. The bridge now explicitly exports those five timing fields; UI request flags remain at their consumer.
- Next real-button RED found `Committed plan malformed`: dock view models add/replace presentation metadata. The bridge accepts only an exact current engine definition or exact current unlocked/owned UI-adapter definition, then exports the engine definition while retaining placement/target/span/reservation facts. Modified gameplay definitions are rejected. The file codec stays strict.
- Final publication audit produced three additional prospective RED failures: an unacknowledged briefing combat was visible; a failed retry hid the previous board instead of the candidate; a direct completion-subclass render published an unacknowledged completion. Guards now retain the published surface, keep the staged board hidden, and publish only after acknowledgment. The first two focused regressions returned `DURABLE_CONTINUE PASS`; completion fault/retry is included in the final fresh-process matrix.
- Focused lifecycle/transaction verifier passes BRIEFING-to-COMBAT IO failure/retry, FAILURE_RETRY-to-COMBAT failure/retained board, once-only attempt, paused frame/movement and resolution state/phase/resource/counters, once-only terminal/reward, selected-rest reopen, same-screen route advance, corrupt/incompatible/backup UI and failed evidence-preservation replacement/retry. Title and recovery notices fit explicit logical viewports 960×640, 1280×720/800 and 1920×1080. This is automated layout evidence, not a human visual verdict.
- Two ordinary-default persisted native campaigns passed: both 10 wins, 10 rewards, 36 route advances, 299 actual UI activations; elapsed 293055ms and 299183ms. Actual public policy/resolver path uses basic guard/heavy/move/palm/meditate, base ultimates, Hua3, Shaolin7 and Yang7. No terminal injection in these campaigns. Every battle checks carried resources.
  These campaign measurements preceded the final failed-publication guards; the final whole-suite matrix covers those guards, and controller exact-candidate runtime review remains separate.
- Process helper separately labels synthetic module fixtures for route/result/retry/completion and terminal initial HP. Committed/resolved actual dock basic/martial/ultimate processes exit at acknowledged checkpoints, then fresh shell instances restore against an uninterrupted baseline. Second reopening checks no effect replay. Terminal-ready failure leaves a durable RESOLVED checkpoint for fresh-process completion. Final exact test result is recorded below after completion.
- Test-only corrections: route options use `id` and the first interval offers rest only from the third node; asynchronous inherited start must wait for the actual settled state; normalized JSON digest compares integer/float transport; a second Continue after a settled PLANNING boundary has no historical resolved-summary payload. These were fixture defects, not weakened domain assertions.

## Reproduction / final validation

All commands run from this isolated worktree with `C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe`.

```text
godot --headless --path . --script res://tests/verify_durable_run_continue.gd
godot --headless --path . -s res://tests/verify_save_entry_isolation.gd
python -m pytest tests/test_durable_save_contract.py -q
godot --headless --path . --script res://tests/probe_native_ten_duel_campaign.gd -- --run-save-dir=user://durable_native_task3_20260909_final
python tools/check_project_operating_system.py --root .
python tools/check_one_time_protected_change_lifecycle.py --project-root . --base-sha 27f7d922e8ec36e038c6dc943b069161b8b53536
python -m pytest -q
```

Native continuation and `-s` isolation exit0; operating-system and approval lifecycle PASS. Focused fresh-process matrix plus both script-entry forms: `2 passed, 4 deselected in 280.84s` (17 phases, 51 distinct processes). First full suite: `3 failed, 484 passed in 370.33s`, with all six durable tests passing; three stale static current-state/lock assertions were corrected. Owner formatting and roadmap linkage corrections then passed all 481 non-durable tests in17.62s. Final full rerun after all publication guards: **487 passed in391.40s**, exit0, including completion-failure retry and two fresh reopens. CI includes native continuation and isolated persisted campaign; Python suite executes fresh-process and both script-entry forms.

The broad protected checker is `BLOCKED_UNVERIFIED` in this imported dirty workspace because three generated background `.import` and seven generated `.gd.uid` files are counted in addition to the exact 16 approved real product paths (latest check after editor import). All generated sidecars are preserved and excluded from commits; the approval is not broadened to generated churn. Controller must validate the clean checked-out candidate for delivery.

## Cost / full-scope review / learning

Final ordinary campaign sampled 237 actual integrated writes: min319ms, mean692.33ms, max1144ms, aggregate164082ms; last50 mean731.78ms. These synchronous debug-machine timings include validation/IO, not Release FPS evidence. Controller independently measured repeated whole-domain validation dominating reused-store writes. No validation was removed or speculative cache added in Task 3. Controller owns a sequential bounded optimization follow-up.

The complete package review lineage includes controller preflight, Task1 implementation/store review, Task2 deterministic combat review and ownership correction, and Task3 integration self-review of all changed/untouched consumers. Task1 and Task2 local reports each record five real complete candidate loops; these do not substitute for independent final integration review. Task3 controller executable/capture review and final whole-branch review remain pending. No invented final five-loop clean exit is claimed here. Latest project five-loop requirement prevails over newer shared two-loop drift; adoption pin is unchanged.

Self-review considered authority/spec, actual changes, untouched screen hierarchy/route ensure/callbacks/AI/ultimate/reward consumers, failure and rollback evidence, storage cost and maintenance together. The accepted architecture keeps domain owners and one coordinator; save-on-every-signal, command replay and whole animated Node serialization were rejected. The actual UI request/view-model mismatches became regression fixtures. No unverified project lesson is promoted to Base policy; reusable candidate: verify persistence with real UI producers as well as domain fixtures, normalize presentation transport at the producer, and keep an immutable acknowledged boundary across pause and IO failure.

Remaining: independent controller review/capture; measured storage-latency correction; clean-candidate protected checker/exact-head CI/protected merge/main readback; Human/Android/accessibility/release gates. Preserved PDFs remain historical reader artifacts; the human-facing flow owner now explains current save/continue rules without regenerating them.
