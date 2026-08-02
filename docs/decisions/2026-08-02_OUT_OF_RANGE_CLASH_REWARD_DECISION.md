# 사거리 밖 합 승리 보상·전투 종료 랭크 반영 결정

- Decision ID: `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-REWARD-01`
- 승인일: 2026-08-02
- 상태: `CURRENT_APPROVED_PLANNING`
- 구현 권한: `PLANNING_ONLY`
- GrillMe 묶음: `2/10`
- 선행 결정: `TEN-DEC-20260802-BASIC-ACTIONS-PALM-CLASH-01`
- 후속 평가 결정: `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`

## 1. 용어 교정

이 결정에서 `랭크`는 온라인 챔피언 배틀의 시즌 랭킹이 아니다.

- 대상: 각 전투 종료 후 산정하는 `S / A / B / C` 성과 등급
- 현행 점수 골격: 위협 대응 30, 전술 실행 25, 자원 운용 15, 피해 관리 15, 공개 과제 15
- 등급 경계: S 85, A 70, B 55, C 0

온라인 랭킹전의 평점·매칭·시즌 순위는 이 Decision의 대상이 아니다.

## 2. `기세`의 정식 의미

합 승리로 얻는 `기세`는 별도 자원이 아니라 기존 `절초기세`다.

```yaml
resource_id: ultimate_momentum
display_name: 절초기세
range: 0_to_5
clash_win_gain: 1
```

- 기존 규칙대로 합 승리 타격 수와 무관하게 공격 행동당 전투원별 최대 +1만 획득한다.
- 절초기세는 최대 5를 초과하지 않는다.
- 앞으로 정본 문서에서 혼동 가능성이 있는 단독 `기세`는 `절초기세`로 표기한다.

## 3. 사거리 밖 합 승리 보상

사거리 밖에서 공격이 `[합]`에 이긴 경우도 정상적인 합 승리로 인정한다.

- 패자의 현재 피해 단위를 취소한다.
- 승자는 절초기세 +1을 얻는다.
- `ON_CLASH_WIN` 계열 효과를 발동한다.
- 자기 자신에게 적용되는 강화·자원·방어 효과는 정상 적용한다.
- 상대 대상 효과는 해당 효과가 선언한 대상·방향·사거리 조건을 다시 검사한다.
- 승자 공격이 상대에게 닿지 않으면 합 차이 체력 피해는 0이다.
- 실제 적중이 없으므로 `ON_HIT`는 발동하지 않는다.
- 실제 체력 피해가 없으면 `ON_HEALTH_DAMAGE`·피해량 기반 효과는 발동하지 않는다.
- 밀치기·상태 부여·표식 등 상대 대상 부가효과도 각각의 사거리·적중 조건을 만족하지 않으면 적용하지 않는다.

## 4. 판정 순서

```text
양측 공격의 현재 피해 단위 비교
→ 합 승패·동점 결정
→ 패자 현재 피해 단위 취소
→ 승자의 합 승리 확정
→ 절초기세 +1과 ON_CLASH_WIN 발동
→ 승자 공격·부가효과별 대상·사거리 검사
→ 사거리 안: 허용된 피해·대상 효과 적용
→ 사거리 밖: 상대 체력 피해·적중·피해 기반 효과 0
```

합 승리 보상과 실제 적중은 서로 다른 판정 단계다.

## 5. 전투 종료 랭크 반영

사거리 밖 합 승리는 상대 공격을 무효화한 유효한 파훼이므로 전투 종료 평가에 반영한다.

- 결과 로그에 `out_of_range_clash_win` 사건을 기록한다.
- 해당 사건은 `위협 대응` 항목의 성공 증거로 계산한다.
- 사거리 안 합 승리와의 상대적 평가 가치는 후속 Decision `TEN-DEC-20260802-OUT-OF-RANGE-CLASH-GRADE-01`에 따라 동일하다.
- 같은 한 번의 사건을 `위협 대응`과 `전술 실행`에 자동으로 이중 가산하지 않는다.
- 전술 실행 점수는 행동 순서·거리 계획·자원 계획 등 별도 성과 규칙을 충족했을 때만 독립 산정한다.
- 결과·복기 화면은 `사거리 밖에서 상대 공격을 합으로 무효화`한 사실과 획득한 절초기세를 표시한다.
- 정확한 사건당 점수·상한·반복 감쇠는 후속 성과 산식 데이터에서 확정하되, 사건을 점수 계산에서 제외할 수는 없다.

## 6. 적용 범위

- 싱글플레이 주요 비무
- 천하제일인전
- 전투 종료 S/A/B/C 평가가 존재하는 향후 모드

이 Decision은 온라인 시즌 평점이나 PvP 랭킹 산정 공식을 변경하지 않는다.

## 7. 검증 요구

1. 거리 3에서 속공이 장풍과 합 승리: 장풍 현재타 취소, 속공 피해 0, 속공 사용자 절초기세 +1.
2. 같은 사례에서 `ON_CLASH_WIN` 자기 강화는 발동하고 `ON_HIT`는 발동하지 않음.
3. 상대 대상 밀치기·상태 효과가 사거리 밖이면 적용되지 않음.
4. 한 공격 행동이 여러 합을 이겨도 절초기세 획득은 최대 +1.
5. 전투 종료 결과에 사거리 밖 합 승리가 `위협 대응` 증거로 기록됨.
6. 같은 사건이 위협 대응·전술 실행에 자동 이중 가산되지 않음.
7. 온라인 시즌 평점 계산에는 이 Decision을 근거로 임의 보정을 추가하지 않음.

## 8. 구현·증거 경계

```yaml
authority_status: CURRENT_APPROVED_PLANNING
scope_status: POC_PRIMARY
implementation_status: NOT_STARTED
battle_grade_integration: APPROVED
relative_battle_grade_value: EQUAL_TO_IN_RANGE_CLASH_WIN
online_season_rating_change: NONE
static_validation: PENDING_DRAFT_PR
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
grillme_count: 2/10
```
