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

## 2. 연격 대 연격의 순차 합

- 같은 수에 양측 연격 공격이 충돌하면 현재 순번 피해 단위끼리 앞에서부터 합한다.
- 합 패배는 패자의 현재 피해 단위만 취소하며 동점은 양측 현재 피해 단위만 상쇄한다.
- 현재 순번 정산 뒤 양측 체력 피해가 0이고 두 공격 행동이 유지되며 양쪽에 다음 피해 단위가 있으면 다음 순번도 합한다.
- 체력 피해로 한쪽 공격이 중단되면 해당 공격의 미실행 후속 피해 단위를 취소한다.
- 강건 등 명시적 중단 방지가 공격을 유지시키면 다음 순번 합을 계속할 수 있다.
- 한쪽 피해 단위 목록이 먼저 끝나면 상대의 유지된 잔여 피해 단위는 단독 타격으로 해결한다.
- 여러 순번의 합에서 승리해도 절초기세는 원본 공격 행동당 최대 +1이다.

## 3. 부분 파훼

해당 공격 행동으로 체력 피해가 1 이상 발생하면 완전 파훼가 아니다.

- 일부 피해 단위 취소는 `부분 파훼` 로그로 기록한다.
- 부분 파훼는 완전 파훼 사건으로 승격하지 않는다.
- 현재 전투 종료 5지표 산식에 완전·부분 파훼 전용 점수를 자동 추가하지 않는다.

## 4. 전투 보상·등급 분리

- 실제 순번별 합 승리가 발생하면 합 승리 사건을 각각 기록한다.
- 절초기세는 공격 행동당 최대 +1이다.
- 완전 파훼 여부가 이미 발생한 합 승리 보상을 취소하지 않는다.
- 현재 전투 종료 등급은 회피 성공·합 승리·잃은 체력·라운드 수·절초 사용의 원자료를 사용한다.
- 완전 파훼 사건과 반복 감쇠는 현재 등급 점수에 자동 적용하지 않는다.
- 한 공격 행동 안의 다수 합 승리 원자료에 대한 정확한 상한·정규화는 후속 결정이다.

## 5. 사거리 안·밖·부가효과

- 사거리 안·밖 모두 현재 순번 피해 단위끼리 합한다.
- 사거리 밖 합 승리로 체력 피해가 0이고 양측 공격이 유지되면 다음 순번도 합한다.
- 방어로 체력 피해 0이지만 밀치기가 적용될 수 있다.
- 해당 피해 단위를 회피하면 밀치기 같은 회피 가능 부가효과가 적용되지 않는다.
- 결과 화면은 체력 피해 차단과 부가효과 적용을 분리한다.

## 6. 검증 요구

1. 연격 `[8,5,7]` 대 `[6,7,4]`에서 각 순번 정산 후 양측 체력 피해가 0이면 3번의 합이 순차 진행됨.
2. 2번째 순번에서 한쪽이 체력 피해로 중단되면 그쪽 잔여 피해 단위가 취소됨.
3. 강건이 중단을 막으면 다음 순번 합이 계속됨.
4. 연격 공격의 최종 체력 피해가 0이면 완전 파훼 사건은 공격 행동당 1회임.
5. 체력 피해가 1 이상이면 부분 파훼 로그만 남음.
6. 여러 합 승리에도 절초기세는 공격 행동당 최대 +1임.
7. 완전 파훼 전용 점수·반복 감쇠가 현 5지표 등급에 자동 적용되지 않음.

## 7. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING_LOG_EVENT
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
counting_unit: ATTACK_ACTION
maximum_complete_parry_event_per_attack_action: 1
complete_parry_condition: ZERO_HEALTH_DAMAGE_FROM_ATTACK_ACTION
clash_packet_scope: CURRENT_PACKET
losing_packet_cancelled_only: true
tied_packets_cancelled_only: true
continue_clash_if_both_attacks_active_and_have_next_packets: true
interruption_cancels_remaining_packets: true
fortitude_may_preserve_attack_and_continue: true
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
