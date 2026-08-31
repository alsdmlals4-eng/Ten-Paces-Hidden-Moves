# TEN-DEC-20260831-FRONTAL-DUEL-PRESENTATION-AND-ILLUSTRATED-CARD-POLICY-01

```yaml
date: 2026-08-31
status: USER_APPROVED_BUILD
user_final_lock: "최종확정"
scope:
  - final-lock and promote FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1
  - replace the diagonal foreground/background combat staging with a frontal same-ground-line duel
  - retire the player-facing opponent-intent hypothesis selector and visible immediate-complete control
  - keep native 3/3/4 planning, sequential action reveal, combat review, fast replay, reduced motion, sound controls, and public-information boundaries
  - establish illustrated-card coverage as the active policy for basic, martial, ultimate, and intent cards
non_goals:
  - combat-rule, AI-information-boundary, save-schema, or platform-core changes
  - copying user reference pixels, embedded UI, characters, text, or composition
  - treating an unreviewed martial/ultimate/intent illustration candidate as a runtime asset
```

## Decision

`ADOPT` a symmetric frontal scene: the player and enemy remain at distinct horizontal positions but share one foot-anchor baseline, comparable scale, and one centrally placed live `거리 N` readout. The final-locked stone-courtyard background supplies real ground contact and perspective while all gameplay state remains native Godot UI.

`REMOVE` the player-authored `상대 의도 가설` input panel and the visible `즉시 완료` button. An internal test-only presentation-completion helper may remain where deterministic regression needs it; it is not a player-facing control. Fast replay, motion reduction, sound controls, the combat log, observation result, sequential reveal, and review continue to express their existing state without reconstructing combat results in UI.

`ADAPT` the shared `ActionChoiceCard` surface as the only card shell for every action source. The existing final-locked basic atlas remains active. Martial, ultimate, and intent imagery require a separately generated, reviewed, user-final-locked atlas and exact region map before they can be rendered in runtime; the policy change does not falsely turn missing art into approved art.

## Source relevance, comparison, and feasibility

The directly relevant 12-game reverse-engineering record is `docs/reviews/2026-08-30_TEN_PACES_BENCHMARK_REVERSE_ENGINEERING.md`, rechecked against its official sources on 2026-08-31. Its transfer remains valid for this unchanged decision dimension: `ADAPT` grounded left/right staging and live action readability; `AVOID` imported deck/hand/draw mechanics, full enemy-plan disclosure, real-time control, copied art, copied UI, or copied characters.

`FEASIBLE`: `BattleBackground` owns only the responsive raster backdrop; `CombatBoardPreviewAuto` owns the product layout; `CombatBoardPreview` owns visible controls, focus, review snapshots, and presentation sequencing; `ActionChoiceCard` owns card visual children. Existing approved inward-facing player/enemy battlers can provide the frontal runtime pose without a new character-asset promotion. The final-locked background candidate is the only new runtime raster in this package.

## Asset and rollback contract

- Candidate source: `docs/visual-assets/candidates/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.png`
- Canonical source after promotion: `docs/visual-assets/approved/FRONTAL_COURTYARD_DUEL_BACKGROUND_01_v1.png`
- Runtime destination after promotion: `assets/backgrounds/frontal_courtyard_duel_background_01_v1.png`
- Runtime consumer: `src/combat/battle_background.gd`
- Superseded active background: `ink_mist_valley_duel_01_v1`, retained as an inactive rollback asset in `assets/ASSET_MANIFEST.json`
- Non-basic card art: `BRIEF_READY`, then `GENERATED_CANDIDATE`, then a separate user final lock; no runtime path, manifest entry, or illustration region is introduced early.

## Acceptance contract

1. The promoted background file is byte-equal to the final-locked candidate and has provenance, hash, rollback mapping, manifest, and destination readback.
2. At 1440×900, player and enemy stand left/right on the same foot-anchor baseline with comparable scale; the readout remains centred and the logical ten-tile layer remains hidden outside targeting.
3. `OpponentHypothesisPanel` and `SkipPresentationButton` have no active runtime node, player-visible copy, focus route, or active production consumer. Sequential reveal and review remain available.
4. Existing approved basic card illustration coverage remains unchanged. Every non-basic action source stays on the shared card shell; image coverage is reported truthfully until its separate asset gate completes.
5. Focused RED→GREEN regressions, project validation, related Godot checks, visible runtime input/readback, and a clean changed-path review are recorded. Human UX, accessibility-user, Android-device, release performance, and player-comparison evidence remain `NOT_RUN` unless separately executed.
