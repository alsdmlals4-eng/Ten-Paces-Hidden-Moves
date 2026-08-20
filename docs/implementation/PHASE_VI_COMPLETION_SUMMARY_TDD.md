# Phase VI · Completion Summary · TDD Contract

- Base main: `b9d2939ae953daa3bdf3ae8897b2641295cc4db3`
- Handoff phase: `Phase VI · Completion Summary`
- User continuation approval: `진행해`
- Status: `TDD_RED_PENDING_CI`

## Required behavior

The first five-duel Vertical Slice completion state must preserve and summarize only player-visible run history:

1. exactly five Duel rows with actual opponent identity and outcome;
2. the top 2–3 Review cause codes derived from retained resolved Review summaries;
3. exactly five confirmed Result reward receipts;
4. exactly eight Route receipts;
5. one or two most-grown manuals based on actual accumulated focused training;
6. one short recurring-peer closing beat;
7. a structured functional Completion UI/snapshot that remains explicitly non-final visual evidence.

## Protected boundaries

The Completion summary must not:

- diagnose a player personality/type;
- recommend a correct build or next-run answer;
- expose AI numeric weights, selector seed, hidden current plans, or internal behavior keys;
- change combat formulas, Route balance, reward values, or AI information authority;
- claim Human fun/readability/final visual PASS.

## TDD order

1. Add `tests/verify_vertical_slice_completion_summary.gd` and CI step.
2. Observe RED because five-Duel history / Completion model / Completion shell binding do not yet exist.
3. Implement the minimum retained Duel history and read-only Completion model/UI needed for the test.
4. Re-run the dedicated Vertical Slice workflow, Base v9 gate, Full Validation, and Product Gate.
5. Only after fresh GREEN evidence may Phase VI be merged.
