from __future__ import annotations

import json
from pathlib import Path
from typing import Any


class RuntimeFoundationError(AssertionError):
    pass


ROOT = Path(__file__).resolve().parents[1]
CATALOG = Path("data/cards/martial_manual_cards.json")
SEMANTIC = Path("docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json")
BUDGET = Path("docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json")
REGISTRY = Path("src/combat/martial_manual_registry.gd")
PIPELINE = Path("src/combat/martial_effect_pipeline.gd")
ENGINE = Path("src/combat/combat_resolution_engine.gd")
BUILD_APPROVAL = Path("docs/implementation/BUILD_APPROVAL_2026-08-06.md")
RUNTIME_DECISION = Path("docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md")

DECISION_ID = "TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01"
RUNTIME_GATE = "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE"

EXPECTED_LEGACY_IDS = {
    "basic_move",
    "basic_footwork",
    "basic_guard",
    "basic_evade",
    "basic_quick_attack",
    "basic_heavy_attack",
    "basic_meditate",
    "basic_stance",
    "ultimate_ten_paces_wave",
    "ultimate_cleave_peak",
    "ultimate_void_sword_qi",
}

ALLOWED_EFFECT_OPS = {
    "GAIN_STATUS",
    "GAIN_RESOURCE",
    "CONSUME_STATUS",
    "CONSUME_ONCE_PER_BATTLE",
    "MOVE_TOWARD",
    "MOVE_AWAY",
    "RECHECK_RANGE",
    "ATTACK",
    "INDEPENDENT_ATTACK",
    "SPECIAL_CLASH",
    "BREAK_DEFENSE",
    "PUSH_TARGET",
    "REQUIRE_ACTUAL_HP_HITS",
    "REQUIRE_DEFENSE_ZERO",
    "REQUIRE_CLASH_WIN",
    "REQUIRE_EVADE_SUCCESS",
    "GAIN_MOMENTUM_ON_COMPLETE",
    "START_DEFENSE_LOSS_RECORD",
    "END_DEFENSE_LOSS_RECORD",
}


def _fail(message: str) -> None:
    raise RuntimeFoundationError(message)


def _read_json(root: Path, relative: Path) -> dict[str, Any]:
    path = root / relative
    if not path.is_file():
        _fail(f"missing required JSON file: {relative.as_posix()}")
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        _fail(f"invalid JSON {relative.as_posix()}: {error}")
    if not isinstance(value, dict):
        _fail(f"JSON root must be an object: {relative.as_posix()}")
    return value


def _read_text(root: Path, relative: Path) -> str:
    path = root / relative
    if not path.is_file():
        _fail(f"missing required text file: {relative.as_posix()}")
    return path.read_text(encoding="utf-8")


def _require(condition: bool, message: str) -> None:
    if not condition:
        _fail(message)


def _ops(card: dict[str, Any]) -> list[str]:
    steps = card.get("effect_steps", [])
    _require(isinstance(steps, list) and steps, f"{card.get('id', '<card>')} must have effect_steps")
    result: list[str] = []
    for index, step in enumerate(steps):
        _require(isinstance(step, dict), f"{card.get('id')} effect step {index} must be an object")
        op = step.get("op")
        _require(isinstance(op, str) and op in ALLOWED_EFFECT_OPS, f"{card.get('id')} has unsupported effect op: {op!r}")
        result.append(op)
    return result


def _assert_subsequence(values: list[str], expected: list[str], label: str) -> None:
    cursor = 0
    for value in values:
        if cursor < len(expected) and value == expected[cursor]:
            cursor += 1
    _require(cursor == len(expected), f"{label} must contain ordered subsequence {expected}; actual={values}")


def validate(root: Path = ROOT) -> None:
    semantic = _read_json(root, SEMANTIC)
    budget = _read_json(root, BUDGET)
    catalog = _read_json(root, CATALOG)
    registry_source = _read_text(root, REGISTRY)
    pipeline_source = _read_text(root, PIPELINE)
    engine_source = _read_text(root, ENGINE)
    build_approval = _read_text(root, BUILD_APPROVAL)
    runtime_decision = _read_text(root, RUNTIME_DECISION)

    _require(semantic.get("decision_id") == DECISION_ID, "semantic Decision ID drift")
    _require(budget.get("decision_id") == DECISION_ID, "budget Decision ID drift")
    _require(catalog.get("decision_id") == DECISION_ID, "runtime catalog Decision ID drift")
    _require(catalog.get("runtime_gate") == RUNTIME_GATE, "runtime gate drift")
    _require(catalog.get("runtime_status") == "RUNTIME_FOUNDATION", "runtime catalog must claim only RUNTIME_FOUNDATION")
    _require(catalog.get("stat_quota_rules_enabled") is False, "stat quota rules must remain disabled")
    for forbidden in ("stat_quota", "primary_stat_quota", "secondary_stat_quota", "equal_distribution"):
        _require(forbidden not in catalog, f"forbidden stat quota field present: {forbidden}")

    semantic_manuals = semantic.get("manuals")
    runtime_manuals = catalog.get("manuals")
    _require(isinstance(semantic_manuals, dict) and len(semantic_manuals) == 10, "semantic contract must contain ten manuals")
    _require(isinstance(runtime_manuals, dict) and set(runtime_manuals) == set(semantic_manuals), "runtime catalog must contain the exact ten-manual roster")

    all_card_ids: set[str] = set()
    for manual_id, semantic_manual in semantic_manuals.items():
        runtime_manual = runtime_manuals.get(manual_id)
        _require(isinstance(runtime_manual, dict), f"runtime manual missing: {manual_id}")
        for field in ("faction", "manual_name", "primary_stat", "secondary_stat"):
            _require(runtime_manual.get(field) == semantic_manual.get(field), f"{manual_id} {field} drift")

        cards = runtime_manual.get("cards")
        overlays = runtime_manual.get("overlays")
        _require(isinstance(cards, dict) and set(cards) == {"star3", "star7", "star10"}, f"{manual_id} must have star3/star7/star10 cards")
        _require(isinstance(overlays, dict) and set(overlays) == {"star5", "star9"}, f"{manual_id} must have star5/star9 overlays")

        for stage, unlock in (("star3", 3), ("star7", 7), ("star10", 10)):
            card = cards[stage]
            _require(isinstance(card, dict), f"{manual_id} {stage} must be an object")
            _require(card.get("unlock_star") == unlock, f"{manual_id} {stage} unlock drift")
            card_id = card.get("id")
            _require(isinstance(card_id, str) and card_id and card_id not in all_card_ids, f"duplicate or blank card id: {card_id!r}")
            all_card_ids.add(card_id)
            _require(card.get("manual_id") == manual_id, f"{card_id} manual_id drift")
            _require(card.get("balance_status") == "PROVISIONAL_WITHIN_APPROVED_BUDGET", f"{card_id} must disclose provisional balance")
            _ops(card)

        star5 = overlays["star5"]
        star9 = overlays["star9"]
        _require(star5.get("unlock_star") == 5 and star5.get("target") == "star3", f"{manual_id} star5 must modify star3 only")
        _require(star9.get("unlock_star") == 9 and star9.get("target") == "star7", f"{manual_id} star9 must modify star7 only")
        _require(star9.get("branching_allowed") is False, f"{manual_id} star9 cannot branch")
        _require(star9.get("additional_input_allowed") is False, f"{manual_id} star9 cannot add input")
        _require(star9.get("additional_resource_cost_allowed") is False, f"{manual_id} star9 cannot add resource cost")
        star9_steps = star9.get("effect_steps")
        _require(isinstance(star9_steps, list) and len(star9_steps) == 1, f"{manual_id} star9 must add exactly one effect step")
        _ops({"id": f"{manual_id}_star9", "effect_steps": star9_steps})
        star5_steps = star5.get("effect_steps")
        _require(isinstance(star5_steps, list) and star5_steps, f"{manual_id} star5 must add at least one star3 effect step")
        _ops({"id": f"{manual_id}_star5", "effect_steps": star5_steps})

    compatibility = catalog.get("compatibility")
    _require(isinstance(compatibility, dict), "compatibility contract missing")
    _require(compatibility.get("legacy_default_behavior_unchanged") is True, "legacy default behavior must remain unchanged")
    _require(set(compatibility.get("preserved_card_ids", [])) == EXPECTED_LEGACY_IDS, "preserved legacy card IDs drift")

    zixia = runtime_manuals["mount_hua_purple_mist_art"]["cards"]["star10"]
    zixia_ops = _ops(zixia)
    _require(zixia_ops[0] == "CONSUME_ONCE_PER_BATTLE", "Zixia use right must be consumed at program start")
    _require(zixia_ops[-1] == "GAIN_MOMENTUM_ON_COMPLETE", "Zixia momentum must be completion-only")

    vajra = runtime_manuals["shaolin_arhat_vajra_art"]["cards"]["star10"]
    vajra_ops = _ops(vajra)
    _assert_subsequence(vajra_ops, ["GAIN_RESOURCE", "GAIN_STATUS", "START_DEFENSE_LOSS_RECORD", "RECHECK_RANGE", "ATTACK", "END_DEFENSE_LOSS_RECORD"], "Vajra ultimate")

    returning_spear = runtime_manuals["yang_family_spear"]["cards"]["star10"]
    _assert_subsequence(_ops(returning_spear), ["ATTACK", "MOVE_AWAY", "RECHECK_RANGE", "ATTACK"], "Returning spear ultimate")

    xiaoyao = runtime_manuals["xiaoyao_lingbo_footwork"]["cards"]["star10"]
    _assert_subsequence(_ops(xiaoyao), ["REQUIRE_EVADE_SUCCESS", "ATTACK", "MOVE_AWAY", "GAIN_STATUS"], "Lingbo footwork ultimate")

    hidden_weapons = runtime_manuals["sichuan_tang_hidden_weapons"]["cards"]["star10"]
    _require(_ops(hidden_weapons).count("INDEPENDENT_ATTACK") == 4, "Myriad Heavens Rain must use four deterministic independent attacks")

    _require("class_name MartialManualRegistry" in registry_source, "registry class_name missing")
    for token in ("build_unlocked_cards", "build_loadout_cards", "duplicate(true)"):
        _require(token in registry_source, f"registry missing token: {token}")
    _require("class_name MartialEffectPipeline" in pipeline_source, "pipeline class_name missing")
    for token in ("CONSUME_ONCE_PER_BATTLE", "RECHECK_RANGE", "UNKNOWN_EFFECT_OP", "GAIN_MOMENTUM_ON_COMPLETE"):
        _require(token in pipeline_source, f"pipeline missing token: {token}")
    for token in ("martial_manual_registry.gd", "martial_effect_pipeline.gd", "configure_martial_loadout", "resolve_martial_card"):
        _require(token in engine_source, f"combat engine integration missing token: {token}")

    for token in (RUNTIME_GATE, "registry + ordered effect pipeline + explicit engine loadout integration", "human validation: NOT_RUN"):
        _require(token in build_approval, f"build approval missing token: {token}")
    for token in (RUNTIME_GATE, "RUNTIME_FOUNDATION", "PR #92", "PR #91"):
        _require(token in runtime_decision, f"runtime Decision missing token: {token}")


def main() -> None:
    validate(ROOT)
    print("TEN_MANUAL_RUNTIME_FOUNDATION_PASS")


if __name__ == "__main__":
    main()
