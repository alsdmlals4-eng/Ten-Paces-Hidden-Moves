# Action Selection Dock 구현 종료 기록

- Decision ID: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`
- Spec ID: `TEN-SIT-SPEC-20260801-ACTION-SELECTION-DOCK-01`
- 구현 PR: `#66` → 통합 PR `#65`
- 구현 브랜치: `agent/2026-08-01-action-selection-dock-build`
- 통합 브랜치: `agent/2026-07-31-combat-route-champion-sync`
- 상태: `IMPLEMENTED_AUTOMATED_VALIDATION_PASS_HUMAN_PENDING`
- 사람 검증: `NOT_RUN`

## 구현 결과

- 전투 행동을 `기초 / 무공 / 절초` 출처로 분리했다.
- 무공서는 직접 배치하지 않고 현재 해금 기술만 배치한다.
- 세 출처는 동일한 `ActionPlacementController`를 사용한다.
- 1~3수 행동은 가장 앞의 유효 연속 수에 자동 배치한다.
- 다중 수 행동은 `[전조] → [실행]` 연결 블록으로 표시한다.
- 연결 블록은 진행 전 이동·제거할 수 있고 묶음 경계를 넘지 않는다.
- 절초기세 5는 배치 성공 시 예약하고 진행 전 제거·이동 시 환불·재예약한다.
- 제품 경로에서 가상 `준비+막기/회피` 카드를 비활성화했다.
- 레거시 Tray·절초 목록·상세 Panel은 숨김 호환 경로로 유지했다.

## 적대적 검토 보완

최초 구현은 연결 블록의 마우스 Drag 시작과 이동 API는 있었지만, 실제 타임라인 슬롯에서 포인터를 놓았을 때 Drop을 완료하는 신호 소비자가 없었다.

RED:

- 회귀 검증 추가 Commit: `fd653d16d78f6f6823bb889b8b4199d9fe6b00e4`
- Full Validation #71의 `verify_action_repositioning`이 예상대로 실패했다.

GREEN:

- `ActionTimingSlot.slot_pointer_released` 추가
- `ActionTimingPanelAuto`가 활성 Drag에서 기존 `drop_linked_block_at()`을 호출하도록 연결
- 수정 HEAD: `673c209017ffe3e1c7ef2a89849ca4ea0846d1c5`

## 자동 검증

HEAD `673c209017ffe3e1c7ef2a89849ca4ea0846d1c5`:

- PR Validation #993: `PASS`
- Validate Base v9 adoption #106: `PASS`
- Full Validation #73: `PASS`
- Ubuntu Godot headless: `PASS`
- Action-selection Godot smoke: `PASS`
- Ubuntu/Windows Python 3.11·3.12 matrix: `PASS`

## 미검증

- Windows에서 실제 Godot 실행·입력 체감
- 마우스 실제 Drag 거리·포인터 해제 체감
- 게임패드 실제 장치
- 화면 읽기 도구
- 1280×800·1440×900 실제 렌더 시각 검수
- 신규 플레이어의 무공서→기술 이해도
- 절초기세 예약·환불의 사람 이해도

자동 검증 통과는 위 항목의 사람 검증을 대체하지 않는다.

## 다음 게이트

1. 통합 PR #65를 최신 정본·Sheet와 동기화한다.
2. `VERTICAL_SLICE_APP_FLOW_SHELL`을 별도 구현 패키지로 계획한다.
3. 행동 선택 Dock 사람 검증은 실제 제품 흐름 Shell에 연결된 빌드에서 수행한다.
