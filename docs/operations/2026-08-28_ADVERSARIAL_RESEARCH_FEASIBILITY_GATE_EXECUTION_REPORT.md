# 2026-08-28 · 적대 검토·외부 조사·구현 가능성 게이트 실행 보고

```yaml
decision_id: TEN-DEC-20260828-ADVERSARIAL-RESEARCH-FEASIBILITY-GATE-01
baseline_main: e08502050da79b7e28f89010ce6272979f253cea
work_mode: PLAN_TO_REVIEW
skill:
  - managing-game-project-operating-system: verify
  - governing-game-user-research-coverage: plan-evidence
  - running-adversarial-review-and-refinement: attack/validate-critique/refine-approved-findings/regression-recheck/decision-report
  - managing-design-documents: update/validate
  - reviewing-and-validating-project-changes: contract-check/reference-freshness/static-validation/regression/evidence-report
user_approval: "2026-08-28 user explicit: 그래"
product_mutation: NONE
notion_mutation: NONE
```

## Current-source relevance check

| research_question | source and freshness | finding | limit |
|---|---|---|---|
| Is the project’s existing automated Godot route technically supported? | Godot Command line tutorial, official, read 2026-08-28 | `--headless` / `--script` and CI export routes are documented. | Does not prove visible Windows or player experience. |
| Is an independent hosted Windows validation route technically available? | GitHub-hosted runners reference, official, read 2026-08-28 | Windows hosted runner availability and live runner labels are documented. | A live Actions result is still required per exact PR head. |
| Does input accessibility need to cover the plan UI as well as gameplay? | Game Accessibility Guidelines, field guideline, read 2026-08-28 | Menu/UI and gameplay input must be checked together. | It is a design/testing guide, not legal compliance or player evidence. |

Current operational feasibility: `FEASIBLE` for the repository policy, Python regression, current Godot headless route, and remote CI route; `PARTIAL` for any Human/device/accessibility claim because no new direct player/device observation is added.

## Five full-scope adversarial loops

Every loop rechecked the same whole surface: latest user intent; repository-only authority; current Decision and planning JSON; AGENTS/contract consumers; actual diff and runtime boundary; open PR ownership; external-source freshness; test/CI route; scope/cost/rollback; and long-term fit.

| loop | attack → validate → refinement | verification / re-attack | result |
|---|---|---|---|
| 1 | The old contract had a five-loop completion rule but did not make an every-task source relevance check or feasibility label explicit. This was a `MUST_FIX` omission for the user’s direction. | Added the Decision, AGENTS contract, project work contract, planning locator, and a failing-then-passing regression. | fixed |
| 2 | A literal “five loops and three sources for every typo” would create fake research/fake findings and higher maintenance cost. | Chose every-task base loop plus five full loops for material work; `NOT_APPLICABLE` requires a reason and cannot fabricate research. | adopted alternative A |
| 3 | Automation evidence could be misreported as Windows, Android, accessibility, or player proof. | Decision and AGENTS require `FEASIBLE / PARTIAL / BLOCKED_UNVERIFIED` and explicitly retain Human/device evidence ceilings. | fixed |
| 4 | A new operating Decision could remain invisible to fresh-read entrypoints or drift from mutable planning state. | AGENTS, contract frontmatter/body, planning JSON, Decision, and four regression assertions are connected. | fixed |
| 5 | Reference freshness may reveal untouched stale consumers; open PRs may duplicate the work. | #199 and #200 are unrelated drafts and remain read-only. Project governance regression passes. External Base freshness command has a pre-existing self-reference false positive described below; no source was weakened to hide it. | clean for this scoped policy change |

## Validated finding outside this change

`C:\Users\user\Documents\GitHub\Base\tools\check_canonical_reference_freshness.py` reports `skills/ten-paces-combat-prediction-validation/SKILL.md` as a deleted path remaining in `.github/reference-freshness.json`. The exact baseline `e0850205` already contains that string solely in `forbidden_active_paths`, so the report is a checker self-reference false positive, not a new active consumer introduced here.

- classification: `REJECTED_CRITIQUE` for this project change; `BASE_FOLLOW_UP_CANDIDATE` if the Base validator remains current.
- disposition: do not delete or weaken the forbidden-path declaration; project-local governance/reference regression continues to pass.
- base promotion: `DEFER_TO_BASE_OWNER`, because correcting the checker belongs to Base and is outside this user-approved project policy scope.

## Evidence and final disposition

- baseline: `python tools/check_project_operating_system.py` and 31 focused governance/contract regressions passed before the change.
- candidate: new gate regression, current-discovery, r5.4 contract, Base adoption, and project-governance regressions passed after the change.
- no code, data, Scene, Resource, asset, runtime behavior, generated image, Notion record, or production approval changed.

`CLEAN_REVIEW_EXIT_CANDIDATE` for this policy diff. Exact-head CI and post-merge `main` readback remain required before final completion.
