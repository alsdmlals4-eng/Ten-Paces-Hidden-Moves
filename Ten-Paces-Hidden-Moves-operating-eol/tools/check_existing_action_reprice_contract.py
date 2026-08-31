#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
from typing import Any


class RepriceContractError(ValueError):
    pass


EXPECTED_IDS = {
    "quick_attack",
    "heavy_attack",
    "basic_palm",
    "flowing_cloud_triple",
    "vajra_guard",
    "cloud_hand_return",
    "pursuing_wind_thrust",
    "clear_heart_breath",
    "iron_step_drift",
    "falling_petal_chasing_sword",
    "rebounding_vajra_fist",
    "four_ounces_move_thousand_pounds",
    "chained_road_lock",
    "returning_qi_meridian",
    "ten_paces_position_reversal",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RepriceContractError(message)


def as_int(value: Any, message: str) -> int:
    require(isinstance(value, int) and not isinstance(value, bool), message)
    return int(value)


def validate(data: dict[str, Any]) -> None:
    require(data.get("schema_version") == 1, "schema_version must be 1")
    require(data.get("decision_id") == "TEN-DEC-20260804-EXISTING-ACTIONS-REPRICE-01", "decision id differs")
    require(data.get("authority_status") == "CURRENT_APPROVED_PLANNING", "authority status differs")
    pricing = data.get("pricing", {})
    require(pricing == {
        "movement_ticks_per_tile": 15,
        "range_ticks_per_tile_beyond_one": 15,
        "stamina_allowance_ticks_per_point": 4,
        "internal_allowance_ticks_per_point": 7,
        "slot_budget_ticks": {"1": 20, "2": 50, "3": 80},
        "automatic_tolerance_ticks": 5,
        "max_stamina": 5,
        "max_internal": 4,
    }, "pricing contract differs")

    exclusions = data.get("exclusions", [])
    require("martial_10_star_ultimates_effects_unapproved" in exclusions, "10-star ultimate exclusion missing")
    require(data.get("runtime_boundary") == {
        "html_poc_changed": False,
        "godot_runtime_changed": False,
        "human_balance_validation": "NOT_RUN",
    }, "runtime boundary differs")

    actions = data.get("actions")
    require(isinstance(actions, list) and len(actions) == 15, "exactly 15 actions required")
    ids = [str(action.get("action_id", "")) for action in actions]
    require(len(ids) == len(set(ids)), "duplicate action id")
    require(set(ids) == EXPECTED_IDS, "approved action coverage differs")

    categories = {"basic_attack": 0, "technique_1": 0, "technique_2": 0}
    slot_budgets = pricing["slot_budget_ticks"]
    for action in actions:
        action_id = str(action["action_id"])
        category = str(action.get("category", ""))
        require(category in categories, f"{action_id}: category differs")
        categories[category] += 1

        slots = as_int(action.get("effective_action_slots"), f"{action_id}: slots must be integer")
        require(str(slots) in slot_budgets, f"{action_id}: unsupported slot count")
        costs = action.get("effective_costs", {})
        stamina = as_int(costs.get("stamina"), f"{action_id}: stamina cost must be integer")
        internal = as_int(costs.get("internal"), f"{action_id}: internal cost must be integer")
        require(0 <= stamina <= pricing["max_stamina"], f"{action_id}: stamina cost unaffordable")
        require(0 <= internal <= pricing["max_internal"], f"{action_id}: internal cost unaffordable")

        movement_tiles = as_int(action.get("movement_tiles"), f"{action_id}: movement tiles must be integer")
        max_range = as_int(action.get("max_range"), f"{action_id}: max range must be integer")
        require(movement_tiles >= 0, f"{action_id}: movement tiles negative")
        require(max_range >= 0, f"{action_id}: max range negative")
        base_effect = as_int(action.get("base_effect_ticks_excluding_distance"), f"{action_id}: base effect ticks must be integer")
        expected_distance = movement_tiles * 15 + max(0, max_range - 1) * 15
        require(action.get("distance_effect_ticks") == expected_distance, f"{action_id}: distance effect cost differs")
        expected_effect = base_effect + expected_distance
        require(action.get("effect_cost_ticks") == expected_effect, f"{action_id}: effect cost differs")

        condition = as_int(action.get("condition_allowance_ticks"), f"{action_id}: condition allowance must be integer")
        other = as_int(action.get("other_resource_allowance_ticks"), f"{action_id}: other allowance must be integer")
        expected_available = slot_budgets[str(slots)] + stamina * 4 + internal * 7 + condition + other
        require(action.get("available_budget_ticks") == expected_available, f"{action_id}: available budget differs")
        expected_variance = expected_effect - expected_available
        require(action.get("variance_ticks") == expected_variance, f"{action_id}: variance differs")
        require(abs(expected_variance) <= 5, f"{action_id}: variance exceeds ±5 ticks")
        require(action.get("preserve_effect_identity") is True, f"{action_id}: effect identity must be preserved")

    require(categories == {"basic_attack": 3, "technique_1": 6, "technique_2": 6}, "category counts differ")


def run(root: pathlib.Path) -> None:
    path = root / "docs" / "planning-data" / "approved_20260804_existing_action_reprice_contract.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    validate(data)
    print("existing approved action reprice contract: PASS")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=pathlib.Path, default=pathlib.Path.cwd())
    args = parser.parse_args()
    run(args.root.resolve())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
