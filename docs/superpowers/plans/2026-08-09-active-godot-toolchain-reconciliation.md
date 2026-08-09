# Active Godot Toolchain Reconciliation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconcile the project canon and protected-state approval to the already-observed active Godot AI 3.1.3 + GUT 9.7.1 + Hera 1.0.0 toolchain without disabling GUT/Hera or falsely claiming local Hera/GUT validation.

**Architecture:** Keep the existing desired `project.godot` state unchanged. Introduce one new tooling reconciliation Decision, a structured active-toolchain contract, truthful Hera/Entry Gate updates, and a one-time Base protected-change approval manifest for the validator-detected `project.godot` path. Add CI-consumed regression tests before the minimal canon changes, then archive the one-time approval after merge and revalidate collector PR #122 on the reconciled main.

**Tech Stack:** GitHub Actions, Python `unittest`, JSON contracts, Godot 4.7.x project configuration, Godot AI/HiGodot 3.1.3, GUT 9.7.1, Hera Agent Godot 1.0.0, Google Sheets governance sync.

## Global Constraints

- Godot AI / HiGodot `3.1.3` remains the sole persistent Godot authoring authority.
- GUT `9.7.1` remains enabled and is deterministic GDScript test authority only.
- Hera Agent Godot `1.0.0` remains enabled and is `LIVE_QA_AND_OBSERVABILITY_ONLY`; persistent source/project mutation is forbidden.
- Existing `project.godot` three-autoload/three-plugin state is the desired state; do not roll it back.
- Do not claim Hera CLI version/status/smoke PASS until those commands actually run successfully.
- Do not claim local clean-checkout GUT PASS until the suite actually runs successfully.
- Do not modify Scene, Resource, combat data, gameplay scripts, images, or card/martial effects in this reconciliation.
- Protected approval must use Decision ID `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01` and exact validator-detected protected paths.
- Do not exploit the Base trailing-slash protected-path matcher blind spot as approval for nested files.
- Keep prior historical Decisions; supersede only stale tooling-state/version fields.

---

### Task 1: Add active-toolchain contract regression in RED

**Files:**
- Create: `tests/test_active_godot_toolchain_reconciliation.py`
- Test consumes: `project.godot`, `addons/godot_ai/plugin.cfg`, `addons/gut/plugin.cfg`, `addons/hera_agent_godot/plugin.cfg`, `docs/planning-data/HERA_ADOPTION_RECORD.json`, `docs/planning-data/current_entry_gate_20260808.json`, `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`, new Decision/contract files.

**Interfaces:**
- Consumes: current repository files only.
- Produces: CI-consumed assertions defining the desired toolchain and truthful claim ceiling.

- [ ] **Step 1: Write the failing test**

Create assertions that require:

```python
DECISION_ID = "TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01"

assert godot_ai_version == "3.1.3"
assert gut_version == "9.7.1"
assert hera_version == "1.0.0"
assert enabled_plugins == [
    "res://addons/godot_ai/plugin.cfg",
    "res://addons/gut/plugin.cfg",
    "res://addons/hera_agent_godot/plugin.cfg",
]
assert required_autoloads == {
    "TenManualProductValidationBootstrap",
    "HeraGameInspector",
    "_mcp_game_helper",
}
assert hera_record["enabled_in_project_godot"] is True
assert hera_record["adoption_status"] == "PLUGIN_ENABLED_L0_OBSERVED_CLI_PAIR_UNVERIFIED"
assert "HIGODOT_L2_ENABLE_HERA_PLUGIN_IF_ADOPTION_CONTINUES" not in hera_record["required_before_active"]
assert hera_record["exact_local_cli_version"] is None
assert entry_gate["hera_plugin_currently_enabled"] is True
assert entry_gate["product_implementation_authorized"] is False
assert approval["decision_ids"] == [DECISION_ID]
assert approval["approved_paths"] == ["project.godot"]
```

Also require the new Decision and structured contract to contain the authority split and L0 evidence marker `ten-paces-higodot-recovery@b62b` while explicitly retaining `HERA_CLI_ADDON_PAIR_UNVERIFIED` / local test `NOT_RUN` claim ceilings.

- [ ] **Step 2: Run the focused test and confirm RED**

Run in PR Validation or local/hosted Python:

```bash
python -m unittest tests.test_active_godot_toolchain_reconciliation -v
```

Expected RED causes: new Decision/contract/approval files missing and Hera/Entry Gate still record disabled state.

- [ ] **Step 3: Connect the new test to an existing CI-consumed validation path if standalone discovery is not guaranteed**

Prefer adding the test module to the existing explicit PR Validation Python invocation rather than creating a new workflow. Do not weaken or remove existing tests.

- [ ] **Step 4: Commit RED only**

```bash
git add tests/test_active_godot_toolchain_reconciliation.py .github/workflows/pr-validation.yml
git commit -m "test: require active Godot toolchain reconciliation"
```

Only include the workflow if explicit test wiring was actually necessary.

### Task 2: Add Decision, structured contract, and protected approval

**Files:**
- Create: `docs/decisions/2026-08-09_GODOT_AI313_GUT971_HERA100_ACTIVE_TOOLCHAIN.md`
- Create: `docs/planning-data/active_godot_toolchain_20260809.json`
- Create: `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`

**Interfaces:**
- Consumes: Task 1 Decision ID and Base protected approval schema.
- Produces: canonical toolchain state and one-time protected approval consumed by Project Base Adapter.

- [ ] **Step 1: Write the Decision**

Record exactly:

```yaml
decision_id: TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01
status: CURRENT_APPROVED_RECONCILIATION
godot_ai: 3.1.3
gut: 9.7.1
hera_addon: 1.0.0
higodot_role: SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY
gut_role: DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY
hera_role: LIVE_QA_AND_OBSERVABILITY_ONLY
hera_persistent_mutation: FORBIDDEN
project_godot_state: APPROVED_ACTIVE_PROTECTED_STATE
local_higodot_l0: PASS_OBSERVED_EXISTING_STATE
local_higodot_session: ten-paces-higodot-recovery@b62b
hera_cli_pair: HERA_CLI_ADDON_PAIR_UNVERIFIED
hera_status: NOT_RUN
hera_smoke_skip_game: NOT_RUN
local_gut_clean_checkout: NOT_RUN
product_implementation_authorized_by_this_decision: false
```

Explicitly supersede only stale configuration/version fields of older Decisions and state that the old rollback plan is `SUPERSEDED_DO_NOT_EXECUTE`.

- [ ] **Step 2: Add structured active-toolchain contract**

`active_godot_toolchain_20260809.json` must encode the exact plugin/autoload lists, versions, authority roles, L0 evidence, and remaining gates in machine-readable form.

- [ ] **Step 3: Add the one-time protected approval manifest**

Use Base schema v1 exactly:

```json
{
  "schema_version": 1,
  "artifact_role": "PROJECT_PROTECTED_CHANGE_APPROVAL",
  "status": "APPROVED",
  "protected_base_commit": "a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90",
  "decision_ids": [
    "TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01"
  ],
  "approved_paths": [
    "project.godot"
  ],
  "approval_source": "USER_EXPLICIT_KEEP_GUT_HERA_AND_CONTINUOUS_WORK_2026-08-09",
  "approval_time": "2026-08-09T10:57:00Z",
  "scope_summary": "Approve the existing desired project.godot active toolchain state: Godot AI, GUT, and Hera enabled with HiGodot sole persistent authoring authority and Hera restricted to live QA/observability."
}
```

Use the actual current timestamp if the write occurs later, while preserving the same approval source semantics.

- [ ] **Step 4: Run focused test**

```bash
python -m unittest tests.test_active_godot_toolchain_reconciliation -v
```

Expected: remaining failures only from stale HERA_ADOPTION_RECORD / entry gate until Task 3.

- [ ] **Step 5: Commit**

```bash
git add docs/decisions/2026-08-09_GODOT_AI313_GUT971_HERA100_ACTIVE_TOOLCHAIN.md docs/planning-data/active_godot_toolchain_20260809.json docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json
git commit -m "docs: approve active Godot toolchain state"
```

### Task 3: Reconcile Hera adoption record and current Entry Gate

**Files:**
- Modify: `docs/planning-data/HERA_ADOPTION_RECORD.json`
- Modify: `docs/planning-data/current_entry_gate_20260808.json`

**Interfaces:**
- Consumes: new Decision and structured contract.
- Produces: truthful current tool/adoption status for project gates.

- [ ] **Step 1: Update Hera adoption record minimally**

Set:

```json
"decision_id": "TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01",
"enabled_in_project_godot": true,
"enablement_evidence": "LOCAL_HIGODOT_L0_OBSERVED_EXISTING_ENABLED_STATE",
"enablement_session": "ten-paces-higodot-recovery@b62b",
"adoption_status": "PLUGIN_ENABLED_L0_OBSERVED_CLI_PAIR_UNVERIFIED"
```

Keep exact addon/release digests and role/security fields. Keep `exact_local_cli_version: null`. Remove only `HIGODOT_L2_ENABLE_HERA_PLUGIN_IF_ADOPTION_CONTINUES` from `required_before_active`; keep CLI SHA/version, restart, localhost/token, status, pre/post source snapshot, smoke, delta-none requirements.

- [ ] **Step 2: Update Entry Gate status**

Set current Hera fields to enabled/L0-observed and remove the future plugin-enable action from `allowed_next_actions`. Preserve blockers for CLI pair/status/smoke, export authoring/validation, local platform/device/human validation. Preserve `product_implementation_authorized: false`.

- [ ] **Step 3: Canonical JSON formatting**

Serialize both files with project-standard `json.dumps(..., ensure_ascii=False, indent=2) + "\n"` formatting to avoid canonical-format regressions.

- [ ] **Step 4: Run focused tests**

```bash
python -m unittest tests.test_active_godot_toolchain_reconciliation -v
python tests/test_poc_planning_data.py
```

Expected: PASS for active-toolchain assertions and canonical planning JSON checks.

- [ ] **Step 5: Commit**

```bash
git add docs/planning-data/HERA_ADOPTION_RECORD.json docs/planning-data/current_entry_gate_20260808.json
git commit -m "docs: reconcile Hera enabled state without claiming live QA"
```

### Task 4: Open reconciliation PR and exercise protected gate

**Files:**
- No product file changes.
- GitHub PR metadata + label only.

**Interfaces:**
- Consumes: Tasks 1-3 branch head.
- Produces: hosted RED/GREEN evidence for the one-time protected approval.

- [ ] **Step 1: Open a Draft PR**

Title:

```text
docs: reconcile active Godot AI GUT Hera toolchain
```

Body must state the user approval source, exact Decision ID, active toolchain roles, local HiGodot L0 observation, remaining CLI/test blockers, and no product/runtime feature diff.

- [ ] **Step 2: Verify pre-label protected gate behavior**

Allow the first Project Base Adapter run to demonstrate fail-closed external approval if practical. Do not alter the validator.

- [ ] **Step 3: Apply `approved-protected-change` label**

The label is the external GitHub approval metadata required by the pinned Base validator. The approval source is the user's explicit keep-GUT/Hera instruction and continuous-work continuation.

- [ ] **Step 4: Fetch exact-head workflow runs**

Require all project-triggered workflows, especially:

```text
Validate Project Base Adapter
PR Validation
Full Validation
Ten Manual Product Gate
GUT reconciliation/test workflows if triggered
```

All required checks must be SUCCESS on the same exact head. No CI rule may be disabled or weakened.

### Task 5: Sheet same-Decision premerge sync

**Files:**
- Google Sheet only: `00_프로젝트_허브`, `02_현재_확정결정`, `04_누락_충돌_감사`, `99_변경이력`.

**Interfaces:**
- Consumes: exact PR head + Decision ID.
- Produces: user-facing GDD state matching GitHub canon proposal.

- [ ] **Step 1: Add/update same Decision ID**

Record `TEN-DEC-20260809-GODOT-AI313-GUT971-HERA100-ACTIVE-TOOLCHAIN-01` as premerge approved-pending-validation state.

- [ ] **Step 2: Supersede rollback audit without erasing history**

Mark `TEN-AUD-20260809-INHERITED-PROTECTED-STATE-DRIFT` / recovery handoff as superseded by the active-toolchain reconciliation. Preserve history rows.

- [ ] **Step 3: Read back written cells**

Confirm Sheet does not claim Hera CLI/status/smoke or local GUT PASS.

### Task 6: Exact-head adversarial review and merge

**Files:**
- PR diff only.

**Interfaces:**
- Consumes: CI + Sheet premerge state.
- Produces: merged main with approved active toolchain canon.

- [ ] **Step 1: Inspect full PR diff**

Require zero changes to `project.godot`, addons, Scene, Resource, product scripts, combat data, or images in this reconciliation PR. The PR canonically approves an already-existing state; it does not rewrite it.

- [ ] **Step 2: Review thread and mergeability gate**

Require unresolved review threads `0`, no P0/P1 or user-decision finding, mergeable true, same exact head as validated.

- [ ] **Step 3: Ready and revalidate if ready transition triggers workflows**

Do not reuse stale exact-head checks after any head change.

- [ ] **Step 4: Squash merge under inherited continuous-work approval**

Merge only after all required evidence is green.

- [ ] **Step 5: Post-merge main readback**

Read back Decision, contract, HERA_ADOPTION_RECORD, entry gate, and unchanged `project.godot` from the new main SHA.

### Task 7: Archive one-time protected approval

**Files:**
- Delete: `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`
- Create: `docs/operations/2026-08-09_ACTIVE_TOOLCHAIN_PROTECTED_CHANGE_APPROVAL_RECORD.md`
- Test: extend `tests/test_active_godot_toolchain_reconciliation.py` or existing approval-adoption test.

**Interfaces:**
- Consumes: merged reconciliation PR evidence.
- Produces: no reusable approval left active for unrelated future PRs.

- [ ] **Step 1: Write archive-state failing test on a follow-up branch**

Require active approval file absent and historical record to contain Decision ID, merged PR/head/main SHA, protected base SHA, approved path `[project.godot]`, and approval source.

- [ ] **Step 2: Archive approval**

Remove the one-time manifest and create the historical merged record following the PR #92 precedent.

- [ ] **Step 3: Run approval regressions**

```bash
python -m unittest tests.test_active_godot_toolchain_reconciliation -v
python -m unittest tests.test_approved_protected_change_adoption -v
```

- [ ] **Step 4: Validate/merge archive follow-up**

This follow-up should contain no protected project-state change and should restore the invariant that no standing one-time approval authorizes future PRs.

### Task 8: Rebase/rebuild and validate collector PR #122

**Files:**
- Existing PR #122 branch: collector + regression test only.

**Interfaces:**
- Consumes: reconciled main without an active one-time approval manifest.
- Produces: Windows-safe collector merged only after its own exact-head evidence.

- [ ] **Step 1: Update #122 onto current main without losing its two-file scope**

Preserve the minimal root-cause fix:

- `$CommandArgs` instead of `$Args` automatic-variable collision;
- `NOT_RUN_GIT_UNAVAILABLE_SAFETY` fail-closed behavior.

- [ ] **Step 2: Update PR body**

Remove obsolete rollback framing. State that active toolchain reconciliation is now canon and #122 does not modify Godot tool state.

- [ ] **Step 3: Re-run exact-head workflows**

Require Project Base Adapter and all other triggered checks SUCCESS on the updated exact head.

- [ ] **Step 4: Merge only after review/thread gate**

Then read back collector from merged main.

### Task 9: Local clean-mode validation handoff

**Files:**
- No canon mutation from this session.
- Local evidence under ignored `build/local-validation/**`.

**Interfaces:**
- Consumes: merged fixed collector and user's clean isolated checkout.
- Produces: truthful local evidence for remaining gates.

- [ ] **Step 1: Run fixed collector from clean current main/recovery checkout**

Expected discovery:

```text
Godot AI 3.1.3
GUT 9.7.1
Hera addon 1.0.0
git available = true
```

- [ ] **Step 2: Resolve Hera CLI installation/PATH separately**

Do not mark `HERA_CLI_ADDON_PAIR_VERIFIED` until exact archive SHA and `hera version` match 1.0.0.

- [ ] **Step 3: Run local Godot/GUT/Hera gates when prerequisites are satisfied**

Sequence:

```text
Godot import/parse
→ focused/full GUT as required
→ tracked source pre-Hera snapshot
→ hera status
→ hera smoke --skip-game
→ tracked source post-Hera snapshot
→ require Hera-phase delta NONE
```

- [ ] **Step 4: Sync only actual PASS evidence back to GitHub + Sheet**

Unexecuted gates remain `NOT_RUN`/`BLOCKED_UNVERIFIED`.

## Self-review

- Spec coverage: active versions, authority split, L0 evidence, protected approval, stale canon supersession, Hera claim ceiling, wrong rollback retirement, Sheet sync, #122 dependency, post-merge approval archival, and local validation are each mapped to a task.
- Placeholder scan: no `TBD`/`TODO`/unspecified implementation placeholders remain.
- Type/property consistency: Decision ID, adoption-state string, protected baseline SHA, approval path, and L0 session ID are identical across tasks.
