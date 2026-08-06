# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ docs/planning-data/current_operating_state.json
→ docs/decisions/2026-08-06_WORK_ENTRY_COMPLETENESS_GATE_DECISION.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ skills/SKILL_REGISTRY.json
→ [기획서]/00_프로젝트_허브/SKILL_REGISTRY.json
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
→ 연결된 Google Sheet의 결정·감사·이미지 검수 readback
```

백업·보류·과거 계획·닫힌 PR·전체 Skill 폴더를 기본 로드하지 않는다. `skills/SKILL_REGISTRY.json`은 현재 프로젝트 고유 Skill 권한이며 `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 호환 진입점이다.

## 현재 기준

활성 기획 PR·exact head·승인 수·다음 Decision은 `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`와 `docs/planning-data/current_operating_state.json`이 함께 책임진다. 개발 도구 PR은 제품 기획 PR과 분리한다.

```yaml
product_stage: VERTICAL_SLICE_APP_FLOW_PLANNING
runtime_work_mode: REVIEW
active_planning_pr: NONE
active_tooling_pr: 104
active_tooling_package: GUT_9_7_1_HIGODOT_3_1_2_ADOPTION
runtime_implementation: TEN_MANUAL_PRODUCT_VALIDATION_MERGED_PR92
latest_combat_planning_runtime: PRODUCT_VALIDATION_AUTOMATED
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
next_package: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION
next_package_state: BLOCKED_BY_WORK_ENTRY_COMPLETENESS_GATE
next_planning_decision: WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION_GATE
work_entry_gate_decision: TEN-DEC-20260806-WORK-ENTRY-COMPLETENESS-GATE-01
product_implementation_entry: BLOCKED
tooling_visual_disposition: NO_NEW_VISUAL_ASSET_REQUIRED
human_validation: NOT_RUN
android_validation: NOT_RUN
base_release_pinned: 9.4.3
```

현재 Branch 승인 상태는 Active Context·current operating state·GitHub PR metadata·Google Sheet를 비교한다. 병합 후 main과 Sheet를 다시 읽기 전에는 `SYNCED_TO_MAIN`으로 표시하지 않는다.

## 작업 진입 필수 Gate

누락 방지는 체크리스트가 아니라 fail-closed Gate다. 다음 Surface를 새로 읽지 못하거나 서로 충돌하면 작업을 시작하지 않는다.

```text
GitHub 현행 Decision 원장
+ Sheet 02_현재_확정결정
+ Sheet 04_누락_충돌_감사
+ Sheet 71_이미지기획_생성목록
+ Sheet 72_이미지검수_승인로그
+ current_operating_state.json
```

제품 코드·Scene·Resource·데이터·플랫폼 Adapter 구현은 다음이 모두 닫힐 때만 시작한다.

```text
PLANNING_COMPLETE
AND REVIEW_COMPLETE
AND VISUAL_COMPLETE_OR_NO_NEW_ASSET_REQUIRED
AND NO_OPEN_P0_P1_CANON_CONFLICT
AND GITHUB_SHEET_SAME_DECISION_ID_SYNC
AND TEST_FIRST_ACCEPTANCE_EXISTS
```

현재 제품 Adapter 구현은 `PLANNING_REVIEW_VISUAL_AND_AUTHORITY_GATES_OPEN`으로 차단돼 있다. `READY`, `READY_NOT_RUN`, `AWAITING_IMPLEMENTATION`, `IMPLEMENTATION_READY`, `CODEX_READY`를 근거 없이 사용하지 않는다.

GUT·HiGodot 채택은 플레이어 화면·전투 규칙·제품 데이터를 바꾸지 않는 `GOVERNANCE_TOOLING` 범위다. 이 범위는 `NO_NEW_VISUAL_ASSET_REQUIRED`로 진행할 수 있으나 제품 구현 Gate를 해제하지 않는다.

## 현재 책임 원본

- 현재 상태: `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`.
- 기계 판독 상태: `docs/planning-data/current_operating_state.json`.
- 작업 진입 Gate: `docs/decisions/2026-08-06_WORK_ENTRY_COMPLETENESS_GATE_DECISION.md`.
- 문서 지도: `[기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md`.
- Base 버전: `docs/BASE_RULES_VERSION.md`.
- 전투 규칙: `docs/02_COMBAT_RULES.md`.
- 행동 선택: `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md`.
- 화면 구조: `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md`.
- 플랫폼 범위: `docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md`.
- Adapter 아키텍처: `docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md`.
- GUT·HiGodot 권위: `docs/decisions/2026-08-06_GUT_9_7_1_TEST_FRAMEWORK_ADOPTION_DECISION.md`.

## 프로젝트 코어

- 1대1 10칸 일자형 전장.
- 거리 0 `[밀착]`.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.
- 핵심 재미는 여러 가능성을 견디는 계획을 만들고, 해결·복기로 상대 의도가 왜 무너졌는지 이해한 뒤 다음 계획을 바꾸는 데 있다.

## 플랫폼 경계

- Windows와 Android는 기본 설계 대상이다.
- 전투 규칙·AI·콘텐츠 ID·수치·저장 Schema·결정적 해결은 하나의 공유 코어를 사용한다.
- 입력·반응형 UI·safe area·앱 생명주기·플랫폼 서비스·export만 Adapter로 분리한다.
- Windows CI 증거는 로컬 Windows 렌더·실물 입력을 대신하지 않는다.
- Android export·설치·실기기·터치·back·safe area·lifecycle·성능이 검증되기 전 지원 완료를 주장하지 않는다.

## HiGodot·GUT 경계

```yaml
HiGodot:
  authority: SOLE_GODOT_AUTHORING_AUTHORITY
  usage: bounded Scene, Node, Resource, project setting, script mutation with diff/Undo/save evidence
GUT:
  authority: GDSCRIPT_TEST_EXECUTION_AND_JUNIT_ONLY
  usage: CLI/CI tests and JUnit evidence
Python:
  authority: REPOSITORY_CANON_AND_STATIC_CONTRACT_VALIDATION
```

GUT EditorPlugin은 제품 프로젝트에서 활성화하지 않는다. HiGodot은 headless CI의 테스트 실행 권위가 아니고, GUT는 Scene·Resource 저작 권위가 아니다.

## 현재 작업 순서

```text
PR #104 GUT·HiGodot 도구 채택과 작업 진입 Gate 검증
→ exact-head CI·적대적 검토·독립 리뷰
→ 병합 후 main·Sheet 동일 Decision ID readback
→ 미확정 P0/P1·기획·검토·이미지 Gate 해소
→ WINDOWS_ANDROID_ADAPTER_IMPLEMENTATION 별도 TDD 패키지
→ 자동·Godot·Windows·Android·접근성·성능·사람 검증
```

제품 코드·Scene·런타임 데이터는 작업 진입 필수 Gate와 별도 Build 승인 전 변경하지 않는다.

## Work Mode

- `PLAN`: 설계·근거·순서·Decision.
- `BUILD`: 승인 패키지 구현.
- `REVIEW`: 적대적 검토·검증·최소 수정.
- `GOVERNANCE_TOOLING`: 제품 행동을 바꾸지 않는 CI·validator·테스트/저작 도구 채택.

## 역사·호환

- PR #7과 Issue #13은 T0 `STEP 0~13` 구현 계보다.
- PR #45는 v6 계획 통합 이력이다.
- PR #65는 ActionSelectionDock과 화면 구조 통합 이력이다.
- PR #68은 Base v9.4 운영 계약 적용 이력이다.
- PR #72와 PR #80은 전투·성장 기획 체크포인트 이력이다.
- PR #92는 무공서 10권 제품 자동 검증 구현 계보다.
- PR #101~#103은 Windows·Android 플랫폼 Decision과 Adapter 아키텍처·postmerge closeout 계보다.
- 현재 공용 Skill 권한은 `skills/PROJECT_BASE_ADAPTER.json`의 Base v9.4.3 pin이다.

자동·정적 검증은 로컬 Windows 실제 Godot, 실물 게임패드, Android 실기기, 화면 읽기 도구, Release 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN`이다.
