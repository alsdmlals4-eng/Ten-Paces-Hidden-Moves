# 2026-08-28 · Phase 1 정본 상태 조정 기록

> Status: `CURRENT_RESOLVED_DOCUMENTATION_ONLY`
> Scope: Board R2 / warm-dusk v2의 계획 상태와 작업 순서만 조정. Godot 제품 파일, 런타임 자산, 전투 규칙, Human evidence는 변경하지 않았다.

## Incident

`PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2`는 사용자 final lock, repository 추적, exact Project Notion Visual Bible binary attachment/readback까지 끝났지만, 다음 current-facing surface에는 이전 상태가 남아 있었다.

- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`: warm-dusk v2 review 진행 중으로 표시.
- Project Notion Home / Visual Bible / Asset Library / GPT Work handoff: 일부가 direction candidate in-review 또는 Board final-lock pending으로 표시.

이 상태는 planning-only artifact를 runtime asset으로 오인하게 하지는 않았지만, 다음 안전 작업과 현재 visual cadence를 잘못 안내할 위험이 있었다.

## Evidence and classification

| Surface | Fresh-read result | Classification | Disposition |
|---|---|---|---|
| Repository planning visual JSON | v2 anchor approved; Board R2 user-final-locked planning-only | `CURRENT` | authority retained |
| Board companion | CTA / 3 slots / first-two linked contract recorded | `CURRENT` | authority retained |
| Active Context | v2 review still pending | `STALE` | corrected |
| Notion Home / Visual Bible / Asset Library / handoff | partial in-review or pending-final-lock wording | `STALE` | corrected and read back |
| POC data/code | 4/7 start, 8 basic cards, `진행` copy | `CANON_CONFLICT` | retained for a later single implementation contract |

## Solution

- Active Context now records Board R2 final lock, warm-dusk v2 planning-anchor status, and the user-directed Phase 1 order: remaining planning/review first, then one implementation contract.
- Contract regression now protects those mutable status fields.
- Project Notion Home, Visual Bible, Asset Library, and GPT Work handoff were updated with the same planning-only and no-automatic-next boundaries.

## Destination readback

| Destination | Readback |
|---|---|
| Active Context + `tests/test_current_discovery_contract.py` | `PASS` after focused regression |
| Notion Home | `PASS` · Board R2 + Phase 1 canonical update present |
| Notion Visual Bible | `PASS` · Board R2 final lock present |
| Notion Asset Library | `PASS` · v2/Board planning-only + runtime boundary present |
| Notion GPT Work handoff | `PASS` · final-lock handoff overlay present |

## Lesson

Planning visual lifecycle labels must be reconciled across repository mutable state and human-facing Notion projections immediately after a final-lock, while keeping `planning-only`, runtime promotion, and Human/Player evidence as separate states.

## Base promotion decision

`NO_BASE_PROMOTION`: the affected Decision IDs, visual artifact identities, destinations, and runtime conflicts are specific to 십보강호. The general repository/Notion readback discipline is already covered by the Base operating contract.

## Deferred implementation conflicts

- player-facing public start distance `2` versus legacy POC coordinate binding `4/7`;
- approved 10 basic actions versus legacy runtime 8 cards;
- `행동계획 실행` and plan-to-resolution transition versus runtime POC `진행` copy;
- human/device/accessibility/player-experience evidence ceilings.

These are not documentation-only fixes and remain open inputs to the consolidated implementation contract.

## Update 2 · Phase 1 remaining planning and adversarial review

> Status: `CURRENT_REVIEW_IN_PROGRESS`
> Scope: current Project GitHub/Notion/runtime evidence, player-experience contract, visual planning anchor, and implementation-contract inputs. No Godot product file or runtime asset was changed.

### Fresh-read authority and evidence

| Surface | Exact source / observed state | Classification |
| --- | --- | --- |
| Project completed `main` | `55612abca0bc91154681febfc2b85faf156ef2f7` (`docs: reconcile phase 1 canonical status (#254)`) | `CURRENT` |
| Base remote completed `main` | `7cfc75d607d1ed4d0f8323d4389e64da93df00c8` (`docs: close BCP-2026-046 as implemented (#767)`) | `CURRENT_REFERENCE` |
| Open PRs | #199, #200 draft; inspected only | `READ_ONLY` |
| Mutable project state | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`, `docs/planning-data/current_user_planning_status.json` | `CURRENT_AFTER_THIS_UPDATE` |
| Human-facing projection | exact Project Notion Home, Direction/Flow, Visual Bible, Asset Library, GPT Work handoff; Home readback confirms current Phase 1 ordering and planning-only visual boundary | `CURRENT_PARTIAL` |
| Runtime combat | `data/combat/combat_board_poc.json`, `data/cards/basic_cards.json`, `src/combat/combat_board_preview.gd` | `IMPLEMENTED_LEGACY_CONFLICT` |
| First-five flow | `scenes/run/vertical_slice_shell.tscn`, `src/run/vertical_slice_*.gd`, focused automated tests/CI | `IMPLEMENTED_AUTOMATED_ONLY` |
| Visual planning anchors | warm-dusk v2 + Board R2 with recorded hashes in current visual handoff | `USER_APPROVED_PLANNING_ONLY` |

Google Sheets was not used: it remains `MIGRATION_ONLY_UNTIL_REMOVAL` and no unique material was required for this review.

### Current experience model

```text
Read public intent/history
→ choose a 3/3/4 action plan within distance, resources, and slot constraints
→ press 행동계획 실행
→ watch the committed plan resolve in combat animation
→ understand the cause in Review
→ adapt the next plan, route, or growth choice
```

The differentiated promise is not collecting a deck or predicting a fully revealed enemy script. It is reading an opponent from public state and history while both current plans remain hidden, then accepting the consequence of a limited-slot martial plan. `3수 = 3슬롯`; a two-slot action occupies `[전조] → [실행]` before its result can be seen.

### Verified findings and dispositions

| Finding | Class | Evidence | Disposition |
| --- | --- | --- | --- |
| Current product canon says public opening distance `2`, but runtime binds player/enemy to `4/7` (distance `3`) | `CONFLICT` | `docs/02_COMBAT_RULES.md`; combat JSON and preview script | `USER_DECISION_REQUIRED` before implementation |
| Canonical 10 basic actions include Observe and Palm; runtime card data has 8 | `CONFLICT` | `docs/02_COMBAT_RULES.md`; `data/cards/basic_cards.json` | consolidated contract input |
| Canonical CTA is `행동계획 실행`; runtime labels are `진행` / `행동 묶음 진행` | `CONFLICT` | CTA Decision; combat JSON/script | consolidated contract input |
| First-five PC-first flow, routes, Result, and RunState exist and focused automated evidence is green | `CURRENT_PARTIAL` | Vertical Slice scenes/scripts and focused tests | preserve; do not restate as unimplemented |
| Result copy says reward application is deferred while `VerticalSliceRunState` applies a reward receipt | `CONFLICT` | Result UI script versus RunState | consolidated contract copy/state input |
| Planned failure/retry learning is not a player-facing first-five flow proof | `PARTIAL` | combat canon/retry contract versus current shell | `USER_DECISION_REQUIRED` after opening-distance decision |
| Windows visible play, Android device, accessibility user, and Player Experience evidence | `NOT_RUN` | current Active Context and validation contracts | remain evidence ceiling; no PASS claim |

### Evidence-based SWOT

| Statement | Class | Evidence / confidence | Player impact | Production impact | Disposition / next validation |
| --- | --- | --- | --- | --- | --- |
| The hidden-plan, public-history duel loop gives each committed bundle a readable social inference hook. | `STRENGTH` | Canonical combat rules + AI hidden-plan guardrails; `VERIFIED` as design/implementation boundary, not fun proof. | A correct read feels authored by the player. | Protect the AI privacy boundary in every consumer. | `PROTECT`; human think-aloud can test whether players infer rather than guess. |
| The first-five route/run structure already lets a player reach several read-plan-resolve-review cycles. | `STRENGTH` | merged scene/scripts + focused automated flow evidence; `PARTIAL`. | Makes the intended journey inspectable rather than a single fight. | Reuse existing RunState and route structure. | `TEST`; visible Windows playthrough with first-session recall. |
| Product canon and active combat runtime disagree on opening distance, basic action count, and CTA copy. | `WEAKNESS` | exact canon/data/script comparison; `VERIFIED`. | A player may learn the wrong spatial or action vocabulary. | One contract must reconcile data, UI, tests, and docs. | `IMPROVE`; resolve decision then exact-head regression. |
| Review can teach the next attempt, but failure/retry and reward wording are not yet one proved player journey. | `WEAKNESS` | flow UI/RunState comparison; `PARTIAL`. | The loss-to-learning loop may feel incomplete. | Small surface can expose a larger save/economy boundary. | `TEST`; decide P0/P1 then test one failed duel. |
| Telegraph-first tactical games show that visible cause-and-effect can support deep short turns without copying their information model. | `OPPORTUNITY` | official Into the Breach and Phantom Brigade references; `INFERENCE` for Ten Paces fit. | Clearer commitment and resolution can make reading satisfying. | Adapt causal feedback only; retain hidden plans. | `TEST`; compare post-resolution comprehension in playtest. |
| Tactical/card-combat expectations can pull the product toward revealed future plans or deck/hand complexity. | `THREAT` | project exclusions + official Yomi/Fights in Tight Spaces references; `VERIFIED` as scope boundary. | Would dilute the specific martial-reading promise. | Scope and content cost increase sharply. | `MITIGATE`; reject deck/hand/draw and exact future-intent reveal. |

External-reference disposition: **ADAPT** Into the Breach’s causal clarity and Phantom Brigade’s plan-to-execution readability; **ADAPT** Yomi’s mutual hidden-choice tension; **REJECT** their fully revealed intent, deck/hand, and distinctive surface expression. These references are not project assets or runtime proof.

### Adversarial review record

Each pass re-checked the same full surface: user direction, authority/Notion/repository ownership, product core, actual data/scripts/scenes/tests, visual/status claims, open PR boundaries, evidence ceiling, alternatives, and long-term fit.

| Pass | Validated result | Correction or status |
| --- | --- | --- |
| 1 | Board and warm-dusk final-lock state was stale across mutable surfaces. | Corrected in Update 1; runtime boundary retained. |
| 2 | First-five flow had been simultaneously described as merged/green and unimplemented. | Corrected in `01`, `05`, and `09`; latest combat core remains explicitly legacy. |
| 3 | User’s current order was still represented as completed planning in mutable state. | Corrected in the planning JSON, Active Context, and regression contract. |
| 4 | Core rule/runtime delta is material, not a documentation typo. | Kept as `USER_DECISION_REQUIRED`; no covert runtime change. |
| 5 | Visual board, CTA decision, and implementation evidence could be conflated. | Planning-only / runtime / human-evidence labels retained; no asset or Godot production started. |

`CLEAN_REVIEW_EXIT` is not applicable: the material opening-distance decision and the later failure/retry scope decision remain open by design. No finding authorizes product implementation before the single consolidated contract.

### Work stage and next order

- `Work 5 stage`: `UNKNOWN_UNVERIFIED`. No current owner defines a canonical five-stage Work model; the project uses `PLAN / BUILD / REVIEW`. This review is `PLAN → REVIEW`; it must not be relabelled as a fabricated “stage 5”.
- Current accepted frontier: resolve the canonical opening-distance/runtime mapping, then failure/retry scope, then finish the consolidated contract.
- Active playable slice: first-five PC-first route flow is present with automated evidence; its combat core remains the 4/7, 8-action legacy implementation.
- Required work remains ordered by dependency and player value: opening-distance decision → failure/retry decision → consolidated contract → Codex Godot implementation handoff → exact-head automated/runtime evidence → Windows visible/Human test → Android/accessibility/performance evidence.

### Execution report

```yaml
work_mode: PLAN_TO_REVIEW
skill_id:
  - ten-paces-game-design: rule-update/poc-contract
  - combat-ux-and-accessibility: ui-contract/planning-mockup-review
  - ten-paces-verification: contract-check/evidence-report
  - managing-design-documents: update/validate
  - auditing-canonical-reference-freshness: impact-map/content-drift/propagation-gap
  - running-adversarial-review-and-refinement: attack/validate-critique/decision-report
selection: automatic_from_project_rules_and_user_requested_grill_me
work_performed: Fresh-read reconciliation and five-pass Phase 1 adversarial planning audit.
result: DOCUMENTATION_DRIFT_CORRECTED; CORE_DECISIONS_PENDING
evidence: Current main/PR reads, exact Notion readback, canon/data/script comparisons, focused automated evidence inventory.
unverified: Windows visible, human play, accessibility user, Android device, release performance.
base_promotion: NO_BASE_PROMOTION — findings are tied to this project’s rules, runtime lineage, and human-facing destinations; Base already owns the general reconciliation method.
```

### Verification incident · pre-existing full-suite failures

`python -m unittest discover -s tests -p 'test_*.py'` ran 404 tests after the current-state regression was corrected. It still has 8 failures that are outside this branch’s diff:

- `test_actions_budget_manual_validation_fallback`: its historical expectation `NOT_RUN_BUDGET_UNAVAILABLE` conflicts with the unchanged main reconciliation JSON value `STANDARD_GITHUB_HOSTED_RUNNER_REQUIRED`.
- `test_integrated_work_contract_v45r2`: all six historical contract parts differ from the stored byte hashes/sizes; the parts and test are unchanged from `origin/main`.

The relevant tests and inputs were verified unchanged from `origin/main`; no historical contract hash, reconciliation value, or test was silently rewritten here. The Phase 1 scoped suite (25 tests), canonical combat impact map, operating-system validator, and canonical-reference freshness check pass. Disposition: `FOLLOW_UP_OUT_OF_SCOPE_HISTORICAL_TEST_RECONCILIATION`; it does not lower Human/Player/runtime evidence and is not treated as a Phase 1 product regression.

## Update 3 · Opening-distance runtime mapping approved

```yaml
decision_id: TEN-DEC-20260828-OPENING-DISTANCE-RUNTIME-MAPPING-01
status: APPROVED_CURRENT_IMPLEMENTATION_BINDING_REQUIRED
approval_source: "user explicit: A.권장안대로 진행"
selected_option: A
product_rule: "The public opening distance is 2."
implementation_direction: "Runtime start state, distance calculation, AI input, HUD, accessibility label, and combat log share that one public meaning."
not_decided_here: "The internal coordinate pair; it is a technical binding chosen only with boundary, occupancy, and regression evidence in the consolidated implementation contract."
runtime_evidence: NOT_RUN
human_evidence: NOT_RUN
```

This closes the opening-distance `USER_DECISION_REQUIRED` finding without changing `data/`, `src/`, `scenes/`, assets, or runtime tests. The legacy `4/7` / distance `3` product path remains `IMPLEMENTED_LEGACY` until the later implementation contract is approved and executed. The next material design question is the player-facing failure/retry journey scope.

## Update 4 · GitHub Actions queue incident

> Classification: `EXTERNAL_VALIDATION_BLOCKED`; no product or canonical-rule failure has been found.

### Statement

The current-task documentation PR cannot yet be safely squash-merged because the exact-head remote check `Validate Approved Protected Change Workflow / contract` remains queued. Its local equivalent passes; all other reported exact-head checks pass.

### Evidence

- Current-task PR: `#256`, head `76b2917a13b16dfd59feec2c221edce44cc150c7`.
- Local exact workflow command: `python -m unittest tests.test_approved_protected_change_workflow -v` → `PASS` (1 test).
- Remote exact-head checks: all reported checks other than the queued workflow completed `SUCCESS`.
- GitHub queue readback: the same repository has unrelated queued runs older than 41 hours. Those branches and runs remain read-only under the open-PR concurrency rule.

### Disposition and next validation

- Do not cancel, restart, merge around, bypass, or modify another PR's run.
- Do not write the user-facing Notion projection before the repository change is accepted on `main`.
- After the queued check completes successfully: re-read the exact PR head/check result, perform the allowed current-task squash merge, re-read `main`, then update and read back Project Notion Home.

### Lesson and Base promotion

`NO_BASE_PROMOTION`: this is an external GitHub Actions capacity condition, not a reusable project-specific design or implementation lesson. The Base already requires exact-head checks and prohibits bypassing them.

## Update 5 · First-five defeat/retry scope approved

```yaml
decision_id: TEN-DEC-20260828-FIRST_FIVE-DEFEAT-RETRY-SCOPE-01
status: APPROVED_CURRENT_IMPLEMENTATION_BINDING_REQUIRED
approval_source: "user explicit: 권장안대로 진행"
selected_option: A
first_five_policy: ONE_FREE_SAME_SEED_RETRY_PER_DUEL_THEN_END_RUN
paid_retry_policy: DEFERRED_POST_SLICE_EXTENSION_REQUIRES_NEW_APPROVAL
runtime_mutation: NONE
runtime_evidence: NOT_RUN
human_player_evidence: NOT_RUN
```

### Resolved conflict

The canonical architecture/UI/planning contract required a paid permanent-currency retry `1/2/3`, while the actual first-five shell only has a victory-tested Result path and its screen inventory marked failure/retry `NOT_APPLICABLE`. The two states could not prove the intended `failure → review → revised plan` loop.

### Resolution

For the first-five slice, the player receives one free retry from the pre-battle snapshot against the same seed after the first failure. A second loss ends the run and returns to title; it grants no reward and cannot advance a Route. Permanent currency, balance, paid retry, profile persistence, and payment recovery remain deferred. This preserves the learning loop while avoiding an unproven economy/save expansion before Human fun evidence.

### Required later validation

- exactly-one retry and retry-exhausted result;
- same opponent/seed and full pre-battle rollback;
- no duplicate reward, Route advancement, signal, or log consumption;
- no permanent-currency or paid-retry surface in the first-five slice;
- Windows visible/Human, accessibility, Android, and Player Experience evidence remain separate `NOT_RUN` gates.

### Base promotion decision

`NO_BASE_PROMOTION`: the retry limit, same-seed policy, 5-duel slice, and deferred currency model are 십보강호-specific. Base already owns the general discipline of separating player-facing learning loops from unvalidated progression economies.
