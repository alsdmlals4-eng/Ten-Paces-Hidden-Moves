# Combat-layout final independent source review

```yaml
review_mode: READ_ONLY_FINAL_PACKAGE_REVIEW
reviewer_context: REUSED_AGENT_CONTEXT_NOT_FRESH_CONTEXT
worktree: C:/Users/user/Documents/GitHub/Ninza/Ten-Paces-Hidden-Moves/.worktrees/combat-layout-20260909
implementation_base: 544fcbbaff0448edf265e381c70ad3d48fd61b7b
protected_baseline: 477697842bf14d95e670f01b0fe815e384b53658
reviewed_head: eda26a97f25a931ac02ba739d5c4921720512d41
source_identity: EXACT_HEAD_FOR_THE_RETAINED_TEN_PATHS
decision: TEN-DEC-20260909-COMBAT-LAYOUT-CORRECTION-01
scope: THREE_PRODUCT_OWNERS_PLUS_SEVEN_TEST_WORKFLOW_OWNERS
reviewer_product_test_canon_mutation: NONE
reviewer_godot_import_native_full_suite_capture_process_operation: NOT_RUN_BY_EXPLICIT_SCOPE
review_verdict: ACCEPT_SOURCE_SCOPE_FOR_CONTROLLER_CAPTURE_AND_CLOSEOUT_WITH_MACHINE_EVIDENCE_CEILING
blocker: NONE_FOUND_IN_DECLARED_SUPPORTED_VIEWPORTS
```

## Scope, authority, and source identity

I fresh-read G's `AGENTS.md`, the project workflow router and routed verification/accessibility/implementation instructions, the current layout Decision, the complete ratified implementation plan, current execution report, current mutable owners, all three task implementation reports, both earlier bounded independent reviews, the complete `544fcbb..eda26a97` retained diff, and the relevant unchanged consumers. This is a source/review pass, not a replacement for controller-owned runtime capture, protected delivery, or Human review.

`git diff --name-status 544fcbb..eda26a97` contains exactly the ten ratified paths (783 additions / 101 deletions): three product owners, five native verifiers, one Python wiring test, and one existing workflow. The read-only retained-path comparison against `HEAD` exited `0`: current dirty state is controller/canon documentation plus imported `.import`/`.uid` environment state, not a post-commit edit to any retained product/test/workflow path.

| Retained path | SHA-256 at reviewed `eda26a97` |
|---|---|
| `.github/workflows/validate-ten-manual-product-gate.yml` | `948EDC95C3BBC5A1E8465922262E8ECEA01F86336EDF196D99A0399CF2102B53` |
| `src/combat/combat_board_preview.gd` | `791891121D2D13301AF0A0B5E6F50E47951702296FA5BE86D5D2938E942D1A8D` |
| `src/combat/combat_board_preview_auto.gd` | `BF838422E70BB595EBF9E40021DFE253B73136AE2A9A2CAEBA4A843EE96BDC2A` |
| `src/combat/combat_character_placeholder.gd` | `17EEA94F124336617C6046AD1F6FD49084F005ADD64148439EDFD03E18F31FF4` |
| `tests/test_combat_feedback_correction.py` | `9BCCDAFC520E58CC71B6850D9E25B0B4C99146F79BA5547CAB67363589B66BDC` |
| `tests/verify_actor_ultimate_presentation.gd` | `C42D6A4B19DF25E0865130E56E7A345D3AA9E6C5E22FCCE8B889F08CCFB470A7` |
| `tests/verify_combat_action_reveal.gd` | `605A08DF2B47AD665EB771A6147F7B01E4564216E29C492AEEE189B9932C8280` |
| `tests/verify_combat_layout_accessibility.gd` | `94EA2A95702FEFBC36A7C8B9747B4114E18D65E220AC468059A771114E093D56` |
| `tests/verify_frontal_duel_screen_partition.gd` | `AA3E72F24D3886637CD83A8633DA046EA0D98F4F65B07552B2FE97793BD1956C` |
| `tests/verify_inline_combat_results.gd` | `0A4456812F0E131D527F6B7CD76F4828C347A8A259407DFA9E68BCC944A7CC3B` |

`git diff --check 544fcbb..eda26a97` produced no whitespace finding. A scoped unchanged-consumer comparison (`data/`, `scenes/`, assets, `project.godot`, run/domain/AI/store paths, overlay, floor and banner owners) exited `0` for no diff.

## Five actual full-scope review loops

These are five separately performed whole-package reviewer passes. They are not retroactive claims that the two earlier Task1/Task2 bounded reviews alone satisfied the project ledger, nor a claim that runtime/Human delivery is complete.

### Loop 1 — authority, boundaries, exact path inventory

- Reconciled the Decision's stage-only background/banner, shared floor, initial-only 42% separation, 52% cap, single CTA/current-only reveal, 3/3/4, and unchanged domain/save/asset boundaries with plan sections 1–6 and the actual ten-path diff.
- Confirmed the three sequential source commits: `fecc72da` Task1 (five paths), `af25b3b7` Task2 (five paths), and `eda26a97` Task3 (two paths); their union is the ratified ten-path package, with no source drift after the Task3 commit.
- Result: no unauthorized product path, new scene/resource/asset, dependency, core-rule, AI, save/schema, or workflow-policy expansion was found.

### Loop 2 — geometry, renderer, background/floor, and MOVE consumers

- Read the actual base/auto/renderer code and unchanged `BattleBackground`, `DuelForegroundBanner`, board scene, ten-manual subclass, title and shell consumers. The base now binds planning `duel_rect`; auto applies the final active rect to background/banner/tint; the unrelated full-screen title/shell consumers are unchanged.
- Verified that the renderer's cached alpha-used rect feeds both `_sprite_rect_local()` drawing and the local/global four-corner occupied-ink bounds. Dogyeom is still enemy-only (`candidate_id == "slot1_dogyeom"`); player art is not redirected. The measured height, mirroring, parent transform, source floor, frontal anchor pair, final-rect `0.01` comparison, same-size MOVE preservation, and genuine geometry-change-only MOVE snap are present in the intended owners.
- The six protected source asset bytes read back exactly as prescribed: player `383FD9A62DE43D1B9C5C6C38F1AD9D537D8F088C08E4F25E23E974B87DC08864`; masked `0841505D275CA970D7D085D7AB206788276517D2290A63960D829E657DFBE17F`; Dogyeom `064A8772406C743BBE6B252C138B4333C88B00B90A0BA905CCE9EA18773539C9`; VFX `0859C714728608744B3F016E03C02F7B0E18D86B0B0CED191A2D5EC25CE2553F`; courtyard `608D67E244AB3BC0C579FF04B359682A20C5189236117FF5390B0D7182DD092C`; banner `56667318D441F7E74ACCFC08F7038500E5D3B313BC68A15387F9C3C62608D7E2`.
- Result: no source-level contradiction with the approved stage/floor/renderer contract or an unintended asset/source-owner mutation was found.

### Loop 3 — execution lanes, text, VFX, and interaction lifecycle

- Traced all lane consumers: base four-corner conversion at `combat_board_preview.gd:1645-1675`; actual transformed actor feet, peak-safe fit, boolean placement, and retained visible-event lifetime at `:1709-1814`; auto's planning clear/execution lane calculation at `combat_board_preview_auto.gd:333-380`; unchanged overlay deferred child settlement at `combat_action_reveal_overlay.gd:266-321`.
- Both ordinary/clash and ultimate show callers return before visibility/tween start when `_place_feedback_vfx()` is false. Resize repositions the retained VFX only; it does not invoke animation or sound. Clear kills the old tween and clears the retained event/kind. No new `_process`, timer, `await`, image load, resource load, signal observer, or growing product history appears in the three-product diff.
- Reviewed the actual CTA/current-only, real Peng and legacy ultimate, long Korean copy, muted/reduced/skip, visible resize and invalid-space tests. The long-copy test checks settled descendants and minimum heights rather than overlay metadata alone; the ultimate test observes the existing tween's `step_finished(0)` boundary instead of manufacturing 1.08.
- Result: no loss of current-only information boundary, VFX resurrection/audio replay route, non-finite supported geometry, or direct caller boolean-ignore defect was found.

### Loop 4 — domain, regression, and CI wiring re-attack

- Rechecked that no `data/`, resolution engine, AI, manual definitions, codec/store, campaign, scene, input transaction, or asset source path is changed. The real CTA tests retain one resolve count and compare skip/resize outputs to a non-skipped ordinary reference; the inline refinement requires exact visible `[4,5,6]` membership and a positive count before checking visible-slot intersections.
- Read Task1 hardening records: the stopped-real-tween negative probe has both a 600-frame/5-second ordinary bound and a three-frame/deadline-zero negative proof; direct visual dependency tests preserve stage/baseline/live MOVE/domain state. Read Task2 final logs: action reveal, ultimate, accessibility, controls, SFX, and terminal markers are all present. The 960×640 long-copy measurement is real but tight: `163.2×168` player callout/minimum `68×168`, `576×34` result, and `618.24×64` label.
- Read Task3 RED/GREEN logs and workflow diff. The Python guard verifies exact `automated-product-evidence` boundaries, exact post-import `run:` lines, and the actual `push` filter; workflow adds only two path-filter entries and two native steps, without changing action pins, permissions, timeout, job identity, or concurrency.
- Result: no domain/state mutation, vacuous inline assertion, CI path spoofing, or missing specified native workflow step was found. Actual remote CI execution remains unrun.

### Loop 5 — failure boundaries, long-term cost, mutable canon, and evidence ceiling

- Re-read the current execution record and mutable owners after source identity/hash readback. Imported sidecars remain environmental state; dirty current docs are controller-owned. `ACTIVE_CONTEXT.md` still describes this package as pre-RED/GREEN, while the execution record currently stops after Task3: this is the known pending lifecycle/499-final/runtime-capture closeout, not a product-source defect and not a reason to silently call delivery complete.
- The only retained runtime cost is bounded cache/Rect2/corner arithmetic on existing callbacks. Static diff inspection found no added process loop, timer/await, resource/image load, observer, or unbounded history in product code. The exact 960 lower lane remains a machine-fit boundary, not a claim of general localization or Human readability.
- I did not rerun operating validation, Godot, import, native scripts, full pytest, capture, process control, or CI because this final review explicitly forbids them. Controller-reported full regression is `499 PASS`, measured `316.3693454s`; it is reported here as controller evidence, not an independently replayed run.
- Result: no blocker emerged. The package is suitable for controller-owned capture/receipt/final canon update, subject to the evidence limits below.

## Findings and residual risks

### No blocking source finding

No P0/P1 product defect was found in the committed ten-path candidate. Earlier Task1 F1/F2 are closed in the committed source, and prior Task1/Task2 focused reviews remain historical bounded evidence rather than being misrepresented as this final whole-package conclusion.

### R1 — invalid-lane coordinator is a nonblocking coverage seam

`combat_board_preview_auto.gd:363-378` invokes `_apply_presentation_layout_lanes(...)` but does not branch on its `false` result before recording `_last_applied_active_duel_rect`. The base seam correctly clears VFX and returns `false`; the two show callers correctly honor that. All declared supported sizes generated valid lanes in the existing native evidence, and no capture/runtime failure currently establishes a user-visible defect.

This is nevertheless narrower than the plan wording that a successful final-rect baseline follows complete actor/stage/lane application. Existing invalid-lane tests invoke the base method directly; they do not prove that an auto-layout attempt with an invalid lane node/rect preserves the previous successful baseline and live MOVE. Treat it as a nonblocking hardening/coverage item for any future unsupported-viewport or missing-lane-node contract, not as evidence that supported 960/720/800/1080 flows fail. It must not be closed by hiding required text.

### Evidence ceiling and required controller closeout

- Existing focused machine evidence is hash-bound historical evidence: Task1 final hardening markers `FRONTAL_DUEL_SCREEN_PARTITION_VERIFY_OK`, `FRONTAL_DUEL_PLAN_LOCK_VERIFY_OK`, `INLINE_COMBAT_RESULTS_PASS`; Task2 final markers `COMBAT_ACTION_REVEAL_VERIFY_OK`, `ACTOR_ULTIMATE_PRESENTATION_VERIFY_OK`, `COMBAT_LAYOUT_ACCESSIBILITY_VERIFY_OK`, controls/SFX/terminal OK; Task3 module and board-contract GREEN. I did not rerun them in this review.
- Controller capture is pending in the active editor. It still must bind a pre-producer receipt and actual engine/project/session identity, and record 720/800/1080 planning/ordinary action/impact/movement/next planning, Peng peak/recovery, enemy Dogyeom with both actor roles, long copy, mute/reduced/skip/visible resize, and stage/HUD/background/banner/tint/ink/feet/lane/input facts. Helper geometry cannot substitute for imagery.
- Exact-head remote CI, protected delivery, merge/main readback, current lifecycle document updates, Human readability/preference, physical input/audio, accessibility users, Android/device, rights, release, and performance are **NOT_RUN** here. No Human/Blueprint/release PASS follows from this review or the reported pytest result.

## Final decision

`ACCEPT_SOURCE_SCOPE_FOR_CONTROLLER_CAPTURE_AND_CLOSEOUT_WITH_MACHINE_EVIDENCE_CEILING`.

The committed retained source is internally consistent with the approved bounded correction and its intended CI wiring. Proceed with the controller-owned runtime capture and the already-expected lifecycle/499 final canon closeout; do not represent this as remote CI, post-merge, Human, accessibility-user, device, rights, or release completion. Keep R1 visible as a future hardening seam unless an actual supported-path capture or verifier turns it into a demonstrated product failure.
