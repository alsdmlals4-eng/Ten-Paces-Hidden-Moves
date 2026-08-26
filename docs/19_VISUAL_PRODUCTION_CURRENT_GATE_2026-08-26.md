# 십보강호 · Visual Production Current Gate · 2026-08-26

> Current execution contract: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`  
> Current visual production decision: `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`  
> Human-facing owner: exact Project Notion Home / `02 · 비주얼 바이블` / `04 · 에셋 라이브러리`  
> Structured current state: `docs/planning-data/current_visual_production_handoff_20260826.json`

이 문서는 `docs/18_VISUAL_PRODUCTION_HANDOFF_2026-08-25.md`의 승인 Reference Set과 당시 사용자 피드백을 삭제하거나 다시 쓰지 않는다. 8월 25일 문서는 historical visual handoff이고 이 문서는 8월 26일 r5.4 current execution gate다.

## 1. 보존되는 승인 Reference

- `TEN-IMG-001` · 대표 전투 화면 Reference.
- `TEN-VIS-CHAR-MASTER-001` · Character Master Reference.
- `TEN-VIS-A07-CANDIDATE` · 기초 행동 삽화 언어 Reference.
- `TEN-VIS-A01` · 공통 수묵 clean plate Reference.

승인 Reference는 shipping/runtime asset PASS가 아니며 runtime art integration과 Human/device 검증을 자동 포함하지 않는다.

## 2. 2026-08-26 사용자 승인 결과

### `OPPONENT_CHARACTER_MASTER_01` · 도겸

상태: `USER_APPROVED_2026_08_26`.

- generation id: `0d895036-38e6-420e-990f-823353373366`.
- source PNG SHA-256: `efe88bf4aaf7d1773916f151d518cf52508f18a670760f817c4226feb7564f42`.
- Notion `04 · 에셋 라이브러리` preview delivery/readback: `PASS`.
- 역할: `Character Master → Portrait Crop → Combat Full Body → Result Crop → Silhouette → Thumbnail` 파생용 source master.
- runtime source master promotion / Godot integration: `NOT_RUN`.

## 3. Current visual language

> **세계는 저대비 수묵화, 인물은 수묵 선화 × 제한 디더링, 정보는 독립적이고 정제된 전술 UI.**

보호한다.

- 전장이 가장 큰 시각 질량.
- 세로로 긴 7~7.5등신 계열의 반실사 무협 인물.
- `거리 N` 중심, 3/3/4 계획 의미 보존.
- `기초 / 무공 / 절초` 출처 분리.
- Action grid 최대 5×2, 최대 10개 수용.
- 행동/무공 카드에는 실제 카드 소비용 작은 삽화 사용.
- 텍스트·비용·사거리·효과 숫자는 원화가 아니라 Godot UI/data binding이 소유.
- 제한 금색은 선택·확정·절초·결정적 결과에만 사용.
- 상대의 숨은 계획/정답을 색·포즈·연출로 누설하지 않음.

`진행` CTA는 현재 대표 시안의 visual label이다. 기존 전투 의미 계약 `행동계획 잠금`을 바꾸는 runtime semantic Decision은 아직 별도다.

## 4. 이미지 생성 cadence

2026-08-26 r5.4 current execution contract는 다음 Gate를 적용한다.

```text
canon + actual game consumer review
→ text brief
→ 사용자 명시 승인
→ 정확히 1개 결과 생성
→ 사용자 결과 검토
→ 다음 결과를 자동 생성하지 않음
```

2026-08-25의 max-three는 historical cadence이며 current automatic batch 권한이 아니다.

## 5. Consumer-first 제작 원칙

사용자는 2026-08-26 **“설명용 시트가 아니라 실제 게임 소비처가 있는 이미지 기준으로 만든다”**고 명시했다.

따라서 신규 이미지에는 항상 `실제 게임 소비처`가 있어야 한다.

- 설명용/스타일 비교만을 위한 `MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01`은 current production queue에서 제거한다.
- 실제 게임이 atlas/sprite sheet 자체를 소비할 때만 production sheet/atlas를 허용한다.
- 이미지에 소비처가 아직 없다면 먼저 구현/데이터의 소비 계약을 확인하고 생성 여부를 결정한다.
- source master는 파생 제품 자산을 만들기 위한 재사용 원본으로 허용하되 source master 자체를 runtime integration PASS로 간주하지 않는다.

현재 확인한 소비처:

1. **전장 전신 Battler** — `src/combat/combat_character_placeholder.gd`; 현재 enemy texture는 `res://assets/characters/enemy_masked_battler_rgba_v1.png`.
2. **상태 패널 Portrait** — `src/ui/combatant_status_panel.gd`; 현재 enemy portrait는 `res://assets/portraits/enemy_masked_ink_v1.png`.
3. **카드 중앙 삽화** — `src/ui/card_view.gd`의 `CardView.illustration`; `data/cards/basic_cards.json`이 실제 illustration atlas region 소비 계약을 보유한다.

## 6. 다음 정확한 1개 결과

### `DOGYEOM_COMBAT_BATTLER_01` · 도겸 전장용 Battler

**실제 게임 소비처:** `src/combat/combat_character_placeholder.gd`.

**source master:** 사용자 승인 `OPPONENT_CHARACTER_MASTER_01`.

목적:

- 승인된 도겸 디자인을 전장에서 실제로 소비 가능한 전신 자산 계약으로 파생한다.
- 현재 generic enemy battler가 사용하는 전장 크기·발 위치·facing 계보를 따른다.
- 이후 Codex 구현 시 opponent-specific asset routing 대상으로 사용할 수 있는 source를 준비한다.

출력 계약:

- 전신, 머리/손/발 crop 없음.
- enemy 기준 화면 왼쪽을 향하는 방향성에 적합.
- 투명 RGBA background.
- 발 anchor가 안정적으로 잡히는 여백과 바닥 접점.
- 승인 Master의 얼굴/머리, 권객 실루엣, 손목 보호대, 의상 큰 덩어리를 보존.
- UI/text/VFX/무기 추가 없음.

현재 상태: `WAITING_EXPLICIT_USER_GENERATION_APPROVAL`.

## 7. 다음 후보 — 현재 결과 검토 후에만

1. `DOGYEOM_STATUS_PORTRAIT_01` — 동일 Master에서 파생, 실제 소비처 `src/ui/combatant_status_panel.gd`.
2. 개별 무공/절초 카드 삽화 — 반드시 **exact card ID**와 `CardView.illustration` 소비가 확인된 이미지 단위로 제작.
3. Route/Result/Background 계열 — 실제 소비 컴포넌트가 확인된 뒤 제작. 게임이 atlas를 소비하는 경우 production atlas는 허용.

## 8. Evidence ceiling

```yaml
approved_reference_set: PASS_2026_08_25
opponent_character_master_01_generation: PASS_EXACTLY_ONE_2026_08_26
opponent_character_master_01_user_approval: PASS_2026_08_26
opponent_character_master_01_notion_delivery: PASS_2026_08_26
consumer_first_visual_policy: USER_APPROVED_2026_08_26
next_result_generation: NOT_RUN
runtime_source_master_promotion: NOT_RUN
runtime_art_integration: NOT_RUN
windows_visible_human_usability: NOT_RUN
android_actual_device: NOT_RUN
fifteen_opponent_identifiability: NOT_RUN
human_fun_readability_immersion: NOT_RUN
final_vfx_audio: NOT_RUN
```
