#!/usr/bin/env python3
"""Validate editable, non-runtime PoC planning data."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


class PlanningDataError(RuntimeError):
    pass


FILES = {
    "budget": "poc_balance_budget.json",
    "manuals": "poc_martial_arts.json",
    "duels": "poc_enemy_duels.json",
    "map": "poc_map_rewards.json",
    "sanity": "poc_sanity_model.json",
}

BUILTIN_ACTION_IDS = {
    "basic_move", "basic_footwork", "basic_guard", "basic_evade",
    "basic_quick_attack", "basic_heavy_attack", "basic_meditate", "basic_stance",
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


def load_object(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise PlanningDataError(f"missing planning data: {path.as_posix()}") from exc
    except json.JSONDecodeError as exc:
        raise PlanningDataError(
            f"invalid JSON: {path.as_posix()}:{exc.lineno}:{exc.colno}: {exc.msg}"
        ) from exc
    if not isinstance(value, dict):
        raise PlanningDataError(f"planning JSON root must be an object: {path.as_posix()}")
    return value


def require(condition: bool, message: str) -> None:
    if not condition:
        raise PlanningDataError(message)


def validate_status(data: dict[str, Any], label: str) -> None:
    require(data.get("editable") is True or label == "sanity", f"{label}: editable must be true")
    role = str(data.get("data_role", ""))
    require(role in {"NON_RUNTIME_POC_PLANNING", "ANALYSIS_ONLY"}, f"{label}: invalid data_role")


def validate_budget(data: dict[str, Any]) -> tuple[dict[int, int], int, set[str], set[str]]:
    validate_status(data, "budget")
    unit = data.get("unit", {})
    require(unit.get("display_step") == 0.05, "budget: display_step must be 0.05")
    require(unit.get("ticks_per_display_step") == 1, "budget: 0.05 must equal one tick")
    slots = {int(key): int(value) for key, value in data.get("slot_budget_ticks", {}).items()}
    require(slots == {1: 20, 2: 50, 3: 80}, "budget: slot targets must be 20/50/80")
    tolerance = int(data.get("automatic_acceptance_tolerance_ticks", -1))
    require(tolerance == 5, "budget: automatic tolerance must be five ticks")
    contract = data.get("effect_contract", {})
    scopes = {str(value) for value in contract.get("scope", [])}
    triggers = {str(value) for value in contract.get("trigger", [])}
    require(scopes == {"PER_HIT", "ONCE_PER_ACTION"}, "budget: effect scopes differ")
    require(triggers == EXPECTED_EFFECT_TRIGGERS, "budget: effect triggers differ")
    require(
        contract.get("action_level_triggers_require_once_per_action") is True,
        "budget: action-level effects must be once per action",
    )
    migration = data.get("migration_policy", {})
    require(
        migration.get("central_price_change_auto_edits_existing_techniques") is False,
        "budget: central price changes must not auto-edit techniques",
    )
    return slots, tolerance, scopes, triggers


def validate_technique(
    technique: dict[str, Any],
    slots: dict[int, int],
    tolerance: int,
    scopes: set[str],
    triggers: set[str],
    technique_ids: set[str],
) -> None:
    technique_id = str(technique.get("id", ""))
    require(technique_id and technique_id not in technique_ids, f"duplicate or empty technique id: {technique_id!r}")
    technique_ids.add(technique_id)
    action_slots = int(technique.get("action_slots", 0))
    require(action_slots in slots, f"{technique_id}: invalid action_slots")
    budget = technique.get("budget", {})
    target = int(budget.get("target_ticks", -1))
    calculated = int(budget.get("calculated_ticks", -10_000))
    variance = int(budget.get("variance_ticks", -10_000))
    components = budget.get("components", {})
    require(isinstance(components, dict) and components, f"{technique_id}: budget components required")
    component_total = sum(int(value) for value in components.values())
    require(target == slots[action_slots], f"{technique_id}: target does not match slot budget")
    require(calculated == component_total, f"{technique_id}: calculated ticks differ from components")
    require(variance == calculated - target, f"{technique_id}: variance is inconsistent")
    within = abs(variance) <= tolerance
    require(within, f"{technique_id}: variance {variance} exceeds ±{tolerance}")
    require(budget.get("within_auto_tolerance") is within, f"{technique_id}: tolerance flag is inconsistent")

    effects = technique.get("effects", [])
    require(isinstance(effects, list), f"{technique_id}: effects must be a list")
    has_attack = bool(technique.get("hits")) or int(technique.get("damage") or 0) > 0
    for index, effect in enumerate(effects):
        require(isinstance(effect, dict), f"{technique_id}: effect {index} must be an object")
        scope = str(effect.get("scope", ""))
        trigger = str(effect.get("trigger", ""))
        effect_type = str(effect.get("type", ""))
        require(scope in scopes, f"{technique_id}: unknown effect scope {scope!r}")
        require(trigger in triggers, f"{technique_id}: unknown effect trigger {trigger!r}")
        if trigger in ACTION_LEVEL_TRIGGERS:
            require(scope == "ONCE_PER_ACTION", f"{technique_id}: {trigger} requires ONCE_PER_ACTION")
        if not has_attack:
            require(
                trigger not in {"ON_HIT", "ON_HEALTH_DAMAGE", "ON_CLASH_WIN"},
                f"{technique_id}: non-attack action cannot use {trigger}",
            )
        if effect_type in {"sure_hit", "clash_power_bonus"}:
            require(trigger == "ON_ACTION_START", f"{technique_id}: {effect_type} must apply before clash/hit")
        if effect_type == "retreat_after_action":
            require(trigger == "ON_ACTION_END", f"{technique_id}: retreat must occur after completed action")


def validate_manuals(data: dict[str, Any], slots: dict[int, int], tolerance: int, scopes: set[str], triggers: set[str]) -> set[str]:
    validate_status(data, "manuals")
    start = data.get("starting_rule", {})
    manuals = data.get("manuals", [])
    require(isinstance(manuals, list), "manuals: manuals must be a list")
    require(len(manuals) == int(start.get("candidate_manuals", -1)) == 6, "manuals: expected six candidates")
    require(int(start.get("choose", -1)) == 4, "manuals: starting choice must be four")
    require(int(start.get("starting_mastery", -1)) == 3, "manuals: starting mastery must be three")
    require(start.get("basic_ultimates_available") is True, "manuals: basic ultimates must be available from PoC start")
    progression = data.get("progression_contract", {})
    milestone = progression.get("focused_mastery_milestone", {})
    costs = {int(k): int(v) for k, v in data.get("mastery_destination_cost", {}).items()}
    required_points = sum(costs[level] for level in range(4, 11))
    require(required_points == 38, "manuals: 3-to-10 mastery cost must total 38")
    require(int(milestone.get("required_training_points", -1)) == required_points, "manuals: focused milestone cost differs")
    require(milestone.get("target_timing") == "before_major_duel_5", "manuals: focused milestone timing differs")
    require(milestone.get("availability") == "POSSIBLE_NOT_GUARANTEED", "manuals: focused milestone must remain optional")
    sources = milestone.get("modeled_sources_before_duel_5", {})
    require([int(sources.get(key, -1)) for key in ("major_duels_1_to_4_at_B_grade", "focused_intermediate_growth", "total")] == [24, 14, 38], "manuals: focused source model must be 24+14=38")

    manual_ids: set[str] = set()
    technique_ids: set[str] = set()
    required_mastery = {"1", "3", "5", "7", "9", "10"}
    medical_cap = int(data.get("medical_cap", -1))
    require(medical_cap == 4, "manuals: medical cap must be four")
    for manual in manuals:
        require(isinstance(manual, dict), "manuals: manual entry must be an object")
        manual_id = str(manual.get("id", ""))
        require(manual_id and manual_id not in manual_ids, f"duplicate or empty manual id: {manual_id!r}")
        manual_ids.add(manual_id)
        medical = manual.get("medical", {})
        require(all(0 <= int(value) <= medical_cap for value in medical.values()), f"{manual_id}: medical outside cap")
        mastery = manual.get("mastery", {})
        require(set(mastery) == required_mastery, f"{manual_id}: mastery keys must be 1/3/5/7/9/10")
        local_techniques: set[str] = set()
        for star in ("3", "7", "10"):
            entry = mastery[star]
            require(entry.get("type") in {"technique", "ultimate"}, f"{manual_id}:{star}: technique type required")
            technique = entry.get("data", {})
            validate_technique(technique, slots, tolerance, scopes, triggers, technique_ids)
            local_techniques.add(str(technique["id"]))
        require(mastery["10"].get("type") == "ultimate", f"{manual_id}: 10-star entry must be an ultimate")
        for star in ("5", "9"):
            entry = mastery[star]
            require(entry.get("type") == "patch", f"{manual_id}:{star}: patch type required")
            target = str(entry.get("target", ""))
            require(target in local_techniques or target == "medical", f"{manual_id}: missing patch target {target!r}")
    return technique_ids


def validate_duels(data: dict[str, Any], technique_ids: set[str]) -> list[str]:
    validate_status(data, "duels")
    contract = data.get("ai_contract", {})
    require(contract.get("reads_player_uncommitted_plan") is False, "duels: AI may not read uncommitted plan")
    require(int(contract.get("candidate_limit", -1)) == 3, "duels: candidate limit must be three")
    duels = data.get("major_duels", [])
    require(isinstance(duels, list) and len(duels) == 10, "duels: expected ten major duels")
    ordered = sorted(duels, key=lambda item: int(item.get("order", 0)))
    require([int(item.get("order", 0)) for item in ordered] == list(range(1, 11)), "duels: order must be 1 through 10")

    duel_ids: set[str] = set()
    allowed_actions = BUILTIN_ACTION_IDS | technique_ids
    for duel in ordered:
        duel_id = str(duel.get("id", ""))
        require(duel_id and duel_id not in duel_ids, f"duels: duplicate or empty id {duel_id!r}")
        duel_ids.add(duel_id)
        candidates = duel.get("candidate_actions", [])
        require(isinstance(candidates, list) and 1 <= len(candidates) <= 3, f"{duel_id}: candidate actions must contain one to three ids")
        unknown = [str(value) for value in candidates if str(value) not in allowed_actions]
        require(not unknown, f"{duel_id}: unknown candidate actions {unknown}")
        require(bool(duel.get("public_tells")), f"{duel_id}: public tells required")
        require(bool(duel.get("public_task")), f"{duel_id}: public task required")

    require([str(item.get("stage_id", "")) for item in ordered] == EXPECTED_STAGE_IDS, "duels: stage mapping differs")
    require([str(item.get("status", "")) for item in ordered[:5]] == ["POC_PRIMARY"] * 5, "duels: major duels 1 through 5 must be POC_PRIMARY")
    require([str(item.get("status", "")) for item in ordered[5:]] == ["POC_EXPANSION"] * 5, "duels: major duels 6 through 10 must be POC_EXPANSION")
    expected_subset = [str(item["id"]) for item in ordered[:5]]
    require([str(value) for value in data.get("poc_runtime_subset", [])] == expected_subset, "duels: PoC runtime subset must be major duels 1 through 5")

    stage_contract = data.get("stage_contract", {})
    require(stage_contract.get("tutorial", {}).get("major_duel_orders") == [1], "duels: tutorial must contain major duel 1")
    require(stage_contract.get("stage_1", {}).get("major_duel_orders") == [2, 3, 4, 5], "duels: stage 1 must contain major duels 2 through 5")
    require(stage_contract.get("stage_2", {}).get("major_duel_orders") == [6, 7, 8], "duels: stage 2 must contain major duels 6 through 8")
    require(stage_contract.get("stage_3", {}).get("major_duel_orders") == [9, 10], "duels: stage 3 must contain major duels 9 and 10")
    require("first_ultimate_available_after_duel_order" not in stage_contract.get("stage_1", {}), "duels: obsolete duel-gated ultimate unlock remains")
    require(int(stage_contract.get("stage_1", {}).get("focused_mastery_10_possible_before_duel_order", 0)) == 5, "duels: focused 10-star timing must be duel 5")
    hidden = stage_contract.get("hidden", {})
    require(hidden.get("status") == "FUTURE_HIDDEN", "duels: hidden battle must remain future scope")
    require(bool(hidden.get("examples")), "duels: hidden battle examples are required")

    duel5 = ordered[4]
    require("progression_unlock" not in duel5, "duels: major duel 5 must not globally unlock ultimates")
    milestone = duel5.get("progression_milestone", {})
    require(milestone.get("type") == "focused_mastery_reachability", "duels: duel 5 milestone type differs")
    require(int(milestone.get("target_mastery", -1)) == 10, "duels: duel 5 milestone must target 10-star")
    require(int(milestone.get("required_training_points", -1)) == 38, "duels: duel 5 milestone must require 38 points")
    require(milestone.get("availability") == "POSSIBLE_NOT_GUARANTEED", "duels: duel 5 mastery must not be guaranteed")
    return expected_subset


def validate_map(data: dict[str, Any], expected_subset: list[str]) -> None:
    validate_status(data, "map")
    campaign = data.get("campaign_structure", {})
    require(campaign.get("tutorial", {}).get("major_duel_orders") == [1], "map: tutorial must contain major duel 1")
    stages = campaign.get("stages", [])
    require(isinstance(stages, list) and len(stages) == 3, "map: expected three stages")
    require([stage.get("major_duel_orders") for stage in stages] == [[2, 3, 4, 5], [6, 7, 8], [9, 10]], "map: stage duel ranges differ")
    require("first_ultimate_available_after_duel_order" not in stages[0], "map: obsolete duel-gated ultimate unlock remains")
    require(int(stages[0].get("focused_mastery_10_possible_before_duel_order", 0)) == 5, "map: focused 10-star timing must be duel 5")
    hidden = campaign.get("hidden_duel", {})
    require(hidden.get("status") == "FUTURE_HIDDEN", "map: hidden duel must remain future scope")
    require(hidden.get("position") == "after_stage_3", "map: hidden duel must follow stage 3")
    require(hidden.get("required_for_main_ending") is False, "map: hidden duel must be optional")

    slice_data = data.get("poc_slice", {})
    require(slice_data.get("major_duels") == expected_subset, "map: PoC slice must use major duels 1 through 5")
    require(slice_data.get("included_sections") == ["tutorial", "stage_1"], "map: PoC must include tutorial and stage 1")
    require(int(slice_data.get("gap_count", -1)) == 4, "map: five duels must create four gaps")
    per_gap = slice_data.get("intermediate_nodes_per_gap", {})
    require((int(per_gap.get("min", -1)), float(per_gap.get("target", -1)), int(per_gap.get("max", -1))) == (2, 2.5, 3), "map: every gap must contain two to three intermediate nodes")
    totals = slice_data.get("total_intermediate_nodes", {})
    require([int(totals.get(key, -1)) for key in ("min", "target", "max")] == [8, 10, 12], "map: PoC intermediate-node totals must be 8/10/12")
    visited = slice_data.get("target_visited_nodes", {})
    require([int(visited.get(key, -1)) for key in ("min", "target", "max")] == [13, 15, 17], "map: PoC visited-node totals must be 13/15/17")
    require(slice_data.get("basic_ultimates_available_from_start") is True, "map: basic ultimates must be available from start")
    require("first_ultimate_available_after_duel_id" not in slice_data, "map: obsolete first-ultimate duel gate remains")
    milestone = slice_data.get("focused_mastery_milestone", {})
    require(int(milestone.get("target_manual_mastery", -1)) == 10, "map: focused milestone must target 10-star")
    require(int(milestone.get("required_training_points", -1)) == 38, "map: focused milestone must require 38 points")
    require(milestone.get("possible_before_major_duel_id") == expected_subset[4], "map: focused milestone must reference duel 5")
    require(milestone.get("availability") == "POSSIBLE_NOT_GUARANTEED", "map: focused milestone must remain optional")
    sources = milestone.get("modeled_sources", {})
    require([int(sources.get(key, -1)) for key in ("major_duels_1_to_4_at_B_grade", "focused_intermediate_growth", "total")] == [24, 14, 38], "map: focused source model must be 24+14=38")

    full = data.get("full_run_hypothesis", {})
    require(int(full.get("mandatory_major_duels", 0)) == 10, "map: full run must use ten major duels")
    require(int(full.get("gap_count", 0)) == 9, "map: full run must contain nine duel gaps")
    full_gap = full.get("intermediate_nodes_between_major_duels", {})
    require((int(full_gap.get("min", -1)), float(full_gap.get("target", -1)), int(full_gap.get("max", -1))) == (2, 2.5, 3), "map: full-run gaps must contain two to three intermediate nodes")
    full_nodes = full.get("expected_total_visited_nodes", {})
    require([int(full_nodes.get(key, -1)) for key in ("min", "target", "max")] == [28, 33, 37], "map: full-run visited-node totals must be 28/33/37")
    combats = full.get("expected_total_combats", {})
    require(int(combats.get("min", 0)) <= int(combats.get("target", -1)) <= int(combats.get("max", -2)), "map: combat range is invalid")
    weights = data.get("performance_grade", {}).get("dimensions", {})
    require(sum(int(value) for value in weights.values()) == 100, "map: performance weights must sum to 100")
    thresholds = data.get("performance_grade", {}).get("thresholds", {})
    require([int(thresholds[key]) for key in ("S", "A", "B", "C")] == [85, 70, 55, 0], "map: grade thresholds differ")
    medical = data.get("medical", {})
    require(int(medical.get("start", -1)) == 0 and int(medical.get("cap", -1)) == 4, "map: medical range must be 0 to 4")
    require(str(medical.get("post_victory_heal", "")) == "min(missing_health, 2 + medical)", "map: recovery formula differs")


def validate_sanity(data: dict[str, Any]) -> None:
    validate_status(data, "sanity")
    require(str(data.get("status", "")).startswith("UNVERIFIED"), "sanity: status must remain unverified")
    require(int(data.get("runs", 0)) > 0, "sanity: runs must be positive")
    results = data.get("results", {})
    require(float(results.get("median_rounds", 0)) > 0, "sanity: median rounds must be positive")
    distribution = results.get("distribution", {})
    require(sum(int(value) for value in distribution.values()) == int(data["runs"]), "sanity: distribution must sum to runs")
    growth = data.get("growth_reachability", {})
    require(int(growth.get("required_training_points", -1)) == 38, "sanity: growth reachability must use 38 points")
    require(growth.get("result") == "POSSIBLE_NOT_GUARANTEED", "sanity: growth reachability must remain unverified")


def run(root: Path) -> None:
    directory = root / "docs/planning-data"
    loaded = {key: load_object(directory / filename) for key, filename in FILES.items()}
    slots, tolerance, scopes, triggers = validate_budget(loaded["budget"])
    technique_ids = validate_manuals(loaded["manuals"], slots, tolerance, scopes, triggers)
    expected_subset = validate_duels(loaded["duels"], technique_ids)
    validate_map(loaded["map"], expected_subset)
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
