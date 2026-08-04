# 자원 포화 위험 — 내력 자동 회복 제거 결정

- Decision ID: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`
- 승인일: 2026-08-05
- 상태: `CURRENT_APPROVED_PLANNING`
- 위험 상태: `MITIGATED_PENDING_HUMAN_MEASUREMENT`
- 부모 Decision: `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`
- 상세 계약: `docs/planning-data/approved_20260804_resource_saturation_internal_recovery_contract.json`
- 제품 런타임: `NOT_IMPLEMENTED`

## 1. 승인 결론

묶음 전환 자동 회복은 다음으로 변경한다.

```yaml
stamina_gain: 1
internal_gain: 0
ultimate_momentum_gain: 1
resource_caps_apply: true
```

첫 묶음 시작에는 회복하지 않고, `1→2`, `2→3`, `3→다음 라운드1` 전환에만 적용한다. 라운드 시작 별도 내력 자동 회복도 없다.

## 2. 자원 정체성

- 기력: 묶음 단위 전술 템포
- 내력: 여러 묶음에 걸쳐 관리하는 장기 자원
- 절초기세: 전투 진행과 성공 사건으로 축적하는 승부 자원

내력은 자동 충전이 아니라 계획에 포함하는 회복 행동과 성공 조건으로만 회복한다.

## 3. 유지되는 내력 회복 경로

- 준비된 명상: 내력 +1
- 청심조식의 승인된 기본·조건부 내력 회복
- 운수회신 등 승인된 조건부 내력 회수
- 향후 별도 Decision으로 승인되는 내력 회복 효과

조건부 회복은 조건 실패 시 전부 0이며 부분 지급·이월·대체가 없다.

## 4. 소프트락 방지

내력 0에서도 무비용 기본 행동, 이동, 준비, 명상, 청심조식, 내력 비소모 행동으로 합법적인 행동 묶음을 만들 수 있어야 한다. 내력 부족은 선택을 제한할 수 있지만 행동 불능을 만들 수 없다.

## 5. 측정 Gate

핵심 지표:

1. `internal_zero_bundle_rate`
2. `internal_constraint_plan_change_rate`
3. `high_internal_action_consecutive_rate`

진단 지표:

- 청심조식 선택률
- 준비→명상 완주율
- 내력 회복 행동 피격·중단률
- 내력3 행동 평균 사용 간격
- 전투 종료 잔여 내력

가드레일:

- 회복 행동이 강제 세금이 되면 `RECOVERY_TAX_RISK`
- 내력 부족으로 무비용 기본 행동 반복이 우세하면 `RESOURCE_STARVATION_RISK`

실제 사람 플레이 첫 측정 배치 전에는 임계값을 확정하지 않는다.

## 6. 부분 대체 계보

부모 Decision은 거리 가격·전조 중단·준비·예산·절초기세 규칙의 현행 권위를 유지한다. 다음 필드만 `[대체됨]`이다.

```text
bundle_transition_recovery.internal: 1
→ bundle_transition_recovery.internal: 0
```

신규 런타임 데이터는 부모 계약을 읽은 뒤 이 overlay를 적용해야 한다. overlay 없이 부모 내력 자동 회복 1을 사용하면 `CANON_CONFLICT`다.

## 7. 비범위

- 기력·절초기세 자동 회복량 변경 없음
- 준비된 명상 효과 변경 없음
- 개별 행동의 내력 비용 변경 없음
- 내력 최대치 변경 없음
- Godot·HTML·제품 런타임 변경 없음

## 8. 검증 경계

```yaml
static_validation: REQUIRED
human_validation: NOT_RUN
balance_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
performance_validation: NOT_RUN
```
