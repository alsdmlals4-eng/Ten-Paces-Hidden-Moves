# 시작 스테이터스 총합 20·무공 2성 보너스 결정

- Decision ID: `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 대체 대상: `TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01`

## 승인 결론

회차 시작 시 외공·근골·신법·내공·심안은 각각 기본 `2`이며, 플레이어는 총 **6점**을 자유 분배한다. 이후 시작 무공 6개 중 4개를 3성으로 선택하고 각 무공의 2성 고정 영구 스테이터스 보너스 `+1`을 적용한다.

```text
기본 합계 10 + 자유 분배 6 + 선택 무공 보너스 4 = 최종 총합 20
```

직접 분배 단계의 각 스테이터스 범위는 `2~6`이며, 무공 보너스는 이후 적용되어 상한 6으로 잘리지 않는다. 선택 조합과 관계없이 시작 무공 보너스 총량은 항상 `+4`다.

## 시작 무공 2성 고정 보너스

| 무공 ID | 무공 | 보너스 |
|---|---|---:|
| `flowing_cloud_sword` | 유운검결 | 신법 +1 |
| `vajra_body` | 금강호체공 | 근골 +1 |
| `taiji_flow` | 태극유전검 | 심안 +1 |
| `pursuing_wind_spear` | 추풍창법 | 외공 +1 |
| `clear_heart_nurturing` | 청심양생공 | 내공 +1 |
| `shadowless_steps` | 무영십보 | 신법 +1 |

모든 무공은 같은 총량 `+1`을 지급한다.

## 도달 가능한 시작 범위

- 외공·근골·내공·심안: 관련 무공 선택 시 최대 `7`
- 신법: 유운검결과 무영십보를 모두 선택하면 최대 `8`
- 보너스를 받지 않은 능력치는 `2`로 시작 가능
- 최종 총합 20의 평균은 정확히 `4`

## 대체 범위

자유 분배 5점, 무공 선택 전 총합 15, 무공별 2성 보너스 미확정 표현을 대체한다. 이전 Decision은 역사 기록으로만 보존한다.

## 구현 경계

기획 규칙과 승인 계약만 변경한다. 제품 런타임 구현과 시작 기술의 정확한 요구 스테이터스는 별도 승인 대상이다.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
base_stat_each: 2
base_total_stats: 10
free_allocation_points: 6
pre_manual_total_stats: 16
manual_star_2_bonus_each: 1
selected_manual_bonus_total: 4
final_starting_total_stats: 20
direct_allocation_min_per_stat: 2
direct_allocation_max_per_stat: 6
manual_bonus_clamped_by_direct_cap: false
balance_reference_stat: 4
starting_average_stat: 4
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 5/10
```