# 공개 전투 상태만으로 합리적 후보를 만들고, 재현 가능한 seed로 하나를 고르는 비치팅 AI다.
class_name CombatAiPlanner
extends RefCounted

const RIVAL_PATH := "res://data/combat/combat_rival_tendency_poc.json"

var _rival_data: Dictionary = {}
var _last_trace: Dictionary = {}
var _runtime_binding: Dictionary = {}

func _init() -> void:
    _rival_data = _load_json(RIVAL_PATH)

func get_last_trace() -> Dictionary:
    return _last_trace.duplicate(true)

func build_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array:
    if _runtime_binding.is_empty():
        return _build_unbound_bundle_actions(state, bundle_index, cards_by_id)
    return _build_bound_bundle_actions(state, bundle_index, cards_by_id)

func set_runtime_binding(archetype_id: String, ai_profile: Dictionary, basic_action_focus_ids: Array[String]) -> bool:
    if not _is_valid_runtime_profile(archetype_id, ai_profile, basic_action_focus_ids):
        return false
    _runtime_binding = {
        "archetype_id": archetype_id,
        "ai_profile": ai_profile.duplicate(true),
        "basic_action_focus_ids": basic_action_focus_ids.duplicate()
    }
    return true

func clear_runtime_binding() -> void:
    _runtime_binding = {}

func _build_unbound_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array:
    var snapshot := _build_public_snapshot(state, bundle_index)
    var profile := _active_profile()
    var candidates := _build_candidates(snapshot, profile, cards_by_id)
    if candidates.is_empty():
        _last_trace = {
            "public_snapshot": snapshot.duplicate(true),
            "rival_id": str(profile.get("id", "")),
            "candidate_ids": [],
            "candidate_scores": {},
            "selected_card_id": "",
            "seed": _scoped_seed(snapshot),
            "reason_codes": []
        }
        return []

    candidates.sort_custom(_candidate_before)
    var top_score := float((candidates[0] as Dictionary).get("score", 0.0))
    var score_window := float(_rival_data.get("score_window", 2.0))
    var max_candidates := maxi(1, int(_rival_data.get("max_candidates", 3)))
    var rational_candidates: Array = []
    for value in candidates:
        var candidate: Dictionary = value
        if float(candidate.get("score", 0.0)) < top_score - score_window:
            continue
        rational_candidates.append(candidate)
        if rational_candidates.size() >= max_candidates:
            break

    var selection_candidates := _selection_candidates(rational_candidates, cards_by_id)
    var seed := _scoped_seed(snapshot)
    var selected_index := absi(seed) % selection_candidates.size()
    var selected: Dictionary = selection_candidates[selected_index]
    var candidate_ids: Array[String] = []
    var candidate_scores: Dictionary = {}
    for value in rational_candidates:
        var candidate: Dictionary = value
        var card_id := str(candidate.get("card_id", ""))
        candidate_ids.append(card_id)
        candidate_scores[card_id] = float(candidate.get("score", 0.0))

    _last_trace = {
        "public_snapshot": snapshot.duplicate(true),
        "rival_id": str(profile.get("id", "")),
        "candidate_ids": candidate_ids,
        "candidate_scores": candidate_scores,
        "selected_card_id": str(selected.get("card_id", "")),
        "seed": seed,
        "reason_codes": (selected.get("reason_codes", []) as Array).duplicate(true)
    }
    return [_build_action(selected, snapshot)]

func _build_bound_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array:
    var snapshot := _build_public_snapshot(state, bundle_index)
    var profile := _active_profile()
    var public_history := _newest_player_public_history(state, profile)
    var candidates := _build_candidates(snapshot, profile, cards_by_id, public_history)
    _apply_focus_bonuses(candidates, _runtime_binding.get("basic_action_focus_ids", []))
    _apply_public_history_counter(candidates, profile, public_history)
    if candidates.is_empty():
        _last_trace = _bound_trace(snapshot, profile, [], {}, "", _scoped_seed(snapshot), [], public_history.size())
        return []

    candidates.sort_custom(_candidate_before)
    var top_score := float((candidates[0] as Dictionary).get("score", 0.0))
    var score_window := float(_rival_data.get("score_window", 2.0))
    var max_candidates := maxi(1, int(_rival_data.get("max_candidates", 3)))
    var rational_candidates: Array = []
    for value in candidates:
        var candidate: Dictionary = value
        if float(candidate.get("score", 0.0)) < top_score - score_window:
            continue
        rational_candidates.append(candidate)
        if rational_candidates.size() >= max_candidates:
            break

    var selection_candidates := _selection_candidates(rational_candidates, cards_by_id)
    var seed := _scoped_seed(snapshot)
    var selected_index := absi(seed) % selection_candidates.size()
    var selected: Dictionary = selection_candidates[selected_index]
    var candidate_ids: Array[String] = []
    var candidate_scores: Dictionary = {}
    for value in rational_candidates:
        var candidate: Dictionary = value
        var card_id := str(candidate.get("card_id", ""))
        candidate_ids.append(card_id)
        candidate_scores[card_id] = float(candidate.get("score", 0.0))

    var scheduled := _schedule_bound_actions(selected, rational_candidates, snapshot, profile, cards_by_id)
    var scheduled_card_ids: Array[String] = []
    for action_value in scheduled:
        if typeof(action_value) == TYPE_DICTIONARY:
            scheduled_card_ids.append(str((action_value as Dictionary).get("card_id", "")))
    _last_trace = _bound_trace(
        snapshot,
        profile,
        candidate_ids,
        candidate_scores,
        str(selected.get("card_id", "")),
        seed,
        scheduled_card_ids,
        public_history.size(),
        selected.get("reason_codes", [])
    )
    return scheduled

func _bound_trace(snapshot: Dictionary, profile: Dictionary, candidate_ids: Array, candidate_scores: Dictionary, selected_card_id: String, seed: int, scheduled_card_ids: Array, public_history_count: int, reason_codes: Array = []) -> Dictionary:
    return {
        "public_snapshot": snapshot.duplicate(true),
        "rival_id": str(profile.get("id", "")),
        "candidate_ids": candidate_ids.duplicate(true),
        "candidate_scores": candidate_scores.duplicate(true),
        "selected_card_id": selected_card_id,
        "seed": seed,
        "reason_codes": reason_codes.duplicate(true),
        "runtime_archetype_id": str(_runtime_binding.get("archetype_id", "")),
        "public_history_count": public_history_count,
        "scheduled_card_ids": scheduled_card_ids.duplicate(true)
    }

func _schedule_bound_actions(selected: Dictionary, rational_candidates: Array, snapshot: Dictionary, profile: Dictionary, cards_by_id: Dictionary) -> Array:
    var result: Array = []
    var bounds := _bundle_bounds(int(snapshot.get("bundle_index", 1)))
    var first_definition := _candidate_definition(selected, cards_by_id)
    var first_span := maxi(1, int(first_definition.get("action_slots", 1)))
    if bounds.x + first_span - 1 > bounds.y:
        return result
    result.append(_build_action(selected, snapshot, first_definition, profile.get("movement_policy", {}), bounds.x))
    if int(profile.get("max_actions_per_bundle", 1)) < 2:
        return result
    var next_anchor := bounds.x + first_span
    for value in rational_candidates:
        var candidate: Dictionary = value
        if str(candidate.get("card_id", "")) == str(selected.get("card_id", "")):
            continue
        var definition := _candidate_definition(candidate, cards_by_id)
        var span := maxi(1, int(definition.get("action_slots", 1)))
        if next_anchor + span - 1 > bounds.y:
            continue
        result.append(_build_action(candidate, snapshot, definition, profile.get("movement_policy", {}), next_anchor))
        break
    return result

func _candidate_definition(candidate: Dictionary, cards_by_id: Dictionary) -> Dictionary:
    var definition = candidate.get("definition", {})
    if typeof(definition) == TYPE_DICTIONARY and not (definition as Dictionary).is_empty():
        return (definition as Dictionary).duplicate(true)
    var card_id := str(candidate.get("card_id", ""))
    var card = cards_by_id.get(card_id, {})
    return (card as Dictionary).duplicate(true) if typeof(card) == TYPE_DICTIONARY else {}

func _apply_focus_bonuses(candidates: Array, focus_value) -> void:
    if typeof(focus_value) != TYPE_ARRAY:
        return
    var bonuses := [1.20, 0.60, 0.30]
    for index in range(mini((focus_value as Array).size(), bonuses.size())):
        var focus_id := str((focus_value as Array)[index])
        for value in candidates:
            var candidate: Dictionary = value
            if str(candidate.get("card_id", "")) == focus_id:
                candidate["score"] = float(candidate.get("score", 0.0)) + float(bonuses[index])
                break

func _newest_player_public_history(state: Dictionary, profile: Dictionary) -> Array:
    var policy: Dictionary = profile.get("history_policy", {})
    if str(policy.get("mode", "none")) != "last_two_player_resolved_cards":
        return []
    var records: Array = []
    var history_value = state.get("public_resolution_history", [])
    if typeof(history_value) != TYPE_ARRAY:
        return records
    for value in history_value:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var record: Dictionary = value
        if str(record.get("actor", "")) != "player":
            continue
        records.append({
            "round_number": int(record.get("round_number", 0)),
            "bundle_index": int(record.get("bundle_index", 0)),
            "actor": "player",
            "card_id": str(record.get("card_id", "")),
            "category": str(record.get("category", "")),
            "outcome": str(record.get("outcome", ""))
        })
    if records.size() <= 2:
        return records
    return records.slice(records.size() - 2, records.size(), 1, true)

func _apply_public_history_counter(candidates: Array, profile: Dictionary, public_history: Array) -> void:
    if str(profile.get("id", "")) != "public_history_counter" or public_history.size() != 2:
        return
    for record_value in public_history:
        var record: Dictionary = record_value
        if str(record.get("category", "")) != "attack":
            return
    var weights: Dictionary = profile.get("score_weights", {})
    var response_bonus := float(weights.get("response_low_health", 0.0))
    for value in candidates:
        var candidate: Dictionary = value
        if str(candidate.get("card_id", "")) in ["basic_guard", "basic_evade"]:
            candidate["score"] = float(candidate.get("score", 0.0)) + response_bonus
            var reasons: Array = candidate.get("reason_codes", [])
            reasons.append("public_history_counter")
            candidate["reason_codes"] = reasons

func _selection_candidates(rational_candidates: Array, cards_by_id: Dictionary) -> Array:
    var legacy_candidates: Array = []
    var martial_candidates: Array = []
    for value in rational_candidates:
        var candidate: Dictionary = value
        var card_id := str(candidate.get("card_id", ""))
        var definition: Dictionary = cards_by_id.get(card_id, {})
        if str(definition.get("source", "")) == "martial_manual":
            martial_candidates.append(candidate)
        else:
            legacy_candidates.append(candidate)
    if legacy_candidates.is_empty() or martial_candidates.is_empty():
        return rational_candidates
    var best_legacy := float((legacy_candidates[0] as Dictionary).get("score", 0.0))
    var best_martial := float((martial_candidates[0] as Dictionary).get("score", 0.0))
    if best_martial >= best_legacy + 1.0:
        return rational_candidates
    return legacy_candidates

func _build_public_snapshot(state: Dictionary, bundle_index: int) -> Dictionary:
    var enemy: Dictionary = state.get("enemy", {})
    var player: Dictionary = state.get("player", {})
    var enemy_tile := int(enemy.get("tile", 6))
    var player_tile := int(player.get("tile", 4))
    var bounds := _bundle_bounds(bundle_index)
    return {
        "round_number": int(state.get("round_number", 1)),
        "bundle_index": bundle_index,
        "bundle_start": bounds.x,
        "bundle_slots": bounds.y - bounds.x + 1,
        "player_tile": player_tile,
        "enemy_tile": enemy_tile,
        "distance": absi(player_tile - enemy_tile),
        "player_health": _resource_current(player, "health", 30),
        "enemy_health": _resource_current(enemy, "health", 30),
        "enemy_health_max": _resource_maximum(enemy, "health", 30),
        "enemy_stamina": _resource_current(enemy, "stamina", 5),
        "enemy_internal": _resource_current(enemy, "internal", 4),
        "enemy_momentum": _resource_current(enemy, "momentum", 0),
        "enemy_momentum_max": _resource_maximum(enemy, "momentum", 5),
        "ai_decision_seed": int(state.get("ai_decision_seed", 0))
    }

func _build_candidates(snapshot: Dictionary, profile: Dictionary, cards_by_id: Dictionary, _public_history: Array = []) -> Array:
    var candidates: Array = []
    var weights: Dictionary = profile.get("score_weights", profile.get("weights", {}))
    var distance := int(snapshot.get("distance", 0))
    var slots := int(snapshot.get("bundle_slots", 1))
    var stamina := int(snapshot.get("enemy_stamina", 0))
    var internal := int(snapshot.get("enemy_internal", 0))
    var health := int(snapshot.get("enemy_health", 0))
    var health_max := maxi(1, int(snapshot.get("enemy_health_max", 30)))
    var momentum := int(snapshot.get("enemy_momentum", 0))
    var momentum_max := maxi(1, int(snapshot.get("enemy_momentum_max", 5)))

    if momentum == momentum_max:
        if distance == 3 and slots >= 3:
            _append_candidate(candidates, "ultimate_void_sword_qi", 9.0 + float(weights.get("ultimate_ready", 0.0)), ["safe_heavy_prepare"], cards_by_id)
        elif distance == 2 and slots >= 2:
            _append_candidate(candidates, "ultimate_cleave_peak", 9.0 + float(weights.get("ultimate_ready", 0.0)), ["safe_heavy_prepare"], cards_by_id)
        elif distance <= 1:
            _append_candidate(candidates, "ultimate_ten_paces_wave", 9.0 + float(weights.get("ultimate_ready", 0.0)), ["midrange_pressure"], cards_by_id)

    if health * 3 <= health_max and distance <= 2:
        if stamina >= 1:
            _append_candidate(candidates, "basic_evade", 7.5 + float(weights.get("response_low_health", 0.0)), ["low_health_response"], cards_by_id)
        _append_candidate(candidates, "basic_guard", 7.4 + float(weights.get("response_low_health", 0.0)), ["low_health_response"], cards_by_id)

    if stamina <= 0 or internal <= 0:
        _append_candidate(candidates, "basic_meditate", 7.0 + float(weights.get("recover_low_resource", 0.0)), ["low_health_response"], cards_by_id)

    if distance <= 1 and stamina >= 1:
        _append_candidate(candidates, "basic_quick_attack", 6.5 + float(weights.get("quick_pressure", 0.0)), ["midrange_pressure"], cards_by_id)

    if distance <= 2 and slots >= 2 and stamina >= 1 and internal >= 1:
        _append_candidate(candidates, "basic_heavy_attack", 6.5 + float(weights.get("heavy_prepare", 0.0)), ["safe_heavy_prepare"], cards_by_id)

    if distance <= 3 and slots >= 2 and internal >= 1:
        _append_candidate(candidates, "basic_palm", 6.4 + float(weights.get("heavy_prepare", 0.0)), ["safe_heavy_prepare"], cards_by_id)

    if distance > 1:
        _append_candidate(candidates, "basic_move", 6.0 + float(weights.get("approach", 0.0)), ["midrange_pressure"], cards_by_id)
        if distance >= 3 and internal >= 1:
            _append_candidate(candidates, "basic_footwork", 5.8 + float(weights.get("approach", 0.0)), ["midrange_pressure"], cards_by_id)

    _append_martial_candidates(candidates, snapshot, cards_by_id)

    if candidates.is_empty():
        _append_candidate(candidates, "basic_guard", 1.0, ["low_health_response"], cards_by_id)
    return candidates

func _append_martial_candidates(candidates: Array, snapshot: Dictionary, cards_by_id: Dictionary) -> void:
    var ids := PackedStringArray()
    for key_value in cards_by_id.keys():
        ids.append(str(key_value))
    ids.sort()
    var distance := int(snapshot.get("distance", 0))
    var slots := int(snapshot.get("bundle_slots", 1))
    var stamina := int(snapshot.get("enemy_stamina", 0))
    var internal := int(snapshot.get("enemy_internal", 0))
    var momentum := int(snapshot.get("enemy_momentum", 0))
    var momentum_max := maxi(1, int(snapshot.get("enemy_momentum_max", 5)))
    var low_health := int(snapshot.get("enemy_health", 0)) * 3 <= maxi(1, int(snapshot.get("enemy_health_max", 30)))
    for card_id in ids:
        var definition: Dictionary = cards_by_id.get(card_id, {})
        if str(definition.get("source", "")) != "martial_manual":
            continue
        var action_slots := maxi(1, int(definition.get("action_slots", 1)))
        if action_slots > slots:
            continue
        if int(definition.get("stamina_cost", 0)) > stamina or int(definition.get("internal_cost", 0)) > internal:
            continue
        var unlock_star := int(definition.get("unlock_star", 0))
        if unlock_star >= 10 and momentum != momentum_max:
            continue
        if not _martial_distance_is_reachable(definition, distance):
            continue
        var score := 8.8 if unlock_star >= 10 else 6.8
        if unlock_star < 10 and not _martial_is_at_preferred_distance(definition, distance):
            score -= 2.0
        if action_slots >= 3:
            score += 0.2
        var reason_codes := ["low_health_response"] if low_health else (["safe_heavy_prepare"] if action_slots >= 2 else ["midrange_pressure"])
        _append_candidate(candidates, card_id, score, reason_codes, cards_by_id, definition)

func _martial_distance_is_reachable(definition: Dictionary, distance: int) -> bool:
    var profile := _martial_range_profile(definition, distance)
    return profile.x >= profile.y and profile.x <= profile.z

func _martial_is_at_preferred_distance(definition: Dictionary, distance: int) -> bool:
    var profile := _martial_range_profile(definition, distance)
    return profile.x == profile.z

func _martial_range_profile(definition: Dictionary, distance: int) -> Vector3i:
    var minimum := 0
    var maximum := 0
    var range_value = definition.get("range", {})
    if typeof(range_value) == TYPE_DICTIONARY:
        minimum = maxi(0, int((range_value as Dictionary).get("min", 0)))
        maximum = maxi(minimum, int((range_value as Dictionary).get("max", minimum)))
    var approach := 0
    for step_value in definition.get("effect_steps", []):
        if typeof(step_value) != TYPE_DICTIONARY:
            continue
        var step: Dictionary = step_value
        if str(step.get("op", "")) == "MOVE_TOWARD":
            approach += maxi(0, int(step.get("tiles", 0)))
        if str(step.get("op", "")) in ["ATTACK", "INDEPENDENT_ATTACK", "SPECIAL_CLASH"]:
            if step.has("min_range"):
                minimum = maxi(0, int(step.get("min_range", minimum)))
            if step.has("max_range"):
                maximum = maxi(minimum, int(step.get("max_range", maximum)))
            break
    var effective_distance := maxi(0, distance - approach)
    return Vector3i(effective_distance, minimum, maximum)

func _append_candidate(candidates: Array, card_id: String, score: float, reason_codes: Array, cards_by_id: Dictionary, definition: Dictionary = {}) -> void:
    if not cards_by_id.has(card_id):
        return
    var card_definition: Dictionary = cards_by_id.get(card_id, {})
    if bool(card_definition.get("player_only", false)):
        return
    for value in candidates:
        if str((value as Dictionary).get("card_id", "")) == card_id:
            return
    var candidate := {
        "card_id": card_id,
        "score": score,
        "reason_codes": reason_codes.duplicate(true)
    }
    if not definition.is_empty():
        candidate["definition"] = definition.duplicate(true)
    candidates.append(candidate)

func _candidate_before(a: Dictionary, b: Dictionary) -> bool:
    var a_score := float(a.get("score", 0.0))
    var b_score := float(b.get("score", 0.0))
    if not is_equal_approx(a_score, b_score):
        return a_score > b_score
    return str(a.get("card_id", "")) < str(b.get("card_id", ""))

func _build_action(candidate: Dictionary, snapshot: Dictionary, supplied_definition: Dictionary = {}, movement_policy: Dictionary = {}, timing: int = -1) -> Dictionary:
    var card_id := str(candidate.get("card_id", ""))
    var definition := supplied_definition.duplicate(true)
    if definition.is_empty():
        var candidate_definition = candidate.get("definition", {})
        definition = (candidate_definition as Dictionary).duplicate(true) if typeof(candidate_definition) == TYPE_DICTIONARY else {}
    var enemy_tile := int(snapshot.get("enemy_tile", 6))
    var player_tile := int(snapshot.get("player_tile", 4))
    var direction := _movement_direction(snapshot, movement_policy)
    var targeting_mode := str(definition.get("targeting_mode", ""))
    var is_move := card_id in ["basic_move", "basic_footwork"] or targeting_mode == "move_tile"
    var move_range := maxi(1, int(definition.get("move_range", 1)))
    var step := mini(move_range, 2) if card_id == "basic_footwork" and int(snapshot.get("distance", 0)) >= 3 else 1
    var reason_codes := _join_reason_codes(candidate.get("reason_codes", []))
    var reason := "public_distance_%d" % int(snapshot.get("distance", 0))
    if not reason_codes.is_empty():
        reason += "_" + reason_codes
    if targeting_mode.is_empty():
        targeting_mode = "move_tile" if is_move else ("none" if card_id in ["basic_meditate", "basic_guard", "basic_evade"] else "attack_direction")
    return {
        "timing": int(snapshot.get("bundle_start", 1)) if timing < 0 else timing,
        "card_id": card_id,
        "targeting_mode": targeting_mode,
        "target_tile": clampi(enemy_tile + direction * step, 1, 10) if is_move else 0,
        "direction": direction if is_move else signi(player_tile - enemy_tile),
        "ai_seed": _scoped_seed(snapshot),
        "ai_reason": reason
    }

func _movement_direction(snapshot: Dictionary, movement_policy: Dictionary) -> int:
    var enemy_tile := int(snapshot.get("enemy_tile", 6))
    var player_tile := int(snapshot.get("player_tile", 4))
    var approach_direction := signi(player_tile - enemy_tile)
    var mode := str(movement_policy.get("mode", "approach"))
    var distance := int(snapshot.get("distance", absi(player_tile - enemy_tile)))
    if mode == "preferred_distance":
        var preferred := maxi(0, int(movement_policy.get("distance", 3)))
        if distance < preferred:
            return -approach_direction
        if distance > preferred:
            return approach_direction
        return 0
    if mode == "hold_or_approach":
        return approach_direction if distance > 3 else 0
    return approach_direction

func _join_reason_codes(value) -> String:
    var codes := PackedStringArray()
    if typeof(value) == TYPE_ARRAY:
        for entry in (value as Array):
            codes.append(str(entry))
    return "+".join(codes)

func _is_valid_runtime_profile(archetype_id: String, ai_profile: Dictionary, basic_action_focus_ids: Array[String]) -> bool:
    if archetype_id.is_empty() or str(ai_profile.get("id", "")) != archetype_id:
        return false
    var score_weights = ai_profile.get("score_weights", {})
    var movement_policy = ai_profile.get("movement_policy", {})
    var history_policy = ai_profile.get("history_policy", {})
    if typeof(score_weights) != TYPE_DICTIONARY or typeof(movement_policy) != TYPE_DICTIONARY or typeof(history_policy) != TYPE_DICTIONARY:
        return false
    for score_id in ["approach", "quick_pressure", "heavy_prepare", "response_low_health", "recover_low_resource", "ultimate_ready"]:
        if not (score_weights as Dictionary).has(score_id):
            return false
    if int(ai_profile.get("max_actions_per_bundle", 0)) < 1 or int(ai_profile.get("max_actions_per_bundle", 0)) > 2:
        return false
    if str((movement_policy as Dictionary).get("mode", "")) not in ["approach", "preferred_distance", "hold_or_approach"]:
        return false
    if str((history_policy as Dictionary).get("mode", "")) not in ["none", "last_two_player_resolved_cards", "own_planned_cards_only"]:
        return false
    if basic_action_focus_ids.size() > 3:
        return false
    var seen: Dictionary = {}
    for card_id in basic_action_focus_ids:
        if card_id.is_empty() or seen.has(card_id):
            return false
        seen[card_id] = true
    return true

func _active_profile() -> Dictionary:
    if not _runtime_binding.is_empty():
        return (_runtime_binding.get("ai_profile", {}) as Dictionary).duplicate(true)
    var active_id := str(_rival_data.get("active_rival_id", ""))
    var profiles: Array = _rival_data.get("profiles", [])
    for value in profiles:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("id", "")) == active_id:
            return (value as Dictionary).duplicate(true)
    if not profiles.is_empty() and typeof(profiles[0]) == TYPE_DICTIONARY:
        return (profiles[0] as Dictionary).duplicate(true)
    return {"id": "fallback", "weights": {}}

func _scoped_seed(snapshot: Dictionary) -> int:
    return int(snapshot.get("ai_decision_seed", 0)) + int(snapshot.get("round_number", 1)) * 101 + int(snapshot.get("bundle_index", 1)) * 17

func _resource_current(actor: Dictionary, key: String, fallback: int) -> int:
    var pair = actor.get(key, [fallback, fallback])
    if typeof(pair) == TYPE_ARRAY and (pair as Array).size() >= 1:
        return int((pair as Array)[0])
    return fallback

func _resource_maximum(actor: Dictionary, key: String, fallback: int) -> int:
    var pair = actor.get(key, [fallback, fallback])
    if typeof(pair) == TYPE_ARRAY and (pair as Array).size() >= 2:
        return int((pair as Array)[1])
    return fallback

func _load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("Rival tendency file was not found: %s" % path)
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _bundle_bounds(bundle_index: int) -> Vector2i:
    var sequence := [3, 3, 4]
    var normalized_index := clampi(bundle_index, 1, sequence.size())
    var start := 1
    for index in range(normalized_index - 1):
        start += int(sequence[index])
    return Vector2i(start, start + int(sequence[normalized_index - 1]) - 1)
