# 자원 포화 위험 — 내력 자동 회복 제거 설계

- 설계일: 2026-08-04
- 대상 위험: `RESOURCE_SATURATION_RISK`
- 제안 Decision: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`
- 기준 정본: `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`
- 범위: 기획·정본·검증·Sheet 동기화
- 제품 런타임: 변경하지 않음

## 1. 목표

세 자원의 역할을 분리한다.

```text
기력 = 묶음 단위 전술 템포
내력 = 여러 묶음에 걸쳐 관리하는 장기 자원
절초기세 = 전투 진행과 성공 사건으로 축적하는 승부 자원
```

묶음 전환 자동 회복에서 내력을 제거하여 고내력 기술의 연속 난사를 억제하고, 내력 회복 행동을 상대가 읽고 대응할 수 있는 계획 선택으로 만든다.

## 2. 승인 규칙

전투 최초 1묶음 시작을 제외한 모든 묶음 전환에서 생존한 양측에 다음을 적용한다.

```yaml
stamina_gain: 1
internal_gain: 0
ultimate_momentum_gain: 1
resource_caps_apply: true
```

적용 전환은 기존과 동일하다.

- `BUNDLE_1_TO_2`
- `BUNDLE_2_TO_3`
- `BUNDLE_3_TO_NEXT_ROUND_BUNDLE_1`

라운드 시작에 별도 내력 자동 회복을 추가하지 않는다.

## 3. 유지되는 명시적 내력 회복

다음은 자동 회복이 아니므로 유지한다.

- 준비된 명상의 내력 +1
- 청심조식의 기본·조건부 내력 회복
- 운수회신 등 승인된 조건부 내력 회수
- 향후 별도 Decision으로 승인된 내력 회복 효과

모든 조건부 회복은 기존 all-or-nothing 조건 계약을 따른다. 조건 실패 시 해당 회복은 0이다.

## 4. 소프트락 방지

내력 0에서도 합법적인 행동 묶음을 만들 수 있어야 한다.

- 무비용 기본 행동
- 이동
- 준비
- 명상
- 청심조식
- 내력을 요구하지 않는 기력 기반 행동

내력 부족은 선택을 제한할 수 있지만 행동 불능을 만들어서는 안 된다.

## 5. 회복 행동 강제 세금 방지

청심조식·준비→명상이 지나치게 자주 필수가 되면 선택이 아니라 세금이다. 다음 측정값을 후속 사람 검증 Gate로 둔다.

### 핵심 지표

1. `internal_zero_bundle_rate`
   - 묶음 계획 시 내력 0인 생존 플레이어-묶음 수 / 전체 생존 플레이어-묶음 수
2. `internal_constraint_plan_change_rate`
   - 내력 부족으로 우선 계획을 다른 합법 계획으로 바꾼 묶음 수 / 전체 계획 묶음 수
3. `high_internal_action_consecutive_rate`
   - 명시적 내력 회복 없이 연속 묶음에서 내력 2 이상 행동을 사용한 사례 / 내력 2 이상 행동 사용 사례

### 진단 지표

- 청심조식 선택률
- 준비→명상 완주율
- 내력 회복 행동 피격·중단률
- 내력 3 기술 평균 사용 간격
- 전투 종료 잔여 내력
- 자동 회복 낭비율: 내력은 항상 0이어야 하며 기력·절초기세만 측정

### 가드레일

- 내력 회복 행동이 전체 행동 묶음의 절반에 근접하면 `RECOVERY_TAX_RISK`로 재검토한다.
- 내력 부족 때문에 무비용 기본 행동만 반복하는 패턴이 우세하면 `RESOURCE_STARVATION_RISK`로 재검토한다.
- 사람 검증 전에는 위 위험을 PASS로 표시하지 않는다.

수치 임계치는 실제 플레이 로그가 없는 현재 단계에서 확정하지 않는다. 첫 측정 배치 후 기준선과 분포를 공개하고 별도 Decision으로 확정한다.

## 6. 권위 계보와 생명주기

기존 `TEN-DEC-20260804-COMBAT-PRICING-INTERRUPTION-RECOVERY-01`은 거리 가격·전조 중단·준비·예산·절초기세 규칙의 현행 권위를 유지한다.

단, 다음 필드는 `[대체됨]`이다.

```text
bundle_transition_recovery.internal: 1
```

새 Decision과 새 approved overlay가 최종 권위를 가진다.

```text
bundle_transition_recovery.internal: 0
```

기존 Decision·contract는 전체 폐기하지 않는다. 파일 상단과 생명주기 등록부에 부분 대체 계보를 명시하고, 신규 런타임 데이터 생성 시 기존 계약을 읽은 뒤 새 overlay를 적용한다. overlay 미적용 내력 자동 회복은 `CANON_CONFLICT`다.

## 7. 검증 계약

자동 검증은 다음을 강제한다.

- 새 Decision ID와 상태가 정확함
- 부모 계약의 전환 목록·기력1·절초기세1·caps·plan-lock 순서는 유지됨
- 새 overlay의 내력 자동 회복은 정확히 0
- 라운드 시작 별도 내력 자동 회복 없음
- 준비된 명상의 내력1은 유지
- 명시적 내력 회복 경로 목록이 존재
- 소프트락 방지 행동 범주가 존재
- 사람 검증과 밸런스 검증은 `NOT_RUN`
- 부모 계약 내력값 1을 직접 현행 런타임 값으로 사용하면 검증 실패

변조 테스트는 부모 전환 목록, overlay 내력값, 준비된 명상 내력값, 별도 라운드 회복, 검증 경계를 각각 변경해 실패해야 한다.

## 8. 정본 동기화 범위

- 새 Decision 문서
- 새 approved overlay contract
- 기존 전투 Decision의 부분 `[대체됨]` 표기
- 기존 전투 contract의 amendment 포인터
- `docs/02_COMBAT_RULES.md`
- `docs/CANON_LIFECYCLE_REGISTRY.md`
- `ACTIVE_CONTEXT.md`
- `docs/04_ROADMAP.md`
- validator·tests·전용 workflow·PR Validation 연결
- Google Sheet 관련 탭과 변경 이력

## 9. 비범위

- 기력 자동 회복량 변경
- 절초기세 자동 회복량 변경
- 준비된 명상 효과 변경
- 개별 기술의 내력 비용 변경
- 내력 최대치 변경
- Godot·HTML·제품 런타임 구현
- 사람 플레이·Windows·접근성·성능 검증

## 10. 적대적 결론

내력 자동 회복 제거는 자원 포화를 완화하면서 내력 회복을 계획 가능한 행동으로 바꿔 프로젝트의 `관찰 → 추론 → 비공개 계획 → 해결 → 복기` 코어를 강화한다.

그러나 내력 고갈과 회복 행동 강제 위험이 남으므로, 이번 Decision은 자원 포화 위험을 완전히 PASS 처리하지 않는다. 상태는 `MITIGATED_PENDING_HUMAN_MEASUREMENT`이며 후속 로그 측정 없이는 비용·최대치·회복량을 추가 변경하지 않는다.
