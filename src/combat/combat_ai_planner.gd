# 공개 전투 상태만으로 합리적 후보를 만들고, 재현 가능한 seed로 하나를 고르는 비치팅 AI다.
class_name CombatAiPlanner
extends RefCounted

const RIVAL_PATH := "res://data/combat/combat_rival_tendency_poc.json"

var _rival_data: Dictionary = {}
var _last_trace: Dictionary = {}

func _init() -> void:
    _rival_data = _load_json(RIVAL_PATH)

func get_last_trace() -> Dictionary:
    return _last_trace.duplicate(true)

func build_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array:
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

    var seed := _scoped_seed(snapshot)
    var selected_index := absi(seed) % rational_candidates.size()
    var selected: Dictionary = rational_candidates[selected_index]
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

func _build_public_snapshot(state: Dictionary, bundle_index: int) -> Dictionary:
    var enemy: Dictionary = state.get("enemy", {})
    var player: Dictionary = state.get("player", {})
    var enemy_tile := int(enemy.get("tile", 7))
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

func _build_candidates(snapshot: Dictionary, profile: Dictionary, cards_by_id: Dictionary) -> Array:
    var candidates: Array = []
    var weights: Dictionary = profile.get("weights", {})
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

    if distance > 1:
        _append_candidate(candidates, "basic_move", 6.0 + float(weights.get("approach", 0.0)), ["midrange_pressure"], cards_by_id)
        if distance >= 3 and internal >= 1:
            _append_candidate(candidates, "basic_footwork", 5.8 + float(weights.get("approach", 0.0)), ["midrange_pressure"], cards_by_id)

    if candidates.is_empty():
        _append_candidate(candidates, "basic_guard", 1.0, ["low_health_response"], cards_by_id)
    return candidates

func _append_candidate(candidates: Array, card_id: String, score: float, reason_codes: Array, cards_by_id: Dictionary) -> void:
    if not cards_by_id.has(card_id):
        return
    for value in candidates:
        if str((value as Dictionary).get("card_id", "")) == card_id:
            return
    candidates.append({
        "card_id": card_id,
        "score": score,
        "reason_codes": reason_codes.duplicate(true)
    })

func _candidate_before(a: Dictionary, b: Dictionary) -> bool:
    var a_score := float(a.get("score", 0.0))
    var b_score := float(b.get("score", 0.0))
    if not is_equal_approx(a_score, b_score):
        return a_score > b_score
    return str(a.get("card_id", "")) < str(b.get("card_id", ""))

func _build_action(candidate: Dictionary, snapshot: Dictionary) -> Dictionary:
    var card_id := str(candidate.get("card_id", ""))
    var enemy_tile := int(snapshot.get("enemy_tile", 7))
    var player_tile := int(snapshot.get("player_tile", 4))
    var direction := signi(player_tile - enemy_tile)
    var is_move := card_id in ["basic_move", "basic_footwork"]
    var step := 2 if card_id == "basic_footwork" and int(snapshot.get("distance", 0)) >= 3 else 1
    var reason_codes := _join_reason_codes(_last_trace.get("reason_codes", []))
    var reason := "public_distance_%d" % int(snapshot.get("distance", 0))
    if not reason_codes.is_empty():
        reason += "_" + reason_codes
    return {
        "timing": int(snapshot.get("bundle_start", 1)),
        "card_id": card_id,
        "targeting_mode": "move_tile" if is_move else ("none" if card_id in ["basic_meditate", "basic_guard", "basic_evade"] else "attack_direction"),
        "target_tile": clampi(enemy_tile + direction * step, 1, 10) if is_move else 0,
        "direction": direction,
        "ai_seed": int(_last_trace.get("seed", snapshot.get("ai_decision_seed", 0))),
        "ai_reason": reason
    }

func _join_reason_codes(value) -> String:
    var codes := PackedStringArray()
    if typeof(value) == TYPE_ARRAY:
        for entry in (value as Array):
            codes.append(str(entry))
    return "+".join(codes)

func _active_profile() -> Dictionary:
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
