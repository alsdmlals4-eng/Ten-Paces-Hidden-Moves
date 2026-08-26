# 십보강호 · GPT Work 인수인계 · 2026-08-26

> Handoff ID: `TEN-HANDOFF-20260826-GPT-WORK-01`  
> User direction: 앞으로 작업 surface는 `GPT Work`  
> Current execution contract: `TEN-DEC-20260826-INTEGRATED-WORK-CONTRACT-V4-8-R5-4-01`  
> Current visual production decision: `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`  
> Shared Work adapter: Base `CHATGPT_WORK_PROJECT_EXECUTION_INSTRUCTION_v4.9` + compatibility appendix  
> Product/runtime mutation authority from this handoff: `false`

이 문서는 과거 채팅 전문을 복제하지 않는다. 새 GPT Work 세션이 **현재 Project GitHub + exact Project Notion을 fresh-read**해 현재 품질, 보호 범위, 다음 안전 작업, evidence ceiling을 복원하기 위한 bounded handoff다.

> 2026-08-26 구현 갱신: `DOGYEOM_STATUS_PORTRAIT_01`은 승인 PNG를 runtime asset으로 등록하고 `slot1_dogyeom` 상태 패널 라우팅까지 구현했다. focused Godot 검증과 Vertical Slice bridge 회귀는 `PASS`; Windows visible human usability와 Android device는 여전히 `NOT_RUN`이다. 세부 증거는 `docs/handoffs/2026-08-26_DOGYEOM_STATUS_PORTRAIT_CODEX_EXECUTION_REPORT.md`를 따른다.

Base v4.9 Work adapter는 프로젝트의 r5.4 계약을 대체하는 새 프로젝트 정본이 아니다. `WORK_IS_EXECUTION_SURFACE_NOT_CANON`으로 Work 실행면을 제공하면서 r5.4 capability와 Project current canon을 보존한다.

## 1. 새 GPT Work 세션 시작 순서

1. `alsdmlals4-eng/Ten-Paces-Hidden-Moves`의 기본 브랜치, 최신 `main`, 열린 PR을 다시 조회한다.
2. `alsdmlals4-eng/Base`의 최신 completed `main`, root `AGENTS.md`, 현재 작업에 필요한 owner/Skill을 progressive-load한다.
3. Base current Work bundle을 확인한다.
   - `templates/project-operations/CHATGPT_WORK_PROJECT_EXECUTION_INSTRUCTION_v4.9.md`
   - `templates/project-operations/CHATGPT_WORK_PROJECT_EXECUTION_INSTRUCTION_v4.9_COMPATIBILITY_APPENDIX.md`
4. Project Notion의 `십보강호 · Home` → `02 · 비주얼 바이블` → `04 · 에셋 라이브러리` → `2026-08-26 · GPT Work 인수인계`를 다시 읽는다.
5. repository의 다음 current state를 다시 읽는다.
   - `docs/PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION.md`
   - `[기획서]/00_프로젝트_허브/ACTIVE_CONTEXT.md`
   - `docs/planning-data/current_user_planning_status.json`
   - `docs/planning-data/current_visual_production_handoff_20260826.json`
   - `docs/19_VISUAL_PRODUCTION_CURRENT_GATE_2026-08-26.md`
6. 과거 대화, Default memory, 이 문서의 observed SHA, Google Sheet를 current truth로 자동 승격하지 않는다.
7. GitHub↔Notion 의미가 다르면 mutation 전에 `CONTEXT_DRIFT_RECHECK_REQUIRED`로 멈춘다.

## 2. Handoff 시점 관측 snapshot

아래 값은 **2026-08-26 handoff 과정에서 관측한 증거**이며 다음 세션의 live authority가 아니다.

```yaml
observed_project_main_before_handoff_merge: b6d76410e3aa0edd7a2e698270742187cc471fd9
observed_project_main_message: docs: bind visual production to actual game consumers (#205)
observed_base_main_latest_during_handoff: 43b3ffb2c5b026e3d4a38dab2338585894d36f61
observed_base_main_message: feat: add Work-native project execution instruction (#726)
observed_base_work_adapter: templates/project-operations/CHATGPT_WORK_PROJECT_EXECUTION_INSTRUCTION_v4.9.md
observed_base_work_compatibility_appendix: templates/project-operations/CHATGPT_WORK_PROJECT_EXECUTION_INSTRUCTION_v4.9_COMPATIBILITY_APPENDIX.md
observed_open_project_prs:
  - 199: DRAFT_READ_ONLY_BY_DEFAULT_CONFLICTING_WITH_NEW_MAIN
  - 200: DRAFT_READ_ONLY_BY_DEFAULT_CONFLICTING_WITH_NEW_MAIN
notion_work_handoff: https://app.notion.com/p/3c81b237eb1c81539c1bd4afa75e4b9a
```

PR `#199`, `#200`은 이 handoff가 소유하지 않는다. 새 Work 세션에서 자동 rebase, 수정, close, merge하지 않는다.

## 3. 현재 Visual production 원칙

사용자 승인 원칙은 다음이다.

> 설명용 시트가 아니라 **실제 게임 소비처가 있는 이미지** 기준으로 만든다.

따라서 `ACTUAL_GAME_CONSUMER_REQUIRED`를 유지한다.

- 설명용/스타일 검증만을 위한 별도 sheet는 production target이 아니다.
- 실제 게임이 atlas/sprite sheet를 소비할 때만 production atlas/sheet를 허용한다.
- source master는 파생 제품 자산을 위한 재사용 원본으로 허용하지만 runtime integration PASS가 아니다.
- 이미지 생성/생성형 편집 cadence는 `text brief → explicit user approval → exactly one result → user review`다.

## 4. 사용자 승인 Visual 상태

### 기존 승인 Reference

- `TEN-IMG-001` · 대표 전투 화면 Reference.
- `TEN-VIS-CHAR-MASTER-001` · Character Master 그림체 Reference.
- `TEN-VIS-A07-CANDIDATE` · 기초 행동 삽화 언어 Reference.
- `TEN-VIS-A01` · 공통 수묵 clean plate Reference.

### `OPPONENT_CHARACTER_MASTER_01` · 도겸 Source Master

```yaml
status: USER_APPROVED_2026_08_26
generation_id: 0d895036-38e6-420e-990f-823353373366
source_png_sha256: efe88bf4aaf7d1773916f151d518cf52508f18a670760f817c4226feb7564f42
notion_delivery: PASS
runtime_asset: false
```

### `DOGYEOM_COMBAT_BATTLER_01` · 도겸 전장 Battler

```yaml
status: USER_APPROVED_2026_08_26
generation_id: 79ae965f-6048-48c5-b667-6e9b7a55b68f
source_png_sha256: 064a8772406c743bbe6b252c138b4333c88b00b90a0ba905cce9ea18773539c9
notion_delivery: PASS
consumer: src/combat/combat_character_placeholder.gd
current_generic_consumer_asset: res://assets/characters/enemy_masked_battler_rgba_v1.png
opponent_specific_routing: NOT_RUN
runtime_asset: false
```

승인된 Battler는 투명 RGBA 전신, enemy left-facing, foot-anchor-safe source다. 사용자 승인은 실제 Godot consumer routing이나 runtime art integration을 뜻하지 않는다.

## 5. 완료된 안전 작업

### `DOGYEOM_STATUS_PORTRAIT_01`

실제 consumer:

- `src/ui/combatant_status_panel.gd`
- 현재 generic enemy portrait: `res://assets/portraits/enemy_masked_ink_v1.png`

완료 결과:

1. 승인 PNG를 `res://assets/portraits/dogyeom_status_portrait_01_v1.png`로 저장하고 asset manifest에 등록했다.
2. `VerticalSliceCombatBridge`가 잠긴 opponent `candidate_id`를 `combat_state.enemy`에 보존한다.
3. `CombatantStatusPanel`은 `slot1_dogyeom`에만 승인 초상을 표시하고, 기타 상대 및 ID 누락 상대는 기존 generic portrait를 유지한다.
4. `opponent-specific Dogyeom routing`과 `runtime art integration`은 `AUTOMATED_GODOT_PASS_20260826`이다. Windows visible human usability는 별도 `NOT_RUN`이다.

### 다음 후보

- exact card ID가 있는 개별 무공/절초 카드 삽화.
- 실제 consumer는 `src/ui/card_view.gd`의 `CardView.illustration`.
- `MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01` 같은 설명용 sheet는 current production queue에 넣지 않는다.
- 나머지 상대 portrait/battler, Route/Result/Background도 실제 게임 consumer 확인 뒤 제작한다.

## 6. Godot / Codex 경계

```text
GPT Work
→ 기획 / 조사 / 검수 / Notion / GitHub 정본 / Visual / handoff

실제 Godot 제품 구현 필요 없음
→ Work에서 정본·Visual 작업 후 검토 종료

실제 Godot 제품 구현 필요
→ CODEX_GODOT_PRODUCT_IMPLEMENTATION_HANDOFF
→ Codex가 Project GitHub + Notion을 독립 fresh-read
→ Codex 자신의 구현환경에서 code/data/scene/asset routing/test/runtime evidence
→ READY_FOR_GPT_REVIEW
```

PowerShell은 local Godot 실행/검증 전용이며 local Codex launcher로 사용하지 않는다.

## 7. Evidence ceiling

```yaml
dogyeom_character_master_user_approval: PASS
dogyeom_character_master_notion_delivery: PASS
dogyeom_combat_battler_generation: PASS_EXACTLY_ONE
dogyeom_combat_battler_user_approval: PASS
dogyeom_combat_battler_notion_delivery: PASS
runtime source promotion: NOT_RUN
opponent-specific Dogyeom routing: AUTOMATED_GODOT_PASS_20260826
runtime art integration: AUTOMATED_GODOT_PASS_20260826
windows visible human usability: NOT_RUN
android actual device: NOT_RUN
fifteen opponent identifiability: NOT_RUN
human fun/readability/immersion: NOT_RUN
final VFX/audio: NOT_RUN
```

자동 테스트나 승인 이미지로 위 `NOT_RUN`을 PASS로 올리지 않는다.

## 8. Google Sheet drift

Handoff 직전 Google Sheet `00_프로젝트_허브`는 아직 다음 과거 상태를 노출했다.

- `2026-08-11` Phase-B planning state.
- old Project main/PR metadata.
- old Base SHA.
- old work-contract Decision.

따라서 current GitHub + Notion과 충돌한다. r5.4에 따라 Google Sheet는 `MIGRATION_ONLY_UNTIL_REMOVAL`이며 **보고만 하고 신규 승인/current state를 Sheet로 되돌려 쓰지 않는다.**

## 9. GPT Work 재개용 첫 요청

Base v4.9 Work adapter 기준으로 별도 Goal을 매번 반복할 필요는 없다. 프로젝트명 + Work 공용 지시문만으로 current Project canon에서 다음 안전 작업을 복원할 수 있다. 이번 handoff를 명시적으로 이어가려면 다음 문장을 사용할 수 있다.

> 십보강호 현재 GitHub main·열린 PR·Base main과 Project Notion Home/Visual Bible/Asset Library/GPT Work 인수인계를 fresh-read하고, 과거 채팅이나 memory를 current truth로 쓰지 말고 `DOGYEOM_STATUS_PORTRAIT_01`의 실제 소비처 기준 다음 작업부터 재개해.

첫 응답에서는 바로 이미지 생성하지 말고 fresh-read 결과, 권위 충돌 여부, 현재 next safe action을 먼저 확인한다.
