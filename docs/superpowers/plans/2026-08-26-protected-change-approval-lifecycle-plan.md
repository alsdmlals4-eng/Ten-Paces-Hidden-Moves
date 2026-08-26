# Protected Change Approval Lifecycle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a new, exactly approved protected-change manifest pass its originating PR while forcing a later audit-and-baseline-promotion cleanup PR.

**Architecture:** A repository Python checker compares the PR base tree with the checked-out head. The existing Base validator still owns label and exact-path validation; the new checker owns only manifest lifetime. The existing active-toolchain regression keeps its archived-record check but no longer guesses PR context.

**Tech Stack:** Python 3.12 `unittest`, GitHub Actions, JSON, Git.

**Spec:** `docs/superpowers/specs/2026-08-26-protected-change-approval-lifecycle-design.md`

## Global Constraints

- Preserve the Base exact manifest and `approved-protected-change` label gates.
- A carried active manifest must fail before Base validation.
- Cleanup requires an audit record and baseline promotion to the exact PR base SHA.
- No Godot product behavior changes.

---

### Task 1: Base-aware lifecycle checker

**Files:**
- Create: `tools/check_one_time_protected_change_lifecycle.py`
- Create: `tests/test_one_time_protected_change_lifecycle.py`

**Interfaces:**
- Consumes: `--base-sha`, Git object tree, current repository files.
- Produces: zero exit only for a new manifest, a correctly archived/prompted cleanup, or no manifest transition.

- [ ] **Step 1: Write failing tests** for new-manifest acceptance, carried-manifest rejection, cleanup audit/baseline requirements, and no-op acceptance.
- [ ] **Step 2: Run the tests** and confirm import failure because the checker does not exist.
- [ ] **Step 3: Implement** a minimal pure lifecycle classifier plus a CLI Git adapter.
- [ ] **Step 4: Run tests** and confirm all lifecycle states pass.

### Task 2: CI integration and archived-toolchain regression

**Files:**
- Modify: `.github/workflows/validate-project-base-adapter.yml`
- Modify: `tests/test_active_godot_toolchain_reconciliation.py`

**Interfaces:**
- Consumes: Task 1 checker and `github.event.pull_request.base.sha`.
- Produces: PR-context lifecycle enforcement before the Base exact-path validator.

- [ ] **Step 1: Write failing workflow regression test** for invoking the lifecycle checker with the PR base SHA.
- [ ] **Step 2: Run it** and confirm the invocation is absent.
- [ ] **Step 3: Add the minimal workflow step** and remove only the context-free active-manifest absence assertion.
- [ ] **Step 4: Run affected tests** and confirm they pass.

### Task 3: Issue #208 manifest and validation

**Files:**
- Create: `docs/implementation/BUILD_APPROVAL_2026-08-26.md`
- Create: `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`

**Interfaces:**
- Consumes: lifecycle checker and existing Base validator.
- Produces: the exact approved protected-path receipt for PR #209.

- [ ] **Step 1: Add the manifest and BUILD record** with the exact detected paths and user approval source.
- [ ] **Step 2: Run lifecycle, affected Python, Godot, and diff checks**.
- [ ] **Step 3: Apply the GitHub label and confirm CI is green.**

### Task 4: Post-merge archive and baseline promotion

**Files:**
- Delete: `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`
- Create: `docs/operations/2026-08-26_PR209_PROTECTED_CHANGE_APPROVAL_RECORD.md`
- Modify: `skills/PROJECT_BASE_ADAPTER.json` and its generated views.

**Interfaces:**
- Consumes: merged PR #209 SHA.
- Produces: a clean base with no reusable active manifest and a protected baseline pinned to the merge commit.

- [ ] **Step 1: Create a separate cleanup branch from merged main.**
- [ ] **Step 2: Write a failing lifecycle check for incomplete cleanup.**
- [ ] **Step 3: Archive the receipt and promote the baseline.**
- [ ] **Step 4: Verify and safely merge the cleanup PR.**
