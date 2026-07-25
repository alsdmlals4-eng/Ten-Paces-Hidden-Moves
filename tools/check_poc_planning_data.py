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
    "basic_move",
    "basic_footwork",
    "basic_guard",
    "basic_evade",
    "basic_quick_attack",
    "basic_heavy_attack",
    "basic_meditate",
    "basic_stance",
}


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
    raw_slots = data.get("slot_budget_ticks", {})
    slots = {int(key): int(value) for key, value in raw_slots.items()}
    require(slots == {1: 20, 2: 50, 3: 80}, "budget: slot targets must be 20/50/80")
    tolerance = int(data.get("automatic_acceptance_tolerance_ticks", -1))
    require(tolerance == 5, "budget: automatic tolerance must be five ticks")
    contract = data.get("effect_contract", {})
    scopes = {str(value) for value in contract.get("scope", [])}
    triggers = {str(value) for value in contract.get("trigger", [])}
    require(scopes == {"PER_HIT", "ONCE_PER_ACTION"}, "budget: effect scopes differ")
    require(triggers == {"ON_HIT", "ON_HEALTH_DAMAGE"}, "budget: effect triggers differ")
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
    for index, effect in enumerate(effects):
        require(isinstance(effect, dict), f"{technique_id}: effect {index} must be an object")
        scope = str(effect.get("scope", ""))
        trigger = str(effect.get("trigger", ""))
        require(scope in scopes, f"{technique_id}: unknown effect scope {scope!r}")
        require(trigger in triggers, f"{technique_id}: unknown effect trigger {trigger!r}")


def validate_manuals(
    data: dict[str, Any],
    slots: dict[int, int],
    tolerance: int,
    scopes: set[str],
    triggers: set[str],
) -> set[str]:
    validate_status(data, "manuals")
    start = data.get("starting_rule", {})
    manuals = data.get("manuals", [])
    require(isinstance(manuals, list), "manuals: manuals must be a list")
    require(len(manuals) == int(start.get("candidate_manuals", -1)) == 6, "manuals: expected six candidates")
    require(int(start.get("choose", -1)) == 4, "manuals: starting choice must be four")
    require(int(start.get("starting_mastery", -1)) == 3, "manuals: starting mastery must be three")
    manual_ids: set[str] = set()
    technique_ids: set[str] = set()
    pending_patch_targets: list[tuple[str, str]] = []
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
        for star in ("5", "9"):
            entry = mastery[star]
            require(entry.get("type") == "patch", f"{manual_id}:{star}: patch type required")
            target = str(entry.get("target", ""))
            pending_patch_targets.append((manual_id, target))
        for owner, target in pending_patch_targets[-2:]:
            require(target in local_techniques or target == "medical", f"{owner}: missing patch target {target!r}")
    return technique_ids


def validate_duels(data: dict[str, Any], technique_ids: set[str]) -> None:
    validate_status(data, "duels")
    contract = data.get("ai_contract", {})
    require(contract.get("reads_player_uncommitted_plan") is False, "duels: AI may not read uncommitted plan")
    require(int(contract.get("candidate_limit", -1)) == 3, "duels: candidate limit must be three")
    duels = data.get("major_duels", [])
    require(isinstance(duels, list) and len(duels) == 10, "duels: expected ten major duels")
    duel_ids: set[str] = set()
    orders: list[int] = []
    allowed_actions = BUILTIN_ACTION_IDS | technique_ids
    for duel in duels:
        duel_id = str(duel.get("id", ""))
        require(duel_id and duel_id not in duel_ids, f"duels: duplicate or empty id {duel_id!r}")
        duel_ids.add(duel_id)
        orders.append(int(duel.get("order", 0)))
        candidates = duel.get("candidate_actions", [])
        require(isinstance(candidates, list) and 1 <= len(candidates) <= 3, f"{duel_id}: candidate actions must contain one to three ids")
        unknown = [str(value) for value in candidates if str(value) not in allowed_actions]
        require(not unknown, f"{duel_id}: unknown candidate actions {unknown}")
        require(bool(duel.get("public_tells")), f"{duel_id}: public tells required")
        require(bool(duel.get("public_task")), f"{duel_id}: public task required")
    require(orders == list(range(1, 11)), "duels: order must be 1 through 10")
    subset = [str(value) for value in data.get("poc_runtime_subset", [])]
    require(len(subset) == 3 and len(set(subset)) == 3, "duels: PoC runtime subset must have three unique ids")
    require(all(value in duel_ids for value in subset), "duels: PoC runtime subset references missing duel")


def validate_map(data: dict[str, Any]) -> None:
    validate_status(data, "map")
    slice_data = data.get("poc_slice", {})
    require(len(slice_data.get("major_duels", [])) == 3, "map: PoC slice must use three duels")
    require(int(slice_data.get("target_visited_nodes", -1)) == 5, "map: PoC slice must target five nodes")
    full = data.get("full_run_hypothesis", {})
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


def run(root: Path) -> None:
    directory = root / "docs/planning-data"
    loaded = {key: load_object(directory / filename) for key, filename in FILES.items()}
    slots, tolerance, scopes, triggers = validate_budget(loaded["budget"])
    technique_ids = validate_manuals(loaded["manuals"], slots, tolerance, scopes, triggers)
    validate_duels(loaded["duels"], technique_ids)
    validate_map(loaded["map"])
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
