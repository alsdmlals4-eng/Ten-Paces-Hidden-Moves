# Ten-Manual UI·AI Adoption Implementation Plan

> Decision gate: `TEN_MANUAL_UI_AI_ADOPTION_GATE`
> User approval: `2026-08-06 권장안대로 진행`
> Parent runtime foundation: `TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE`
> Target PR: Draft PR #92, stacked on PR #91

## Goal

승인된 초기 무공서 10권의 런타임 정본을 행동 선택 UI와 공개 상태 AI에 연결한다. 기존 기본 행동·공용 절초·준비 엔진·비치팅 AI 계약은 유지한다.

## Non-negotiable boundaries

- 무공서와 기술의 유일한 공급 원본은 `MartialManualRegistry`다.
- UI는 명시적 `martial_loadout`과 `martial_mastery_by_manual`만 표시한다.
- AI는 자기 loadout에서 해금된 무공 카드만 후보로 사용한다.
- 플레이어 비공개 계획·포인터·미확정 배치 정보는 AI 입력에 포함하지 않는다.
- loadout이 없을 때 기존 UI·AI·전투 동작은 유지한다.
- 무공 카드가 선택 가능하지만 `effect_steps`가 실행되지 않는 가짜 통합을 금지한다.
- PR #92는 Draft·stacked 상태를 유지하며 병합·Draft 해제는 범위 밖이다.

## Task 1 — RED contract

Files:
- Create `tests/verify_ten_manual_ui_ai_adoption.gd`
- Create `.github/workflows/validate-ten-manual-ui-ai-adoption.yml`

The test must fail until all of the following exist:

1. ActionSelectionDock accepts loadout/mastery runtime context.
2. Martial tab shows registry-backed star3/star7 lock and overlay state.
3. Ultimate tab includes registry-backed star10 ultimates.
4. Enemy AI candidate pool includes only enemy-loadout martial cards.
5. Prepare engine executes a selected martial card through `MartialEffectPipeline` inside `resolve_bundle()`.

## Task 2 — Runtime loadout contract

Files:
- Create `data/combat/ten_manual_loadout_poc.json`
- Update `src/combat/martial_manual_registry.gd`
- Update `src/combat/combat_resolution_engine_ten_manuals.gd`

Add separate player/enemy loadouts and mastery maps. Preserve the legacy single-loadout API as a compatibility alias.

## Task 3 — UI registry adoption

Files:
- Update `src/ui/action_selection/action_view_model_adapter.gd`
- Update `src/ui/action_selection/action_selection_dock.gd`
- Update `src/ui/action_selection/ultimate_action_panel.gd`
- Update `src/combat/combat_board_preview_auto.gd`

The adapter builds view models from the registry, including:

- faction and manual name,
- primary/secondary stat,
- current mastery,
- star3/star7 lock state,
- applied star5/star9 overlays,
- star10 mastery and momentum lock state.

## Task 4 — AI adoption

Files:
- Update `src/combat/combat_ai_planner.gd`
- Update `src/combat/combat_resolution_engine.gd`
- Update `src/combat/combat_resolution_engine_ten_manuals.gd`

Add a protected AI-card-provider hook. The ten-manual adapter returns basic/common cards plus enemy-loadout martial cards only. Generic martial candidate scoring uses public distance, resources, bundle slots, card costs, range and effect-step movement only.

## Task 5 — Bundle execution bridge

Files:
- Update `src/combat/combat_resolution_engine.gd`
- Update `src/combat/combat_resolution_engine_ten_manuals.gd`
- Update `src/combat/combat_resolution_engine_prepare.gd`

Add no-op custom-card hooks to the base engine and implement them only in the ten-manual adapter. The prepare engine inherits the ten-manual adapter so existing prepare post-processing remains active.

Known boundary: simultaneous ordinary manual multi-hit versus ordinary base attack remains a human/balance verification item. `SPECIAL_CLASH` receives public opponent clash power and consumes the opposing action on win/draw.

## Task 6 — Canon and Sheet sync

Files:
- Create `docs/decisions/2026-08-06_TEN_MANUAL_UI_AI_ADOPTION_GATE.md`
- Update active context, roadmap, lifecycle and PR #92 body.
- Create Google Sheet tab `03_무공서_무학`.

Sheet columns:

`번호 | 문파·유파 | 무공서 | 무학 방향성 | 주능력치 | 보조능력치 | 3성 기술1 | 3성 효과 | 5성 강화 | 5성 효과 | 7성 기술2 | 7성 효과 | 9성 완성효과 | 9성 효과 | 10성 절초 | 10성 효과 | 성취도 요약 | 런타임 상태 | Decision | Exact SHA`

## Verification

Required before completion claim:

- new UI·AI adoption workflow PASS,
- existing ten-manual runtime workflow PASS,
- PR Validation PASS,
- Full Validation PASS,
- existing AI tendency test PASS,
- existing action selection dock test PASS,
- Sheet tab readback confirms 10 manual rows and exact SHA,
- PR remains open, Draft, unmerged and stacked on PR #91.
