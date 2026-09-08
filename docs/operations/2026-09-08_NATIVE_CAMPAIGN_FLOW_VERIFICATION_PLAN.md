# Native campaign flow verification

> Execute with subagent-driven-development, one bounded test implementation and independent review. Latest user continuous implementation/testing authority applies; no new gameplay meaning is introduced.

Goal: verify the existing ten-duel campaign through actual native Control input and production shell/bridge transitions, rather than mirroring resource/reward handoff in a test.

## Evidence and feasibility

Current source: merged PR325 `12fe75ca795c9af640a58eff975e2a6cbe02888d`.
Existing ten-case frontal reveal and ten-case route benchmark packets were fully reread on September 8. Their decision dimensions (3/3/4 reveal, public information, four next-node choices) are unchanged. This package adds verification only, not a new design dimension; no new ten-game study claimed.
Official input refresh: https://docs.godotengine.org/en/stable/classes/class_input.html and https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html . ADOPT event propagation through Input.parse_input_event; REJECT action_press as evidence of GUI event delivery. Headless generated input is not a physical keyboard/Human pass.
FEASIBLE: current shell has real setup/primary/reward/route buttons; bridge has native dock, timing, progress and review controls. Existing public-policy probe is reusable test logic. Partial risk: timing/targeting/animation input may reveal a consumer mismatch, which must be reported and reproduced rather than bypassed.

## Global Constraints

No product path mutation in this test task. No health, outcome, resource, mastery, reward, hidden enemy plan or run progression injection. Do not call run.advance/mark_combat_finished or resolve_bundle directly to move the campaign. No mirrored resource handoff, ultimate reservation, reward receipt construction. Actual native controls must invoke existing production consumers. Public-policy selection may read own state/registry and public distance only. Use a deep copied combat state when reusing the existing policy because its test reservation mutates its argument. No copied full policy module. Preserve existing tests, assets, worktrees, protected baseline and candidate statuses. Report native generated-input evidence separately from Windows visible, physical input, Human, Android and release.

## Task 1: Native input campaign regression

Files: create tests/probe_native_ten_duel_campaign.gd; optional focused test helper only if needed to reuse existing tests/probe_sequential_ten_duel_campaign.gd without duplicating policy. Add passing regression to existing product CI only after locally passing. Record exact commands/failures/limits in docs/operations/2026-09-08_NATIVE_CAMPAIGN_FLOW_VERIFICATION_REPORT.md.

Instantiate scenes/run/vertical_slice_shell.tscn. Existing probe STARTERS/public scoring and route/reward preference supply the same policy, not gameplay truth. Prefer extending its script and overriding run_probe so no second SceneTree is created. Do not call its resolver/run advance methods. Drive visible enabled Button with grab_focus then pressed/released InputEventAction ui_accept through Input.parse_input_event; await frames. Check focus, enabled and visible prerequisites; assert expected state transition after each action. Start through title button if reachable; explicitly disclose any start method needed. Use source tabs/manual selector/technique buttons for actions (action_id metadata), production targeting buttons if required, progress button twice (plan lock then execute), actual review continuation. A public fast/reduced-motion setting can be toggled through its button, never write internal flags. Wait bounded real frames/time for review, failing with screen/bundle/input diagnostics on stall. Do not force results to make it green.

Before full campaign, test helper rejects a disabled button (no activation) and never counts a failed activation as progress. Then require 10 terminal successes, 10 earned rewards,36 route choices, real mastery techniques/base ultimate use, exact resources between production shell and next bridge, no SCRIPT ERROR. Reward/route selection uses actual visible buttons and metadata/text; no direct selection APIs. Receipt zero selection remains native CTA. Preserve ordinary animation defaults except publicly toggled settings, record used mode. Bounded max270 bundles/duel and a practical global wall timeout; fail closed with diagnostics.

If existing consumer prevents progression, keep a truthful failing regression and report the smallest grounded product fix separately; do not silently bypass input or expand protected scope. If UI policy differs in an innocuous scheduling way, diagnose using public trace and record adjustment, no hidden information. Test-only helper implementation follows TDD where behavior is added; full campaign may itself be first failure evidence. Commit owned files only. No remote/editor/subagents.
