# 전투 규칙 개정 — 등급 파밍 방지

- Decision ID: `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`
- 부모 등급 권위: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
- 상태: `CURRENT_APPROVED_PLANNING_GOVERNANCE`
- 구현 권한: `PLANNING_ONLY`

## 1. 적용 범위

이 개정은 전투 종료 등급의 유효 입력 집계에만 적용한다. 전투 판정·피해·합·회피·중단·관찰·AI·절초기세·원시 로그·복기는 변경하지 않는다.

## 2. 원시 사건

```yaml
successful_dodges_record_all: true
clash_wins_record_all: true
player_health_lost_records_all: true
rounds_elapsed_records_all: true
ultimate_uses_record_all: true
```

원시 사건은 UI·복기·디버그·통계 증거다. 등급 감쇠 때문에 삭제·합치기·변경하지 않는다.

## 3. 안정 ID와 행동 인스턴스

```text
canonical_source_id = source_type + ":" + source_id
action_instance_id = enemy_action_instance_id
```

- hit index는 별도 source ID가 아니다.
- 준비·스탯·거리·방향·대상·임시 보정·표시명은 source ID를 바꾸지 않는다.
- 같은 source ID의 성공 대응 인스턴스 순서에 `1.0→0.5→0.0`을 적용한다.

## 4. 합·회피 유효 반영량

```text
pool = repeat_multiplier
qualifying_events = CLASH_WIN + DODGE_SUCCESS in one enemy action instance
per_event_credit = pool / len(qualifying_events)
```

- 행동 인스턴스당 합·회피 합계 최대 1.0.
- 세 번째 같은 source ID 성공 대응부터 양의 반영량 0.
- 원시 합·회피 횟수는 계속 증가한다.
- 합 유효 반영량 상한 3.0, 회피 유효 반영량 상한 3.0.

## 5. 기준 라운드

```yaml
encounter_field: grade_target_rounds
minimum: 1
poc_default: 3
eligible: round_index <= grade_target_rounds
```

기준 라운드 뒤에는 합·회피·유효 절초의 양의 반영량을 추가하지 않는다. 원시 사건·체력 손실·라운드 수는 계속 기록한다.

## 6. 절초 유효 반영량

전투당 최대 첫 유효 절초 1회만 반영한다.

```text
legal resolution
AND within scoring window
AND one non-cost result applied
```

비비용 결과는 체력 피해·회복·강제 이동·상태 적용·공격 중단·유리한 자원 변화다. 비용 지불·예약만으로는 반영하지 않는다.

## 7. 결과 데이터 최소 필드

```text
raw_successful_dodges
raw_clash_wins
raw_player_health_lost
raw_rounds_elapsed
raw_ultimate_uses
effective_dodge_credit
effective_clash_credit
effective_ultimate_credit
grade_target_rounds
```

최종 가중치·체력 정규화·라운드 감점·S/A/B/C 컷은 이 개정이 소유하지 않는다.

## 8. 경제·재도전

- 시도별 독립 집계.
- 실패·포기 시도 사건의 다음 시도 합산 금지.
- 사람 검증 전 등급 기반 회차 재화·수련·드롭·영구재화·환불 보정 금지.
- 보상 연결과 수치 변경은 별도 Decision 필요.

## 9. 검증

1. 같은 source ID 첫·둘째·셋째 성공 인스턴스 pool이 1.0·0.5·0.0.
2. 한 인스턴스의 합·회피 여러 사건 합계가 pool 이하.
3. 연격 hit index가 반복 횟수를 우회하지 않음.
4. 기준 라운드 뒤 양의 반영량0, 원시 사건·손실·라운드 기록 유지.
5. 절초 여러 번 사용에도 유효 반영 최대1.
6. 결과 화면이 원시 횟수와 유효 반영량을 구분.
7. 경제 연결 없음.

```yaml
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
balance_validation: NOT_RUN
```
