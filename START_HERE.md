# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ skills/SKILL_REGISTRY.json
→ [기획서]/00_프로젝트_허브/SKILL_REGISTRY.json
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

현행 통합 작업계약은 `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01` / `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`다. 백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 로드하지 않는다. `skills/SKILL_REGISTRY.json`은 현재 프로젝트 고유 Skill 권한이며 `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 호환 진입점이다.

## 현재 기준

`START_HERE.md`는 **안정적인 cold-start router**다. 활성 PR·exact head·현재 Work Mode·구현 상태·검증 상태·승인 수·다음 package/Decision처럼 merge마다 바뀌는 값은 복제하지 않는다.

```yaml
current_state_owner: ACTIVE_CONTEXT
current_pr_authority: GITHUB_PR_METADATA
current_sheet_authority: GOOGLE_SHEET_00_02_04_99
current_work_contract: TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
product_build_requires_user_planning_complete: true
base_authority: BASE_RULES_VERSION_PLUS_PROJECT_BASE_ADAPTER
```

현재 상태를 묻거나 작업을 재개할 때는 `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`를 읽은 뒤 GitHub `main`·열린 PR과 Google Sheet `00·02·04·99`를 다시 조회한다. Branch 승인 상태는 GitHub PR metadata와 비교하고, 병합 후 main·Sheet 재조회 전에는 `SYNCED_TO_MAIN`으로 표시하지 않는다.

## 현재 책임 원본

- 통합 작업계약: `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` / `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`.
- 변동 상태·현재 다음 작업: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
- 문서 지도: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`.
- Base 적용 권위: `docs/BASE_RULES_VERSION.md`와 `skills/PROJECT_BASE_ADAPTER.json`.
- 전투 규칙: `docs/02_COMBAT_RULES.md`.
- 전투 UI 정보 위계: `docs/decisions/2026-08-11_COMBAT_UI_INFORMATION_HIERARCHY_DECISION.md`.
- 행동 선택: `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`.
- 화면 구조: `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`.
- 플랫폼 범위: `docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md`.
- 플랫폼 Adapter 구조: `docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md`.
- 최신 총기획 감사: `docs/reviews/2026-08-02_BASE_PROJECT_SHEET_TOTAL_PLANNING_AUDIT.md`.

과거 구현 PR·merge SHA·증거 run은 Active Context의 명시적 역사/관측 섹션, 구현 closeout, PR metadata에서 읽으며 이 current 책임 원본 목록에 mutable checkpoint처럼 복제하지 않는다.

## 프로젝트 코어

- 1대1 10칸 일자형 **논리 전장**.
- 시작 공개 거리 2.
- 플레이어 기본 전투 화면은 절대 번호 발판보다 `거리 N`을 우선 표시한다.
- 거리 0은 `[밀착]`이다.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.
- 핵심 재미는 한 행동을 맞히는 것이 아니라 여러 가능성을 견디는 계획을 만들고, 해결·복기로 왜 상대의 의도가 무너졌는지 이해한 뒤 다음 계획을 바꾸는 데 있다.

새 절대 시작 좌표나 현행 런타임의 legacy 좌표처럼 구현 단계에 따라 달라지는 binding은 `docs/02_COMBAT_RULES.md`, Active Context, 실제 런타임을 함께 읽고 판단한다.

## 플랫폼 경계

- 현재 대상 플랫폼은 `Windows`와 `Android`다.
- 두 플랫폼은 단일 게임 로직·데이터 코어를 공유한다.
- 플랫폼 차이는 입력·UI 반응형 레이아웃·플랫폼 통합·export/delivery·성능 프로파일 어댑터로 제한한다.
- 플랫폼 세부 구현·검증 상태는 `AGENTS.md`, `ACTIVE_CONTEXT.md`, 현재 승인 Decision을 다시 읽고 판단하며 이 문서의 과거 상태 문자열을 구현 권한으로 사용하지 않는다.

## 현재 작업

`START_HERE.md`는 특정 PR 번호·이미지 생성·고정 package 이름을 현재 다음 작업으로 박아 두지 않는다.

```text
ACTIVE_CONTEXT의 current next action
→ 현재 Gate 안에서 기획·REVIEW 진행
→ 사용자 명시 `기획 완료`
→ Base·Project main/open PR·Sheet·Entry Gate 재조회
→ 별도 Build 권한과 current Gate가 모두 허용할 때만 구현 인계
→ 자동·Godot·Windows·Android·접근성·성능·사람 검증을 증거별로 분리
```

사용자 명시 `기획 완료` 전에는 제품 코드·Scene·런타임 데이터 BUILD를 시작하지 않는다. 이미지/애니메이션/HX 생성 여부와 현재 pause 상태도 Active Context와 최신 사용자 지시를 다시 읽고 판단한다.

## Work Mode

- `PLAN`: 설계·근거·순서·Decision.
- `BUILD`: 승인 패키지 구현.
- `REVIEW`: 적대적 검토·검증·최소 수정.

실제 current Work Mode는 Active Context가 소유한다.

## 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 계획 통합 이력이다.
- PR #65는 ActionSelectionDock과 화면 구조 통합 이력이다.
- PR #68은 Base v9.4 운영 계약 적용 이력이다.
- PR #72와 PR #80은 이후 전투·성장 기획 체크포인트 이력이다.
- PR #92는 초기 10권 무공 런타임·UI/AI·자동 제품 검증 계보다.
- `TEN-DEC-20260806-INTEGRATED-WORK-CONTRACT-V4-3-01`은 역사적 작업계약 바인딩이며 current authority는 v4.5 r2다.
- 현재 공용 Skill 적용 권위는 `skills/PROJECT_BASE_ADAPTER.json`의 채택 pin이다. Base remote current와 자동 동일시하지 않는다.

자동·정적·CI 검증은 로컬 Windows 실제 렌더, 실물 입력, Android 실제 기기, 접근성 사용자, Release 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN`이다.