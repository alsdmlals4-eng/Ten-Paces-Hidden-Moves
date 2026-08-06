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

- 한 공격 행동 안에서 여러 순번의 합을 이겨도 절초기세는 전투원별 최대 +1이다.
- 최대 5를 초과하지 않는다.
- 정본에서는 혼동 가능한 단독 `기세` 대신 `절초기세`를 쓴다.

## 2. 사거리 밖 현재 순번 합 승리

사거리 밖에서 공격 효과의 현재 순번 피해 단위가 `[합]`에 이긴 경우도 정상 합 승리다.

- 패자의 현재 피해 단위만 취소한다.
- 동점은 양측 현재 피해 단위만 상쇄한다.
- 승자는 공격 행동당 상한 안에서 절초기세 +1을 얻는다.
- `ON_CLASH_WIN`을 발동한다.
- 승자 현재 피해 단위의 대상·방향·사거리를 다시 검사한다.
- 사거리·방향을 만족하지 못하면 해당 피해 단위의 체력 피해와 적중 기반 효과는 0이다.
- 자기 강화·자원·방어처럼 합 승리 자체를 조건으로 하는 자기 효과는 정상 적용한다.

## 3. 연격의 다음 순번

사거리 밖 합으로 양측 체력 피해가 0이라고 해서 공격 행동 전체가 종료되지는 않는다.

```text
현재 순번 사거리 밖 합
→ 패자 현재 피해 단위 취소 또는 동점 상쇄
→ 승자 대상 피해 0
→ 중단 없음
→ 양측 공격이 유지되고 다음 피해 단위가 모두 있으면 다음 순번 합
```

- 다음 순번도 사거리와 무관하게 합 비교를 먼저 한다.
- 어느 순번에서든 실제 체력 피해로 한쪽 공격이 중단되면 그쪽 미실행 후속 피해 단위를 취소한다.
- 강건 등 중단 방지가 공격을 유지시키면 다음 순번 합을 계속할 수 있다.
- 한쪽 피해 단위 목록이 먼저 끝나면 상대의 유지된 잔여 피해 단위는 단독 타격으로 해결한다.

## 4. 판정 순서

```text
양측 현재 순번 피해 단위 비교
→ 합 승패·동점
→ 패자 현재 피해 단위 취소 / 동점 상쇄
→ 합 승리·절초기세 상한·ON_CLASH_WIN
→ 승자 현재 피해 단위의 사거리·방향 검사
→ 유효: 합 차이 피해와 효과 해결
→ 무효: 체력 피해·적중 기반 효과 없이 현재 피해 단위 종료
→ 중단·강건
→ 양측 공격 유지 여부와 다음 피해 단위 확인
```

## 5. 전투 종료 등급 연결

이 Decision 작성 당시의 `위협 대응30 / 전술 실행25 / 자원15 / 피해 관리15 / 공개 과제15`와 `S85/A70/B55/C0`은 후속 `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`로 비활성화됐다.

현재 유지되는 평가 연결:

- 사거리 밖 합 승리도 5개 핵심 원자료 중 `합 승리 횟수`에 실제 사건 1회로 기록한다.
- 연격 한 공격 행동 안에서 여러 순번 합 승리가 발생하면 각 사건을 원자료에 기록한다.
- 사거리 안 합 승리와 사거리 밖 합 승리를 횟수에서 다르게 감액하지 않는다.
- 체력 피해·적중이 없었다는 사실은 별도 로그로 표시한다.
- 동일 위협 100%→50%→0% 감쇠는 현재 등급 산식에 적용하지 않는다.

## 6. 적용 범위

- 싱글플레이 주요 비무
- 천하제일인전
- 5개 핵심 원자료 기반 전투 종료 등급을 사용하는 향후 모드

온라인 시즌 평점·매칭·순위는 변경하지 않는다.

## 7. 검증 요구

1. 거리 3에서 속공이 장풍의 현재 피해 단위와 합 승리하면 속공 피해는 0이고 절초기세 상한 안에서 +1이다.
2. 같은 사례에서 자기 `ON_CLASH_WIN`은 발동하고 `ON_HIT`는 발동하지 않는다.
3. 양측 연격의 현재 피해 단위가 사거리 밖 합으로 체력 피해 0이 되면 다음 피해 단위도 합한다.
4. 한 공격 행동에서 여러 합을 이겨도 절초기세 획득은 최대 +1이다.
5. 전투 결과의 `합 승리 횟수`에 사거리 밖의 실제 합 승리 사건이 포함된다.
6. 레거시 위협 대응 점수와 반복 감쇠가 자동 적용되지 않는다.
7. 온라인 시즌 평점에는 영향을 주지 않는다.

## 8. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
clash_packet_scope: CURRENT_PACKET
losing_packet_cancelled_only: true
tied_packets_cancelled_only: true
continue_clash_if_both_attacks_active_and_have_next_packets: true
out_of_range_health_damage: 0
out_of_range_on_hit: false
ultimate_momentum_max_per_attack_action: 1
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
