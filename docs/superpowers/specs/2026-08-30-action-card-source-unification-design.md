# Action Card Source Unification Design

**Decision:** `TEN-DEC-20260830-ACTION-CARD-SOURCE-UNIFICATION-01`
**Approval:** `USER_EXPLICIT_20260830: 확정`
**Baseline:** `origin/main` `0b2ab3fe64a8325b52b743c8d9da03cb23646b3f`

## Goal

Replace the three inconsistent action-source presentations and the old board-tile direction picker with one readable, responsive card-selection experience that preserves the combat engine's existing tactical meaning.

## Player flow

```text
기초 / 무공 / 절초 탭
→ 공통 행동 카드 격자에서 행동 선택
→ 현재 묶음의 가장 앞 유효 연속 슬롯에 배치
→ 필요한 경우 같은 독의 의도 카드 선택
→ 3/3/4 계획 검토
→ 행동계획 실행
→ 순차 공개·합·복기
```

### Action cards

`ActionChoiceCard` is a reusable button view. It receives normalized view data and renders the same semantic fields for every source. `art_mode` is `basic_atlas` only for basic actions; it is `none` for martial, ultimate and intent cards.

| source | card collection | art mode | source-only state |
| --- | --- | --- | --- |
| `basic` | current 10 actions | `basic_atlas` | existing approved atlas crop |
| `martial` | selected manual's unlocked/locked techniques | `none` | manual, mastery and unlock reason |
| `ultimate` | base and 10-star ultimates | `none` | momentum, reservation and lock reason |
| `intent` | move or aim follow-up choices | `none` | intended distance or prediction meaning |

The manual selector remains above the martial card grid because it selects a source collection, not an action to place.

### Intent cards

| originating action | card examples | stored UI intent | resolver normalization |
| --- | --- | --- | --- |
| move range 1 | `접근 1칸`, `후퇴 1칸` | `approach` / `retreat`, `steps: 1` | relative sign and bounded destination |
| move range 2 | above plus `접근 2칸`, `후퇴 2칸` | `approach` / `retreat`, `steps: 2` | relative sign and bounded destination |
| attack | `상대를 노림`, `반대 예측` | `toward_enemy` / `away_from_enemy` | planned directional sign |

The selection dock owns only intent choice and emits an already-normalized placement request. `ActionTimingPanel` owns slot readiness. `CombatResolutionEngine` remains the owner of range, collision, miss and damage resolution.

## Non-goals

- No generated image, new artwork or alteration to approved character/background/basic-atlas assets.
- No combat formula, AI private-information, save format, deck/hand/draw, 3/3/4 or ultimate-economy change.
- No human-player, Android-device, accessibility-user or release-performance pass claim.

## Migration rule

Product surfaces must stop consuming `data/combat/action_selection_poc.json`, `select_destination_board_tile`, `select_left_or_right_direction`, `move_tile`, `attack_direction`, and the hidden legacy basic/ultimate selection UI. Unique fixture evidence may remain only in a clearly test-only fixture if an affected engine regression needs it; product code, active data and player-facing logs must not depend on it.
