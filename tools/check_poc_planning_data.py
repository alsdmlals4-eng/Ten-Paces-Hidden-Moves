#!/usr/bin/env python3
"""Validate editable, non-runtime PoC planning data and REVIEW decisions."""

from __future__ import annotations

import argparse
import json
from copy import deepcopy
from pathlib import Path
from typing import Any


class PlanningDataError(RuntimeError):
    pass


FILES = {
    "budget": "poc_balance_budget.json",
    "manuals": "poc_martial_arts.json",
    "duels": "poc_enemy_duels.json",
    "map": "poc_map_rewards.json",
    "run": "poc_run_state_contract.json",
    "sanity": "poc_sanity_model.json",
}

BUILTIN_ACTION_SLOTS = {
    "basic_move": 1,
    "basic_footwork": 1,
    "basic_guard": 1,
    "basic_evade": 1,
    "basic_quick_attack": 1,
    "basic_heavy_attack": 2,
    "basic_meditate": 1,
    "basic_stance": 1,
}

EXPECTED_STAGE_IDS = [
    "tutorial", "stage_1", "stage_1", "stage_1", "stage_1",
    "stage_2", "stage_2", "stage_2", "stage_3", "stage_3",
]
EXPECTED_EFFECT_TRIGGERS = {
    "ON_ACTION_START", "ON_ACTION_RESOLVE", "ON_CLASH_WIN", "ON_EVADE_SUCCESS",
    "ON_HIT", "ON_HEALTH_DAMAGE", "ON_ACTION_END",
}
ACTION_LEVEL_TRIGGERS = EXPECTED_EFFECT_TRIGGERS - {"ON_HIT", "ON_HEALTH_DAMAGE"}
FORMULA_IDS = {
    "SUCCESS_RATIO", "RESOURCE_EFFICIENCY", "DAMAGE_CONTROL", "PUBLISHED_TASK_PROGRESS"
}
REQUIRED_NODE_TYPES = {"combat", "training", "faction", "encounter", "inn", "market"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise PlanningDataError(message)


def load_object(path: Path) -> dict[str, Any]:
    try:
        text = path.read_text(encoding="utf-8")
        value = json.loads(text)
    except FileNotFoundError as exc:
        raise PlanningDataError(f"missing planning data: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise PlanningDataError(
            f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}"
        ) from exc
    require(isinstance(value, dict), f"planning JSON root must be an object: {path.as_posix()}")
    canonical = json.dumps(value, ensure_ascii=False, indent=2) + "\n"
    require(text == canonical, f"planning JSON must use canonical two-space formatting: {path.name}")
    return value


def validate_status(data: dict[str, Any], label: str) -> None:
    require(data.get("editable") is True or label == "sanity", f"{label}: editable must be true")
    require(
        str(data.get("data_role", "")) in {"NON_RUNTIME_POC_PLANNING", "ANALYSIS_ONLY"},
        f"{label}: invalid data_role",
    )


def as_int(value: Any, message: str) -> int:
    require(isinstance(value, int) and not isinstance(value, bool), message)
    return int(value)


def validate_budget(data: dict[str, Any]) -> dict[str, Any]:
    validate_status(data, "budget")
    require(int(data.get("schema_version", 0)) >= 3, "budget: schema version must include REVIEW contracts")
    unit = data.get("unit", {})
    require(unit.get("display_step") == 0.05, "budget: display_step must be 0.05")
    require(unit.get("ticks_per_display_step") == 1, "budget: 0.05 must equal one tick")
    slots = {int(key): int(value) for key, value in data.get("slot_budget_ticks", {}).items()}
    require(slots == {1: 20, 2: 50, 3: 80}, "budget: slot targets must be 20/50/80")
    tolerance = int(data.get("automatic_acceptance_tolerance_ticks", -1))
    require(tolerance == 5, "budget: automatic tolerance must be five ticks")

    pricing = data.get("pricing_ticks", {})
    condition_credits = data.get("condition_credits", {})
    require(all(isinstance(v, int) for v in pricing.values()), "budget: pricing values must be integer ticks")
    require(all(isinstance(v, int) for v in condition_credits.values()), "budget: condition credits must be integer ticks")
    require(int(pricing.get("medical_per_point", -1)) == 5, "budget: medical point price must be five ticks")

    contract = data.get("effect_contract", {})
    scopes = {str(value) for value in contract.get("scope", [])}
    triggers = {str(value) for value in contract.get("trigger", [])}
    conditions = {str(value) for value in contract.get("condition_vocabulary", [])}
    require(scopes == {"PER_HIT", "ONCE_PER_ACTION"}, "budget: effect scopes differ")
    require(triggers == EXPECTED_EFFECT_TRIGGERS, "budget: effect triggers differ")
    require(conditions == {"requires_existing_defense", "requires_at_least_one_hit", "attack_misses"}, "budget: effect condition vocabulary differs")
    require(contract.get("action_level_triggers_require_once_per_action") is True, "budget: action-level effects must be once per action")
    sure_hit = contract.get("sure_hit_stack_policy", {})
    require(sure_hit.get("unit") == "ONE_STACK_PER_EFFECTIVE_HIT", "budget: sure-hit unit differs")
    require(sure_hit.get("consume_when") == "BYPASSES_AVAILABLE_EVADE", "budget: sure-hit consumption differs")
    require(sure_hit.get("persistence") == "UNTIL_CONSUMED_OR_BATTLE_END", "budget: sure-hit persistence differs")
    require(sure_hit.get("reset") == "BATTLE_END", "budget: sure-hit reset differs")
    require(
        set(sure_hit.get("does_not_consume_on", []))
        == {"CLASH_CANCELLED", "INTERRUPTED", "NO_TARGET", "OUT_OF_RANGE", "NO_EVADE_PRESENT"},
        "budget: sure-hit non-consumption cases differ",
    )

    patch = data.get("patch_contract", {})
    require(int(patch.get("allowance_ticks", -1)) == 5, "budget: patch allowance must be five ticks")
    require(int(patch.get("automatic_tolerance_ticks", -1)) == 1, "budget: patch tolerance must be one tick")
    require(int(patch.get("max_added_budget_ticks", -1)) == 6, "budget: patch max must be six ticks")
    allowed_patch_fields = {str(v) for v in patch.get("allowed_fields", [])}
    require(
        allowed_patch_fields == {"hits", "damage", "move_range", "defense_gain", "clash_power_bonus", "health_heal", "medical", "sure_hit_stacks"},
        "budget: patch field vocabulary differs",
    )
    require(
        data.get("migration_policy", {}).get("central_price_change_auto_edits_existing_techniques") is False,
        "budget: central price changes must not auto-edit techniques",
    )
    return {
        "slots": slots,
        "tolerance": tolerance,
        "scopes": scopes,
        "triggers": triggers,
        "conditions": conditions,
        "tables": {"pricing_ticks": pricing, "condition_credits": condition_credits},
        "patch": patch,
    }


def validate_budget_ledger(technique: dict[str, Any], contract: dict[str, Any]) -> None:
    technique_id = str(technique.get("id", ""))
    action_slots = int(technique.get("action_slots", 0))
    require(action_slots in contract["slots"], f"{technique_id}: invalid action_slots")
    budget = technique.get("budget", {})
    ledger = budget.get("ledger", [])
    require(isinstance(ledger, list) and ledger, f"{technique_id}: budget ledger required")
    derived_components: dict[str, int] = {}
    seen_components: set[str] = set()
    for index, item in enumerate(ledger):
        require(isinstance(item, dict), f"{technique_id}: ledger {index} must be an object")
        component_id = str(item.get("component_id", ""))
        source_table = str(item.get("source_table", ""))
        price_id = str(item.get("price_id", ""))
        quantity = as_int(item.get("quantity"), f"{technique_id}: ledger quantity must be integer")
        derived = as_int(item.get("derived_ticks"), f"{technique_id}: ledger ticks must be integer")
        require(component_id and component_id not in seen_components, f"{technique_id}: duplicate ledger component {component_id!r}")
        seen_components.add(component_id)
        require(source_table in contract["tables"], f"{technique_id}: unknown price table {source_table!r}")
        table = contract["tables"][source_table]
        require(price_id in table, f"{technique_id}: unknown price id {price_id!r}")
        require(quantity >= 0, f"{technique_id}: ledger quantity must be non-negative")
        require(derived == int(table[price_id]) * quantity, f"{technique_id}: stale ledger ticks for {component_id}")
        derived_components[component_id] = derived

    components = budget.get("components", {})
    require(components == derived_components, f"{technique_id}: components must be derived from ledger")
    target = int(budget.get("target_ticks", -1))
    calculated = int(budget.get("calculated_ticks", -10_000))
    variance = int(budget.get("variance_ticks", -10_000))
    require(target == contract["slots"][action_slots], f"{technique_id}: target does not match slot budget")
    require(calculated == sum(derived_components.values()), f"{technique_id}: calculated ticks differ from ledger")
    require(variance == calculated - target, f"{technique_id}: variance is inconsistent")
    within = abs(variance) <= contract["tolerance"]
    require(within, f"{technique_id}: variance {variance} exceeds ±{contract['tolerance']}")
    require(budget.get("within_auto_tolerance") is within, f"{technique_id}: tolerance flag is inconsistent")


def validate_technique(
    technique: dict[str, Any],
    contract: dict[str, Any],
    technique_ids: set[str],
) -> None:
    technique_id = str(technique.get("id", ""))
    require(technique_id and technique_id not in technique_ids, f"duplicate or empty technique id: {technique_id!r}")
    technique_ids.add(technique_id)
    category = str(technique.get("category", ""))
    phase = str(technique.get("resolution_phase", ""))
    targeting = str(technique.get("targeting_mode", ""))
    require(category in {"attack", "response", "move", "recovery", "strengthen"}, f"{technique_id}: invalid category")
    require(phase in {"response", "quick_attack", "move", "general"}, f"{technique_id}: invalid resolution phase")
    require(targeting in {"attack_direction", "move_tile", "self"}, f"{technique_id}: invalid targeting mode")

    attack = technique.get("attack", {})
    raw_powers = attack.get("raw_powers", [])
    require(isinstance(raw_powers, list), f"{technique_id}: raw powers must be a list")
    require(all(isinstance(v, int) and v > 0 for v in raw_powers), f"{technique_id}: raw powers must be positive integers")
    legacy_raw = list(technique.get("hits") or ([] if not int(technique.get("damage") or 0) else [int(technique["damage"])]))
    require(raw_powers == legacy_raw, f"{technique_id}: normalized raw powers differ from legacy data")
    attack_range = attack.get("range", {})
    if raw_powers:
        require(category == "attack", f"{technique_id}: damaging action must be attack category")
        require(attack.get("damage_model") == "ABSOLUTE_RAW_POWER", f"{technique_id}: attack damage model differs")
        require(int(attack_range.get("min", -1)) == 1, f"{technique_id}: attack minimum range differs")
        require(int(attack_range.get("max", -1)) == int(technique.get("range", -2)), f"{technique_id}: attack range differs")
        require(targeting == "attack_direction", f"{technique_id}: attacks require direction targeting")
    else:
        require(attack.get("damage_model") == "NONE", f"{technique_id}: non-attack damage model differs")
        require(attack_range == {"min": 0, "max": 0}, f"{technique_id}: non-attack range must be zero")

    movement = technique.get("movement", {})
    move_range = int(technique.get("move_range", 0))
    require(int(movement.get("max_tiles", -1)) == move_range, f"{technique_id}: movement range differs")
    if move_range == 0:
        require(movement.get("timing") == "NONE" and movement.get("mode") == "NONE", f"{technique_id}: zero movement must use NONE")
    else:
        require(movement.get("timing") in {"BEFORE_ATTACK", "AFTER_ACTION", "ON_ACTION_RESOLVE"}, f"{technique_id}: movement timing missing")
        require(movement.get("mode") in {"DASH_TOWARD_TARGET", "RETREAT", "FREE_TILE"}, f"{technique_id}: movement mode missing")

    validate_budget_ledger(technique, contract)
    effects = technique.get("effects", [])
    require(isinstance(effects, list), f"{technique_id}: effects must be a list")
    has_attack = bool(raw_powers)
    for index, effect in enumerate(effects):
        require(isinstance(effect, dict), f"{technique_id}: effect {index} must be an object")
        scope = str(effect.get("scope", ""))
        trigger = str(effect.get("trigger", ""))
        effect_type = str(effect.get("type", ""))
        require(scope in contract["scopes"], f"{technique_id}: unknown effect scope {scope!r}")
        require(trigger in contract["triggers"], f"{technique_id}: unknown effect trigger {trigger!r}")
        condition = effect.get("condition")
        if condition is not None:
            require(str(condition) in contract["conditions"], f"{technique_id}: unknown effect condition {condition!r}")
        if trigger in ACTION_LEVEL_TRIGGERS:
            require(scope == "ONCE_PER_ACTION", f"{technique_id}: {trigger} requires ONCE_PER_ACTION")
        if not has_attack:
            require(trigger not in {"ON_HIT", "ON_HEALTH_DAMAGE", "ON_CLASH_WIN"}, f"{technique_id}: non-attack action cannot use {trigger}")
        if effect_type in {"sure_hit", "clash_power_bonus"}:
            require(trigger == "ON_ACTION_START", f"{technique_id}: {effect_type} must apply before clash/hit")
        if effect_type == "sure_hit":
            require(int(effect.get("amount", 0)) >= 1, f"{technique_id}: sure-hit must grant at least one stack")
        if effect_type == "retreat_after_action":
            require(trigger == "ON_ACTION_END", f"{technique_id}: retreat must occur after completed action")


def effect_amount(technique: dict[str, Any], effect_type: str) -> int:
    for effect in technique.get("effects", []):
        if effect.get("type") == effect_type:
            return int(effect.get("amount", 0))
    return 0


def derive_patch_ticks(
    changes: dict[str, Any],
    technique: dict[str, Any] | None,
    before_medical: int,
    pricing: dict[str, int],
) -> int:
    total = 0
    for field, after in changes.items():
        if field == "hits":
            require(technique is not None and isinstance(after, list), "patch: hits target must be a technique list")
            before = list(technique.get("hits") or [])
            require(all(isinstance(v, int) and v > 0 for v in after), "patch: hit powers must be positive integers")
            require(len(after) >= len(before), "patch: hit count may not decrease")
            damage_delta = sum(after) - sum(before)
            extra_delta = max(0, len(after) - len(before))
            require(damage_delta >= 0, "patch: total hit power may not decrease")
            total += damage_delta * int(pricing["raw_damage_per_point"])
            total += extra_delta * int(pricing["extra_hit_after_first"])
        elif field == "damage":
            require(technique is not None, "patch: damage target must be a technique")
            before = int(technique.get("damage") or 0)
            require(isinstance(after, int) and after >= before, "patch: damage may not decrease")
            total += (after - before) * int(pricing["raw_damage_per_point"])
        elif field == "move_range":
            require(technique is not None, "patch: movement target must be a technique")
            before = int(technique.get("move_range", 0))
            require(isinstance(after, int) and after >= before, "patch: move range may not decrease")
            total += (after - before) * int(pricing["movement_per_tile"])
        elif field in {"defense_gain", "clash_power_bonus", "health_heal", "sure_hit_stacks"}:
            require(technique is not None, f"patch: {field} target must be a technique")
            effect_type = "sure_hit" if field == "sure_hit_stacks" else field
            price_id = {
                "defense_gain": "defense_gain_per_point",
                "clash_power_bonus": "clash_power_per_point",
                "health_heal": "health_heal_per_point",
                "sure_hit_stacks": "sure_hit",
            }[field]
            before = effect_amount(technique, effect_type)
            require(isinstance(after, int) and after >= before, f"patch: {field} may not decrease")
            total += (after - before) * int(pricing[price_id])
        elif field == "medical":
            require(isinstance(after, int) and after >= before_medical, "patch: medical may not decrease")
            total += (after - before_medical) * int(pricing["medical_per_point"])
        else:
            raise PlanningDataError(f"patch: unknown field {field!r}")
    return total


def validate_manuals(data: dict[str, Any], contract: dict[str, Any]) -> tuple[dict[str, dict[str, Any]], set[str], dict[str, dict[str, int]]]:
    validate_status(data, "manuals")
    require(int(data.get("schema_version", 0)) >= 3, "manuals: schema version must include normalized cards")
    start = data.get("starting_rule", {})
    manuals = data.get("manuals", [])
    require(isinstance(manuals, list), "manuals: manuals must be a list")
    require(len(manuals) == int(start.get("candidate_manuals", -1)) == 6, "manuals: expected six candidates")
    require(int(start.get("choose", -1)) == 4, "manuals: starting choice must be four")
    require(int(start.get("starting_mastery", -1)) == 3, "manuals: starting mastery must be three")
    require(start.get("basic_ultimates_available") is True, "manuals: basic ultimates must be available from PoC start")

    acquisition = data.get("acquisition_contract", {})
    require(acquisition.get("starting_selection", {}).get("activate_one_star_passive") is True, "manuals: starting passives must activate")
    require(int(acquisition.get("new_manual_grant", {}).get("starting_mastery", -1)) == 3, "manuals: new manual grant must start at mastery 3")
    require(acquisition.get("new_manual_grant", {}).get("activate_one_star_passive") is True, "manuals: new manual passive must activate")
    duplicate = acquisition.get("duplicate_manual_grant", {})
    require(duplicate.get("conversion") == "DESIGNATED_TRAINING", "manuals: duplicate conversion differs")
    require(int(duplicate.get("designated_training_points", -1)) == 10, "manuals: duplicate conversion must grant ten points")
    require(duplicate.get("target") == "SAME_MANUAL", "manuals: duplicate conversion target differs")

    costs = {int(k): int(v) for k, v in data.get("mastery_destination_cost", {}).items()}
    required_points = sum(costs[level] for level in range(4, 11))
    require(required_points == 38, "manuals: 3-to-10 mastery cost must total 38")
    milestone = data.get("progression_contract", {}).get("focused_mastery_milestone", {})
    require(int(milestone.get("required_training_points", -1)) == 38, "manuals: focused milestone cost differs")
    require(milestone.get("target_timing") == "before_major_duel_5", "manuals: focused milestone timing differs")
    require(milestone.get("availability") == "POSSIBLE_NOT_GUARANTEED", "manuals: milestone status differs")
    sources = milestone.get("modeled_sources_before_duel_5", {})
    require(
        [int(sources.get(key, -1)) for key in (
            "focused_rewards_duels_1_to_4", "guaranteed_intermediate_focus_points", "focused_total",
            "free_rewards_duels_1_to_4", "high_efficiency_intermediate_focus_points", "free_total",
        )] == [32, 6, 38, 24, 14, 38],
        "manuals: focused source models must be 32+6 and 24+14",
    )

    manual_ids: set[str] = set()
    technique_ids: set[str] = set()
    techniques: dict[str, dict[str, Any]] = {}
    medical_by_manual: dict[str, dict[str, int]] = {}
    required_mastery = {"1", "3", "5", "7", "9", "10"}
    medical_cap = int(data.get("medical_cap", -1))
    require(medical_cap == 4, "manuals: medical cap must be four")
    for manual in manuals:
        require(isinstance(manual, dict), "manuals: manual entry must be an object")
        manual_id = str(manual.get("id", ""))
        require(manual_id and manual_id not in manual_ids, f"duplicate or empty manual id: {manual_id!r}")
        manual_ids.add(manual_id)
        medical = {str(k): int(v) for k, v in manual.get("medical", {}).items()}
        require(set(medical) == {"1", "5", "10"}, f"{manual_id}: medical milestones differ")
        require(all(0 <= value <= medical_cap for value in medical.values()), f"{manual_id}: medical outside cap")
        require(medical["1"] <= medical["5"] <= medical["10"], f"{manual_id}: medical must be cumulative")
        medical_by_manual[manual_id] = medical
        mastery = manual.get("mastery", {})
        require(set(mastery) == required_mastery, f"{manual_id}: mastery keys must be 1/3/5/7/9/10")
        local_techniques: dict[str, dict[str, Any]] = {}
        for star in ("3", "7", "10"):
            entry = mastery[star]
            require(entry.get("type") in {"technique", "ultimate"}, f"{manual_id}:{star}: technique type required")
            technique = entry.get("data", {})
            validate_technique(technique, contract, technique_ids)
            techniques[str(technique["id"])] = technique
            local_techniques[str(technique["id"])] = technique
        require(mastery["10"].get("type") == "ultimate", f"{manual_id}: 10-star entry must be an ultimate")
        for star, previous_medical_key in (("5", "1"), ("9", "5")):
            entry = mastery[star]
            require(entry.get("type") == "patch", f"{manual_id}:{star}: patch type required")
            target = str(entry.get("target", ""))
            require(target in local_techniques or target == "medical", f"{manual_id}: missing patch target {target!r}")
            changes = entry.get("changes", {})
            require(isinstance(changes, dict) and changes, f"{manual_id}:{star}: patch changes required")
            unknown = set(changes) - set(contract["patch"]["allowed_fields"])
            require(not unknown, f"{manual_id}:{star}: unknown patch fields {sorted(unknown)}")
            technique = local_techniques.get(target)
            expected_ticks = derive_patch_ticks(
                changes,
                technique,
                medical[previous_medical_key],
                contract["tables"]["pricing_ticks"],
            )
            added = int(entry.get("added_budget_ticks", -1))
            require(added == expected_ticks, f"{manual_id}:{star}: patch tick delta differs")
            require(0 < added <= int(contract["patch"]["max_added_budget_ticks"]), f"{manual_id}:{star}: patch exceeds allowance")
            if target == "medical":
                after_key = "5" if star == "5" else "10"
                require(int(changes["medical"]) == medical[after_key], f"{manual_id}:{star}: medical patch differs from cumulative table")
    return techniques, manual_ids, medical_by_manual


def validate_ai_template(
    duel_id: str,
    template: dict[str, Any],
    allowed_actions: set[str],
    action_slots: dict[str, int],
    condition_vocab: set[str],
) -> None:
    require(str(template.get("id", "")), f"{duel_id}: template id required")
    when = str(template.get("when", ""))
    require(when == "always" or when in condition_vocab, f"{duel_id}: unknown template condition {when!r}")
    actions = template.get("actions", [])
    require(isinstance(actions, list) and 1 <= len(actions) <= 3, f"{duel_id}: template must contain one to three actions")
    occupied: set[int] = set()
    for action in actions:
        action_id = str(action.get("action_id", ""))
        require(action_id in allowed_actions, f"{duel_id}: template action {action_id!r} not in candidate pool")
        require(action.get("targeting_mode") == "AUTO_FROM_CARD", f"{duel_id}: template targeting must use card contract")
        anchor = int(action.get("anchor", 0))
        span = action_slots[action_id]
        slots = set(range(anchor, anchor + span))
        require(anchor >= 1 and max(slots) <= 3, f"{duel_id}: template action exceeds three-slot bundle")
        require(not occupied & slots, f"{duel_id}: template actions overlap")
        occupied |= slots


def validate_duels(
    data: dict[str, Any],
    techniques: dict[str, dict[str, Any]],
    manual_ids: set[str],
) -> list[str]:
    validate_status(data, "duels")
    require(int(data.get("schema_version", 0)) >= 4, "duels: schema version must include AI and reward contracts")
    contract = data.get("ai_contract", {})
    require(contract.get("reads_player_uncommitted_plan") is False, "duels: AI may not read uncommitted plan")
    require(int(contract.get("candidate_limit", -1)) == 3, "duels: candidate limit must be three")
    require(float(contract.get("score_window", 0)) > 0, "duels: score window must be positive")
    require(int(contract.get("bundle_template_slots", 0)) == 3, "duels: AI templates must use three slots")
    condition_vocab = {str(v) for v in contract.get("phase_condition_vocabulary", [])}
    effect_vocab = {str(v) for v in contract.get("phase_effect_vocabulary", [])}
    require(condition_vocab and effect_vocab, "duels: AI phase vocabularies required")

    duels = data.get("major_duels", [])
    require(isinstance(duels, list) and len(duels) == 10, "duels: expected ten major duels")
    ordered = sorted(duels, key=lambda item: int(item.get("order", 0)))
    require([int(item.get("order", 0)) for item in ordered] == list(range(1, 11)), "duels: order must be 1 through 10")
    action_slots = dict(BUILTIN_ACTION_SLOTS)
    action_slots.update({key: int(value["action_slots"]) for key, value in techniques.items()})
    allowed_all = set(action_slots)
    duel_ids: set[str] = set()
    for duel in ordered:
        duel_id = str(duel.get("id", ""))
        require(duel_id and duel_id not in duel_ids, f"duels: duplicate or empty id {duel_id!r}")
        duel_ids.add(duel_id)
        candidates = [str(v) for v in duel.get("candidate_actions", [])]
        require(1 <= len(candidates) <= 3 and len(set(candidates)) == len(candidates), f"{duel_id}: candidate actions must contain one to three unique ids")
        require(set(candidates) <= allowed_all, f"{duel_id}: unknown candidate actions")
        require(bool(duel.get("public_tells")), f"{duel_id}: public tells required")
        require(bool(duel.get("public_task")), f"{duel_id}: public task required")
        phase = duel.get("phase_change", {})
        require(str(phase.get("condition", "")) in condition_vocab, f"{duel_id}: unknown phase condition")
        require(str(phase.get("effect", "")) in effect_vocab, f"{duel_id}: unknown phase effect")

        reward = duel.get("reward", {})
        require(set(reward) == {"option_set_id", "money", "faction_manual_id"}, f"{duel_id}: reward fields must reference central option set")
        require(reward.get("option_set_id") == "major_duel_standard_v1", f"{duel_id}: reward option set differs")
        require(isinstance(reward.get("money"), int) and 0 <= int(reward["money"]) <= 100, f"{duel_id}: money reward outside range")
        require(str(reward.get("faction_manual_id", "")) in manual_ids, f"{duel_id}: faction manual id unknown")

        profile = duel.get("ai_profile", {})
        weights = profile.get("weights", {})
        require(set(weights) == set(candidates), f"{duel_id}: AI weights must match candidate actions")
        require(all(isinstance(v, (int, float)) and v >= 0 for v in weights.values()), f"{duel_id}: AI weights must be non-negative")
        modifiers = profile.get("condition_modifiers", [])
        require(isinstance(modifiers, list) and modifiers, f"{duel_id}: AI modifiers required")
        for modifier in modifiers:
            require(str(modifier.get("condition", "")) in condition_vocab, f"{duel_id}: modifier condition unknown")
            require(str(modifier.get("effect", "")) in effect_vocab, f"{duel_id}: modifier effect unknown")
            require(str(modifier.get("action_id", "")) in candidates, f"{duel_id}: modifier action unknown")
            require(isinstance(modifier.get("score_delta"), (int, float)), f"{duel_id}: modifier score must be numeric")
        templates = profile.get("bundle_templates", [])
        require(isinstance(templates, list) and templates, f"{duel_id}: bundle templates required")
        for template in templates:
            validate_ai_template(duel_id, template, set(candidates), action_slots, condition_vocab)
        require(str(profile.get("fallback_action_id", "")) in candidates, f"{duel_id}: fallback action unknown")
        require(profile.get("selection") == "WITHIN_SCORE_WINDOW_THEN_DETERMINISTIC_SEED", f"{duel_id}: selection rule differs")

    require([str(item.get("stage_id", "")) for item in ordered] == EXPECTED_STAGE_IDS, "duels: stage mapping differs")
    require([str(item.get("status", "")) for item in ordered[:5]] == ["POC_PRIMARY"] * 5, "duels: major duels 1 through 5 must be POC_PRIMARY")
    require([str(item.get("status", "")) for item in ordered[5:]] == ["POC_EXPANSION"] * 5, "duels: major duels 6 through 10 must be POC_EXPANSION")
    expected_subset = [str(item["id"]) for item in ordered[:5]]
    require([str(value) for value in data.get("poc_runtime_subset", [])] == expected_subset, "duels: PoC runtime subset differs")

    stage = data.get("stage_contract", {})
    require(stage.get("tutorial", {}).get("major_duel_orders") == [1], "duels: tutorial must contain duel 1")
    require(stage.get("stage_1", {}).get("major_duel_orders") == [2, 3, 4, 5], "duels: stage 1 mapping differs")
    require(stage.get("stage_2", {}).get("major_duel_orders") == [6, 7, 8], "duels: stage 2 mapping differs")
    require(stage.get("stage_3", {}).get("major_duel_orders") == [9, 10], "duels: stage 3 mapping differs")
    require("first_ultimate_available_after_duel_order" not in stage.get("stage_1", {}), "duels: obsolete ultimate gate remains")
    require(int(stage.get("stage_1", {}).get("focused_mastery_10_possible_before_duel_order", 0)) == 5, "duels: focused timing differs")
    require(stage.get("hidden", {}).get("status") == "FUTURE_HIDDEN", "duels: hidden battle status differs")
    duel5 = ordered[4]
    require("progression_unlock" not in duel5, "duels: duel 5 must not globally unlock ultimates")
    milestone = duel5.get("progression_milestone", {})
    require(milestone.get("type") == "focused_mastery_reachability", "duels: duel 5 milestone type differs")
    require(int(milestone.get("required_training_points", -1)) == 38, "duels: duel 5 milestone cost differs")
    require(milestone.get("availability") == "POSSIBLE_NOT_GUARANTEED", "duels: milestone must remain optional")
    sources = milestone.get("modeled_sources", {})
    require([int(sources.get(k, -1)) for k in ("focused_rewards_duels_1_to_4", "guaranteed_intermediate_focus_points", "total")] == [32, 6, 38], "duels: milestone source model must be 32+6=38")
    return expected_subset


def validate_reward_options(data: dict[str, Any]) -> None:
    contract = data.get("major_duel_reward_options", {})
    require(contract.get("id") == "major_duel_standard_v1", "map: major-duel option set id differs")
    require(contract.get("ownership") == "poc_map_rewards.json", "map: reward ownership differs")
    require(contract.get("principle") == "LOWER_FREEDOM_GRANTS_HIGHER_TOTAL_VALUE", "map: reward freedom principle differs")
    options = {str(item.get("id", "")): item for item in contract.get("options", [])}
    require(set(options) == {"free_training_6", "focused_training_5_plus_3", "faction_manual_mastery_3"}, "map: reward options differ")
    free = options["free_training_6"]
    focused = options["focused_training_5_plus_3"]
    manual = options["faction_manual_mastery_3"]
    require(free.get("type") == "FREE_TRAINING" and int(free.get("free_points", -1)) == 6 and int(free.get("total_value", -1)) == 6, "map: free reward differs")
    require(focused.get("type") == "FOCUSED_TRAINING" and int(focused.get("designated_points", -1)) == 5 and int(focused.get("free_points", -1)) == 3 and int(focused.get("total_value", -1)) == 8, "map: focused reward differs")
    require(manual.get("type") == "FACTION_MANUAL" and int(manual.get("grant_mastery", -1)) == 3 and int(manual.get("comparison_value", -1)) == 10, "map: faction manual reward differs")
    require(manual.get("convertible_to_training_points") is False, "map: faction manual comparison value must not be convertible")
    require(6 < 8 < 10, "map: reward values must rise as freedom decreases")
    duplicate = contract.get("duplicate_manual_conversion", {})
    require(duplicate == {"type": "DESIGNATED_TRAINING", "points": 10, "target": "SAME_MANUAL"}, "map: duplicate conversion differs")


def validate_map(data: dict[str, Any], expected_subset: list[str], medical_by_manual: dict[str, dict[str, int]]) -> None:
    validate_status(data, "map")
    require(int(data.get("schema_version", 0)) >= 4, "map: schema version must include REVIEW contracts")
    campaign = data.get("campaign_structure", {})
    require(campaign.get("tutorial", {}).get("major_duel_orders") == [1], "map: tutorial must contain duel 1")
    stages = campaign.get("stages", [])
    require(isinstance(stages, list) and len(stages) == 3, "map: expected three stages")
    require([stage.get("major_duel_orders") for stage in stages] == [[2, 3, 4, 5], [6, 7, 8], [9, 10]], "map: stage ranges differ")
    require("first_ultimate_available_after_duel_order" not in stages[0], "map: obsolete ultimate gate remains")
    require(int(stages[0].get("focused_mastery_10_possible_before_duel_order", 0)) == 5, "map: focused timing differs")
    hidden = campaign.get("hidden_duel", {})
    require(hidden.get("status") == "FUTURE_HIDDEN" and hidden.get("position") == "after_stage_3" and hidden.get("required_for_main_ending") is False, "map: hidden duel boundary differs")

    validate_reward_options(data)
    require(data.get("training_rewards", {}).get("major_duel") == {"option_set_id": "major_duel_standard_v1"}, "map: major duel reward must be centrally owned")

    slice_data = data.get("poc_slice", {})
    require(slice_data.get("major_duels") == expected_subset, "map: PoC slice differs")
    require(slice_data.get("included_sections") == ["tutorial", "stage_1"], "map: PoC sections differ")
    require(int(slice_data.get("gap_count", -1)) == 4, "map: five duels must create four gaps")
    per_gap = slice_data.get("intermediate_nodes_per_gap", {})
    require((int(per_gap.get("min", -1)), float(per_gap.get("target", -1)), int(per_gap.get("max", -1))) == (2, 2.5, 3), "map: every gap must contain two to three nodes")
    require([int(slice_data.get("total_intermediate_nodes", {}).get(k, -1)) for k in ("min", "target", "max")] == [8, 10, 12], "map: node totals differ")
    require([int(slice_data.get("target_visited_nodes", {}).get(k, -1)) for k in ("min", "target", "max")] == [13, 15, 17], "map: visited totals differ")
    require(slice_data.get("basic_ultimates_available_from_start") is True, "map: basic ultimates must be available from start")
    require("first_ultimate_available_after_duel_id" not in slice_data, "map: obsolete ultimate duel gate remains")
    milestone = slice_data.get("focused_mastery_milestone", {})
    require(int(milestone.get("required_training_points", -1)) == 38, "map: focused milestone cost differs")
    require(milestone.get("possible_before_major_duel_id") == expected_subset[4], "map: focused milestone duel differs")
    require(milestone.get("availability") == "POSSIBLE_NOT_GUARANTEED", "map: focused milestone status differs")
    paths = milestone.get("validated_paths", {})
    require(paths.get("focused_rewards_plus_guaranteed_nodes") == {"duel_rewards": 32, "intermediate_points": 6, "total": 38, "availability": "GUARANTEED_IF_OPTIONS_CHOSEN"}, "map: focused reward path differs")
    require(paths.get("free_rewards_plus_high_efficiency_nodes") == {"duel_rewards": 24, "intermediate_points": 14, "total": 38, "availability": "POSSIBLE_NOT_GUARANTEED"}, "map: free reward path differs")

    node_types = data.get("node_types", {})
    require(set(node_types) == REQUIRED_NODE_TYPES, "map: node type catalog differs")
    catalog = data.get("node_catalog", {})
    require(isinstance(catalog, dict) and catalog, "map: node catalog required")
    for node_id, node in catalog.items():
        require(node_id and node.get("type") in REQUIRED_NODE_TYPES, f"map: invalid node {node_id!r}")
        for choice in node.get("reward_choices", []):
            require(isinstance(choice, dict) and str(choice.get("id", "")), f"map: node {node_id} reward choice id required")
            for key, value in choice.items():
                if key != "id":
                    require(isinstance(value, int) and value >= 0, f"map: node {node_id} reward values must be non-negative integers")
        if "reward_formula_id" in node:
            require(str(node["reward_formula_id"]) in data.get("training_rewards", {}), f"map: node {node_id} reward formula unknown")

    generation = data.get("generation_contract", {})
    require(generation == {"seed_field": "run_seed", "deterministic_for_same_seed": True, "reroll_on_reload": False}, "map: generation seed policy differs")
    gaps = data.get("poc_gap_constraints", [])
    require(isinstance(gaps, list) and len(gaps) == 4, "map: expected four gap constraints")
    guaranteed = 0
    target = 0
    for index, gap in enumerate(gaps):
        require(gap.get("after_duel_id") == expected_subset[index] and gap.get("before_duel_id") == expected_subset[index + 1], f"map: gap {index + 1} duel references differ")
        require(int(gap.get("min_nodes", 0)) == 2 and int(gap.get("max_nodes", 0)) == 3, f"map: gap {index + 1} node bounds differ")
        candidates = set(gap.get("candidate_node_ids", []))
        required_ids = set(gap.get("required_node_ids", []))
        require(candidates and candidates <= set(catalog), f"map: gap {index + 1} candidates unknown")
        require(required_ids and required_ids <= candidates, f"map: gap {index + 1} required nodes unknown")
        guaranteed += int(gap.get("guaranteed_focus_points", -1))
        target += int(gap.get("target_focus_points", -1))
    require(guaranteed == 6, "map: guaranteed focus points before duel 5 must total six")
    require(target == 14, "map: high-efficiency focus points before duel 5 must total fourteen")

    grade = data.get("performance_grade", {})
    calculation = grade.get("calculation", {})
    require(calculation.get("dimension_scale") == {"min": 0, "max": 100}, "map: dimension scale differs")
    require(calculation.get("weighted_total_formula") == "SUM(DIMENSION_SCORE_X_WEIGHT_DIV_100)", "map: weighted formula differs")
    dimensions = grade.get("dimensions", {})
    require(set(dimensions) == {"threat_response", "tactical_execution", "resource_use", "damage_management", "public_enemy_task"}, "map: grade dimensions differ")
    weights = []
    for dimension_id, dimension in dimensions.items():
        weight = int(dimension.get("weight", -1))
        require(1 <= weight <= 100, f"map: {dimension_id} weight outside 1..100")
        weights.append(weight)
        require(dimension.get("formula_id") in FORMULA_IDS, f"map: {dimension_id} formula unknown")
        require(isinstance(dimension.get("input_events"), list) and dimension["input_events"], f"map: {dimension_id} input events required")
        require(dimension.get("clamp") == {"min": 0, "max": 100}, f"map: {dimension_id} clamp differs")
        require(0 <= int(dimension.get("zero_denominator_score", -1)) <= 100, f"map: {dimension_id} zero-denominator score outside range")
    require(sum(weights) == 100, "map: performance weights must sum to 100")
    require([int(grade.get("thresholds", {})[k]) for k in ("S", "A", "B", "C")] == [85, 70, 55, 0], "map: grade thresholds differ")

    medical = data.get("medical", {})
    require(int(medical.get("start", -1)) == 0 and int(medical.get("cap", -1)) == 4, "map: medical range must be 0 to 4")
    require(str(medical.get("post_victory_heal", "")) == "min(missing_health, 2 + medical)", "map: recovery formula differs")
    clear = medical_by_manual["clear_heart_nurturing"]
    expected_deltas = {1: clear["1"], 5: clear["5"] - clear["1"], 10: clear["10"] - clear["5"]}
    sources = [item for item in medical.get("planned_sources", []) if item.get("source") == "clear_heart_nurturing"]
    require(len(sources) == 3, "map: clear-heart medical sources must contain three milestones")
    for source in sources:
        mastery = int(source.get("at_mastery", -1))
        require(mastery in expected_deltas and int(source.get("amount", -1)) == expected_deltas[mastery], "map: medical source drift from manual cumulative values")
    rare = [item for item in medical.get("planned_sources", []) if item.get("source") == "rare_run_event"]
    require(rare == [{"source": "rare_run_event", "amount": 1, "limit": "once_per_run"}], "map: rare medical source differs")

    full = data.get("full_run_hypothesis", {})
    require(int(full.get("mandatory_major_duels", 0)) == 10 and int(full.get("gap_count", 0)) == 9, "map: full-run duel/gap counts differ")
    require([int(full.get("expected_total_visited_nodes", {}).get(k, -1)) for k in ("min", "target", "max")] == [28, 33, 37], "map: full-run visited totals differ")
    combats = full.get("expected_total_combats", {})
    require(int(combats.get("min", 0)) <= int(combats.get("target", -1)) <= int(combats.get("max", -2)), "map: combat range invalid")


def validate_run_state(data: dict[str, Any]) -> None:
    validate_status(data, "run")
    require(data.get("owner") == "docs/09_COMBAT_SYSTEM_ARCHITECTURE.md", "run: owner differs")
    profile = data.get("permanent_profile_state", {})
    require(profile.get("fields") == ["permanent_currency"] and profile.get("rollback_with_run_state") is False, "run: permanent profile boundary differs")
    run_state = data.get("run_state", {})
    required_run_fields = {"run_id", "run_seed", "current_node_id", "visited_node_ids", "current_health", "maximum_health", "money", "manual_mastery_by_id", "unlocked_technique_ids", "medical", "current_battle_id", "same_battle_retry_count"}
    require(set(run_state.get("fields", [])) == required_run_fields, "run: RunState fields differ")
    require(run_state.get("health_carries_between_battles") is True, "run: health must carry between battles")
    require(run_state.get("temporary_combat_statuses_persist") is False, "run: temporary statuses must not persist")
    snapshot = data.get("pre_battle_snapshot", {})
    require(snapshot.get("id") == "PRE_BATTLE_RUN_STATE" and snapshot.get("includes_all_run_state_fields") is True and snapshot.get("excludes_permanent_profile_state") is True, "run: pre-battle snapshot boundary differs")
    retry = data.get("defeat_retry", {})
    require(retry.get("restore_snapshot") == "PRE_BATTLE_RUN_STATE", "run: retry snapshot differs")
    require(retry.get("same_seed") is True, "run: retry must preserve seed")
    require(retry.get("permanent_currency_costs_same_battle") == [1, 2, 3], "run: retry costs must be 1/2/3")
    require(int(retry.get("cost_cap", -1)) == 3, "run: retry cost cap must be three")
    require(retry.get("counter_reset") == "WHEN_ENTERING_DIFFERENT_BATTLE", "run: retry counter reset differs")
    require(retry.get("charge_order") == "CHECK_BALANCE_THEN_CHARGE_THEN_RESTORE", "run: retry charge order differs")
    require(retry.get("paid_currency_is_not_rolled_back") is True, "run: paid currency must not roll back")
    require(set(retry.get("rollback", [])) == {"battle_damage", "battle_resource_changes", "temporary_statuses", "unearned_rewards", "node_advance"}, "run: retry rollback fields differ")
    require(set(retry.get("insufficient_currency", [])) == {"ABANDON_RUN", "RETURN_TO_TITLE"}, "run: insufficient-currency actions differ")
    victory = data.get("victory_commit", {})
    require(victory.get("health_formula") == "min(maximum_health, combat_health + 2 + medical)", "run: victory heal formula differs")
    require(victory.get("grant_reward_once") is True and victory.get("advance_node_once") is True, "run: victory must commit once")
    debug = data.get("debug_restart_boundary", {})
    require(debug.get("legacy_t0_restart_is_not_paid_run_retry") is True and debug.get("available_in_poc_run_flow") is False, "run: debug restart boundary differs")


def validate_sanity(data: dict[str, Any]) -> None:
    validate_status(data, "sanity")
    require(str(data.get("status", "")).startswith("UNVERIFIED"), "sanity: status must remain unverified")
    require(int(data.get("runs", 0)) > 0, "sanity: runs must be positive")
    results = data.get("results", {})
    require(float(results.get("median_rounds", 0)) > 0, "sanity: median rounds must be positive")
    require(sum(int(value) for value in results.get("distribution", {}).values()) == int(data["runs"]), "sanity: distribution must sum to runs")
    growth = data.get("growth_reachability", {})
    require(int(growth.get("required_training_points", -1)) == 38 and int(growth.get("modeled_points_before_major_duel_5", -1)) == 38, "sanity: growth reachability must use 38 points")
    require(growth.get("result") == "POSSIBLE_NOT_GUARANTEED", "sanity: growth status must remain unverified")
    paths = growth.get("validated_paths", {})
    require(paths.get("focused_rewards_plus_guaranteed_nodes") == {"duel_rewards": 32, "intermediate_points": 6, "total": 38}, "sanity: focused path differs")
    require(paths.get("free_rewards_plus_high_efficiency_nodes") == {"duel_rewards": 24, "intermediate_points": 14, "total": 38}, "sanity: free path differs")


def run(root: Path) -> None:
    directory = root / "docs/planning-data"
    loaded = {key: load_object(directory / filename) for key, filename in FILES.items()}
    contract = validate_budget(loaded["budget"])
    techniques, manual_ids, medical_by_manual = validate_manuals(loaded["manuals"], contract)
    expected_subset = validate_duels(loaded["duels"], techniques, manual_ids)
    validate_map(loaded["map"], expected_subset, medical_by_manual)
    validate_run_state(loaded["run"])
    validate_sanity(loaded["sanity"])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    args = parser.parse_args()
    try:
        run(Path(args.root).resolve())
    except PlanningDataError as exc:
        print(f"PoC planning data: FAIL\n{exc}")
        return 1
    print("PoC planning data: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
