# 승인된 수묵 전투 이미지·합 연출·먹 VFX 구현

사용자 최신 명시 지시 “좋아 지금 느낌으로 전투쪽 이미지,연출등을 변경하자. 먹 v.fx 연출도 연결하고”를 실제 Godot 전투 진행에 적용한다. 앞서 확정한 기존 전투 준비 방식 보존, 3/3/4수 묶음의 연속 진행, 실제 판정·자원 변화의 하단 표시를 같은 승인 범위로 재사용한다. 이 문서는 새 승인을 만들어내는 문서가 아니라 CI가 요구하는 기존 승인 근거의 연결 기록이다.

- Decision: `TEN-DEC-20260924-INK-WUXIA-STYLE-AND-FLOW-01` / `docs/decisions/2026-09-24_INK_WUXIA_STYLE_AND_FLOW.md`.
- `CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF`: 현재 Codex가 repository owner, 실제 해결기·전투 화면·자산 consumer를 독립 확인해 구현한다.
- 범위: 확정 후 전투 진행 화면의 승인 수묵 원화 파생 자산·연속 동작·먹 궤적과 접촉 효과·결과 읽기 전용 표시. 기존 준비 화면의 선택·배치·방향·취소·확정, 판정·AI·저장·보상은 보호한다.
- 제품 경로는 일회 `docs/operations/PROJECT_PROTECTED_CHANGE_APPROVAL.json`의 정확한 목록을 따른다. 승인 기록 시각과 사용자 원문을 구분한다.
- 검증·두 차례 전체 검토·교정·PR/main readback은 기존 `docs/operations/2026-09-09_CLASH_DIRECTION_EXECUTION_REPORT.md`에 누적한다. 사람 체감·Android·적별 전용 원화·출시 승인은 자동 실행 증거와 구분한다.
