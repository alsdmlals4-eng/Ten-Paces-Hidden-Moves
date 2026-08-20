# First Five-Duel Vertical Slice · Phase I Build Approval

- Gate: `TEN-DEC-20260820-PC-FIRST-VERTICAL-SLICE-IMPLEMENTATION-GATE-01`
- Planning Complete: `TEN-DEC-20260820-VERTICAL-SLICE-PLANNING-COMPLETE-01`
- Visual/UX: `TEN-DEC-20260820-VISUAL-UX-SYSTEM-01`
- Approved on: `2026-08-20 KST`
- Approval source: user instruction `이미지 생성 외 작업을 진행하자`
- Authority level: `SCOPED_PC_FIRST_VERTICAL_SLICE_PHASE_I`

## Approved scope

This build may implement Phase I of `docs/16_VERTICAL_SLICE_IMPLEMENTATION_HANDOFF_PLAN.md`:

1. a data-independent RunState/flow controller for `Main → Setup → Intro → Briefing → Combat → Review → Result → Route → next Briefing → Completion`;
2. exactly five duel visits and exactly eight inter-duel Route visits;
3. Review and Result as separate states;
4. no Route after Duel 5;
5. a shell/bridge around the existing CombatBoardPreview without rewriting combat resolution rules;
6. automated headless verification for the new flow;
7. later Phase-I UI shell work may use structured text/frames and existing approved assets while final visual reference remains pending.

## Protected invariants

- logical 10-cell battlefield;
- `3 → 3 → 4` combat bundles;
- hidden current plans;
- public-state-only enemy AI;
- distance / clash / response / interruption / review;
- player-only `[관찰]` authority;
- existing ten martial manuals;
- Combat Review overlay / Duel Result separate Scene / Route separate Scene boundary.

## Explicitly not authorized by this build

- changing combat formulas, AI hidden-information access, manual effects, balance seeds, or save semantics beyond the new run shell;
- Windows/Android Adapter implementation;
- Android physical-device completion;
- Human fun/readability PASS;
- release readiness claims;
- new image generation or promotion of the current generated concept to product asset.

## Evidence ceiling

- new RunState headless verification: required;
- existing PR / Full / Product Gate validation: required once runtime files are introduced;
- Windows visible local usability: `NOT_RUN`;
- Android physical device: `BLOCKED_UNVERIFIED`;
- Human validation: `NOT_RUN`;
- final visual approval: `USER_REFERENCE_PENDING`.
