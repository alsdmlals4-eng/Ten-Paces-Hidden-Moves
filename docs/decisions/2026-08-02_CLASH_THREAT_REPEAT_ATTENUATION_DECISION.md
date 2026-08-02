# 반복 합 파훼 감쇠 후보 결정

- Decision ID: `TEN-DEC-20260802-CLASH-THREAT-ATTENUATION-01`
- 승인일: 2026-08-02
- 상태: `SUPERSEDED_FOR_CURRENT_BATTLE_GRADE`
- 구현 권한: `HOLD_PLANNING_CANDIDATE`
- GrillMe 묶음: `4/10`
- 선행 결정: `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`
- 대체 결정: `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`

## 1. 역사적 승인안

기존 위협 대응 점수 체계에서는 같은 공격 ID의 반복 합 파훼에 다음 감쇠를 적용하기로 했다.

| 같은 위협의 성공 횟수 | 과거 위협 대응 가치 |
|---:|---:|
| 첫 번째 | 100% |
| 두 번째 | 50% |
| 세 번째 이후 | 0% |

사거리 안·밖에는 같은 감쇠를 적용하고 전투 판정·절초기세·`ON_CLASH_WIN`·로그는 감쇠하지 않는 안이었다.

## 2. 현재 권위

후속 `TEN-DEC-20260802-BATTLE-GRADE-FIVE-METRICS-01`이 전투 종료 등급의 핵심 입력을 아래 5개로 교체했다.

- 회피 성공 횟수
- 합 승리 횟수
- 플레이어가 잃은 체력
- 전투 라운드 수
- 절초 사용 여부·횟수

따라서 현재는:

- `100%→50%→0%` 감쇠를 전투 종료 등급에 적용하지 않는다.
- 같은 공격 ID를 반복해서 합으로 이겨도 `합 승리 횟수` 원자료에는 실제 성공 횟수를 기록한다.
- 파밍 방지가 필요하면 5개 지표의 정규화·상한·감쇠를 별도 GrillMe로 다시 승인한다.
- 이 문서는 미래 파밍 방지 후보와 역사 근거로만 보존한다.

## 3. 유지되는 비점수 계약

- 전투 로그에서 공격 행동의 안정 ID를 기록할 수 있다.
- 합 판정·절초기세·`ON_CLASH_WIN`은 반복 횟수로 약화되지 않는다.
- 사거리 안·밖 합 승리는 같은 판정 규칙을 따른다.
- 온라인 시즌 평점에는 이 감쇠를 적용하지 않는다.

## 4. 검증 요구

1. 현 전투 종료 등급 계산에 100%→50%→0%가 적용되지 않음.
2. 실제 합 승리 횟수 원자료가 반복 성공을 누락하지 않음.
3. 전투 판정·절초기세·로그가 감쇠되지 않음.
4. 향후 재도입 시 새 Decision ID와 5지표 산식 연결이 필요함.
5. 온라인 시즌 평점에 영향이 없음.

## 5. 구현·증거 경계

```yaml
authority_status: SUPERSEDED_FOR_CURRENT_BATTLE_GRADE
scope_status: HOLD_FUTURE_ANTI_FARMING_CANDIDATE
implementation_status: DEFERRED
historical_repeat_multipliers: [1.0, 0.5, 0.0]
current_battle_grade_application: false
current_clash_win_raw_count_records_all_successes: true
combat_rewards_attenuated: false
online_season_rating_change: NONE
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 4/10
```
