# 연격·다단 공격 완전 파훼 판정 결정

- Decision ID: `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `6/10`
- 선행 결정: `TEN-DEC-20260802-THREAT-ID-ACTION-01`

## 1. 승인 결론

여러 피해 단위를 가진 연격·다단 공격도 전투 종료 `위협 대응` 반복 감쇠에서는 **공격 행동 하나당 최대 1회의 파훼 사건**으로 계산한다.

완전 파훼 성공 조건:

1. 같은 공격 행동에서 생성된 모든 유효 피해 단위를 `[합]` 또는 해당 행동을 무효화하는 정상 규칙으로 취소한다.
2. 그 공격 행동으로 인한 체력 피해가 0이다.
3. 공격 행동의 유효 피해가 후속타 취소·중단 등으로 더 이상 남아 있지 않다.

조건을 모두 만족하면 해당 공격 행동의 정규화 위협 ID 카운트를 1 증가시킨다.

## 2. 부분 파훼

일부 피해 단위만 취소하고 나머지 피해 단위가 체력 피해를 주면 완전 파훼로 계산하지 않는다.

- 부분 파훼는 전투 로그·복기 사건으로 기록한다.
- 부분 파훼는 반복 감쇠의 100%·50%·0% 카운트를 소비하지 않는다.
- 부분 파훼 자체가 완전 파훼와 같은 `위협 대응` 사건 점수를 자동 생성하지 않는다.
- 별도의 부분 대응 보너스가 필요하다면 후속 Decision으로만 추가한다.

## 3. 카운트 단위

- 연격 3타를 모두 무효화해도 완전 파훼 카운트는 1회다.
- 각 피해 단위마다 반복 감쇠 횟수를 증가시키지 않는다.
- 같은 공격 행동 안에서 여러 번 합을 이겨도 정규화 위협 ID 카운트는 최대 1 증가한다.
- 한 공격 행동 안에 서로 다른 파생 타격 이름이나 내부 hit index가 있어도, 별도 행동 ID로 분리되지 않았다면 하나의 위협 사건이다.

## 4. 절초기세와 합 승리 보상

- 절초기세는 기존 규칙대로 공격 행동당 최대 +1이다.
- 완전 파훼 여부와 관계없이 실제 합 승리 조건을 충족한 경우 `ON_CLASH_WIN`은 정상 처리한다.
- 부분 파훼라고 해서 이미 발생한 정상 합 승리 보상을 취소하지 않는다.
- 전투 종료 점수 감쇠와 전투 보상은 분리한다.

## 5. 사거리 안·밖 대칭

사거리 안 합 승리와 사거리 밖 합 승리에 같은 완전 파훼 조건을 적용한다.

- 모든 유효 피해 단위를 취소했고 공격 행동의 체력 피해가 0이면 완전 파훼다.
- 사거리 밖이라는 이유로 추가 감액하거나 별도 카운트를 만들지 않는다.
- 사거리 밖 합 승리로 공격을 취소한 경우에도 같은 정규화 위협 ID의 반복 횟수를 공유한다.

## 6. 결과·복기 표시

결과 화면과 복기는 최소 다음을 구분할 수 있어야 한다.

```text
완전 파훼: 연격의 모든 유효 피해 단위 무효화
부분 파훼: 일부 피해 단위 무효화, 잔여 피해 발생
반복 반영률: 첫 100% / 둘째 50% / 셋째 이후 0%
```

## 7. 미결정 경계

이 결정은 다음을 확정하지 않는다.

- 위협 대응 사건당 정확한 기본 점수
- 부분 파훼에 별도 소량 점수를 줄지 여부
- 피해가 아닌 밀치기·상태 이상만 남은 경우의 완전 파훼 판정
- 장풍의 정확한 피해 공식

규칙 충돌이 발생하면 후속 GrillMe로 확인한다.

## 8. 검증 요구

1. 연격 3타를 모두 취소하면 반복 카운트가 1 증가함.
2. 연격 3타 중 2타만 취소하고 1타가 체력 피해를 주면 반복 카운트가 증가하지 않음.
3. 한 공격 행동에서 여러 합을 이겨도 절초기세는 최대 +1임.
4. 부분 파훼도 합 승리·로그·복기 기록은 정상 유지됨.
5. 사거리 안·밖에 같은 완전 파훼 조건이 적용됨.
6. 서로 다른 공격 행동 두 개를 완전 파훼하면 각각 1회로 계산됨.
7. 온라인 시즌 평점에는 영향이 없음.

## 9. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
counting_unit: ATTACK_ACTION
maximum_threat_count_increment_per_attack_action: 1
complete_parry_requires_all_effective_damage_units_cancelled: true
complete_parry_requires_zero_health_damage_from_attack_action: true
partial_parry_consumes_repeat_count: false
ultimate_momentum_max_gain_per_attack_action: 1
in_range_out_of_range_symmetric: true
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 6/10
```
