# 십보강호 문서 지도

이 지도는 **어떤 질문을 어느 현재 책임 원본에서 읽을지**만 정한다. 활성 PR·exact HEAD·현재 Work Mode·제품 단계·구현 상태·검증 상태·승인 수·다음 package/Decision 같은 mutable state는 복제하지 않는다.

기본 읽기:

```text
최신 사용자 지시
→ 최신 Base completed main / Base root AGENTS.md
→ AGENTS.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ 이 문서
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·Resource·테스트·GitHub metadata
→ repository human-facing owner when planning/visual/state is relevant
```

## 질문별 현재 책임 원본

| 질문 | 현재 책임 원본 |
|---|---|
| 현행 전체 작업 방식·검증·병합·전달 계약 | `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` / `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01` |
| 새 L1+ package의 10종 이상 사전 벤치마크·역공학 | `TEN-DEC-20260830-PREWORK-BENCHMARK-REVERSE-ENGINEERING-GATE-01`, `docs/planning-data/approved_20260805_work_governance_contract.json`, `docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md` |
| 현재 단계·권한·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` + current planning JSON + GitHub current metadata + repository owners |
| 사람용 Project Home·전체 Flow·Visual·사람이 수정하는 핵심 표 | repository (`REPOSITORY_HUMAN_FACING_CANON`) |
| 구조화 정본·실제 구현·런타임 증거 | repository (`REPOSITORY_STRUCTURED_CANON` + `REPOSITORY_RUNTIME_TRUTH`) |
| Google Sheets 과거 고유 자료 | `docs/PROJECT_GOOGLE_SHEET_WORKBOOK.md`에 등록된 legacy workbook — `MIGRATION_ONLY_UNTIL_REMOVAL` |
| 프로젝트의 과거 Base release·payload/evidence/finalization pin | `docs/BASE_RULES_VERSION.md`, `skills/PROJECT_BASE_ADAPTER.json` — compatibility/adoption evidence |
| 프로젝트 고유 Skill | `skills/SKILL_REGISTRY.json`, `skills/*/SKILL.md` |
| 게임 정체성·핵심 재미 | `docs/01_GAME_DESIGN.md` |
| 통합 기획·AI 실행 명세·Notion 이관표 | `docs/design/PROJECT_AI_PRODUCTION_SPEC.md` — active project-wide machine-searchable narrative source; paired source snapshot `afa152b`, delivery lineage `18d647c` |
| 현재 사람용 master GDD publication | `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf` — `CURRENT_HUMAN_DERIVED_PUBLICATION`, 36-page baseline을 원문 그대로 보존하고 9-page visual/wireframe layer를 추가한 46-page human view; source owner 또는 latest-repository-commit 판정자 아님 |
| 세계·플레이어 역할·강호 비무행·5전 감정곡선·비전투 App Flow | `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`, `TEN-DEC-20260820-JIANGHU-JOURNEY-VERTICAL-SLICE-01` |
| 전투 규칙·판정·자원·AI·관찰 | `docs/02_COMBAT_RULES.md` |
| 전투 UI 정보 위계·거리·카드·관찰 표시 | `docs/decisions/2026-08-11_COMBAT_UI_INFORMATION_HIERARCHY_DECISION.md`, `docs/07_COMBAT_UI_SPEC.md` |
| 콘텐츠 범위 | `docs/03_CONTENT_CATALOG.md` |
| 장기 로드맵·제품 증거 체크포인트 | `docs/04_ROADMAP.md` |
| 현재 제품 실행 범위·PoC 경계 | `docs/05_COMBAT_POC_SPEC.md` |
| 시작 무공·성취 가설·구현 경계 | `docs/06_STARTING_FACTION_MASTERY_DATA.md` |
| 테스트 기준 | `docs/08_TEST_CHECKLIST.md` |
| 전투 시스템 구조 | `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md` |
| 표현·리플레이 계획 | `docs/10_COMBAT_PRESENTATION_PLAN.md` |
| Base 채택·학습 이력 | `docs/11_BASE_ADOPTION_AND_LEARNING_LOG.md` |
| 플랫폼 범위 | `docs/decisions/2026-08-06_WINDOWS_ANDROID_DUAL_TARGET_DECISION.md` |
| 플랫폼 Adapter 구조 | `docs/decisions/2026-08-06_WINDOWS_ANDROID_ADAPTER_ARCHITECTURE_DECISION.md` |
| 화면 구조 | `docs/decisions/2026-08-01_SITUATION_SCREEN_ARCHITECTURE_DECISION.md` |
| 행동 선택 | `docs/decisions/2026-08-01_MARTIAL_MANUAL_TECHNIQUE_TIMELINE_UX_DECISION.md` |
| 현재 Visual production Gate | `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md` + `docs/planning-data/current_visual_production_handoff_20260826.json` + repository Visual/asset records |
| 현재 목표 Build의 실제 화면·screen-to-asset coverage·제작 방식·Codex handoff | `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md` §16 + actual `scenes/run/vertical_slice_shell.tscn` / `src/run/vertical_slice_run_state.gd` + repository Flow/Visual/Asset owners |
| 2026-08-25 Visual Reference/handoff history | `docs/18_VISUAL_PRODUCTION_HANDOFF_2026-08-25.md` + `docs/planning-data/current_visual_production_handoff_20260825.json` |
| 무공서·무학 과거 사용자-facing 표 | legacy Sheet `03_무공서_무학` + 해당 Decision ID의 repository destination — migration 확인 전용 |

구조화 planning JSON은 각 Decision·분야 정본의 검증 가능한 계약/ledger다. 어떤 JSON이 현재 활성인지 여부는 Decision 연결과 `docs/CANON_LIFECYCLE_REGISTRY.md`를 통해 판정한다. 과거 PR·branch·merge SHA는 현재 책임 원본 목록에 넣지 않고 역사·증거 문서에서만 읽는다.

## Human Game Blueprint layered route

`HUMAN_GAME_BLUEPRINT_GDD_LAYERED_PROFILE`

`NO_SEPARATE_BLUEPRINT_ARTIFACT`

Blueprint는 세 번째 정본 문서가 아니다. AI spec이 layered route를 선언하고, 20260829 baseline 36쪽을 원문 그대로 보존한 20260902 additive PDF가 current human master publication으로 연결된다. master role은 `AI_PRODUCTION_SPEC_MARKDOWN`과 `HUMAN_MASTER_GDD_PDF` 정확히 둘이며, mutable state나 rules를 이 지도에 복사하지 않는다.

| layer | 책임 질문 | current route |
|---|---|---|
| `PROJECT_PLAYER_LAYER` | 게임·player promise·first 5/15/30 | AI spec §02–§06 |
| `SYSTEM_LAYER` | core flow/system/rules/state | AI spec §07–§08, §18–§20 |
| `CONTENT_UX_PRESENTATION_LAYER` | content/UI/input/visual/audio consumer | AI spec §09–§13 |
| `PRODUCTION_EVIDENCE_LAYER` | implementation owner/test/runtime/UX evidence | AI spec §14–§17, §21–§27 |

```text
3-MINUTE PROJECT / PLAYER READ
-> 10-MINUTE SYSTEM + CONTENT / UX / PRESENTATION READ
-> DETAIL READ
-> IMPLEMENTATION READ
-> VERIFICATION READ
```

`exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260828.pdf`만 `HISTORICAL_DERIVED_NOT_CURRENT_SOURCE`다. `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf`는 current human master가 아니라 `PRESERVED_BASELINE_SOURCE_36_PAGES`이며, current 20260902 additive PDF는 repository owner보다 높은 source가 아니다. `TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf`는 current master가 아닌 absorbed focused output이다.

## Prospective package lifecycle

`PLAN -> REQUIRED_IMAGE_AND_MATERIAL_PREPARATION -> BLUEPRINT_REVIEW_PUBLICATION -> USER_FINAL_REVIEW_APPROVAL -> IMPLEMENTATION_START`

- `NO_POST_ADOPTION_IMPLEMENTATION_PACKAGE_BEFORE_USER_FINAL_APPROVAL`: profile 채택 뒤 새 package는 exact reviewed revision에 대한 명시적 `USER_FINAL_APPROVAL` 전 시작하지 않는다.
- `ISSUE267_EXISTING_APPROVED_PACKAGE_GRANDFATHERED_NON_RETROACTIVE`: Issue #267의 기존 Decision/contract/exact scope는 이미 사용자 구현 승인을 받았으므로 새 approval 없이 시작할 수 있다. scope 확대나 successor package는 포함하지 않는다.
- `LATER_PACKAGES_REQUIRE_BLUEPRINT_REVIEW_AND_USER_FINAL_APPROVAL`: Issue #267 evidence 뒤 첫 balance instrumentation과 이후 package는 새 lifecycle과 명시적 final approval이 필요하다.
- `EXISTING_MERGED_RUNTIME_FACTS_NO_ROLLBACK`: 이 prospective gate는 기존 merged code/data/Scene/test와 과거 runtime evidence를 취소하지 않는다.

## 최신 활성 Decision

이 지도는 “최신 Decision ID 목록”을 손으로 복제하지 않는다.

```text
현재 사용자 승인
→ ACTIVE_CONTEXT.md의 보호 결정/현재 권위
→ docs/CANON_LIFECYCLE_REGISTRY.md
→ 관련 Decision 문서
→ 분야 책임 원본·planning JSON
→ repository human-facing owner when human-facing projection is required
```

Decision이 추가·대체·부분 overlay되면 위 권위 사슬을 갱신하고, 이 지도에는 **새 질문 종류 또는 책임 원본이 생길 때만** 경로를 추가한다.

## 현재 상태

이 지도는 current-state snapshot이 아니다.

```yaml
current_state_owner: ACTIVE_CONTEXT
current_pr_authority: GITHUB_PR_METADATA
current_human_facing_authority: REPOSITORY_HUMAN_FACING_CANON
current_structured_runtime_authority: GITHUB_REPOSITORY_AND_ACTUAL_RUNTIME
google_sheets_policy: MIGRATION_ONLY_UNTIL_REMOVAL
legacy_sheet_migration_locator: GOOGLE_SHEET_00_02_04_99
current_decision_authority: ACTIVE_CONTEXT_PLUS_CANON_LIFECYCLE_REGISTRY
product_build_authority: CURRENT_WORK_CONTRACT_PLUS_CURRENT_USER_APPROVAL_PLUS_CURRENT_GATE
```

Google Sheet/Notion locator는 기존 자료의 unique/duplicate/obsolete 분류와 migration readback을 위한 compatibility token일 뿐이다. 신규 기획 입력·Decision 동기화·현재 사용자 작업 권위는 repository를 사용한다.

새 세션·post-merge에서는 저장된 SHA나 과거 PR 번호를 current로 재사용하지 않는다. `ACTIVE_CONTEXT.md`, current planning JSON, GitHub main/open PR, repository human-facing/structured owner, current operating/entry gate를 fresh-read해 현재 상태를 판정한다.

안정적인 게임 코어·플랫폼·UI 의미는 해당 분야 책임 원본이 소유하며, 이 지도는 그 내용을 재서술하지 않는다.

## 구형·오해 표현 차단

현재 작업에 다음 표현을 권위로 사용하지 않는다.

- `PC 우선 / 모바일은 미래 고려` → Windows·Android dual-target Decision으로 대체됨.
- `플레이어4/상대7 = 현행 기획 시작거리` → player-facing planning은 시작 공개 거리2이며 4/7은 runtime legacy binding으로 구분.
- `전투 UI의 1~10 번호 발판 상시 표시` → current player-facing UI는 `거리 N` 중심.
- `모든 카드에 사거리 행` → `[공격]` 행동에만 사거리 표시.
- `[태세]` 사용자 표시 → `[준비]`가 current player-facing 용어.
- `예상 명중률`, `% 명중률`, `[기절]` → current 전투 UI 개념이 아님.
- `PR #65 또는 PR #80이 현재 active planning truth` → 역사·구현 계보이며 current 상태는 fresh-read.
- `Image generation을 거쳐야만 모든 Build 가능` → 최신 사용자 지시와 current visual/asset gate에서 판정.
- `Google Sheets 신규 입력이 현재 GDD 작업 기본 경로` → `MIGRATION_ONLY_UNTIL_REMOVAL`로 대체됨.
- `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`이 current 작업계약 → 역사 evidence.
- `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`이 current 작업계약 → r5.4 product-safety baseline과 `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`로 대체됨.
- `2026-08-25 max-three image batch`가 current 자동 생성 권한 → 폐기된 당시 cadence.
- 이미지 생성 전 사용자 승인 필수 → 최신 사용자 지시에 따라 필요한 단일 시각자료는 생성 후 최종 방향 lock만 사용자 승인으로 받는다.

## 현재 다음 작업

이 지도는 다음 package를 고정하지 않는다.

```text
ACTIVE_CONTEXT + current planning JSON의 current next action
→ 최신 사용자 지시·current Gate 안에서 PLAN/BUILD/REVIEW 판정
→ Base·Project main/open PR·repository human-facing/structured owners·Entry Gate 재조회
→ Issue #267 exact scope이면 기존 승인 readback, 그 외 새 package이면 Blueprint review와 USER_FINAL_REVIEW_APPROVAL readback
→ 현재 승인과 Gate가 허용하는 package만 실행
→ evidence/readback 뒤 다음 current state를 다시 계산
```

이미지·애니메이션 생성 여부는 최신 사용자 지시와 current visual state를 다시 읽는다. 특정 생성 단계·PR 번호·Codex package 이름을 영구 선행 순서로 박아 두지 않는다.

## 역사·호환 경계

- PR #7 / Issue #13: T0 `STEP 0~13` 구현 계보.
- PR #45: v6 계획 통합 이력.
- PR #65: ActionSelectionDock·화면 구조 통합 이력.
- PR #68: Base v9.4 운영 계약 적용 이력.
- PR #72·#80: 이후 전투·성장 planning checkpoint 이력.
- PR #92: 초기 10권 무공 런타임·UI/AI·자동 제품 검증 계보.
- `TEN-DEC-20260824-INTEGRATED-WORK-CONTRACT-V4-8-R2-01`: `SUPERSEDED_HISTORICAL_EVIDENCE`.
- `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01`: `SUPERSEDED_HISTORICAL_EVIDENCE`.
- `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260828.pdf`: `HISTORICAL_DERIVED_NOT_CURRENT_SOURCE`; current master role 없음.
- 과거 Base SHA와 당시 workflow/run은 역사 회귀 증거이며 current Base remote main이 아니다.

자동·정적·CI 검증은 로컬 Windows 실제 렌더, 실물 입력, Android 실제 기기, 접근성 사용자, Release 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 검증은 `NOT_RUN`이다.
