# 십보강호 개발 게이트

> 현재 상태: `ACTIVE_CONTEXT.md`  
> 현재 상세 로드맵: `../../../docs/04_ROADMAP.md`  
> 과거 v6 결정 인덱스: `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`

## 1. 상태 축

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING | PROTOTYPE_AND_VERTICAL_SLICE | PRODUCTION_APPROVAL | RELEASE_CANDIDATE_APPROVAL
work_mode: PLAN | BUILD | REVIEW
gate: APPROVED | APPROVED_WITH_CONDITIONS | REWORK | REPEAT_VALIDATION | HOLD | STOP | UNVERIFIED
implementation: IMPLEMENTED | PARTIALLY_IMPLEMENTED | PLANNED | PROPOSED_ONLY | DEFERRED | REMOVED | UNVERIFIED
```

파일 존재·Actions·Godot headless·Windows 실제 실행·접근성·성능·사람 플레이는 독립 증거다.

## 2. 현재 게이트

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
automated_validation: RECHECK_IN_PROGRESS
human_validation: NOT_RUN
t1_greenlight: NOT_GRANTED
```

## 3. G0 — 권한·기준선

- [x] 최신 사용자 지시와 프로젝트 코어 확인.
- [x] main·PR #65·최근 병합 PR·Sheet 확인.
- [x] PR #7·Issue #13 T0 구현 계보 보존.
- [x] v6 원장을 역사 인덱스로 유지하고 최신 날짜별 Decision을 우선.
- [x] Base v9.1 Adapter와 Base main v9.3 차이 분리.

판정: `APPROVED`.

## 4. G1 — ActionSelectionDock

- [x] `[기초] [무공] [절초]` 출처와 무공서→해금 기술 계약.
- [x] 전체 10수·3/3/4 현재 묶음 편집.
- [x] 자동 배치와 `[전조] → [실행]` 연결 블록.
- [x] 진행 전 이동·제거와 절초기세 예약·환불.
- [x] 포인터 Drop 누락 RED 재현·수정.
- [x] 구현 HEAD `673c2090` 자동 검증 통과.
- [ ] Windows 실제 Godot·실물 입력·사람 이해도 검증.

판정: `APPROVED_WITH_CONDITIONS / HUMAN_PENDING`.

## 5. G2 — 정본·Google Sheets 동기화

- [x] `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01` Decision·planning JSON·Closeout 연결.
- [x] `TEN-DEC-20260801-SITUATION-SCREEN-01` Decision·planning JSON 연결.
- [x] Sheet 00·01·02·04·60·80·99 동기화·재조회.
- [x] `TEN-AUD-010`과 `TEN-SYNC-20260801-09` 기록.
- [ ] 최신 PR HEAD의 필수 검사 통과.
- [ ] 병합 뒤 main SHA와 Sheet `SYNCED` 재기록.

판정: `REWORK_UNTIL_REQUIRED_CHECKS_PASS`.

## 6. G3 — PR #65 병합

필수 조건:

1. PR Validation·Validate Base v9 adoption·Full Validation이 동일 HEAD에서 PASS.
2. merge conflict 0.
3. unresolved review thread 0.
4. P0/P1·기획 충돌 없음.
5. Sheet의 Decision ID·PR HEAD 일치.

판정: `PENDING_REQUIRED_CHECKS`.

## 7. G4 — 다음 BUILD

다음 패키지: `VERTICAL_SLICE_APP_FLOW_SHELL`.

```text
App Root
→ Main
→ 시작 무공 6중4
→ Route·Node·Briefing
→ 기존 Combat
→ Result·Reward·Retry
```

BUILD 진입 조건:

- PR #65 main 병합·post-merge 동기화.
- 별도 구현 Plan·Branch·회귀 계약.
- `RunSession`·`SaveService` 최소 소유권.
- 전환 중 입력 잠금·저장 실패·보상 이중 commit 테스트.

현재 판정: `APPROVED_NEXT_PACKAGE / NOT_STARTED`.

## 8. G5 — Vertical Slice·사람 검증

- Windows 실제 Godot 실행.
- 키보드·마우스·게임패드 핵심 흐름.
- 1280×800·1440×900·16:9 safe area.
- 접근성 보조기술·성능 프로파일.
- `STEP 14` 신규 플레이어 5명.
- 두 번째 상대·노드 반복 제작 증거.

현재 판정: `NOT_GRANTED`.

## 9. `[보류]`

- 후보 15명 전체를 첫 App Flow 구현의 선행 조건으로 삼는 것.
- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 최종 아트·오디오 폴리싱.
- Base v9.3 migration을 PR #65에 혼합.

## 10. 검증 순서

```text
contract-check
→ reference-freshness
→ syntax·static
→ automated tests
→ Godot headless
→ Windows runtime·render
→ accessibility·performance
→ normal·failure·edge·counterexample·regression
→ Sheet readback
→ evidence-report
```

실행하지 않은 검증은 `NOT_RUN / UNVERIFIED`다.
