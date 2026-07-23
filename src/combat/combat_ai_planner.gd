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
    var distance := absi(player_tile - enemy_tile)
    var card_id := "basic_quick_attack" if distance <= 1 else "basic_move"
    if not cards_by_id.has(card_id):
        return []
    return [{"timing": timing, "card_id": card_id, "targeting_mode": "attack_direction" if card_id == "basic_quick_attack" else "move_tile", "target_tile": enemy_tile + direction, "direction": direction, "ai_reason": "public_distance_%d" % distance}]

func _bundle_bounds(bundle_index: int) -> Vector2i:
    var sequence := [3, 3, 4]
    var start := 1
    for index in range(maxi(0, bundle_index - 1)):
        start += int(sequence[index])
    return Vector2i(start, start + int(sequence[bundle_index - 1]) - 1)
