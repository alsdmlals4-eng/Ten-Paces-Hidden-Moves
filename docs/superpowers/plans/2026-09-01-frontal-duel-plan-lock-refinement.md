# 정면 결투 행동계획 잠금 · 구현 계획

> **Execution note:** Execute this plan through the project-local Build route. No core rule, resolver number, AI-information boundary, save schema, raster asset, or platform contract changes are permitted.

**Goal:** 현재 묶음의 모든 행동을 배치한 뒤 플레이어가 먼저 `행동계획\n잠금`으로 배치를 닫고, 같은 작은 CTA에서 `N수 실행`으로 해상도를 시작하게 한다.

**Architecture:** `CombatBoardPreviewAuto`가 presentation-only `plan_locked` 상태를 소유한다. `CombatProgressButton`은 잠금 전/후 copy와 tooltip만 표시한다. `ActionSelectionDock`과 placement controller는 plan-lock 상태에서 입력을 비활성화한다. resolver에는 잠긴 기존 placement를 그대로 한 번만 전달한다.

**Tech Stack:** Godot 4.7.1, GDScript, existing action-placement controller, Godot headless regression scripts, Hera-compatible runtime evidence.

---

## Scope and guardrails

- Retain `3 → 3 → 4` bundle structure, public-only AI, observation type-only boundary, current auto target for all non-move actions, and existing final-locked assets.
- Movement remains the only intent picker; this package never adds attack direction, board tile selection, or future reveal data.
- No JSON card values, save data, new raster image, or user-facing combat rule changes.
- The locked plan is presentation/input state only. The second CTA activation still reaches the same resolver transaction exactly once.

## Task 1 — Write the red product regression

**Files:**

- Create: `tests/verify_frontal_duel_plan_lock.gd`

**Steps:**

1. Instantiate the product combat scene at 1440×900 and fill its first bundle through the real `ActionSelectionDock`.
2. Assert that a complete bundle shows `행동계획\n잠금`, fits the compact progress control, and remains disabled until all current actions are ready.
3. Trigger the CTA once and assert: no resolver invocation, `presentation_state == "plan_locked"`, source/action placement controls are locked, and the CTA reads `3수 실행`.
4. Trigger the CTA a second time and assert exactly one resolution starts and source controls remain locked while presentation runs.

**Run (expect failure before implementation):**

```powershell
& $godot --headless --path . --script res://tests/verify_frontal_duel_plan_lock.gd
```

## Task 2 — Implement the local plan-lock state

**Files:**

- Modify: `src/ui/combat_progress_button.gd`
- Modify: `src/combat/combat_board_preview_auto.gd`
- Modify: `src/ui/action_selection/action_selection_dock.gd`

**Steps:**

1. Add explicit `plan_locked` presentation state and expose it in progress snapshots.
2. Render `행동계획\n잠금` before confirmation and current-bundle `N수 실행` only after confirmation; keep the control inside its current timing-row bounds.
3. Route the first completion CTA to the plan-lock transition; route only the second activation to the existing superclass resolution path.
4. Lock dock tabs/cards, linked placement actions, and timing interactions during plan lock, then reset state at restart and when a next bundle opens.

## Task 3 — Turn green and verify unchanged contracts

**Run:**

```powershell
& $godot --headless --path . --script res://tests/verify_frontal_duel_plan_lock.gd
& $godot --headless --path . --script res://tests/verify_combat_action_selection_integration.gd
& $godot --headless --path . --script res://tests/verify_combat_board.gd
& $godot --headless --path . --script res://tests/verify_combat_presentation_liveness.gd
& $godot --headless --path . --script res://tests/verify_ink_paper_combat_presentation.gd
& $godot --headless --path . --script res://tests/verify_phase2_observation.gd
python -m unittest discover -s tests
```

**Expected:** plan lock cannot alter resolver data or unlock source cards; auto targeting, observation, sequential reveal, card fields, and ground anchors all continue to pass.

## Task 4 — Runtime evidence and cleanup

1. Use the active project live-editor route if available; otherwise record why only scoped headless runtime evidence exists.
2. Capture the real product scene at 1280×800 and 1440×900 if a project-bound runtime capture route is available. Record machine evidence separately from Human/Android/accessibility/release claims.
3. Remove only exact disposable test caches or own merged worktree/branch after verifying tracked sources and active consumers are unaffected.
4. Re-read diff, five adversarial passes, commit, push, PR, current-head CI, merge when authorized, and post-merge main readback.
