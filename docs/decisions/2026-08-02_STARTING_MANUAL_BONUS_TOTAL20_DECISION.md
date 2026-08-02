# 시작 무공 2성 보너스·최종 총합 20 결정

- Decision ID: `TEN-DEC-20260802-STARTING-MANUAL-BONUS-TOTAL20-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `5/10`
- 선행 결정:
  - `TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01`
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
- 대체 범위: 선행 결정의 자유 분배 `5점`과 무공 선택 전 총합 `15`를 각각 `6점`, `16`으로 대체한다.

## 1. 승인 결론

회차 시작 스테이터스는 다음 총량으로 구성한다.

```text
기본 스테이터스 합계 10
+ 자유 분배 6
+ 시작 무공 4개의 2성 보너스 총합 4
= 최종 시작 스테이터스 총합 20
```

- 외공·근골·신법·내공·심안은 각각 기본 `2`다.
- 자유 분배점은 `5 → 6`으로 증가하며 전부 사용해야 한다.
- 자유 분배 후, 무공 선택 전 총합은 `16`이다.
- 자유 분배 단계의 각 스테이터스 범위는 계속 `2~6`이다.
- 후보 무공 6개 중 4개를 3성으로 선택한다.
- 선택한 각 무공은 2성 고정 보너스 `+1`을 즉시 제공한다.
- 네 무공 선택으로 얻는 시작 보너스 총량은 항상 `+4`다.
- 최종 시작 총합은 어떤 4개를 선택해도 항상 `20`이다.

## 2. 시작 무공별 2성 고정 보너스

| 무공 | 2성 고정 보너스 | 설계 연결 |
|---|---:|---|
| 유운검결 | 신법 +1 | 이동 후 연격·순차 합 |
| 금강호체공 | 근골 +1 | 방어도·강건·버티기 |
| 태극유전검 | 심안 +1 | 회피·간파·조건 반격 |
| 추풍창법 | 외공 +1 | 거리 병기 공격·밀기 |
| 청심양생공 | 내공 +1 | 내력·회복·호신 |
| 무영십보 | 신법 +1 | 이동·보법·회피 |

- 모든 시작 무공의 2성 보너스 가치는 동일하게 `+1`이다.
- 무공 선택은 총량이 아니라 능력치 분포를 바꾼다.
- 유운검결과 무영십보를 함께 선택하면 신법 `+2` 시너지가 가능하다.
- 시작 무공의 4·6·8성 보너스는 이 Decision에서 확정하지 않는다.

## 3. 적용 순서와 상한

```text
1. 다섯 스테이터스 기본 2 적용
2. 자유 분배 6점 적용
3. 선택한 시작 무공 4개의 2성 보너스 +1씩 적용
4. 최종 시작 스테이터스와 기술 요구치 검증
```

- 직접 분배 단계의 상한은 스테이터스별 `6`이다.
- 자유 분배 6점을 한 능력치에 모두 넣을 수 없으며, 상한 6을 지켜 분배한다.
- 무공의 2성 보너스는 직접 분배 상한 6으로 잘리지 않는다.
- 동일 능력치 보너스가 겹치면 합산한다.
- 전체 운용 상한 `15`만 최종 하드캡으로 유지한다.
- 가능한 최종 시작 단일 스테이터스 최대값은 직접 분배 6에 같은 능력치 보너스 2개가 겹치는 `8`이다.

## 4. 기준 스테이터스 4와의 관계

- 최종 시작 총합은 `20`, 다섯 스테이터스 평균은 정확히 `4`다.
- 기술 점수표의 기준 스테이터스 4와 시작 빌드의 평균값이 일치한다.
- 평균 4는 모든 능력치가 4임을 강제하지 않는다.
- 자유 분배와 무공 선택에 따라 집중형·분산형 빌드를 만들 수 있다.
- 기술 공식과 요구치는 평균이 아니라 실제 최종 스테이터스 벡터를 사용한다.

## 5. 적대적 검토

- 무공마다 +2를 지급하면 최종 총합이 24가 되어 시작부터 기준값을 크게 초과한다.
- 무공별 보너스 총량이 다르면 기술 성능과 무관하게 스테이터스 효율이 높은 무공이 필수 선택이 될 수 있다.
- 모든 무공을 +1로 통일하면 선택 총량은 고정하면서 역할별 분포만 달라진다.
- 신법 보너스 무공이 두 개이므로 신법 집중 빌드는 가능하지만, 총합 우위는 발생하지 않는다.
- 직접 분배 6점은 무공 보너스를 포함한 최종 총합을 20으로 맞추기 위한 조정이며, 능력치별 직접 분배 상한 6은 유지한다.

## 6. 대체·미확정 경계

이 Decision은 다음을 대체한다.

- 자유 분배 5점
- 무공 선택 전 총합 15
- 여섯 시작 무공의 2성 보너스가 `POC_HYPOTHESIS_TBD`라는 상태

다음은 별도 승인 대상이다.

- 3성 시작 기술의 정확한 스테이터스 요구치
- 4·6·8성 무공별 고정 보너스
- 최종 시작 능력치 조합별 기술 활성화 검증
- 시작 능력치 UI와 분배 취소·초기화 UX

## 7. 검증 요구

1. 기본 합계가 `10`임.
2. 자유 분배점이 정확히 `6`이며 모두 사용됨.
3. 무공 선택 전 총합이 `16`임.
4. 직접 분배 단계의 각 스테이터스가 `2~6`임.
5. 선택한 각 시작 무공이 정확히 고정 보너스 `+1`을 제공함.
6. 시작 무공 4개 선택으로 총 `+4`를 얻음.
7. 최종 시작 총합이 항상 `20`, 평균이 `4`임.
8. 신법 보너스 중복 선택 시 최종 신법 최대 `8`이 가능함.
9. 무공 보너스가 직접 분배 상한 6으로 잘리지 않음.
10. 제품 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
base_stat_each: 2
base_total_stats: 10
free_allocation_points: 6
pre_manual_total_stats: 16
direct_allocation_min_per_stat: 2
direct_allocation_max_per_stat: 6
starting_manual_candidates: 6
starting_manuals_chosen: 4
starting_manual_mastery: 3
star_2_bonus_each_selected_manual: 1
selected_manual_bonus_total: 4
final_starting_total_stats: 20
final_starting_average_stat: 4
maximum_possible_single_starting_stat: 8
manual_bonus_vectors:
  flowing_cloud_sword: {agility: 1}
  vajra_body: {constitution: 1}
  taiji_reversal_sword: {insight: 1}
  gale_spear: {external_power: 1}
  clear_heart_nourishing_art: {internal_power: 1}
  shadowless_ten_steps: {agility: 1}
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 5/10
```