# 전투 결과·10성 절초 피드백 정합성 교정

```yaml
decision_id: TEN-DEC-20260909-COMBAT-FEEDBACK-CORRECTION-01
status: APPROVED_SCOPE_RECOMMENDED_IMPLEMENTATION
authority: CURRENT_USER_CONTINUOUS_BLUEPRINT_IMPLEMENTATION_AND_CORRECTION
baseline: fe720f5dce686ea5b2ff68a1ec078d53544a0e92
stage: SPECIFIED
implementation_state: NOT_STARTED
CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF: REQUIRED
research: docs/reviews/2026-09-09_COMBAT_FEEDBACK_BENCHMARK.md
```

## 책임과 보호 범위

승인 Blueprint의 ‘확정 결과 비교 → 해당 합/회피/절초 연출 → 전투 종료 → 강호행로’를 현재 Godot에 정확히 연결한다. 별도 복기 화면을 복원하거나 새 보상을 만들지 않는다. `docs/10_COMBAT_PRESENTATION_PLAN.md`, `docs/UX_UI_SYSTEM.md`, 기존 audio pipeline 설계를 구체화하는 작은 구현 계약이다.

- 전투 판정·피해·기세·비용·무공서 수치·AI 정보 경계·3/3/4·10전/36행로는 불변이다.
- 저장 schema 1 및 `ten-duel-four-route-one-retry-bimu-actor-bound-save-v1`은 불변이다.
- 화면은 기존 상태/확정 사건을 소비한다. 승패 공식은 도메인 함수 한 곳이 소유하고 board와 run bridge가 함께 소비한다.
- 기존 승인 image/atlas/PDF bytes는 불변이다. 새 raster 생성/등록은 이 교정에 필요하지 않다.
- 모션 감소·음소거·skip·일시중단·COMMITTED/RESOLVED 복원은 기존 결과와 상태를 보존한다.
- Human/UX, 가청 선호, 실제 Android·보조기기·Release performance는 자동 검사로 승인하지 않는다.

## 1. 종료 결과

기존 bridge의 분기 그대로 도메인 `CombatResolutionEngine.battle_outcome(state: Dictionary) -> String`에 이관한다. 적 체력 0 이하/플레이어 생존은 `win`, 그 반대는 `loss`, 나머지는 `draw`. 호출 화면은 기존 terminal 조건을 그대로 사용한다. ongoing을 terminal로 바꾸지 않는다.

board와 bridge는 이 함수를 소비하고 동일한 outcome을 쓴다. 종료 cue는 `win → victory`, `loss → defeat`, `draw → draw`; 텍스트는 각각 `승리 · 결전 종료`, `패배 · 결전 종료`, `무승부 · 결전 종료`. 종료 로그도 같은 결과를 표시한다. terminal signal/결과 확인/보상/저장은 중복 발행하지 않는다.

`CombatSoundBank`의 기존 결정적 synthesis를 재사용한다. 원본 authored cue `victory=[0.46,523.25,0.03]`, `draw=[0.36,220.0,0.04]`, `ultimate_release=[0.30,165.0,0.26]`를 추가한다. victory는 상승 sweep, draw는 고정 pitch, release는 기존 하강 envelope를 쓴다. 기존 cue PCM 변경 금지. 22050 Hz/16bit mono, peak clamp, 짧은 envelope, lazy cache와 기존 prewarm/두 player/volume/mute 경로를 유지한다. 세 cue의 원본은 코드이며 외부 녹음/비용/추가 middleware가 없다. 이 수치는 되돌릴 수 있는 구현 기본값이지 사람에게 최종 음질 승인을 받은 수치가 아니다.

## 2. actor-owned 10성 절초

board가 해당 사건 actor의 `get_actor_card_definition(card_id, actor)`로 읽은 정의만 분류한다. `source=ultimate` 또는 `source_kind=ultimate`일 때만 절초다. ID 접두사/접미사, opponent union, UI 미확정 선택을 권위로 사용하지 않는다. 미보유/위조 ID는 절초 연출을 얻지 않는다.

`src/ui/combat_presentation_profile.gd`는 정의와 이미 해결된 사건을 입력으로 받는 작은 순수 표현 helper다. 판정 상태를 변경하거나 효과 프로그램을 실행하지 않는다. duration/windup/motion/feedback/VFX/SFX의 판별이 이 helper를 공유한다.

분류 우선순위:

1. 실제 `type=clash` 또는 `outcome=clash_*`는 기존 합 연출을 유지한다.
2. `interrupted`, `miss_direction`, `miss_range`, `move_invalid`, `martial_failed`는 실패/중단 label을 우선하며 성공 절초의 큰 VFX·공격 motion을 내보내지 않는다. 실제 양수 damage가 포함된 부분 실행 실패는 그 피해 사실을 텍스트/피격으로 보존하되 전체 절초 성공으로 포장하지 않는다.
3. 이 사건의 **대상**이 회피/방어한 `defense_outcome=evade/block` 또는 동등한 outer outcome은 방어 피드백이 우선이며, 피해 없는 회피에 hit sound를 내보내지 않는다. 행동자 자신의 `evade_succeeded`는 상대 회피가 아니므로 상대에게 회피 모션을 주지 않는다. 다단 martial program의 일부 `BLOCKED`만으로 전체를 방어 성공으로 축약하지 않는다. 완료된 program에 실제 양수 aggregate damage가 있으면 일부 막힘과 관계없이 실제 피해와 정상 절초 강조를 보존한다. 실제 damage가 0이고 시도된 ATTACK가 전부 BLOCKED라면 방어 outcome으로 표시한다.
4. 정상 절초 실행은 `ultimate`; 공격 절초 및 실제 반격 피해가 있는 대응 절초만 공격형 ultimate motion을 사용한다. 회복/피해 없는 대응은 제자리 self VFX+기술 이름으로 표현한다. `martial_events`의 SPECIAL_CLASH는 내부 효과 사실이며 outer clash로 승격하지 않는다. requirement가 실패해 counter가 건너뛰어진 완료 program은 `조건 미충족`을 표시하고 공격 성공 motion/impact를 내보내지 않는다. 이미 적용된 자기 상태 효과까지 실패로 되돌렸다고 표현하지 않는다.
5. 일반 공격·일반 utility는 기존 동작/분류를 유지한다.

현재 `resolved_actions`가 가진 `failure_reason`, `martial_events`, `actual_hp_hits`, `clash_won`, `evade_succeeded`를 transient presentation event로 그대로 deep-copy 전달할 수 있다. 이 projection은 이미 확정된 정보만 표현하며 도메인 재계산/전투 상태 변경이 아니다. DTO schema에 새 필드를 추가하거나 RESOLVED 복원에 이벤트를 다시 실행하지 않는다.

성공 절초의 기본 duration은 기존 0.70초, 합은 0.34초, fast/reduced-motion 상한은 기존값을 보존한다. 실패/방어는 기존 짧은 사건 duration을 사용한다. 성공 절초에는 기존 impact 우선순위 이후 `ultimate_release`를 사용하되, 실제 합/회피/중단 cue를 덮어쓰지 않는다.

## 3. 기존 승인 VFX의 명시적 재사용

기존 `assets/vfx/ultimate_ink_gold_sprite_sheet_rgba.png`의 세 band를 유지한다. 이것은 새 고유 절초 art 제작이 아니라 현재 reusable energy VFX의 연결이다. 원본 이미지의 생성·사용자 lock·rights 상태를 재승격하지 않는다.

| 기존/무공서 | band | 표현 anchor |
|---|---:|---|
| 기본 십보 유파 | 0 | 기존 impact |
| 기본 단악결 | 1 | 기존 impact |
| 기본 파공검기 | 2 | 기존 impact |
| 강룡장결 / 나한금강공 | 0 | impact |
| 매화검결 / 팽가도결 | 1 | impact |
| 창궁무애검법 / 천기암기록 / 양가창결 | 2 | impact |
| 자하심법 | 0 | actor/self |
| 태극검결 | 0 | 실제 반격 피해가 있으면 impact, 없으면 actor/self |
| 소요보결 | 2 | 실제 반격 피해가 있으면 impact, 없으면 actor/self |

알 수 없는 정의/없는 texture는 label과 기존 결과 strip을 남기며 fail-safe로 VFX를 숨긴다. 미래 미등록 무공서에 임의 band를 추정하지 않는다. 원본 대신 primitives로 illustration을 만들지 않는다.

## 4. acceptance·검증·rollback

- RED→GREEN: 실제 승리의 기존 defeat 기대를 새 승리 기대와 비교하여 원 결함을 재현한다. win/loss/draw 전부 domain/board/bridge 일치, 이미 지급된 결과 중복 없음.
- 10종 전부 actor-owned star10, star7, 상대만 보유, 위조 ID, 7 attack/2 response/1 recovery, 실패/회피/합 counterexample.
- 실제 resolver로 도달 가능한 공격·회복·태극 대응 및 현재 소요의 조건 미충족 경로를 검증한다. 소요 성공 반격은 현재 `_run_martial_pipeline`가 `evade_succeeded`를 공급하지 않아 도달할 수 없다. 성공 자기 회피+반격의 순수 profile counterexample는 합성 표현 계약 검사로 명시하고 실제 gameplay PASS로 기록하지 않는다. 이 도메인 누락은 다음 전투 규칙 교정에서 실제 RED를 재현해 별도 책임 계약으로 처리한다.
- 실제 resolver event에서 projection deep-copy와 기존 combat state/logs/locks/DTO equality를 확인한다. 테스트가 UI convenience data를 만들어 product 흐름 검증인 것처럼 주장하지 않는다.
- 기존 ultimate/clash/game-feel/inline-result/actor-bound save 회귀와 전체 Python suite. 실제 native 화면에서 공격 절초, 회복 절초, 합, 회피, 승/패/무승부 capture를 별도 장면으로 기록한다. 테스트 fixture는 일반 캠페인 플레이의 성장 해금 증거가 아니다.
- sound PCM의 길이·유한 값·크기/범위·cue별 상이함·cache reuse·mute 경로 검사. test 종료는 실제 자연 종료 또는 bounded audio mixer-release condition; 무한 대기/고정 sleep/경고 숨김 금지.
- 마지막 green commit을 되돌리는 정상 revert가 rollback이며 저장 migration·art 교체가 없으므로 기존 actor-bound 파일은 그대로 읽는다.

후속 성장 지출·사건표/선택·정탐 단계·등급/행운/금전 보상·고유 적 art·가청 polish·화면 크기 개선은 별도 현재 작업으로 계속한다. 이 계약 통과만으로 전체 Blueprint를 완료라 하지 않는다.
