# HTML Technique1 Playable PoC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a browser-playable, deterministic 1v1 combat PoC that exercises all six approved 3-star Technique1 contracts, the ten basic actions, sequential clashes, observation, and ultimate momentum.

**Architecture:** Use dependency-free ES modules. `engine.js` owns immutable-ish combat state and deterministic resolution; `ai.js` plans from public state before player editing; `ui.js` renders and dispatches commands without calculating combat outcomes. Contract data is centralized in `contracts.js` and tested with Node's built-in test runner.

**Tech Stack:** HTML5, CSS3, JavaScript ES modules, Node.js built-in test runner, Playwright/Chromium smoke test.

## Global Constraints

- PC-first 16:9 browser layout; no build step or external runtime dependency.
- Ten-tile board; player starts at tile 4, enemy at tile 7.
- One round is split into 3/3/4 timing bundles and only the current bundle is editable.
- Player has ten basic actions; enemy cannot use Observation.
- Both sides can use all six approved Technique1 actions.
- Ultimate momentum is separate from stamina/internal, ranges from 0 to 5, and clash gain is capped at +1 per attack action.
- Multi-slot costs are paid on placement and refunded only when removed before commit; ultimate reservation follows the same pre-commit refund boundary.
- Martial-technique movement is deterministic; no post-commit choice prompts.
- UI and presentation may only consume engine events; they never recalculate damage or movement.
- S/A/B/C grade calculation is excluded; show raw metrics only.

---

### Task 1: Contract data and deterministic state

**Files:**
- Create: `web/technique1-poc/src/contracts.js`
- Create: `web/technique1-poc/src/engine.js`
- Test: `web/technique1-poc/tests/engine.test.mjs`

**Interfaces:**
- Produces: `createInitialState()`, `getAction(id)`, `placeAction(state, side, actionId, options)`, `removePlacedAction(state, side, anchor)`, `resolveBundle(state, enemyPlan)`, `startNextBundle(state)`.

- [x] Write failing tests for the six Technique1 formulas, resource reservation/refund, deterministic movement, sequential clash, non-consuming defense, interruption, observation carry, and momentum cap.
- [x] Run `node --test tests/engine.test.mjs` and confirm RED failures are missing exports/behavior.
- [x] Implement contract definitions and engine behavior minimally.
- [x] Run the test suite and confirm all tests pass.

### Task 2: Public-state deterministic AI

**Files:**
- Create: `web/technique1-poc/src/ai.js`
- Test: `web/technique1-poc/tests/ai.test.mjs`

**Interfaces:**
- Consumes: `ACTIONS`, `getCurrentBundleRange(state)`, public actor resources and positions.
- Produces: `planEnemyBundle(state, seed)` returning `{ actions, hash, categories }`.

- [x] Write failing tests proving the same public state/seed produces the same plan and player-plan changes do not alter an already locked plan.
- [x] Implement a seeded PRNG, legal-candidate filtering, and weighted selection that prioritizes untested Technique1 actions without reading player slots.
- [x] Run AI and full engine suites.

### Task 3: Playable planning and battle UI

**Files:**
- Create: `web/technique1-poc/index.html`
- Create: `web/technique1-poc/styles.css`
- Create: `web/technique1-poc/src/ui.js`
- Create: `web/technique1-poc/src/main.js`

**Interfaces:**
- Consumes: engine state/events and AI plan.
- Produces: action cards, auto-placement, slot removal, commit/resolve controls, board/HUD, replay log, validation dashboard, test controls.

- [x] Build semantic HTML regions for HUD, board, timeline, action dock, controls, replay, and validation.
- [x] Implement rendering with keyboard-operable buttons and no hover-only information.
- [x] Wire action placement, direction variants, removal/refund, AI lock/reveal, resolution playback, next-bundle progression, and reset.
- [x] Add reduced-motion, mute, volume, event-step, 1x/2x/skip controls.

### Task 4: Visual identity, motion, and validation visibility

**Files:**
- Modify: `web/technique1-poc/styles.css`
- Modify: `web/technique1-poc/src/ui.js`

**Interfaces:**
- Consumes: typed resolution events.
- Produces: deterministic CSS animation classes and textual fallbacks.

- [x] Add ink-wash dusk styling, ten-tile readability, distinct silhouettes, resource bars, linked multi-slot blocks, and source tabs.
- [x] Map each Technique1 to a distinct motion grammar and use existing repository assets via relative paths when available, with CSS fallback silhouettes.
- [x] Keep all result information visible when reduced motion is enabled.

### Task 5: Automated and browser verification

**Files:**
- Create: `web/technique1-poc/package.json`
- Create: `web/technique1-poc/tests/ui-smoke.mjs`
- Create: `web/technique1-poc/README.md`

**Interfaces:**
- Produces: reproducible test commands and local launch instructions.

- [x] Run Node engine and AI tests.
- [x] Serve with `python -m http.server 8000` and run Playwright smoke tests in Chromium.
- [x] Verify no console errors, action placement works, a bundle resolves, momentum test control enables ultimate reservation, and reset restores the initial state.
- [x] Record exact validation commands and known human-validation limits in README.
