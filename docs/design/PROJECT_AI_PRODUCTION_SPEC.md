# PROJECT AI PRODUCTION SPEC — 십보강호

```yaml
artifact_role: AI_MASTER_GDD
pair_id: ten-paces-hidden-moves-20260829-afa152b
project_repository: alsdmlals4-eng/Ten-Paces-Hidden-Moves
project_source_branch: origin/main
project_sha: afa152b985975a3f8e6292ca0298d22a95c03872
delivery_lineage_commit: 18d647c34ae8544d58d79e870f82dde1ef1d0c55
base_repository: alsdmlals4-eng/Base
base_sha: 2e6fa14a93ffba177b22fd7ff21e2f654ea15bb0
generated_at_utc: 2026-08-29T00:59:49Z
document_version: 1.1.1
scope: vertical-slice production snapshot; documentation and delivery only
canonical_path: docs/design/PROJECT_AI_PRODUCTION_SPEC.md
human_pdf_path: exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf
source_priority: latest user direction > repository owners/Decisions > actual code/data/scene/tests > derived views > historical migration inputs > example PDF
overall_status: DOCUMENTED_CURRENT_SNAPSHOT / PRODUCT_RUNTIME_PARTIAL
known_stale_points: opponent runtime personality binding is implemented; deterministic balance instrumentation, human, Android, accessibility, audio and release evidence are NOT_RUN
```

> 목적: 이 문서는 GPT/Codex가 후속 기획·구현·검증을 안전하게 이어가기 위한 **검색 가능한 통합 생산 명세**다. 실제 코드·Scene·Resource·JSON·테스트 및 각 분야의 책임 원본을 대체하지 않는다. 새 규칙을 승인하거나 기존 owner를 하나로 병합하지 않으며, 충돌과 미검증은 그대로 표시한다.

## 00. CANON SNAPSHOT

| 항목 | 값 |
|---|---|
| 프로젝트 | Ten Paces: Hidden Moves / 십보강호 |
| source branch | `origin/main` |
| paired source snapshot | `afa152b985975a3f8e6292ca0298d22a95c03872` (`origin/main` at publication capture; not a claim about the repository's latest commit) |
| delivery lineage | `18d647c34ae8544d58d79e870f82dde1ef1d0c55` landed this complete spec/current PDF pair after the captured source snapshot |
| 기준일 | 2026-08-29 (KST) |
| 기준 PR / Issue | #261·#263 historical product/governance evidence; #273 opponent runtime personality binding implementation and #277 presentation are later verified successor facts; `TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01` begins the balance-instrumentation written-spec review |
| 현재 작업 성격 | repository current-state reconciliation + user-approved balance-instrumentation written-spec review. 이 문서 자체는 새 제품 런타임을 구현하지 않음. |
| 플랫폼 | Windows + Android, 공유 코어/플랫폼 adapter (`TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`) |
| 엔진 | Godot 4.7, `scenes/run/vertical_slice_shell.tscn` |
| 문서 상태 표기 | `DOCUMENTED / CONFIRMED / IMPLEMENTED / AUTOMATED_TEST_PASS / RUNTIME_VERIFIED / UX_VERIFIED / RELEASE_READY` |

### 00.1 읽기 우선순위

`최신 사용자 승인 → AGENTS.md → 분야별 repository owner/Decision → latest completed main의 코드·테스트 → open/draft PR → Base → optional historical migration input → historical chat` 순서다. migration input이 repository current truth와 다르면 코드 또는 문서 중 하나를 자동 정본화하지 않고 `CANON_CONFLICT`로 남긴다.

### 00.2 상태 요약

| 구분 | 판정 | 근거 |
|---|---|---|
| core combat / Phase 2 | `IMPLEMENTED + AUTOMATED_TEST_PASS` | #261과 `src/combat/`, `src/ui/`, `tests/` |
| Godot headless runtime | historical automated evidence exists; this document change did not rerun Godot | actual-window/person-input의 대체 아님 |
| Human usability / player fun | `NOT_RUN` | 사람이 플레이한 관찰·설문·영상 없음 |
| Android | `NOT_RUN` | export, 설치, touch, back, safe area, lifecycle 증거 없음 |
| Visual runtime | `PARTIAL` | 일부 배틀러·초상·카드 atlas·VFX consumer 있음; 전체 캐릭터/표현 검증 없음 |
| Audio | `NOT_RUN` | 승인된 runtime audio consumer 및 검증 증거 없음 |
| release | `NOT_RELEASE_READY` | 권리·스토어·실기기·성능·접근성 근거 미완성 |

### 00.3 MASTER ARTIFACT ROLES

`HUMAN_GAME_BLUEPRINT_GDD_LAYERED_PROFILE`

`NO_SEPARATE_BLUEPRINT_ARTIFACT`

이 선택형 profile은 새로운 Blueprint 파일을 만들지 않고 현재 두 master artifact 안에서 같은 ID와 evidence ceiling으로 읽기 계층을 제공한다. current master 역할은 아래 두 개뿐이다.

| master role | exact artifact | current boundary |
|---|---|---|
| `AI_PRODUCTION_SPEC_MARKDOWN` | `docs/design/PROJECT_AI_PRODUCTION_SPEC.md` | active project-wide machine-searchable narrative source |
| `HUMAN_MASTER_GDD_PDF` | `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf` | current additive human-facing derived publication: preserved 36-page 20260829 baseline + current nine-page frontal-duel visual/wireframe layer |

`HUMAN_BLUEPRINT_ADDITIVE_20260902`: `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf` = `CURRENT_HUMAN_DERIVED_PUBLICATION`. 이 46-page 파생본은 새 표지 1쪽, 원문 그대로 보존한 20260829 36쪽 baseline, current frontal-duel visual/wireframe addendum 9쪽을 주제별로 interleave한다. source owner나 최신 repository commit 판정자는 아니다. `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf` = `PRESERVED_BASELINE_SOURCE_36_PAGES`; 삭제하거나 10쪽으로 요약·치환하지 않는다. 기존 집중 10쪽 output은 새 master 안에 흡수된 `ABSORBED_DERIVED_OUTPUT`이며 current master 역할이 없다. `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260828.pdf` = `HISTORICAL_DERIVED_NOT_CURRENT_SOURCE`.

### 00.4 LAYERED READER ROUTE

| layer | first question | route into this spec |
|---|---|---|
| `PROJECT_PLAYER_LAYER` | 어떤 게임이고 플레이어가 무엇을 선택·학습하는가? | §02–§06, 특히 §05.1 first 5/15/30 |
| `SYSTEM_LAYER` | 핵심 flow와 system은 어떤 규칙·상태·피드백으로 작동하는가? | §07–§08, §18–§20 |
| `CONTENT_UX_PRESENTATION_LAYER` | 어떤 콘텐츠·화면·입력·시청각 consumer가 경험을 전달하는가? | §09–§13 |
| `PRODUCTION_EVIDENCE_LAYER` | 무엇이 구현 owner이고 어떤 evidence로 완료를 판정하는가? | §14–§17, §21–§27 |

```text
3-MINUTE PROJECT / PLAYER READ
-> 10-MINUTE SYSTEM + CONTENT / UX / PRESENTATION READ
-> DETAIL READ
-> IMPLEMENTATION READ
-> VERIFICATION READ
```

이 route는 기존 §05.1의 첫 5·15·30분 player contract를 대체하지 않는다. 앞의 route는 문서를 읽는 시간이고, §05.1은 제품 안에서 플레이어가 배우는 시간이다.

### 00.5 STATE AND EVIDENCE LEGEND

`STATE_AND_EVIDENCE_LEGEND`

| token | 이 문서가 허용하는 주장 | 아직 허용하지 않는 상위 주장 |
|---|---|---|
| `DOCUMENTED` / `CONFIRMED` | repository owner·Decision에 규칙 또는 범위가 기록됨 | code/runtime 동작 |
| `IMPLEMENTED` | exact code/data/Scene consumer가 존재함 | 현재 SHA test pass, 사람 이해, release 품질 |
| `AUTOMATED_TEST_PASS` | 명시한 SHA·환경의 자동 검증이 pass함 | visible Windows, Android device, accessibility, fun |
| `RUNTIME_VERIFIED` | 명시한 runtime/environment에서 관찰됨 | 다른 platform 또는 사용자군의 UX |
| `UX_VERIFIED` | 정의된 사람·과업·판정 기준의 관찰 evidence가 있음 | release readiness 전체 |
| `NOT_RUN` / `UNKNOWN_UNVERIFIED` | 해당 evidence를 아직 확보하지 않음 | 추정으로 PASS 승격 |

### 00.6 PROSPECTIVE BLUEPRINT PRE-IMPLEMENTATION GATE

`PLAN -> REQUIRED_IMAGE_AND_MATERIAL_PREPARATION -> BLUEPRINT_REVIEW_PUBLICATION -> USER_FINAL_REVIEW_APPROVAL -> IMPLEMENTATION_START`

`NO_POST_ADOPTION_IMPLEMENTATION_PACKAGE_BEFORE_USER_FINAL_APPROVAL`: 이 profile 채택 뒤 새로 만드는 implementation package는 exact Blueprint revision의 명시적 `USER_FINAL_APPROVAL` 전에는 시작할 수 없다. 새 image deliverable의 생성·편집은 Base의 `IMAGE_MODEL_REQUIRED_FOR_IMAGE_CREATION_OR_EDITING`과 current-conversation approval gate를 따라야 한다. 정확성·검색성·편집성이 중요한 Mermaid/Flow/table은 `TEXT_NATIVE_EXACT_DIAGRAMS` 및 `STRUCTURED_INFORMATION_ARTIFACTS_REMAIN_TEXT_NATIVE`로 유지한다. 이미지 생성 성공만으로 사용자 승인·project asset 승인·runtime evidence가 되지 않는다.

`ISSUE267_EXISTING_APPROVED_PACKAGE_GRANDFATHERED_NON_RETROACTIVE`: Issue #267은 이 profile 채택 전에 exact Decision·implementation contract·scope에 대해 사용자가 이미 구현을 승인한 package이므로, 승인된 범위의 `IMPLEMENTATION_START`에 새 `USER_FINAL_APPROVAL`을 요구하지 않는다. 이것은 scope 확대나 successor package의 blanket approval가 아니다.

`LATER_PACKAGES_REQUIRE_BLUEPRINT_REVIEW_AND_USER_FINAL_APPROVAL`: Issue #267 evidence 이후의 첫 balance instrumentation package를 포함한 모든 새/successor package는 위 lifecycle과 새 명시적 user final approval을 거친다. `EXISTING_MERGED_RUNTIME_FACTS_NO_ROLLBACK`: 이 prospective gate는 이미 merge된 code/data/Scene/test와 기존 runtime evidence의 역사적 사실을 취소하거나 하향하지 않는다.

## 01. SOURCE REGISTRY

| source | identity / readback | 역할 | 상태 |
|---|---|---|---|
| Repository source snapshot | `origin/main@afa152b` | paired publication이 capture한 코드·데이터·Scene·test snapshot; latest commit 주장 아님 | CURRENT_PAIRED_SOURCE_SNAPSHOT |
| delivery lineage | `18d647c34ae8544d58d79e870f82dde1ef1d0c55` | complete 20260829 spec/PDF pair landing | CURRENT_DELIVERY_LINEAGE |
| `docs/design/PROJECT_AI_PRODUCTION_SPEC.md` | pair `ten-paces-hidden-moves-20260829-afa152b` | active project-wide machine-searchable narrative source | CURRENT |
| `exports/ten-paces-hidden-moves_HUMAN_GAME_BLUEPRINT_20260902.pdf` | 46 pages: cover + preserved 36-page baseline + 9-page visual/wireframe layer | current human-facing derived publication; no game rule or runtime evidence replacement | CURRENT_HUMAN_DERIVED_PUBLICATION |
| `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf` | same pair, 36 pages | exact preserved baseline source inside the current additive human publication | PRESERVED_BASELINE_SOURCE_36_PAGES |
| `exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260828.pdf` | earlier pair | historical derived publication only | HISTORICAL_DERIVED_NOT_CURRENT_SOURCE |
| GitHub PR #261 / #263 | merged, checks success | Phase 2 정본 reconciliation / every-task adversarial-research gate | HISTORICAL_AUTOMATED_EVIDENCE |
| GitHub PR #273 / Issue #267 | merged isolated implementation and post-merge readback | opponent runtime personality binding implemented; balance instrumentation remains separate | IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK / BALANCE_SIMULATION_NOT_RUN |
| GitHub PR #200, #199 | open draft | 미병합 후보, READ_ONLY | CURRENT_METADATA |
| `AGENTS.md` | repo root | 작업 경계·코어 불변식 | CURRENT |
| `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | 2026-08-30 approved balance-instrumentation written-spec review state | mutable context | CURRENT |
| `docs/planning-data/current_user_planning_status.json` | current structured mutable state | structured mutable state | CURRENT |
| `docs/decisions/2026-08-29_OPPONENT_RUNTIME_PERSONALITY_BINDING_DECISION.md` | five archetypes, public boundary, candidate binding acceptance criteria | historical approval Decision; implementation evidence lives in the execution report | IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK |
| `docs/decisions/2026-08-30_BALANCE_INSTRUMENTATION_CONTRACT_DECISION.md` | engine-direct deterministic single-duel measurement boundary | current successor Decision | USER_APPROVED_WRITTEN_SPEC_REVIEW_PENDING |
| `docs/operations/2026-08-29_POSTMERGE_CANON_AND_RUNTIME_REALITY_REVIEW.md` | catalog-vs-runtime gap; feasibility limits | current adversarial review | CURRENT_REVIEW |
| Notion / Google Sheet | repository-only migration inputs | no current authority | HISTORICAL_INPUT_ONLY |
| `docs/01_GAME_DESIGN.md` 등 분야별 owner | repository | game rules, content, architecture, test owners | CURRENT/PARTIAL (각 항목 참조) |
| `docs/decisions/*2026-08-28*` | repository | opening distance, retry, CTA, Phase 2 decisions | CURRENT |
| `docs/visual-assets/approved/...` | repository | approved source-set locator | CURRENT |
| historical chat / memory | discovery only | 이전 탐색 보조 | HISTORICAL_ONLY |

### 01.1 Notion migration gap

Notion은 이 문서의 입력으로만 읽었다. #261 병합 후의 GitHub 상태는 Notion Home/Flow의 10:18Z 읽기 시점보다 늦으므로, Phase 2를 “handoff issued / merge pending”으로 표기한 부분은 이 문서의 기준 SHA와 충돌했다. 그 고유 Flow/Visual/asset 상태는 이 문서 §03·§12와 repository owners로 흡수했다. 이어서 Active Context·current planning JSON·Documentation Map·entry router를 repository-only current state로 동기화하고 readback했다. `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`에 따라 Notion 신규 출력은 만들지 않았으며 앞으로 current authority로 사용하지 않는다.

### 01.2 CURRENT_SOURCE_RELEVANCE_CHECK — 2026-08-29

**APPLICABLE.** 이 GDD는 UI 입력·접근성 및 비교 게임의 설계 해석을 포함하므로, 최신 1차 자료를 다시 확인했다. [Godot GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html)은 명시적 focus 순서와 초기 focus가 필요하다는 플랫폼 제약을, [Android accessibility guidance](https://developer.android.com/guide/topics/ui/accessibility/views/apps-views)은 충분한 터치 영역과 고유한 조작 설명의 원칙을 뒷받침한다. [Into the Breach](https://subsetgames.com/itb.html), [YOMI Hustle](https://ivysly.itch.io/your-only-move-is-hustle), [Shogun Showdown](https://store.steampowered.com/app/2084000/Shogun_Showdown/), [Hellish Quart](https://www.hellishquart.com/)의 공식 페이지는 각각 읽을 수 있는 적 의도, 계획 후 관찰, 위치·타이밍, 결투 거리라는 **비교 출발점**만 제공한다. 이 자료는 우리 게임의 fun·밸런스·런타임 구현을 증명하지 않는다. 외부 source freshness는 terminology/constraint에만 쓰고, 제품 현재 truth는 위의 repository register가 소유한다.

## 02. CURRENT PROJECT STATE

### 02.1 프로젝트 한 문장

**십보강호는 공개된 거리·해결 이력만으로 상대의 다음 수를 가설화하고, 3개의 수(슬롯)에 1수 또는 2수 `[전조] → [실행]`을 비공개 배치한 뒤 실행·복기로 가설을 검증하는 1대1 무협 심리전이다.**

### 02.2 Current / historical / conflict 분류

| ID | 항목 | 분류 | 현재 판정 |
|---|---|---|---|
| DEC-CORE-001 | 10칸 직선 전장, 공개 시작 거리 2, 거리 중심 HUD | CURRENT | CONFIRMED / IMPLEMENTED |
| SYS-PLAN-001 | `3수 → 해결 → 3수 → 해결 → 4수 → 해결` | CURRENT | CONFIRMED / IMPLEMENTED |
| SYS-PLAN-002 | 3수 = 3슬롯, 2슬롯 행동은 `[전조] → [실행]`으로 2수를 소모 | CURRENT | CONFIRMED / IMPLEMENTED |
| UI-COMBAT-001 | CTA `N수 실행`; 실행 뒤 전투 표현으로 전환 | CURRENT | CONFIRMED / IMPLEMENTED |
| SYS-AI-001 | AI는 공개 상태·해결 이력만 사용, 미확정 계획/UI 의도를 읽지 않음 | CURRENT | CONFIRMED / IMPLEMENTED |
| UX-RETRY-001 | 첫 패배 후 실제 원인 복기·동일 seed 1회 무료 재도전 | CURRENT | CONFIRMED / IMPLEMENTED |
| CNT-MANUAL-001 | 덱·손패·드로우·장착 제한 없이 해금 기술을 슬롯에 배치 | CURRENT | CONFIRMED / IMPLEMENTED |
| AST-VIS-001 | WARM DUSK v2 | CURRENT | planning anchor only; runtime asset 승인 아님 |
| DEC-OPS-001 | repository-only canonical workspace | CURRENT | user confirmed; Notion is historical migration input only |
| DEC-STALE-001 | Phase 2 merge 전 Active Context/JSON/Notion 상태 | RESOLVED | repository owner sync·governance regression·readback 완료 |
| DEC-OPPONENT-001 | 15 candidate의 runtime personality binding | CURRENT_DECISION | IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK / BALANCE_SIMULATION_NOT_RUN |
| DEC-HIST-001 | `행동계획 잠금`, 4/7 슬롯 등 과거 표기 | SUPERSEDED | current CTA/3-3-4 계약으로 대체 |
| QA-HUMAN-001 | 사람 플레이·가독성·감정 evidence | UNKNOWN_UNVERIFIED | NOT_RUN |

### 02.3 현재 Work 5단계 위치

`UNKNOWN_UNVERIFIED`: 프로젝트에는 공통의 “Work 5단계” 정본 모델이 없고 `PLAN / BUILD / REVIEW` work mode만 확인된다. 이 문서 작업은 REVIEW이며, Phase 2 제품 코드는 main에 병합됐다. 새로운 단계 번호나 완료율을 발명하지 않는다.

## 03. CONFIRMED DECISIONS

| ID | 결정 | owner / evidence | 구현 영향 |
|---|---|---|---|
| DEC-CORE-001 | 1v1, 10 logical cells, start distance 2, distance-first player HUD | `AGENTS.md`, opening-distance decision | board preview, resolution, UI |
| DEC-PLAN-001 | 3/3/4 bundle rhythm; one turn is one slot | `AGENTS.md`, combat rules | plan controller / resolver |
| DEC-PLAN-002 | 2-slot action occupies telegraph then action | user-approved + Phase 2 contract | action span/timing / animation |
| DEC-CTA-001 | action planning is executed, not locked | `2026-08-28_ACTION_PLAN_EXECUTION_CTA_DECISION.md` | button text, plan→presentation transition |
| DEC-AI-001 | public state only AI | `AGENTS.md`, Phase 2 observation test | planner snapshot / observation boundary |
| DEC-RETRY-001 | first loss: Review→same-seed retry once; retry win commits once; second loss ends run | retry decision, `vertical_slice_run_state.gd` | result state / persistence boundary |
| DEC-VIS-001 | WARM DUSK v2 planning visual direction | visual decision + Visual Bible | future visual briefs, not runtime proof |
| DEC-PLATFORM-001 | Windows/Android dual target, one core with adapters | AGENTS platform decision | input/layout/test matrix |
| DEC-OPS-001 | repository-only human-facing and structured canon | `2026-08-28_REPOSITORY-ONLY-CANONICAL-WORKSPACE_DECISION.md` | no future Notion write/readback |
| DEC-OPPONENT-001 | candidate별 archetype·기본 행동 선호·결정적 stat allocation을 runtime에 bind하되, AI의 public-only 관찰 경계를 보존 | `TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01` | Issue #267 격리 구현은 PR #273으로 병합·readback됨; successor 계측은 `TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01` |

## 04. DESIGN PILLARS

1. **공개 단서에서 가설을 세운다.** 결과·거리·자원·해결 이력을 보고 다음 수를 추론한다.
2. **슬롯의 희소성이 고민을 만든다.** 강한 2수 행동은 첫 수의 유연성을 포기하게 한다.
3. **실행은 판결, 복기는 학습이다.** 입력을 되돌려 계산하지 않고, 애니메이션과 인과 기록으로 왜 이겼거나 졌는지 읽는다.
4. **무협의 거리는 감각으로 읽힌다.** 절대 칸보다 “거리 N”, 합·방어·회피·중단·강건이라는 대련 언어를 쓴다.
5. **성장은 정답을 대체하지 않는다.** 해금은 파훼 선택지를 넓히지만 독해와 계획을 대신하지 않는다.

## 05. PLAYER EXPERIENCE CONTRACT

### SYS-EXPERIENCE-001 — Player Promise

| 항목 | 계약 |
|---|---|
| player action | 공개 정보로 상대 수를 예측하고 내 행동을 3개의 수에 배치한다. |
| meaningful choice | 지금의 확실한 방어/이동/관찰과, 전조를 감수한 2수 고위력·거리 제어 중 고른다. |
| observable outcome | 해결 순서·거리 변화·합·방어·회피·중단·자원·피해와 Review의 인과 기록. |
| reward / failure learning | 유효한 가설은 다음 bundle의 정보 우위와 승리로, 틀린 가설은 실제 원인 1~3개와 동일 조건 재시도로 이어진다. |
| target emotion | “읽었다/읽혔다”는 긴장, 실행 순간의 판결감, 복기 후의 납득. |
| next-action drive | 공개 이력에서 새 가설을 만들고 상대의 반복을 끊는다. |
| sales hook | 턴제 전술의 가독성과 비공개 동시 계획의 심리전을 무협 1대1 거리전으로 결합. |

### 05.1 첫 5·15·30분 계약

| 시간 | 목표 경험 | evidence 상태 |
|---|---|---|
| 첫 5분 | 거리 2에서 슬롯 배치→`N수 실행`→해결의 기본 리듬을 1회 이해 | IMPLEMENTED path / UX_NOT_RUN |
| 첫 15분 | 합·중단 또는 방어·강건의 실패 원인을 Review로 읽고 같은 seed를 한 번 다시 푼다 | DOCUMENTED + PARTIAL_IMPLEMENTED / UX_NOT_RUN |
| 첫 30분 | 5대련의 대응·거리·반복 파훼를 보고, 성장이 답이 아니라 선택지 확장임을 이해 | DOCUMENTED vertical-slice goal / NOT_RUN |

## 06. CORE / SESSION / META LOOP

```text
공개 거리·해결 이력 관찰
  → 가설과 3수 계획
  → N수 실행 (편집 종료)
  → 동시 해결·전투 표현
  → 결과/복기: 실제 원인·거리·자원 변화
  → 다음 bundle 또는 결과
  → route 정보/성장 선택 → 다음 대련
```

| loop | ID | 규칙 | 상태 |
|---|---|---|---|
| Core | SYS-PLAN-001 | bundle당 3/3/4 슬롯, 1/2 슬롯 행동, 해결 순서 | IMPLEMENTED |
| Session | UX-RUN-001 | Main→Setup→Intro→Briefing→Combat/Review→Result→Route→Completion | DOCUMENTED / PARTIAL_IMPLEMENTED |
| Meta | SYS-GROWTH-001 | 무공 성장·해금으로 대응 선택지 확대, 판단을 대체하지 않음 | DOCUMENTED / balance NOT_RUN |

## 07. SYSTEM REGISTRY

| ID | 시스템 | player value | owner / implementation | status |
|---|---|---|---|---|
| SYS-BOARD-001 | 거리 전장 | 도달·이탈·사거리 판단 | `combat_board_preview*.gd`, `combat_resolution_engine.gd` | IMPLEMENTED |
| SYS-PLAN-001 | 행동 계획 | 3수 제한 안의 예측·배치 | `action_placement_controller.gd` | IMPLEMENTED |
| SYS-RESOLVE-001 | 동시 해결 | 내 예측의 판결과 관찰 가능한 인과 | `combat_resolution_engine.gd` | IMPLEMENTED |
| SYS-AI-001 | 공개 상태 AI | 공정하게 읽히는 상대 적응 | `combat_ai_planner.gd` | IMPLEMENTED |
| SYS-OPPONENT-001 | 상대 runtime personality binding | 상대의 공개 경향을 관찰하고 파훼하는 기대 | Decision + PR #273 execution/readback | IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK / BALANCE_SIMULATION_NOT_RUN |
| SYS-REVIEW-001 | 복기 | 실패가 다음 행동으로 이어짐 | `combat_review_panel.gd` | IMPLEMENTED |
| SYS-RETRY-001 | 동일 seed 재도전 | 학습을 반복 기회로 전환 | `vertical_slice_run_state.gd` | IMPLEMENTED |
| SYS-TAG-001 | 행동 태그와 인과 | 전조·관찰·강건·합을 같은 언어로 읽음 | `02_COMBAT_RULES.md`, action data, resolver events | CONFIRMED / IMPLEMENTED |
| SYS-GROWTH-001 | 무공 성장 | 파훼 폭을 확장 | `06_STARTING_FACTION_MASTERY_DATA.md` | DOCUMENTED / NOT_BALANCE_VALIDATED |
| SYS-ROUTE-001 | route 선택 | 정보/회복/성장 사이의 장기 선택 | `vertical_slice_route*.gd` | PARTIAL |
| SYS-MARTIAL-001 | 무공·절초 계층 | 기술 선택의 정체성과 결정적 순간의 보상 | martial-manual data, CardView, ultimate VFX | PARTIAL / UX_NOT_RUN |

### 07.1 REUSABLE FLOW AND SYSTEM CARD SCHEMA

`REUSABLE_FLOW_AND_SYSTEM_CARDS`

중요 flow/system은 새 규칙을 복제하지 않고 위 registry ID와 아래 공통 card field로 §08 상세, §09–§13 consumer, §14–§21 implementation/evidence를 연결한다.

| card field | owner / use |
|---|---|
| ID + player purpose | §05 promise와 §07 registry의 공통 ID·player value |
| trigger/input + choice/condition | §08의 WHY/HOW 및 entry/input/guard |
| state/data change | §15 data contract, §18–§20 flow/state/save boundaries |
| output/feedback + failure/recovery | §08 system outcome, §11 UI, Review/retry |
| content/UX/presentation consumers | §09–§13 registries and matrices |
| implementation owner | §14–§17 exact Scene/script/data responsibility |
| acceptance/evidence | §21 traceability, §22 QA, §24 risk/evidence ceiling |

현재 material cards는 `SYS-PLAN-001`, `SYS-RESOLVE-001`, `SYS-AI-001`, `SYS-OPPONENT-001`, `SYS-REVIEW-001`, `SYS-RETRY-001`, `SYS-ROUTE-001`, `SYS-GROWTH-001`이다. Untouched system을 mass-backfill하지 않고 각 기존 상세 section을 card body로 재사용한다.

## 08. SYSTEM SPECIFICATIONS

### SYS-PLAN-001 — 행동 계획

**WHY.** 계획을 숨기는 이유는 상대가 내 UI·미확정 계획을 읽는 즉시 심리전이 사라지기 때문이다. 3수의 제한은 “무엇을 할까”를 “어떤 타이밍을 포기할까”로 바꾼다.

**HOW.** 사용자는 해금된 기술에서 행동을 선택하고 현재 bundle의 빈 슬롯에 배치한다. 1수 행동은 한 슬롯, 2수 행동은 `[전조]`와 `[실행]`의 연속 두 슬롯을 차지한다. 이동만 접근/후퇴 의도를 고르고, 공격·반격·절초는 공개된 상대를 자동 대상으로 한다. 배치가 끝난 뒤 `N수 실행`을 누르면 편집이 중단되고 Combat Presentation으로 전환한다. 취소/재배치는 실행 전만 가능하다.

| 상태 | entry | player input | output / guard |
|---|---|---|---|
| Planning | bundle 시작 | 선택·배치·제거 | 슬롯 유효성 표시 |
| Ready | 유효 계획 | `N수 실행` | UI editing disabled |
| Presentation | 실행 요청 수락 | 관찰 중심 | resolver 이벤트에 맞춘 표현 |
| Resolved | bundle 종료 | 복기/다음 수 | public history 갱신 |

**WHAT.** 기본 action data는 이동·보법·막기·회피·속공·강공·관찰·명상·준비·장풍이다. 강공·장풍은 2수이며 전조가 공개적으로 해석 가능한 risk가 된다. 덱·손패·드로우·장착 제한은 사용하지 않는다.

**IMPLEMENT.**

| 레이어 | path / 역할 |
|---|---|
| UI control | `src/ui/action_selection/action_placement_controller.gd` — placement, locked guard |
| UI shell | `src/ui/action_selection/action_selection_dock.gd` — selection dock |
| CTA | `src/ui/combat_progress_button.gd` — execute request / disabled state |
| scene | `scenes/combat/combat_board_preview.tscn`, `scenes/run/vertical_slice_combat_bridge.tscn` |
| data | `data/cards/basic_cards.json`, `data/cards/ultimate_cards.json`, `data/combat/mastery_ultimate_poc.json`, `data/cards/martial_manuals/*.json` (registry/loadout), `data/combat/combat_board_poc.json` (semantic intent fixture) |

**PSEUDOCODE.** `if plan.valid and execute_pressed: lock_inputs(); resolve_bundle(); play_resolution_events(); expose_public_history()`.

**COMPLETE WHEN.** 3/3/4 슬롯, 2수 span, 실행 후 편집 불가, resolver로의 단일 execute 흐름, plan leak 없음, Phase 2 tests pass. Human이 2수 전조 비용을 이해하는지는 `QA-HUMAN-001`으로 남는다.

### SYS-PLAN-002 — 행동묶음과 2슬롯 비용

**PLAYER QUESTION.** `이번 묶음의 세 칸을 지금 안전하게 쓸 것인가, 두 칸을 미리 내어 강한 한 수를 끝까지 살릴 것인가?`

한 라운드는 `3수 → 해결 → 3수 → 해결 → 4수 → 해결`이다. 여기서 **3수는 행동을 세 번 누른다는 뜻이 아니라, 계획판의 슬롯이 정확히 3개라는 뜻**이다. 각 묶음에서는 1슬롯 행동 셋, 또는 1슬롯 행동 하나와 2슬롯 행동 하나처럼 합계가 슬롯 수를 넘지 않는 조합만 계획할 수 있다. 덱·손패·드로우·장착 제한은 이 희소성을 만드는 장치가 아니다.

```text
공개 거리·자원·해결 이력 확인
  → 현재 묶음의 3칸(마지막 묶음은 4칸)에 행동 배치
  → N수 실행
  → 양측의 잠긴 계획을 동시 해결·표현
  → 공개 이력과 자원 갱신
```

| 배치 | 슬롯 표기 | 플레이어가 감수하는 것 | 판정 경계 |
|---|---|---|---|
| 1슬롯 행동 | 해당 수에 행동명 | 다음 수의 유연성은 남긴다 | 행동 종류별 거리·자원·대응 규칙 |
| 2슬롯 행동 | 첫 수 `[전조]` → 둘째 수 `[실행]` | 전조부터 실행까지 두 슬롯을 점유한다 | 첫 전조에 비용 전액 선지불, 확정 뒤 환불 없음 |
| 전조 중 피격 | 연결 슬롯은 같은 `action_instance_id` | 강한 수를 준비한 만큼 중단 위험이 생긴다 | 실제 체력 피해가 나면 `[강건]`이 없을 때 남은 전조·실행을 취소 |
| 실행 요청 | `N수 실행` | 되돌릴 수 있는 계획 단계를 끝낸다 | 입력은 비활성화되고 resolver event로 전환 |

`[전조]`는 별도의 강화 보너스가 아니라 **실행 전 점유와 읽을 수 있는 위험**을 뜻한다. 따라서 2슬롯 강공·장풍의 전조를 본 상대는 대응·이동·관찰을 고민할 여지를 얻지만, 상대 AI는 플레이어가 아직 실행하지 않은 슬롯·방향·대상을 볼 수 없다.

### SYS-RESOLVE-001 — 동시 해결과 인과

**WHY.** 플레이어가 “게임이 나를 속였다”가 아니라 “내 가설이 이 조건에서 틀렸다”고 읽어야 다음 수를 바꾼다.

**HOW.** 한 bundle의 양측 action을 같은 공개 state에서 확정해 순차 `[합]`과 거리·방어·회피·중단·강건·자원 규칙으로 해결한다. 2수 action은 anchor+span-1 타이밍에 실행한다. 결과 이벤트는 board presentation과 Review가 소비한다.

| event | producer | consumers | player-visible meaning |
|---|---|---|---|
| action start / telegraph | resolution engine | board/animation | 상대의 실행 전조/내 계획의 소모 |
| range / distance change | engine | board/HUD/review | 닿음·이탈·사거리 변화 |
| clash / block / evade / interrupt | engine | board/VFX/review | 성공·실패 원인 |
| result | engine | run state / result model | 승패·보상·재시도 가능성 |

**COMPLETE WHEN.** 같은 입력은 동일한 result event sequence, 실패 원인이 Review로 전달, UI가 규칙을 재계산하지 않음, `verify_phase2_combat_resolution.gd` pass. animation timing·사람의 납득은 별도 evidence다.

### SYS-TAG-001 — 전투 태그를 읽는 법

태그는 장식용 키워드가 아니라, **계획할 때 보이는 위험과 해결 뒤 복기가 설명해야 하는 원인**이다. 아래 표는 규칙 원본을 요약한 안내이며, 수치·예외·데이터 스키마는 `docs/02_COMBAT_RULES.md`와 action JSON이 소유한다.

| 태그/용어 | 계획에서 보이는 의미 | 해결·복기에서 확인할 결과 | 오해하면 안 되는 경계 |
|---|---|---|---|
| `[전조] → [실행]` | 한 행동이 연속 슬롯 둘을 차지한다 | 전조 뒤 실제 행동이 실행되거나 중단된다 | 전조만으로 강화·피해가 발생하지 않는다 |
| `[관찰]` | 1슬롯을 당장의 피해 대신 정보에 쓴다 | 적이 먼저 묶음을 잠근 뒤, 앞 수부터 행동 **유형**을 관찰량만큼 공개한다 | 기술명·무공서·비용·방향·거리·피해·AI 가중치·정답은 공개하지 않는다 |
| `[준비]` | 다음 비이동 행동을 위해 지금 한 슬롯을 쓴다 | 다음 공격은 원공격력 +2와 `[강건]`, 다음 명상은 기력·내력·절초기세 +1을 얻는다 | `[준비]`는 행동이고 `[강화]`는 그 결과 상태다. 이동·보법은 준비를 소비하지 않는다 |
| `[강건]` | 중단될 수 있는 큰 수를 한 번 버티게 할 수 있다 | 유효 중단 1회를 막아 연결 행동/다음 피해 단위를 유지할 수 있다 | 받은 피해·상태·KO를 되돌리거나 무적이 되지는 않는다 |
| `[합]` | 같은 수에 양쪽 공격이 겹칠 가능성을 읽는다 | 현재 피해 단위끼리 비교하고, 높은 쪽은 차이만큼 원피해를 남긴다 | 사거리 밖이어도 비교와 합 승리는 일어날 수 있으나 체력 피해·적중은 별도 조건이다 |
| `[연격 N]` | 한 공격이 여러 피해 단위로 이어질 수 있다 | 체력 피해 없이 공격이 유지되면 다음 단위도 다시 `[합]`; 한쪽이 중단되면 남은 단위는 취소/단독 타격으로 갈린다 | 연격은 최종 총피해를 N개 단위로 나누는 판정 언어이지 별도 행동 묶음이 아니다 |
| `[중단]` | 전조와 후속타가 끊길 위험이다 | 실제 체력 피해 뒤 현재 `action_instance_id`의 미실행 슬롯·피해 단위가 취소된다 | 방어로 피해가 0이면 중단이 아니다. `[강건]`은 한 번만 막는다 |
| `[필중]` | 회피에 의존한 대응을 흔드는 조건이다 | 유효한 공격은 회피를 무시한다 | `[합]`·방어·거리·방향·중단·KO까지 무시하지 않는다 |

**관찰 예시.** 적의 2슬롯 공격과 이동이 잠겨 있고 관찰량이 2라면, 플레이어는 `[전조] / [공격] / ?`처럼 행동 종류만 본다. 이 정보는 다음 계획의 가설 재료이지, 상대의 기술명이나 정답 대응표가 아니다.

**합 예시.** 두 연격의 첫 피해 단위가 부딪쳐 한쪽이 방어로 체력 피해를 0으로 막으면, 살아남은 양쪽의 다음 피해 단위가 다시 `[합]`한다. 반대로 실제 체력 피해가 나서 중단되면, 중단된 쪽의 남은 연격과 전조 후속 실행은 사라지고 유지된 쪽의 잔여타만 순서대로 해결될 수 있다. 이 인과는 전투 표현과 Review가 같은 사건 기록으로 보여 주어야 한다.

### SYS-AI-001 — 공개 상태 AI

**WHY.** 상대가 항상 내 답을 알고 있다고 느끼면 계획은 무의미해진다.

**INPUT BOUNDARY.** player/enemy positions, 공개 자원, resolved history. **EXCLUDED:** player pending plan, hidden technique placement, UI intent signal.

| path | responsibility |
|---|---|
| `src/combat/combat_ai_planner.gd` | public snapshot에서 enemy bundle 선택 |
| `data/combat/combat_resolution_preview.json` | `enemy_plan_source: public_state_ai` fixture |
| `tests/verify_phase2_observation.gd` | plan/UI leakage regression |

**COMPLETE WHEN.** planner snapshot에서 제외 필드가 없고, enemy plan은 bundle resolve 전에 lock되며, 관찰은 action type의 해결 뒤 노출된다.

### SYS-OPPONENT-001 — 상대 runtime personality binding

**PLAYER QUESTION.** `Briefing과 해결 이력에서 본 이 상대의 습관을 다음 3슬롯 가설에 어떻게 반영할까?`

**CURRENT FACT.** `data/run/vertical_slice_opponents.json`의 15 후보는 하나의 `runtime_archetype_id`, ordered `basic_action_focus_ids`, `final_stat_total_seed`를 가진다. Issue #267 구현은 이를 per-combat runtime binding으로 검증해 `VerticalSliceMetricsCombatResolutionEngine`의 candidate stats와 독립 planner instance에 연결했다. `CombatAiPlanner`는 공개 상태와 해결 완료 public history만 사용하며, 후보별 weight/total의 **실제 난이도·승률**은 아직 측정하지 않았다. 따라서 후보 개성 binding은 구현됐지만, 밸런스 PASS는 아니다.

| consumer classification | exact fields | current evidence |
|---|---|---|
| CURRENT_RUNTIME_CONSUMED_FIELDS | `signature_manual_id`, `signature_star_seed`, `runtime_archetype_id`, `basic_action_focus_ids`, `final_stat_total_seed` | current loadout/route/result plus Issue #267 per-combat binding, derived stats, and planner consumer |
| MEASURED_BY_VALIDATION_ONLY_INSTRUMENTATION_NOT_NUMERICALLY_DECIDED | profile weights, derived stat total, player/loadout/policy/seed outcome distribution | schema 2 4,500-row coverage is merged historical machine evidence. Successor `TEN-DEC-20260830-BALANCE-MEASUREMENT-REPRESENTATIVE-POLICY-COVERAGE-01` is merged in PR #292 with remote CI PASS and schema 3 six-archetype 6,750-row byte-identical machine evidence; PR #293 archived the one-time approval and has exact-main readback, and it is not a numerical balance decision. |

| state | owned by | player-visible meaning | evidence boundary |
|---|---|---|---|
| candidate catalog | `data/run/vertical_slice_opponents.json` | 상대 소개와 학습용 가설 재료 | DOCUMENTED / catalog consumer only |
| binding decision | `TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01` | 같은 이름만 다른 상대가 되지 않게 하는 승인된 방향 | IMPLEMENTED_MERGED_MAIN_PR273_POSTMERGE_READBACK |
| runtime bridge | Issue #267 isolated implementation | 한 candidate → 한 archetype, 결정적 stat 합계 | AUTOMATED_GODOT_AND_REMOTE_CI_VERIFIED |
| actual combat behavior | `CombatAiPlanner` / combatant stats | 전투에서 확인되는 선택 경향과 수치 | MACHINE_RUNTIME_VERIFIED_FOR_BINDING; BALANCE_SIMULATION_NOT_RUN |

**CURRENT BINDING / AUTHORIZED SUCCESSOR MEASUREMENT.** 각 candidate는 하나의 runtime archetype에 bind되고, 행동 선호는 공개 상태와 해결 이력만으로 계산한다. stat allocation은 `final_stat_total_seed` 합계를 보존하는 결정적 결과다. Brief/Review는 관찰 가능한 경향만 표현하고, 플레이어의 아직 확정되지 않은 계획·숨은 기술 배치·UI 의도·AI 가중치·정답 수순을 누설하지 않는다. 후속 `TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01`은 이 구현을 실제 engine-direct single-duel matrix로 측정하지만, 수치 변경과 Human balance PASS를 자동 승인하지 않는다.

**failure / recovery example.** 후보 이름과 카드가 달라도 모두 같은 global profile로 행동하면 “가짜 개성” 실패다. Issue #267은 bridge snapshot의 archetype/stat 합계와 controlled planner score regression의 focus 효과를 automated/Godot으로 증명했다. 후속 계측은 그 구현을 실제 candidate/loadout/policy/seed 행렬에서 재현하고, Human playtest는 여전히 별도로 난이도·재미를 평가한다.

### SYS-REVIEW-001 / SYS-RETRY-001 — 복기와 동일 조건 재도전

**WHY.** 첫 패배를 루프 종료가 아닌 반증된 가설의 학습으로 만든다.

| 흐름 | 규칙 |
|---|---|
| first loss | Review에 실제 원인 1~3개, 거리 전/후, 가설/실제 결과 노출 |
| retry | retry count 0→1, 동일 snapshot/seed 복구, 무료 1회 |
| retry win | progression 단 한 번 commit |
| second loss | Main으로 종료, 보상/route 없음 |

`src/run/vertical_slice_run_state.gd`가 run 상태와 commit boundary를, `src/ui/combat_review_panel.gd`가 인과 설명을 소유한다. 완료 자동 증거: `tests/verify_vertical_slice_failure_retry.gd`.

### SYS-ROUTE-001 — 강호행: 비무 사이의 두 노드

**PLAYER PROMISE.** 강호행은 전투를 하나 더 붙이는 맵이 아니라, `방금 무엇을 배웠고 다음 상대에게 무엇을 알고 들어갈 것인가`를 고르는 **비전투 선택 구간**이다. 첫 Vertical Slice에서 방문 수는 고정이다.

```text
Duel 1 → 성장/회복 노드 → 정보/준비 노드 → Duel 2
       → 성장/회복 노드 → 정보/준비 노드 → Duel 3
       → 성장/회복 노드 → 정보/준비 노드 → Duel 4
       → 성장/회복 노드 → 정보/준비 노드 → Duel 5
```

주요 비무 1~4 사이에는 **정확히 두 노드**, 전체에는 성장/회복 4개와 정보/준비 4개, 총 8개의 비전투 노드가 있다. 화면이 일직선 지도일 필요는 없지만, 일반 전투·랜덤 전투·덱 보상·탐험 서브시스템으로 확장하지 않는다.

| 순서 | 노드가 던지는 질문 | 선택의 이득과 포기 | 다음 화면에 남기는 것 |
|---|---|---|---|
| 1. 성장/회복 | `지난 비무에서 드러난 문제를 지금 안정시킬까, 이후 대응 폭을 키울까?` | 회복은 당장 생존을, 집중 수련은 특정 무공의 성장, 자유 수련은 후속 선택 폭을 준다. 한 선택으로 모두 최대화하지 않는다 | 체력·자원 또는 무공 성장 상태 |
| 2. 정보/준비 | `다음 상대에 대해 어떤 가설 재료를 확보할까?` | 공개 스테이터스·방어/전조 경향·사거리/무공 계통 중 한 축을 깊게 본다. 다른 축은 포기한다 | Briefing에 추가되는 공개 단서 |
| Briefing | `내가 아는 것과 모르는 것은 어디까지인가?` | 상대 이름/전투 인상/공개 상태/조사된 기술 범위를 확인한다 | Combat으로 넘길 공개 정보 경계 |

다음 상대 후보는 Duel Result 뒤 run seed로 먼저 확정되고, Route의 정보 선택이 후보를 다시 뽑지 않는다. 정보 노드는 AI의 현재 계획·확률·가중치·정답 수순을 제공하지 않는다. 따라서 강호행의 보상은 숨은 보정이나 정답이 아니라, **다음 3슬롯 계획을 더 좋은 가설로 시작할 근거**다.

**STATUS.** 5대련과 8노드의 질문·텍스트·가역 수치 seed는 `DOCUMENTED`; `vertical_slice_route*.gd`의 소비처는 `PARTIAL`; Windows 사람 플레이에서 이 선택이 명료하고 재미있는지는 `UX_NOT_RUN`이다.

### SYS-GROWTH-001 / SYS-MARTIAL-001 — 무공 성장·절초·시각 계층

**WHY.** 무공은 “더 높은 숫자”가 아니라 거리·순서·대응의 새 조합을 여는 언어여야 한다. 절초는 그 조합을 무시하는 만능 버튼이 아니라, 전투에서 축적한 기세를 결정적 순간에 쓰는 선택이다.

| 계층 | 플레이어가 읽는 역할 | 현재 정본의 규칙 | 시각 언어와 evidence 경계 |
|---|---|---|---|
| 기초 행동 | 누구나 쓰는 거리·대응·자원 문법 | 10종 행동으로 이동·보법·막기·회피·속공·강공·관찰·명상·준비·장풍을 제공한다 | 실제 카드 아틀라스와 `CardView.illustration` 소비처가 있다. 작은 삽화·출처 배지·태그·비용은 읽기 우선이며, 긴 텍스트를 원화에 굽지 않는다 |
| 무공서 기술 | 어떤 방식으로 거리를 만들고, 공격/대응을 연결하는지의 정체성 | 초기 10권, 성취 3→10과 기술 해금이 대응 폭을 넓힌다. 덱·손패·드로우·장착 제한은 없다 | 무공서명·기술·태그·비용·사거리는 UI/data binding이 소유한다. 개별 무공 삽화는 exact card ID와 실제 `CardView.illustration` 소비처가 확정될 때까지 자동 제작하지 않는다 |
| 절초 | 축적한 기세를 비용과 함께 결단하는 정점 | 절초기세 0~5; 묶음 전환, 실제 회피, 준비된 명상, 합 승리로 얻으며 기본 절초와 10성 절초는 각 슬롯·자원·기세·해금 조건을 지킨다 | 제한된 고색은 절초·선택 확정·결정적 결과에만 쓴다. `ultimate_ink_gold_sprite_sheet_rgba`는 tracked consumer가 있으나 Human 가독성·최종 VFX 품질은 `NOT_RUN` |

무공의 시각적 구분은 같은 게임 안에서 세 출처가 다르게 읽히게 하는 것이지, 새 전장 배경·캐릭터·카드 배치를 자동 생산하는 권한이 아니다. 현재 전체 문법은 **WARM DUSK: 저채도 종이·먹선·절제된 고색·비격자 논리 전장**이다. 이 문법은 거리 N, 슬롯 점유, 전조, 합, 중단의 인과를 먼저 보이게 해야 하며, 숨은 계획을 포즈·색·연출로 누설해서는 안 된다.

| data / owner | status | validation |
|---|---|---|
| `docs/06_STARTING_FACTION_MASTERY_DATA.md` | DOCUMENTED | tuning table / fixture 필요 |
| `data/cards/martial_manual_cards.json`, `data/cards/martial_manuals/*.json` | IMPLEMENTED adoption data | UI/AI adoption test |
| `src/run/vertical_slice_route*.gd` | PARTIAL runtime consumer | visible Godot / human choice test |
| `src/ui/card_view.gd`, `data/cards/basic_cards.json` | IMPLEMENTED basic-card illustration consumer | gameplay-size readability / Human test |
| `src/combat/combat_board_preview.gd`, ultimate VFX sprite sheet | PARTIAL visual consumer | Windows visible / Human VFX clarity |

## 09. CONTENT REGISTRY

| ID | 콘텐츠 | 역할 | status |
|---|---|---|---|
| CNT-DUEL-001 | 1대련: 합/중단 | 첫 판결과 실패 원인 학습 | DOCUMENTED / PARTIAL runtime |
| CNT-DUEL-002 | 2대련: 방어/강건/전조 | 강한 수의 비용 읽기 | DOCUMENTED |
| CNT-DUEL-003 | 3대련: 거리/이동 | 사거리 가설 | DOCUMENTED |
| CNT-DUEL-004 | 4대련: 공개 이력 적응 | 반복 패턴 파훼 | DOCUMENTED |
| CNT-DUEL-005 | 5대련: 순차 해결·합·중단 | 통합 시험 | DOCUMENTED |
| CNT-ACTION-001 | 기본 10행동 | 슬롯·거리·자원 문법 | IMPLEMENTED |
| CNT-MANUAL-001 | 초기 10권 무공 | 대응 폭 성장 | IMPLEMENTED data / UX_NOT_RUN |
| CNT-OPPONENT-001 | vertical slice opponents | 5대련의 소개·학습 후보 catalog | DOCUMENTED / PARTIAL consumer |
| CNT-OPPONENT-RUNTIME-001 | candidate runtime personality | 후보 개성을 실제 공개 경향으로 만들기 | USER_APPROVED / NOT_IMPLEMENTED |

### CNT-ACTION-001 — 기본 행동 계약

| action | slots | 핵심 의도 | important rule |
|---|---:|---|---|
| 이동 / 보법 | 1 | 거리 조절 | 인접·사거리 판단을 바꿈 |
| 막기 / 회피 | 1 | 즉시 생존 | 방어/회피의 읽기 가능 결과 |
| 속공 | 1 | 짧은 기회 포착 | `floor(3 + external*0.5)` |
| 강공 | 2 | 전조를 감수한 타격 | `floor(7 + external*1)` |
| 관찰 | 1 | 정보 우위 | player only, 관찰점 1 |
| 명상 | 1 | resource 전환 | stamina+1, internal+1 |
| 준비 | 1 | 후속 비이동 행동 준비 | 다음 공격은 +2 피해와 `[강건]`, 다음 명상은 자원·절초기세를 강화 |
| 장풍 | 2 | 거리 있는 내력 공격 | internal 1, range 1–3, `floor(3 + internal*0.75)` |

## 10. CONTENT SPECIFICATIONS

### CNT-DUEL-001…005 — 5대련 학습 아크

| duel | learning goal | player counter | failure/recovery | implementation status |
|---|---|---|---|---|
| 1 | 합·중단의 첫 인과 | 움직임/방어/타이밍을 바꿈 | Review→1 retry | PARTIAL |
| 2 | 방어·강건과 2수 전조 | 전조에 맞춰 거리·대응 선택 | Review→1 retry | DOCUMENTED |
| 3 | 거리와 사거리 | 이동 후 공격, 닿지 않으면 계획 수정 | Review→1 retry | DOCUMENTED |
| 4 | 공개 이력의 반복 | 해결 이력에서 반복만 파훼 | AI no-leak boundary | DOCUMENTED |
| 5 | 순차·합·중단 통합 | 3수 전체 가설 조합 | Review→1 retry | DOCUMENTED |

**콘텐츠 생산 template.** 각 대련은 `learning_goal, public_state, opponent_archetype, initial_distance, allowed_actions, reward, review_causes, retry_seed`를 명시하고 공통 resolver/Review/route consumer를 재사용한다. 개별 독립 판정 순서는 만들지 않는다.

## 11. UI/UX AND INPUT CONTRACT

| ID | screen / UI | user goal | required information | input / feedback | status |
|---|---|---|---|---|---|
| UI-MAIN-001 | Main / Setup | run 시작 | start, settings | mouse/touch/focus | PARTIAL |
| UI-BRIEF-001 | Briefing | 이번 대련의 공개 조건 이해 | 거리, 상대, 학습 목표 | continue | DOCUMENTED |
| UI-PLAN-001 | Action Selection Dock | 3수에 계획 배치 | distance N, slot occupancy, action cost, resources | select/place/remove; validation | IMPLEMENTED |
| UI-COMBAT-001 | Combat Board | 해결을 읽기 | 공개 거리, action resolution, result | `N수 실행` 이후 관찰 중심 | IMPLEMENTED |
| UI-REVIEW-001 | Review | 실패 원인으로 다음 가설 세움 | hypothesis/actual/cause/distance before-after | retry/return | IMPLEMENTED |
| UI-RESULT-001 | Result/Route | 보상과 다음 선택 | win/loss, reward, route info | choose/continue | PARTIAL |

### UI-COMBAT-001 state contract

`visible`: 공개 거리, 양측 battler, bundle progress, 실행 피드백.

`planning`: action dock editable.

`ready`: valid plan + CTA active.

`pressed/executing`: CTA disables, plan changes cannot mutate resolver input.
`warning/error`: invalid span, out-of-range/insufficient resource are pre-execution feedback; post-execution failure is Review explanation, not silent rejection.

**Accessibility / input.** `pc_standard / pc_wide_or_ultrawide / mobile_landscape`에서 같은 정보 위계와 의미를 유지한다. focus navigation, touch target, contrast, localization expansion은 design requirement이나 Android/assistive runtime evidence는 NOT_RUN이다.

## 12. VISUAL ASSET CONSUMER MATRIX

| ID | asset / locator | consumer | approval / rights | runtime state |
|---|---|---|---|---|
| AST-CHAR-001 | `assets/characters/dogyeom_combat_battler_01_v1.png` | combat battler | user source-set record | actual routed consumer |
| AST-CHAR-002 | `assets/portraits/dogyeom_status_portrait_01_v1.png` | status portrait | user source-set record | actual routed consumer |
| AST-UI-001 | card atlas SVG / manifest | action cards | tracked asset manifest | runtime consumer |
| AST-VFX-001 | ultimate VFX RGBA asset | combat feedback | tracked source/provenance record | consumer must remain verified per scene |
| AST-VIS-001 | WARM DUSK v2 / Core Scene Board R2 | planning reference | PLANNING_ONLY | not runtime asset / not rights proof |

**Visual grammar.** Warm dusk, charcoal ink, paper, restrained antique gold; non-grid logical board; semi-real 2D ink outlines, low-saturation wash, restrained dot/dither. Keep: clear distance/causality hierarchy. Avoid: baked UI text, hard floor grid, plan leakage, deck/hand visual language. Do not drift: unrelated project style or asset identity. Exact planning palette: `INK_900 #171411`, `PAPER100 #EADFC9`, `SEPIA500 #7F6847`, `GOLD500 #B99254`, `DANGER500 #965148`, `BLUEGRAY500 #687783`.

### 12.1 무공·절초 시각 의미 계약

| 화면 요소 | 반드시 전달할 의미 | 허용된 표현 | 금지/미검증 경계 |
|---|---|---|---|
| 기초 행동 카드 | 출처·행동 유형·슬롯·비용·태그 | 작은 수묵 삽화, 기초 배지, UI가 소유한 텍스트/숫자 | 삽화 속 pseudo-text, 카드가 규칙을 재계산하는 표현 |
| 무공서 기술 카드 | 어느 무공서의 어떤 기술이 어떤 대응 폭을 여는가 | 무공서 identity, 기술명, 태그, 사거리·비용의 data-bound UI | 소비처 없는 개별 기술 원화의 자동 생성·runtime 승격 |
| 2슬롯 전조 | 한 행동이 다음 슬롯까지 예약되어 있고 끊길 수 있음 | 타임라인 span, 절제된 선행 모션/기세, `[전조]` 표기 | 전조만으로 피해·강화가 난 것처럼 보이기, 숨은 적 계획 노출 |
| `[합]`·중단·강건 | 어느 피해 단위가 살아남고 무엇이 끊겼는가 | 먹선 충돌, 짧은 타격 강조, 결과 log/Review와 같은 사건 순서 | 화려함 때문에 거리·피해·중단 원인을 가리는 연출 |
| 절초 | 기세를 쌓아 지불한 결정적 선택 | 제한된 고색, seal/ink burst, existing sprite-sheet consumer | 모든 강한 행동에 금색 사용, final VFX/Human 품질 통과 주장 |

이 표는 visual brief와 runtime consumer의 경계를 설명할 뿐이다. `PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2`는 planning artifact이고 runtime asset·Scene 구현·Human usability PASS가 아니다.

## 13. AUDIO CONSUMER MATRIX

| ID | required cue | intended consumer | state | next validation |
|---|---|---|---|---|
| AUD-PLAN-001 | slot placement / invalid placement | action dock | NOT_IMPLEMENTED_OR_UNVERIFIED | inspect runtime audio routing before production |
| AUD-RESOLVE-001 | telegraph, clash, block, evade, interrupt | combat presentation | NOT_RUN | define event→cue map after visual lock |
| AUD-REVIEW-001 | review/retry confirmation | result/review | NOT_RUN | human readability test |

No audio asset or runtime consumer is claimed solely from this planning document.

## 14. TECHNICAL ARCHITECTURE

```text
vertical_slice_shell.tscn
  → vertical_slice_shell_completion_auto.gd
  → vertical_slice_combat_bridge.tscn / vertical_slice_combat_bridge.gd
      → ActionSelectionDock / ActionPlacementController
      → CombatProgressButton
      → CombatResolutionEngine
          ↔ CombatAIPlanner (public snapshot only)
      → CombatBoardPreviewAuto (presentation)
      → CombatReviewPanel
      → VerticalSliceRunState / ResultModel / Route
```

| layer | actual owner | contract |
|---|---|---|
| resolver/model | `src/combat/combat_resolution_engine.gd` | authoritative action span, timing, state/event resolution |
| planner | `src/combat/combat_ai_planner.gd` | public info only enemy plan |
| UI controller | `src/ui/action_selection/action_placement_controller.gd` | plan editing/locked guard, no combat recalc |
| UI view | `src/ui/combat_progress_button.gd`, review panel | input state and observable result |
| run/persistence boundary | `src/run/vertical_slice_run_state.gd`, result model | retry snapshot / commit exactly once |
| scene adapters | `scenes/run/*`, `scenes/combat/*` | compose controls, visual presentation |
| content data | `data/cards/*`, `data/combat/*`, `data/run/*` | IDs and fixture content, no UI-owned rules |

## 15. DATA CONTRACTS

| ID | data | fields / constraints | owner |
|---|---|---|---|
| DAT-ACTION-001 | `basic_cards.json` | `id`, slots/span, resource, range, effect; 2-slot has telegraph/execution meaning | combat data |
| DAT-RESOLVE-001 | `combat_resolution_preview.json` | board 10 cells, starting positions, public AI source, action fixture | combat fixture |
| DAT-PLAN-001 | `combat_board_poc.json` | 3/3/4 slot capacity, hidden logical tile layer, player-facing `move_intent` only and public-opponent auto target for all other actions | action selection |
| DAT-MANUAL-001 | `martial_manual_cards.json`, `martial_manuals/*.json` | manual ID, unlock/adoption data | content data |
| DAT-RUN-001 | `vertical_slice_opponents.json` | candidate catalog, focus IDs, `final_stat_total_seed`; runtime binding fields are absent | run content / NOT_RUNTIME_BOUND |

Schema changes must preserve data/fallback/fixture/consumer/test compatibility. UI may display but must not recalculate combat rule truth.

## 16. SCENE MAP

| scene | role | evidence |
|---|---|---|
| `scenes/run/vertical_slice_shell.tscn` | run shell / application entry | `project.godot` main scene chain |
| `scenes/run/vertical_slice_combat_bridge.tscn` | run-to-combat composition | bridge tests |
| `scenes/combat/combat_board_preview.tscn` | combat board/UI presentation | Phase 2 visual/combat tests |
| `scenes/combat/action_selection_dock.tscn` | planning interface | UI adoption test |

Unknown scene paths are intentionally not fabricated. Inspect exact `.tscn` before changing nodes or bindings.

## 17. SCRIPT RESPONSIBILITY MAP

| script | responsibility | prohibited responsibility |
|---|---|---|
| `combat_resolution_engine.gd` | action spans, resolution events, state transitions | UI layout/visual-only totals |
| `combat_ai_planner.gd` | public snapshot decision | pending player plan/UI inspection |
| future `vertical_slice_opponent_runtime_binding` resource/adapter | candidate→archetype/stat binding | silently changing UI copy, reading player pending plan, or inventing combat rules |
| `combat_board_preview*.gd` | board state projection/presentation lifecycle | changing authoritative rules |
| `action_placement_controller.gd` | placement legality, lock behavior | hidden opponent reasoning |
| `combat_progress_button.gd` | execute request, disabled feedback | independently resolving combat |
| `combat_review_panel.gd` | causal replay/readout | inventing cause not in event history |
| `vertical_slice_run_state.gd` | retry count/snapshot/progression commit | duplicate reward commits |

## 18. SIGNAL AND EVENT FLOW

```text
UI-PLAN-001: placement_changed → valid_plan_changed
UI-COMBAT-001: execute_requested → SYS-RESOLVE-001.resolve_bundle
SYS-RESOLVE-001: resolution_event → Board / VFX / Review
SYS-RESOLVE-001: bundle_resolved → RunState / ResultModel
SYS-REVIEW-001: retry_requested → RunState.restore_same_snapshot
RunState: result_finalized → Result / Route
```

Emitter/receiver names must be re-read from exact scripts when implementation changes. The sequence records ownership and timing, not invented API names.

## 19. STATE MACHINES

### combat
`Planning → Ready → Executing/Presentation → Resolved → (next Planning | Review | Result)`.

### loss recovery
`Loss(retry_count=0) → Review → SameSeedRetry(retry_count=1) → (Win: commit once | Loss: Main, no reward/route)`.

### planning action
`Unselected → Selected → Placed(slot n) → [locked after execute] → Resolved`. A 2-slot action uses `Telegraph(slot n) → Action(slot n+1)`.

## 20. SAVE/LOAD CONTRACT

Current contract protects retry snapshot and exactly-once progression commit. Persisted formats, migrations, and platform lifecycle behavior require exact source review before any schema change. Android suspend/resume and device storage proof are `NOT_RUN`; never infer them from a headless test.

## 21. IMPLEMENTATION TRACEABILITY

| player experience | system/content | UI | implementation | validation |
|---|---|---|---|---|
| 가설을 3수에 배치 | SYS-PLAN-001 / CNT-ACTION-001 | UI-PLAN-001 | placement controller + action data | Phase 2 resolution/UI tests |
| 전조 비용을 보고 판단 | SYS-PLAN-002 | UI-COMBAT-001 | engine span/timing + CTA | phase2 combat test; human clarity NOT_RUN |
| 공정한 상대 읽기 | SYS-AI-001 | Review/history | AI public snapshot | `verify_phase2_observation.gd` |
| 상대의 관찰 가능한 습관을 파훼 | SYS-OPPONENT-001 / CNT-OPPONENT-RUNTIME-001 | Briefing / Review | PR #273 binding bridge | MACHINE_RUNTIME_VERIFIED_FOR_BINDING; balance simulation NOT_RUN |
| 실패에서 재도전 | SYS-REVIEW-001/SYS-RETRY-001 | UI-REVIEW-001 | run state / review panel | `verify_vertical_slice_failure_retry.gd` |
| 무공 선택으로 대응 폭 확장 | SYS-GROWTH-001/CNT-MANUAL-001 | selection / route | manual JSON + adoption UI/AI | `verify_ten_manual_ui_ai_adoption.gd`; UX NOT_RUN |

## 22. TEST AND QA CONTRACT

| ID | test / evidence | claim allowed | status |
|---|---|---|---|
| QA-PHASE2-001 | `tests/verify_phase2_observation.gd` | no private-plan AI observation regression | automated result required per exact SHA |
| QA-PHASE2-002 | `tests/verify_phase2_combat_resolution.gd` | 3/3/4, spans/timing, result rules | automated result required per exact SHA |
| QA-RETRY-001 | `tests/verify_vertical_slice_failure_retry.gd` | one retry/one commit contract | automated result required per exact SHA |
| QA-MANUAL-001 | `tests/verify_ten_manual_ui_ai_adoption.gd` | manual data/UI/AI adoption | automated result required per exact SHA |
| QA-BRIDGE-001 | `tests/verify_vertical_slice_combat_bridge.gd` | shell/bridge integration | automated result required per exact SHA |
| QA-DATA-001 | `pytest tests/test_phase2_combat_canon_data.py -q` | phase2 fixture/data coherence | automated result required per exact SHA |
| QA-BLUEPRINT-001 | `python -m unittest tests.test_human_game_blueprint_profile -v` | layered/profile/router/consumer/lifecycle documentation contract only | documentation validation required |
| QA-OPPONENT-001 | Issue #267 static + Godot scenario harness | candidate archetype, deterministic stat sum, focus score, public-only boundary | AUTHORIZED_GRANDFATHERED / NOT_RUN |
| QA-HUMAN-001 | visible Windows playthrough | readability, understanding, delight | NOT_RUN |
| QA-ANDROID-001 | device install/touch/back/safe-area/lifecycle | Android runtime | NOT_RUN |
| QA-A11Y-001 | keyboard focus/touch/accessibility session | inclusive input / contrast | NOT_RUN |

## 23. VERTICAL SLICE DEFINITION

**In scope:** 5 learning duels, first-loss Review and same-seed retry, 10 manual data adoption, route information/growth intent, planning→execution→presentation core.

**Proof target:** the player can explain one failure using public evidence and alter the next 3-slot plan.

**Most dangerous hypotheses:** (1) 2-slot telegraph cost creates readable tension, (2) Review makes a loss instructive rather than punitive, (3) the WARM DUSK visual grammar remains readable at gameplay size, (4) production can reuse shared resolver/template without bespoke duel systems.
**Out of scope:** new production asset batch, full campaign, deck/hand/draw grammar, real-time physics fighter, release claim.

## 24. RISKS AND BLOCKERS

| risk | class | evidence | disposition | next validation |
|---|---|---|---|---|
| stale mutable docs after #261 merge | internal / VERIFIED | Active Context, planning JSON, historical Notion timestamp vs main | FIXED | repository owner readback + governance regression |
| 2-slot telegraph unclear at actual scale | UX / NOT_RUN | no human evidence | TEST | five-player moderated session |
| review may explain too much/too little | design / NOT_RUN | no comprehension evidence | TEST | ask player to predict changed plan |
| 15-opponent / art production cost | production / INFERENCE | content/asset scope | MITIGATE | template + asset consumer estimate |
| deck-like card UI mispositions game | positioning / INFERENCE | explicit no-deck rule vs card visual | MITIGATE | usability and store-page concept test |
| Android usability | technical / NOT_RUN | no device evidence | TEST | target device matrix |
| visual board treated as shipping asset | rights/release / VERIFIED risk | planning-only decision | PROTECT | provenance and consumer check before adoption |
| candidate combat personality/stat binding absent | design/runtime / CURRENT | manual/star fields have current loadout/route/result consumers; behavior/focus/stat-seed fields have no combat personality/stat consumer | GRANDFATHERED_IMPLEMENTATION_NOT_STARTED | Issue #267 bridge + scenario tests; balance instrumentation is a later newly approved package |
| successor package bypasses Blueprint review | governance / PROSPECTIVE | Issue #267 has narrow pre-adoption approval; successor scope does not inherit it | BLOCK_NEW_PACKAGE_UNTIL_USER_FINAL_APPROVAL | first balance instrumentation and later packages run the §00.6 lifecycle |

## 25. USER DECISION REQUIRED

No new product-meaning decision is required to use this document as a GDD snapshot. `DEC-OPPONENT-001` is implemented as the approved Issue #267 isolated contract and has merged-main readback; that does not itself prove balance across the candidate/loadout/policy/seed matrix. `TEN-DEC-20260830-BALANCE-INSTRUMENTATION-CONTRACT-01` is user-approved for a written-spec review and still requires its design-review gate before implementation. Scope expansion and successor packages cannot reuse this approval. The following cannot be silently decided:

1. **Human test threshold and audience:** number/profile/definition of understanding pass for first 5–15 minutes.
2. **Production art scope:** whether to fund character/animation/VFX batch after a visual implementation contract; WARM DUSK planning anchor is not a shipping asset lock.
3. **Release priority:** Windows-first validation versus Android parity timing, after device evidence.

## 26. IMPLEMENTATION QUEUE

1. Execute the already approved/grandfathered Issue #267 in its exact isolated Codex/Godot handoff scope: bind candidate data to runtime archetype/stat allocation, preserve public-only AI, and report only actual evidence. This existing authority needs no new `USER_FINAL_APPROVAL`; expansion does.
2. After Issue #267 evidence exists, treat balance instrumentation as the first later package. Before it starts, run `PLAN -> REQUIRED_IMAGE_AND_MATERIAL_PREPARATION -> BLUEPRINT_REVIEW_PUBLICATION -> USER_FINAL_REVIEW_APPROVAL -> IMPLEMENTATION_START` and record a new explicit user final approval.
3. Visible Windows 5/15-minute player tests remain deferred and `NOT_RUN`; schedule them after the relevant implementation evidence and approval boundary without pre-claiming comprehension or balance.
4. Android, keyboard/focus, accessibility, audio/VFX, performance, and release gates remain deferred and `NOT_RUN` until their exact environments and observers execute them.

Priority formula: player-value risk (comprehension) → technical/platform risk → content/art production.

## 27. CHANGE LOG

| date | change | evidence |
|---|---|---|
| 2026-08-28 | First two-artifact GDD snapshot created from `origin/main@6baf817` | this document / matching PDF |
| 2026-08-28 | Phase 2 code reconciled through #261 before snapshot | merged PR #261 |
| 2026-08-28 | identified post-merge stale mutable owner records | DEC-STALE-001 |
| 2026-08-28 | resolved DEC-STALE-001 and retired the carried one-time protected approval | repository owner readback / lifecycle validator |
| 2026-08-28 | Issue #264: expanded Jianghu Journey, action-bundle/tag, martial/ultimate and visual-consumer explanations without changing product rules | user approval, `docs/02`, `docs/12`, `docs/17`, `docs/19`, actual data/consumer readback |
| 2026-08-29 | Issue #269: refreshed paired GDD from `origin/main@afa152b`, reconciled stale operating baseline, and separated approved opponent runtime binding from current runtime evidence | current source register, Decision `TEN-DEC-20260829-OPPONENT-RUNTIME-PERSONALITY-BINDING-01`, matching 20260829 PDF |
| 2026-08-29 | fresh-main layered-profile reconciliation: registered the existing AI spec, routed the current 20260829 pair, exposed status/cards/current field consumers, and added the prospective gate with non-retroactive Issue #267 grandfathering | delivery lineage `18d647c`; documentation contract test; PDFs unchanged |

### 27.1 Project Incident / Solution / Lesson — Issue #264

- **Incident.** 시스템 등록표와 단락형 요약만으로는 강호행의 비전투 선택, 3슬롯·2슬롯의 실제 기회비용, 관찰·강건·합·중단의 인과, 무공/절초의 시각 소비 경계를 한 흐름으로 이해하기 어려웠다. 이는 규칙 자체의 충돌이 아니라 **설명 밀도 부족으로 인한 정본 오독 위험**이다.
- **Solution.** §08과 §12에 player question, 선택의 이득/포기, 태그 glossary, `[합]`/중단 예시, 8노드 강호행, 기초/무공서/절초 시각 계층을 추가했다. 모든 새 설명은 기존 규칙 owner를 참조하고 `IMPLEMENTED`, `PARTIAL`, `UX_NOT_RUN` 경계를 유지한다.
- **Lesson.** 통합 GDD는 시스템 이름과 소유자만 나열하지 말고 `플레이어가 보는 정보 → 선택·대가 → 해결 결과 → 복기·다음 행동`을 최소 한 번 연결해야 한다. 다만 그 설명은 데이터·Scene·자산 소비처의 실제 상태를 앞질러서는 안 된다.
- **Base promotion.** `NO_BASE_PROMOTION`: 강호행 8노드, 3/3/4, 태그 뜻, 무공/절초의 visual grammar는 십보강호 고유이다. Base는 이미 설명-근거-상태 분리와 적대적 문서 검토 원칙을 소유한다.

## Appendix A. Evidence-based SWOT

| statement | class | evidence | confidence | player impact | production impact | disposition | next validation |
|---|---|---|---|---|---|---|---|
| Public-only AI boundary is executable and covered by a dedicated regression | STRENGTH | planner, fixture, observation test | VERIFIED | fair inference game | reusable opponent template | PROTECT | current-main test run |
| 3-slot/2-slot telegraph ties power to a legible timing sacrifice | STRENGTH | rules, engine span/timing | PARTIAL | meaningful commitment | low system reuse cost | TEST | comprehension playtest |
| 5-duel arc gives a teachable sequence of counters | STRENGTH | game/POC docs | PARTIAL | learning-shaped first session | templateable content | TEST | full 30 min session |
| Current mutable state was stale after merge | WEAKNESS | Active Context/JSON/historical Notion vs #261 | VERIFIED | indirect confusion | wrong handoff risk | IMPROVED | repository owner readback + governance regression |
| No human readability, audio, or device evidence exists | WEAKNESS | test/status audit | NOT_RUN | fun/clarity unknown | late rework risk | TEST | Windows+Android sessions |
| 15-opponent visual/content demand can outrun shared template | THREAT | vertical-slice content scope | INFERENCE | repetition or thin identity | budget/schedule risk | MITIGATE | per-template cost estimate |
| A compact wuxia inference duel has a clear category explanation | OPPORTUNITY | design synthesis, comparable mechanics | INFERENCE | memorable pitch | focused marketing surface | TEST | pitch/playtest response |
| Card-like presentation can be mistaken for a deckbuilder | THREAT | no-deck rule and card consumer | INFERENCE | wrong expectation | rework/store risk | MITIGATE | first-impression test |

## Appendix B. Benchmarks (primary-source recheck 2026-08-29)

| reference | category | observation | decision | adapt / reject | validation |
|---|---|---|---|---|---|
| Into the Breach | direct tactical readability | 공식 소개가 적 공격을 미리 읽고 counter를 찾는 구조를 제시한다 | ADAPT | 결과 원인을 보이되, 우리 AI의 전체 계획 공개는 거절 | can players predict one counter? |
| Your Only Move Is HUSTLE | direct commit→watch loop | committed sequence produces an inspectable playback | ADAPT | plan→presentation pacing; reject frame-sim/PvP scope | execution pacing test |
| Fights in Tight Spaces | direct spatial tactic | compact arenas make position/action consequences legible | ADAPT | spatial readability; reject deck/hand/draw grammar | distance comprehension |
| Shogun Showdown | direct timing-position tactic | 공식 소개가 position·attack timing·tile combo의 선택을 강조한다 | ADAPT | timing/position teaching; reject roguelike deck surface | duel template test |
| Hellish Quart | direct duel fantasy | distance and attack timing carry tension | ADAPT | dueling impact language; reject physics/contact-sim cost | action readability |
| Wandering Sword | direct wuxia identity | martial fantasy supports tactical anticipation | ADAPT | wuxia tone/skill identity; reject open-world/dual-mode scope | pitch test |
| Slay the Spire | adjacent route clarity | small visible route choices can clarify long-term tradeoffs | ADAPT | information-first route choice; REJECT deck system | route decision test |
| Godot GUI navigation + Android accessibility guidance | adjacent platform practice | focus neighbor/initial focus, 충분한 touch target과 고유 조작 설명이 명시적으로 필요하다 | ADOPT | focus/touch/contrast gate | device/a11y test |

Sources: [Into the Breach](https://subsetgames.com/itb.html); [YOMI Hustle](https://ivysly.itch.io/your-only-move-is-hustle); [Fights in Tight Spaces](https://store.steampowered.com/app/1265820/Fights_in_Tight_Spaces/); [Shogun Showdown](https://store.steampowered.com/app/2084000/Shogun_Showdown/); [Hellish Quart](https://www.hellishquart.com/); [Wandering Sword](https://store.steampowered.com/app/1876890/Wandering_Sword/); [Slay the Spire](https://www.megacrit.com/); [Godot GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html); [Android accessibility](https://developer.android.com/guide/topics/ui/accessibility/views/apps-views).

**Benchmark conclusion:** `ADOPT` readable result causality and focus/accessibility gates. `ADAPT` planned-sequence presentation, compact timing/position tension, information-first route choices, wuxia identity. `REJECT` full telegraph, deck/hand/draw, real-time physics combat, PvP/frame simulation, open-world scope. **Differentiation:** public-evidence-only AI plus 3-slot telegraph/action commitment and causal retry. **Remaining uncertainty:** human readability, 5-duel pacing, content cost, Android input.

## Appendix C. Notion retirement migration inventory

`TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`을 적용하기 전에 Notion Home와 L2/L3 tree를 fresh-read했다. 이 표는 이전 구조와 작업물을 삭제하지 않고, **현재 의미가 있는 고유 정보가 어느 repository owner에 있는지** 확인하는 migration readback이다. 2026-08-18~25의 planning-only 설명 중 최신 GitHub/Decision과 충돌하거나 current runtime을 주장하는 문구는 복사하지 않고 `HISTORICAL_OR_SUPERSEDED`로 낮췄다.

| legacy structure | current/relevant material | repository destination | migration verdict |
|---|---|---|---|
| `십보강호 · Home` | Player Promise, 3/3/4→execute→review loop, current evidence ceiling, P0 screen coverage | this spec §02–§06, §11–§12, §22–§24; `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`; `docs/20_SCREEN_VISUAL_COVERAGE_INVENTORY_20260828.md` | MIGRATED; Phase 2 “merge pending” wording corrected to PR #261 merged |
| `01 · Direction · Planning` | planning boundary / completion handoff | `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`, `docs/15_VERTICAL_SLICE_REVIEW_READY_CONTRACT.md`, `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md` | MIGRATED; old pre-user-complete gate is historical |
| `02 · Combat · Martial Arts · Route` | Flow Map, core systems, 15-candidate/8-route wire and reversible route seeds | `docs/02_COMBAT_RULES.md`, `docs/07_COMBAT_UI_SPEC.md`, `docs/09_COMBAT_SYSTEM_ARCHITECTURE.md`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`, `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md` | MIGRATED; numeric seeds remain `NOT_BALANCE_VALIDATED` |
| `03 · Visual · UX · Assets` | WARM DUSK v2, Board R2 planning-only boundary, runtime asset consumers | `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`, `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`, `docs/20_SCREEN_VISUAL_COVERAGE_INVENTORY_20260828.md`, `docs/visual-assets/**` | MIGRATED; planning image never promoted to runtime asset |
| `04 · Opponents · World · Content` | 5 learning slots × 3 candidates, 8 Route nodes, Briefing/Review/Result text grammar, Jianghu journey boundary | `docs/03_CONTENT_CATALOG.md`, `docs/12_VERTICAL_SLICE_JIANGHU_JOURNEY.md`, `docs/13_VERTICAL_SLICE_OPPONENT_ROUTE_TEXT_UX.md`, `docs/14_VERTICAL_SLICE_LOADOUT_ROUTE_BUDGET_WIREFRAME.md` | MIGRATED; names/appearance/long-form story remain reversible content detail |
| `05 · Production · Validation` | handoff, human/device evidence ceiling, validation packet | `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`, `docs/validation/TEN_PACES_UX_UI_VALIDATION_PACKET.md`, `docs/planning-data/current_user_planning_status.json`, `docs/operations/*` | MIGRATED; only exact-current automated result is claimed |
| `06 · Reference · Benchmark` | benchmark library function | Appendix B and source links in this spec | MIGRATED; raw historical library is not current canon |
| Notion Visual Bible / Asset Library attachments | visual direction, planning/R2 status, source-set/consumer/provenance distinctions | `docs/visual-assets/approved/**`, `docs/visual-assets/planning/**`, `docs/ASSET_RIGHTS_AND_PROVENANCE_RECORD.md`, this spec §12 | MIGRATED; prior attachments are historical delivery evidence only |

**Result:** no current Notion structure is required for a cold start. New Notion page, database, view, attachment, synchronization, or destination readback is out of scope for future work. A future request may selectively migrate a historical-only item only when it contains project-unique information not already owned by the repository.
