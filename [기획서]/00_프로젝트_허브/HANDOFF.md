# 십보강호 세션 인수

## 현재 상태

```yaml
project: 십보강호: 숨은 수의 비무
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
work_mode: REVIEW
integration_pr: 65
runtime_implementation: ACTION_SELECTION_DOCK_IMPLEMENTED_PR65
implemented_decision: TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01
approved_planning_decision: TEN-DEC-20260801-SITUATION-SCREEN-01
automated_validation: RECHECK_IN_PROGRESS
human_validation: NOT_RUN
next_package: VERTICAL_SLICE_APP_FLOW_SHELL
t1_greenlight: NOT_GRANTED
```

## 반드시 읽을 파일

1. `../../../AGENTS.md`.
2. `../../../docs/BASE_RULES_VERSION.md`.
3. `ACTIVE_CONTEXT.md`.
4. `DOCUMENTATION_MAP.md`.
5. `../../../docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`.
6. `../../../docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`.
7. `../../../docs/implementation/2026-08-01_ACTION_SELECTION_DOCK_CLOSEOUT.md`.
8. `../../../docs/reviews/2026-08-01_BASE_PROJECT_SHEET_ADVERSARIAL_AUDIT.md`.
9. 질문별 책임 원본과 실제 코드·데이터·테스트·PR.

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

## 승인된 다음 구조

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

## GitHub·Sheet 동기화

- Sync ID: `TEN-SYNC-20260801-09`.
- Decision: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`.
- Decision: `TEN-DEC-20260801-SITUATION-SCREEN-01`.
- Audit: `TEN-AUD-010`.
- Sheet: 00·01·02·04·60·80·99 tab 쓰기·재조회 완료.
- 현재 상태: `SHEET_SYNCED_PR_OPEN_AUTOMATED_RECHECK_PENDING`.

## 다음 작업

1. PR #65 최신 HEAD의 세 필수 워크플로 통과.
2. PR #65 main 병합.
3. 새 main HEAD와 Google Sheets를 `SYNCED`로 재기록.
4. `VERTICAL_SLICE_APP_FLOW_SHELL` 별도 Plan·Branch·PR.
5. Windows·입력·해상도·접근성·성능·`STEP 14` 사람 검증.
6. 두 번째 상대·노드 반복 제작.

## 현재 제외

- 후보 15명 전체를 첫 App Flow 구현의 선행 조건으로 삼지 않는다.
- 16권 절초 개별 설계.
- 주요 비무 6~10 런타임.
- 천하제일인·비동기 기능.
- 최종 아트·오디오 폴리싱.
- Base v9.3 migration을 PR #65에 혼합하지 않는다.

## 역사

- PR #7·Issue #13: T0 `STEP 0~13` 구현 계보.
- PR #45·`2026-07-28_V6_DECISION_AUTHORITY_LEDGER.md`: 재설계·승인 이력.
- 2026-07-26 BUILD 문서: `SUPERSEDED_REFERENCE`.

자동 검증은 Windows 실제 Godot·실물 게임패드·화면 읽기 도구·성능·사람 플레이를 증명하지 않는다.
