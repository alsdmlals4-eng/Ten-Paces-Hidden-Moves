# 전투 사건의 안정 행동 ID 판별 결정

- Decision ID: `TEN-DEC-20260802-THREAT-ID-ACTION-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING_LOG_IDENTITY`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 역사적 선행: `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01`
- 현재 평가 정본: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`

## 1. 승인 결론

전투 로그·복기·통계에서 공격 행동의 정체성은 정확한 안정 ID로 판별한다.

```text
기초 행동 → basic_action_id
무공 기술 → technique_id
절초 → ultimate_technique_id
정규화 ID → source_type + ':' + source_id
```

- 같은 속공 ID는 같은 행동 정체성이다.
- 같은 장풍 ID는 같은 행동 정체성이다.
- 같은 무공 기술 ID는 같은 행동 정체성이다.
- 서로 다른 기술 ID는 공개 종류가 모두 `[공격]`이어도 서로 다르다.
- 기초 속공과 별도 속공계 무공 기술은 다른 ID다.

## 2. ID를 바꾸지 않는 요소

- 현재 스테이터스 차이
- `[준비]` 강화 적용 여부
- 일시적인 피해·사거리 보정
- 현재 거리·방향·대상
- 자원 잔량·비용 할인
- 같은 기술의 성취 patch
- 임시 버프·디버프
- 표시명·번역 변경

구조가 영구 개편되어 새 정식 데이터 ID를 받았을 때만 별도 행동으로 취급한다.

## 3. 현재 전투 종료 등급과의 관계

- 현 5지표 등급은 실제 `합 승리 횟수`를 원자료로 기록한다.
- 같은 행동 ID라는 이유로 현재 합 승리 횟수를 100%→50%→0% 감쇠하지 않는다.
- 안정 ID는 복기·디버깅·통계와 향후 별도 승인될 파밍 방지 산식에 사용할 수 있다.
- 모든 `[공격]`을 하나의 ID로 묶지 않는다.

## 4. 연격·복합 행동

- `[연격]`의 hit index는 별도 행동 ID가 아니다.
- 한 공격 효과의 첫 피해 단위와 후속 피해 단위는 같은 source ID를 공유한다.
- 하나의 복합 기술에 독립 공격 효과가 여러 개 있다면 데이터가 각 공격 효과의 parent action ID와 effect index를 기록할 수 있으나, 기술 정체성은 원본 technique ID를 유지한다.

## 5. 검증 요구

1. 같은 기초 속공이 동일 정규화 ID로 기록됨.
2. 기초 속공과 별도 무공 기술은 다른 ID임.
3. 준비·스테이터스·거리 변화가 ID를 바꾸지 않음.
4. 표시명 변경이 ID를 바꾸지 않음.
5. 연격 hit index가 새 행동 ID를 만들지 않음.
6. 현재 전투 종료 합 승리 횟수에 반복 감쇠가 적용되지 않음.

## 6. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING_LOG_IDENTITY
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
identity_basis: EXACT_CANONICAL_ACTION_OR_TECHNIQUE_ID
name_used_as_identity: false
public_category_used_as_identity: false
temporary_modifiers_create_new_identity: false
multi_hit_subpacket_creates_new_identity: false
current_battle_grade_repeat_attenuation: false
future_anti_farming_input_allowed_with_new_decision: true
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 5/10
```
