# 십보강호 문서 지도

이 지도는 **어떤 질문을 어느 현재 책임 원본에서 읽을지**만 정한다. 활성 PR·exact head·현재 Work Mode·현재 구현 상태·검증 상태·승인 수·다음 package/Decision처럼 merge마다 바뀌는 값은 복제하지 않는다.

기본 읽기:

```text
AGENTS.md
→ docs/BASE_RULES_VERSION.md
→ docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md
→ 이 문서
→ 최신 관련 Decision
→ 질문별 책임 원본
→ 실제 코드·데이터·Scene·테스트·PR
```

## 질문별 현재 책임 원본

| 질문 | 현재 책임 원본 |
|---|---|
| 현행 전체 작업 방식·검증·병합·전달 계약 | `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md` / `TEN-DEC-20260811-INTEGRATED-WORK-CONTRACT-V4-5-R2-01` |
| 현재 단계·권한·다음 작업 | `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` + GitHub current metadata + exact Project Notion |
| 프로젝트가 채택한 Base release·payload/evidence/finalization pin | `docs/BASE_RULES_VERSION.md`, `skills/PROJECT_BASE_ADAPTER.json` |
| 프로젝트 고유 Skill | `skills/SKILL_REGISTRY.json`, `skills/*/SKILL.md` |
| 게임 정체성·핵심 재미 | `docs/01_GAME_DESIGN.md` |
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
| 무공서·무학 과거 사용자-facing 표 | Google Sheet `03_무공서_무학` + 해당 Decision ID의 GitHub 정본 — migration 확인 전용 |

구조화 planning JSON은 각 Decision·분야 정본의 **검증 가능한 계약/ledger**다. 어떤 JSON이 현재 활성인지 여부는 Decision 연결과 `docs/CANON_LIFECYCLE_REGISTRY.md`를 통해 판정한다. 과거 PR·branch·merge SHA는 현재 책임 원본 목록에 넣지 않고 역사·증거 문서에서만 읽는다.

> 2026-08-20 사용자 v4.7 작업 계약에 따라 Google Sheets는 신규 기획 입력 경로가 아니라 `migration-only`다. 위 Sheet 항목은 과거/마이그레이션 발견 경계이며 새 Decision은 Project Notion + GitHub에 동기화한다.

## 최신 활성 Decision

이 지도는 “최신 Decision ID 목록”을 손으로 복제하지 않는다.

```text
현재 사용자 승인
→ [기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md의 보호 결정/현재 권위
→ docs/CANON_LIFECYCLE_REGISTRY.md
→ 관련 Decision 문서
→ 분야 책임 원본·planning JSON
→ Project Notion
```

Decision이 추가·대체·부분 overlay되면 위 권위 사슬을 갱신하고, 이 지도에는 **새 질문 종류 또는 책임 원본이 생길 때만** 경로를 추가한다.

## 현재 상태

이 지도는 current-state snapshot이 아니다.

```yaml
current_state_owner: ACTIVE_CONTEXT
current_pr_authority: GITHUB_PR_METADATA
current_notion_authority: EXACT_PROJECT_NOTION
legacy_discovery_compatibility: "current_sheet_authority: GOOGLE_SHEET_00_02_04_99"
current_decision_authority: ACTIVE_CONTEXT_PLUS_CANON_LIFECYCLE_REGISTRY
product_build_authority: CURRENT_WORK_CONTRACT_PLUS_USER_PLANNING_COMPLETE_PLUS_CURRENT_GATE
```

`legacy_discovery_compatibility`의 Sheet 문자열은 기존 회귀·발견 도구가 과거 구조를 찾기 위한 호환 토큰일 뿐이다. 신규 기획 입력·Decision 동기화·현재 사용자 작업 권위는 Project Notion + GitHub이며 Google Sheets는 migration-only다.

새 세션·post-merge에서는 저장된 SHA나 과거 PR 번호를 current로 재사용하지 않는다. `ACTIVE_CONTEXT.md`, GitHub main/open PR, exact Project Notion, current operating/entry gate를 fresh-read해 현재 상태를 판정한다.

안정적인 게임 코어·플랫폼·UI 의미는 해당 분야 책임 원본이 소유하며, 이 지도는 그 내용을 재서술하지 않는다.

## 구형·오해 표현 차단

현재 작업에 다음 표현을 권위로 사용하지 않는다.

- `PC 우선 / 모바일은 미래 고려` → 2026-08-06 Windows·Android dual-target Decision으로 대체됨.
- `플레이어4/상대7 = 현행 기획 시작거리` → current planning은 시작 공개 거리2이며 4/7은 `IMPLEMENTED_LEGACY`.
- `전투 UI의 1~10 번호 발판 상시 표시` → current player-facing UI는 `거리 N` 중심.
- `모든 카드에 사거리 행` → `[공격]` 행동에만 사거리 표시.
- `[태세]` 사용자 표시 → `[준비]`가 current player-facing 용어.
- `예상 명중률`, `% 명중률`, `[기절]` → current 전투 UI 개념이 아님.
- `PR #65 또는 PR #80이 현재 active planning truth` → 역사·구현 계보이며 current 상태는 fresh-read.
- `Image generation을 거쳐야만 모든 Build 가능` → 현재 이미지 상태와 적용 가능한 asset gate는 최신 사용자 지시·Active Context·Development Gates에서 다시 판정.
- `Google Sheets 신규 입력이 현재 GDD 작업 기본 경로` → v4.7에서 신규 입력은 중단하고 migration-only로 취급.

## 현재 다음 작업

이 지도는 다음 package를 고정하지 않는다.

```text
ACTIVE_CONTEXT의 current next action
→ 최신 사용자 지시·current Gate 안에서 PLAN/REVIEW
→ 사용자 명시 `기획 완료`
→ Base·Project main/open PR·exact Project Notion·Entry Gate 재조회
→ 현재 Build 권한·적용 Gate가 허용하는 승인 package만 구현
```

이미지·애니메이션·HX 생성 여부는 최신 사용자 지시와 current visual state를 다시 읽는다. 현재 또는 미래의 특정 생성 단계·PR 번호·Codex package 이름을 이 지도에 영구적인 선행 순서로 박아 두지 않는다.

## 역사·호환 경계

- PR #7 / Issue #13: T0 `STEP 0~13` 구현 계보.
- PR #45: v6 계획 통합 이력.
- PR #65: ActionSelectionDock·화면 구조 통합 이력.
- PR #68: Base v9.4 운영 계약 적용 이력.
- PR #72·#80: 이후 전투·성장 planning checkpoint 이력.
- PR #92: 초기 10권 무공 런타임·UI/AI·자동 제품 검증 계보.
- 과거 Base SHA와 당시 workflow/run은 역사 회귀 증거이며 current Base remote main이 아니다.

자동·정적·CI 검증은 로컬 Windows 실제 렌더, 실물 입력, Android 실제 기기, 접근성 사용자, Release 성능, 사람 플레이를 증명하지 않는다. 실행하지 않은 검증은 `NOT_RUN`이다.
