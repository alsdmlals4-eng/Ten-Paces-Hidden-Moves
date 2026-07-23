# 공개 전투 상태만으로 적의 현재 행동 묶음을 결정하는 최소 비치팅 AI다.
class_name CombatAiPlanner
extends RefCounted

func build_bundle_actions(state: Dictionary, bundle_index: int, cards_by_id: Dictionary) -> Array:
    var enemy: Dictionary = state.get("enemy", {})
    var player: Dictionary = state.get("player", {})
    var enemy_tile := int(enemy.get("tile", 7))
    var player_tile := int(player.get("tile", 4))
    var direction := signi(player_tile - enemy_tile)
    var bounds := _bundle_bounds(bundle_index)
    var timing := bounds.x
    var slots := bounds.y - bounds.x + 1
    var distance := absi(player_tile - enemy_tile)
    var momentum: Array = enemy.get("momentum", [0, 5])
    var stamina: Array = enemy.get("stamina", [0, 5])
    var internal: Array = enemy.get("internal", [0, 4])
    var health: Array = enemy.get("health", [30, 30])
    var card_id := _choose_card(distance, slots, int(momentum[0]), int(momentum[1]), int(stamina[0]), int(internal[0]), int(health[0]))
    if not cards_by_id.has(card_id):
        return []
    var is_move := card_id in ["basic_move", "basic_footwork"]
    return [{"timing": timing, "card_id": card_id, "targeting_mode": "move_tile" if is_move else ("none" if card_id in ["basic_meditate", "basic_guard", "basic_evade"] else "attack_direction"), "target_tile": clampi(enemy_tile + direction, 1, 10) if is_move else 0, "direction": direction, "ai_seed": int(state.get("ai_decision_seed", 0)), "ai_reason": "public_distance_%d_slots_%d" % [distance, slots]}]

func _choose_card(distance: int, slots: int, momentum: int, momentum_max: int, stamina: int, internal: int, health: int) -> String:
    if momentum == momentum_max:
        if distance == 3 and slots >= 3:
            return "ultimate_void_sword_qi"
        if distance == 2 and slots >= 2:
            return "ultimate_cleave_peak"
        if distance <= 1:
            return "ultimate_ten_paces_wave"
    if health <= 10 and distance <= 2:
        return "basic_evade" if stamina >= 1 else "basic_guard"
    if stamina <= 0 or internal <= 0:
        return "basic_meditate"
    if distance <= 1:
        return "basic_quick_attack"
    if distance <= 2 and slots >= 2 and stamina >= 1 and internal >= 1:
        return "basic_heavy_attack"
    return "basic_move"

func _bundle_bounds(bundle_index: int) -> Vector2i:
    var sequence := [3, 3, 4]
    var start := 1
    for index in range(maxi(0, bundle_index - 1)):
        start += int(sequence[index])
    return Vector2i(start, start + int(sequence[bundle_index - 1]) - 1)
