# One-Time Protected Change Approval Lifecycle

> Decision scope: GitHub Issue #210. This design unblocks the approved `DOGYEOM_STATUS_PORTRAIT_01` runtime binding in Issue #208 without altering game behavior.

## Problem

The Base validator correctly requires an exact active approval manifest plus the `approved-protected-change` label for protected runtime paths. The project-only active-toolchain test, however, rejects any active manifest without PR/base context. A newly approved protected change therefore cannot pass both checks.

## Design

Add a small executable lifecycle checker used by PR CI. It compares the PR base tree with the head tree:

1. A manifest newly added by the PR is allowed when that PR also pins `skills/PROJECT_BASE_ADAPTER.json` `protected_baseline.commit` to its exact base SHA; the existing Base validator remains responsible for its exact path list and GitHub label.
2. A manifest carried from the base tree is rejected, so it cannot authorize unrelated later PRs.
3. A PR that removes a carried manifest must add an immutable audit record and set `skills/PROJECT_BASE_ADAPTER.json` `protected_baseline.commit` to that PR's base SHA. This is the archive-and-promote transition.
4. No-manifest PRs remain unaffected.

The unconditional toolchain test will retain its historical-record assertions but delegate active-manifest lifecycle enforcement to the new base-aware checker.

## Non-goals

- No weakening of exact manifest validation, GitHub label enforcement, generated-view validation, or protected-path detection.
- No Godot runtime, asset, UI, combat, AI, save, platform, or Notion behavior changes.

## Verification

Unit tests must prove all four lifecycle states. The PR workflow must run the checker before the existing Base validator. The approved status-portrait tests and existing project checks remain required.
