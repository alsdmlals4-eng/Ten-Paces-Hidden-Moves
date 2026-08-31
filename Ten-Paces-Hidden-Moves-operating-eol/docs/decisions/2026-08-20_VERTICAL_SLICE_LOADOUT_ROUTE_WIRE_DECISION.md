# Vertical Slice 상대 Loadout · Route 예산 · 비전투 Wire 결정

- Decision ID: `TEN-DEC-20260820-VERTICAL-SLICE-LOADOUT-ROUTE-WIRE-01`
- 날짜: 2026-08-20
- 승인 근거: 사용자의 선행 권장안 승인 + 연속작업 지시
- 상위 Decision: `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01`
- 선행 상세 Decision: `TEN-DEC-20260820-VERTICAL-SLICE-CONTENT-DETAIL-01`
- 상세 정본: `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md`
- 제품 구현 권한: `false`

## 결정

1. 후보 15명은 현행 `APPROVED_DRAFT_PLANNING` 10권 무공서와 승인 기초 행동만 재사용한다.
2. 후보별 신규 전투 규칙·11번째 무공서·적 전용 관찰 규칙을 만들지 않는다.
3. 천기암기록을 사용하는 비연은 첫 Slice 적 기본 노출을 3성 `추혼표`까지로 제한하여 플레이어 전용 `[관찰]` 경계를 보호한다.
4. 동일 무공 재사용은 서로 다른 슬롯 질문·행동 습관·기술 범위로 변주하여 `같은 무공을 다른 무인이 어떻게 운용하는가`를 보여준다.
5. 다음 상대는 직전 Duel Result 확정 시 run seed로 잠근다. 이후 Growth→Info Route는 그 상대를 대상으로 하며 정보 선택으로 상대를 reroll하지 않는다.
6. 성장 Route 초기 Seed는 집중 `1+1+2+2=6`, 자유 `3+3+4+4=14`로 기존 Duel 5 전 38 성장 경로를 보존한다.
7. 회복 Seed는 각 성장 Route에서 `최대 체력25% + 기력1 + 내력1`, 상한 적용, 절초기세/영구재화 미지급이다. 이 값은 `REVERSIBLE_BALANCE_SEED`이다.
8. 정보 Route는 공개 사실/과거 사례/정성 습관 중 하나를 추가하며 hidden plan, AI weight, exact probability, best counter, seed를 노출하지 않는다.
9. 비전투 화면은 `현재 상태 → 최대 3선택 → 변화 preview → 확정` 공통 문법을 재사용한다.
10. Combat Review Overlay와 Duel Result 별도 Scene 경계를 유지한다.

## 검증 경계

- 문서/정본 교차검증: 완료.
- 10성 성장 경로 산술 검산: 완료 (`32+6=38`, `24+14=38`).
- Godot/runtime data 변경: 없음.
- 실제 밸런스 시뮬레이션: NOT_RUN.
- Human time/readability/fun validation: NOT_RUN.
- Android/Windows local visible render: 이번 Decision 범위 NOT_RUN.

## 적대적 검토

5회 전체 루프 + clean-exit reattack 결과 `MUST_FIX_REMAINING: 0` for this planning package.

남은 작업:
- 후보별 영구 스테이터스·성급·AI 공개행동 정책.
- Route Seed의 정적/시뮬레이션 사전 검증 계약.
- 15~22분 데모 시간 예산 재검산.
- Planning Completion Inventory 전체 재감사.
