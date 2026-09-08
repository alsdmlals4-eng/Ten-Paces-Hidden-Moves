# Retained read-only preflight; not an implementation-completion claim

Controller independently repeated the exact diagnostic on unchanged fe720 on 2026-09-09: exit0, 41 bundle records, 3 direct-API records, completion marker, no ERROR/WARNING. This report preserves observed integration gaps for the next domain contract. The probe/log files below are local ignored evidence, not shipped scripts or a clean-clone test command; dedicated tracked RED/GREEN regressions must be authored with that contract. PR334 changes documents/tests only, so its merge6b566842 has the same product bytes. No whole-game/Human acceptance is implied.

# Domain response/defense preflight — actual bundle diagnostic

Status: REPRODUCED_DOMAIN_INTEGRATION_GAPS, no implementation authority created.
Baseline: fe720f5dce686ea5b2ff68a1ec078d53544a0e92, detached imported B worktree constraint-exact-head-check-20260908.
Work Mode REVIEW/DIAGNOSE; systematic-debugging root-cause/dataflow comparison and project verification evidence separation. CURRENT_SOURCE_RELEVANCE_CHECK: REUSED_EVIDENCE for the same feedback benchmark/runtime source dimension; new domain correction contract/research remains controller-owned and future. No new network search, full suite, campaign, subagent or tracked product/test edit.

## Reproduction and evidence boundaries

Ignored path was confirmed before writing with git check-ignore .superpowers/sdd/domain-response-preflight/probe.gd. Source and logs remain there. Exact command:

```text
C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe --headless --path . --log-file .superpowers/sdd/domain-response-preflight/native-final.log --script res://.superpowers/sdd/domain-response-preflight/probe.gd
```

Native 4.7.1.stable.a13da4feb, exit0, marker DOMAIN_RESPONSE_PREFLIGHT_COMPLETE; no ERROR/WARNING/SCRIPT ERROR matches in final log. Initial18-scenario native.log also exit0; final adds Wudang and has19 real resolve_bundle cases plus3 explicitly labeled DIRECT_API_NOT_BUNDLE probes. Full log is retained rather than relying on truncated tool console. No rendering/audio instantiated, no save/progression/human evidence.

Each real case uses the actual VerticalSliceMetricsCombatResolutionEngine, new instance/fresh owned registry configuration, actual canonical player definitions, normal resolve_bundle, and ai_enabled=false explicit enemy_bundles fixture. No opponent outcome or evade_success context injection. A Recorder subclass only records resolve_martial_card call arguments then delegates super; it does not alter results. Actor HP100, stamina/internal30, momentum5, five canonical stats10, positions4/5 are bounded engine-fixture inputs, not legal starting-run/growth claims. Enemy incoming basic_quick_attack executes at the selected player's final slot (1/2/3), avoiding earlier-slot preparation cancellation; same-slot cancellation of a surviving-nonattack candidate is still a real expected domain outcome, as the Purple addendum demonstrates. Slots are a sparse module plan, not a full ActionSelectionDock/run-envelope proof. No ultimate reservation/UI-cost claim is made.

## A. Actual Xiaoyao response path does not reach its martial program

| Actual player choice | Incoming action | Player HP after | Pipeline calls | Player resolved outcome |
|---|---|---:|---:|---|
| star3 / technique1 | normal quick attack8 at1 |98|0|response|
| star7 / technique2 | normal quick attack8 at2 |98|0|response|
| star10 / ultimate | normal quick attack8 at3 |98|0|response|
| Wudang star10 / ultimate | normal quick attack8 at3 |98|0|response|

Every case gets temporary defense profile guard_block4, guard_timings containing its nominal execution timing, no evade timing, no martial_events, and no actual martial movement/status/counter effects. Incoming8 becomes floor((8-4)*0.5)=2 with defense_outcome block. Both actors remain tiles4/5; player statuses remain empty. Technique costs are deducted but its authored effects never execute.

Root consumer chain:
- combat_resolution_engine.gd resolve_bundle builds actions then calls _prepare_bundle_defenses for all responses before its timing loop.
- _prepare_bundle_defenses at about499 treats category=response as basic_evade only when _base_card_id == basic_evade; all other response IDs take the guard branch. It pays costs and appends outcome=response.
- The per-timing loop only dispatches quick_attack/move/general; response actions are not sent to TenManual _execute_utility/_execute_martial_program.
- TenManual and Prepare/metrics have no response-dispatch override to resolve martial response programs. Thus the missing evade_succeeded context is a second downstream gap, not the first actual-bundle failure.

**Correction of earlier pre-review inference:** actual Xiaoyao/Wudang bundle execution is NOT martial_completed-but-condition-unmet. That description belongs to the direct martial API. The earlier D spec review was a source-dataflow inference at the wrong integration layer and must not be used as actual bundle evidence. Controller was alerted immediately. No successful real Wudang counter is reachable through this unchanged response route either.

## B. Direct martial API shows the separate requirement gate accurately

The separately labeled engine.resolve_martial_card(id,state,player,{}) probes do not inject evade_succeeded. All3 return completed=true, failure_reason empty, evade_succeeded=false:
- star3: MOVE_AWAY4→3, GAIN_STATUS evade1, REQUIRE_EVADE_SUCCESS FAILED, following MOVE_AWAY and completion-momentum SKIPPED_REQUIREMENT.
- star7: GAIN_STATUS evade1, requirement FAILED, counter ATTACK and retreat SKIPPED_REQUIREMENT.
- star10: GAIN_STATUS evade1, requirement FAILED, counter ATTACK/retreat/prepared all SKIPPED_REQUIREMENT.

This direct path does not simulate the incoming attack lifecycle and cannot prove gameplay recovery/counter behavior. _run_martial_pipeline supplies only tile_count/timing/opponent_clash_power; pipeline _initial_runtime reads evade_succeeded from context defaultfalse. Merely setting a self status to evade does not produce an actual evasion outcome. requirement_failed closes the gate without rolling back prior effects or making completed=false.

## C. Attacks use two disconnected defense representations

All attacks below use canonical authored definitions at distance1, defender basic response at the attacking execution timing, or an explicitly seeded actor.defense integer with no guard action:

| Attacker | none | basic_evade | basic_guard | actor.defense4 | actor.defense10 |
|---|---:|---:|---:|---:|---:|
| Shaolin star7, ATTACK power9, no authored sure-hit |9|9|9|5|0|
| basic_heavy_attack, stats10→17 |17|0|6|17|17|
| ultimate_void_sword_qi, authored 필중22 |22|22|9|22|22|

Cells are actual enemy HP loss. Shaolin invokes pipeline once and reports defense_outcome=martial_pipeline; its basic-evade and basic-guard opponents do produce valid normal defense profiles, but the attack does not consume/read them. Scalar defense is retained unchanged and is subtracted by the martial pipeline.

Normal heavy and authored generic sure-hit use _apply_defense's profile, not actor.defense. Heavy's same-timing guard6 is legacy floor((17-4)*0.5); sure-hit's guard9 is floor((22-4)*0.5), and authored sure-hit correctly bypasses the normal evade profile. Both ignore scalar martial defense.

Root code:
- TenManual _execute_attack_phase intercepts source=martial_manual and calls _run_martial_pipeline directly instead of the normal attack/defense path.
- martial_effect_pipeline._execute_attack reads distance, raw power and target.defense, subtracts directly from health, and emits HIT/BLOCKED. It does not see the normal defenses dictionary or sure-hit/evade counts.
- Normal engine _apply_defense reads guard_block/guard_timings/evade_timings or evade_bundle; no scalar actor.defense and no consumable count.
- Current martial catalog has no authored sure_hit or 필중 field/tag. Therefore no fake martial sure-hit card was created to claim a positive sure-hit test. The concrete error is that a non-sure-hit authored martial attack bypasses ordinary evade; generic authored sure-hit is only the control.

## Canon comparison and limits

docs/02_COMBAT_RULES.md sections8–9 and current docs/00_TAG_STATUS_REGISTRY.md specify range/direction → evade → subtract current nonconsumed defense → HP/effects/interruption, one evade entitlement for the first eligible damage unit, and 필중 bypassing evade only (not defense). The sections are approved planning, not a claim that every listed rule is already implemented; the same rules document retains historical implementation caveats and specific phase2 implementation overlays. Actual basic card text still describes legacy same-timing full evade and extra guard50%. Do not silently treat these observed legacy numerics as the approved final defense formula or silently rewrite those data in the feedback-only package.

Relevant decision history re-read: 2026-08-02_BASIC_ACTIONS_PALM_CLASH_DECISION (sequential hit/defense/evade order), 2026-08-04_COMBAT_PRICING_INTERRUPTION_RECOVERY_DECISION (response→attack/prepare interruption ownership), 2026-08-06_TEN_RECOGNIZABLE_MARTIAL_MANUALS_FULL_GROWTH_DECISION, and actual Xiaoyao/Wudang/Shaolin data. Current source, planning status and gameplay implementation must remain distinct. Full attack-clash chain, every condition/full_absorb, both-actor mirrors, timing interleaving, stack spending and normal campaign balance were not exhaustively tested in this bounded diagnostic.

## Recommended bounded next contract, not implementation

1. Correct response dispatch at the existing engine/TenManual boundary so only genuine basic guard/evade use their basic path; actual martial response programs run through an explicitly specified execution/timing lifecycle. Determine response-before-incoming and conditional-continuation timing from canon before coding; do not infer success from acquiring an evade status. Keep actor ownership, single costs, prepare interruption and enemy lock unchanged.
2. Give basic and martial attacks a shared authoritative defense/evasion application path or a narrow domain callback using the same combat state, rather than keeping two unrelated representations. Bind actual evasion outcome to the relevant suspended/conditional martial response, with actor/timing/action ownership. Decide one-charge consumption, sure-hit entitlement and temporary profile↔persistent state representation explicitly. Do not repair this with a permanent true evade_succeeded test context.
3. Keep the work out of D's presentation-only contract. A later execution-meaning change needs explicit save/COMMITTED determinism compatibility policy; do not assume an unchanged schema field layout means unchanged old execution identity.

Minimum prospective regression set for that later contract: the three Xiaoyao choices and Wudang response through actual resolve_bundle with reachable incoming attack; no incoming attack/failed evasion; both actors; no premature response/cost duplication across preparation; basic and martial damage against normal evade/guard and actual martial defense; one eligible damage unit consumes one evade while later units remain; authored sure-hit bypasses only evade and preserves defense; response counter after real success and no counter after no success; partial effects/failed requirements; state/events/metrics plus COMMITTED/RESOLVED save compatibility and actual UI producer parity. No balancing or blanket successful program expectations.

## Retention and warning provenance

Only ignored probe.gd, native.log, native-final.log, native-all10.log and this report were produced. git diff --name-only -- src tests data scenes project.godot is empty. B already contains imported asset .import and generated .uid sidecars; these are preserved and not staged/cleaned. This diagnostic's logs contain no ObjectDB warning, unlike separately observed audio/editor runs; no inference about those other warnings' cause is made here.

## D. Follow-up: all ten actor-owned ultimates through actual plans

The latest run adds twenty actual resolve_bundle cases (each star10 alone and against the ordinary enemy quick attack at execution timing3) plus two low-resource Purple cases, retaining the original nineteen bundle cases and three direct-API probes: **41 normal bundle cases + 3 direct API probes**. Each case configures only the named player's actual manual at mastery10; definitions come from get_actor_card_definition, not invented success effects. Exact latest command, working directory B:

```text
C:/Users/user/Downloads/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe --headless --path . --log-file .superpowers/sdd/domain-response-preflight/native-all10.log --script res://.superpowers/sdd/domain-response-preflight/probe.gd
```

Exit0, 1.29s command wall time, completion marker present. Latest native log SHA-256: 9D7F7E1C678AF4AEB15E7F59AD128D018FB4802A20EB725406ED40AAC3158CA7. Initial final-log SHA-256 remains AD10AED2CE3EED5E80B8A98BBFAD303ACF95069BD767875C16DB9F49E37706D6. This is a diagnostic execution result, not a regression suite PASS or a claim that all ten effects work.

| Authored manual star10 (ID prefix) | Pipeline calls alone / incoming | Final execution outcome alone / incoming | Enemy HP loss alone / incoming | Player HP loss incoming | Distinct actual result |
|---|---|---|---|---|---|
| beggars_dragon_subduing_palm |1 / 1|martial_completed / same|0 / 0|8|Move4→5 produces distance0; ATTACK skipped out of range; internal SPECIAL_CLASH WIN is not outer attack clash evidence|
| hebei_peng_five_tigers_saber |1 / 1|martial_completed / same|28 / 28|8|Three actual damage units8+8+12|
| mount_hua_plum_blossom_sword |1 / 1|martial_completed / same|0 / 0|8|Move4→5, three out-of-range attempts; hit-count requirement fails and later steps skip|
| mount_hua_purple_mist_art |1 / 0|martial_completed / interrupted|0 / 0|8|Alone recovery program runs; incoming quick attack cancels still-pending utility|
| nangong_boundless_sky_sword |1 / 1|martial_completed / same|12 / 12|8|Defense break and actual ATTACK12; internal SPECIAL_CLASH WIN|
| shaolin_arhat_vajra_art |1 / 1|martial_completed / same|12 / 12|8|Own defense4 and actual ATTACK12; defense-loss record0|
| sichuan_tang_hidden_weapons |1 / 1|martial_completed / same|16 / 16|8|Four independent actual damage units4 each|
| wudang_taiji_sword |0 / 0|response / response|0 / 0|2|Generic guard4; no authored response program or counter|
| xiaoyao_lingbo_footwork |0 / 0|response / response|0 / 0|2|Generic guard4; no authored evade program or counter|
| yang_family_spear |1 / 1|martial_completed / same|9 / 9|8|First ATTACK9, retreat4→2; distance3 causes second attack to skip|

The fixed distance1 fixture intentionally does not force every movement/range requirement to succeed; zero damage alone is not evidence of a broken program. This matrix proves integration-route reachability (or its absence), not full ten-manual gameplay acceptance. A later full matrix must select legal UI-produced plans/positions for every relevant condition, mirror actors, and preserve negative cases, rather than injecting synthetic successful contexts. In the current diagnostic, eight distinct authored ultimate programs reach the pipeline alone; Wudang and Xiaoyao demonstrably do not. Seven reach it against the actual quick attack; Purple correctly supplies an interruption case.

### Purple recovery: expected versus actual

Canonical data/cards/martial_manuals/mount_hua_purple_mist_art.json declares recovery/general/self,3slots. It consumes its once-per-battle key, gains internal4/stamina3/fortitude1/defense3, and health4 when LOW_RESOURCE_AT_START. At full resources the alone case emits these program events, caps internal/stamina/health, skips the conditional health gain, and leaves defense3.

Additional exact initial fixture player HP60/100, internal3/30, stamina3/30, momentum5/5 (all other inputs unchanged):

- Alone: one pipeline call; health64, internal7, stamina6, defense3, fortitude event APPLIED, purple_mist_ultimate key CONSUMED, final martial_completed.
- Opposite ordinary quick attack at timing3: zero pipeline calls; actual health52, internal3, stamina3, defense0, no martial events or once-key consumption, final interrupted.

Expected approved phase behavior is not a new choice: docs/02_COMBAT_RULES.md §8 explicitly orders response → quick attack → move → attack → surviving nonattack actions, with actual HP damage interrupting a still-unexecuted same-slot nonattack unless existing fortitude prevents it. The referenced approved 2026-08-04_COMBAT_PRICING_INTERRUPTION_RECOVERY_DECISION §2 states that interrupted meditation does not recover and names the same order. Thus the observed absence of healing after interruption is a valid negative case; this validates that phase consequence only, not all Purple lifecycle behavior. Do not move recovery ahead of attacks or grant fortitude early merely to produce a success animation. Purple's own later program-granted fortitude cannot retroactively protect an unexecuted program. This probe does not evaluate a preexisting-fortitude case.

**Separate once-use lifecycle boundary / potential canon conflict:** the later 2026-08-06_TEN_RECOGNIZABLE_MARTIAL_MANUALS_FULL_GROWTH_DECISION, special rule 자하신공, requires consumption when the FIRST TELEGRAPH executes, no refund on interruption or KO, and completion-only momentum recovery. Actual authored data puts CONSUME_ONCE_PER_BATTLE at the first effect step; in this sparse engine fixture the interrupted branch never reaches that step and shows no key consumption even after preparation records. That is not a validated or approved no-consumption outcome. The probe does not exercise the actual dock reservation/preamble path, so first-telegraph consumption end-to-end remains UNVERIFIED with a potential domain integration gap. A future actual producer/lifecycle regression must verify use-right consumption at the first telegraph and its retention after interruption/KO separately from the already-observed no-healing consequence. No new probe or product correction is performed in this diagnostic follow-up.

Actual consumers: src/combat/combat_resolution_engine.gd:278 quick dispatch, :292 ordinary attack dispatch, :293 deferred hit resolution, :294–302 cancelled utility rejection then execution; src/combat/combat_resolution_engine_ten_manuals.gd:206–213 actual recovery pipeline routing. Wudang/Xiaoyao instead fall through src/combat/combat_resolution_engine.gd:495 response prepass with no martial dispatch. Minimal future response repair belongs to that existing boundary plus the effect pipeline's conditional lifecycle; Purple has an already reachable recovery consumer and should retain its approved phase/interruption semantics while its distinct first-telegraph once-use lifecycle requires the separate verification above. This is not a blanket Purple correctness finding.

Diagnostic-field correction: the emitted field named input_unchanged is merely the original HP100/100 predicate and is false in the intentionally HP60 fixture. It is not a mutation-isolation assertion and must not be cited as either mutation evidence or a nonmutation PASS. Source immutability is evidenced separately by the empty tracked consumer diff. No diagnostic outcome is predicated on this unused print field.

## Successor prework: ten-case execution-order benchmark

Accessed 2026-09-09 before any successor domain mutation. This is a new decision dimension, not silent reuse of the earlier audio/visual benchmark: **a committed defensive or compound action must execute its actual ordered effects, and all damage producers must respect the same applicable defense rules**. The diagnostic product baseline remains fe720; the subsequent feedback-only change does not alter these domain consumers. These official sources establish product mechanisms, not competitors' source-code architecture. The transfer column is our inference. No competitor play session, representative player survey, purchased asset or external code integration was performed. Reaction evidence is absent unless explicitly named; absence is not positive acceptance evidence.

| Case / role / official source and freshness | Observed product mechanism | Transfer principle / disposition | DO_NOT_COPY and evidence limit |
|---|---|---|---|
| Your Only Move Is HUSTLE / direct / [developer Steam description](https://store.steampowered.com/app/2212330/Yomi_Hustle/?l=english), live page | Turn-based fighting, detailed action planning, defensive options and cinematic replays are advertised together. | ADAPT/TEST: retain exact resolved facts for both effective defense and replay; a readable move name alone is not execution evidence. | No full precognition, frame simulation, online PvP or copied move sets. Store description does not document implementation or defense edge cases; review percentages are not used. |
| Mega Knockdown / direct / [developer FAQ](https://megaknockdown.com/FAQ/), undated, contains historical 2022 development wording | Both players choose movement and combat double-blind; combat resolves after both lock, then input resumes. The developer explicitly distinguishes proactive prediction from hard-to-represent reaction interactions. | ADOPT/TEST: counter eligibility must come from the already locked action and actual contact, never a new input or AI access to hidden player intent. | No simultaneous movement/combat dual selector, throw system or reaction-time minigame. No measured reaction evidence. |
| Shogun Showdown / direct / [publisher page](https://goblinzstudio.com/game/shogun-showdown/), displayed launch September 2024 | Position, timing and attack combinations form its turn-based tactical promise. | ADAPT/TEST: after each actual movement, recompute legal reach for the next authored strike; retain an honest failed continuation. | No deck, draw, tile inventory or copied attacks; exact collision rules not documented here. |
| Fights in Tight Spaces / direct and mixed-negative / [developer patch history](https://roadmap.groundshatter.com/home), historical Early Access and v1.0 entries | Dodge protects against the next incoming attack; published fixes cover dodgeable counters, wrong impact sounds, skipped effects, stacked-counter soft locks and replay corrections. | ADAPT/TEST: distinguish acquiring evasion, consuming it against a valid unit, counter eligibility and presentation. Bound continuation count and test negative paths. | Do not copy whole-attack dodge, damage-over-time, deck, rollback or numerical balance. Historical developer-reported bugs are risk examples, not current incidence or a player survey. |
| For Honor / direct-adjacent / [Ubisoft parry explanation](https://www.ubisoft.com/en-us/game/for-honor/news-updates/6WApFxyOmgCgYkDYSQpsq0/yes), 2018-09-01 | A parry depends on the opponent's attack direction and correct timing and grants an advantage when successful. | ADAPT: a counter must have a real qualifying opponent attack; a stance label or positive nominal power is insufficient. | No real-time reflex test, guaranteed damage or frame numbers. Historical tutorial does not establish current balancing. |
| Hellish Quart / direct and mixed / [developer site](https://www.hellishquart.com/) and [FAQ](https://www.hellishquart.com/faq), live undated | Blades physically clash/block; the FAQ explains passive guard and its project's physics/networking limitations. | ADAPT visible contact clarity; AVOID making this deterministic ten-cell core depend on VFX collisions, frame rate or a new physics subsystem. | No passive free guard, ragdolls, weapon physics or online infrastructure. The developer's networking limitation is project-specific, not proof that all physics networking is impossible; no gameplay measurement here. |
| Into the Breach / adjacent / [developer page](https://subsetgames.com/itb.html), live undated | Enemy attacks are telegraphed so the player can plan a counter; protecting other objects affects decisions. | ADAPT/TEST: communicate the consequence of an actual counter and its failure reason consistently. | AVOID importing complete enemy attack disclosure: this project's observation boundaries remain authoritative. No city/object objectives added; no reaction sample. |
| Frozen Synapse / adjacent / [Mode 7](https://www.mode7.games/), live undated | Simultaneous turn-based orders emphasize positioning, timing and terrain reading. | ADAPT/TEST: committed plans and replay state must be stable; presentation speed and skip cannot choose a different result. | No squads, terrain system, continuous five-second simulation or multiplayer. Public product description does not prove a save algorithm. |
| Phantom Brigade / adjacent / [developer page](https://braceyourselfgames.com/phantom-brigade/), current 2.0 description and June 2026 news | Players schedule countermeasures on a timeline and execute a cinematic sequence. | ADAPT: separate deterministic action execution from its animation timeline, and associate each response with the relevant scheduled contact. | AVOID future-knowledge UI, 3D physics, equipment economy and destructible terrain. Advertised mechanism, not an internal-engine audit. |
| Transistor / adjacent / [PlayStation hands-on](https://blog.playstation.com/2013/09/04/hands-on-with-transistor-on-ps4/), 2013-09-04 preview | Its Turn system permits repositioning and ordered attacks while time is stopped, followed by quick execution. | ADAPT/TEST: preserve authored order and final state across a staged presentation; moving first may invalidate a later attack. | No real-time/turn hybrid or free pause combat redesign. This is a platform-holder's historical preview, not final-version certification or representative player evidence. |

### Practical findings and implementation boundary

The current native source, not competitor analogy, establishes the repair locations: base `_prepare_bundle_defenses` preprocesses every response for the entire bundle; TenManual routes only attacks/utilities into the authored pipeline; `_run_martial_pipeline` lacks actual evasion/contact context; `_apply_defense` and pipeline `_execute_attack` use incompatible defense representations. Prepare's result overlay and the metrics/checkpoint consumers also depend on that ordering. A one-line call to the pipeline during the response prepass is therefore **REJECTED**: it would test a future evasion before its incoming attack and could pay/apply effects at the wrong time. A permanent `evade_succeeded=true` is also rejected.

The successor must define and test bounded action-local preparation/continuation, actual contact or evasion-triggered resumption, shared damage-unit defense and terminal/interruption cancellation. Exact implementation remains `PARTIAL / SPECIFICATION_REQUIRED`; this preflight does not authorize changing shared gameplay or save semantics under the feedback-only approval. Preserve authored prices, hidden-information boundaries and actor-owned definitions. No new middleware or purchased asset is justified by these findings. Keep all ten-case negative/failure fixtures when the positive path is implemented.

The current approved combat owner and actual legacy runtime also disagree on basic defense duration, packet-level evasion, sequential clashes, cost timing and interruption. Those are linked domain decisions, not harmless presentation refactors. Fresh-read the latest specific Decisions before resolving each conflict; do not silently canonize old tests or replace all rules as an incidental response fix. `run_checkpoint_codec.gd` explicitly versions code-owned combat semantics, so COMMITTED replay compatibility must be designed and tested before publishing altered resolution. Preserve RESOLVED output and unknown save files; no deletion or silent migration.

Prework review: (1) checked source/relevance and historical labels; (2) checked direct/adjacent/mixed coverage and information-boundary exclusions; (3) traced actual producer/consumer ordering; (4) attacked naive early execution and fake success alternatives; (5) checked cost, save compatibility and evidence ceilings. No product mutation or completed-domain claim follows from this review.
