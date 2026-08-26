# 십보강호 · Visual Production Current Gate · 2026-08-26

> Current execution contract: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`  
> Current visual Decisions: `TEN-DEC-20260826-OPPONENT-CHARACTER-MASTER-01-APPROVAL-01` / `TEN-DEC-20260826-RUNTIME-CONSUMER-FIRST-VISUAL-ASSET-01`  
> Human-facing owner: exact Project Notion Home / `02 · 비주얼 바이블` / `04 · 에셋 라이브러리`  
> Structured current state: `docs/planning-data/current_visual_production_handoff_20260826.json`

이 문서는 2026-08-25 승인 Reference Set을 보존하면서 2026-08-26 r5.4 exact-one gate와 최신 사용자 승인인 **실제 게임 소비처 기준 이미지 제작**을 현재 실행 규칙으로 둔다.

## 1. 보존되는 승인 Reference / Source Master

- `TEN-IMG-001` · 대표 전투 화면 Reference.
- `TEN-VIS-CHAR-MASTER-001` · Character Master style Reference.
- `TEN-VIS-A07-CANDIDATE` · 기초 행동 삽화 언어 Reference.
- `TEN-VIS-A01` · 공통 수묵 clean plate Reference.
- `OPPONENT_CHARACTER_MASTER_01` · 도겸 Character Master · `USER_APPROVED_SOURCE_MASTER`.

도겸 승인 preview: `docs/visual-reference/OPPONENT_CHARACTER_MASTER_01_APPROVED_PREVIEW.svg`.

승인 Reference/Source Master는 shipping/runtime asset PASS가 아니다. runtime source promotion, runtime art integration, Human/device PASS는 별도 evidence가 필요하다.

## 2. Current visual language

> **세계는 저대비 수묵화, 인물은 수묵 선화 × 제한 디더링, 정보는 독립적이고 정제된 전술 UI.**

보호한다.

- 전장이 가장 큰 시각 질량.
- 세로로 긴 7~7.5등신 계열의 반실사 무협 인물.
- `거리 N` 중심, 3/3/4 계획 의미 보존.
- `기초 / 무공 / 절초`의 출처 분리.
- Action grid 최대 5×2, 최대 10개 수용.
- 행동/무공 카드의 작은 삽화.
- 텍스트·비용·사거리·효과 숫자는 원화가 아니라 Godot UI/data binding이 소유.
- 제한 금색은 선택·확정·절초·결정적 결과에만 사용.
- 상대의 숨은 계획/정답을 색·포즈·연출로 누설하지 않음.

## 3. 생성 단위 · 실제 게임 소비처 우선

`TEN-DEC-20260826-RUNTIME-CONSUMER-FIRST-VISUAL-ASSET-01`에 따라 신규 생성 단위는 **실제 게임 소비처가 있는 이미지**다.

현재 확인된 직접 소비처:

- `src/combat/combat_character_placeholder.gd` → Combat battler PNG.
- `src/ui/combatant_status_panel.gd` → 상태패널 Portrait PNG.
- `src/ui/card_view.gd` → 카드 데이터의 `illustration` atlas region.
- `data/cards/basic_cards.json` → 현재 카드 illustration region `240×270` 사용례.
- `assets/ASSET_MANIFEST.json` → active runtime visual asset provenance.

따라서 다음은 생성 단위로 세지 않는다.

- runtime이 직접 소비하지 않는 설명용/컨셉용 martial-technique sheet.
- runtime이 직접 소비하지 않는 route-icon 설명 sheet.
- 화면을 설명하기 위한 composite mock sheet.

필요한 무공 삽화·Route icon 요구 자체는 유지한다. 단, 실제 `card_id`·Route component·atlas/cell 등 **구체 소비처에 바인딩된 자산**으로 다시 정의한 뒤 생성한다.

Character Master는 `SOURCE_MASTER`로 허용하지만 runtime asset PASS로 세지 않는다.

## 4. r5.4 exact-one Gate

```text
canon + actual consumer review
→ exact runtime-consumer asset text brief
→ 사용자 명시 승인
→ 정확히 1개 결과 생성
→ 사용자 결과 검토
→ 승인 시 Notion delivery + provenance/canon sync
→ 다음 결과를 자동 생성하지 않음
```

## 5. 최신 승인 결과

### `OPPONENT_CHARACTER_MASTER_01` · 도겸

Status: `USER_APPROVED_SOURCE_MASTER`.

승인 의미:

- 도겸의 얼굴/머리 실루엣, 묵직한 권객 체형, 손·팔 보호대, 중립 비무 준비 자세, 저채도 수묵 선화를 동일 인물 파생 기준으로 사용.
- `Portrait → Combat battler → Result crop → Silhouette → Thumbnail`의 identity consistency owner.

아직 승인되지 않은 것:

- 최종 투명 RGBA Combat battler.
- 상태패널 Portrait.
- runtime asset mapping/integration.

## 6. 다음 정확한 1개 결과

### `TEN-VIS-A03-SLOT1-DOGYEOM-BATTLER-01` · Dogyeom Combat Battler #01

목적:

- 도겸 Source Master를 실제 전투 소비 자산으로 변환한다.
- Godot 전장 character consumer에서 쓸 수 있는 투명 배경 전신 battler 규격을 검증한다.
- 전투 보드의 발 위치·축소 실루엣·facing에서 읽히는지 검증한다.

Target consumer:

`src/combat/combat_character_placeholder.gd` / 이후 `slot1_dogyeom` character-art binding.

Target role:

`COMBAT_BATTLER_RGBA`.

Current status:

`WAITING_EXPLICIT_USER_GENERATION_APPROVAL`.

다음 후보는 도겸 상태패널 Portrait이며, 이후 카드 삽화는 실제 `card_id` 예: `beggars_dragon_subduing_palm_star3`에 연결된 소비 자산으로 만든다.

## 7. Evidence ceiling

```yaml
approved_reference_set: PASS_2026_08_25
opponent_character_master_01_generation: PASS_2026_08_26
opponent_character_master_01_user_approval: PASS_2026_08_26_SOURCE_MASTER_ONLY
opponent_character_master_01_notion_delivery: PENDING_POSTMERGE_READBACK
runtime_source_master_promotion: NOT_RUN
runtime_art_integration: NOT_RUN
windows_visible_human_usability: NOT_RUN
android_actual_device: NOT_RUN
fifteen_opponent_identifiability: NOT_RUN
human_fun_readability_immersion: NOT_RUN
final_vfx_audio: NOT_RUN
```
