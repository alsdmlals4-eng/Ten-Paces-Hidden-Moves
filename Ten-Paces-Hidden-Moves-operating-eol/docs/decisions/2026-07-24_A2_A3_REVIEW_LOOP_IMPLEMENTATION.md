# A2·A3 가설 기록·결정적 복기 구현 기록

> Goal: `docs/decisions/2026-07-24_REPEAT_POC_CORE_VALIDATION_GOAL.md`
> 계획: `plans/2026-07-24-repeat-poc-core-validation-implementation-plan.md`
> Issue: #16

## 1. 스택

```text
PR #19 · A1 라이벌 후보 정책
→ PR #22 · A2 가설 snapshot·summary builder
→ PR #25 · A3 결정적 복기 UI·review gate
```

각 PR은 직전 PR의 head branch를 base로 사용하는 Draft 스택이다. 제품 코드와 검증 전용 PR은 분리하며 검증 전용 PR은 병합하지 않는다.

## 2. A2 구현

- `combat_hypothesis_poc.json`: 직접 선택 가능한 가설 5개와 `none`.
- `OpponentHypothesisPanel`: 선택·잠금·reset·deep snapshot.
- `CombatReviewSummaryBuilder`: 권위 결과 이벤트를 읽어 결정적 cause를 선택하는 순수 계층.
- commit 직전 player plan·hypothesis·state snapshot.
- cause 우선순위: `clash > interrupted > defense > direction > range > resource > position > order`.
- 미선택 가설 자동 추정과 판정 재계산 금지.

### A2 증거

- Red: PR Validation run #592에서 A2 생산 파일 부재로 실패.
- Green: PR Validation run #607 success.
- 접근성 회귀 수정 후 검증 전용 PR #24:
  - PR Validation run #610 success.
  - Full Validation run #6 success.
  - Ubuntu·Windows × Python 3.11·3.12 success.
  - Godot 4.7 import·기존 회귀·가설·summary verifier success.

## 3. A3 구현

- `CombatReviewPanel`: summary Dictionary만 읽는 표시 계층.
- 표시 순서: 내 가설 → 상대 실제 행동 → 결정적 원인 → 전후 거리 → 다음 검토.
- `상세 기록`: 기존 `CombatLogPanel`을 펼친다.
- `review_ready`: 복기 확인 전 카드·슬롯·타일·진행 입력을 잠근다.
- 비종료 계속: 다음 묶음으로 이동.
- 종료 계속: `restart_combat()`으로 완전 초기화.
- review 중 키보드 포커스는 상세 기록과 계속 버튼 사이에 고정한다.
- 모션 감소·음향 끄기·연출 건너뛰기가 summary text를 제거하지 않는다.

## 4. A3 검증 상태

```yaml
static_contract: PENDING_FRESH_PR_VALIDATION
godot_review_ui: PENDING_FULL_VALIDATION
windows_python_matrix: PENDING_FULL_VALIDATION
canonical_doc_sync: PENDING
technical_closeout: PENDING
```

A3 PASS는 최신 head의 PR Validation과 전체 매트릭스·Godot 성공 뒤에만 기록한다.

## 5. 제품·사람 증거 경계

```yaml
human_step14: DEFERRED_BY_USER
human_validation: UNVERIFIED
product_gate: REPEAT_POC
t1_greenlight: NOT_GRANTED
mvp_complete: false
```

A2·A3 기술 검증은 실제 플레이어가 가설을 이해하고 복기를 활용해 다음 계획을 바꾸는지 증명하지 않는다.
