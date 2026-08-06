# 십보강호 운영 로드맵

> 상세 제품 로드맵: `../../../docs/04_ROADMAP.md`  
> 현재 상태: `ACTIVE_CONTEXT.md`  
> 정본 생명주기: `../../../docs/CANON_LIFECYCLE_REGISTRY.md`

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
runtime_integration_pr: 65
active_planning_work_mode: BUILD
active_planning_pr: 92
active_planning_parent_pr: 91
active_approval_count: 10/10
active_decision_state: TEN_MANUAL_PRODUCT_VALIDATION_AUTOMATED
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE
human_validation: NOT_RUN
base_release_pinned: 9.4.3
```

## 현재 작업

- `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`: 완료.
- `TEN_MANUAL_UI_AI_ADOPTION_GATE`: 완료.
- `TEN_MANUAL_PRODUCT_VALIDATION_GATE`: 자동 증거 완료, `PARTIAL_AUTOMATED_COMPLETE`.
- Windows CI export·runtime, 50개 성취도 시나리오, 3개 해상도, 합성 입력, 자동 접근성, 성능 baseline: PASS/CAPTURED.
- 로컬 Windows·실물 게임패드·접근성 사용자·Release 성능·STEP 14·밸런스: NOT_RUN.

## 다음 순서

```text
TEN_MANUAL_LOCAL_WINDOWS_ACCESSIBILITY_PERFORMANCE_GATE
→ TEN_MANUAL_STEP14_HUMAN_VALIDATION_GATE
→ TEN_MANUAL_BALANCE_MEASUREMENT_GATE
→ NON_STAT_NODE_EXPECTED_VALUE_AND_WEIGHT
→ FULL_CORE_FUN_CANON_ADVERSARIAL_REVIEW
```

## 운영 경계

- PR #92는 PR #91 위의 Draft를 유지한다.
- 자동 증거를 전체 제품 PASS·T1·MVP·병합 권한으로 확대하지 않는다.
- 실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.
