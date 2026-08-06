# 십보강호 세션 인수

## 현재 상태

```yaml
project: 십보강호: 숨은 수의 비무
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
active_planning_work_mode: PLAN
main_state_sync_commit: 6d8237e00168e45a7d3c001a0f6b3587b57147b7
last_planning_checkpoint_merge: d9f38e6f3cacaf170d4b290e95b3645114639aff
active_planning_pr: 82
active_planning_head: 289378c214702223dc0d1e149134438c3e761ba0
active_approval_count: 2/10
active_decision_state: APPROVED_PENDING_MERGE
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
automated_validation: PASS_AT_PR82_HEAD
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
next_planning_decision: INTERMEDIATE_NODE_PERMANENT_STAT_REWARDS
base_release_pinned: 9.4.3
t1_greenlight: NOT_GRANTED
```

`work_mode: REVIEW`와 `integration_pr: 65`는 런타임 기준선이다. 현재 승인 활동은 PR #82의 `PLAN`이며 병합 전 상태는 `APPROVED_PENDING_MERGE`다.

## 반드시 읽을 파일

1. `../../../AGENTS.md`.
2. `../../../docs/BASE_RULES_VERSION.md`.
3. `ACTIVE_CONTEXT.md` — 병합된 main 체크포인트.
4. `DOCUMENTATION_MAP.md` — 활성 PR #82 포함 현재 권한 지도.
5. `../../../docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`.
6. `../../../docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`.
7. `../../../docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`.
8. `../../../docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md`.
9. PR #82의 두 최신 Decision·planning JSON.
10. 질문별 책임 원본과 실제 코드·데이터·테스트·PR.

과거 v6 결정 인덱스는 `../../../docs/decisions/2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`이며 현재 날짜별 Decision보다 높은 권한을 갖지 않는다.

## 현재 구현

ActionSelectionDock:

- `[기초] [무공] [절초]` 출처.
- 무공서→현재 해금 기술.
- 전체 10수·3/3/4 현재 묶음 편집.
- 가장 앞 유효 연속 수 자동 배치.
- `[전조] → [실행]` 연결 블록.
- 진행 전 이동·제거.
- 절초기세 예약·환불·재예약.
- 가상 `준비+막기/회피` 제품 경로 제외.

적대적 검토에서 실제 포인터 Drop 소비자 누락을 발견했고 RED 회귀 뒤 수정했다.

구현 증거:

```yaml
implementation_head: 673c209017ffe3e1c7ef2a89849ca4ea0846d1c5
pr_validation_993: PASS
base_v9_106: PASS
full_validation_73: PASS
ubuntu_godot_headless: PASS
ubuntu_windows_python_matrix: PASS
windows_godot_runtime: NOT_RUN
human_validation: NOT_RUN
```

최신 전투·성장 기획은 런타임에 아직 반영되지 않았다.

## 승인된 제품 구조

`TEN-DEC-20260801-SITUATION-SCREEN-01`:

```text
MAIN
→ RUN_SETUP
→ ROUTE
→ NODE
→ DUEL_BRIEFING
→ COMBAT
→ COMBAT_REVIEW
→ DUEL_RESULT
→ REWARD_OR_RETRY
```

- Route와 Combat은 별도 Scene.
- Combat Review는 Combat Overlay.
- Duel Result는 별도 Scene.
- P0 Autoload 후보는 `RunSession`, `SaveService`.
- 전체 제품 흐름 런타임은 아직 시작하지 않았다.

## 현재 기획 배치

PR #80·#81:

- 성장 기획 10/10 체크포인트 병합.
- main 상태 `6d8237e...`와 Sheet 0/10 동기화 완료.

PR #82 `2/10`:

1. `TEN-DEC-20260803-STAR10-ULTIMATE-PRIMARY-STAT12-01`.
2. `TEN-DEC-20260803-STARTING-MARTIAL-SECONDARY-STATS-01`.

- exact head: `289378c214702223dc0d1e149134438c3e761ba0`.
- PR Validation·Base adoption·Full Validation: PASS.
- review threads: 0.
- runtime·Windows·network·accessibility·performance·human: `NOT_RUN`.

## GitHub·Sheet 동기화

- main checkpoint: PR #80 `d9f38e6...`.
- state sync: PR #81 `6d8237e...`.
- active planning: PR #82 `289378c...`, 2/10.
- Sheet 상태: `ACTIVE_DRAFT_PR82_2_OF_10`.
- 병합 전 Decision은 `APPROVED_PENDING_MERGE`; 병합 후 main·Sheet 재조회 뒤에만 `SYNCED_TO_MAIN`.

## 다음 작업

1. 중간 노드 영구 스테이터스 보상 GrillMe 승인.
2. 무공별 기술 주/보조 배수와 5/9성 임계 효과.
3. 전투 종료 5지표 가중치·등급·파밍 방지·절초 평가.
4. 경쟁·관찰·고능력치 사람 검증 계약.
5. 10/10 또는 조기 체크포인트의 exact-head CI·적대적 검토·병합·main/Sheet readback.
6. 기획 완료 뒤 전체 검토 완료.
7. 필요한 이미지·애니메이션·HX 생성·검수·승인.
8. 이미지 완료 뒤 `VERTICAL_SLICE_APP_FLOW_SHELL` Codex Build.
9. Windows·입력·해상도·접근성·성능·`STEP 14` 사람 검증.

## 현재 제외

- 기획·검토·이미지 Gate 전 Codex BUILD.
- 후보 15명 전체를 첫 App Flow 구현의 선행 조건으로 삼는 것.
- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 모바일 포팅·스토어·크로스 세이브.
- 최종 아트·오디오 폴리싱.

## 역사

- PR #7·Issue #13: T0 `STEP 0~13` 구현 계보.
- PR #45·`2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`: 재설계·승인 이력.
- PR #65: 현재 런타임 통합 기준선.
- PR #68: Base v9.4 운영 계약 초기 적용 이력.
- PR #72·#80: 이후 전투·성장 기획 체크포인트.
- 2026-07-26 BUILD 문서: `SUPERSEDED_REFERENCE`.

자동 검증은 Windows 실제 Godot·실물 게임패드·화면 읽기 도구·성능·사람 플레이를 증명하지 않는다.