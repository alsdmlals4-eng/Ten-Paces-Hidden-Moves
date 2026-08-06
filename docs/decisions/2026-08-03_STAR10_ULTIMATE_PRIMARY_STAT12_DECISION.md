# 10성 절초 주 능력치 12 요구 결정

- Decision ID: `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`
- 승인일: 2026-08-03
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `1/10`
- 선행 결정:
  - `TEN-DEC-20260802-OBSERVATION-STATS-MASTERY-01`
  - `TEN-DEC-20260802-EVEN-STAR-STAT-ESCALATION-01`
  - `TEN-DEC-20260803-UNCAPPED-CORE-STATS-01`
  - `TEN-DEC-20260803-STAR7-TECHNIQUE-PRIMARY-STAT8-01`

## 1. 승인 결론

무공서가 10성에 도달해 고유 `[절초]` 획득 판정을 수행할 때, 해당 무공의 **주 영구 능력치 12**를 요구한다.

```text
10성 절초 요구치 = 해당 무공의 주 영구 능력치 12
```

- 보조 능력치 요구는 붙이지 않는다.
- 임시 능력치와 전투 중 버프는 해금 판정에 사용하지 않는다.
- 실제 영구 능력치를 사용하며 15에서 절단하지 않는다.
- 무공서 수련은 요구치 때문에 중단되지 않는다.

## 2. 성장 사다리

각 기술 획득 시점의 무공 자체 자동 주 능력치 하한과 요구치를 다음처럼 연결한다.

| 성취 | 자동 주 능력치 하한 | 요구치 | 외부 영구 투자 필요량 |
|---:|---:|---:|---:|
| 3성 기술1 | 3 | 4 | +1 |
| 7성 기술2 | 6 | 8 | +2 |
| 10성 절초 | 9 | 12 | +3 |

10성 직전 자동 하한 계산:

```text
기본 2
+ 2성 주 +1
+ 4성 주 +1
+ 6성 주 +2
+ 8성 주 +3
= 주 능력치 9
```

따라서 10성 도달 시간만으로 절초가 자동 활성화되지 않고, 실제 빌드 전문화에 추가 3점이 필요하다.

허용되는 영구 투자 경로:

- 시작 자유 분배
- 같은 주 능력치를 제공하는 다른 무공
- 향후 승인된 중간 노드 영구 보상
- 기타 별도 승인된 영구 성장 경로

특정 보조 능력치·노드·다른 무공을 필수 조건으로 강제하지 않는다.

## 3. 미달 시 처리

주 영구 능력치가 12에 미달해도 무공서와 기존 성취는 유지한다.

- 무공서는 10성 상태를 유지한다.
- 기존 패시브·짝수 성 보너스·3성/7성 기술·5성/9성 강화는 유지한다.
- 해당 무공의 10성 절초만 `LOCKED_STAT_REQUIREMENT` 상태가 된다.
- 이후 주 영구 능력치가 12에 도달하면 추가 수련포인트나 재획득 없이 자동 활성화한다.
- 한번 활성화된 절초는 전투 중 임시 능력치 감소로 다시 잠기지 않는다.
- 임시 버프만으로 12를 충족한 경우에는 활성화하지 않는다.

## 4. 벤치마킹·적대적 판정

검토한 진행 패턴:

1. **숙련도만으로 최종 기술 자동 해금**: 이해하기 쉽지만 10성 수련 자체가 유일한 조건이 되어 능력치 빌드 선택의 의미가 약해진다.
2. **숙련도 + 단일 주 능력치 Gate**: 무공 전문화를 판별하면서도 보조 능력치·노드 운을 필수화하지 않는다.
3. **숙련도 + 주·보조 복합 Gate**: 무공 정체성은 강하지만 아직 미확정인 보조 매핑과 노드 공급을 역으로 구속하고 이중 장벽을 과도하게 만든다.

프로젝트에는 두 번째 원칙을 채택한다.

- 10성이라는 큰 수련 Gate 위에 단일 주 능력치 Gate만 추가한다.
- 자동 하한 9보다 3 높은 12로 두어 3·7·10성의 추가 투자량을 +1·+2·+3으로 증가시킨다.
- 보조 요구를 두지 않아 특정 조합·노드 운을 필수화하지 않는다.
- 절초만 잠그고 이미 획득한 성장 보상은 보존한다.
- 고능력치가 수읽기를 덮는지는 별도 사람 검증으로 확인한다.

관련 작업 절차는 `docs/reviews/2026-08-03_GRILLME_BENCHMARK_PROTOCOL.md`를 따른다.

## 5. 대체·후속 범위

이번 Decision으로 확정:

- 10성 절초 요구치: 주 영구 능력치 12
- 보조 능력치 요구 없음
- 미달 시 절초만 잠금
- 영구 주 능력치 12 도달 시 자동 활성화
- 임시 버프 해금 불가
- 활성화 후 임시 감소 재잠금 없음

아직 미확정:

- 여섯 무공의 정확한 보조 능력치 매핑
- 중간 노드 영구 스테이터스 보상 여부·량
- 각 무공 고유 절초의 실제 효과·행동 슬롯·자원·효과 예산
- 고능력치에서 절초가 거리·순서·대응 수읽기를 지배하는지 사람 검증

## 6. 검증 요구

1. 10성 도달만으로 절초가 자동 활성화되지 않음.
2. 요구값이 해당 무공의 주 영구 능력치 12임.
3. 보조 능력치 요구가 암묵적으로 추가되지 않음.
4. 임시 능력치가 해금 판정에 사용되지 않음.
5. 미달 시 무공서·기존 기술·강화·성장 보너스가 유지됨.
6. 영구 주 능력치 12 도달 시 별도 비용 없이 자동 활성화됨.
7. 임시 능력치 감소가 활성 절초를 다시 잠그지 않음.
8. 런타임 구현 완료로 오인하지 않음.

```yaml
authority_status: CURRENT_APPROVED_PLANNING
implementation_status: NOT_STARTED
milestone_star: 10
unlock_type: PRIMARY_PERMANENT_STAT
unlock_value: 12
secondary_requirement: NONE
automatic_primary_floor_before_star_10: 9
additional_primary_investment_required_from_floor: 3
manual_training_blocked_when_locked: false
locked_ultimate_only: true
auto_enable_on_permanent_requirement_met: true
temporary_stat_counts_for_unlock: false
temporary_stat_drop_relocks: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 1/10
```