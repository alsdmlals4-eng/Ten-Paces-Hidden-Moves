# 사거리 밖 합 승리의 전투 종료 등급 가치 결정

- Decision ID: `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING_WITH_SUPERSEDED_SCORE_CATEGORY`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `3/10`
- 선행 결정: `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
- 후속 평가 정본: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`

## 1. 현재 유지되는 결론

동일한 상대 공격을 무효화한 사거리 안 합 승리와 사거리 밖 합 승리는 전투 종료 5개 핵심 원자료 중 `합 승리 횟수`에서 동일하게 1회로 기록한다.

```text
사거리 안 정상 합 승리 1회
=
사거리 밖 정상 합 승리 1회
```

- 사거리 밖이라는 이유로 합 승리 횟수를 50%나 소수 값으로 감액하지 않는다.
- 사거리 밖 승리는 피해·적중·체력 감소를 자동 생성하지 않는다.
- 결과·복기는 합 승리, 절초기세 획득, 사거리 밖 피해 0을 구분해 표시한다.

## 2. 후속 Decision으로 대체된 부분

이 Decision 작성 당시 사용한 `위협 대응` 점수 카테고리와 사건당 가치 표현은 후속 `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`로 대체됐다.

현재 비활성:

- `위협 대응30` 카테고리 입력
- 위협 대응 사건당 고정 점수
- 전술 실행과의 점수 이중 가산 검사
- 동일 위협 100%→50%→0% 감쇠

전투 사건 로그와 사거리 안·밖의 합 승리 횟수 대칭만 유지한다.

## 3. 적용 범위

- 주요 비무 1~10
- 천하제일인전
- 전투 종료 `S/A/B/C` 평가를 사용하는 향후 모드

온라인 시즌 평점·순위 산정은 변경하지 않는다.

## 4. 검증 요구

1. 동일한 적 공격을 사거리 안·밖에서 합으로 취소하면 각각 `합 승리 횟수` 1회다.
2. 사거리 밖 승리가 체력 피해·적중 성공으로 기록되지 않는다.
3. 결과 화면에서 합 승리·절초기세·피해 0 원인을 분리한다.
4. 레거시 위협 대응 점수와 반복 감쇠를 적용하지 않는다.
5. 온라인 시즌 평점 계산에 영향이 없다.

## 5. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING_WITH_SUPERSEDED_SCORE_CATEGORY
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
current_battle_grade_metric: clash_wins
in_range_count: 1
out_of_range_count: 1
legacy_battle_grade_category: SUPERSEDED_THREAT_RESPONSE
automatic_damage_or_hit_credit: false
repeat_attenuation_active: false
online_season_rating_change: NONE
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 3/10
```
