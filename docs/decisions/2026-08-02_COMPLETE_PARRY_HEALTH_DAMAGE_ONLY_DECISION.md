# 완전 파훼의 체력 피해 기준 결정

- Decision ID: `TEN-DEC-20260802-COMPLETE-PARRY-HP-ONLY-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `7/10`
- 선행 결정: `TEN-DEC-20260802-MULTIHIT-COMPLETE-PARRY-01`

## 1. 승인 결론

전투 종료 `위협 대응` 평가의 완전 파훼는 **해당 공격 행동으로 받은 체력 피해가 0인지**만으로 판정한다.

- 공격 행동의 모든 유효 피해 단위가 취소되었거나 방어·합 등으로 최종 체력 피해가 0이면 완전 파훼다.
- 밀치기·위치 이동·경직·상태 이상·자원 감소 등 일부 적대적 부가효과가 남아도 완전 파훼 판정을 취소하지 않는다.
- 부가효과를 막았는지는 완전 파훼와 별도 사건으로 기록·평가할 수 있다.
- 한 공격 행동당 완전 파훼 카운트는 최대 1회다.

## 2. 회피와 부가효과

일부 적대적 부가효과는 `[회피]`로만 완전히 파훼할 수 있다.

대표 예시:

- `[밀치기]`가 붙은 공격은 `[방어]` 또는 `[합]`으로 체력 피해를 0으로 만들더라도 밀치기가 적용될 수 있다.
- 같은 공격을 `[회피]`로 피하면 체력 피해와 밀치기가 모두 적용되지 않는다.

따라서 다음 두 결과는 모두 체력 피해 기준 완전 파훼이지만 전투 결과는 다르다.

```text
방어/합: 체력 피해 0, 밀치기 적용 → 완전 파훼 + 부가효과 피격
회피: 체력 피해 0, 밀치기 미적용 → 완전 파훼 + 완전 회피
```

기술별 부가효과의 방어·합·회피 상호작용은 해당 기술 데이터와 태그 규칙이 소유한다. 모든 부가효과를 일괄적으로 회피 전용으로 간주하지 않는다.

## 3. 전투 종료 평가

- 완전 파훼의 반복 감쇠는 기존대로 첫 100%, 둘째 50%, 셋째 이후 0%다.
- 밀치기 등 부가효과를 맞았다는 이유로 완전 파훼 점수를 감액하지 않는다.
- 회피로 피해와 부가효과를 모두 피한 경우, 별도 `회피 성공` 또는 `위치 유지` 평가 조건이 있다면 독립적으로 반영할 수 있다.
- 같은 사건을 `위협 대응`과 다른 항목에 자동 이중 가산하지 않는다.

## 4. 결과·복기 표시

결과 화면과 복기는 체력 피해 차단과 부가효과 적용을 분리해 표시해야 한다.

```text
완전 파훼: 체력 피해 0
부가효과: 밀치기 적용
대응 방식: 합 승리
```

또는

```text
완전 파훼: 체력 피해 0
부가효과: 없음
대응 방식: 회피 성공
```

## 5. 검증 요구

1. `[밀치기]` 공격을 방어해 체력 피해 0, 밀치기 적용 시 완전 파훼 1회로 기록됨.
2. 같은 공격을 합으로 상쇄해 체력 피해 0, 밀치기 적용 시 완전 파훼 1회로 기록됨.
3. 같은 공격을 회피해 피해와 밀치기 모두 미적용 시 완전 파훼 1회와 회피 사건이 분리 기록됨.
4. 체력 피해가 1 이상 발생하면 부가효과 유무와 관계없이 완전 파훼로 기록되지 않음.
5. 부가효과 피격이 완전 파훼 반복 카운트를 추가로 소비하지 않음.
6. 전투 보상·절초기세·`ON_CLASH_WIN` 규칙은 기존 Decision을 따름.
7. 온라인 시즌 평점에는 영향이 없음.

## 6. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
complete_parry_primary_condition: ZERO_HEALTH_DAMAGE_FROM_ATTACK_ACTION
hostile_secondary_effects_may_remain: true
secondary_effects_cancel_complete_parry: false
dodge_can_negate_secondary_effects: true
all_secondary_effects_are_dodge_only: false
maximum_complete_parry_count_per_attack_action: 1
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 7/10
```
