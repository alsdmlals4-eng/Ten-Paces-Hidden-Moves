# DOGYEOM_COMBAT_BATTLER_01 · Codex Execution Report

## 기준

- GitHub Issue: #212
- 기준 main: `b0e40d035629f87ca15874d7e34f8e9ac3aacca9`
- 승인 source SHA-256: `064a8772406c743bbe6b252c138b4333c88b00b90a0ba905cce9ea18773539c9`
- Work mode: `BUILD`

## 수행

1. 사용자 승인 PNG를 `res://assets/characters/dogyeom_combat_battler_01_v1.png`로 등록하고 asset manifest에 provenance와 RGBA audit를 기록했다.
2. `CombatCharacterPlaceholder`이 enemy `candidate_id == "slot1_dogyeom"`일 때만 전용 Battler를 선택하도록 최소 라우팅을 추가했다.
3. 전투판이 `combat_state.enemy.candidate_id`를 Battler 선택에 전달하도록 연결했다.
4. 다른 상대와 candidate ID 누락 상대는 기존 `enemy_masked_battler_rgba_v1.png`를 그대로 사용한다.

## 검증

- `verify_dogyeom_combat_battler.gd`: 전용 라우팅, generic fallback, 발 앵커 PASS.
- `verify_combat_character_art.gd`: 기존 역할별 원화, 발 앵커, 공격 모션 PASS.
- `verify_vertical_slice_combat_bridge.gd`: 고정된 도겸 candidate의 실제 bridge Battler/Portrait 라우팅 PASS.

## 증거 경계

- Windows visible human readability: `NOT_RUN`.
- Android actual device: `NOT_RUN`.
- 나머지 14명 opponent-specific Battler: `NOT_RUN`.
- 전투 규칙, AI, 저장, 레이아웃 의미: 변경하지 않음.

## Rollback

Issue #212에 대응하는 merge PR을 GitHub에서 revert하면 전장 Battler는 기존 generic enemy texture fallback으로 복귀한다.
