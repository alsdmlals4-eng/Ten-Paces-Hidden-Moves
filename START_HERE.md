# 십보강호 시작 지점

## 기본 읽기

```text
최신 사용자 지시
→ 최신 Base completed main / Base root AGENTS.md
→ AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ [기획서]/00_프로젝트_허브/DOCUMENTATION_MAP.md
→ skills/SKILL_REGISTRY.json
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·GitHub metadata
→ repository human-facing owner when planning/visual/state is relevant
```

현행 실행 workspace 계약은 `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`이며, r5.4는 product-safety baseline으로 유지한다. `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`은 `SUPERSEDED_HISTORICAL_EVIDENCE`다. `docs/BASE_RULES_VERSION.md`는 과거 Base release 채택 pin을 current Base remote truth와 구분하기 위한 compatibility/adoption evidence entrypoint다.

`skills/SKILL_REGISTRY.json`이 현재 프로젝트 고유 Skill authority다. `[기획서]/00_프로젝트_허브/SKILL_REGISTRY.json`은 legacy compatibility reference이며 기본 cold-start에서 로드하지 않는다.

## 안정 authority

```yaml
current_state_owner: ACTIVE_CONTEXT
current_pr_authority: GITHUB_PR_METADATA
current_human_workspace: REPOSITORY_HUMAN_FACING_CANON
current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
current_work_contract: TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01
product_safety_contract_baseline: TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01
design_platforms: WINDOWS_ANDROID
platform_core_architecture: SINGLE_CORE_PLATFORM_ADAPTERS
base_authority: LATEST_COMPLETED_BASE_OWNER_PLUS_PROJECT_COMPATIBILITY_PIN
fresh_read_bootstrap: PROJECT_GITHUB_REPOSITORY_OWNER_RECONSTRUCTION_REQUIRED
past_conversation_required: false
```

활성 PR·exact SHA·현재 Work Mode·제품 단계·현재 구현 상태·승인 수·다음 package/Decision·device/Human evidence는 이 파일에 복제하지 않는다. 작업 재개 시 `ACTIVE_CONTEXT.md`, current planning JSON, GitHub live metadata, repository human-facing/structured owner를 fresh-read한다.

repository owner와 actual implementation/current GitHub metadata의 의미가 다르면 과거 대화·Handoff로 추정하지 않고 `CONTEXT_DRIFT_RECHECK_REQUIRED`다.

## DOMAIN SPLIT

- `REPOSITORY_HUMAN_FACING_CANON`: 사람이 읽고 비교·수정하는 Project Home equivalent, Flow, Visual, 핵심 표와 전체 그림.
- `REPOSITORY_STRUCTURED_CANON` / `REPOSITORY_RUNTIME_TRUTH`: Markdown/JSON, game data, code, Scene, Resource, tests, tracked asset, CI, runtime truth.
- Google Sheets: 고유 미이관 자료가 남은 경우의 `MIGRATION_ONLY_UNTIL_REMOVAL` source. 신규 current GDD 입력면이 아니다.

Notion은 historical migration input이며 새 output·attachment·sync·destination readback 대상이 아니다.

## 프로젝트 코어

- 1대1 10칸 일자형 **논리 전장**.
- 시작 공개 거리 2, 거리 0 `[밀착]`.
- 플레이어 기본 전투 화면은 절대 번호보다 `거리 N`을 우선한다.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론.
- AI의 미확정 플레이어 계획 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없음.
- 무공서가 아니라 현재 해금 기술을 수에 배치.
- 핵심 재미는 불완전한 공개 정보에서 여러 가능성을 견디는 계획을 만들고, 해결·복기로 왜 상대의 의도가 무너졌는지 이해해 다음 계획을 바꾸는 데 있다.

정확한 현재 전투 수치와 legacy/runtime binding은 `docs/02_COMBAT_RULES.md`, 최신 Decision, 실제 runtime을 함께 읽는다.

## 플랫폼·UI 최소 경계

- 현재 대상 플랫폼은 `Windows`와 `Android`다.
- 두 플랫폼은 단일 전투·AI·콘텐츠·ID·수치·저장 코어를 공유한다.
- 플랫폼 차이는 입력, 반응형 UI/안전영역, 앱 생명주기/뒤로가기, 플랫폼 서비스, export/품질/성능 adapter로 제한한다.
- Android 실제 지원 완료는 실기기 evidence 전에는 주장하지 않는다.
- localization-ready 최소 계획: `ko / en / ja / zh-*`; Chinese variant는 별도 Decision 전 `UNKNOWN_UNVERIFIED`.
- responsive 최소 계획: `pc_standard / pc_wide_or_ultrawide / mobile_landscape`; 정보 위계·행동·상태·피드백 의미를 동일하게 유지한다.

## Godot·Codex 현재 실행 경계

```text
GPT → 기획 / 조사 / 검수 / Base / repository 문서 / Visual
실제 Godot 제품 구현 필요 → CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF
Codex → Project GitHub + repository owner 독립 fresh-read → 자신의 구현환경에서 구현/test/runtime evidence
GPT → 최종 검수/정본/PR closeout
```

- GPT→PowerShell→local Codex launcher는 current route가 아니다.
- project-specific `CODEX_HOME`, 과거 dedicated Godot/8003/9503 checkpoint를 current readiness로 사용하지 않는다.
- PowerShell은 Godot 로컬 실행·검증이 실제 필요할 때만 사용한다.
- 호환 가능한 host에서는 shared approved exact Godot pin + Godot AI 기본 포트 + exact project/editor/session identity를 기본으로 한다.

## Visual 현재 실행 경계

새 이미지 생성·생성형 편집은 current r5.4 product-safety baseline과 최신 사용자 지시에 따라 `text brief → scoped single generation → user final lock → review`다. 2026-08-25의 최대 3장 묶음은 history이며 current 자동 batch 권한이 아니다.

현재 승인 Visual과 다음 제작 대상은 `docs/planning-data/current_user_planning_status.json`, `docs/planning-data/current_visual_production_handoff_20260826.json`, repository Visual/asset owner에서 fresh-read한다. `docs/planning-data/current_visual_production_handoff_20260825.json`은 승인 Reference Set과 당시 max-three cadence의 역사 evidence다.

## Work Mode

- `PLAN`: 설계·근거·순서·Decision.
- `BUILD`: 승인 범위 구현.
- `REVIEW`: 적대적 검토·검증·최소 수정.

실제 current Work Mode와 다음 작업은 `ACTIVE_CONTEXT.md`와 current structured JSON이 소유한다.

## 역사·호환

- PR #7과 Issue #13: T0 `STEP 0~13` 구현 계보.
- PR #45: v6 계획 통합 이력.
- PR #65: ActionSelectionDock/화면 구조 구현 이력.
- PR #92: 초기 10권 무공 런타임·UI/AI·자동 제품 검증 이력.
- `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`: `SUPERSEDED_HISTORICAL_EVIDENCE`.
- `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`: `SUPERSEDED_HISTORICAL_EVIDENCE`.
- Base release pin은 프로젝트 채택 이력/호환 증거이며 Base remote current를 대신하지 않는다.
- `TEN-DEC-20260811-LOCAL-EXECUTOR-BOOTSTRAP-01`의 CODEX_HOME·dedicated port 상태는 역사 evidence다.

자동·정적·CI 검증은 Windows visible, 실물 입력, Android 실제 기기, 접근성 사용자, Release 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 항목은 `NOT_RUN`이다.
