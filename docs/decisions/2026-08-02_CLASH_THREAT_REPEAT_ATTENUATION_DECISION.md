# 반복 합 파훼의 위협 대응 감쇠 결정

- Decision ID: `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `4/10`
- 선행 결정: `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`

## 1. 승인 결론

한 전투 안에서 같은 적 기술 또는 같은 기초 공격 유형을 `[합]`으로 반복 무효화할 때, 전투 종료 `위협 대응` 점수 기여도는 다음처럼 감쇠한다.

| 같은 위협의 성공 횟수 | 위협 대응 가치 |
|---:|---:|
| 첫 번째 | 100% |
| 두 번째 | 50% |
| 세 번째 이후 | 0% |

- 다른 적 기술 또는 다른 기초 공격 유형을 처음 파훼하면 다시 100%로 계산한다.
- 감쇠 카운트는 각 전투 시작 시 0으로 초기화한다.
- 사거리 안 합 승리와 사거리 밖 합 승리에 완전히 같은 감쇠 규칙을 적용한다.
- 사거리 밖이라는 이유로 별도 감액하지 않는다.

## 2. 감쇠 적용 범위

이 감쇠는 전투 종료 `S/A/B/C` 평가 중 `위협 대응` 점수에만 적용한다.

감쇠하지 않는 항목:

- `[합]` 승패 판정
- 패자의 현재 피해 단위 취소
- 절초기세 +1
- `ON_CLASH_WIN`
- 전투 로그와 복기 사건
- 실제 사거리·적중·피해 판정

세 번째 이후 같은 위협을 다시 막아도 전투적으로는 정상적인 합 승리이며, 점수 기여만 0%다.

## 3. 대칭성과 중복 방지

- 사거리 안·밖 성공에 같은 반복 카운트를 사용한다.
- 같은 한 번의 파훼 사건을 `위협 대응`과 `전술 실행`에 자동 이중 가산하지 않는다.
- 여러 타격을 가진 한 공격 행동의 동일한 위협 카운트 단위는 후속 성과 산식에서 확정한다.
- 위협 ID의 정확한 데이터 키도 후속 성과 데이터 계약에서 확정하되, 단순 `[공격]` 공개 종류 전체를 하나의 위협으로 묶어서는 안 된다.

## 4. 설계 목적

- 약한 공격을 반복 유도해 위협 대응 30점을 채우는 점수 파밍을 억제한다.
- 같은 패턴을 두 번 안정적으로 읽어낸 숙련도까지는 인정한다.
- 다양한 위협을 파훼한 플레이를 더 높게 평가한다.
- 평가 감쇠가 실제 전투 보상을 약화시키지 않게 한다.

## 5. 결과·복기 표시

결과 화면은 필요할 경우 같은 위협의 성공 횟수와 점수 반영률을 구분해 표시한다.

```text
첫 파훼: 위협 대응 100%
두 번째 파훼: 위협 대응 50%
세 번째 이후: 전투 기록만 유지, 추가 점수 없음
```

절초기세 획득과 공격 무효화 결과는 감쇠 여부와 별도로 표시한다.

## 6. 검증 요구

1. 같은 적 기술 첫 파훼는 100%, 두 번째는 50%, 세 번째는 0%로 입력됨.
2. 다른 적 기술의 첫 파훼는 다시 100%로 입력됨.
3. 사거리 안 첫 성공 뒤 사거리 밖 두 번째 성공도 같은 위협의 두 번째 50%로 계산됨.
4. 세 번째 이후에도 절초기세·`ON_CLASH_WIN`·로그는 정상 발생함.
5. 새 전투 시작 시 반복 카운트가 초기화됨.
6. 같은 사건이 전술 실행에 자동 중복 가산되지 않음.
7. 온라인 시즌 평점·챔피언 랭킹에는 영향이 없음.

## 7. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
battle_grade_category: threat_response
repeat_multipliers: [1.0, 0.5, 0.0]
reset_scope: per_battle
in_range_out_of_range_symmetric: true
combat_rewards_attenuated: false
online_season_rating_change: NONE
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 4/10
```
