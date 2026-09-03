# Human Blueprint Additive Recovery Design

## Revision 2 · 2026-09-03

The user approved an incremental expansion rather than a replacement. `FM` is
interpreted here as **Flow Map**. The larger publication must therefore retain
the original 36-page sequence and the first additive visual layer, then add
the following reader-facing, actionable surfaces:

- a project goal and system map that makes purpose, current state, reason, and
  expected effect legible without inventing a new game rule;
- a staged `3수 → 해결 → 3수 → 해결 → 4수` Flow Map and the preparation /
  combat wireframes that own each transition;
- a case-status board that separates `IMPLEMENTED`, machine runtime capture,
  `PARTIAL`, and `NOT_RUN` rather than treating a polished PDF as product
  completion;
- an image-production board that demonstrates `whole scene → separated
  candidate modules → composition / Godot runtime evidence` while preserving
  approved module locks and the older whole-scene candidate's superseded
  provenance.

The whole-scene exploration stays a provenance/reference item. It is not
re-promoted, and this document-only package does not regenerate or replace the
approved background, banner, player, or opponent modules.

## Goal

Keep every page and documented subject from the 36-page human Master GDD while adding the current frontal-duel visual, interaction-flow, card, and reveal wireframes. The replacement must be a larger human-facing derived publication, never a ten-page substitute.

## Root cause

`exports/ten-paces-hidden-moves_MASTER_PRODUCTION_GDD_20260829.pdf` is the repository's 36-page `HUMAN_MASTER_GDD_PDF`. The later 10-page `output/pdf/TEN_PACES_FRONTAL_DUEL_ACTION_FLOW_BLUEPRINT_2026-09-02.pdf` was a useful focused action-flow artifact, but it was incorrectly presented as the final human blueprint. Its narrower scope did not contain the 36-page source's vision, journey, system map, AI, content, platform, QA, risk, and register layers.

## Approved design

Create a new 52-page `HUMAN_MASTER_GDD_PDF` publication.

1. A new current cover states the current source revision, the evidence ceiling, and the additive rule.
2. Every page from the existing 36-page Master GDD is copied in full and in page order. No legacy page is summarized, rasterized, or deleted.
3. Fifteen functional pages from the focused visual document are inserted beside the related master sections:
   - visual direction;
   - project goal / system map;
   - actual Godot planning capture;
   - staged player Flow Map;
   - planning wireframe;
   - preparation-screen wireframe;
   - unified cards;
   - combat-screen wireframe;
   - current-action reveal wireframe;
   - lock/reveal/clash/settle contract;
   - whole-scene → module → composition image-production pipeline;
   - asset lineage and composition board;
   - case-status matrix;
   - visual evidence ceiling;
   - implementation handoff.
4. The former focused output is absorbed: its reusable source generator remains, but its standalone derived PDF is not a competing current human-master output.
5. The new PDF becomes the single `HUMAN_MASTER_GDD_PDF`; the 36-page PDF remains a preserved source baseline, not deleted history.

## Page-order contract

The assembled order is exactly: new cover; baseline pages 1-8; visual direction and project goal/system map; baseline page 9; planning capture, staged Flow Map, planning wireframe, and preparation wireframe; baseline pages 10-12; unified cards; baseline pages 13-14; combat wireframe, reveal wireframe, and reveal contract; baseline pages 15-23; image-production pipeline, asset lineage/composition board, case-status matrix, and visual evidence; baseline pages 24-36; implementation handoff.

The resulting count is `1 + 36 + 15 = 52` pages. The 36 baseline pages are byte-for-byte source pages in the assembled output; the new cover and fifteen inserts provide the current visual/wireframe, planning, and production layer.

## Evidence boundary

The actual preparation, hover, lock, and current-action images are machine
runtime captures. The whole-scene candidate and planning boards are visual
production/provenance artifacts and are not claimed as runtime. Exact
motion-quality, human player, accessibility, Android device, and release
evidence remain explicitly unverified until their own exact records exist.

## Non-goals

- No combat rule, implementation, scene, asset, save, platform, or AI behavior change.
- No new image generation, canon promotion, or locked-module replacement.
- No deletion of the 36-page source PDF.
- No human/device/runtime PASS claim beyond the evidence already recorded.

## Acceptance criteria

- A PDF at the active human-master path has at least 52 pages.
- It contains all 36 pages of the prior Master GDD in the exact source sequence.
- It contains the fifteen specified visual/wireframe/planning additions.
- It visibly contains a project goal/system map, per-case status board,
  staged Flow Map, preparation/combat wireframes, and whole-scene → module →
  composition evidence chain.
- Its reader route explicitly says the prior 36-page source is preserved and the 10-page derivative is absorbed.
- The old focused output no longer appears as a primary/current human blueprint path.
- Pypdf readback, PDF rendering inspection, focused regression tests, canonical-reference freshness, and exact-head CI all succeed.
