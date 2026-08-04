# [대체됨] 여섯 시작 무공 3성 기술1 기본 효과·예산 결정

- Decision ID: `TEN-DEC-20260803-STARTING-MARTIAL-TECHNIQUE-1-BASE-EFFECTS-AND-BUDGETS-01`
- 승인일: 2026-08-03
- 상태: `SUPERSEDED`
- 생명주기 표시: `[대체됨]`
- 구현 권한: `HISTORICAL_PLANNING_EVIDENCE_ONLY`
- 대체 Decision: `TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01`
- 현재 효과·조건·5성 권위: `docs/planning-data/approved_20260804_technique1_conditional_rework_star5_contract.json`
- 현재 유효 비용·슬롯 권위: `docs/planning-data/approved_20260804_existing_action_reprice_contract.json`
- 역사 원본 blob: `e8c132eda7debd54623c6e28d11a2b400d420007`
- 역사 병합 계보: PR #84, merge `81765e35c179b7a57eaa527a307080b63c32f0b8`

> 이 문서는 현재 기술1의 효과·비용·조건을 구현하는 근거가 아니다. 2026-08-03 당시 승인 구조를 추적하는 역사 포인터이며, 현재 구현은 반드시 두 2026-08-04 계약을 합성해야 한다.

## 과거 승인 범위

과거 버전은 여섯 기술1의 명칭·역할·기준 능력치4 공식과 당시 비용을 승인했다.

- 유운삼첩
- 금강가세
- 운수회신
- 추풍일섬
- 청심조식
- 철각유영

해당 상세 수치와 원문은 Git 역사 원본 blob 및 PR #84 계보에서 재현한다.

## 현재 권위로 대체된 항목

- 기술1 효과와 성공·실패 경로.
- 조건 난도 가격과 all-or-nothing 지급.
- 유운삼첩 총피해 선계산·타격 분배.
- 5성 무료20% 강화.
- 운수회신·추풍일섬·철각유영 등의 유효 자원 비용.

## 허용·금지

허용:

- before/after 설계 감사.
- migration·회귀 테스트.
- 명칭·역할 계보 추적.

금지:

- 이 문서의 과거 표를 제품 카드·런타임 데이터에 직접 사용.
- 현재 밸런스 근거로 인용.
- 구형 계약만 읽고 기술1을 생성.

이 문서 또는 역사 계약의 구형 수치를 현재 구현에 직접 사용하면 `CANON_CONFLICT`다.

```yaml
authority_status: SUPERSEDED
lifecycle_label_ko: "[대체됨]"
superseded_by: TEN-DEC-20260804-TECHNIQUE1-CONDITIONAL-REWORK-STAR5-01
current_effect_contract: approved_20260804_technique1_conditional_rework_star5_contract.json
current_cost_contract: approved_20260804_existing_action_reprice_contract.json
allowed_use: HISTORICAL_EFFECT_EVIDENCE_ONLY
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
human_validation: NOT_RUN
```
