class_name TenManualCombatResolutionEngine
extends "res://src/combat/combat_resolution_engine.gd"

const MartialManualRegistryScript := preload("res://src/combat/martial_manual_registry.gd")
const MartialEffectPipelineScript := preload("res://src/combat/martial_effect_pipeline.gd")

var martial_registry: MartialManualRegistry
var martial_effect_pipeline: MartialEffectPipeline
var _loaded_martial_card_ids := PackedStringArray()

func _init() -> void:
    super()
    martial_registry = MartialManualRegistryScript.new()
    martial_effect_pipeline = MartialEffectPipelineScript.new()

func configure_martial_loadout(loadout: Array, mastery_by_manual: Dictionary) -> void:
    _remove_loaded_martial_cards()
    var unlocked: Dictionary = martial_registry.build_loadout_cards(loadout, mastery_by_manual)
    var ids := PackedStringArray()
    for card_key in unlocked.keys():
        var card_id := str(card_key)
        var card: Dictionary = unlocked.get(card_key, {})
        cards_by_id[card_id] = card.duplicate(true)
        ids.append(card_id)
    ids.sort()
    _loaded_martial_card_ids = ids

func resolve_martial_card(card_id: String, state: Dictionary, actor_key: String, context: Dictionary = {}) -> Dictionary:
    if not cards_by_id.has(card_id):
        return {
            "state": state.duplicate(true),
            "events": [],
            "completed": false,
            "failure_reason": "MARTIAL_CARD_NOT_LOADED",
            "actual_hp_hits": 0,
            "clash_won": false,
            "evade_succeeded": false
        }
    var definition: Dictionary = cards_by_id.get(card_id, {})
    if str(definition.get("source", "")) != "martial_manual":
        return {
            "state": state.duplicate(true),
            "events": [],
            "completed": false,
            "failure_reason": "NOT_A_MARTIAL_CARD",
            "actual_hp_hits": 0,
            "clash_won": false,
            "evade_succeeded": false
        }
    return martial_effect_pipeline.execute(definition.duplicate(true), state, actor_key, context)

func get_loaded_martial_card_ids() -> PackedStringArray:
    return _loaded_martial_card_ids.duplicate()

func _remove_loaded_martial_cards() -> void:
    for card_id in _loaded_martial_card_ids:
        cards_by_id.erase(str(card_id))
    _loaded_martial_card_ids = PackedStringArray()
