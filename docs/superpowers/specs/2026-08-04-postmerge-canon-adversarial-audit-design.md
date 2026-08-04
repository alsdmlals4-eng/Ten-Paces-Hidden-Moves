# Post-Merge Canon Adversarial Audit Design

- Decision candidate: `TEN-DEC-20260804-POSTMERGE-CANON-ADVERSARIAL-AUDIT-01`
- Base main: `0ba841ff2e62b2f716466356dd9e7ffcf587d150`
- Scope: planning authority, lifecycle governance, core-fun risk review
- Runtime authority: none

## 1. Goal

PR #84, #86, #87의 승인 내용을 병합된 main 정본으로 확정하고, 병합 전 상태가 남은 문서·계약·PR을 생명주기 상태로 분류한다. 동시에 현재 전투·성장 구조가 프로젝트 코어인 `관찰 → 비공개 계획 → 거리·순서·대응·중단 → 복기 → 다음 계획 변경`을 강화하는지 적대적으로 검토한다.

## 2. Non-goals

- Godot 제품 코드·Scene·런타임 데이터 변경
- HTML PoC 재개 또는 병합
- 근거 없이 자원 회복량·조건 가격·능력치 배수를 즉시 재조정
- 9성·10성 개별 효과를 이번 감사에서 확정
- 사람 검증을 자동 검증으로 대체

## 3. Authority lifecycle

모든 권위 파일은 다음 중 하나를 명시한다.

- `[현행]`: 현재 제품 기획·검증이 직접 참조하는 권위
- `[대체됨]`: 새 Decision이 권위를 인수했으며 역사 재현에만 사용
- `[보류]`: 증거는 보존하지만 현재 제품 정본·병합 근거로 사용 금지
- `[폐기]`: 복구·참조 가치가 없고 현재·역사 권위 모두 없음

`[대체됨]`과 `[보류]` 파일은 삭제하지 않는다. 제목 또는 첫 권위 블록, 기계 판독 상태, 대체·재개 조건을 함께 기록한다. 현재 감사에서는 삭제할 파일이 없으므로 `[폐기]` 항목은 정의만 유지한다.

## 4. Post-merge state contract

병합 후 활성 컨텍스트와 로드맵은 PR 번호가 아니라 main 병합 체크포인트를 권위로 사용한다.

```yaml
active_planning_pr: NONE
active_planning_parent_pr: NONE
active_decision_state: MERGED_CANON_CHECKPOINT
active_approval_count: 7/10
last_merged_planning_commit: 0ba841ff2e62b2f716466356dd9e7ffcf587d150
next_planning_decision: STAR9_PUBLIC_READ_BRANCH_TEMPLATE
```

PR #84·#86·#87은 `[병합됨]` 역사 계보다. PR #85는 `[보류]`, 닫힘, 병합 금지다.

## 5. Core-fun adversarial review

### 5.1 Fit conclusion

현재 방향은 코어와 대체로 일치한다.

- AI가 미확정 계획을 읽지 않고 관찰 전에 현재 묶음을 잠근다.
- 3/3/4 묶음과 다중 수 전조·중단이 예측과 역예측을 만든다.
- 기술1의 실패 저점·성공 고점은 조건을 맞추는 계획 숙련을 보상한다.
- 고정 이동과 행동 중 추가 선택 금지는 비공개 계획의 책임을 보존한다.
- 복기에서 조건 실패·거리·순서·중단 원인을 설명할 수 있다.

### 5.2 Risks that block unqualified balance claims

1. `RESOURCE_SATURATION_RISK` — 묶음마다 기력·내력·절초기세 +1이 자원 희소성과 명상·준비의 가치를 약화할 수 있다.
2. `CONDITION_CALIBRATION_RISK` — 정적 난도 계수가 실제 성공률과 어긋나면 조건부 기술이 무료 고효율 또는 함정이 된다.
3. `WRONG_PLAN_RESCUE_RISK` — 무상한 능력치가 잘못된 계획을 반복 구제하면 핵심 재미가 성장 수치로 대체된다.
4. `OBSERVATION_ANSWER_LEAK_RISK` — 관찰이 추론 재료가 아니라 정답 공개가 되면 비공개 계획의 긴장이 사라진다.
5. `GRADE_FARMING_RISK` — 전투 종료 5지표의 가중치·정규화가 미확정이라 합·회피 반복 파밍을 막지 못한다.
6. `RUNTIME_AUTHORITY_GAP` — main 런타임은 최신 계획을 구현하지 않았으므로 플레이 가능하다는 사실을 정본 구현 완료로 해석할 수 없다.

이번 감사는 위험을 이유로 승인 규칙을 임의 변경하지 않는다. 각 위험을 후속 Decision 또는 사람 검증의 병합 차단 조건으로 만든다.

## 6. Improved planning order

기존의 여섯 9성 분기를 바로 개별 작성하기 전에 공통 템플릿을 한 번 확정한다.

```text
STAR9_PUBLIC_READ_BRANCH_TEMPLATE
→ 여섯 개별 9성 자동 분기
→ 여섯 10성 고유 절초 효과·비용·예산
→ 비스탯 노드 기대가치
→ 전투 종료 등급 산식
→ 전체 정본·핵심 재미 적대적 검토
→ Build 승인
```

공통 9성 템플릿은 공개 정보만 사용하고, 행동 확정 뒤 추가 입력이 없으며, 조건 실패 경로·복기 설명·가격 계수·대응 수단을 필수 필드로 갖는다.

## 7. Validation design

새 validator는 다음을 차단한다.

- 활성 문서의 `APPROVED_PENDING_MERGE`, `ACTIVE_DRAFT_7_OF_10_PR87`, `active_planning_pr: 87`
- 구형 기술1 계약의 `CURRENT_APPROVED_PLANNING`
- 대체 Decision에서 `[대체됨]` 표시 누락
- 생명주기 등록부의 현재·대체·보류 항목 누락
- 핵심 재미 위험·필수 측정지표 누락
- PR #85를 현행 또는 병합 가능 권위로 기록

기존 PR·Full·Base·전용 계약 검증과 함께 통과해야 한다.

## 8. Evidence boundary

- 자동 문서·계약 검증: 실행 대상
- Sheet 동기화·readback: 실행 대상
- Godot·Windows·접근성·성능·사람 플레이: `NOT_RUN`
- 자원 포화·조건 성공률·잘못된 계획 구제율: 아직 실측 없음
