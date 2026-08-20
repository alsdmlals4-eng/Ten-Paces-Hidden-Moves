# Decision · Vertical Slice Visual/UX System

- Decision ID: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`
- Date: 2026-08-20
- Status: `APPROVED`
- User approval: `좋아 진행해`
- Scope: first five-duel Vertical Slice Visual/UX requirement and reuse system
- Product implementation authorization: `false`
- New image generation authorization: `false`

## Decision

십보강호 첫 Vertical Slice는 **통합 수묵 전술 화폭**을 사용한다.

현재 전투의 수묵·세피아·먹+금 자산과 정보 위계를 재사용하여 `Main → Setup → Intro → Briefing → Combat → Review → Result → Route → Completion`을 하나의 시각 언어로 묶는다.

## Why

- 기존 전투 자산과 가장 높은 일관성을 유지한다.
- 15명 × 화면별 독립 일러스트 폭증을 막는다.
- 전투판·거리·3/3/4 계획의 가독성을 장식보다 우선한다.
- 숨은 계획 정체성을 보호하면서 Review의 인과는 더 명확하게 만들 수 있다.
- Windows/Android에서 같은 정보 필드를 유지한 채 반응형 재배치가 가능하다.

## Protected constraints

- 10칸, 3/3/4, hidden plan, AI anti-cheat, 거리·합·대응·중단·복기.
- 시작 무공 6중4.
- 5 duel slots × 3 candidates.
- Duel 사이 2 Route nodes.
- Result 뒤 다음 상대 선잠금.
- Combat Review overlay / Result separate scene.
- `[관찰]` answer-leak guardrails.
- 카드를 덱/손패/드로우 시스템으로 재해석하지 않음.

## Reuse-first package

- 기존 전투 배경 계보.
- 기존 player/enemy portrait 계보.
- 기존 RGBA battler 계보.
- 기존 먹+금 VFX 계보.
- 기존 card illustration/badge/cost icon atlas.
- 구조화 UI text/data binding.

## Minimum new visual inventory

- `TEN-VIS-A01`: shared noncombat ink clean plate 1–2.
- `TEN-VIS-A02`: 15 opponent portraits.
- `TEN-VIS-A03`: 15 opponent combat battlers.
- `TEN-VIS-A04`: 8 route icons.
- `TEN-VIS-A05`: result/completion seals and grade markers.
- `TEN-VIS-A06`: 2–3 additional low-contrast battle background variants.

All are `REQUIREMENT_APPROVED / NOT_GENERATED`.

## Benchmark boundary

Use only principles:

- causal readability after resolution;
- separation of planning and execution tension;
- opponent tendency reading;
- positional and wait-vs-act significance.

Do not copy full enemy future-plan telegraphing, timeline prediction, or deckbuilding systems.

## Reopen conditions

Reopen only if evidence shows:

- art consistently overwhelms tactical information;
- 1280×720/mobile loses critical information;
- repeated opponents cannot be distinguished;
- briefing becomes an answer sheet;
- review becomes automatic coaching;
- route becomes a larger meta-game than combat.

## Next state

`VISUAL_UX_REQUIREMENT_COMPLETE / AWAITING_EXPLICIT_ASSET_OR_IMPLEMENTATION_REQUEST`

New image generation still requires an explicit user request. Product mutation still requires a separate implementation request plus fresh Entry Gate verification.
