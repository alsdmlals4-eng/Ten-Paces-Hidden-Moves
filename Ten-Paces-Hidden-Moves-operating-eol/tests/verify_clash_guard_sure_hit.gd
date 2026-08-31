# 합·순차 방어·필중 전투 계약을 엔진과 이벤트 수준에서 검증한다.
extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hud := _load_json(HUD_PATH)
    _verify_clash_difference(hud)
    _verify_clash_draw(hud)
    _verify_sure_hit_ignores_evade(hud)
    _finish()

func _verify_clash_difference(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    var enemy_attack: Dictionary = (engine.cards_by_id.get("basic_heavy_attack", {}) as Dictionary).duplicate(true)
    enemy_attack["id"] = "enemy_clash_attack"
    enemy_attack["action_slots"] = 1
    enemy_attack["damage"] = "8"
    engine.cards_by_id["enemy_clash_attack"] = enemy_attack
    engine.rules["enemy_bundles"] = {"1": [{"timing": 1, "card_id": "enemy_clash_attack", "direction": -1}]}
    var quick: Dictionary = engine.cards_by_id.get("basic_quick_attack", {})
    var result := engine.resolve_bundle([_placement(quick, 1, 1)], _context(), engine.make_initial_state(hud, 4, 5))
    var player: Dictionary = (result.get("state", {}) as Dictionary).get("player", {})
    if int((player.get("health", [0, 0]) as Array)[0]) != 28:
        failures.append("A 6-versus-8 clash must deal only 2 damage to the lower attack. expected=28")
    if not _has_clash_event(result.get("presentation_events", [])):
        failures.append("A valid same-timing quick/general attack pair must emit an authoritative clash event.")

func _verify_clash_draw(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    var enemy_attack: Dictionary = (engine.cards_by_id.get("basic_quick_attack", {}) as Dictionary).duplicate(true)
    enemy_attack["id"] = "enemy_equal_clash"
    engine.cards_by_id["enemy_equal_clash"] = enemy_attack
    engine.rules["enemy_bundles"] = {"1": [{"timing": 1, "card_id": "enemy_equal_clash", "direction": -1}]}
    var quick: Dictionary = engine.cards_by_id.get("basic_quick_attack", {})
    var result := engine.resolve_bundle([_placement(quick, 1, 1)], _context(), engine.make_initial_state(hud, 4, 5))
    var state: Dictionary = result.get("state", {})
    if int(((state.get("player", {}) as Dictionary).get("health", [0, 0]) as Array)[0]) != 30 or int(((state.get("enemy", {}) as Dictionary).get("health", [0, 0]) as Array)[0]) != 30:
        failures.append("Equal clash power must deal zero damage to both sides.")

func _verify_sure_hit_ignores_evade(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    engine.rules["enemy_bundles"] = {"1": [{"timing": 3, "card_id": "basic_evade", "direction": 0}]}
    var sure_hit: Dictionary = engine.cards_by_id.get("ultimate_void_sword_qi", {})
    var state := engine.make_initial_state(hud, 4, 5)
    var result := engine.resolve_bundle([_placement(sure_hit, 1, 1)], _context(), state)
    var enemy: Dictionary = (result.get("state", {}) as Dictionary).get("enemy", {})
    if int((enemy.get("health", [0, 0]) as Array)[0]) != 0:
        failures.append("Void Sword Qi must ignore same-timing evade through its sure-hit tag.")
    if not _has_defense_outcome(result.get("resolved_actions", []), "sure_hit"):
        failures.append("Sure-hit resolution must expose a non-evade defense outcome.")

func _placement(definition: Dictionary, anchor: int, direction: int) -> Dictionary:
    return {"card_id": str(definition.get("id", "")), "definition": definition.duplicate(true), "anchor_index": anchor, "span": maxi(1, int(definition.get("action_slots", 1))), "indices": PackedInt32Array([anchor]), "targeting_mode": "attack_direction", "target_ready": true, "direction": direction, "target_tile": 0}

func _context() -> Dictionary:
    return {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}

func _has_clash_event(events: Array) -> bool:
    for event_value in events:
        if typeof(event_value) == TYPE_DICTIONARY and str((event_value as Dictionary).get("type", "")) == "clash":
            return true
    return false

func _has_defense_outcome(actions: Array, outcome: String) -> bool:
    for action_value in actions:
        if typeof(action_value) == TYPE_DICTIONARY and str((action_value as Dictionary).get("defense_outcome", "")) == outcome:
            return true
    return false

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _finish() -> void:
    if failures.is_empty():
        print("CLASH_GUARD_SURE_HIT_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
