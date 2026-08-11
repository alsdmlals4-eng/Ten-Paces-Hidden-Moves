# Planning Completion Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to execute this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 십보강호의 현재 `VERTICAL_SLICE_APP_FLOW_PLANNING` 범위를 텍스트 정본으로 완결하고, 별도 적대적 검수를 통과한 뒤에만 이미지 생성을 재개할 수 있는 검증 가능한 Gate를 만든다.

**Architecture:** 현재 상태는 `ACTIVE_CONTEXT.md`, 제품/분야 의미는 각 책임 정본, 승인 상태는 Decision/구조화 계약/Google Sheet가 소유한다. 계획 완료와 검수 완료는 이미지 생성과 분리하며, 시각 요구사항은 텍스트로 닫되 실제 생성물은 검수 완료 뒤에만 만든다. 각 작업은 `Base / Project / Sheet fresh-read → 벤치마킹·현업 조사 → 프로젝트 적합성 판정 → RED → 최소 수정 → GREEN → 적대적 재검토 → exact-head 검증 → Sheet readback` 순서를 따른다.

**Tech Stack:** Markdown/YAML/JSON planning canon, Python `unittest`, GitHub Actions, Google Sheets, Godot 4.7 planning authority. 제품 Godot runtime은 이 계획의 수정 대상이 아니다.

## Global Constraints

- Base / Project / Sheet fresh-read는 **모든 작업 시작 전에** 다시 수행한다.
- 벤치마킹·현업 조사는 **모든 작업 시작 전에** 수행하되, 외부 시스템을 복사하지 않고 십보강호에 맞는 요소만 취한다.
- 프로젝트 코어는 `3/3/4 비공개 계획 + 공개 단서 추론 + 1대1 거리 결투`다.
- 시작 공개 거리 `2`, 거리0=`[밀착]`, 번호 발판 상시 표시 금지.
- 카드 `사거리`는 `[공격]` 행동만 표시하고 비공격은 행 자체를 생략한다.
- `[관찰]`은 잠긴 상대 계획의 앞 수부터 행동 종류만 공개한다.
- 2슬롯 행동은 `[전조] → [실행]`, 계획판 실행 슬롯은 실제 행동 종류를 표시한다.
- `[기절]`, `예상 명중률`, `% 명중률`은 사용하지 않는다.
- 이미지 생성 순서는 `기획완료 → 검수완료 → 이미지 생성`이다.
- `PLANNING_COMPLETE does not require generated images`.
- `REVIEW_COMPLETE does not require generated images`.
- `image_generation_gate: AFTER_REVIEW_COMPLETE`.
- `image_generation_before_review_complete: FORBIDDEN`.
- `product_implementation_authorized: false`.
- 제품 코드, Godot Scene/Resource, runtime 데이터, Android/Windows 사람 검증 상태를 이 계획 문서만으로 승격하지 않는다.
- `IMPLEMENTED_LEGACY`와 `CURRENT_APPROVED_PLANNING`을 구분하고 자동 구현 동기화를 금지한다.
- 모든 승인 Decision은 동일 Decision ID로 GitHub와 Sheet에 동기화한다.
- P0/P1 = 0이 아니면 완료 판정을 내리지 않는다.

---

## Scope Boundary

이번 `기획완료`의 대상은 **현재 Vertical Slice/App Flow에 필요한 제품 기획**이다. 출시 이후 사업·스토어·장기 라이브 기능처럼 현재 Vertical Slice를 막지 않는 항목은 `DEFERRED_NON_BLOCKING`으로 명시할 수 있으며, 미정 상태를 숨기지 않는다.

완료 대상:

- 제품 방향·핵심 재미·승패/실패·핵심 루프
- 전투 규칙·3/3/4·거리·자원·관찰·전조·합·중단·기본 행동
- 무공서/무학·성장·보상·경제의 Vertical Slice 필요 범위
- 지도/노드/브리핑/결과/보상/재시도 App Flow
- 캐릭터·상대·세력의 현재 데모 필요 범위
- 카드 본체/상세창/계획판·HUD·접근성·Windows/Android 반응형 정보 계약
- 저장/입력/플랫폼 Adapter의 기획 계약
- 아트·오디오의 **요구사항과 금지사항**; 실제 신규 이미지 생성은 제외
- 구현 legacy ↔ 최신 기획 delta inventory
- acceptance criteria와 검증 evidence class

현재 완료를 막지 않는 후속 범위는 반드시 `DEFERRED_NON_BLOCKING + trigger`로 기록한다.

---

# Stage 1 — 기획완료 후보

Stage 1은 자동으로 `PLANNING_COMPLETE`를 선언하지 않는다. 모든 기획 항목이 닫힌 **후보 상태**를 만들고, 이후 사용자 명시 `기획 완료` 선언을 받을 준비를 하는 단계다.

### Task 1: 승인된 카드·상세창·계획판 spec을 현재 기획 권위에 연결

**Files:**
- Modify: `docs/superpowers/specs/2026-08-11-combat-card-detail-plan-information-design.md`
- Test: `tests/test_combat_ui_top_level_authority.py`
- Reference: `docs/02_COMBAT_RULES.md`
- Reference: `docs/07_COMBAT_UI_SPEC.md`
- Reference: `docs/decisions/2026-08-11_COMBAT_UI_INFORMATION_HIERARCHY_DECISION.md`

**Produces:** user-approved UI information spec marked `PLANNING_COMPLETION_REVIEW_READY` without granting runtime implementation.

- [ ] **Step 1:** Assert the user-approved spec status and ordered `기획완료 → 검수완료 → 이미지 생성` sequence in `tests/test_combat_ui_top_level_authority.py`.
- [ ] **Step 2:** Run `python -m unittest tests.test_combat_ui_top_level_authority -v`; expected RED is missing approval status or missing review-plan contract.
- [ ] **Step 3:** Change only the spec lifecycle status to `USER_APPROVED_SPEC / PLANNING_COMPLETION_REVIEW_READY`; preserve `PLANNING_ONLY`, `image_generation: NO`, and all current combat values.
- [ ] **Step 4:** Re-run the exact unittest and require PASS.
- [ ] **Step 5:** Run PR Validation, Full Validation, Product Gate and all triggered existing workflows at the exact head; product/runtime evidence remains unchanged in meaning.

### Task 2: Build the authoritative planning inventory

**Files:**
- Create: `docs/reviews/2026-08-11_PLANNING_COMPLETION_INVENTORY.md`
- Create: `docs/planning-data/planning_completion_inventory_20260811.json`
- Test: `tests/test_planning_completion_inventory.py`

**Consumes:** current GitHub main, Base main, Sheet `00·01·02·03_무공서_무학·04·05·10·11·12·13·14·15·20·30·40·41·50·60·70·80·90·98·99`.

**Produces:** one row per current-scope planning area with `authority`, `decision_ids`, `sheet_rows`, `implementation_state`, `open_conflicts`, `evidence_class`, `completion_status`.

- [ ] **Step 1:** Fresh-read Base structure/main/open PRs, project main/open PRs, and all listed Sheet tabs before writing the inventory.
- [ ] **Step 2:** Run task-specific benchmark/industry research and record only `borrow / do-not-borrow / project-fit` findings in the inventory appendix.
- [ ] **Step 3:** Write a failing test requiring every required domain key and requiring no blank `authority` or `completion_status`.
- [ ] **Step 4:** Run `python -m unittest tests.test_planning_completion_inventory -v`; require RED while the inventory is absent/incomplete.
- [ ] **Step 5:** Populate Markdown + JSON from live authority; do not infer missing decisions.
- [ ] **Step 6:** Mark unresolved items as `P0`, `P1`, `P2`, `DEFERRED_NON_BLOCKING`, or `EVIDENCE_PENDING_NON_PLANNING`.
- [ ] **Step 7:** Re-run the same test and require PASS.

### Task 3: Resolve product/core-loop and combat-rule planning blockers

**Files:**
- Modify only the responsibility owners identified by Task 2, typically `docs/00_GDD.md`, `docs/02_COMBAT_RULES.md`, relevant Decision/approved JSON, and corresponding Sheet rows.
- Test: domain-specific existing contract tests plus any new focused regression test.

**Produces:** no P0/P1 ambiguity in core fun, 3/3/4, distance, action tags, costs, observation, clashes, interruption, resource recovery, win/loss flow.

- [ ] **Step 1:** Fresh-read and benchmark before each independent blocker.
- [ ] **Step 2:** For each blocker, write one focused RED that states the currently missing/contradictory contract.
- [ ] **Step 3:** Present any product-meaning or numeric choice that cannot be resolved from existing approval to the user; do not invent it.
- [ ] **Step 4:** Apply the approved minimum change with the same Decision ID on GitHub and Sheet.
- [ ] **Step 5:** Run focused GREEN, canonical combat impact validation, PR/Full/Product workflows, and Sheet readback.

### Task 4: Resolve growth/content/app-flow planning blockers

**Files:**
- Modify only responsibility owners identified in Task 2 for manuals/martial arts, growth/economy, route/node/briefing/result/reward/retry, characters/factions needed by the Vertical Slice.
- Test: focused regression contract per independent decision.

**Produces:** every Vertical Slice screen/state transition has defined inputs, outputs, player choice, failure/recovery, and ownership.

- [ ] **Step 1:** Audit `start → manual selection → route/node → briefing → combat → result → reward → retry/continue` as a state transition chain.
- [ ] **Step 2:** RED any missing transition, duplicate reward/commit risk, undefined failure recovery, or hidden content dependency.
- [ ] **Step 3:** Resolve only current-scope blockers; mark later campaign/business scope `DEFERRED_NON_BLOCKING` with trigger.
- [ ] **Step 4:** GREEN each independent contract and synchronize Sheet.

### Task 5: Resolve UX/accessibility/platform planning blockers

**Files:**
- Modify: `docs/07_COMBAT_UI_SPEC.md` and/or responsibility owners identified in Task 2.
- Reference: approved card/detail/plan spec.
- Test: focused UI/platform contract tests.

**Produces:** Windows/Android share information meaning while layout/input adapt by platform; no hover-only/drag-only essential interaction.

- [ ] **Step 1:** Audit keyboard/mouse/gamepad/touch/back/focus paths for every current-scope interactive screen.
- [ ] **Step 2:** Verify critical state is not color-only and Android interactive targets are designed around a 48dp minimum touch target where applicable.
- [ ] **Step 3:** Verify card body/detail/plan board preserve the current attack-only range rule, observation visibility, `행동계획 잠금`, and `[전조]` semantics.
- [ ] **Step 4:** RED and resolve any planning ambiguity without claiming physical device or human usability validation.

### Task 6: Close visual/audio requirement text without generating assets

**Files:**
- Modify: relevant `docs/` visual/audio requirement owners and Sheet `70·71·72` only as needed.
- Test: visual requirement lifecycle contract.

**Produces:** textual art/audio requirements sufficient for post-review image generation; existing explorations remain `NOT_AN_ASSET`.

- [ ] **Step 1:** Inventory required screens/assets and distinguish `REUSE_EXISTING`, `NEW_ASSET_REQUIRED_AFTER_REVIEW`, and `NO_NEW_ASSET_REQUIRED`.
- [ ] **Step 2:** Define purpose, required information, forbidden content, responsive constraints, rights/provenance requirements for each `NEW_ASSET_REQUIRED_AFTER_REVIEW` item.
- [ ] **Step 3:** Ensure no actual image generation happens in Stage 1.
- [ ] **Step 4:** Keep TEN-IMG-001 prior chat explorations `NOT_AN_ASSET` unless separately approved after Stage 2.

### Task 7: Produce the planning-completion candidate report

**Files:**
- Create: `docs/reviews/2026-08-11_PLANNING_COMPLETION_CANDIDATE.md`
- Modify: `docs/planning-data/planning_completion_inventory_20260811.json`
- Test: `tests/test_planning_completion_candidate.py`

**Produces:** `PLANNING_COMPLETION_CANDIDATE` only when current-scope P0/P1 are zero.

- [ ] **Step 1:** RED a candidate test that requires every current-scope inventory item to be `RESOLVED` or explicitly `DEFERRED_NON_BLOCKING`.
- [ ] **Step 2:** Require `P0/P1 = 0`, no GitHub/Sheet Decision-ID mismatch, and complete implementation-delta inventory.
- [ ] **Step 3:** Require image generation to still be forbidden and product implementation authorization to remain false.
- [ ] **Step 4:** Run exact-head PR/Full/Product and all triggered workflow checks; require review threads 0.
- [ ] **Step 5:** Fresh-read merged authority and Sheet. If all criteria pass, report **candidate** status to the user and request the explicit `기획 완료` declaration required by the operating contract.

---

# Stage 2 — 검수완료

Stage 2 begins only after Stage 1 candidate evidence is complete and the user explicitly declares `기획 완료`.

### Task 8: Adversarial full-canon review

**Files:**
- Create: `docs/reviews/2026-08-11_FINAL_PLANNING_ADVERSARIAL_REVIEW.md`
- Create: `docs/planning-data/final_planning_review_20260811.json`
- Test: `tests/test_final_planning_adversarial_review.py`

**Produces:** independent evidence classes for planning consistency; does not pretend to be human usability or device validation.

- [ ] **Step 1:** Fresh-read Base/project/Sheet and re-run pre-work benchmark/industry research focused only on discovered risk areas.
- [ ] **Step 2:** Review changed files, untouched responsibility owners, consumers, derived JSON, cold-start routers, historical documents, and Sheet for stale current authority.
- [ ] **Step 3:** Attack normal, failure, edge, counterexample, regression, information-leak, accessibility, responsive, save/commit, and legacy-boundary cases.
- [ ] **Step 4:** For every finding, classify `P0/P1/P2/INFO`; P0/P1 must be resolved through fresh RED→GREEN work units before completion.
- [ ] **Step 5:** Explicitly keep `human_usability`, `local_windows_visible`, `android_device`, and physical-input evidence as `NOT_RUN` unless actually executed.

### Task 9: Verify no hidden image dependency and close review

**Files:**
- Modify: final adversarial review and structured review JSON.
- Test: `tests/test_final_planning_adversarial_review.py`

- [ ] **Step 1:** Assert `PLANNING_COMPLETE does not require generated images`.
- [ ] **Step 2:** Assert `REVIEW_COMPLETE does not require generated images`.
- [ ] **Step 3:** Assert every image requirement needed for Stage 3 is textual, traceable, and rights/provenance bounded.
- [ ] **Step 4:** Require P0/P1 = 0, exact-head CI success, review threads 0, GitHub/Sheet readback match.
- [ ] **Step 5:** Only then set the review artifact status to `REVIEW_COMPLETE` and synchronize Sheet. This status still does not authorize product BUILD.

---

# Stage 3 — 이미지 생성

Stage 3 begins only after `REVIEW_COMPLETE`. It may create planning/product-asset candidates, but generated output is not automatically a product asset.

### Task 10: Generate only approved visual requirements

**Files:**
- Modify/create provenance records under `docs/planning-data/`.
- Sync Sheet `71_이미지기획_생성목록` and `72_이미지검수_승인로그`.
- Product asset files are added only after a separate asset-approval decision.

- [ ] **Step 1:** Fresh-read current canon and re-run visual benchmark/rights research before each generation batch.
- [ ] **Step 2:** Generate only items marked `NEW_ASSET_REQUIRED_AFTER_REVIEW` with their approved purpose/required/forbidden constraints.
- [ ] **Step 3:** Record tool/model/date/brief/provenance and mark every new output `NOT_AN_ASSET` initially.
- [ ] **Step 4:** Review planning match, information accuracy, accessibility/readability, implementation feasibility, responsive feasibility, style consistency, and rights similarity.
- [ ] **Step 5:** Reject/regenerate failures; only separately approved outputs may become product asset candidates.

---

## Completion Semantics

```yaml
stage_1_result: PLANNING_COMPLETION_CANDIDATE
stage_1_user_transition: EXPLICIT_기획_완료_REQUIRED
stage_2_result: REVIEW_COMPLETE
stage_3_entry: REVIEW_COMPLETE_REQUIRED
image_generation_gate: AFTER_REVIEW_COMPLETE
image_generation_before_review_complete: FORBIDDEN
product_implementation_authorized: false
local_windows_visible_validation: NOT_RUN_UNLESS_EXECUTED
android_device_validation: NOT_RUN_UNLESS_EXECUTED
human_usability_validation: NOT_RUN_UNLESS_EXECUTED
```

`기획완료 후보`, 사용자 `기획 완료`, `검수완료`, `이미지 생성`, `제품 BUILD 승인`은 서로 다른 Gate이며 서로를 대신하지 않는다.

## Self-Review

- Spec coverage: 카드 본체/상세창/계획판, 관찰, 전조, 거리, 잠금, responsive/accessibility 요구를 Stage 1에 포함했다.
- Project coverage: 제품 방향, 세계/캐릭터, 전투, 성장/콘텐츠, App Flow, UX/platform, visual/audio, implementation delta를 inventory 대상으로 포함했다.
- Sequence coverage: `기획완료 후보 → 사용자 명시 기획 완료 → 검수완료 → 이미지 생성`; 이미지가 앞 두 완료의 선행조건이 아님을 명시했다.
- Evidence boundary: CI/문서 검증을 human/device/runtime evidence로 승격하지 않는다.
- Placeholder scan: `TBD`, `TODO`, `implement later` 없음.
- Scope control: 제품 runtime 변경 및 Build 승인을 포함하지 않는다.
