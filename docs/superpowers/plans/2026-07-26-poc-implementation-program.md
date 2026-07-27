# PoC Implementation Program

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 승인된 주요 비무 1~5 PoC를 현행 Godot 전투 기반 위에 구현하고, UI·UX·사운드 에셋을 검증 가능한 절차로 통합한다.

**Architecture:** 구현을 런타임 전투 기반, 캠페인·성장, 표현·에셋의 세 독립 workstream으로 분리한다. planning JSON은 빌드 도구가 검증·변환하고 Godot 런타임은 생성된 `data/runtime/` 카탈로그만 소비한다. 각 workstream은 별도 RED/GREEN과 리뷰를 통과한 뒤 통합 branch에서 결합한다.

**Tech Stack:** Godot 4.x, GDScript, JSON, Python unittest, Godot headless tests, GitHub Actions, Windows 수동 검증.

## Global Constraints

- 프로젝트 코어: 1대1, 10칸, 4/7, 비공개 3/3/4, 공개 정보 AI, 거리·합·대응·중단·복기.
- PoC 범위: 주요 비무 1~5와 네 구간의 중간 노드 2~3개씩.
- 주요 비무 6~10, 스테이지 2·3, 히든 전투는 구현하지 않는다.
- 기본 절초 3종은 시작부터 사용 가능하다.
- 무공별 절초는 해당 무공 10성에서 해금한다.
- 주요 비무 5 진입 전 집중 32+노드 6 또는 자유 24+고효율 노드 14로 38포인트 도달이 가능해야 한다.
- 패배 재도전은 전투 직전 `RunState` 복원, 같은 seed, 영구재화 1→2→3 비용, 다른 전투 진입 시 초기화다.
- `[필중]`은 실제 회피를 우회한 유효 타격마다 1스택 소비한다.
- planning JSON은 source-only이며 Godot runtime에서 직접 읽지 않는다.
- 기존 `restart_combat()`은 개발용 완전 재시작으로 보존하고 유료 재도전과 결합하지 않는다.
- 에셋은 컨셉·gap map → 최신 검색 → 라이선스 평가 → 부족분 생성 → 통합 검증 순서다.
- 출처·라이선스가 불명확한 에셋은 사용하지 않는다.
- Godot·Windows·접근성·성능·사람 증거를 서로 대체하지 않는다.

---

## Workstream Order

1. `2026-07-26-poc-runtime-foundation-implementation-plan.md`
2. `2026-07-26-poc-campaign-progression-implementation-plan.md`
3. `2026-07-26-poc-ui-audio-assets-implementation-plan.md`
4. 통합 Full Validation과 STEP 14 준비

### Task 1: 구현 branch와 기준선

**Files:**
- Read: `docs/decisions/2026-07-26_POC_PLANNING_BASELINE.md`
- Read: `docs/decisions/2026-07-26_FULL_ADVERSARIAL_REVIEW_LOOP.md`
- Read: `docs/superpowers/specs/2026-07-26-ui-ux-audio-asset-pipeline-design.md`
- Existing branch: `codex/p0-poc-runtime-foundation`

**Interfaces:**
- Consumes: PR #45의 `검수 완료` 전환 head.
- Produces: uncommitted planning edit가 없는 isolated implementation worktree.

- [ ] **Step 1: Create an isolated worktree**

```bash
git fetch origin
git worktree add ../Ten-Paces-Hidden-Moves-p0 codex/p0-poc-runtime-foundation
cd ../Ten-Paces-Hidden-Moves-p0
```

- [ ] **Step 2: Record baseline evidence**

```bash
python -m unittest tests.test_poc_planning_data -v
python tools/check_poc_planning_data.py --root .
godot --headless --path . --quit
```

Expected: planning 24/24 PASS, planning validator PASS, project parses without script errors.

- [ ] **Step 3: Commit no product changes**

Do not create an empty commit. Store the command outputs in the first implementation PR body.

### Task 2: Runtime foundation workstream

**Files:**
- Plan: `docs/superpowers/plans/2026-07-26-poc-runtime-foundation-implementation-plan.md`

- [ ] Execute the runtime plan in order.
- [ ] Request code review after build-time catalog/RunState contracts, before combat resolver replacement.
- [ ] Require all legacy combat tests and new P0 tests to pass.
- [ ] Open a draft PR against the planning head or merged `main`, whichever is current at execution time.

### Task 3: Campaign and progression workstream

**Files:**
- Plan: `docs/superpowers/plans/2026-07-26-poc-campaign-progression-implementation-plan.md`

- [ ] Start only after runtime catalog loader and `RunStateStore` interfaces are merged into the implementation branch.
- [ ] Implement only the first five major duels and four node gaps.
- [ ] Verify reward ownership, 38-point routes, mastery unlock, and one-time reward commit.

### Task 4: UI, audio, and asset workstream

**Files:**
- Plan: `docs/superpowers/plans/2026-07-26-poc-ui-audio-assets-implementation-plan.md`

- [ ] Start the event matrix and gap map after runtime event IDs are stable.
- [ ] Search current stores and libraries at execution time; record URLs, prices, versions, licenses, and acquisition dates.
- [ ] Generate only items classified `GENERATE` after candidate review.
- [ ] Keep text, shape, and silent fallbacks operational.

### Task 5: Integration review

**Files:**
- Modify: `.github/workflows/full-validation.yml`
- Modify: `docs/08_TEST_CHECKLIST.md`
- Create: `docs/decisions/2026-07-26_P0_IMPLEMENTATION_EVIDENCE.md`

- [ ] **Step 1: Run static and unit checks**

```bash
python -m unittest tests.test_poc_planning_data -v
python tools/check_poc_planning_data.py --root .
```

- [ ] **Step 2: Run Godot contract tests**

```bash
godot --headless --path . --script res://tests/verify_p0_runtime_adapter.gd
godot --headless --path . --script res://tests/verify_p0_sequential_clash.gd
godot --headless --path . --script res://tests/verify_p0_run_retry.gd
godot --headless --path . --script res://tests/verify_p0_campaign_flow.gd
godot --headless --path . --script res://tests/verify_p0_ui_event_contract.gd
```

Expected: every script exits 0 and prints its explicit PASS token.

- [ ] **Step 3: Run Windows smoke flow**

Launch the exported Windows build and verify: start manual selection → duel 1 → node selection → defeat → paid retry → victory reward → duel 2 transition.

- [ ] **Step 4: Verify protected scope**

```bash
git diff --name-only origin/agent/poc-planning-baseline-and-legacy-audit...HEAD
```

Expected: no stage 2·3 or hidden content implementation; no unlicensed asset files.

- [ ] **Step 5: Record evidence and return to REVIEW**

Set `phase: REVIEW_IN_PROGRESS`, list PASS/FAIL/NOT_RUN separately, and never mark human validation complete without observed sessions.
