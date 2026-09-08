# Task 4 local delivery preparation

Status: DONE_WITH_CONCERNS. No remote operations, editor changes, branch switches or subagents.
Canonical full report: `docs/operations/2026-09-08_BIMU_CONSTRAINT_RUNTIME_EXECUTION_REPORT.md`.
Baseline `65fb51e3`, protected baseline `81ef0f0b2ede9cd63d6a2aba521a645efc1d4e5f`.

Implemented current operating-state correction, historical PR65/92 distinction,
current Decision routes in both roadmaps, separate constraint_continuation in planning JSON,
model/runtime/UI product CI steps, exact unlock-ID regression, fresh exact 12-path protected
approval, canonical evidence/report, and only three fixed captures. Controller BUILD approval
and runtime plan additions were read and included. Existing import/UID/raw capture dirt preserved.

TDD RED: `python -m pytest tests/test_current_discovery_contract.py -q --tb=short`
after current-stage regression change, before owner correction: `1 failed, 18 passed`.
Expected failure: current stage still FIRST_FIVE despite already merged ten-duel implementation.
GREEN same command: `19 passed`; `python tools/check_postmerge_canon_lifecycle.py`:
`CANON_LIFECYCLE_OK`.

First full Python: `python -m pytest -q --tb=short`: `5 failed, 468 passed`.
Failures identified unchanged next-phase regression consumers, JSON canonical whitespace,
and current Decision missing from both roadmap consumers. Corrected owners and regressions
together; final `python -m pytest -q --tb=line`: `473 passed in 15.50s`.
`python tools/check_project_operating_system.py --root .`: `project operating system: PASS`.

Godot command:

```powershell
$cases = @('verify_bimu_constraint_model','verify_bimu_constraint_runtime','verify_bimu_constraint_ui','probe_sequential_ten_duel_campaign','verify_ten_duel_campaign','verify_vertical_slice_failure_retry','verify_vertical_slice_combat_bridge','verify_ten_manual_product_gate','verify_ten_manual_product_viewports','verify_combat_keyboard_accessibility','verify_combat_focus_order','verify_combat_layout_accessibility','verify_combat_action_selection_integration','verify_action_card_summary','verify_atlas_presentation_successor')
foreach ($case in $cases) {
  & 'C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script "tests/$case.gd"
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

All 15 passed, overall exit 0; model45, product50, constraint runtime/UI OK,
10 wins/36 routes/10 rewards actual public resolver campaign, no script error.
Task 3 headless 720/800 contrast/scroll/focus/identity checks stay in CI.
Controller visible captures source65fb51e3 are actual1280x800 only, no result/resource injection;
Hera error0/warning0. Fixed capture SHA values are in canonical report; raw attempts stay unstaged.

Five full-scope self-review loops and each correction are detailed in canonical report.
Review 1 current/history owner conflict; 2 engine/registry/retry identities and exact unlock IDs;
3 untouched full-suite consumers and format/routes; 4 capture/UI/evidence ceilings and preservation;
5 exact protected paths/approval/CI/report/current-owner alignment and pending delivery boundaries.

Concern: standalone bridge does not independently compare receipt run_seed/duel_index to a separate
expected context. Current actual shell sources current RunState receipt directly and retry compares
the frozen snapshot. No external receipt input consumer found; controller may choose a later bounded
defense patch. No core/save/reward/asset approval change.

Remaining: controller independent review, exact remote CI/label/PR merge/main readback and approval
lifecycle closeout. Whole Blueprint, visible720, full native-input campaign, Human/device/accessibility/
release remain unverified. An attempted `git -c core.autocrlf=false diff --check` treated existing CRLF
as whitespace and produced false whole-file noise; normal repository Git settings are required.

Final report/manifest rerun: 473 passed in 15.15s. Normal `git diff --cached --check` initially
found one new Markdown hard-break trailing space; removed it, then check PASS. An incorrect
expanded base SHA caused lifecycle command Invalid symmetric difference; resolved actual base
using `git rev-parse 61ccbdf5` and reran with `61ccbdf568968e98b3c1665cc66e53c343f418ef`:
`Protected approval lifecycle validation passed`. Exact manifest/committed product diff comparison:
`PROTECTED_APPROVAL_EXACT_PATHS_OK count=12`. No product edits in task 4 changed those paths.
