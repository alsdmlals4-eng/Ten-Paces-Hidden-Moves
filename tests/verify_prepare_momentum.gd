extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"
const PLAYER_START_TILE := 4
const ENEMY_START_TILE := 5

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hud := _load_json(HUD_PATH)
    if hud.is_empty():
        failures.append("Combat HUD fixture could not be loaded.")
        _finish()
        return
    _verify_prepare_meditate(hud)
    _verify_prepare_survives_movement(hud)
    _verify_prepare_attack(hud)
    _verify_failed_non_move_consumes(hud)
    _verify_momentum_cap(hud)
    _finish()

func _new_engine() -> CombatResolutionEngine:
    var engine := CombatResolutionEngine.new()
    engine.rules["enemy_bundles"] = {}
    return engine

func _new_state(engine: CombatResolutionEngine, hud: Dictionary) -> Dictionary:
    var state := engine.make_initial_state(hud, PLAYER_START_TILE, ENEMY_START_TILE)
    state["ai_enabled"] = false
    return state

func _verify_prepare_meditate(hud: Dictionary) -> void:
    var engine := _new_engine()
    var state := _new_state(engine, hud)
    var placements := [
        _placement(engine.cards_by_id.get("basic_stance", {}), 1),
        _placement(engine.cards_by_id.get("basic_meditate", {}), 2)
    ]
    var result := engine.resolve_bundle(placements, _context(), state)
    var player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
    if _resource_current(player, "momentum") != 1:
        failures.append("Prepare -> meditation must grant exactly one ultimate momentum.")
    if bool(player.get("prepare_active", true)):
        failures.append("Meditation must consume prepare after the reward is applied.")

func _verify_prepare_survives_movement(hud: Dictionary) -> void:
    var engine := _new_engine()
    var state := _new_state(engine, hud)
    var move := _placement(engine.cards_by_id.get("basic_move", {}), 2)
    move["targeting_mode"] = "move_tile"
    move["target_tile"] = PLAYER_START_TILE
    move["origin_tile"] = PLAYER_START_TILE
    move["direction"] = 1
    var placements := [
        _placement(engine.cards_by_id.get("basic_stance", {}), 1),
        move,
        _placement(engine.cards_by_id.get("basic_meditate", {}), 3)
    ]
    var result := engine.resolve_bundle(placements, _context(), state)
    var player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
    if _resource_current(player, "momentum") != 1:
        failures.append("Movement between prepare and meditation must not remove the momentum reward.")
    if bool(player.get("prepare_active", true)):
        failures.append("Meditation after movement must consume prepare.")

func _verify_prepare_attack(hud: Dictionary) -> void:
    var engine := _new_engine()
    var state := _new_state(engine, hud)
    var move := _placement(engine.cards_by_id.get("basic_move", {}), 2)
    move["targeting_mode"] = "move_tile"
    move["target_tile"] = PLAYER_START_TILE
    move["origin_tile"] = PLAYER_START_TILE
    move["direction"] = 1
    var attack := _placement(engine.cards_by_id.get("basic_quick_attack", {}), 3)
    attack["targeting_mode"] = "attack_direction"
    attack["direction"] = 1
    var placements := [
        _placement(engine.cards_by_id.get("basic_stance", {}), 1),
        move,
        attack
    ]
    var result := engine.resolve_bundle(placements, _context(), state)
    var resolved: Array = result.get("resolved_actions", [])
    var attack_damage := -1
    for value in resolved:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("card_id", "")) == "basic_quick_attack":
            attack_damage = int((value as Dictionary).get("raw_damage", -1))
    if attack_damage != 8:
        failures.append("Prepare must add the existing +2 bonus to the next attack after movement. actual=%d" % attack_damage)
    var player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
    if bool(player.get("prepare_active", true)) or int(player.get("next_attack_bonus", -1)) != 0:
        failures.append("The empowered attack must consume prepare and clear its attack bonus.")

func _verify_failed_non_move_consumes(hud: Dictionary) -> void:
    var engine := _new_engine()
    var state := _new_state(engine, hud)
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    player["stamina"] = [0, int((player.get("stamina", [0, 1]) as Array)[1])]
    state["player"] = player
    var placements := [
        _placement(engine.cards_by_id.get("basic_stance", {}), 1),
        _placement(engine.cards_by_id.get("basic_quick_attack", {}), 2)
    ]
    var result := engine.resolve_bundle(placements, _context(), state)
    player = (result.get("state", {}) as Dictionary).get("player", {})
    if bool(player.get("prepare_active", true)):
        failures.append("A failed non-movement action attempt must consume prepare.")

func _verify_momentum_cap(hud: Dictionary) -> void:
    var engine := _new_engine()
    var state := _new_state(engine, hud)
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [5, 5]
    state["player"] = player
    var placements := [
        _placement(engine.cards_by_id.get("basic_stance", {}), 1),
        _placement(engine.cards_by_id.get("basic_meditate", {}), 2)
    ]
    var result := engine.resolve_bundle(placements, _context(), state)
    player = (result.get("state", {}) as Dictionary).get("player", {})
    if _resource_current(player, "momentum") != 5:
        failures.append("Prepare-enhanced meditation must not exceed the momentum maximum.")

func _placement(definition_value, anchor: int) -> Dictionary:
    var definition: Dictionary = (definition_value as Dictionary).duplicate(true) if typeof(definition_value) == TYPE_DICTIONARY else {}
    var span := maxi(1, int(definition.get("action_slots", 1)))
    var indices := PackedInt32Array()
    for offset in range(span):
        indices.append(anchor + offset)
    return {
        "card_id": str(definition.get("id", "")),
        "card_name": str(definition.get("name", "")),
        "definition": definition,
        "anchor_index": anchor,
        "span": span,
        "indices": indices,
        "targeting_mode": "none",
        "target_ready": true,
        "target_tile": 0,
        "direction": 1,
        "origin_tile": PLAYER_START_TILE
    }

func _context() -> Dictionary:
    return {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}

func _resource_current(actor: Dictionary, key: String) -> int:
    var pair = actor.get(key, [0, 0])
    return int(pair[0]) if typeof(pair) == TYPE_ARRAY and pair.size() >= 1 else 0

func _load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _finish() -> void:
    if failures.is_empty():
        print("PREPARE_MOMENTUM_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("PREPARE_MOMENTUM_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
