# PR #92 보호 경로 승인 이력

```yaml
record_type: MERGED_PROTECTED_CHANGE_APPROVAL_EVIDENCE
status: HISTORICAL_MERGED
product_pr: 92
product_head: 3f4b2dd8b97480b39cb4301c33b2e27e0921cb37
product_merge_commit: a839cd724d0d3ca60c8066abe5a1e2a5e0b78e90
protected_base_commit: 4b5967dee99592de4a09a611068344994e1ee026
approved_paths: [project.godot]
decision_ids: [TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE, TEN_MANUAL_UI_AI_ADOPTION_GATE, TEN_MANUAL_PRODUCT_VALIDATION_GATE]
approval_source: GITHUB_PR_LABEL_APPROVED_PROTECTED_CHANGE
base_gate_commit: 4ec410e611152294f3f2685570fca6019c7abcfa
project_gate_adoption_commit: 7651b73021effba8a83f2c902e6cf2218690c91f
```

이 문서는 병합된 일회성 승인 manifest의 감사 이력이다. 활성 `PROJECT_PROTECTED_CHANGE_APPROVAL.json`은 후속 무관 PR에 승인을 상속하지 않도록 PR #92 병합 뒤 제거한다.

승인 범위는 `project.godot`의 초기 10권 런타임 등록 변경뿐이었다. 다른 보호 경로, 향후 변경, Android 구현, 사람·성능 검증을 승인하지 않는다.
