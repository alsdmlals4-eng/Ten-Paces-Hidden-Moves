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
active_planning_pr: 82
active_planning_head: 289378c214702223dc0d1e149134438c3e761ba0
base_release: 9.4.3
base_finalization_commit: 0b7c94f38d959efc0fc9442274c60b2e268a3c97
sheet_id: 1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0
```

## 문제

프로젝트의 canonical Base Adapter는 Base `9.4.3`과 finalization commit `0b7c94f38d959efc0fc9442274c60b2e268a3c97`을 고정하고 PR #82는 새 GrillMe 승인 묶음 `2/10`을 보유한다. 그러나 최상위 `AGENTS.md`, `README.md`, `START_HERE.md`, `docs/BASE_RULES_VERSION.md`, 프로젝트 Documentation Map과 Google Sheet 일부 활성 요약은 Base `9.4.0~9.4.1`, PR #65·#72·#80, 이전 main SHA 또는 `0/10`을 현행처럼 표시한다.

이 드리프트는 제품 기획 충돌이 아니라 읽기 순서와 작업 라우팅을 오도하는 운영 정본 신선도 결함이다.

## 결정

1. 제품 코어·수치·콘텐츠·런타임은 변경하지 않는다.
2. 최상위 진입 문서는 단일 상태값 대신 다음을 분리해 기록한다.
   - 병합된 main 상태 동기화 commit
   - 마지막 병합 기획 체크포인트
   - 현재 활성 GrillMe Draft PR과 head
   - 현재 승인 수 `2/10`
   - 현재 Base Adapter release `9.4.3`
3. PR #82의 두 승인 Decision은 `APPROVED_PENDING_MERGE`이며 `SYNCED_TO_MAIN`으로 과장하지 않는다.
4. Google Sheet의 활성 허브·GDD 요약·마일스톤·감사·변경이력만 갱신한다. 과거 PR·Commit을 보존하는 역사 행은 수정하지 않는다.
5. 다음 제품 기획은 `INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS`이며 PR #82의 세 번째 GrillMe Decision으로 진행한다.

## 영향 파일

- `AGENTS.md`
- `README.md`
- `START_HERE.md`
- `docs/BASE_RULES_VERSION.md`
- `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`
- Google Sheet `00_프로젝트_허브`, `04_누락_충돌_감사`, `05_GDD_요약`, `90_본제작_출시_사업`, `99_변경이력`

## 검증

- 현재 Adapter의 release/version/commit 재조회
- main `6d8237e...`와 PR #82 `289378c...` 분리 표기
- PR #82의 2개 Decision ID·2/10 상태 재조회
- Sheet readback
- exact-head PR Validation·Full Validation·Base adoption
- 실행하지 않은 Godot·Windows·접근성·성능·사람 검증은 `NOT_RUN`
