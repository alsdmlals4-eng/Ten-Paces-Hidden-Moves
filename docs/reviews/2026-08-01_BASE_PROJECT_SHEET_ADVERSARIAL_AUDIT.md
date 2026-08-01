# Base·십보강호·Google Sheets 적대적 통합 감사

- Audit ID: `TEN-AUD-010`
- 날짜: `2026-08-01`
- Work Mode: `REVIEW → BUILD → REVIEW`
- Base 기준: `alsdmlals4-eng/Base@a82976a3a42450ea413cdc5d4aebf701678110d8`
- 프로젝트 기준: PR `#65`
- 감사 결과: `CONFLICT_FIXED_WITH_DECLARED_GAPS`

## 1. 감사 범위

### Base

- `START_HERE.md`
- `AGENTS.md`
- `docs/OPERATING_MODEL.md`
- `docs/WORK_MODE_AND_SKILL_ROUTING.md`
- `docs/BASE_SHARED_SKILL_ADAPTER_CONTRACT.md`
- `docs/CONFIRMED_DECISION_SYNC_POLICY.md`
- `docs/PROJECT_GDD_GOOGLE_SHEETS_POLICY.md`
- `skills/SKILL_REGISTRY.json`의 생성 View
- 최근 v9.1~v9.3 release PR과 열린 BCP 제안

### 프로젝트

- PR #65·#66과 최근 병합 계보
- 프로젝트 Adapter·Skill Registry
- 시작점·Active Context·Documentation Map·Roadmap·결정 원장
- 행동 선택 Decision·Spec·Plan·구현·테스트
- 전투 실제 Scene·Script·Data·Workflow

### Google Sheets

- 25개 tab 구조
- `01_작업순서`
- `02_현재_확정결정`
- `04_누락_충돌_감사`
- `60_UX_UI_접근성`
- `80_데모_버티컬슬라이스_플레이테스트`
- `99_변경이력`

## 2. Base 구조 이해

- Base는 공용 판단·절차·품질 기준을 소유하고 프로젝트는 게임 고유 규칙·경로·자산·구현 상태를 소유한다.
- 모든 Skill을 기본 로드하지 않고 Registry trigger로 필요한 최소 Skill만 선택한다.
- Work Mode는 `PLAN / BUILD / REVIEW`를 분리한다.
- 프로젝트의 공용 Skill은 로컬 복사하지 않고 `skills/PROJECT_BASE_ADAPTER.json`으로 route한다.
- 승인 Decision은 분야 정본·GitHub·Google Sheets에 동일 ID로 반영하고 재조회해야 한다.
- Sheet는 `USER_FACING_GDD_WORKSPACE`이며 GitHub 정본과 실제 구현을 대체하지 않는다.

## 3. 검증된 Finding

### MUST_FIX — 해결

1. **행동 선택 구현 상태가 문서·Sheet에 누락됨**
   - 최신 Decision과 구현은 존재했지만 현재 결정 Sheet, UX Sheet, 변경이력에 없었다.
   - Decision·구조화 계약·Closeout·Sheet 동기화 대상으로 지정했다.

2. **연결 블록 마우스 Drag의 Drop 경로 누락**
   - Drag 시작과 이동 API는 있었으나 실제 슬롯 포인터 해제 소비자가 없었다.
   - RED 회귀 후 최소 신호 연결로 수정했고 Full Validation을 통과했다.

3. **상위 시작 문서의 단계·PR·Base 기준 drift**
   - README·START_HERE·AGENTS·Active Context·Documentation Map·Roadmap이 PR #45/PLAN/Base v8 중심으로 남아 있었다.
   - 현행 PR #65, ActionSelectionDock, Base v9.1 Adapter, 승인된 화면 구조를 기준으로 갱신한다.

4. **화면 명세 승인 상태 미확정**
   - 상세 명세가 사용자 검토 대기였으나 사용자가 권장안을 일괄 승인했다.
   - `TEN-DEC-20260801-SITUATION-SCREEN-01`과 같은 ID의 planning JSON으로 승인했다.

### SHOULD_FIX — 후속 분리

1. **Base v9.1 → v9.3 채택 검토**
   - Base main은 v9.3 release 상태지만 프로젝트 Adapter는 검증된 v9.1에 고정돼 있다.
   - 현재 대형 제품 PR에서 release pin과 생성물을 함께 교체하지 않는다.
   - PR #65가 main에 안정화된 뒤 별도 migration PR로 수행한다.

2. **Legacy freshness 설정의 이중 기준**
   - 일부 strict 문서는 과거 Base v8 SHA·PR #7·Issue #13 token을 회귀 증거로 요구한다.
   - 현재 문서에서는 이를 `HISTORICAL_COMPATIBILITY_BASELINE`으로만 보존한다.
   - v9.3 migration에서 freshness 설정과 생성물을 함께 재생성한다.

3. **대형 CombatBoardPreview 책임**
   - 전투 판정은 재사용 가능하지만 화면 조립·레이아웃·입력·연출·오디오·재시작 책임이 집중돼 있다.
   - App Flow Shell 이후 컴포넌트 경계를 단계적으로 추출한다.

### DEFER

- 후보 15명 전체 구현
- 최종 아트·오디오 폴리싱
- 주요 비무 6~10
- 천하제일인·비동기 전투
- 16개 개별 절초

### BLOCKED_UNVERIFIED

- 실제 Windows Godot 조작
- 사람 플레이와 이해도
- 게임패드 실제 장치
- 실제 해상도별 시각 검수
- 화면 읽기 도구
- 성능 프로파일

## 4. 보호한 코어

- 1대1 10칸 일자형 전장
- 거리 0 `[밀착]`
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`
- 비공개 동시 계획
- 상대 미확정 계획 비열람
- 덱·손패·드로우·장착 제한 없음
- 무공서→해금 기술
- 순차 `[합]`·방어도·중단·복기
- 데모 5슬롯·후보 3명 계약

## 5. 현재 다음 작업

```text
PR #65 정본·Sheet 동기화와 병합
→ post-merge main·Sheet 재조회
→ VERTICAL_SLICE_APP_FLOW_SHELL 계획·구현
→ 행동 선택 Dock을 제품 흐름에 연결
→ 저충실도 화면·저장·transaction 자동 검증
→ 실제 화면·입력·사람 검증
→ 후보 풀 반복 제작
```

## 6. 최종 판정

- 행동 선택 Dock: `IMPLEMENTED_AUTOMATED_VALIDATION_PASS_HUMAN_PENDING`
- 상황별 화면 구조: `APPROVED_PLANNING_RUNTIME_NOT_STARTED`
- 프로젝트 Sheet: `SYNC_PENDING_PR65_MAIN`
- Base v9.3 migration: `SEPARATE_FOLLOWUP`
- 사람 검증: `NOT_RUN`
