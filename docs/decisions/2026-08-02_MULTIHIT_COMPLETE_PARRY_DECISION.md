# 연격·다단 공격 완전 파훼 판정 결정

- Decision ID: `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `6/10`
- 선행 결정: `TEN-DEC-20260802-THREAT-ID-ACTION-01`
- 후속 보완: `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`

## 1. 승인 결론

여러 피해 단위를 가진 연격·다단 공격도 전투 종료 `위협 대응` 반복 감쇠에서는 **공격 행동 하나당 최대 1회의 완전 파훼 사건**으로 계산한다.

완전 파훼의 최신 판정 기준은 후속 Decision을 따른다.

```text
해당 공격 행동으로 받은 최종 체력 피해 = 0
→ 완전 파훼 1회
```

- 모든 피해 단위를 합으로 직접 취소하지 않아도 방어·감소·상쇄 결과 최종 체력 피해가 0이면 완전 파훼다.
- 밀치기·경직·상태 이상 등 부가효과가 남아도 완전 파훼 판정을 취소하지 않는다.
- 한 공격 행동당 반복 카운트 증가는 최대 1회다.

## 2. 부분 파훼

일부 피해 단위를 취소했지만 해당 공격 행동으로 체력 피해가 1 이상 발생하면 완전 파훼로 계산하지 않는다.

- 부분 파훼는 전투 로그·복기 사건으로 기록한다.
- 부분 파훼는 반복 감쇠의 100%·50%·0% 카운트를 소비하지 않는다.
- 부분 파훼 자체가 완전 파훼와 같은 `위협 대응` 사건 점수를 자동 생성하지 않는다.
- 별도의 부분 대응 보너스가 필요하다면 후속 Decision으로만 추가한다.

## 3. 카운트 단위

- 연격 3타의 최종 체력 피해가 0이어도 완전 파훼 카운트는 1회다.
- 각 피해 단위마다 반복 감쇠 횟수를 증가시키지 않는다.
- 같은 공격 행동 안에서 여러 번 합을 이겨도 정규화 위협 ID 카운트는 최대 1 증가한다.
- 한 공격 행동 안에 서로 다른 파생 타격 이름이나 내부 hit index가 있어도 별도 행동 ID가 아니라면 하나의 위협 사건이다.

## 4. 절초기세와 합 승리 보상

- 절초기세는 기존 규칙대로 공격 행동당 최대 +1이다.
- 완전 파훼 여부와 관계없이 실제 합 승리 조건을 충족한 경우 `ON_CLASH_WIN`은 정상 처리한다.
- 부분 파훼라고 해서 이미 발생한 정상 합 승리 보상을 취소하지 않는다.
- 전투 종료 점수 감쇠와 전투 보상은 분리한다.

## 5. 사거리 안·밖 대칭

사거리 안 합 승리와 사거리 밖 합 승리에 같은 체력 피해 0 기준을 적용한다.

- 해당 공격 행동의 최종 체력 피해가 0이면 완전 파훼다.
- 사거리 밖이라는 이유로 추가 감액하거나 별도 카운트를 만들지 않는다.
- 사거리 안·밖 성공은 같은 정규화 위협 ID의 반복 횟수를 공유한다.

## 6. 부가효과 분리

완전 파훼와 부가효과 회피는 별도 판정이다.

```text
방어/합으로 체력 피해 0 + 밀치기 적용
→ 완전 파훼, 부가효과 피격

회피로 체력 피해 0 + 밀치기 미적용
→ 완전 파훼, 회피 성공
```

기술별 부가효과 상호작용은 `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`과 개별 기술 데이터를 따른다.

## 7. 결과·복기 표시

결과 화면과 복기는 최소 다음을 구분한다.

```text
완전 파훼: 해당 공격 행동의 체력 피해 0
부분 파훼: 일부 피해 취소, 최종 체력 피해 발생
부가효과: 적용 또는 회피
반복 반영률: 첫 100% / 둘째 50% / 셋째 이후 0%
```

## 8. 미결정 경계

- 위협 대응 사건당 정확한 기본 점수
- 부분 파훼에 별도 소량 점수를 줄지 여부
- 장풍의 정확한 피해 공식

규칙 충돌이 발생하면 후속 GrillMe로 확인한다.

## 9. 검증 요구

1. 연격 3타의 최종 체력 피해가 0이면 반복 카운트가 1 증가함.
2. 연격 일부를 합으로 취소했지만 체력 피해가 1 이상이면 반복 카운트가 증가하지 않음.
3. 한 공격 행동에서 여러 합을 이겨도 절초기세는 최대 +1임.
4. 체력 피해 0이면서 밀치기가 적용돼도 완전 파훼로 기록됨.
5. 사거리 안·밖에 같은 완전 파훼 조건이 적용됨.
6. 서로 다른 공격 행동 두 개를 완전 파훼하면 각각 1회로 계산됨.
7. 온라인 시즌 평점에는 영향이 없음.

## 10. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
counting_unit: ATTACK_ACTION
maximum_threat_count_increment_per_attack_action: 1
complete_parry_requires_zero_health_damage_from_attack_action: true
complete_parry_requires_all_damage_units_cancelled: false
secondary_effects_cancel_complete_parry: false
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
