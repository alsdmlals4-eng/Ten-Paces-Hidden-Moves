# Local Executor Handoff Closeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist the verified Ten Paces v5 local-executor bootstrap, close its project learning/handoff state without overstating live readiness, merge the project closeout, then submit any non-duplicate reusable lesson to Base as a proposal-only change.

**Architecture:** Keep one project-specific executable under `tools/`, one project verification owner (`ten-paces-verification`), and the existing `ACTIVE_CONTEXT/HANDOFF` state owners. Project merge happens before Base proposal work so Base provenance points to an actual merged source commit. Base active implementation remains untouched.

**Tech Stack:** Windows PowerShell 5.1-compatible launcher, Godot 4.7.1, Godot AI 3.1.4, Hera v1.0.0, GUT 9.7.1, Codex CLI, Python unittest, GitHub Actions/PR checks.

## Global Constraints

- Decision: `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`.
- Project: `C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves`.
- Dedicated Godot: `C:\Users\user\Tools\Godot-Ten-Paces-4.7.1\Godot_v4.7.1-stable_win64.exe` with `_sc_`.
- HiGodot/Godot AI: HTTP `8003`, WS `9503`, version `3.1.4`.
- Hera: version `1.0.0`, exact-project heartbeat/PID, dynamic localhost `8770..8785`; token values never enter evidence.
- Codex home: `C:\Users\user\.codex-ten-paces` on every fresh shell.
- Do not mutate `data/`, `src/`, `scenes/`, `assets/`, `addons/`, or `project.godot` in this closeout.
- PR #162 remains read-only/reference and is not merged or rewritten by this goal.
- Base write scope in the later stage is only `[수정제안서]/**`.

---

### Task 1: RED/GREEN Persisted Launcher Contract

**Files:**
- Modify: `tests/test_local_executor_bootstrap_contract.py`
- Create: `tools/start_ten_paces_local_executor.ps1`

**Interfaces:**
- Consumes: exact v5 launcher SHA-256 `db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c`.
- Produces: repository-resident launcher and current static contract.

- [ ] **Step 1: Correct the failing contract before implementation**

Replace the superseded `--recovery-mode` expectation with requirements for `@tool`, a temporary headless editor project/scene, `SceneTree.quit()` self-termination, Hera supported auth-source resolution, and semantic Codex `Not logged in` handling. Add negative assertions for standalone editor-context `--script`/`--recovery-mode` use.

- [ ] **Step 2: Run the focused test and confirm RED**

Run:

```bash
python -m unittest tests.test_local_executor_bootstrap_contract -v
```

Expected before launcher persistence: failure because `tools/start_ten_paces_local_executor.ps1` is missing.

- [ ] **Step 3: Persist the exact v5 launcher**

Copy the byte-exact v5 launcher into `tools/start_ten_paces_local_executor.ps1`. Verify:

```bash
python - <<'PY'
from pathlib import Path
import hashlib
p=Path('tools/start_ten_paces_local_executor.ps1')
print(hashlib.sha256(p.read_bytes()).hexdigest())
PY
```

Expected: `db7717ad7fda58a43aaf42c930d6c27a2b70d8862db894208c3ae2a861f9db7c`.

- [ ] **Step 4: Re-run focused test and confirm GREEN**

Run the same unittest command; expected all launcher-contract cases PASS.

### Task 2: Absorb Local Readiness into Existing Project Verification Owner

**Files:**
- Modify: `skills/qa/ten-paces-verification/SKILL.md`
- Modify: `skills/SKILL_LEARNING_LOG.md`
- Create: `tests/test_local_executor_handoff_contract.py`

**Interfaces:**
- Consumes: launcher markers/Decision and existing verification Skill.
- Produces: `local-executor-readiness` project verification mode plus reusable lesson locators.

- [ ] **Step 1: Write RED project-learning assertions**

Require the verification Skill to contain `local-executor-readiness`, `GODOT_AI_MCP_LIVE`, `HERA_EXACT_PROJECT`, `REPO_NO_NEW_MUTATION`, and a statement that bootstrap/process/port existence is not readiness PASS. Require the learning log to record the editor-context, native-stderr, reused-editor-auth, and repository-persistence lessons.

- [ ] **Step 2: Run the new test and confirm RED**

```bash
python -m unittest tests.test_local_executor_handoff_contract -v
```

Expected: FAIL until the Skill/log are updated.

- [ ] **Step 3: Make the minimum Skill/log changes**

Add one mode to the existing verification Skill; do not create a new Skill or Registry entry. Add concise validated lesson records to the existing learning log.

- [ ] **Step 4: Run focused tests and confirm GREEN**

Run both local-executor unittest modules.

### Task 3: Reconcile Superseded Bootstrap Documentation

**Files:**
- Modify: `docs/superpowers/plans/2026-08-11-local-executor-bootstrap.md`
- Modify: `docs/decisions/2026-08-11_LOCAL_EXECUTOR_BOOTSTRAP_DECISION.md`

**Interfaces:**
- Produces: documentation matching observed Windows/Godot behavior.

- [ ] **Step 1:** Remove current-plan instructions that require standalone `--recovery-mode + --script` for editor-context work and replace them with the verified temporary headless editor `@tool` scene mechanism.
- [ ] **Step 2:** Preserve historical failed attempts as evidence, not current procedure.
- [ ] **Step 3:** Record v5 local evidence precisely: Hera auth source resolved as `shared_token`, exact-project Hera PID/port observed, project-specific Codex login completed far enough to open Codex in the exact project with Sandbox ready; in-Codex fresh readiness and repeat-run remain `NOT_RUN`.

### Task 4: Continuation/Handoff Closure

**Files:**
- Modify: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- Modify: `[기획서]/00_프로젝트_허브/HANDOFF.md`
- Create/Modify: `tests/test_local_executor_handoff_contract.py`

**Interfaces:**
- Produces: one resumable checkpoint in existing state owners.

- [ ] **Step 1:** Add RED assertions that Handoff names the Decision, exact launcher path, completed/partial/not-run states, and next executable `IN_CODEX_FRESH_READINESS_GATE` then `FRESH_POWERSHELL_REPEAT_RUN_GATE`.
- [ ] **Step 2:** Update Active Context with semantic live state only; do not make stored PIDs/SHA current authority.
- [ ] **Step 3:** Update Handoff with recent applicable lessons and explicit `Base proposal work may be concurrent; always refetch Base main/Registry/open proposal PRs` warning.
- [ ] **Step 4:** Run focused tests.

### Task 5: Project Exact-Head Review and Merge

**Files:** all project branch changes above.

- [ ] **Step 1:** Compare branch to latest project main and confirm PR #162 changed files remain non-overlapping.
- [ ] **Step 2:** Run focused local-executor tests plus project operating/skill validation available in CI.
- [ ] **Step 3:** Create/update project PR with exact goal, learning closure table, `NOT_RUN` live gates, and no product implementation claim.
- [ ] **Step 4:** Inspect exact-head checks, review threads, changed files, and mergeability.
- [ ] **Step 5:** Merge once current exact-head evidence is terminal-clean under repository policy.
- [ ] **Step 6:** Re-read project new main and confirm launcher, Skill mode, Active Context/Handoff, and Decision are present. Do not create a follow-up PR only to write the closure PR's own merge SHA into Handoff.

### Task 6: Base Existing-Solution/Concurrency Gate and Proposal-Only Closeout

**Files in Base:** `[수정제안서]/**` only.

**Interfaces:**
- Consumes: merged project new-main SHA/PR and current Base `main`, proposal Registry, template, validator, open proposal-only PRs.
- Produces: either `REUSE_EXISTING_BCP` locator or one current-schema `SUBMITTED` proposal and Registry entry.

- [ ] **Step 1:** Fresh-read Base main, `[수정제안서]/README.md`, `PROPOSAL_REGISTRY.json`, template, validator, all open Base PRs, and same-goal proposals.
- [ ] **Step 2:** Classify `REUSE / ABSORB / REFACTOR / BUILD_NEW / NO_PROMOTION`. Prefer existing one-shot/dedicated-local-executor owners; do not propose a new broad Skill.
- [ ] **Step 3:** If a material gap remains and no concurrent same-goal proposal exists, allocate the next current-schema machine ID without touching another project's entry, create a proposal-only branch from current Base main, and add Proposal + Registry semantic-union entry.
- [ ] **Step 4:** Validate proposal repository/schema/proposal-only diff against current Base main; include project source PR/new-main and benchmark evidence.
- [ ] **Step 5:** Create proposal-only PR, recheck Base main/Registry/open proposal PRs immediately before merge, refresh own delta if Base moved, then merge when exact-head checks/review are clean.
- [ ] **Step 6:** Re-read Base new main and confirm only `[수정제안서]/**` changed for this proposal. Proposal remains `SUBMITTED`/current lifecycle state; Base active implementation is a separate follow-up stage.

## Completion Gate

The closeout is complete only when project learning closure is merged and verified, and the Base reusable outcome is either a verified `REUSE_EXISTING_BCP` or a merged proposal-only record. In-Codex fresh readiness and fresh-PowerShell repeat-run are deliberately carried forward as next executable local evidence; they are not fabricated as PASS during this handoff.
