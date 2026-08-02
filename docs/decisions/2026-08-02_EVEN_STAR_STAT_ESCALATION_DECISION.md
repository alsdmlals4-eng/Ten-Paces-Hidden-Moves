# 무공서 짝수 성 신규 스테이터스 지급량 결정

- Decision ID: `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING_WITH_CONFLICT_GATE`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `8/10`
- 선행 결정:
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
  - `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`

## 1. 승인 결론

무공서의 2·4·6·8성 고정 영구 스테이터스 보너스는 **해당 성까지의 누적 표시값이 아니라, 그 성에 처음 도달할 때 새로 지급되는 값**이다.

| 성취 | 해당 성에서 새로 지급 | 해당 무공의 누적 지급 |
|---:|---|---|
| 2성 | 주 능력치 +1 | 주 +1 / 보조 +0 / 총 1 |
| 4성 | 주 능력치 +1, 보조 능력치 +1 | 주 +2 / 보조 +1 / 총 3 |
| 6성 | 주 능력치 +2, 보조 능력치 +1 | 주 +4 / 보조 +2 / 총 6 |
| 8성 | 주 능력치 +3, 보조 능력치 +2 | 주 +7 / 보조 +4 / 총 11 |

따라서 시작 3성 무공은 2성의 주 능력치 +1을 이미 보유하며, 이후 4·6·8성에 도달할 때 각각 총 2·3·5점을 추가로 얻는다.

## 2. 지급 계약

- 보너스는 무공서별 고정 주·보조 능력치 벡터를 사용한다.
- 각 성취 보너스는 해당 무공이 그 성에 **처음 도달할 때 회차당 한 번만** 적용한다.
- 시작 무공 또는 회차 중 3성으로 습득한 무공은 1·2·3성 보상을 한 번만 초기 적용한다.
- 이미 보유한 무공을 중복 습득해 지정 수련으로 변환하는 경우 2성 보너스를 다시 지급하지 않는다.
- 같은 성을 다시 계산하거나 저장 데이터를 재로드해도 보너스를 재지급하지 않는다.
- 5·7·9·10성은 별도 승인 전 영구 스테이터스를 지급하지 않는다.
- 정확한 무공별 주·보조 능력치 매핑은 후속 Decision에서 확정한다.

## 3. 기존 안과의 관계

다음 표현을 대체한다.

- 2·4·6·8성마다 동일하게 +1 지급
- 8성까지 주 +2·보조 +2 누적
- 4·6·8성 보너스 벡터와 총량이 모두 미정이라는 표현

유지되는 내용:

- 모든 무공의 2성 보너스는 주 능력치 +1
- 시작 무공 4개 선택 시 시작 보너스 총량은 +4
- 무공 수련은 능력치 요구치 때문에 중단되지 않음
- 기술만 요구치 미달 시 잠기며 영구 능력치 충족 시 자동 활성화

## 4. 정량 영향

한 무공을 시작 3성에서 8성까지 성장시키면 새로 얻는 추가 보너스는 다음과 같다.

```text
4성 +2
+ 6성 +3
+ 8성 +5
= 시작 이후 추가 +10
```

2성 보너스까지 포함한 해당 무공의 총 기여는 주 +7·보조 +4, 총 +11이다.

3성에서 8성까지 필요한 기존 수련포인트는 총 20이므로, 해당 경로는 수련포인트 20으로 영구 스테이터스 10점과 5성 강화·7성 기술을 함께 얻는 고성장 경로다.

## 5. 충돌 Gate

이번 승인으로 다음 충돌이 새로 확정적으로 발생할 수 있다.

1. 기존 주요 운용 범위 `1~15`와 다중 무공의 동일 능력치 중첩
2. 7성·10성 기술 요구치가 성장 보너스만으로 자동 충족될 위험
3. 중간 노드의 추가 영구 스테이터스 보상과의 중복 과성장
4. 능력치 15를 넘길 경우 현재 기술 공식 검증 범위 이탈
5. 유운검결·무영십보처럼 같은 주 능력치를 공유하는 무공의 성장 효율 집중

따라서 다음 항목은 충돌 해결 Decision 전 구현·병합 정본화가 금지된다.

- 능력치 상한과 초과분 처리
- 7성 기술·10성 절초의 정확한 요구치
- 중간 노드 영구 스테이터스 지급량
- 여섯 무공의 정확한 보조 능력치 매핑
- 능력치 15 초과 전투 공식

## 6. 구현·검증 경계

이번 승인은 지급 구조와 총량만 확정한다. 제품 코드·런타임 데이터·무공별 개별 벡터는 변경하지 않는다.

```yaml
authority_status: CURRENT_APPROVED_PLANNING_WITH_CONFLICT_GATE
implementation_status: NOT_STARTED
star_2_new_grant:
  primary: 1
  secondary: 0
star_4_new_grant:
  primary: 1
  secondary: 1
star_6_new_grant:
  primary: 2
  secondary: 1
star_8_new_grant:
  primary: 3
  secondary: 2
cumulative_through_star_8:
  primary: 7
  secondary: 4
  total: 11
milestone_grants_are_incremental: true
grant_once_per_manual_per_run: true
duplicate_acquisition_regrants_bonus: false
stat_cap_policy: BLOCKED_PENDING_CONFLICT_DECISION
star_7_requirement: BLOCKED_PENDING_CONFLICT_DECISION
star_10_requirement: BLOCKED_PENDING_CONFLICT_DECISION
secondary_stat_mapping: TBD_AFTER_CONFLICT_RESOLUTION
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 8/10
```
