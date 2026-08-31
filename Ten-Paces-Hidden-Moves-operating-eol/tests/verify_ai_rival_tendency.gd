# 공개 상태 기반 라이벌 후보 정책의 결정론·후보 경계·비공개 입력 차단을 검증한다.
extends SceneTree

const DATA_PATH := "res://data/combat/combat_rival_tendency_poc.json"
const BASIC_PATH := "res://data/cards/basic_cards.json"
const ULTIMATE_PATH := "res://data/cards/ultimate_cards.json"
const TRACE_KEYS := [
    "public_snapshot",
    "rival_id",
    "candidate_ids",
    "candidate_scores",
    "selected_card_id",
    "seed",
    "reason_codes"
]
const SNAPSHOT_KEYS := [
    "round_number",
    "bundle_index",
    "bundle_start",
    "bundle_slots",
    "player_tile",
    "enemy_tile",
    "distance",
    "player_health",
    "enemy_health",
    "enemy_health_max",
    "enemy_stamina",
    "enemy_internal",
    "enemy_momentum",
    "enemy_momentum_max",
    "ai_decision_seed"
]
const FORBIDDEN_TRACE_TOKENS := [
    "placement",
    "player_plan",
    "uncommitted",
    "reserved_ultimate",
    "preview_resource",
    "pointer",
    "focus",
    "target_preview"
]

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var tendency := _load_json(DATA_PATH)
    var cards_by_id := _load_cards()
    _verify_data_contract(tendency)
    _verify_seeded_policy(tendency, cards_by_id)
    if failures.is_empty():
        print("AI_RIVAL_TENDENCY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _verify_data_contract(tendency: Dictionary) -> void:
    if int(tendency.get("schema_version", 0)) != 1:
        failures.append("Rival tendency schema must be 1.")
    if str(tendency.get("active_rival_id", "")) != "rival_t0_midrange_pressure":
        failures.append("The T0 active rival id is missing.")
    if int(tendency.get("max_candidates", 0)) != 3 or not is_equal_approx(float(tendency.get("score_window", 0.0)), 2.0):
        failures.append("Candidate limit and score window must remain 3 and 2.0.")
    var profiles: Array = tendency.get("profiles", [])
    if profiles.size() != 1:
        failures.append("T0 must expose exactly one rival profile.")
        return
    var profile: Dictionary = profiles[0]
    var clue_ids: Array[String] = []
    for clue_value in profile.get("public_clues", []):
        var clue: Dictionary = clue_value
        clue_ids.append(str(clue.get("id", "")))
    if clue_ids != ["midrange_pressure", "safe_heavy_prepare", "low_health_response"]:
        failures.append("Public rival clue ids changed unexpectedly.")

func _verify_seeded_policy(tendency: Dictionary, cards_by_id: Dictionary) -> void:
    var planner := CombatAiPlanner.new()
    var base_state := _public_state(0)
    var first := planner.build_bundle_actions(base_state, 1, cards_by_id)
    var first_trace := planner.get_last_trace()
    var second := planner.build_bundle_actions(base_state, 1, cards_by_id)
    var second_trace := planner.get_last_trace()
    if first.is_empty() or first != second or first_trace != second_trace:
        failures.append("Same public state and seed must produce the same action and trace.")
    if not first.is_empty() and str((first[0] as Dictionary).get("card_id", "")) != str(first_trace.get("selected_card_id", "")):
        failures.append("Selected action and trace card id must agree.")

    var profiles: Array = tendency.get("profiles", [])
    var public_clue_ids: Array[String] = []
    if not profiles.is_empty():
        for clue_value in (profiles[0] as Dictionary).get("public_clues", []):
            public_clue_ids.append(str((clue_value as Dictionary).get("id", "")))

    var observed: Dictionary = {}
    for seed_value in range(6):
        var state := _public_state(seed_value)
        var actions := planner.build_bundle_actions(state, 1, cards_by_id)
        var trace := planner.get_last_trace()
        _verify_trace_shape(trace)
        var selected := str(trace.get("selected_card_id", ""))
        var candidate_ids: Array = trace.get("candidate_ids", [])
        if actions.is_empty() or selected.is_empty() or selected not in candidate_ids:
            failures.append("Every selected action must belong to the rational candidate pool.")
            continue
        if candidate_ids.size() > 3:
            failures.append("Candidate pool must not exceed three actions.")
        var candidate_scores: Dictionary = trace.get("candidate_scores", {})
        if not candidate_scores.is_empty():
            var score_values: Array[float] = []
            for score_value in candidate_scores.values():
                score_values.append(float(score_value))
            if score_values.max() - score_values.min() > 2.0001:
                failures.append("Rational candidate scores must remain inside the 2.0 window.")
        observed[selected] = true
        for reason_value in trace.get("reason_codes", []):
            if str(reason_value) not in public_clue_ids:
                failures.append("AI reason codes must map to a public clue id.")
        if _contains_forbidden_trace_data(trace):
            failures.append("AI trace leaked a private or UI-only field.")
    if observed.size() < 2:
        failures.append("The initial public state must expose at least two rational choices across seeds.")

    var ultimate_state := _public_state(0)
    var ultimate_enemy: Dictionary = (ultimate_state.get("enemy", {}) as Dictionary).duplicate(true)
    ultimate_enemy["momentum"] = [5, 5]
    ultimate_state["enemy"] = ultimate_enemy
    var ultimate_actions := planner.build_bundle_actions(ultimate_state, 1, cards_by_id)
    if ultimate_actions.is_empty() or str((ultimate_actions[0] as Dictionary).get("card_id", "")) != "ultimate_void_sword_qi":
        failures.append("A ready range-three ultimate must remain the only rational top candidate.")

    var recover_state := _public_state(0)
    var recover_enemy: Dictionary = (recover_state.get("enemy", {}) as Dictionary).duplicate(true)
    recover_enemy["internal"] = [0, 4]
    recover_state["enemy"] = recover_enemy
    var recover_actions := planner.build_bundle_actions(recover_state, 1, cards_by_id)
    if recover_actions.is_empty() or str((recover_actions[0] as Dictionary).get("card_id", "")) != "basic_meditate":
        failures.append("A resource-starved rival must keep meditation as the seed-zero top choice.")

func _verify_trace_shape(trace: Dictionary) -> void:
    var trace_keys: Array[String] = []
    for key_value in trace.keys():
        trace_keys.append(str(key_value))
    trace_keys.sort()
    var expected_trace_keys := TRACE_KEYS.duplicate()
    expected_trace_keys.sort()
    if trace_keys != expected_trace_keys:
        failures.append("AI trace keys changed or exposed an unapproved field.")
    var snapshot: Dictionary = trace.get("public_snapshot", {})
    var snapshot_keys: Array[String] = []
    for key_value in snapshot.keys():
        snapshot_keys.append(str(key_value))
    snapshot_keys.sort()
    var expected_snapshot_keys := SNAPSHOT_KEYS.duplicate()
    expected_snapshot_keys.sort()
    if snapshot_keys != expected_snapshot_keys:
        failures.append("Public AI snapshot keys changed or exposed an unapproved field.")

func _public_state(seed_value: int) -> Dictionary:
    return {
        "round_number": 1,
        "bundle_index": 1,
        "ai_decision_seed": seed_value,
        "player": {
            "tile": 4,
            "health": [30, 30],
            "stamina": [5, 5],
            "internal": [4, 4],
            "momentum": [0, 5]
        },
        "enemy": {
            "tile": 7,
            "health": [30, 30],
            "stamina": [5, 5],
            "internal": [4, 4],
            "momentum": [0, 5]
        },
        "debug_hidden_player_plan": [{"card_id": "ultimate_void_sword_qi"}],
        "pointer_focus": "must_not_leak"
    }

func _contains_forbidden_trace_data(value) -> bool:
    if typeof(value) == TYPE_DICTIONARY:
        for key_value in (value as Dictionary).keys():
            var key_text := str(key_value).to_lower()
            for token in FORBIDDEN_TRACE_TOKENS:
                if token in key_text:
                    return true
            if _contains_forbidden_trace_data((value as Dictionary)[key_value]):
                return true
    elif typeof(value) == TYPE_ARRAY:
        for child in (value as Array):
            if _contains_forbidden_trace_data(child):
                return true
    return false

func _load_cards() -> Dictionary:
    var cards_by_id: Dictionary = {}
    for path in [BASIC_PATH, ULTIMATE_PATH]:
        var data := _load_json(path)
        for value in data.get("cards", []):
            if typeof(value) == TYPE_DICTIONARY:
                var card: Dictionary = value
                cards_by_id[str(card.get("id", ""))] = card.duplicate(true)
    return cards_by_id

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
