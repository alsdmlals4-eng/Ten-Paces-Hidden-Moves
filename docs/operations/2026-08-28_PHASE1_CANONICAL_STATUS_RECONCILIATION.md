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
