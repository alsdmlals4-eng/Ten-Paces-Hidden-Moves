# 시작 스테이터스 자유 분배 5점 결정

- Decision ID: `TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `4/10`
- 선행 결정:
  - `TEN-DEC-20260802-STAT-REFERENCE-PRICE-BASE4-01`
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`

## 1. 승인 결론

회차 시작 시 외공·근골·신법·내공·심안은 각각 기본 `2`에서 시작하며, 플레이어는 총 **5점**을 자유 분배한다.

```text
무공 선택 전 시작 스테이터스
= 각 스테이터스 기본 2
+ 자유 분배 총 5점
```

- 다섯 스테이터스의 기본 합계는 `10`이다.
- 자유 분배 후 무공 선택 전 합계는 `15`다.
- 자유 분배 단계의 스테이터스별 상한은 `6`이다.
- 자유 분배 단계에서 어느 스테이터스도 기본값 `2` 아래로 내릴 수 없다.
- 자유 분배 5점은 모두 사용해야 한다.

## 2. 시작 무공 보너스 적용 순서

현재 시작 규칙은 후보 무공 6개 중 4개를 선택하고, 선택한 무공을 모두 3성으로 시작한다. 따라서 각 선택 무공의 2성 고정 영구 스테이터스 보너스가 즉시 적용된다.

적용 순서는 다음과 같다.

```text
1. 다섯 스테이터스 기본 2 적용
2. 자유 분배 5점 적용
3. 선택한 시작 무공 4개의 2성 고정 보너스 적용
4. 최종 시작 스테이터스 검증
```

최종 시작값 공식:

```text
final_starting_stat
= 2
+ direct_allocation
+ sum(selected_manual_star_2_fixed_bonuses)
```

- 자유 분배 상한 `6`은 **직접 분배 단계의 상한**이다.
- 시작 무공의 고정 보너스가 적용된 뒤 최종 스테이터스가 6을 넘는 것은 허용한다.
- 무공 보너스를 6에서 잘라내거나 환불하지 않는다.
- 전체 영구 스테이터스 운용 범위 `1~15`는 유지한다.

## 3. 기준 스테이터스 4와의 관계

- 기술 예산의 기준 스테이터스 `4`는 자유 분배 직후의 평균을 뜻하지 않는다.
- 기준값 4는 **시작 무공의 2성 보너스까지 적용한 최종 시작 빌드와 초기 전투 성능을 검증하는 중심점**이다.
- 무공 선택 전 자유 분배 상태의 평균은 `3`이다.
- 시작 무공 보너스의 정확한 총량과 분포가 확정된 뒤, 선택 가능한 시작 빌드가 기준 4 전후에 형성되는지 조합 검증한다.

## 4. 미확정 경계

이번 Decision은 자유 분배량과 적용 순서만 확정한다. 다음은 별도 승인 대상이다.

- 여섯 시작 무공 각각의 2성 고정 보너스 스테이터스와 수량
- 시작 무공 4개 선택으로 얻는 총 보너스의 최소·최대
- 무공 보너스 적용 후 스테이터스별 권장 시작 상한
- 시작 기술의 요구 스테이터스 수치

현재 개별 무공 수치·짝수 성 보너스는 `POC_HYPOTHESIS`이며, 명시 데이터 없이 임의로 구현하지 않는다.

## 5. 적대적 검토

자유 분배를 10점으로 유지하면 시작 무공 4개의 2성 보너스까지 더해져 초기 능력치가 기준 4를 과도하게 넘거나, 특정 공격 능력치에 극단적으로 몰아주는 문제가 생길 수 있다.

자유 분배 5점은 다음을 의도한다.

- 캐릭터의 직접 선택은 유지한다.
- 시작 무공 선택이 실제 스테이터스 구성에 영향을 준다.
- 무공 선택 전에 완성형 능력치 배분을 끝내는 것을 방지한다.
- 시작 무공과 자유 분배의 역할 중복을 줄인다.

다만 무공별 2성 보너스가 지나치게 크거나 특정 능력치에 편중되면 여전히 과성장이 발생하므로, 보너스 데이터 확정 전 구현 인계는 금지한다.

## 6. 검증 요구

1. 모든 스테이터스가 직접 분배 전 `2`로 시작함.
2. 자유 분배점 합계가 정확히 `5`임.
3. 직접 분배 후 총합이 `15`임.
4. 직접 분배 단계에서 각 스테이터스가 `2~6` 범위임.
5. 선택한 4개 시작 무공의 2성 고정 보너스가 직접 분배 후 적용됨.
6. 무공 보너스가 직접 분배 상한 6으로 잘리지 않음.
7. 최종 시작값이 전체 운용 상한 15를 넘지 않음.
8. 무공별 2성 보너스 미확정 상태를 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
base_stat_each: 2
free_allocation_points: 5
pre_manual_total_stats: 15
direct_allocation_min_per_stat: 2
direct_allocation_max_per_stat: 6
starting_manual_candidates: 6
starting_manuals_chosen: 4
starting_manual_mastery: 3
star_2_fixed_bonus_applies_immediately: true
final_start_formula: 2 + direct_allocation + selected_manual_star_2_bonuses
balance_reference_stat_applies_after_manual_bonuses: true
manual_bonus_vectors: POC_HYPOTHESIS_TBD
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 4/10
```
