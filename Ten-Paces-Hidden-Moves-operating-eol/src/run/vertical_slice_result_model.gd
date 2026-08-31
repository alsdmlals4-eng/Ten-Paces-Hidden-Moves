class_name VerticalSliceResultModel
extends RefCounted

const METRICS_SCRIPT := preload("res://src/run/vertical_slice_battle_metrics.gd")
const GRADE_STATUS := "FORMULA_PENDING"

var battle_metrics: VerticalSliceBattleMetrics


func _init() -> void:
    battle_metrics = METRICS_SCRIPT.new()


func build_snapshot(terminal_result: Dictionary, player_loadout, opponent: Dictionary) -> Dictionary:
    return {
        "outcome": str(terminal_result.get("outcome", "draw")),
        "player_health": int(terminal_result.get("player_health", 0)),
        "enemy_health": int(terminal_result.get("enemy_health", 0)),
        "grade_status": GRADE_STATUS,
        "final_grade": "",
        "battle_metrics": battle_metrics.normalize(terminal_result.get("battle_metrics", {})),
        "reward_options": build_reward_options(player_loadout, opponent)
    }


func build_reward_options(player_loadout, opponent: Dictionary) -> Array:
    var result: Array = [
        {
            "reward_type": "free_training",
            "label": "자유 수련",
            "free_training": 6,
            "focused_training": 0,
            "target_required": false,
            "application_status": "DEFERRED_TO_PHASE_V"
        },
        {
            "reward_type": "focused_training",
            "label": "집중 수련",
            "free_training": 3,
            "focused_training": 5,
            "target_required": true,
            "eligible_manual_ids": _string_values(player_loadout),
            "application_status": "DEFERRED_TO_PHASE_V"
        }
    ]
    var signature_manual_id := str(opponent.get("signature_manual_id", ""))
    result.append({
        "reward_type": "faction_transfer",
        "label": "문파 전수",
        "manual_id": signature_manual_id,
        "mastery": 3,
        "target_required": false,
        "application_status": "DEFERRED_TO_PHASE_V"
    })
    return result


func build_reward_receipt(reward_type: String, target_manual_id: String, player_loadout, opponent: Dictionary) -> Dictionary:
    match reward_type:
        "free_training":
            return {
                "reward_type": "free_training",
                "free_training": 6,
                "focused_training": 0,
                "target_manual_id": "",
                "application_status": "DEFERRED_TO_PHASE_V"
            }
        "focused_training":
            var player_ids := _string_values(player_loadout)
            if target_manual_id.is_empty() or target_manual_id not in player_ids:
                return {}
            return {
                "reward_type": "focused_training",
                "free_training": 3,
                "focused_training": 5,
                "target_manual_id": target_manual_id,
                "application_status": "DEFERRED_TO_PHASE_V"
            }
        "faction_transfer":
            var signature_manual_id := str(opponent.get("signature_manual_id", ""))
            if signature_manual_id.is_empty():
                return {}
            return {
                "reward_type": "faction_transfer",
                "manual_id": signature_manual_id,
                "mastery": 3,
                "target_manual_id": "",
                "application_status": "DEFERRED_TO_PHASE_V"
            }
    return {}


func _string_values(values) -> Array[String]:
    var result: Array[String] = []
    if typeof(values) != TYPE_ARRAY and typeof(values) != TYPE_PACKED_STRING_ARRAY:
        return result
    for value in values:
        var text := str(value)
        if not text.is_empty():
            result.append(text)
    return result
