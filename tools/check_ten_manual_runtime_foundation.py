from __future__ import annotations

import json
from pathlib import Path
from typing import Any


class RuntimeFoundationError(AssertionError):
    pass


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = Path("data/cards/martial_manual_cards.json")
SEMANTIC = Path("docs/planning-data/approved_20260806_ten_recognizable_martial_manuals_contract.json")
BUDGET = Path("docs/planning-data/approved_20260806_ten_manual_growth_budget_overlay_contract.json")
REGISTRY = Path("src/combat/martial_manual_registry.gd")
PIPELINE = Path("src/combat/martial_effect_pipeline.gd")
ENGINE = Path("src/combat/combat_resolution_engine_ten_manuals.gd")
BUILD_APPROVAL = Path("docs/implementation/BUILD_APPROVAL_2026-08-06.md")
RUNTIME_DECISION = Path("docs/decisions/2026-08-06_TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE.md")

DECISION_ID = "TEN-DEC-20260806-TEN-RECOGNIZABLE-MARTIAL-MANUALS-FULL-GROWTH-01"
RUNTIME_GATE = "TEN_MANUAL_RUNTIME_IMPLEMENTATION_GATE"
EXPECTED_LEGACY_IDS = {
    "basic_move", "basic_footwork", "basic_guard", "basic_evade",
    "basic_quick_attack", "basic_heavy_attack", "basic_meditate", "basic_stance",
    "ultimate_ten_paces_wave", "ultimate_cleave_peak", "ultimate_void_sword_qi",
}
ALLOWED_OPS = {
    "GAIN_STATUS", "GAIN_RESOURCE", "CONSUME_STATUS", "CONSUME_ONCE_PER_BATTLE",
    "MOVE_TOWARD", "MOVE_AWAY", "RECHECK_RANGE", "ATTACK", "INDEPENDENT_ATTACK",
    "SPECIAL_CLASH", "BREAK_DEFENSE", "PUSH_TARGET", "REQUIRE_ACTUAL_HP_HITS",
    "REQUIRE_DEFENSE_ZERO", "REQUIRE_CLASH_WIN", "REQUIRE_EVADE_SUCCESS",
    "GAIN_MOMENTUM_ON_COMPLETE", "START_DEFENSE_LOSS_RECORD", "END_DEFENSE_LOSS_RECORD",
}


def _fail(message: str) -> None:
    raise RuntimeFoundationError(message)


def _require(condition: bool, message: str) -> None:
    if not condition:
        _fail(message)


def _json(root: Path, relative: Path) -> dict[str, Any]:
    path = root / relative
    _require(path.is_file(), f"missing required JSON file: {relative.as_posix()}")
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        _fail(f"invalid JSON {relative.as_posix()}: {error}")
    _require(isinstance(value, dict), f"JSON root must be an object: {relative.as_posix()}")
    return value


def _text(root: Path, relative: Path) -> str:
    path = root / relative
    _require(path.is_file(), f"missing required text file: {relative.as_posix()}")
    return path.read_text(encoding="utf-8")


def _manuals(root: Path, manifest: dict[str, Any]) -> dict[str, dict[str, Any]]:
    entries = manifest.get("manual_files")
    _require(isinstance(entries, dict), "runtime manifest manual_files must be an object")
    result: dict[str, dict[str, Any]] = {}
    paths: set[str] = set()
    for manual_id, relative in entries.items():
        _require(isinstance(relative, str), f"manual path must be text: {manual_id}")
        _require(relative.startswith("data/cards/martial_manuals/") and relative.endswith(".json"), f"invalid manual path: {relative}")
        _require(relative not in paths, f"duplicate manual path: {relative}")
        paths.add(relative)
        value = _json(root, Path(relative))
        _require(value.get("manual_id") == manual_id, f"manual_id/path drift: {manual_id}")
        result[str(manual_id)] = value
    return result


def _ops(value: dict[str, Any], label: str) -> list[str]:
    steps = value.get("effect_steps")
    _require(isinstance(steps, list) and steps, f"{label} must have effect_steps")
    result: list[str] = []
    for index, step in enumerate(steps):
        _require(isinstance(step, dict), f"{label} step {index} must be an object")
        op = step.get("op")
        _require(isinstance(op, str) and op in ALLOWED_OPS, f"{label} has unsupported effect op: {op!r}")
        result.append(op)
    return result


def _subsequence(actual: list[str], expected: list[str], label: str) -> None:
    cursor = 0
    for value in actual:
        if cursor < len(expected) and value == expected[cursor]:
            cursor += 1
    _require(cursor == len(expected), f"{label} order drift: expected {expected}, actual {actual}")


def validate(root: Path = ROOT) -> None:
    semantic = _json(root, SEMANTIC)
    budget = _json(root, BUDGET)
    manifest = _json(root, MANIFEST)
    manuals = _manuals(root, manifest)

    for value, label in ((semantic, "semantic"), (budget, "budget"), (manifest, "runtime manifest")):
        _require(value.get("decision_id") == DECISION_ID, f"{label} Decision ID drift")
    _require(manifest.get("runtime_gate") == RUNTIME_GATE, "runtime gate drift")
    _require(manifest.get("runtime_status") == "RUNTIME_FOUNDATION", "runtime authority must remain RUNTIME_FOUNDATION")
    _require(manifest.get("stat_quota_rules_enabled") is False, "stat quota rules must remain disabled")
    for forbidden in ("stat_quota", "primary_stat_quota", "secondary_stat_quota", "equal_distribution"):
        _require(forbidden not in manifest, f"forbidden quota field present: {forbidden}")

    approved = semantic.get("manuals")
    _require(isinstance(approved, dict) and len(approved) == 10, "semantic contract must contain ten manuals")
    _require(set(manuals) == set(approved), "runtime catalog must contain the exact approved roster")

    card_ids: set[str] = set()
    for manual_id, authority in approved.items():
        manual = manuals[manual_id]
        for field in ("faction", "manual_name", "primary_stat", "secondary_stat"):
            _require(manual.get(field) == authority.get(field), f"{manual_id} {field} drift")
        cards = manual.get("cards")
        overlays = manual.get("overlays")
        _require(isinstance(cards, dict) and set(cards) == {"star3", "star7", "star10"}, f"{manual_id} card stages drift")
        _require(isinstance(overlays, dict) and set(overlays) == {"star5", "star9"}, f"{manual_id} overlay stages drift")
        for stage, unlock in (("star3", 3), ("star7", 7), ("star10", 10)):
            card = cards[stage]
            _require(isinstance(card, dict) and card.get("unlock_star") == unlock, f"{manual_id} {stage} unlock drift")
            card_id = card.get("id")
            _require(isinstance(card_id, str) and card_id and card_id not in card_ids, f"duplicate or blank card ID: {card_id!r}")
            card_ids.add(card_id)
            _require(card.get("manual_id") == manual_id, f"{card_id} manual reference drift")
            _require(card.get("balance_status") == "PROVISIONAL_WITHIN_APPROVED_BUDGET", f"{card_id} balance disclosure drift")
            _ops(card, card_id)
        star5 = overlays["star5"]
        star9 = overlays["star9"]
        _require(star5.get("unlock_star") == 5 and star5.get("target") == "star3", f"{manual_id} star5 must modify star3 only")
        _require(star9.get("unlock_star") == 9 and star9.get("target") == "star7", f"{manual_id} star9 must modify star7 only")
        _require(star9.get("branching_allowed") is False, f"{manual_id} star9 cannot branch")
        _require(star9.get("additional_input_allowed") is False, f"{manual_id} star9 cannot add input")
        _require(star9.get("additional_resource_cost_allowed") is False, f"{manual_id} star9 cannot add cost")
        _require(isinstance(star9.get("effect_steps"), list) and len(star9["effect_steps"]) == 1, f"{manual_id} star9 must add exactly one step")
        _ops(star5, f"{manual_id} star5")
        _ops(star9, f"{manual_id} star9")

    compatibility = manifest.get("compatibility")
    _require(isinstance(compatibility, dict), "compatibility contract missing")
    _require(compatibility.get("legacy_default_behavior_unchanged") is True, "legacy default behavior must remain unchanged")
    _require(set(compatibility.get("preserved_card_ids", [])) == EXPECTED_LEGACY_IDS, "legacy card IDs drift")

    zixia = _ops(manuals["mount_hua_purple_mist_art"]["cards"]["star10"], "Zixia")
    _require(zixia[0] == "CONSUME_ONCE_PER_BATTLE", "Zixia use right must be consumed first")
    _require(zixia[-1] == "GAIN_MOMENTUM_ON_COMPLETE", "Zixia momentum must be completion-only")
    _subsequence(_ops(manuals["shaolin_arhat_vajra_art"]["cards"]["star10"], "Vajra"), ["GAIN_RESOURCE", "GAIN_STATUS", "START_DEFENSE_LOSS_RECORD", "RECHECK_RANGE", "ATTACK", "END_DEFENSE_LOSS_RECORD"], "Vajra")
    _subsequence(_ops(manuals["yang_family_spear"]["cards"]["star10"], "Returning Spear"), ["ATTACK", "MOVE_AWAY", "RECHECK_RANGE", "ATTACK"], "Returning Spear")
    _subsequence(_ops(manuals["xiaoyao_lingbo_footwork"]["cards"]["star10"], "Lingbo"), ["REQUIRE_EVADE_SUCCESS", "ATTACK", "MOVE_AWAY", "GAIN_STATUS"], "Lingbo")
    _require(_ops(manuals["sichuan_tang_hidden_weapons"]["cards"]["star10"], "Myriad Rain").count("INDEPENDENT_ATTACK") == 4, "Myriad Rain must have four deterministic attacks")

    registry = _text(root, REGISTRY)
    pipeline = _text(root, PIPELINE)
    engine = _text(root, ENGINE)
    approval = _text(root, BUILD_APPROVAL)
    decision = _text(root, RUNTIME_DECISION)
    for token in ("class_name MartialManualRegistry", "build_unlocked_cards", "build_loadout_cards", "duplicate(true)"):
        _require(token in registry, f"registry missing token: {token}")
    for token in ("class_name MartialEffectPipeline", "CONSUME_ONCE_PER_BATTLE", "RECHECK_RANGE", "UNKNOWN_EFFECT_OP", "GAIN_MOMENTUM_ON_COMPLETE"):
        _require(token in pipeline, f"pipeline missing token: {token}")
    for token in ("martial_manual_registry.gd", "martial_effect_pipeline.gd", "configure_martial_loadout", "resolve_martial_card"):
        _require(token in engine, f"combat adapter missing token: {token}")
    for token in (RUNTIME_GATE, "registry + ordered effect pipeline + explicit engine loadout integration", "human validation: NOT_RUN"):
        _require(token in approval, f"build approval missing token: {token}")
    for token in (RUNTIME_GATE, "RUNTIME_FOUNDATION", "PR #92", "PR #91"):
        _require(token in decision, f"runtime Decision missing token: {token}")


def main() -> None:
    validate(ROOT)
    print("TEN_MANUAL_RUNTIME_FOUNDATION_PASS")


if __name__ == "__main__":
    main()
