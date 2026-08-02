# 사거리 밖 합 승리 보상 결정

- Decision ID: `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `2/10`
- 선행 결정: `TEN-DEC-20260802-BASIC-ACTIONS-PALM-CLASH-01`
- 현재 평가 정본: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`

## 1. 절초기세

합 승리로 얻는 `기세`는 별도 자원이 아니라 `절초기세`다.

```yaml
resource_id: ultimate_momentum
display_name: 절초기세
range: 0_to_5
clash_win_gain: 1
```

- 합 승리 수와 무관하게 공격 행동당 전투원별 최대 +1이다.
- 최대 5를 초과하지 않는다.
- 정본에서는 혼동 가능한 단독 `기세` 대신 `절초기세`를 쓴다.

## 2. 사거리 밖 합 승리

사거리 밖에서 공격 효과의 첫 피해 단위가 `[합]`에 이긴 경우도 정상 합 승리다.

- 패자의 첫 피해 단위와 후속 피해 단위를 취소한다.
- 승자는 절초기세 +1을 얻는다.
- `ON_CLASH_WIN`을 발동한다.
- 승자 공격의 대상·방향·사거리를 다시 검사한다.
- 사거리·방향을 만족하지 못하면 합 차이 체력 피해와 모든 후속 피해 단위의 체력 피해는 0이다.
- 실제 적중이 없으므로 `ON_HIT`·`ON_HEALTH_DAMAGE`는 발동하지 않는다.
- 밀치기·상태 부여 등 적중 조건 상대 대상 효과도 적용하지 않는다.
- 자기 강화·자원·방어처럼 합 승리 자체를 조건으로 하는 자기 효과는 정상 적용한다.

## 3. 판정 순서

```text
양측 공격 효과의 첫 피해 단위 비교
→ 합 승패·동점
→ 패자 첫 피해 단위와 후속 피해 단위 취소
→ 승자의 합 승리·절초기세+1·ON_CLASH_WIN
→ 승자 공격의 사거리·방향 검사
→ 유효: 첫 합 차이 피해와 후속 피해 단위 해결
→ 무효: 체력 피해·적중 기반 효과 없이 공격 종료
```

## 4. 전투 종료 등급 연결

이 Decision 작성 당시의 `위협 대응30 / 전술 실행25 / 자원15 / 피해 관리15 / 공개 과제15`와 `S85/A70/B55/C0`은 후속 `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`로 비활성화됐다.

현재 유지되는 평가 연결:

- 사거리 밖 합 승리도 5개 핵심 원자료 중 `합 승리 횟수`에 1회 기록한다.
- 사거리 안 합 승리와 사거리 밖 합 승리를 횟수에서 다르게 감액하지 않는다.
- 체력 피해·적중이 없었다는 사실은 별도 로그로 표시한다.
- 동일 위협 100%→50%→0% 감쇠는 현재 등급 산식에 적용하지 않는다.

## 5. 적용 범위

- 싱글플레이 주요 비무
- 천하제일인전
- 5개 핵심 원자료 기반 전투 종료 등급을 사용하는 향후 모드

온라인 시즌 평점·매칭·순위는 변경하지 않는다.

## 6. 검증 요구

1. 거리 3에서 속공이 장풍의 첫 피해 단위와 합 승리하면 장풍 공격 효과가 취소되고 속공 피해는 0이며 절초기세 +1이다.
2. 같은 사례에서 자기 `ON_CLASH_WIN`은 발동하고 `ON_HIT`는 발동하지 않는다.
3. 사거리 밖 밀치기·상태 효과가 적용되지 않는다.
4. 한 공격 행동의 절초기세 획득은 최대 +1이다.
5. 전투 결과의 `합 승리 횟수`에 사거리 밖 승리가 포함된다.
6. 레거시 위협 대응 점수와 반복 감쇠가 자동 적용되지 않는다.
7. 온라인 시즌 평점에는 영향을 주지 않는다.

## 7. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
clash_packet: FIRST_DAMAGE_PACKET_ONLY
losing_attack_followups_cancelled: true
ultimate_momentum_gain: 1
ultimate_momentum_max_per_attack_action: 1
on_clash_win: true
out_of_range_health_damage: 0
on_hit_out_of_range: false
battle_grade_metric: clash_wins
legacy_threat_response_scoring_active: false
repeat_attenuation_active: false
online_season_rating_change: NONE
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 2/10
```
