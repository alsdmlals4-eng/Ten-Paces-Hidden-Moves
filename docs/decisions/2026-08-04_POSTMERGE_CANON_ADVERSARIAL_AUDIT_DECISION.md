# 병합 후 정본·핵심 재미 적대적 감사 결정

- Decision ID: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`
- 승인일: 2026-08-04
- 상태: `CURRENT_APPROVED_PLANNING_GOVERNANCE`
- 구현 권한: `PLANNING_GOVERNANCE_AND_VALIDATION_ONLY`
- 기준 main 병합 커밋: `0ba841ff2e62b2f716466356dd9e7ffcf587d150`
- 상세 계약: `docs/planning-data/approved_20260804_postmerge_canon_adversarial_audit_contract.json`
- 생명주기 등록부: `docs/CANON_LIFECYCLE_REGISTRY.md`
- 제품 런타임: `NOT_CHANGED`

## 1. 병합 확정

다음 승인 계보를 main 정본으로 확정한다.

| PR | 병합 커밋 | 정본 범위 |
|---:|---|---|
| #84 | `81765e35c179b7a57eaa527a307080b63c32f0b8` | 성장·기술 역할·기술1/2 기반 승인 6/10 |
| #86 | `731e6431e76ebc76841f9253e87cd1e7a693ebb2` | 거리·자원·중단·묶음 회복·기존 행동 repricing |
| #87 | `0ba841ff2e62b2f716466356dd9e7ffcf587d150` | 기술1 조건부 저점/고점·5성 강화·연격 총피해 계약 |

병합 전 PR 번호·stacked parent·`APPROVED_PENDING_MERGE`·`ACTIVE_DRAFT` 상태는 현행 운영 문서에서 제거한다. PR은 역사 계보이고 main의 Decision·approved contract가 현재 권위다.

## 2. 생명주기 상태

- `[현행]`: 현재 기획·검증·후속 작성이 직접 참조한다.
- `[대체됨]`: 새 Decision이 권위를 인수했다. 역사 재현과 migration diff에만 사용한다.
- `[보류]`: 증거는 보존하지만 현재 제품 정본·병합·구현 근거로 사용하지 않는다.
- `[폐기]`: 현재·역사 권위와 복구 가치가 모두 없어 참조를 금지한다.

이번 감사에서 실제 `[폐기]` 파일은 없다. 삭제보다 역사 증거와 대체 계보 보존이 더 안전하다.

## 3. 즉시 분류

### `[현행]`

- `docs/02_COMBAT_RULES.md`
- `docs/decisions/2026-08-04_COMBAT_PRICING_INTERRUPTION_RECOVERY_DECISION.md`
- `docs/decisions/2026-08-04_EXISTING_APPROVED_ACTIONS_REPRICE_DECISION.md`
- `docs/decisions/2026-08-04_TECHNIQUE1_CONDITIONAL_REWORK_STAR5_DECISION.md`
- 대응하는 2026-08-04 approved planning contract 3종

### `[대체됨]`

- `docs/decisions/2026-08-02_RANGE_PRICE_BANDS_DECISION.md`
- `docs/decisions/2026-08-03_STARTING_MARTIAL_TECHNIQUE_1_BASE_EFFECTS_AND_BUDGETS_DECISION.md`
- `docs/planning-data/approved_20260803_starting_martial_technique_1_base_effects_and_budgets_contract.json`

구형 가격·효과를 신규 구현 또는 밸런스 근거로 사용하면 `CANON_CONFLICT`다.

### `[보류]`

- PR #85 `Build playable HTML Technique1 combat validation PoC`
- HTML 산출물의 자동 테스트 증거는 역사 참고로 보존하지만 현재 main·Godot 제품에 병합하지 않는다.
- 재개는 사용자가 HTML 검증을 명시적으로 다시 승인한 경우에만 가능하다.

## 4. 핵심 재미 정합성 결론

현재 구조는 다음 이유로 프로젝트 코어와 일치한다.

1. AI는 공개 상태로 현재 묶음을 먼저 잠그고 미확정 플레이어 계획을 읽지 않는다.
2. 10칸·3/3/4·전조·중단은 거리와 순서를 미리 설계하게 한다.
3. 관찰은 행동 종류만 좁혀 추론 재료를 제공하고 정답 행동을 직접 공개하지 않는다.
4. 기술1의 실패 저점·성공 고점은 조건을 맞추는 계획과 상대 읽기를 보상한다.
5. 고정 이동·자동 조건·행동 중 추가 입력 금지는 계획 확정의 책임을 보존한다.
6. 복기에서 거리 실패·합·회피·중단·조건 실패를 원인으로 설명할 수 있다.

따라서 즉시 핵심 구조를 교체할 근거는 없다. 다만 아래 위험을 측정하지 않고 밸런스 완료나 재미 검증 완료를 주장할 수 없다.

## 5. 적대적 위험과 후속 Gate

### `RESOURCE_SATURATION_RISK`

묶음마다 생존 양측 기력·내력·절초기세 +1이 고비용 행동을 지나치게 일상화하거나 명상·준비의 선택 가치를 약화할 수 있다.

필수 측정:

- 묶음 종료 자원 상한 도달률
- 자동 회복 낭비율
- 명상·준비 선택률
- 고비용 기술 연속 사용률
- 자원 부족으로 계획을 바꾼 비율

실측 전에는 현 규칙을 유지한다. 포화가 확인되면 선택 회복·단일 자원 회복·회복 주기 조정안을 별도 Decision으로 비교한다.

### `CONDITION_CALIBRATION_RISK`

조건 난도 계수와 실제 성공률이 다르면 조건부 기술이 무료 고효율 또는 함정이 된다.

필수 측정:

- 기술별·조건별 실제 성공률
- 선언 난도 범위 이탈률
- 실패 지점별 분포
- 성공 시 고점 만족도와 실패 저점 수용도
- 조건 때문에 기술을 포기한 비율

관측 성공률이 선언 범위를 벗어나면 가격·조건 문구·효과 묶음을 재검토한다.

### `WRONG_PLAN_RESCUE_RISK`

무상한 영구 능력치가 잘못된 거리·순서·대응을 반복 구제하면 성장 수치가 핵심 재미를 대체한다.

필수 측정:

- 잘못된 계획의 생존·승리 구제율
- 올바른 읽기와 잘못된 읽기의 기대 성과 차이
- 고능력치 단순 반복 승리율
- 성장 뒤 계획 다양성 변화

### `OBSERVATION_ANSWER_LEAK_RISK`

관찰이 추론 재료가 아니라 정답 공개가 되면 비공개 계획의 긴장이 사라진다.

필수 측정:

- 관찰 뒤 계획 변경률
- 플레이어가 공개 정보로 추론 근거를 설명하는 비율
- 관찰 없이 추측한 경우와의 성과 차이
- 기술명·정확한 피해·방향 등 금지 정보 노출 여부

### `GRADE_FARMING_RISK`

전투 종료 5지표의 가중치·정규화·상한이 미확정이다. 합·회피·절초 반복 파밍을 막는 Decision 전에는 등급 산식을 제품 권위로 사용할 수 없다.

### `RUNTIME_AUTHORITY_GAP`

현재 main 런타임은 최신 성장·거리 가격·기술1/2·5성 계약을 구현하지 않았다. 플레이 가능·자동 회귀 PASS는 최신 기획 구현 완료를 뜻하지 않는다.

## 6. 개선된 다음 기획 순서

여섯 9성 분기를 각각 바로 작성하지 않고 공통 템플릿을 먼저 확정한다.

```text
STAR9_PUBLIC_READ_BRANCH_TEMPLATE
→ 여섯 개별 9성 공개 정보 기반 자동 분기
→ 여섯 10성 고유 절초 효과·슬롯·자원·틱 예산
→ 비스탯 노드 기대가치·배치·가중치
→ 전투 종료 5지표 등급 산식·파밍 방지
→ 전체 핵심 재미·정본 적대적 검토
→ 이미지 Gate
→ 별도 Build 승인
```

9성 공통 템플릿 필수 필드:

- 공개 정보 trigger
- 자동 발동이며 행동 중 추가 입력 없음
- 실패 경로와 지급 0 범위
- 조건 가격 계수와 실제 성공률 검증 계획
- 상대 대응 수단
- 복기 설명 문구
- 기술1·기술2 대체율 측정

## 7. 병합 차단 조건

- 활성 문서에 PR #84·#86·#87이 현재 작업으로 남음
- `APPROVED_PENDING_MERGE` 또는 `ACTIVE_DRAFT_7_OF_10_PR87` 잔존
- 구형 기술1 JSON이 `CURRENT_APPROVED_PLANNING`을 주장함
- `[대체됨]` 파일이 현재 구현 근거로 링크됨
- PR #85 또는 HTML PoC가 현행 제품 권위로 취급됨
- 핵심 재미 위험을 실측하지 않고 재미·밸런스 PASS 주장
- Godot·Windows·접근성·사람 검증을 실행하지 않고 PASS 주장

## 8. 검증 경계

```yaml
product_code_changed: false
runtime_data_changed: false
html_poc_changed: false
runtime_validation: NOT_RUN
godot_validation: NOT_RUN
windows_validation: NOT_RUN
accessibility_validation: NOT_RUN
human_validation: NOT_RUN
balance_validation: NOT_RUN
```
