# Task 2 report — measured action-dock invalidation

- Status: implementation and local evidence complete; controller review/capture/integration remain.
- Baseline: `ea86c8fe88743d7fa0029bbaefdbc48776ec27f7` on `codex/single-execute-blueprint-20260908`.
- Product change: `src/ui/action_selection/action_selection_dock.gd` now owns normalized loadout/mastery copies and rebuilds manual/ultimate view models only for first explicit context or genuine input change. All dynamic context paths remain outside the guard.
- TDD: focused regression failed before production implementation, then passed with initial-empty, identical-input, caller-mutation, mastery/loadout change, preview/constraint/momentum/reservation assertions.
- Measurement: before `539854 / 563441 / 561096 µs`; final after `1375 / 1166 / 1172 µs` (prior after run `1181 / 1157 / 1154 µs`) for three warmed synchronous headless samples of 100 identical updates. No FPS/device/Human claim.
- Focused/adjacent Godot: action dock, martial panel, action-selection integration, bimu constraint UI/runtime, ultimate UI PASS; known ultimate ObjectDB warning remains.
- Full Python: `474 passed in 17.73s`.
- Operating/protected-path regression: project operating system PASS; 9/9 selected contract tests PASS.
- Durable evidence: `docs/operations/2026-09-08_SINGLE_EXECUTE_BLUEPRINT_EXECUTION_REPORT.md` optimization section. Approval and same-date BUILD records append the exact product path without replacing Task 1 scope.
- Evidence ceiling: physical/Human/accessibility-user/Android/release and controller independent replay/CI/merge/readback remain `NOT_RUN`.
