# 전투 종료 등급 파밍 방지 결정

- Decision ID: `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`
- 승인일: 2026-08-05
- 상태: `CURRENT_APPROVED_PLANNING_GOVERNANCE`
- 위험 상태: `MITIGATED_PENDING_HUMAN_MEASUREMENT`
- 구현 권한: `PLANNING_ONLY`
- 활성 승인 배치: `9/10`
- 선행 권위:
  - `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`
  - `TEN-DEC-20260802-THREAT-ID-ACTION-01`
  - `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
  - `TEN-DEC-20260805-OBSERVATION-ANSWER-LEAK-GUARDRAILS-01`

## 1. 승인 결론

기존 전투 종료 등급의 다섯 원자료를 유지한다.

1. 회피 성공 횟수
2. 합 승리 횟수
3. 플레이어가 잃은 체력
4. 전투 라운드 수
5. 절초 사용 횟수

전투 판정·원시 로그·복기에는 실제 사건을 모두 기록한다. 등급 계산에는 별도의 `유효 등급 반영량`을 사용해 반복 행동, 연격 다중 사건, 기준 라운드 이후 지연, 무효 절초 사용의 파밍을 제한한다.

## 2. 원시 사건과 등급 반영량 분리

다음은 감쇠하지 않는다.

- 실제 합 승리 사건
- 실제 회피 성공 사건
- 잃은 체력
- 실제 라운드 수
- 실제 절초 사용
- 완전·부분 파훼 로그
- 절초기세와 `ON_CLASH_WIN`
- 리플레이·디버그·통계 원자료

감쇠와 상한은 오직 전투 종료 등급의 유효 입력에만 적용한다.

## 3. 반복 행동 감쇠

적 공격 행동의 정체성은 `source_type:source_id` 안정 ID를 사용한다. 같은 안정 ID의 공격 행동 인스턴스를 성공적으로 대응한 순서에 따라 다음 배수를 적용한다.

| 같은 안정 ID의 성공 대응 순서 | 등급 반영 배수 |
|---:|---:|
| 첫 번째 | 1.0 |
| 두 번째 | 0.5 |
| 세 번째 이후 | 0.0 |

과거 위협 대응 점수 체계의 `100%→50%→0%` 후보를 새 5지표 집계 권위 아래 제한적으로 재사용한다. 과거 Decision 자체를 현행 등급 공식으로 복원하지 않는다.

## 4. 공격 행동 인스턴스 상한

한 적 공격 행동 인스턴스의 합 승리와 회피 성공을 합친 등급 반영량은 최대 1.0이다.

```text
instance_credit_pool = repeat_multiplier
qualifying_event_credit = instance_credit_pool / qualifying_event_count
```

예시:

```text
첫 번째 같은 공격 행동에서 합 1회 + 회피 1회
→ 총 pool 1.0
→ 합 0.5, 회피 0.5

두 번째 같은 공격 행동에서 합 3회
→ 총 pool 0.5
→ 각 합 1/6, 합계 0.5
```

연격 hit index, 임시 스탯, 준비 강화, 거리, 방향, 대상, 표시명은 새 행동 정체성을 만들지 않는다.

## 5. 지표별 상한

PoC 초기 기본값:

```yaml
clash_credit_cap: 3.0
dodge_credit_cap: 3.0
normalized_clash_input: min(total_clash_credit, 3.0) / 3.0
normalized_dodge_input: min(total_dodge_credit, 3.0) / 3.0
```

이는 최종 가중치나 S/A/B/C 컷이 아니다. 최종 가중치·체력 손실 정규화·라운드 감점·등급 컷은 후속 Decision이다.

## 6. 기준 라운드

각 상대 데이터는 `grade_target_rounds >= 1`을 가질 수 있다. 개별 값이 없을 때 PoC 기본값은 3라운드다.

```text
round_index <= grade_target_rounds
→ 합·회피·유효 절초 양의 반영량 획득 가능

round_index > grade_target_rounds
→ 원시 사건은 계속 기록
→ 합·회피·절초의 새 양의 반영량은 0
→ 체력 손실·라운드 수는 계속 기록
```

전투를 일부러 늘여 양의 사건을 추가하는 이익을 차단하되, 실제 전투 경과와 손실을 숨기지 않는다.

## 7. 절초 반영

원시 절초 사용 횟수는 모두 기록한다. 기준 라운드 안에서 합법적으로 해결되고 실제 비비용 효과를 낸 첫 절초 1회만 등급에 반영한다.

유효 효과:

- 체력 피해
- 회복
- 강제 이동
- 상태 적용
- 공격 중단
- 유리한 자원 변화

비용 지불·예약·환불만 발생한 사용은 유효 절초가 아니다.

## 8. 재도전·경제 경계

- 각 전투 시도는 독립 집계한다.
- 실패·포기 시도의 사건을 다음 재도전에 합산하지 않는다.
- 재도전으로 얻은 학습은 허용하며 별도 감점하지 않는다.
- 사람 검증 완료 전 등급은 회차 재화·수련·드롭·영구재화·재도전 환불에 영향을 주지 않는다.
- 보상 연결에는 별도 Decision이 필요하다.

## 9. 사람 검증 Gate

경제 연결 전 최소 표본:

```yaml
completed_victories: 30
distinct_encounters: 5
maximum_single_encounter_share: 0.40
```

필수 지표:

- 원시/유효 방어 반영량 비율
- 같은 안정 ID 반복 대응 비율
- 기준 라운드 이후 양의 원시 사건 비율
- 기준 라운드 내 전투 완료율
- 관찰 사용에 따른 유효 반영량 상승폭
- 평균·90백분위 라운드 수
- 유효 절초 사용률

경고 기준은 자동 조정 조건이 아니다. 수치 변경은 새 GrillMe Decision을 요구한다.

## 10. 결과 화면 원칙

플레이어가 실제 성공이 사라졌다고 오해하지 않도록 원시 사건과 등급 반영량을 분리 표시한다.

```text
합 승리: 5회 / 등급 반영 2.5
회피 성공: 3회 / 등급 반영 1.5
절초 사용: 2회 / 유효 반영 1회
```

## 11. 거부한 대안

- 성공 횟수÷대응 기회의 완전 비율형: 기회 판정·상대별 기대값·쉬운 기회 선별 문제가 커 현재 단계에서 과설계다.
- S/A/B/C 전체 보류: 안전하지만 결과 화면 성취 피드백과 후속 검증을 지나치게 지연한다.
- 원시 로그 자체 감쇠: 복기·디버깅·실제 숙련 증거를 훼손하므로 금지한다.

## 12. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING_GOVERNANCE
risk_status: MITIGATED_PENDING_HUMAN_MEASUREMENT
active_approval_count: 9/10
next_planning_decision: STAR9_PUBLIC_READ_BRANCH_TEMPLATE
product_code_changed: false
runtime_data_changed: false
combat_resolution_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
performance_validation: NOT_RUN
human_validation: NOT_RUN
balance_validation: NOT_RUN
```
