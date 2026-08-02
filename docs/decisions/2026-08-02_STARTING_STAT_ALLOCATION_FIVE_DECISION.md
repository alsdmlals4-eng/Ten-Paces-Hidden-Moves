# 시작 스테이터스 자유 분배 5점 결정 — 대체됨

- Decision ID: `TEN-DEC-20260802-STARTING-STAT-ALLOCATION-FIVE-01`
- 승인일: 2026-08-02
- 상태: `SUPERSEDED`
- 후속 권위: `TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01`
- 구현 권한: `NONE_HISTORICAL`
- 당시 GrillMe 묶음: `4/10`

## 역사적 결정

당시에는 다섯 스테이터스를 각각 기본 `2`로 두고 자유 분배 `5점`을 모두 사용하여, 시작 무공 선택 전 총합을 `15`로 두었다.

```text
기본 합계 10 + 자유 분배 5 = 무공 선택 전 총합 15
```

직접 분배 단계의 각 스테이터스 범위는 `2~6`이었고, 선택한 시작 무공 4개의 2성 고정 보너스를 직접 분배 뒤 적용하며 상한 6으로 잘라내지 않는 원칙을 승인했다.

## 대체 이유

후속 검토에서 시작 무공 4개가 각각 2성 고정 보너스 `+1`을 제공하도록 확정되었다. 자유 분배를 `6점`으로 조정하면 다음과 같이 최종 시작 총합과 기준 스테이터스 평균이 정확히 일치한다.

```text
기본 합계 10 + 자유 분배 6 + 무공 보너스 4 = 최종 총합 20
평균 스테이터스 = 4
```

따라서 다음 구형 값은 더 이상 현재 기획에 사용하지 않는다.

- 자유 분배 5점
- 무공 선택 전 총합 15
- 시작 무공 2성 보너스 벡터 미확정
- 최종 시작 총합 미확정

현재 규칙과 보너스 표는 `docs/decisions/2026-08-02_STARTING_STAT_TOTAL20_MANUAL_BONUS_DECISION.md`를 따른다.

```yaml
authority_status: SUPERSEDED
successor_decision: TEN-DEC-20260802-STARTING-STAT-TOTAL20-MANUAL-BONUS-01
historical_free_allocation_points: 5
historical_pre_manual_total_stats: 15
current_use_allowed: false
```
