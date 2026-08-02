# 연격·다단 공격의 완전 파훼 사건 결정

- Decision ID: `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING_LOG_EVENT`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `6/10`
- 선행 결정: `TEN-DEC-20260802-THREAT-ID-ACTION-01`
- 후속 보완: `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
- 현재 평가 정본: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`

## 1. 승인 결론

여러 피해 단위를 가진 연격·다단 공격도 전투 로그·복기에서 **공격 행동 하나당 최대 1회의 완전 파훼 사건**으로 기록한다.

```text
해당 공격 행동으로 받은 최종 체력 피해 = 0
→ 완전 파훼 사건 1회
```

- 모든 피해 단위를 직접 취소하지 않아도 방어·합·회피 결과 최종 체력 피해가 0이면 완전 파훼다.
- 밀치기·경직·상태 이상 등 부가효과가 남아도 완전 파훼 사건을 취소하지 않는다.
- 한 공격 행동당 완전 파훼 사건은 최대 1회다.

## 2. 첫 피해 단위 합과 후속 피해 단위

- 대립 공격 효과의 첫 피해 단위만 합에 참여한다.
- 첫 합에서 승리하지 못한 공격 효과는 후속 피해 단위를 잃는다.
- 첫 합 승리 공격의 후속 피해 단위는 순차 해결하지만 다시 합하지 않는다.
- 따라서 한 연격 공격 효과 안에서 여러 피해 단위가 각각 합 승리를 만드는 규칙은 사용하지 않는다.
- 하나의 복합 기술에 독립 공격 효과가 여러 개 있다면 각 공격 효과는 자체 첫 합을 가질 수 있지만, 절초기세는 원본 공격 행동당 최대 +1이다.

## 3. 부분 파훼

해당 공격 행동으로 체력 피해가 1 이상 발생하면 완전 파훼가 아니다.

- 일부 피해 단위 취소는 `부분 파훼` 로그로 기록한다.
- 부분 파훼는 완전 파훼 사건으로 승격하지 않는다.
- 현재 전투 종료 5지표 산식에 완전·부분 파훼 전용 점수를 자동 추가하지 않는다.

## 4. 전투 보상·등급 분리

- 실제 첫 합 승리가 발생하면 절초기세 +1과 `ON_CLASH_WIN`은 정상 처리한다.
- 절초기세는 공격 행동당 최대 +1이다.
- 완전 파훼 여부가 이미 발생한 합 승리 보상을 취소하지 않는다.
- 현재 전투 종료 등급은 회피 성공·합 승리·잃은 체력·라운드 수·절초 사용의 원자료를 사용한다.
- 완전 파훼 사건과 반복 감쇠는 현재 등급 점수에 자동 적용하지 않는다.

## 5. 사거리 안·밖·부가효과

- 사거리 안·밖 모두 최종 체력 피해 0 기준을 사용한다.
- 방어·합으로 체력 피해 0이지만 밀치기가 적용될 수 있다.
- 해당 피해 단위를 회피하면 밀치기 같은 회피 가능 부가효과가 적용되지 않는다.
- 결과 화면은 체력 피해 차단과 부가효과 적용을 분리한다.

## 6. 검증 요구

1. 연격 공격의 최종 체력 피해가 0이면 완전 파훼 사건 1회임.
2. 체력 피해가 1 이상이면 부분 파훼 로그만 남음.
3. 첫 피해 단위만 합에 참여하고 후속 피해 단위는 다시 합하지 않음.
4. 첫 합 패배·동점 시 후속 피해 단위가 취소됨.
5. 한 공격 행동의 절초기세 획득은 최대 +1임.
6. 부가효과가 남아도 체력 피해 0이면 완전 파훼 사건임.
7. 완전 파훼 전용 점수·반복 감쇠가 현 5지표 등급에 자동 적용되지 않음.

## 7. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING_LOG_EVENT
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
counting_unit: ATTACK_ACTION
maximum_complete_parry_event_per_attack_action: 1
complete_parry_condition: ZERO_HEALTH_DAMAGE_FROM_ATTACK_ACTION
clash_participating_packet: FIRST_DAMAGE_PACKET_ONLY
losing_attack_followups_cancelled: true
followup_packets_reclash: false
secondary_effects_cancel_complete_parry: false
ultimate_momentum_max_gain_per_attack_action: 1
current_grade_direct_complete_parry_score: false
current_grade_repeat_attenuation: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 6/10
```
