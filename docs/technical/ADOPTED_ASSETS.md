# Adopted Assets

이 문서는 프로젝트에 실제 채택된 Godot 애드온·상용 플러그인·아트·오디오 자산의 정본 목록이다.

## 정책

- 직접 제작 전에 Base Skill `evaluating-godot-assets-and-plugins-before-creation`을 route한다.
- 조사 후보는 채택과 구분한다.
- 사용자 승인 없는 구매·설치·계정 연결은 채택으로 기록하지 않는다.
- 버전, 원본, 라이선스, 수정 내역, 검증, 제거 방법을 기록한다.

## 현재 채택 목록

현재 이 작업으로 새로 설치하거나 구매한 제3자 자산은 없다.

### 전투 피드백 원본 합성음

`TEN-DEC-20260909-COMBAT-FEEDBACK-CORRECTION-01`은 기존 `src/ui/combat_sound_bank.gd`의 결정적 합성기를 재사용한다. 새 외부 라이브러리·녹음·샘플·멜로디·음성·계정·비용을 도입하지 않았다. 제작 경로는 repository code-authored procedural audio이며 새 cue는 `victory`, `draw`, `ultimate_release`다. 원본은 해당 스크립트의 커밋 이력·합성 매개변수이며 consumer는 `CombatBoardPreview._play_procedural_sfx`의 기존 두 AudioStreamPlayer다.

세 cue는 22050Hz/16-bit mono, 합계 49,392 bytes의 PCM으로 생성·캐시된다. 기존 9개 cue bytes는 native 비교로 보존했다. 재사용·유한 길이·음소거·결과 연결은 자동 검사 대상이며, 청음 선호·최종 믹싱·출시 권리/마케팅 승인은 별도 `NOT_RUN`이다. 원본 코드 기여의 권리와 release gate가 완료됐다고 이 목록만으로 선언하지 않는다. 교정/rollback은 스크립트의 정상 버전관리로 수행하며 사용자 저장을 변환하지 않는다.

기존 `assets/vfx/ultimate_ink_gold_sprite_sheet_rgba.png`는 세 band를 새 consumer에 명시 연결하는 재사용이다. 새 이미지를 생성하거나 원본/승인 상태를 바꾸지 않았다. 기존 provenance는 `docs/operations/2026-08-31_FRONTAL_DUEL_FEEDBACK_EXECUTION_REPORT.md`, 현재 연결 규칙은 feedback Decision에서 확인한다. 각 기술의 독립적인 새 원화·VFX 품질 승인으로 간주하지 않는다.
