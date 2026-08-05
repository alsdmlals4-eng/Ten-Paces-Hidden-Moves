# Battle Grade Farming Guardrails Design

- Decision ID: `TEN-DEC-20260805-GRADE-FARMING-GUARDRAILS-01`
- User direction: approve recommended valid-event cap approach
- Work Mode: `PLAN`
- Product/runtime authority: `PLANNING_ONLY`

## 1. Problem

The approved battle-grade inputs remain:

1. successful dodges
2. clash wins
3. player health lost
4. rounds elapsed
5. ultimate uses

Raw event counts are useful for replay and telemetry, but successful dodges, clash wins, and ultimate uses can be inflated by prolonging a battle or repeatedly exploiting one safely known enemy action. Grade calculation therefore needs a separate eligible-credit layer without weakening combat resolution, observation, logs, ultimate momentum, or replay evidence.

## 2. Goals

- Preserve every raw combat event exactly as resolved.
- Reward accurate reads and responses without rewarding indefinite repetition.
- Prevent one multi-hit attack action from producing multiple full grade credits.
- Stop positive grade-credit accumulation after an encounter's expected scoring window.
- Keep the result explainable by displaying raw counts separately from effective grade credit.
- Keep grade rewards disconnected from run economy until human validation.

## 3. Non-goals

- Do not set final metric weights, S/A/B/C thresholds, health-loss normalization, or round penalty curves.
- Do not change combat damage, clash, dodge, interruption, observation, ultimate momentum, or AI behavior.
- Do not change product code, Godot scenes, HTML PoC, or runtime data in this planning package.
- Do not attenuate raw logs, replay events, achievements, or online season rating.

## 4. Event Identity

Each enemy attack action instance must expose:

```text
enemy_action_instance_id
canonical_source_id = source_type + ":" + source_id
round_index
qualifying_response_events[]
```

`canonical_source_id` follows `TEN-DEC-20260802-THREAT-ID-ACTION-01`. Temporary stats, preparation, distance, direction, target, display name, hit index, and temporary modifiers do not create a new source identity.

Qualifying response events are raw `CLASH_WIN` and `DODGE_SUCCESS` events produced while resolving that enemy attack action instance.

## 5. Eligible Defensive Credit

Raw events remain unchanged. Grade credit is computed independently.

For the first, second, and later successfully answered enemy attack instances sharing the same canonical source ID:

```text
repeat_multiplier = [1.0, 0.5, 0.0]
```

An attack instance receives one credit pool equal to its repeat multiplier. If the same attack instance contains multiple qualifying clash/dodge events, divide the pool equally across all qualifying events.

Example:

```text
one clash + one dodge in first instance
→ pool 1.0
→ clash credit 0.5
→ dodge credit 0.5

three clash wins in second instance
→ pool 0.5
→ each clash event credit 1/6
→ total clash credit 0.5
```

This guarantees:

```text
sum(clash_credit + dodge_credit for one enemy action instance)
<= repeat_multiplier
<= 1.0
```

The raw event counter still records every clash win and dodge success.

## 6. Metric Caps and Normalization Inputs

Initial reversible PoC defaults:

```yaml
clash_credit_cap: 3.0
dodge_credit_cap: 3.0
normalized_clash_input: min(total_clash_credit, 3.0) / 3.0
normalized_dodge_input: min(total_dodge_credit, 3.0) / 3.0
```

These are grade-input normalization values, not final grade weights.

## 7. Scoring Window

Each encounter should author `grade_target_rounds >= 1`. Until encounter-specific values exist, the PoC fallback is:

```yaml
default_grade_target_rounds: 3
```

Positive dodge, clash, and ultimate grade credit can be earned only when:

```text
round_index <= grade_target_rounds
```

After the scoring window:

- raw dodge, clash, and ultimate events continue to log normally;
- no new positive dodge, clash, or ultimate grade credit is added;
- health loss and elapsed rounds continue to be recorded for the future negative/efficiency formula.

## 8. Ultimate Credit

Raw ultimate use count records every legal use. Grade credit is limited to the first effective ultimate use within the scoring window.

An ultimate use is effective when it resolves legally and applies at least one non-cost result:

- health damage
- healing
- forced movement
- status application
- attack interruption
- beneficial resource change

Action cost, reservation, or payment alone does not qualify.

```yaml
maximum_effective_ultimate_grade_credit: 1
```

## 9. Retry and Reward Boundaries

- Each battle attempt is scored independently; failed or abandoned attempts do not contribute events to a later attempt.
- Learning an enemy through retry is allowed and is not penalized.
- Grade, grade credit, or grade rank must not multiply run currency, training, drops, permanent currency, or retry refunds until the human-validation gate passes.
- Future reward linkage requires a new Decision.

## 10. Human Validation Gate

Before any economy linkage, collect at least:

```yaml
minimum_completed_victories: 30
minimum_distinct_encounters: 5
maximum_single_encounter_sample_share: 0.40
```

Required diagnostics:

- raw-to-effective defensive credit ratio
- same-source repeat-response share
- post-window positive raw-event share
- full scoring-window completion rate
- observation-assisted effective-credit uplift
- average and 90th-percentile rounds elapsed
- effective ultimate use rate

Provisional warning thresholds are diagnostic only and never trigger automatic tuning:

```yaml
raw_to_effective_credit_ratio_warning: 2.0
same_source_repeat_share_warning: 0.40
post_window_positive_raw_event_share_warning: 0.15
observation_assisted_credit_uplift_warning_pp: 20
```

## 11. Result Explanation

The result surface must keep raw evidence and grade input distinct:

```text
합 승리: 5회 / 등급 반영 2.5
회피 성공: 3회 / 등급 반영 1.5
절초 사용: 2회 / 유효 반영 1회
```

Exact final score, weights, and grade boundaries remain a later Decision.

## 12. Error and Conflict Rules

The contract is invalid if any of the following occurs:

- raw logs are attenuated or deleted;
- a single enemy action instance receives more than 1.0 combined clash+dodge credit;
- repeat multipliers differ from `1.0, 0.5, 0.0` without a new Decision;
- hit index creates a new action identity;
- positive credit continues after the scoring window;
- more than one ultimate use receives grade credit;
- grade affects economy before the human-validation gate;
- automatic tuning changes values without a new GrillMe Decision.

## 13. Test Matrix

- approved contract passes deterministic validation;
- missing raw-log preservation fails;
- changed repeat multipliers fail;
- instance combined-credit cap above 1.0 fails;
- missing equal pool split fails;
- metric cap drift fails;
- scoring-window positive-credit continuation fails;
- ultimate credit above one fails;
- economy linkage before human validation fails;
- missing measurement diagnostics fails;
- Active Context advances to `9/10` and next Decision `STAR9_PUBLIC_READ_BRANCH_TEMPLATE`;
- product/runtime change claims fail.

## 14. Decision State

```yaml
authority_status: CURRENT_APPROVED_PLANNING_GOVERNANCE
risk_status: MITIGATED_PENDING_HUMAN_MEASUREMENT
active_approval_count: 9/10
next_planning_decision: STAR9_PUBLIC_READ_BRANCH_TEMPLATE
product_code_changed: false
runtime_data_changed: false
human_validation: NOT_RUN
balance_validation: NOT_RUN
```
