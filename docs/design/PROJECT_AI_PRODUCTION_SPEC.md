# PROJECT AI PRODUCTION SPEC — 십보강호

> 목적: 이 문서는 GPT/Codex가 후속 기획·구현·검증을 안전하게 이어가기 위한 **검색 가능한 통합 생산 명세**다. 실제 코드·Scene·Resource·JSON·테스트 및 각 분야의 책임 원본을 대체하지 않는다. 새 규칙을 승인하거나 기존 owner를 하나로 병합하지 않으며, 충돌과 미검증은 그대로 표시한다.

## 00. CANON SNAPSHOT

| 항목 | 값 |
|---|---|
| 프로젝트 | Ten Paces: Hidden Moves / 십보강호 |
| source branch | `origin/main` |
| 기준 commit | `6baf817b5f86baa3fe7df193832bd4f7bc4b2abf` |
| 기준일 | 2026-08-28 (KST) |
| 기준 PR | #261 `feat: reconcile Phase 2 combat canon`, squash-merged |
| 현재 작업 성격 | 문서 정본화·REVIEW. 제품 구현 계약을 새로 승인하지 않음. |
| 플랫폼 | Windows + Android, 공유 코어/플랫폼 adapter (`TEN-DEC-20260806-WINDOWS-ANDROID-DUAL-TARGET-01`) |
| 엔진 | Godot 4.7, `scenes/run/vertical_slice_shell.tscn` |
| 문서 상태 표기 | `DOCUMENTED / CONFIRMED / IMPLEMENTED / AUTOMATED_TEST_PASS / RUNTIME_VERIFIED / UX_VERIFIED / RELEASE_READY` |

### 00.1 읽기 우선순위

`최신 사용자 승인 → AGENTS.md → 분야별 repository owner/Decision → latest completed main의 코드·테스트 → open/draft PR → Base → optional historical migration input → historical chat` 순서다. migration input이 repository current truth와 다르면 코드 또는 문서 중 하나를 자동 정본화하지 않고 `CANON_CONFLICT`로 남긴다.

### 00.2 상태 요약

| 구분 | 판정 | 근거 |
|---|---|---|
| core combat / Phase 2 | `IMPLEMENTED + AUTOMATED_TEST_PASS` | #261과 `src/combat/`, `src/ui/`, `tests/` |
| Godot headless runtime | `RUNTIME_VERIFIED`는 이 문서 생성 시 재검증 대상으로 둔다 | 실제 창·사람 입력의 대체 아님 |
| Human usability / player fun | `NOT_RUN` | 사람이 플레이한 관찰·설문·영상 없음 |
| Android | `NOT_RUN` | export, 설치, touch, back, safe area, lifecycle 증거 없음 |
| Visual runtime | `PARTIAL` | 일부 배틀러·초상·카드 atlas·VFX consumer 있음; 전체 캐릭터/표현 검증 없음 |
| Audio | `NOT_RUN` | 승인된 runtime audio consumer 및 검증 증거 없음 |
| release | `NOT_RELEASE_READY` | 권리·스토어·실기기·성능·접근성 근거 미완성 |

## 01. SOURCE REGISTRY

| source | identity / readback | 역할 | 상태 |
|---|---|---|---|
| Repository | `origin/main@6baf817` | 코드·데이터·Scene·test runtime truth | CURRENT |
| GitHub PR #261 | merged, checks success | Phase 2 정본 reconciliation | CURRENT |
| GitHub PR #200, #199 | open draft | 미병합 후보, READ_ONLY | CURRENT_METADATA |
| `AGENTS.md` | repo root | 작업 경계·코어 불변식 | CURRENT |
| `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md` | #261 병합·repository-only current-state sync readback | mutable context | CURRENT_AFTER_SYNC |
| `docs/planning-data/current_user_planning_status.json` | #261 병합·human-test next readback | structured mutable state | CURRENT_AFTER_SYNC |
| Notion Project Home / Flow | 2026-08-28 10:18Z readback | historical migration input; Phase 2 pre-merge content migrated below | HISTORICAL_INPUT_ONLY |
| Notion Visual Bible / Asset Library | 2026-08-28 00:17Z readback | historical visual/asset migration input | HISTORICAL_INPUT_ONLY |
| `docs/01_GAME_DESIGN.md` 등 분야별 owner | repository | game rules, content, architecture, test owners | CURRENT/PARTIAL (각 항목 참조) |
| `docs/decisions/*2026-08-28*` | repository | opening distance, retry, CTA, Phase 2 decisions | CURRENT |
| `docs/visual-assets/approved/...` | repository | approved source-set locator | CURRENT |
| historical chat / memory | discovery only | 이전 탐색 보조 | HISTORICAL_ONLY |

### 01.1 Notion migration gap

Notion은 이 문서의 입력으로만 읽었다. #261 병합 후의 GitHub 상태는 Notion Home/Flow의 10:18Z 읽기 시점보다 늦으므로, Phase 2를 “handoff issued / merge pending”으로 표기한 부분은 이 문서의 기준 SHA와 충돌했다. 그 고유 Flow/Visual/asset 상태는 이 문서 §03·§12와 repository owners로 흡수했다. 이어서 Active Context·current planning JSON·Documentation Map·entry router를 repository-only current state로 동기화하고 readback했다. `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01`에 따라 Notion 신규 출력은 만들지 않았으며 앞으로 current authority로 사용하지 않는다.

## 02. CURRENT PROJECT STATE

### 02.1 프로젝트 한 문장

**십보강호는 공개된 거리·해결 이력만으로 상대의 다음 수를 가설화하고, 3개의 수(슬롯)에 1수 또는 2수 `[전조] → [행동]`을 비공개 배치한 뒤 실행·복기로 가설을 검증하는 1대1 무협 심리전이다.**

### 02.2 Current / historical / conflict 분류

| ID | 항목 | 분류 | 현재 판정 |
|---|---|---|---|
| DEC-CORE-001 | 10칸 직선 전장, 공개 시작 거리 2, 거리 중심 HUD | CURRENT | CONFIRMED / IMPLEMENTED |
| SYS-PLAN-001 | `3수 → 해결 → 3수 → 해결 → 4수 → 해결` | CURRENT | CONFIRMED / IMPLEMENTED |
| SYS-PLAN-002 | 3수 = 3슬롯, 2슬롯 행동은 `[전조] → [행동]`으로 2수를 소모 | CURRENT | CONFIRMED / IMPLEMENTED |
| UI-COMBAT-001 | CTA `행동계획 실행`; 실행 뒤 전투 표현으로 전환 | CURRENT | CONFIRMED / IMPLEMENTED |
| SYS-AI-001 | AI는 공개 상태·해결 이력만 사용, 미확정 계획/UI 의도를 읽지 않음 | CURRENT | CONFIRMED / IMPLEMENTED |
| UX-RETRY-001 | 첫 패배 후 실제 원인 복기·동일 seed 1회 무료 재도전 | CURRENT | CONFIRMED / IMPLEMENTED |
| CNT-MANUAL-001 | 덱·손패·드로우·장착 제한 없이 해금 기술을 슬롯에 배치 | CURRENT | CONFIRMED / IMPLEMENTED |
| AST-VIS-001 | WARM DUSK v2 | CURRENT | planning anchor only; runtime asset 승인 아님 |
| DEC-OPS-001 | repository-only canonical workspace | CURRENT | user confirmed; Notion is historical migration input only |
| DEC-STALE-001 | Phase 2 merge 전 Active Context/JSON/Notion 상태 | RESOLVED | repository owner sync·governance regression·readback 완료 |
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
| 첫 5분 | 거리 2에서 슬롯 배치→`행동계획 실행`→해결의 기본 리듬을 1회 이해 | IMPLEMENTED path / UX_NOT_RUN |
| 첫 15분 | 합·중단 또는 방어·강건의 실패 원인을 Review로 읽고 같은 seed를 한 번 다시 푼다 | DOCUMENTED + PARTIAL_IMPLEMENTED / UX_NOT_RUN |
| 첫 30분 | 5대련의 대응·거리·반복 파훼를 보고, 성장이 답이 아니라 선택지 확장임을 이해 | DOCUMENTED vertical-slice goal / NOT_RUN |

## 06. CORE / SESSION / META LOOP

```text
공개 거리·해결 이력 관찰
  → 가설과 3수 계획
  → 행동계획 실행 (편집 종료)
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
| SYS-REVIEW-001 | 복기 | 실패가 다음 행동으로 이어짐 | `combat_review_panel.gd` | IMPLEMENTED |
| SYS-RETRY-001 | 동일 seed 재도전 | 학습을 반복 기회로 전환 | `vertical_slice_run_state.gd` | IMPLEMENTED |
| SYS-GROWTH-001 | 무공 성장 | 파훼 폭을 확장 | `06_STARTING_FACTION_MASTERY_DATA.md` | DOCUMENTED / NOT_BALANCE_VALIDATED |
| SYS-ROUTE-001 | route 선택 | 정보/회복/성장 사이의 장기 선택 | `vertical_slice_route*.gd` | PARTIAL |

## 08. SYSTEM SPECIFICATIONS

### SYS-PLAN-001 — 행동 계획

**WHY.** 계획을 숨기는 이유는 상대가 내 UI·미확정 계획을 읽는 즉시 심리전이 사라지기 때문이다. 3수의 제한은 “무엇을 할까”를 “어떤 타이밍을 포기할까”로 바꾼다.

**HOW.** 사용자는 해금된 기술에서 행동을 선택하고 현재 bundle의 빈 슬롯에 배치한다. 1수 행동은 한 슬롯, 2수 행동은 `[전조]`와 `[행동]`의 연속 두 슬롯을 차지한다. 배치가 끝난 뒤 `행동계획 실행`을 누르면 편집이 중단되고 Combat Presentation으로 전환한다. 취소/재배치는 실행 전만 가능하다.

| 상태 | entry | player input | output / guard |
|---|---|---|---|
| Planning | bundle 시작 | 선택·배치·제거 | 슬롯 유효성 표시 |
| Ready | 유효 계획 | `행동계획 실행` | UI editing disabled |
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
| data | `data/combat/action_selection_poc.json`, `data/cards/basic_cards.json` |

**PSEUDOCODE.** `if plan.valid and execute_pressed: lock_inputs(); resolve_bundle(); play_resolution_events(); expose_public_history()`.

**COMPLETE WHEN.** 3/3/4 슬롯, 2수 span, 실행 후 편집 불가, resolver로의 단일 execute 흐름, plan leak 없음, Phase 2 tests pass. Human이 2수 전조 비용을 이해하는지는 `QA-HUMAN-001`으로 남는다.

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

### SYS-AI-001 — 공개 상태 AI

**WHY.** 상대가 항상 내 답을 알고 있다고 느끼면 계획은 무의미해진다.

**INPUT BOUNDARY.** player/enemy positions, 공개 자원, resolved history. **EXCLUDED:** player pending plan, hidden technique placement, UI intent signal.

| path | responsibility |
|---|---|
| `src/combat/combat_ai_planner.gd` | public snapshot에서 enemy bundle 선택 |
| `data/combat/combat_resolution_preview.json` | `enemy_plan_source: public_state_ai` fixture |
| `tests/verify_phase2_observation.gd` | plan/UI leakage regression |

**COMPLETE WHEN.** planner snapshot에서 제외 필드가 없고, enemy plan은 bundle resolve 전에 lock되며, 관찰은 action type의 해결 뒤 노출된다.

### SYS-REVIEW-001 / SYS-RETRY-001 — 복기와 동일 조건 재도전

**WHY.** 첫 패배를 루프 종료가 아닌 반증된 가설의 학습으로 만든다.

| 흐름 | 규칙 |
|---|---|
| first loss | Review에 실제 원인 1~3개, 거리 전/후, 가설/실제 결과 노출 |
| retry | retry count 0→1, 동일 snapshot/seed 복구, 무료 1회 |
| retry win | progression 단 한 번 commit |
| second loss | Main으로 종료, 보상/route 없음 |

`src/run/vertical_slice_run_state.gd`가 run 상태와 commit boundary를, `src/ui/combat_review_panel.gd`가 인과 설명을 소유한다. 완료 자동 증거: `tests/verify_vertical_slice_failure_retry.gd`.

### SYS-GROWTH-001 / SYS-ROUTE-001 — 성장과 route

성장은 특정 수치를 고정 정답으로 만들지 않고 새로운 대응 가능한 기술 조합을 연다. 현 계획에 10권 무공, 3→10 성장, 총 비용 38의 seed가 기록되어 있으나, 실제 사람 플레이 밸런스 증거는 없다. route는 성장/회복과 정보/준비를 결합하되, macro map 또는 덱 보상으로 확장하지 않는다.

| data / owner | status | validation |
|---|---|---|
| `docs/06_STARTING_FACTION_MASTERY_DATA.md` | DOCUMENTED | tuning table / fixture 필요 |
| `data/cards/martial_manual_cards.json`, `data/cards/martial_manuals/*.json` | IMPLEMENTED adoption data | UI/AI adoption test |
| `src/run/vertical_slice_route*.gd` | PARTIAL runtime consumer | visible Godot / human choice test |

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
| CNT-OPPONENT-001 | vertical slice opponents | 5대련의 행동 archetype | PARTIAL |

### CNT-ACTION-001 — 기본 행동 계약

| action | slots | 핵심 의도 | important rule |
|---|---:|---|---|
| 이동 / 보법 | 1 | 거리 조절 | 인접·사거리 판단을 바꿈 |
| 막기 / 회피 | 1 | 즉시 생존 | 방어/회피의 읽기 가능 결과 |
| 속공 | 1 | 짧은 기회 포착 | `floor(3 + external*0.5)` |
| 강공 | 2 | 전조를 감수한 타격 | `floor(7 + external*1)` |
| 관찰 | 1 | 정보 우위 | player only, 관찰점 1 |
| 명상 | 1 | resource 전환 | stamina+1, internal+1 |
| 준비 | 1 | 후속 행동 준비 | current data owner 확인 |
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
| UI-COMBAT-001 | Combat Board | 해결을 읽기 | 공개 거리, action resolution, result | `행동계획 실행` 이후 관찰 중심 | IMPLEMENTED |
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
| DAT-PLAN-001 | `action_selection_poc.json` | placement UI fixture / slot capacity | action selection |
| DAT-MANUAL-001 | `martial_manual_cards.json`, `martial_manuals/*.json` | manual ID, unlock/adoption data | content data |
| DAT-RUN-001 | `vertical_slice_opponents.json` | opponent/run seed data | run content |

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

## 25. USER DECISION REQUIRED

No new product-meaning decision is required to use this document as a GDD snapshot. The following cannot be silently decided:

1. **Human test threshold and audience:** number/profile/definition of understanding pass for first 5–15 minutes.
2. **Production art scope:** whether to fund character/animation/VFX batch after a visual implementation contract; WARM DUSK planning anchor is not a shipping asset lock.
3. **Release priority:** Windows-first validation versus Android parity timing, after device evidence.

## 26. IMPLEMENTATION QUEUE

1. Execute visible Windows player test for 5/15 minute comprehension; do not tune rules until results exist.
2. Create a single Phase 2 implementation contract only from approved human-test findings; then build in isolated PR.
3. Perform Android, keyboard/focus, accessibility and performance gates before release scope expands.

Priority formula: player-value risk (comprehension) → technical/platform risk → content/art production.

## 27. CHANGE LOG

| date | change | evidence |
|---|---|---|
| 2026-08-28 | First two-artifact GDD snapshot created from `origin/main@6baf817` | this document / matching PDF |
| 2026-08-28 | Phase 2 code reconciled through #261 before snapshot | merged PR #261 |
| 2026-08-28 | identified post-merge stale mutable owner records | DEC-STALE-001 |
| 2026-08-28 | resolved DEC-STALE-001 and retired the carried one-time protected approval | repository owner readback / lifecycle validator |

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

## Appendix B. Benchmarks (research date 2026-08-28)

| reference | category | observation | decision | adapt / reject | validation |
|---|---|---|---|---|---|
| Into the Breach | direct tactical readability | enemy intent and board state make causality inspectable | ADAPT | show why a result happened; reject full enemy plan telegraph | can players predict one counter? |
| Your Only Move Is HUSTLE | direct commit→watch loop | committed sequence produces an inspectable playback | ADAPT | plan→presentation pacing; reject frame-sim/PvP scope | execution pacing test |
| Fights in Tight Spaces | direct spatial tactic | compact arenas make position/action consequences legible | ADAPT | spatial readability; reject deck/hand/draw grammar | distance comprehension |
| Shogun Showdown | direct timing-position tactic | turn timing and placement form compact combos | ADAPT | timing/position teaching; reject roguelike deck surface | duel template test |
| Hellish Quart | direct duel fantasy | distance and attack timing carry tension | ADAPT | dueling impact language; reject physics/contact-sim cost | action readability |
| Wandering Sword | direct wuxia identity | martial fantasy supports tactical anticipation | ADAPT | wuxia tone/skill identity; reject open-world/dual-mode scope | pitch test |
| Slay the Spire | adjacent route clarity | small visible route choices can clarify long-term tradeoffs | ADAPT | information-first route choice; REJECT deck system | route decision test |
| Godot GUI navigation + Android accessibility guidance | adjacent platform practice | focus order and accessible touch targets require explicit design | ADOPT | focus/touch/contrast gate | device/a11y test |

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
