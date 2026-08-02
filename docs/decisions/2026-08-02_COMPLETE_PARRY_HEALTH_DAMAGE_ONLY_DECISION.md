# 완전 파훼의 체력 피해 기준 결정

- Decision ID: `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING_LOG_EVENT`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `7/10`
- 선행 결정: `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`
- 현재 평가 정본: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`

## 1. 승인 결론

완전 파훼 로그·복기 사건은 **해당 공격 행동으로 받은 체력 피해가 0인지**만으로 판정한다.

- 공격 행동의 피해 단위가 취소되었거나 방어·합·회피 결과 최종 체력 피해가 0이면 완전 파훼다.
- 밀치기·위치 이동·경직·상태 이상·자원 감소 등 일부 적대적 부가효과가 남아도 완전 파훼 사건을 취소하지 않는다.
- 부가효과를 막았는지는 완전 파훼와 별도 사건으로 기록한다.
- 한 공격 행동당 완전 파훼 사건은 최대 1회다.

## 2. 회피와 부가효과

일부 적대적 부가효과는 해당 피해 단위를 회피해야 무효화된다.

대표 예시:

```text
방어/합: 체력 피해 0, 밀치기 적용
→ 완전 파훼 + 부가효과 피격

회피: 체력 피해 0, 밀치기 미적용
→ 완전 파훼 + 회피 성공
```

- 밀치기 공격은 방어로 체력 피해가 0이어도 `ON_HIT`이면 밀치기가 적용될 수 있다.
- 합 승리로 상대 공격 효과가 취소됐다면 상대 밀치기는 적용되지 않는다.
- 해당 공격 피해 단위를 회피하면 체력 피해와 회피 가능 밀치기가 모두 적용되지 않는다.
- 모든 부가효과가 회피 전용인 것은 아니며 개별 태그·기술 데이터가 상호작용을 소유한다.

## 3. 전투 종료 등급과의 관계

- 현 전투 종료 등급은 회피 성공·합 승리·잃은 체력·라운드 수·절초 사용의 5개 원자료를 사용한다.
- 완전 파훼 전용 `위협 대응` 점수는 현재 활성 산식이 아니다.
- 100%→50%→0% 반복 감쇠도 현재 적용하지 않는다.
- 완전 파훼와 부가효과 사건은 복기·설명·향후 분석용으로 유지한다.
- 회피 성공이나 합 승리는 각각의 5지표 원자료 규칙에 따라 독립 기록된다.

## 4. 결과·복기 표시

```text
완전 파훼: 체력 피해 0
부가효과: 밀치기 적용 또는 없음
대응 방식: 방어 / 합 / 회피
```

체력 피해 차단과 부가효과 적용을 한 결과로 합치지 않는다.

## 5. 검증 요구

1. 밀치기 공격을 방어해 체력 피해 0·밀치기 적용이면 완전 파훼 사건임.
2. 공격 효과를 합으로 취소해 피해·밀치기 모두 미적용이면 완전 파훼와 합 승리를 분리 기록함.
3. 공격을 회피해 피해·밀치기 미적용이면 완전 파훼와 회피 성공을 분리 기록함.
4. 체력 피해가 1 이상이면 완전 파훼가 아님.
5. 부가효과 피격이 별도 완전 파훼 카운트를 만들지 않음.
6. 완전 파훼 점수·반복 감쇠가 현재 5지표 등급에 자동 적용되지 않음.
7. 온라인 시즌 평점에는 영향이 없음.

## 6. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING_LOG_EVENT
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
complete_parry_primary_condition: ZERO_HEALTH_DAMAGE_FROM_ATTACK_ACTION
hostile_secondary_effects_may_remain: true
secondary_effects_cancel_complete_parry: false
dodge_can_negate_dodgeable_secondary_effects: true
all_secondary_effects_are_dodge_only: false
maximum_complete_parry_event_per_attack_action: 1
current_grade_direct_complete_parry_score: false
current_grade_repeat_attenuation: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 7/10
```
