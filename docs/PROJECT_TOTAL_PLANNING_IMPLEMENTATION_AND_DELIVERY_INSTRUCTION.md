---
contract_name: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION
contract_version: '4.8'
status: ACTIVE_BASE_CURRENT_MAIN_THIN_ADAPTER_PROJECT_EXECUTION_CONTRACT
revision: '2026-08-26-r5.4-superset-final'
current_binding_decision: TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01
source_uploaded_sha256: fdf238c202cfac6d3a824aae49b8ac525fba023e31bba7df6ece64a2790365a0
base_repository: https://github.com/alsdmlals4-eng/Base
base_snapshot_observed_at_binding: edb3b3376603c9f6b00d64af3126304f8c9946bf
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_COMPLETED_MAIN
adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON
project_fact_policy: PROJECT_CANON_AND_ACTUAL_IMPLEMENTATION_FIRST
project_repository: https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves
project_default_branch: main
human_workspace: NOTION_DEFAULT_PROJECT_WORKSPACE
runtime_structured_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
open_pr_policy: OPEN_PR_READ_ONLY_BY_DEFAULT
current_task_pr_policy: CURRENT_TASK_CONTINUATION_AUTHORIZES_READY_MERGE
force_and_ruleset_bypass_policy: FORBIDDEN
quality_priority: QUALITY_OVER_RESPONSE_SPEED
minimum_viable_alternatives: 3
adversarial_full_loop_minimum: 5
implementation_reality_gate: REQUIRED
visual_generation_policy: TEXT_BRIEF_THEN_EXPLICIT_USER_APPROVAL_THEN_EXACTLY_ONE_RESULT
local_codex_policy: RETIRED_NOT_USED
gpt_local_codex_orchestration_policy: RETIRED
codex_execution_policy: INDEPENDENT_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF_ONLY
powershell_policy: LOCAL_GODOT_OR_VALIDATION_ONLY_NOT_CODEX_LAUNCHER
fresh_read_bootstrap_policy: PROJECT_GITHUB_NOTION_ONLY_RECONSTRUCTION_REQUIRED
past_conversation_dependency_policy: NOT_REQUIRED_FOR_NEW_CHAT_RESUME
shared_godot_runtime_policy: SHARED_APPROVED_EXACT_PIN_DEFAULT_NO_PER_PROJECT_DUPLICATE_BINARY
shared_godot_ai_port_policy: FIXED_DEFAULT_PORTS_WITH_EXACT_SESSION_ROUTING
minimum_localization_targets: [ko, en, ja, zh-*]
chinese_locale_variant: UNKNOWN_UNVERIFIED_USER_DECISION_REQUIRED_BEFORE_LOCALIZATION_LOCK
responsive_target_profiles: [pc_standard, pc_wide_or_ultrawide, mobile_landscape]
execution_scope_guard: PROJECT_WORK_ONLY_WHEN_CURRENT_USER_REQUEST_AUTHORIZES_EXECUTION
protected_product_paths:
  - data/
  - src/
  - scenes/
  - assets/
  - addons/
  - project.godot
historical_contracts:
  - decision: TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01
    status: SUPERSEDED_HISTORICAL_EVIDENCE
    structured_record: docs/planning-data/approved_20260824_integrated_work_contract_v4_8_r2_binding.json
  - decision: TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01
    status: SUPERSEDED_HISTORICAL_EVIDENCE
    body_root: docs/contracts/integrated-work-v4.5-r2/
---

# 프로젝트 총기획·시각화·구현·검증·병합 통합 작업지시문 v4.8 r5.4 — 십보강호 Thin Adapter

이 문서는 Base 공용 절차의 복사본이 아니다. 십보강호에서 새 채팅·새 담당자가 **현재 GitHub + 현재 Notion만 fresh-read하여 동일한 실행 경계**를 복원하도록 프로젝트 고유 불변식과 최신 계약 locator만 유지한다. 세부 Work Mode·Skill·CI·review·completion 절차는 실행 시점의 최신 Base owner를 progressive-load한다.

## 1. 시작·권위

```text
최신 사용자 지시
→ 최신 Base completed main + Base root AGENTS.md
→ 프로젝트 AGENTS.md
→ 이 r5.4 thin adapter
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ current planning JSON + GitHub live metadata + exact Project Notion
→ 최신 Decision / 질문별 owner
→ 실제 code/data/scene/resource/asset/test/runtime
```

- 과거 채팅·Handoff·저장된 SHA를 current truth로 자동 승격하지 않는다.
- GitHub와 Notion 의미가 다르면 mutation 전에 `CONTEXT_DRIFT_RECHECK_REQUIRED`다.
- Google Sheets는 고유 미이관 자료를 찾는 `MIGRATION_ONLY_UNTIL_REMOVAL` source이며 신규 기획·승인·current state 작업면이 아니다.
- Base v9.4.3 등 프로젝트가 보존한 release pin은 compatibility/adoption evidence이지 current Base remote truth가 아니다.

## 2. DOMAIN SPLIT

**Notion**은 사람용 Project Home, Flow/Storyboard, 세계관·캐릭터·핵심 시스템 설명, 승인 Visual, 사람이 직접 비교·수정하는 핵심 표를 소유한다.

**GitHub repository**는 Markdown/JSON structured canon, game data, code, Scene/Resource, tracked asset, tests, CI, runtime evidence를 소유한다.

승인된 의미 변경은 같은 Decision/Requirement identity로 올바른 양쪽 owner에 반영하고 destination readback한다. 한쪽의 보기 좋은 설명이 다른 쪽의 실제 구현 사실을 덮어쓰지 않는다.

## 3. 프로젝트 코어·보호 범위

- 1대1 10칸 일자형 논리 전장.
- 시작 공개 거리 2, 거리 0 `[밀착]`; 플레이어 화면은 절대 번호보다 `거리 N` 중심.
- `3수 → 해결 → 3수 → 해결 → 4수 → 해결`.
- 공개 상태·해결 이력 기반 상대 추론; AI의 미확정 플레이어 계획·숨은 배치·UI 의도 신호 열람 금지.
- 덱·손패·드로우·장착 기술 제한 없이 현재 해금 기술을 수에 배치.
- 순차 `[합]`, 방어도, 회피, 중단, 강건, 복기.
- 성장은 판단을 대체하지 않고 파훼 선택지를 확장한다.
- Windows·Android는 전투 규칙·AI·콘텐츠·ID·수치·저장 의미의 공유 코어를 사용하고 플랫폼 차이는 adapter에 한정한다.

코어·Core Loop·주요 UX·경제/보상·서사 의미·저장 호환성을 바꾸는 변경은 새 Decision이 필요하다.

## 4. Work Mode·Skill·Evidence

- `skills/SKILL_REGISTRY.json`이 프로젝트-local Skill authority다.
- 최신 Base `skills/SKILL_REGISTRY.json`과 generated active map을 inventory하고 trigger가 맞는 Base Skill만 progressive-load한다.
- 파일 존재·tool discovery·CI success를 runtime/Human/player PASS로 승격하지 않는다.
- Windows visible, 실물 입력, Android actual device, accessibility user, release performance, Human/player experience를 실행하지 않았으면 `NOT_RUN` 또는 `BLOCKED_UNVERIFIED`다.
- 중요 요구는 `requirement → owner → implementation/canon → evidence → completion`으로 추적한다.
- 완료 후보는 최소 5회 full-scope adversarial loop와 clean exit 뒤에만 완료로 승격한다.

## 5. Godot·Codex·PowerShell 현재 역할

현재 실행 경계는 다음이다.

```text
GPT
→ 기획 / 조사 / 검수 / Base / Notion / 문서 / Visual

실제 Godot 제품 구현 없음
→ GPT가 정본 readback 후 닫음

실제 Godot 제품 구현 있음
→ CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF
→ Codex가 프로젝트 GitHub + Notion을 독립 fresh-read
→ Codex 자신의 구현환경에서 Godot 제품 구현/test/runtime evidence
→ READY_FOR_GPT_REVIEW
→ GPT 최종 검수/정본/PR closeout
```

현재 실행 경로에서 금지한다.

- GPT → PowerShell → local Codex one-shot launcher.
- 프로젝트별 `CODEX_HOME`을 필수 준비조건으로 사용.
- 과거 dedicated Godot binary/HTTP 8003/WS 9503 같은 checkpoint를 current readiness로 재사용.
- process/port 존재만으로 exact project/session readiness PASS 주장.

PowerShell은 사용자 PC의 **Godot 실행·검증·환경 확인이 실제 필요할 때만** 사용하며 Codex launcher가 아니다.

호환 가능한 host에서는 프로젝트별 동일 Godot binary/port를 증식하지 않고 **검증된 shared exact Godot pin + Godot AI 기본 포트 + exact project/editor/session identity**를 기본으로 한다. 프로젝트 정본의 engine compatibility가 shared pin과 맞지 않으면 자동으로 열지 않고 compatibility Gate를 다시 판정한다.

## 6. Visual·UI·Localization

Visual 제작 전 current Notion Visual Bible/Asset Library와 repository Visual requirement/inventory를 읽고 `VISUAL_REQUIREMENT_DELETE_TEST`, asset coverage, Art Style Lock을 확인한다.

새 이미지 생성/생성형 편집은 현재 계약에서:

```text
canon review
→ text brief
→ 사용자 명시 승인
→ 정확히 1개 결과 생성
→ 사용자 결과 검토
→ 승인 뒤에만 Notion/repository asset lifecycle 진행
```

과거 2026-08-25의 `한번에 최대 3장` 작업 메모는 역사 승인 맥락으로 보존하되, 2026-08-26 r5.4 current execution에서는 자동 batch 권한으로 사용하지 않는다.

UI/구조는 최소 `ko / en / ja / zh-*`를 수용할 localization-ready 구조로 계획한다. 중국어 variant는 이 계약에서 추정하지 않으며 프로젝트 Decision으로 `zh-Hans / zh-Hant / both` 중 하나를 확정하기 전 `UNKNOWN_UNVERIFIED`다.

반응형 최소 계획은 `pc_standard / pc_wide_or_ultrawide / mobile_landscape`이며 pixel-identical이 아니라 동일 정보 위계·행동 의미·상태 의미·피드백 의미를 보호한다.

## 7. 현재 제품·시각 상태 해석

현재 제품 단계·Visual 승인·다음 작업은 이 문서에 snapshot으로 고정하지 않는다. 다음 current owner를 fresh-read한다.

- `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
- `docs/planning-data/current_user_planning_status.json`
- `docs/planning-data/current_visual_production_handoff_20260825.json`
- `docs/planning-data/current_operating_state.json`
- exact Project Notion Home / Visual Bible / Asset Library
- GitHub live main/open PR/recent commits

이미 병합된 첫 5전 PC-first Vertical Slice Phase I–VI를 이 계약 교체만으로 되돌리지 않는다. 추가 제품 mutation은 current Gate와 사용자 요청을 다시 확인한다.

## 8. Open PR·CI·완료

- 모든 pre-existing open/draft/ready PR은 `READ_ONLY`가 기본이다.
- current-task continuation이 latest completed main에서 직접 만든 하나의 명확한 PR만 exact HEAD·required checks·review/thread/ruleset Gate 뒤 safe merge할 수 있다.
- direct main push, force push, admin/ruleset bypass는 금지한다.
- CI check 이름과 required 상태는 live repository/ruleset에서 발견한다.
- `REQUIRED_WORK_REMAINING: 0`은 completion candidate이며 correction rescan + 최소 5회 adversarial loop + postmerge GitHub/Notion readback 뒤에만 종료한다.

## 9. r2 → r5.4 migration/non-regression

`TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`의 프로젝트 고유 의미는 삭제하지 않는다.

- Notion human canon / repository runtime canon / Sheet migration-only: **PRESERVED**.
- Base progressive-load / open PR read-only / IRG / 5회 adversarial review: **PRESERVED**.
- Fresh-Read GitHub+Notion cold-start: **IMPROVED**.
- Visual exactly-one approval loop: **CURRENT r5.4 OVERRIDE**.
- GPT→PowerShell→local Codex, project CODEX_HOME, dedicated port readiness: **INTENTIONALLY SUPERSEDED** by independent Codex Godot product handoff + local Godot validation-only PowerShell.
- dated/fixed Skill·PR·CI/tool counts: **INTENTIONALLY SUPERSEDED** by live discovery.

r2 Decision과 structured record는 historical evidence로 보존한다. 이 r5.4 adapter 변경 자체는 제품 코드·Scene·Resource·Asset·전투 규칙을 변경하지 않는다.
