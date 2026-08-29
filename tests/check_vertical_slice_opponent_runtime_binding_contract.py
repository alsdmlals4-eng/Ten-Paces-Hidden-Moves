from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ARCHETYPES_PATH = ROOT / "data/run/vertical_slice_opponent_archetypes.json"
OPPONENTS_PATH = ROOT / "data/run/vertical_slice_opponents.json"
BINDING_PATH = ROOT / "src/run/vertical_slice_opponent_runtime_binding.gd"
BASIC_CARDS_PATH = ROOT / "data/cards/basic_cards.json"

STAT_ORDER = ["external", "constitution", "agility", "internal_power", "insight"]
EXPECTED_PROFILE_IDS = [
    "initiative_exchange",
    "stabilize_then_pressure",
    "range_control",
    "public_history_counter",
    "sequence_pressure",
]
EXPECTED_CANDIDATE_ARCHETYPES = {
    "slot1_yeongyo": "initiative_exchange",
    "slot1_dogyeom": "stabilize_then_pressure",
    "slot1_chaeryeong": "initiative_exchange",
    "slot2_mukjin": "stabilize_then_pressure",
    "slot2_seokmu": "stabilize_then_pressure",
    "slot2_danso": "stabilize_then_pressure",
    "slot3_seolha": "range_control",
    "slot3_uram": "range_control",
    "slot3_biyeon": "range_control",
    "slot4_cheongheo": "public_history_counter",
    "slot4_damwol": "public_history_counter",
    "slot4_jinryeo": "public_history_counter",
    "slot5_jeogu": "sequence_pressure",
    "slot5_pungmok": "sequence_pressure",
    "slot5_rajin": "sequence_pressure",
}
REQUIRED_PROFILE_FIELDS = {
    "id",
    "score_weights",
    "max_actions_per_bundle",
    "movement_policy",
    "history_policy",
    "stat_weights",
}
REQUIRED_BINDING_TOKENS = (
    "class_name VerticalSliceOpponentRuntimeBinding",
    "func build(candidate: Dictionary) -> Dictionary:",
    "func _allocate_stats(total_seed: int, stat_weights: Dictionary) -> Dictionary:",
    "final_stat_total_seed",
)


def load_json(path: Path) -> dict:
    assert path.is_file(), f"missing required runtime-binding owner: {path.relative_to(ROOT)}"
    payload = json.loads(path.read_text(encoding="utf-8"))
    assert isinstance(payload, dict), f"JSON root must be an object: {path.relative_to(ROOT)}"
    return payload


def main() -> None:
    archetypes = load_json(ARCHETYPES_PATH)
    opponents = load_json(OPPONENTS_PATH)
    basic_cards = load_json(BASIC_CARDS_PATH)

    assert archetypes.get("schema_version") == 1
    assert archetypes.get("stat_order") == STAT_ORDER
    assert archetypes.get("stat_weight_total") == 20
    profiles = archetypes.get("profiles")
    assert isinstance(profiles, list) and len(profiles) == len(EXPECTED_PROFILE_IDS)
    assert [profile.get("id") for profile in profiles] == EXPECTED_PROFILE_IDS
    for profile in profiles:
        assert REQUIRED_PROFILE_FIELDS <= profile.keys(), profile
        assert isinstance(profile["score_weights"], dict) and profile["score_weights"], profile
        assert isinstance(profile["movement_policy"], dict) and profile["movement_policy"], profile
        assert isinstance(profile["history_policy"], dict) and profile["history_policy"], profile
        assert int(profile["max_actions_per_bundle"]) in {1, 2}, profile
        weights = profile["stat_weights"]
        assert list(weights) == STAT_ORDER, profile
        assert all(isinstance(value, int) and value > 0 for value in weights.values()), profile
        assert sum(weights.values()) == 20, profile

    candidates = opponents.get("candidates")
    assert isinstance(candidates, list) and len(candidates) == 15
    by_id = {candidate.get("candidate_id"): candidate for candidate in candidates}
    assert set(by_id) == set(EXPECTED_CANDIDATE_ARCHETYPES)
    basic_ids = {card.get("id") for card in basic_cards.get("cards", [])}
    for candidate_id, expected_archetype_id in EXPECTED_CANDIDATE_ARCHETYPES.items():
        candidate = by_id[candidate_id]
        assert candidate.get("runtime_archetype_id") == expected_archetype_id, candidate_id
        focus_ids = candidate.get("basic_action_focus_ids")
        assert isinstance(focus_ids, list) and len(focus_ids) == 3 and len(set(focus_ids)) == 3, candidate_id
        assert all(focus_id in basic_ids for focus_id in focus_ids), candidate_id
        assert isinstance(candidate.get("final_stat_total_seed"), int) and candidate["final_stat_total_seed"] >= 20, candidate_id

    assert BINDING_PATH.is_file(), "missing runtime-binding adapter"
    binding = BINDING_PATH.read_text(encoding="utf-8")
    for token in REQUIRED_BINDING_TOKENS:
        assert token in binding, f"missing binding contract token: {token}"


if __name__ == "__main__":
    main()
