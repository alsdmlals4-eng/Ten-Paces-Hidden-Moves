# 십보강호 · Visual Production Current Gate · 2026-08-26

> Current workspace contract: `TEN-DEC-20260828-REPOSITORY-ONLY-CANONICAL-WORKSPACE-01` (product safety baseline: r5.4)
> Current visual production decision: `TEN-DEC-20260826-VISUAL-CONSUMER-ASSET-PRODUCTION-01`  
> Human-facing owner: repository Visual/asset owners; Notion is historical migration input only
> Structured current state: `docs/planning-data/current_visual_production_handoff_20260826.json`  
> Work handoff: `docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md`

> 2026-08-28 planning-anchor override: `TEN-DEC-20260828-WARM-DUSK-V2-PLANNING-ANCHOR-01` locks the warm-dusk, charcoal-ink, restrained-gold v2 as a `USER_APPROVED_PLANNING_ANCHOR_ONLY_NON_RUNTIME` source for `PROJECT_CORE_SCENE_VISUAL_BOARD`. All approved runtime assets remain separate evidence until a consumer-specific asset-promotion task is approved and verified.

> 2026-08-28 cadence override: `TEN-DEC-20260828-CORE-SCENE-VISUAL-BOARD-FINAL-LOCK-CADENCE-01` replaces pre-generation approval with scoped single-result generation and **user final-lock review only**. It neither starts an automatic asset queue nor promotes a planning preview to a runtime asset.

> 2026-08-28 final lock: `PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2` is now `USER_FINAL_LOCKED_PLANNING_ARTIFACT_ONLY`, stored at `docs/visual-assets/planning/PROJECT_CORE_SCENE_VISUAL_BOARD_20260828_R2.png`. Historical Notion attachment/readback does not create a current owner. It remains non-runtime and does not authorize automatic next image work.

이 문서는 `docs/18_VISUAL_PRODUCTION_HANDOFF_2026-08-25.md`의 승인 Reference Set과 당시 사용자 피드백을 삭제하거나 다시 쓰지 않는다. 8월 25일 문서는 historical visual handoff이고 이 문서는 r5.4 product safety baseline을 사용한다. Work도 memory나 과거 대화를 current truth로 사용하지 않고 Project GitHub + repository visual owners를 fresh-read한다.

## 1. 보존되는 승인 Reference

- `TEN-IMG-001` · 대표 전투 화면 Reference.
- `TEN-VIS-CHAR-MASTER-001` · Character Master Reference.
- `TEN-VIS-A07-CANDIDATE` · 기초 행동 삽화 언어 Reference.
- `TEN-VIS-A01` · 공통 수묵 clean plate Reference.

승인 Reference는 shipping/runtime asset PASS가 아니며 runtime art integration과 Human/device 검증을 자동 포함하지 않는다.

## 2. 2026-08-26 사용자 승인 결과

### `OPPONENT_CHARACTER_MASTER_01` · 도겸

상태: `USER_APPROVED_AND_IMPLEMENTED_2026_08_27`.

- generation id: `0d895036-38e6-420e-990f-823353373366`.
- source PNG SHA-256: `efe88bf4aaf7d1773916f151d518cf52508f18a670760f817c4226feb7564f42`.
- historical Notion `04 · 에셋 라이브러리` preview delivery/readback evidence: `PASS`.
- 역할: `Character Master → Portrait Crop → Combat Full Body → Result Crop → Silhouette → Thumbnail` 파생용 source master.
- runtime source master promotion / Godot integration: `NOT_RUN`.

### `DOGYEOM_COMBAT_BATTLER_01` · 도겸 전장용 Battler

상태: `USER_APPROVED_2026_08_26`.

- generation id: `79ae965f-6048-48c5-b667-6e9b7a55b68f`.
- source PNG SHA-256: `064a8772406c743bbe6b252c138b4333c88b00b90a0ba905cce9ea18773539c9`.
- historical Notion `04 · 에셋 라이브러리` preview delivery/readback evidence: `PASS`.
- 실제 consumer slot: `src/combat/combat_character_placeholder.gd`.
- 현재 generic runtime asset: `res://assets/characters/enemy_masked_battler_rgba_v2.png`.
- runtime asset: `res://assets/characters/dogyeom_combat_battler_01_v1.png`.
- 승인 source contract: transparent RGBA full body / enemy left-facing / foot-anchor safe.
- `slot1_dogyeom`만 전용 Battler를 선택하고, 다른 상대 및 ID 누락 상대는 generic fallback을 유지한다.
- opponent-specific Dogyeom routing: `AUTOMATED_GODOT_PASS_20260827`.
- runtime art integration: `AUTOMATED_GODOT_PASS_20260827`.
- Windows visible local machine runtime smoke: `PASS_20260830_GODOT_4_7_1_START_TO_SLOT1_DOGYEOM_COMBAT_SCREEN`; 이는 Codex가 실제 화면을 시작부터 도겸 전투까지 통과시킨 증거이며, Human usability/player approval는 아니다. 상세는 `docs/operations/2026-08-30_WINDOWS_VISIBLE_GODOT_RUNTIME_SMOKE_EXECUTION_REPORT.md`가 소유한다.
- Windows visible human usability / Android device: `NOT_RUN`.

## 3. Current visual language

> **세계는 저대비 한지 질감의 무협 애니메이션, 인물은 굵은 수묵 윤곽 × 절제된 셀 음영, 정보는 독립적이고 정제된 전술 UI.**

보호한다.

- 전장이 가장 큰 시각 질량.
- 세로로 긴 7~7.5등신 계열의 무협 애니메이션 전신 인물과 물리적으로 짧은 저자세 검.
- `거리 N` 중심, 3/3/4 계획 의미 보존.
- `기초 / 무공 / 절초` 출처 분리.
- Action grid 최대 5×2, 최대 10개 수용.
- 기초·무공·절초는 하나의 `ActionChoiceCard` 카드 규칙과 승인된 출처별 삽화 atlas를 공유한다.
- 텍스트·비용·사거리·효과 숫자는 원화가 아니라 Godot UI/data binding이 소유.
- 제한 금색은 선택·확정·절초·결정적 결과에만 사용.
- 상대의 숨은 계획/정답을 색·포즈·연출로 누설하지 않음.

`TEN-DEC-20260901-GROUNDED-DUEL-AUTO-TARGET-OBSERVE-01`은 현재 묶음 CTA의 보이는 copy를 `N수 실행`으로 컴팩트화했다. 이는 유효한 3/3/4 슬롯 묶음을 commit한 뒤 전투·해결 애니메이션으로 전환하는 행위라는 2026-08-28 Decision의 의미를 유지한다. 역사적 `행동계획 실행` 표기는 이 보이는 CTA copy 범위에서 superseded다.

### 무공·절초 카드 — 공용 삽화 후보 gate

사용자 최신 지시와 `TEN-DEC-20260831-ACTION-CARD-ILLUSTRATION-EXTENSION-01`에 따라 기본 행동·무공 기술·절초는 동일한 `ActionChoiceCard` 위계와 상단 삽화 영역을 공유하는 방향으로 확장한다. 이름, 행동 수, 기력/내력/기세 비용, 잠금 상태, 행동 종류, 사거리, 효과, 키보드 포커스와 접근성 텍스트는 계속 UI/data binding이 소유한다. 삽화는 보조 정보이며 유일한 규칙 전달 수단이 아니다.

`MARTIAL_AND_ULTIMATE_CARD_ILLUSTRATION_ATLAS_01_v1.png`은 사용자 `삽화 확정`(2026-08-31)으로 `USER_FINAL_LOCKED_CANON_REGISTERED_IMPLEMENTED_MACHINE_RUNTIME_VERIFIED`가 됐다. 후보→approved→runtime PNG는 같은 SHA-256으로 exact-byte 승격됐고, manifest 등록 뒤 `ActionViewModelAdapter`가 source-kind semantic region을 `ActionChoiceCard`에 전달한다. 따라서 `MartialActionPanel`과 `UltimateActionPanel`은 별도 삽화 레이아웃 없이 같은 renderer에서 `TextureRect`를 만든다. 이전 무삽화 결정은 역사 기록으로 보존하되 current 방향에서는 superseded다. Human/accessibility/Android/release evidence는 별도 Gate다.

## 4. 이미지 생성 cadence

생성형 이미지 작업은 actual consumer-first boundary를 유지하되, 2026-08-28 사용자 지시와 `TEN-DEC-20260828-CORE-SCENE-VISUAL-BOARD-FINAL-LOCK-CADENCE-01`의 현행 cadence를 적용한다.

```text
canon + actual game consumer review
→ scoped text brief
→ 정확히 1개 결과 생성
→ adversarial review
→ 사용자 final lock
→ 다음 결과를 자동 생성하지 않음
```

2026-08-25의 max-three는 historical cadence이며 current automatic batch 권한이 아니다. 다만 승인 원본의 deterministic crop/mask/resample처럼 **새 생성이 아닌 파생 작업**이 실제 소비처를 충족하면 이를 우선한다.

## 5. Consumer-first 제작 원칙

사용자는 2026-08-26 **“설명용 시트가 아니라 실제 게임 소비처가 있는 이미지 기준으로 만든다”**고 명시했다.

따라서 신규 이미지에는 항상 `실제 게임 소비처`가 있어야 한다.

- 설명용/스타일 비교만을 위한 `MARTIAL_TECHNIQUE_ILLUSTRATION_SHEET_01`은 current production queue에서 제거한다.
- 실제 게임이 atlas/sprite sheet 자체를 소비할 때만 production sheet/atlas를 허용한다.
- 이미지에 소비처가 아직 없다면 먼저 구현/데이터의 소비 계약을 확인하고 생성 여부를 결정한다.
- source master는 파생 제품 자산을 만들기 위한 재사용 원본으로 허용하되 source master 자체를 runtime integration PASS로 간주하지 않는다.

현재 확인한 소비처:

1. **전장 전신 Battler** — `src/combat/combat_character_placeholder.gd`; 현재 generic enemy texture는 `res://assets/characters/enemy_masked_battler_rgba_v2.png`.
2. **상태 패널 Portrait** — `src/ui/combatant_status_panel.gd`; 현재 enemy portrait는 `res://assets/portraits/enemy_masked_ink_v1.png`.
3. **카드 중앙 삽화** — `src/ui/card_view.gd`의 `CardView.illustration`; `data/cards/basic_cards.json`이 실제 illustration atlas region 소비 계약을 보유한다.

## 6. 구현 완료 실제 소비처 자산

### `DOGYEOM_STATUS_PORTRAIT_01` · 도겸 상태 패널 Portrait

**실제 게임 소비처:** `src/ui/combatant_status_panel.gd`.

**현재 generic consumer asset:** `res://assets/portraits/enemy_masked_ink_v1.png`.

**승인 결과:** 사용자 명시 승인 후 생성한 `DOGYEOM_STATUS_PORTRAIT_01_v1`.

**source local asset:** `docs/visual-assets/approved/DOGYEOM_STATUS_PORTRAIT_01_v1.png`.

**runtime asset:** `res://assets/portraits/dogyeom_status_portrait_01_v1.png`.

제작 원칙:

- 사용자 승인 도겸 전신·캐릭터 시트를 정체성·화풍 참고로 사용한다.
- 현재 status panel crop에서 얼굴/상체가 작은 크기로 명확히 읽혀야 한다.
- 승인 Master PNG를 fresh-read로 복구하지 못해, 사용자의 새 원화 명시 승인에 따라 text brief → 명시 승인 → 정확히 1개 → 검토를 완료했다.
- UI/text/수치/프레임을 원화에 굽지 않는다.
- `VerticalSliceCombatBridge`는 잠긴 상대의 `candidate_id`를 `combat_state.enemy`에 보존한다.
- `CombatantStatusPanel`은 `slot1_dogyeom`일 때만 이 asset을 선택하며, 다른 상대 및 ID 누락 상대는 기존 `enemy_masked_ink_v1.png`를 유지한다.
- 기존 `STRETCH_KEEP_ASPECT_COVERED` 표시 계약은 유지한다.

현재 상태: `IMPLEMENTED · AUTOMATED_GODOT_VERIFIED_20260826 · WINDOWS_HUMAN_VISUAL_REVIEW_NOT_RUN`.

### `DOGYEOM_COMBAT_BATTLER_01` · 도겸 전장 Battler

**실제 게임 소비처:** `src/combat/combat_character_placeholder.gd`.

승인된 투명 RGBA 전신 PNG를 `res://assets/characters/dogyeom_combat_battler_01_v1.png`로 등록했다. 전투판은 `combat_state.enemy.candidate_id == "slot1_dogyeom"`일 때만 이 Battler를 선택하며, 다른 상대와 ID 누락 상대는 현재 `enemy_masked_battler_rgba_v2.png` generic fallback을 유지한다. 기존 enemy-facing, 발 앵커, 이동·공격 모션, 전투 규칙은 변경하지 않았다.

현재 상태: `IMPLEMENTED · AUTOMATED_GODOT_VERIFIED_20260827 · WINDOWS_HUMAN_VISUAL_REVIEW_NOT_RUN`.

### `FRONTAL_COURTYARD_DUEL_BACKGROUND_01` · 전투 배경 (역사 버전)

**실제 게임 소비처:** `src/combat/battle_background.gd`.

사용자가 2026-08-31에 명시적으로 `최종확정`을 주었다. 그에 따라 한 장의 environment-only 정면 결투 마당 결과를 정식 등록했다.

- canonical source asset: `docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.png`.
- runtime asset: `res://assets/backgrounds/frontal_courtyard_duel_background_01_v1.png`.
- SHA-256: `27778369c3896d7d6237990ec70620c54ad0d636f660c9aa80322b0632262d06` (both repository destinations have the exact same bytes).
- dimensions: `1672×941`.
- output id: `exec-e3ab08d2-ac38-48de-81b4-de02580ecafc`.
- composition: warm hanji, centred gate, distant mountains, sunset, and an intentionally visible shared stone ground plane. It contains no people, weapons, UI, readable/pseudo-readable text, numbers, logos, or watermark.
- user reference handling: the supplied combat screenshot informed only the overall ink-paper mood, world/UI hierarchy, and gameplay-safe composition. Its pixels, characters, UI, and text were not copied into this asset.
- cleanup: superseded background binaries were removed from the current tree under the user-approved cleanup rule and remain recoverable from Git history.
- provenance and release-rights ceiling: see `docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.md`. This is a user-final-locked project asset, not a blanket shipping-rights or release-pass claim.

현재 상태: `SUPERSEDED_BY_USER_FINAL_LOCK_20260902`. 이 버전의 2026-08-31 machine evidence는 역사 증거로 보존하며, 새 modular background의 runtime evidence로 재사용하지 않는다.

### `FRONTAL_COMBATANT_ROUTING_01` · 정면 대치 Battler Routing

**실제 게임 소비처:** `src/combat/combat_character_placeholder.gd`.

2026-08-31의 사용자 explicit `최종확정`에 따라 정면 대치 공유 지면 구도로 되돌렸던 historical routing이다. 이후 2026-09-02 explicit final lock에 따라 generic player/enemy route는 v2로 supersede되었다. status portrait, 전투 타일 논리, AI 정보 경계, 저장 schema는 바꾸지 않는다.

- `assets/ASSET_MANIFEST.json`은 현재 player, generic enemy, Dogyeom 전신 원화의 provenance, alpha audit, 정확한 consumer를 소유한다.
- 대각선 pair binary와 derived crop은 현재 소비처가 없어 사용자 승인 cleanup rule에 따라 현재 트리에서 제거했다. Git history에서만 복구 가능하다.
- 새 정면 shared-ground composition의 Godot runtime readback은 아직 실행 전이다.

현재 상태: `SUPERSEDED_BY_USER_FINAL_LOCK_20260902`. Human usability/player approval, accessibility-user, Android device, release clearance는 `NOT_RUN`이다.

### `FRONTAL_COURTYARD_MODULAR_ART_PACK_20260902_v2` · 현재 배경·전경·전투원

사용자 명시 승인 “방금 2 이미지는 승인”과 “배경,깃발도 방금 만든거 2개 승인”(2026-09-02)에 따라 다음 네 모듈을 현재 generic runtime route로 등록했다.

- Background: `frontal_courtyard_duel_background_02_v1.png`; environment-only shared stone-floor module.
- Foreground: `frontal_courtyard_banner_overlay_01_v1.png`; `DuelForegroundBanner`가 좌/우 반전 pair로 재사용하며 input을 가로막지 않는다.
- Player / generic enemy: `player_wanderer_battler_rgba_v2.png`, `enemy_masked_battler_rgba_v2.png`; low, body-proportional swords and alpha-only figures with no baked floor.
- Consumers: `BattleBackground`, `CombatBoardPreview`, `MainTitleScreen`, and `CombatCharacterPlaceholder`. Dogyeom’s specific `slot1_dogyeom` route is untouched.

각 exact source PNG, SHA-256, prompt scope, alpha audit, approval phrase, consumers, and rights ceiling are `assets/ASSET_MANIFEST.json` and the four `docs/visual-assets/approved/*_v1.md` / `*_v2.md` records that own. Old generic v1 binaries remain manifest-marked, recoverable superseded assets—not deleted current evidence.

현재 상태: `USER_FINAL_LOCKED · CANON_REGISTERED · IMPLEMENTED · PENDING_MACHINE_RUNTIME_VERIFICATION`. Exact new-art capture is mandatory before a runtime-verified claim. Human usability/player approval, accessibility-user, Android device, and release clearance remain `NOT_RUN`.

### `TEN_BASIC_TECHNIQUE_INK_ATLAS_01` · 기초 기술 5×2 Card Atlas

**실제 게임 소비처:** `data/cards/basic_cards.json` → `BasicActionPanel` / card detail / `CombatActionRevealOverlay`.

동일 final lock으로 1장의 `1536×1024` basic-technique atlas를 등록하고, 10개 기초 card ID 각각을 measured region으로 연결했다. Action grid는 최대 5×2와 card-data text ownership을 유지한다. compact horizontal slot에서는 pose readability를 위해 native `TextureRect.STRETCH_KEEP_ASPECT_COVERED`를 쓰고, 이미지 안에 card name, cost, range, result text를 굽지 않는다.

- canonical/runtime SHA-256: `a047a81c92d51cfa3c0b0d81ac2edf53b9a15e262420753a08bc2ed473ed7998`.
- region map, consumer, source/rights ceiling은 `TEN_BASIC_TECHNIQUE_INK_ATLAS_01_v1.md`와 `assets/ui/cards/card_asset_manifest.json`이 소유한다.
- 2026-08-30 actual Godot current-frame readback은 10 physical card images in the active 5×2 dock를 확인했다.

### `COMBAT_ACTION_REVEAL_OVERLAY` · 한 수씩 공개하는 대결 연출

**실제 게임 소비처:** `src/combat/combat_board_preview.gd` → `CombatActionRevealOverlay`.

`CombatResolutionEngine.resolve_bundle()`은 기존처럼 bundle 당 정확히 한 번만 authoritative resolution을 수행한다. 화면은 `timing_results` 중 현재 timing의 authoritative post-resolution event만 전달받아 양측 card·`VS`·결과를 먼저 표시하고, 그 뒤에만 해당 timing snapshot을 적용한다. planning dock/timing/progress는 overlay 동안 숨기고, skip은 미래 행동을 공개하지 않은 채 ordered snapshot을 끝까지 적용해 review로 이동한다. `public_resolution_history`의 field는 확장하지 않았고 AI/private plan boundary도 바꾸지 않았다.

현재 상태: `IMPLEMENTED · MACHINE_RUNTIME_VERIFIED_20260830`; exact runtime screenshot and snapshot confirm timing 1 only, `future_action_visible: false`, hidden action-selection dock, and visible player/enemy cards with `VS`. Human comprehension/readability remains `NOT_RUN`.

## 7. 다음 후보 — 자동 생성 없음

1. 개별 절초 카드 삽화 — 반드시 **exact card ID**와 `CardView.illustration` 소비가 확인된 이미지 단위로 제작. 무공 기술서의 기술 행 삽화는 `TEN-DEC-20260830-MARTIAL-MANUAL-TEXT-FIRST-PRESENTATION-01`에 따라 제작 대상이 아니다.
2. 나머지 상대 Portrait/Battler — 승인 source identity + 실제 consumer 계약을 확인한 뒤 제작.
3. Route/Result 계열 — 실제 소비 컴포넌트가 확인된 뒤 제작. 추가 Background variant도 새 exact consumer와 별도 scoped brief가 있을 때만 제작.

## 8. GPT Work handoff

새 GPT Work 세션은 다음을 먼저 읽는다.

- Project GitHub `main` + 열린 PR.
- Base 최신 completed `main`.
- repository Visual Bible / Asset Library / GPT Work handoff owner.
- `docs/planning-data/current_user_planning_status.json`.
- `docs/planning-data/current_visual_production_handoff_20260826.json`.
- `docs/handoffs/2026-08-26_GPT_WORK_HANDOFF.md`.

Google Sheet는 `MIGRATION_ONLY_UNTIL_REMOVAL`이며 current visual authority가 아니다.

## 9. Evidence ceiling

```yaml
approved_reference_set: PASS_2026_08_25
opponent_character_master_01_generation: PASS_EXACTLY_ONE_2026_08_26
opponent_character_master_01_user_approval: PASS_2026_08_26
opponent_character_master_01_historical_notion_delivery: PASS_2026_08_26
dogyeom_combat_battler_01_generation: PASS_EXACTLY_ONE_2026_08_26
dogyeom_combat_battler_01_user_approval: PASS_2026_08_26
dogyeom_combat_battler_01_historical_notion_delivery: PASS_2026_08_26
dogyeom_status_portrait_01_user_approval: PASS_2026_08_26
dogyeom_status_portrait_01_historical_notion_binary_delivery: PASS_20260826_READBACK
dogyeom_status_portrait_01_runtime_asset: res://assets/portraits/dogyeom_status_portrait_01_v1.png
consumer_first_visual_policy: USER_APPROVED_2026_08_26
dogyeom_status_portrait_01: USER_APPROVED_2026_08_26
dogyeom_status_portrait_01_local_asset: docs/visual-assets/approved/DOGYEOM_STATUS_PORTRAIT_01_v1.png
dogyeom_status_portrait_01_historical_notion_binary_attachment: PASS_20260826_READBACK
next_safe_action: FOLLOW_CURRENT_PHASE1_REVIEW_AND_SCOPED_CONSUMER_POLICY_NO_AUTOMATIC_IMAGE_WORK
runtime_source_master_promotion: NOT_RUN
opponent_specific_dogyeom_routing: AUTOMATED_GODOT_PASS_20260827_STATUS_PORTRAIT_AND_COMBAT_BATTLER
runtime_art_integration: AUTOMATED_GODOT_PASS_20260827_STATUS_PORTRAIT_AND_COMBAT_BATTLER
frontal_courtyard_duel_background_01_user_final_lock: PASS_20260831
frontal_courtyard_duel_background_01_canon_copy_sha256_readback: PASS_20260831
frontal_courtyard_duel_background_01_runtime_asset: res://assets/backgrounds/frontal_courtyard_duel_background_01_v1.png
frontal_courtyard_duel_background_01_runtime_integration: MACHINE_RUNTIME_VERIFIED_20260831_GODOT_4_7_1_VISIBLE_NODE_LOG_READBACK
frontal_courtyard_duel_background_01_human_usability: NOT_RUN
superseded_ink_mist_and_diagonal_runtime_binaries: REMOVED_FROM_CURRENT_TREE_RECOVERABLE_GIT_HISTORY
ten_basic_technique_ink_atlas_01_user_final_lock: PASS_20260830
ten_basic_technique_ink_atlas_01_canon_runtime_readback: PASS_20260830
ten_basic_technique_ink_atlas_01_runtime_integration: MACHINE_RUNTIME_VERIFIED_20260830_GODOT_4_7_1_ACTIVE_5X2_DOCK
martial_ultimate_card_illustration_atlas_01_user_final_lock: PASS_20260831
martial_ultimate_card_illustration_atlas_01_canon_runtime_readback: PASS_20260831
martial_ultimate_card_illustration_atlas_01_runtime_integration: MACHINE_RUNTIME_VERIFIED_20260831_GODOT_4_7_1_SHARED_ACTIONCHOICECARD
combat_action_reveal_overlay_runtime_integration: MACHINE_RUNTIME_VERIFIED_20260830_GODOT_4_7_1_TIMING_1_ONLY_VS_RESULT
combat_action_reveal_overlay_human_comprehension: NOT_RUN
windows_visible_local_machine_runtime_smoke: PASS_20260830_GODOT_4_7_1_START_TO_SLOT1_DOGYEOM_COMBAT_SCREEN_NOT_HUMAN_USABILITY
windows_visible_local_machine_runtime_smoke_report: docs/operations/2026-08-30_WINDOWS_VISIBLE_GODOT_RUNTIME_SMOKE_EXECUTION_REPORT.md
windows_visible_human_usability: NOT_RUN
android_actual_device: NOT_RUN
fifteen_opponent_identifiability: NOT_RUN
human_fun_readability_immersion: NOT_RUN
final_vfx_audio: NOT_RUN
```

---

## 10. Screen-first coverage readback · 2026-08-27

## 10A. Runtime visual capture evidence · 2026-09-01

`TEN-DEC-20260901-RUNTIME-VISUAL-CAPTURE-EVIDENCE-01` is the current owner for the user-required in-game capture evidence on every player-visible design or visual change. Store the smallest useful normal/result screenshot set in `docs/evidence/RUNTIME_VISUAL_CAPTURE_MANIFEST.json`; do not treat a temporary HERA output, a static planning board, a generated candidate, or a screenshot alone as Human/device/accessibility/release approval.

Issue [#238](https://github.com/alsdmlals4-eng/Ten-Paces-Hidden-Moves/issues/238)은 `VerticalSliceShell`의 actual screen state와 asset consumer를 fresh-read했다. 상세 Target Screen Inventory, Screen→Asset Coverage Matrix, Design Reference Queue, Runtime Asset Family Queue, correction log, bounded Codex handoff는 `docs/17_VERTICAL_SLICE_VISUAL_UX_REQUIREMENT_SPEC.md`의 **§16**이 단독으로 소유한다. 이 Gate에 같은 matrix를 복제하지 않는다.

```yaml
target_build: FIRST_FIVE_DUEL_PC_FIRST_VERTICAL_SLICE
actual_p0_surfaces:
  - MAIN
  - SETUP
  - INTRO
  - BRIEFING
  - COMBAT
  - REVIEW_OVERLAY
  - RESULT
  - ROUTE_GROWTH
  - ROUTE_INFO
  - COMPLETION
p0_blocking_gap: 0
noncombat_runtime_mode: GODOT_UI_TEXT_LAYER_NO_NEW_IMAGE_FILE_REQUIRED
candidate_guardrail: WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_V2_USER_APPROVED_PLANNING_ANCHOR_ONLY_NON_RUNTIME
new_image_from_audit: FORBIDDEN
bounded_codex_handoff: CODEX_UI_COPY_CORRECTION_REQUIRED
```

This planning-anchor decision changes neither runtime asset approval nor runtime promotion. `WARM_DUSK_TEN_STEP_COMBAT_ANCHOR_01_v2_NO_FLOOR_GRID` is not connected to `BattleBackground` and is not evidence of Windows/Android/Human visual quality. The 14 remaining opponent portraits/battlers, route icons, result marks, and extra backgrounds remain `GAP_NONBLOCKING` only when their exact future screen/component consumer is selected; they are not an automatic creation list.
