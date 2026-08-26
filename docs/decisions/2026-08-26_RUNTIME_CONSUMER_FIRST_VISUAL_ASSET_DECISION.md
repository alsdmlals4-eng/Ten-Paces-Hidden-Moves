# TEN-DEC-20260826-RUNTIME-CONSUMER-FIRST-VISUAL-ASSET-01

Status: APPROVED  
Date: 2026-08-26  
Approval source: user explicit — `우린 '설명용 시트'가 아니라 “실제 게임 소비처가 있는 이미지” 기준으로 만드는거야.`

## Decision

십보강호의 신규 이미지 생성 우선순위와 작업 단위는 **설명용/컨셉용 시트가 아니라 실제 게임 소비처가 있는 이미지 자산**을 기준으로 한다.

- 생성 대상은 실제 Godot UI/Combat/Route/VFX 소비처 또는 그 소비처에 바로 연결될 final source asset이어야 한다.
- 여러 이미지를 한 장에 모은 설명용 sheet는 그 sheet 자체를 runtime이 소비하지 않는 한 신규 생성 우선순위에서 제외한다.
- Character Master는 반복 생산과 일관성을 위한 `SOURCE_MASTER`로 보존할 수 있으나, 이것만으로 runtime asset PASS를 주장하지 않는다.
- 실제 제품 자산은 예: Combat battler, 상태패널 Portrait, `CardView`가 소비하는 카드 illustration cell/atlas input, Route icon, battle background, runtime VFX frame/sprite 등으로 정의한다.
- 카드 삽화는 실제 데이터의 card id와 `illustration` consumer contract에 연결한다. generic martial-technique explanation sheet를 제품 자산으로 세지 않는다.
- 현재 r5.4 visual gate는 그대로 유지한다: text brief → 사용자 명시 승인 → 정확히 1개 결과 → 사용자 결과 검토.

## Current runtime evidence

- `src/combat/combat_character_placeholder.gd` consumes enemy/player battler PNG.
- `src/ui/combatant_status_panel.gd` consumes enemy/player portrait PNG.
- `src/ui/card_view.gd` consumes card `illustration` atlas regions.
- `data/cards/basic_cards.json` demonstrates actual 240×270 illustration regions.
- `assets/ASSET_MANIFEST.json` records active runtime visual assets and provenance.

## Immediate consequence

`MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01` and `TEN_VIS_A04_ROUTE_ICON_SHEET_01` are retired as *generation-unit names*. Their underlying needs remain, but future generation units must be bound to concrete runtime consumers.

After approved `OPPONENT_CHARACTER_MASTER_01`, the next proposed generation unit is `TEN-VIS-A03-SLOT1-DOGYEOM-BATTLER-01`, a combat battler source for the Slot 1 Dogyeom opponent. The next candidate after that is the corresponding status-panel Portrait. Card art later targets concrete card IDs such as `beggars_dragon_subduing_palm_star3`, not an explanatory martial-art sheet.

## Evidence ceiling

This Decision changes production targeting only. It does not claim runtime integration, source-master promotion, Windows visible usability, Android device PASS, or Human/player PASS.
