# Visual Consumer Asset Production Decision · 2026-08-26

> Decision ID: `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`  
> Status: `USER_APPROVED_CURRENT`  
> Scope: Visual production order and asset eligibility only  
> Product/runtime mutation authority: `false`

## User decision

The user clarified the production rule on 2026-08-26:

> 우리는 설명용 시트가 아니라 **실제 게임 소비처가 있는 이미지** 기준으로 만든다.

This decision supersedes any current queue item whose only purpose is style demonstration, explanatory review, or an isolated illustration sheet without a verified game consumer.

## Adopted policy

`ACTUAL_GAME_CONSUMER_REQUIRED`

Before a new image is generated, the brief must identify:

1. the exact player-visible asset role,
2. an **existing verified game consumer component/data field in the current repository**,
3. the reusable source/master relationship,
4. the intended runtime asset form,
5. the evidence ceiling if runtime integration has not happened yet.

A merely planned future slot is not enough. If the current consumer is still generic rather than opponent-specific, the brief must name the existing slot it can consume through and explicitly keep opponent-specific routing as `NOT_RUN` until implementation. A production atlas or sprite sheet is allowed only when the game itself consumes that atlas/sheet. An explanatory sheet made only to compare style is not a production target.

## Current evidence

### Approved source master

- `OPPONENT_CHARACTER_MASTER_01` · working character `도겸`.
- User approval: `USER_APPROVED_2026_08_26`.
- Generation ID: `0d895036-38e6-420e-990f-823353373366`.
- Source PNG SHA-256: `efe88bf4aaf7d1773916f151d518cf52508f18a670760f817c4226feb7564f42`.
- Notion Asset Library delivery/readback: `PASS`.
- This master is a reusable source, not yet a runtime-consumed product asset.

### Approved combat battler derivative

- `DOGYEOM_COMBAT_BATTLER_01` · transparent RGBA full-body Dogyeom battlefield battler source.
- User approval: `USER_APPROVED_2026_08_26`.
- Generation ID: `79ae965f-6048-48c5-b667-6e9b7a55b68f`.
- Source PNG SHA-256: `064a8772406c743bbe6b252c138b4333c88b00b90a0ba905cce9ea18773539c9`.
- Notion Asset Library delivery/readback: `PASS`.
- Existing consumer slot: `src/combat/combat_character_placeholder.gd` → generic enemy battler texture `res://assets/characters/enemy_masked_battler_rgba_v1.png`.
- Opponent-specific Dogyeom routing: `NOT_RUN`.
- Runtime art integration: `NOT_RUN`.

### Verified game consumers

- Combat full-body battler: `src/combat/combat_character_placeholder.gd` currently loads an enemy battler texture from `res://assets/characters/enemy_masked_battler_rgba_v1.png`.
- Combat status portrait: `src/ui/combatant_status_panel.gd` currently loads an enemy portrait texture from `res://assets/portraits/enemy_masked_ink_v1.png`.
- Card illustration: `src/ui/card_view.gd` renders `definition.illustration`; `data/cards/basic_cards.json` proves the current runtime card contract consumes illustration atlas regions.

## Next production order

1. `DOGYEOM_STATUS_PORTRAIT_01` — completed for the **existing generic enemy status/portrait slot**. `slot1_dogyeom` routing and generic fallback passed automated Godot verification; Windows human visual and Android device evidence remain separate.
2. Individual martial/ultimate card illustrations only when each image is mapped to an actual card ID and `CardView.illustration` consumer path, and a user explicitly selects the concrete asset. Do not generate `MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01` as an explanatory style sheet.
3. Remaining opponent portrait/battler assets only when their source master/identity and actual consumer contract are identified, and a user explicitly selects the concrete asset.
4. Route/result/background visual assets only after their actual in-game consumer is identified. If the game consumes a production atlas, that atlas may be generated/assembled as the deliverable.

The user then directed that future work continue in **GPT Work**. This changes the execution surface, not project authority: the next Work session must fresh-read Project GitHub + exact Project Notion before continuing this queue.

## Alternatives considered

1. Continue with `MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01` as a style sheet — rejected; it creates review material rather than a directly consumed game asset.
2. Generate several unrelated assets to explore the style — rejected; violates the current exactly-one approval cadence and increases orphan-asset risk.
3. Consumer-first derivative pipeline from an approved master — adopted; it minimizes duplicated art work, preserves style consistency, and gives each produced image a concrete existing runtime destination.

## Guardrails

- Current r5.4 cadence remains: `text brief → explicit user approval → exactly one result → user review` whenever generative image work is used.
- Deterministic crop/mask/resample from an approved master is preferred when it satisfies the consumer without a new generated image.
- No automatic next generation.
- No runtime/Godot integration claim until Codex independently implements the approved asset and runtime evidence exists.
- No text, numbers, card rules, or UI baked into illustration pixels unless the consumer explicitly requires image-encoded content.
- Google Sheet remains migration-only and is not repromoted as current visual authority.
