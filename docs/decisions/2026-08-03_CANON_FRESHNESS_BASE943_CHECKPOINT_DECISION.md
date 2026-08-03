# TEN-MAINT-20260803-CANON-FRESHNESS-BASE943-01

## 분류

```yaml
decision_id: TEN-MAINT-20260803-CANON-FRESHNESS-BASE943-01
kind: OPERATING_CANON_MAINTENANCE
work_mode: REVIEW
classification: VERIFIED_CANON_DRIFT_FIX
product_direction_changed: false
product_code_changed: false
source_main: 6d8237e00168e45a7d3c001a0f6b3587b57147b7
runtime_integration_pr: 65
active_planning_work_mode: PLAN
active_planning_pr: 82
active_planning_head: 289378c214702223dc0d1e149134438c3e761ba0
base_release: 9.4.3
base_finalization_commit: 0b7c94f38d959efc0fc9442274c60b2e268a3c97
sheet_id: 1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0
```

## 문제

프로젝트의 canonical Base Adapter는 Base `9.4.3`과 finalization commit `0b7c94f38d959efc0fc9442274c60b2e268a3c97`을 고정하고 PR #82는 새 GrillMe 승인 묶음 `2/10`을 보유한다. 그러나 최상위 진입점과 프로젝트 허브의 활성 소비자들은 Base `9.4.0~9.4.1`, PR #65 병합 대기, PR #72·#80 또는 이전 main SHA를 현재 작업처럼 표시했다. Google Sheet 일부 활성 요약도 Base·승인 수·기획/구현 Gate가 혼재했다.

첫 수정에서 `work_mode: REVIEW`와 `integration_pr: 65`를 활성 기획 상태로 오판해 제거했으나, 거버넌스 회귀 검사가 이 두 값을 현재 **런타임 통합 기준선**으로 강제함을 확인했다. 따라서 런타임 기준선과 활성 기획 배치를 단일 상태값으로 덮어쓰지 않고 두 축으로 분리해야 한다.

이 드리프트는 제품 기획 충돌이 아니라 읽기 순서·작업 라우팅·BUILD 진입 판단을 오도하는 운영 정본 신선도 결함이다.

## 결정

1. 제품 코어·수치·콘텐츠·런타임은 변경하지 않는다.
2. 활성 진입 문서는 다음 두 축을 분리해 기록한다.
   - 런타임 통합 기준선: `work_mode: REVIEW`, `integration_pr: 65`, `ACTION_SELECTION_DOCK_IMPLEMENTED_PR65`
   - 활성 기획 기준선: `active_planning_work_mode: PLAN`, PR #82, head `289378c...`, 승인 `2/10`
3. 공통 상태에는 다음을 함께 기록한다.
   - 병합된 main 상태 동기화 commit `6d8237e...`
   - 마지막 병합 기획 체크포인트 `d9f38e6...`
   - 현재 Base Adapter release `9.4.3`
   - 다음 Decision `INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS`
4. PR #82의 두 승인 Decision은 `APPROVED_PENDING_MERGE`이며 `SYNCED_TO_MAIN`으로 과장하지 않는다.
5. 프로젝트 허브의 `START_HERE`, `DEVELOPMENT_GATES`, `ROADMAP`, `HANDOFF`도 활성 소비자이므로 과거 PR #65 병합 대기·Base v9.3 후속 지시를 제거한다.
6. Google Sheet의 활성 허브·GDD 요약·마일스톤·감사·변경이력만 갱신한다. 과거 PR·Commit을 보존하는 역사 행은 수정하지 않는다.
7. `[기획 완료] → [전체 검토 완료] → [이미지·애니메이션·HX 승인] → [Codex BUILD]` Gate를 명시한다.
8. 다음 제품 기획은 `INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS`이며 PR #82의 세 번째 GrillMe Decision으로 진행한다.

## 영향 파일

- `AGENTS.md`
- `README.md`
- `START_HERE.md`
- `docs/BASE_RULES_VERSION.md`
- `[기획서]/00_프로젝트_허브/START_HERE.md`
- `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- `[기획서]/00_프로젝트_허브/DEVELOPMENT_GATES.md`
- `[기획서]/00_프로젝트_허브/ROADMAP.md`
- `[기획서]/00_프로젝트_허브/HANDOFF.md`
- Google Sheet `00_프로젝트_허브`, `04_누락_충돌_감사`, `05_GDD_요약`, `90_본제작_출시_사업`, `99_변경이력`

## 검증

- 현재 Adapter의 release/version/commit 재조회
- main `6d8237e...`와 PR #82 `289378c...` 분리 표기
- PR #82의 2개 Decision ID·2/10 상태 재조회
- Sheet readback
- 거버넌스 회귀의 실패 원인과 `REVIEW/PR65` 런타임 기준선 복원 확인
- exact-head PR Validation·Full Validation·Base adoption
- changed files·활성 소비자·untouched 문서·리뷰 스레드 재검토
- 실행하지 않은 Godot·Windows·접근성·성능·사람 검증은 `NOT_RUN`