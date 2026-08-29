# 공개 상태 기반 라이벌 후보 정책의 결정론·후보 경계·비공개 입력 차단을 검증한다.
extends SceneTree

const DATA_PATH := "res://data/combat/combat_rival_tendency_poc.json"
const BASIC_PATH := "res://data/cards/basic_cards.json"
const ULTIMATE_PATH := "res://data/cards/ultimate_cards.json"
const ARCHETYPE_PATH := "res://data/run/vertical_slice_opponent_archetypes.json"
const CombatAiPlannerScript := preload("res://src/combat/combat_ai_planner.gd")
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
    _verify_phase2_basic_candidate_boundary(cards_by_id)
    _verify_bound_runtime_policy(cards_by_id)
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
    var planner := CombatAiPlannerScript.new()
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

func _verify_phase2_basic_candidate_boundary(cards_by_id: Dictionary) -> void:
    var planner := CombatAiPlannerScript.new()
    var state := _public_state(0)
    var enemy: Dictionary = (state.get("enemy", {}) as Dictionary).duplicate(true)
    enemy["internal"] = [1, 4]
    state["enemy"] = enemy
    planner.build_bundle_actions(state, 1, cards_by_id)
    var trace := planner.get_last_trace()
    var candidate_ids: Array = trace.get("candidate_ids", [])
    if "basic_palm" not in candidate_ids:
        failures.append("A public distance-three rival with two slots and internal 1 must consider palm.")
    if "basic_observe" in candidate_ids:
        failures.append("Player-only observation must never enter enemy candidates.")

func _verify_bound_runtime_policy(cards_by_id: Dictionary) -> void:
    var profiles := _load_archetype_profiles()
    var planner := CombatAiPlannerScript.new()
    if not planner.has_method("set_runtime_binding") or not planner.has_method("clear_runtime_binding"):
        failures.append("Planner must expose optional per-combat runtime binding controls.")
        return
    var range_profile: Dictionary = profiles.get("range_control", {})
    if not planner.set_runtime_binding("range_control", range_profile, ["basic_move", "basic_footwork", "basic_palm"]):
        failures.append("Range-control runtime profile must validate.")
        return
    var movement_cards := {"basic_move": (cards_by_id.get("basic_move", {}) as Dictionary).duplicate(true)}
    var retreat_actions := planner.build_bundle_actions(_public_state_at_distance(2, 0), 1, movement_cards)
    if retreat_actions.is_empty() or int((retreat_actions[0] as Dictionary).get("target_tile", 0)) != 7:
        failures.append("At public distance two, range control must retreat from tile 6 to 7 toward distance three.")
    _verify_bound_trace_shape(planner.get_last_trace(), "range_control", 0)

    var initiative_profile: Dictionary = profiles.get("initiative_exchange", {})
    if not planner.set_runtime_binding("initiative_exchange", initiative_profile, ["basic_guard"]):
        failures.append("Initiative runtime profile must validate.")
        return
    planner.build_bundle_actions(_low_health_distance_one_state(0), 1, cards_by_id)
    var focused_trace := planner.get_last_trace()
    if not is_equal_approx(float((focused_trace.get("candidate_scores", {}) as Dictionary).get("basic_guard", 0.0)), 9.6):
        failures.append("First focus must add 1.20 only to the legal low-health guard score.")
    _verify_bound_trace_shape(focused_trace, "initiative_exchange", 0)

    var sequence_profile: Dictionary = profiles.get("sequence_pressure", {})
    if not planner.set_runtime_binding("sequence_pressure", sequence_profile, ["basic_quick_attack", "basic_guard"]):
        failures.append("Sequence runtime profile must validate.")
        return
    var sequence := planner.build_bundle_actions(_low_health_distance_one_state(0), 1, cards_by_id)
    if sequence.size() > 2:
        failures.append("Sequence profile may schedule at most two actions per bundle.")
    _expect_no_overlap_or_bundle_cross(sequence, 1)
    _verify_bound_trace_shape(planner.get_last_trace(), "sequence_pressure", 0)

    var counter_profile: Dictionary = profiles.get("public_history_counter", {})
    if not planner.set_runtime_binding("public_history_counter", counter_profile, []):
        failures.append("Public-history counter profile must validate.")
        return
    var history_state := _low_health_distance_one_state(0)
    history_state["public_resolution_history"] = _counter_history("basic_quick_attack")
    var first_actions := planner.build_bundle_actions(history_state, 1, cards_by_id)
    var first_trace := planner.get_last_trace()
    var changed_oldest := history_state.duplicate(true)
    changed_oldest["public_resolution_history"] = _counter_history("basic_guard")
    var second_actions := planner.build_bundle_actions(changed_oldest, 1, cards_by_id)
    var second_trace := planner.get_last_trace()
    if int(first_trace.get("public_history_count", -1)) != 2:
        failures.append("Counter behavior must receive exactly the two newest player resolved records.")
    if first_actions != second_actions or first_trace != second_trace:
        failures.append("Counter behavior must ignore older public records outside the newest two player records.")
    var private_variant := history_state.duplicate(true)
    private_variant["debug_hidden_player_plan"] = [{"card_id": "ultimate_void_sword_qi", "target_tile": 10}]
    private_variant["pointer_focus"] = "uncommitted_pointer"
    private_variant["uncommitted_target_preview"] = {"direction": 1, "tile": 10}
    private_variant["observation_answer"] = "hidden"
    var private_actions := planner.build_bundle_actions(private_variant, 1, cards_by_id)
    var private_trace := planner.get_last_trace()
    if first_actions != private_actions or first_trace != private_trace:
        failures.append("Bound behavior must not read player-plan, UI, preview, or observation data.")
    _verify_bound_trace_shape(private_trace, "public_history_counter", 2)

    planner.clear_runtime_binding()
    var unbound_actions := planner.build_bundle_actions(_public_state(0), 1, cards_by_id)
    if unbound_actions.is_empty() or str(planner.get_last_trace().get("rival_id", "")) != "rival_t0_midrange_pressure":
        failures.append("Clearing a binding must restore the untouched global default profile.")

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

func _verify_bound_trace_shape(trace: Dictionary, archetype_id: String, expected_history_count: int) -> void:
    if str(trace.get("runtime_archetype_id", "")) != archetype_id:
        failures.append("Bound trace must name only its runtime archetype id.")
    if int(trace.get("public_history_count", -1)) != expected_history_count:
        failures.append("Bound trace must expose only the bounded public-history count.")
    if typeof(trace.get("scheduled_card_ids", [])) != TYPE_ARRAY:
        failures.append("Bound trace must expose its scheduled public card ids.")
    if _contains_forbidden_trace_data(trace):
        failures.append("Bound AI trace leaked focus, private, or UI-only data.")

func _expect_no_overlap_or_bundle_cross(actions: Array, bundle_index: int) -> void:
    var bounds := [1, 3] if bundle_index == 1 else ([4, 6] if bundle_index == 2 else [7, 10])
    var occupied: Dictionary = {}
    for value in actions:
        if typeof(value) != TYPE_DICTIONARY:
            failures.append("Scheduled AI action must be a dictionary.")
            continue
        var action: Dictionary = value
        var anchor := int(action.get("timing", 0))
        var card_id := str(action.get("card_id", ""))
        var span := 2 if card_id in ["basic_heavy_attack", "basic_palm"] else 1
        for timing in range(anchor, anchor + span):
            if timing < int(bounds[0]) or timing > int(bounds[1]) or occupied.has(timing):
                failures.append("Sequence actions must reserve non-overlapping real slots inside the active 3/3/4 bundle.")
                return
            occupied[timing] = true

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

func _public_state_at_distance(distance: int, seed_value: int) -> Dictionary:
    var state := _public_state(seed_value)
    var enemy: Dictionary = (state.get("enemy", {}) as Dictionary).duplicate(true)
    enemy["tile"] = 4 + distance
    state["enemy"] = enemy
    return state

func _low_health_distance_one_state(seed_value: int) -> Dictionary:
    var state := _public_state_at_distance(1, seed_value)
    var enemy: Dictionary = (state.get("enemy", {}) as Dictionary).duplicate(true)
    enemy["health"] = [10, 30]
    state["enemy"] = enemy
    return state

func _counter_history(oldest_card_id: String) -> Array:
    return [
        {"round_number": 1, "bundle_index": 1, "actor": "player", "card_id": oldest_card_id, "category": "attack", "outcome": "completed"},
        {"round_number": 1, "bundle_index": 1, "actor": "enemy", "card_id": "basic_guard", "category": "response", "outcome": "completed"},
        {"round_number": 2, "bundle_index": 1, "actor": "player", "card_id": "basic_heavy_attack", "category": "attack", "outcome": "completed"},
        {"round_number": 2, "bundle_index": 1, "actor": "player", "card_id": "basic_palm", "category": "attack", "outcome": "completed"}
    ]

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

func _load_archetype_profiles() -> Dictionary:
    var profiles_by_id: Dictionary = {}
    for value in _load_json(ARCHETYPE_PATH).get("profiles", []):
        if typeof(value) == TYPE_DICTIONARY:
            var profile: Dictionary = value
            profiles_by_id[str(profile.get("id", ""))] = profile.duplicate(true)
    return profiles_by_id

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
