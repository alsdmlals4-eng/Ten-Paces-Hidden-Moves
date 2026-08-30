# Machine runtime readback — human-player comparison deferred

```yaml
report_id: TEN-OPS-20260830-MACHINE-RUNTIME-READBACK-01
work_mode: REVIEW
baseline_main: a49115a948bea9a875450b36ae88ab012892ea88
scope: current-main Godot machine readback, deterministic balance-report readback, and explicit human-player deferral
user_direction: "진행해 사람 플레이대조는 나중에하자"
current_source_relevance_check: NOT_APPLICABLE
feasibility: FEASIBLE
result: PARTIAL
```

## 작업 전 문제

The current planning status still named a combined human-player and Windows-visible balance review as the next surface. The user explicitly deferred the human-player comparison. The state needed to keep the numerical-decision block while allowing machine-only evidence to continue.

## 범위와 채택

- No combat number, combat-rule, AI, scene, asset, or save-schema change was authorized or made.
- `current_user_planning_status.json` and `ACTIVE_CONTEXT.md` now name machine-only runtime evidence as the active surface and retain the block on a separate numerical decision.
- Human player, Windows usability, Android device, accessibility-user, and release-performance evidence remain separate and unpromoted.
- **CURRENT_SOURCE_RELEVANCE_CHECK: NOT_APPLICABLE.** This was a local current-main runtime observation and state readback. No external technical, market, rights, or design evidence could change the result.

## Current-main machine evidence

| Claim | Evidence | Result |
|---|---|---|
| Exact project identity | HERA instance PID `26836`, exact isolated worktree path, Godot `4.7.1.stable.official.a13da4feb` | PASS |
| Godot bootstrap | `--headless --editor --path <exact worktree> --quit` completed initial import and class scan | PASS |
| Focused runtime contracts | balance instrumentation, public policies, report runner, diagonal pair/assets, per-timing action reveal, combat bridge, opponent binding, briefing, and phase-2 resolution | 10 PASS |
| Current balance readback | Generated `6750`-row schema-3 report and ran `tests/check_vertical_slice_balance_report.py` | PASS |
| Current report identity | SHA-256 `A0669A0727C9608B6A240910CE529263C1982C510E4B3C376BD58D8AB5F66558`, matching the canonical result-review report | PASS |
| Visible combat readback | Start → setup → `비무 1 · 도겸` combat reached through the exact live editor; runtime screenshot nonblank, no possible clipping | PASS |
| Runtime diagnostics | `error_count: 0`, `warning_count: 0` at screenshot observation | PASS |

The live combat screenshot showed the non-overlapping lower action dock, asymmetric diagonal combatants, current distance, the `3수 → 3수 → 4수` plan timeline, and basic/martial/ultimate action tabs. The automated sequence had already resolved an opening movement, so the live screen correctly displayed `거리 1`; this is not evidence that the opening-distance-2 contract changed.

## Adversarial review and clean exit

1. **Exact-source review:** rejected the stale root worktree and used `origin/main` SHA `a49115a...` in a clean isolated worktree.
2. **Session-identity review:** rejected four live Hera sessions owned by other projects; accepted only the instance whose project path matched the exact Ten Paces worktree.
3. **State interpretation review:** a live assertion expecting distance 2 failed because the automated action sequence had already moved to distance 1. The visual state and action timeline were read instead of treating the historical opening distance as a frame-invariant.
4. **Cache-delta review:** Godot generated only `.import` cache artifacts in the disposable worktree. No source, runtime data, scene, asset, or user root-worktree file was promoted or committed.
5. **Evidence-ceiling review:** a current single generated report matched the canonical SHA, but this readback did not independently recreate a fresh two-file byte-identical pair. Human/player/usability/device/accessibility/release claims remain `NOT_RUN`.

`CLEAN_REVIEW_EXIT`: no source defect identified inside the machine-readback scope; no numerical mutation recommended.

## Remaining risks and next safe work

- Human-player comparison is **deferred by the user**, not passed or cancelled permanently.
- This report does not establish human fun, readability, balance judgment, Windows usability, Android device quality, accessibility-user usability, or release performance.
- A separate numerical change remains blocked until a future approved evidence package justifies one.
- The machine runner produced a valid current report but the local process-management observation did not preserve a new independent two-file byte-pair; that stronger repetition remains optional machine follow-up, not a reason to mutate numbers.
