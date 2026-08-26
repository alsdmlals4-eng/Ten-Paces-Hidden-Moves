# 십보강호 · Visual Production Current Gate · 2026-08-26

> Current execution contract: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`  
> Human-facing owner: exact Project Notion Home / `02 · 비주얼 바이블` / `04 · 에셋 라이브러리`  
> Structured current state: `docs/planning-data/current_visual_production_handoff_20260826.json`

이 문서는 `docs/18_VISUAL_PRODUCTION_HANDOFF_2026-08-25.md`의 승인 Reference Set과 당시 사용자 피드백을 삭제하거나 다시 쓰지 않는다. 8월 25일 문서는 **historical visual handoff**, 이 문서는 8월 26일 r5.4 계약에 따른 **current execution gate**다.

## 1. 보존되는 승인 Reference

- `TEN-IMG-001` · 대표 전투 화면 Reference.
- `TEN-VIS-CHAR-MASTER-001` · Character Master Reference.
- `TEN-VIS-A07-CANDIDATE` · 기초 행동 삽화 언어 Reference.
- `TEN-VIS-A01` · 공통 수묵 clean plate Reference.

이 Reference들은 2026-08-25 사용자 승인 상태를 유지한다. 승인 Reference는 shipping/runtime asset PASS가 아니며 현재도 runtime art integration과 Human/device 검증을 자동 포함하지 않는다.

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

`진행` CTA는 현재 대표 시안의 visual label이다. 기존 전투 의미 계약 `행동계획 잠금`을 바꾸는 runtime semantic Decision은 아직 별도다.

## 3. 2026-08-25 batch와 2026-08-26 current Gate

2026-08-25 사용자는 당시 Visual-production cadence로 `한번에 3장씩 만들자`를 승인했다. 그 사실과 당시 3개 후보는 역사 evidence로 보존한다.

2026-08-26 r5.4 current execution contract는 더 최신이며 이미지 생성/생성형 편집에 다음 Gate를 적용한다.

```text
canon review
→ text brief
→ 사용자 명시 승인
→ 정확히 1개 결과 생성
→ 사용자 결과 검토
→ 다음 결과를 자동 생성하지 않음
```

따라서 max-three는 삭제된 사용자 피드백이 아니라 **historical cadence**이며 current automatic batch 권한으로 재사용하지 않는다.

## 4. 다음 정확한 1개 결과

### `OPPONENT_CHARACTER_MASTER_01` · Opponent Character Master #01

목적:

- 승인 Character Master 문법을 실제 상대 인물에 적용한다.
- 플레이어 낭인과 다른 얼굴/머리 실루엣·무기·자세·의상 큰 덩어리를 검증한다.
- 이후 상대 15명 Portrait/Combat Set의 반복 생산 기준을 검증한다.

보호:

- 성인 무협 인물, 세로로 긴 반실사 비율.
- 수묵 선화 + 저채도 담채 + 먹의 큰 덩어리.
- 도트/디더링은 가장자리·먹 번짐의 부분 마감 언어.
- 작은 크기에서 얼굴/머리 → 무기 → 자세 → 의상 큰 덩어리 순으로 식별.
- Character Master → Portrait Crop → Combat Full Body → Result Crop → Silhouette → Thumbnail 재사용 가능.

금지:

- 플레이어 Master 얼굴·의상 단순 복제.
- 색상만 바꾼 상대 차별화.
- 상대의 숨은 계획·정답을 포즈·색으로 누설.
- baked-in 게임 텍스트/수치/UI.
- full pixel-art 전환.

현재 상태:

`WAITING_EXPLICIT_USER_GENERATION_APPROVAL`.

이 문서가 존재한다고 이미지 생성 권한이 생기지 않는다.

## 5. 다음 결과 이후 후보

현재 1개 결과를 사용자가 검토한 뒤에만 다음 후보를 다시 고른다.

- `MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01`.
- `TEN_VIS_A04_ROUTE_ICON_SHEET_01`.

이 둘은 현재 자동 연속 생성 queue가 아니다.

## 6. Evidence ceiling

```yaml
approved_reference_set: PASS_2026_08_25
current_r5_4_single_result_generation: NOT_RUN
new_result_user_approval: NOT_RUN
new_result_notion_delivery: NOT_RUN
runtime_source_master_promotion: NOT_RUN
runtime_art_integration: NOT_RUN
windows_visible_human_usability: NOT_RUN
android_actual_device: NOT_RUN
fifteen_opponent_identifiability: NOT_RUN
human_fun_readability_immersion: NOT_RUN
final_vfx_audio: NOT_RUN
```
