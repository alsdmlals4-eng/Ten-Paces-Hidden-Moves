# 시작 스테이터스 총합 20·무공 2성 보너스 결정

- Decision ID: `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 대체 대상: `TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01`
- 선행 결정:
  - `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`

## 1. 승인 결론

회차 시작 시 외공·근골·신법·내공·심안은 각각 기본 `2`이며, 플레이어는 총 **6점**을 자유 분배한다. 이후 시작 무공 6개 중 4개를 3성으로 선택하고, 각 무공의 2성 고정 영구 스테이터스 보너스 `+1`을 적용한다.

```text
기본 합계 10
+ 자유 분배 6
+ 선택 무공 4개 × 2성 보너스 1
= 최종 시작 스테이터스 총합 20
```

- 자유 분배 6점은 모두 사용해야 한다.
- 직접 분배 단계의 각 스테이터스 범위는 `2~6`이다.
- 무공 보너스는 직접 분배 뒤 적용하며, 직접 분배 상한 6으로 잘리지 않는다.
- 선택한 무공 조합과 무관하게 시작 무공 보너스 총량은 항상 `+4`다.
- 전체 영구 스테이터스 운용 범위 `1~15`는 유지한다.

## 2. 시작 무공 2성 고정 보너스

| 무공 ID | 무공 | 2성 고정 보너스 | 정체성 연결 |
|---|---|---:|---|
| `flowing_cloud_sword` | 유운검결 | 신법 +1 | 이동 뒤 연격·순차 합 |
| `vajra_body` | 금강호체공 | 근골 +1 | 방어·강건·버티기 |
| `taiji_flow` | 태극유전검 | 심안 +1 | 대응·간파·반격 |
| `pursuing_wind_spear` | 추풍창법 | 외공 +1 | 거리 병기·외가 공격 |
| `clear_heart_nurturing` | 청심양생공 | 내공 +1 | 내력·회복·양생 |
| `shadowless_steps` | 무영십보 | 신법 +1 | 이동·회피·위치 파훼 |

모든 무공은 같은 총량 `+1`을 지급한다. 기술 성능과 별개로 스테이터스 보너스 총량이 더 큰 무공은 만들지 않는다. 위 ID는 `docs/planning-data/poc_martial_arts.json`의 현재 canonical manual ID와 일치한다.

## 3. 적용 순서

```text
1. 다섯 스테이터스에 기본 2 적용
2. 자유 분배 6점 적용
3. 시작 무공 6개 중 4개 선택
4. 선택 무공의 2성 고정 보너스 +1씩 적용
5. 최종 시작 총합 20 및 개별 스테이터스 검증
```

최종 시작값:

```text
final_starting_stat
= 2
+ direct_allocation
+ sum(selected_manual_star_2_fixed_bonuses)
```

## 4. 도달 가능한 시작 범위

직접 분배 단계 상한은 6이지만 무공 보너스는 이후 적용되므로 다음 값이 가능하다.

- 외공·근골·내공·심안: 관련 무공을 선택한 경우 시작 최대 `7`.
- 신법: 유운검결과 무영십보를 모두 선택하면 시작 최대 `8`.
- 어떤 스테이터스도 직접 분배와 선택 무공 보너스를 받지 않으면 `2`로 시작할 수 있다.
- 위 값은 시작 조합에서 도달 가능한 결과이며 별도 영구 상한이 아니다.

## 5. 기준 스테이터스 4와의 관계

- 최종 시작 총합은 20이고 평균은 정확히 `4`다.
- 따라서 기술 점수표의 기준 스테이터스 4와 최종 시작 빌드의 평균이 일치한다.
- 평균 4는 모든 스테이터스가 4라는 뜻이 아니며, 자유 분배와 무공 선택에 따라 `2~8` 범위의 비대칭 빌드를 허용한다.
- 기준 스테이터스 4는 개별 기술 예산 검산 기준이며 모든 시작 캐릭터의 개별 능력치 보장값이 아니다.

## 6. 대체 범위

이 Decision은 다음 구형 표현을 대체한다.

- 자유 분배 5점
- 무공 선택 전 총합 15
- 시작 무공 2성 보너스 벡터 `POC_HYPOTHESIS_TBD`
- 최종 시작 총합이 미확정이라는 표현

`TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01`은 역사 기록으로 보존하되 현재 권위는 이 Decision이다.

## 7. 구현·검증 경계

- 기획 규칙과 승인 계약만 변경한다.
- 기존 `poc_martial_arts.json`의 개별 기술·짝수 성 데이터는 승인 계약에 맞게 후속 정리할 수 있으나, 제품 런타임 구현은 별도 Build 승인 전 금지한다.
- 시작 기술의 정확한 요구 스테이터스는 아직 별도 승인 대상이다.

검증 요구:

1. 기본 스테이터스 합계가 10임.
2. 자유 분배 합계가 정확히 6임.
3. 직접 분배 후 총합이 16임.
4. 시작 무공 4개의 2성 보너스가 각각 +1임.
5. 무공 보너스 총합이 조합과 무관하게 4임.
6. 최종 시작 총합이 정확히 20임.
7. 직접 분배 단계 각 스테이터스가 2~6임.
8. 무공 보너스가 직접 분배 상한 6으로 잘리지 않음.
9. 유운검결+무영십보 선택 시 신법 보너스가 +2로 합산됨.
10. canonical manual ID와 승인 계약 ID가 일치함.
11. 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
base_stat_each: 2
base_total_stats: 10
free_allocation_points: 6
pre_manual_total_stats: 16
starting_manual_candidates: 6
starting_manuals_chosen: 4
starting_manual_mastery: 3
manual_star_2_bonus_each: 1
selected_manual_bonus_total: 4
final_starting_total_stats: 20
direct_allocation_min_per_stat: 2
direct_allocation_max_per_stat: 6
manual_bonus_clamped_by_direct_cap: false
manual_bonus_vectors:
  flowing_cloud_sword: {agility: 1}
  vajra_body: {constitution: 1}
  taiji_flow: {insight: 1}
  pursuing_wind_spear: {external_power: 1}
  clear_heart_nurturing: {internal_power: 1}
  shadowless_steps: {agility: 1}
reachable_starting_max:
  external_power: 7
  constitution: 7
  agility: 8
  internal_power: 7
  insight: 7
balance_reference_stat: 4
starting_average_stat: 4
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 5/10
```