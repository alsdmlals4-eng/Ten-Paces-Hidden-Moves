# PR #65 병합 후 GitHub·Google Sheets 동기화 증거

- Evidence ID: `TEN-SHEET-EVIDENCE-20260801-01`
- Sync ID: `TEN-SYNC-20260801-09`
- Decision ID: `TEN-DEC-20260801-MARTIAL-TECHNIQUE-UX-01`
- Decision ID: `TEN-DEC-20260801-SITUATION-SCREEN-01`
- GitHub main commit: `2d8b9fc2a435322ba26860421eecadf356f53a4b`
- Spreadsheet ID: `1KzU5M7xsrbz3a3_vG0yEh3hqk736lrYJW3YgPPRloP0`
- Readback date: `2026-08-01`
- Verdict: `SYNCED_MAIN`

## Readback ranges

- `00_프로젝트_허브!E2:K2`
- `01_작업순서!H9:M10`
- `02_현재_확정결정!J10:L11`
- `04_누락_충돌_감사!D11:H11`
- `60_UX_UI_접근성!J11:J11`
- `99_변경이력!E11:H11`

## Verified values

- 프로젝트 허브 동기화 상태: `SYNCED_MAIN`.
- 행동 선택 Decision main SHA: `2d8b9fc2a435322ba26860421eecadf356f53a4b`.
- 행동 선택 상태: `SYNCED_MAIN_AUTOMATED_PASS_HUMAN_NOT_RUN`.
- 화면 구조 Decision main SHA: `2d8b9fc2a435322ba26860421eecadf356f53a4b`.
- 화면 구조 상태: `SYNCED_MAIN_RUNTIME_NOT_STARTED`.
- 감사 판정: `CONFLICT_FIXED_SYNCED_MAIN_WITH_DECLARED_GAPS`.
- 변경이력 상태: `SYNCED_MAIN`.
- 다음 패키지: `VERTICAL_SLICE_APP_FLOW_SHELL`.

## Evidence boundary

이 증거는 GitHub 정본과 Google Sheets의 Decision ID·main Commit·동기화 상태가 일치함을 기록한다.

다음 항목은 증명하지 않는다.

- Windows 실제 Godot 실행.
- 실물 마우스·게임패드 조작.
- 접근성 보조기술.
- 성능 프로파일.
- `STEP 14` 사람 플레이.
- 전체 제품 화면 흐름 런타임 구현.
