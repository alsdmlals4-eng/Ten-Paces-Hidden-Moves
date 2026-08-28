# Issue #264 · Master GDD 핵심 시스템 설명 확장 실행 보고

```yaml
issue: 264
baseline_main: 768cc67e369ae992d9f92ef51024c677fa217cb6
branch: codex/core-system-gdd-expansion-20260828
work_mode: REVIEW
skill_mode:
  - ten-paces-hidden-moves-workflow-router: verify
  - managing-design-documents: update/validate
  - running-adversarial-review-and-refinement: five-full-scope-loops
  - reviewing-and-validating-project-changes: reference-freshness/static-validation/regression/evidence-report
  - pdf: create/render/inspect
user_approval: "2026-08-28 user explicit: 승인"
product_mutation: NONE
asset_mutation: NONE
notion_mutation: NONE
```

## Current-source relevance and feasibility

| research question | source and freshness | finding | limit |
|---|---|---|---|
| Can the GDD describe plan-to-execution combat presentation without inventing an impossible Godot path? | [Godot animation introduction](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html), official, read 2026-08-28 | `AnimationPlayer` supports property-based animation across sprites, UI, and particles. | Feasibility only; not a runtime, Human, or final-VFX quality result. |
| Can sprite-sequence feedback remain compatible with the stated visual layer? | [Godot 2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html), official, read 2026-08-28 | `AnimatedSprite2D` and sprite-sheet animation are documented. | Does not approve a new asset batch or prove gameplay-size readability. |

Feasibility: `FEASIBLE` for the repository GDD/PDF documentation update and the existing animation-consumer description; `PARTIAL` for any visible Windows, Human, Android, accessibility, or release claim.

## Five full-scope adversarial loops

Every loop rechecked the approved user correction, current repository authority, `AGENTS.md`, source rules/data/Scene/asset consumers, open PR ownership, actual diff, scope/cost/rollback, external-source relevance, and evidence ceiling.

| loop | attack | validated evidence | refinement / result |
|---|---|---|---|
| 1 | The GDD could still treat `3수` as three independent actions and hide the cost of a 2-slot action. | `docs/02_COMBAT_RULES.md` §3 and `data/cards/basic_cards.json` define 3 slots and `[전조] → [실행]`. | Added the player-question, occupancy, prepayment, interruption, and execute-transition explanation. |
| 2 | 강호행 could be misread as a combat/map expansion rather than the approved non-combat choice structure. | `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md` §7; `docs/13_*` and `docs/14_*` define 5 duels and exactly 8 intermediate nodes. | Added the fixed two-node cadence, decision trade-offs, Briefing boundary, and no-reroll/no-answer-leak protections. |
| 3 | A tag glossary could invent effects or collapse `[준비]`, `[강화]`, `[강건]`, `[합]`, and `[중단]` into vague flavor. | `docs/02_COMBAT_RULES.md` §§6–12 and actual basic action JSON. | Added causal descriptions and corrected the stale summary wording from `[행동]` to `[실행]` where the rules/data use the execution tag. |
| 4 | Visual wording could promote planning art or a tracked VFX file into a final runtime/Human-quality claim. | `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md` §16; `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`; actual consumer paths. | Separated actual card/VFX consumers, deferred individual technique art, planning-only board status, and `UX_NOT_RUN` evidence. |
| 5 | The GDD header could retain an older source snapshot and make current open PRs or the every-task gate invisible. | `origin/main@768cc67`, PR #199/#200 metadata, #263 Decision and planning-state owner. | Advanced the GDD's source baseline to `768cc67`, preserved #199/#200 as read-only metadata, and added the Issue #264 incident/lesson record. |

## Incident / Solution / Lesson

**Incident:** the prior GDD registered core systems but did not connect non-combat Route choices, action-slot cost, tag causality, and martial visual consumers into a player-readable system explanation.

**Solution:** the approved GDD expansion adds these explanations while retaining field-level owners, implementation/evidence labels, and non-production-asset boundaries.

**Lesson:** a consolidated GDD must state `visible information → player choice/cost → resolution result → review/next action` for each core system, without turning documentation into a new rules owner or a runtime claim.

**Base promotion:** `NO_BASE_PROMOTION`. The route cadence, combat tags, and martial visual grammar are project-specific; Base already owns the generic evidence-and-adversarial-review discipline.

## Scope, rollback, and remaining evidence gap

- Changed only the GDD source, its matching PDF, and this execution record. No code, data, Scene, Resource, asset, visual generation, Notion record, gameplay rule, or runtime behavior changes.
- Rollback is a single PR revert of the documentation revision.
- PDF rendering, document contracts, exact-head checks, remote PR checks, and post-merge main readback remain required before final completion.
- Windows-visible readability, Human/player experience, Android device, accessibility-user, final VFX, and release evidence remain `NOT_RUN`.
