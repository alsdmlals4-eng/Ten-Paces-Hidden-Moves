# 7성 기술 주 능력치 8 요구 결정

- Decision ID: `TEN-DEC-20260803-STAR7-TECHNIQUE-PRIMARY-STAT8-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `10/10`
- 선행 결정:
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
  - `TEN-DEC-20260802-STARTING-TECHNIQUE-PRIMARY-STAT4-01`
  - `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`
  - `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`

## 1. 승인 결론

무공서가 7성에 도달해 기술 2 획득 판정을 수행할 때, 해당 무공의 **주 영구 능력치 8**을 요구한다.

```text
7성 기술 요구치 = 해당 무공의 주 영구 능력치 8
```

- 보조 능력치 요구는 붙이지 않는다.
- 임시 능력치와 전투 중 버프는 해금 판정에 사용하지 않는다.
- 외공·근골·신법·내공·심안의 실제 영구값을 사용하며 15에서 절단하지 않는다.
- 무공서 수련은 요구치 때문에 중단되지 않는다.

## 2. 자동 성장과 추가 투자의 관계

해당 무공을 7성까지 정상 수련했을 때 무공 자체의 짝수 성 보너스만으로 도달하는 최소 주 능력치는 6이다.

```text
기본 2
+ 2성 주 +1
+ 4성 주 +1
+ 6성 주 +2
= 주 능력치 6
```

따라서 주 능력치 8을 충족하려면 최소 2점을 다음 경로 중 하나 이상에서 확보해야 한다.

- 시작 자유 분배
- 같은 주 능력치를 제공하는 다른 무공
- 향후 승인된 중간 노드 영구 보상
- 기타 별도 승인된 영구 성장 경로

이는 7성 도달 시간만으로 자동 해금되지 않고, 실제 빌드 투자 방향을 판별하기 위한 Gate다.

## 3. 미달 시 처리

주 영구 능력치가 8에 미달해도 무공서와 성취는 유지한다.

- 무공서는 7성 상태를 유지한다.
- 기존 패시브·2성 보너스·3성 기술·4/6성 보너스·5성 강화는 유지한다.
- 7성 기술만 `LOCKED_STAT_REQUIREMENT` 상태가 된다.
- 이후 주 영구 능력치가 8에 도달하면 별도 수련포인트나 재획득 없이 자동 활성화한다.
- 한번 활성화된 기술은 전투 중 임시 능력치 감소로 다시 잠기지 않는다.
- 잠긴 상태에서도 무공서를 8·9·10성으로 계속 수련할 수 있다.

## 4. 벤치마킹·적대적 판정

비교한 두 진행 패턴:

1. **숙련도만으로 자동 해금**: 이해하기 쉽지만 이미 7성 수련 비용이 있으므로 능력치 요구가 장식이 된다.
2. **숙련도 + 빌드 속성 Gate**: 기술 성장과 실제 능력치 투자를 연결하지만 과도한 이중 장벽이 될 수 있다.

프로젝트에는 두 번째 원칙을 제한적으로 채택한다.

- 요구치는 자동 도달 하한 6보다 2 높은 8로 둔다.
- 보조 능력치 요구는 붙이지 않아 이중 장벽을 최소화한다.
- 기술만 잠그고 무공 수련과 기존 보상은 유지한다.
- 성장 선택이 수읽기를 덮는지 사람 검증한다.

관련 작업 절차는 `docs/reviews/2026-08-03_GRILLME_BENCHMARK_PROTOCOL.md`를 따른다.

## 5. 대체·후속 범위

이번 Decision으로 확정:

- 7성 기술 요구치: 주 영구 능력치 8
- 보조 능력치 요구 없음
- 미달 시 기술만 잠금
- 영구 주 능력치 8 도달 시 자동 활성화
- 임시 능력치 감소 재잠금 없음

아직 미확정:

- 10성 절초의 정확한 요구치
- 여섯 무공의 보조 능력치 매핑
- 중간 노드 영구 스테이터스 보상 여부·량
- 각 무공 7성 기술의 실제 효과·예산

## 6. 검증 요구

1. 7성 도달만으로 기술이 자동 활성화되지 않음.
2. 요구값이 해당 무공의 주 영구 능력치 8임.
3. 보조 능력치 요구가 암묵적으로 추가되지 않음.
4. 미달 시 무공서·기존 기술·성장 보너스가 유지됨.
5. 무공 수련이 8~10성으로 계속 가능함.
6. 영구 주 능력치 8 도달 시 별도 비용 없이 자동 활성화됨.
7. 임시 능력치 감소가 활성 기술을 다시 잠그지 않음.
8. 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
milestone_star: 7
unlock_type: PRIMARY_PERMANENT_STAT
unlock_value: 8
secondary_requirement: NONE
automatic_primary_floor_before_star_7: 6
additional_primary_investment_required_from_floor: 2
manual_training_blocked_when_locked: false
locked_technique_only: true
auto_enable_on_permanent_requirement_met: true
temporary_stat_drop_relocks: false
star_10_requirement: TBD_NEXT_BATCH
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 10/10
```
