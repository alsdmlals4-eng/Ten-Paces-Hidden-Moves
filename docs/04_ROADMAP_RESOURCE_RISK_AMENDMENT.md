# 자원 위험 작업 순서 현행 개정

- 상태: `[현행]`
- Decision ID: `TEN-DEC-20260804-RESOURCE-SATURATION-INTERNAL-RECOVERY-01`
- 부모 로드맵: `docs/04_ROADMAP.md`
- 적용 범위: 핵심 위험 우선순위와 다음 기획 Gate

## 대체되는 구형 순서

`docs/04_ROADMAP.md`에서 `RESOURCE_SATURATION_RISK`를 단순 미실측 상태로 유지하고 곧바로 9성 공통 템플릿으로 이동하는 순서는 `[대체됨]`이다.

## 현재 위험 순서

```text
RESOURCE_SATURATION_RISK 완화·측정 계약
→ CONDITION_CALIBRATION_RISK
→ WRONG_PLAN_RESCUE_RISK
→ OBSERVATION_ANSWER_LEAK_RISK
→ GRADE_FARMING_RISK
→ STAR9_PUBLIC_READ_BRANCH_TEMPLATE
→ 여섯 개별 9성 분기
→ 여섯 10성 고유 절초
→ 비스탯 노드 기대가치·배치
→ 전체 핵심 재미·정본 적대적 검토
→ 기획 완료 Gate
→ 이미지 Gate
→ 별도 Build 승인
```

## 현재 상태

- `RESOURCE_SATURATION_RISK`: `MITIGATED_PENDING_HUMAN_MEASUREMENT`
- 묶음 전환 회복: 기력1·내력0·절초기세1
- 내력 자동 회복: 없음
- 남은 가드레일: `RECOVERY_TAX_RISK`, `RESOURCE_STARVATION_RISK`
- 다음 위험: `CONDITION_CALIBRATION_RISK`

## 다음 위험 완료 조건

조건 난도 보정 계약은 다음을 필수로 한다.

- 기술별 조건의 선언 난도와 예상 성공률 구간
- 실제 성공률 수집 단위
- 실패 지점 분해
- 저점 수용도와 고점 만족도
- 조건 때문에 기술을 포기한 비율
- 관측값이 선언 구간을 벗어날 때 가격·조건·효과를 수정하는 Gate

## 구현 경계

최신 위험 계약이 모두 확정되기 전 제품 런타임을 부분 구현해 완료로 주장하지 않는다. Godot·Windows·접근성·성능·사람 플레이·밸런스 검증은 `NOT_RUN`이다.
