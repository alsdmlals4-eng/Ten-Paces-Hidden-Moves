extends "res://src/combat/combat_board_preview_auto.gd"

const TEN_MANUAL_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine_ten_manuals.gd")
const TEN_MANUAL_LOADOUT_PATH := "res://data/combat/ten_manual_loadout_poc.json"

var _ten_manual_loadout_data: Dictionary = {}

func _ready() -> void:
    super._ready()
    _ten_manual_loadout_data = _load_ten_manual_loadout()
    var player_config: Dictionary = _ten_manual_loadout_data.get("player", {})
    var enemy_config: Dictionary = _ten_manual_loadout_data.get("enemy", {})
    var engine: TenManualCombatResolutionEngine = TEN_MANUAL_ENGINE_SCRIPT.new()
    engine.configure_martial_loadouts(
        _string_values(player_config.get("loadout", [])),
        _dictionary_value(player_config.get("mastery_by_manual", {})),
        _string_values(enemy_config.get("loadout", [])),
        _dictionary_value(enemy_config.get("mastery_by_manual", {}))
    )
    resolution_engine = engine
    combat_state = resolution_engine.make_initial_state(top_hud.hud_data, _player_tile, _enemy_tile)
    combat_state["ai_enabled"] = true
    _configure_ultimate_menu()
    _sync_action_placement_controller_state()
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()
    set_meta("ten_manual_ui_ai_adoption", true)
    set_meta("ten_manual_loadout_authority", str(_ten_manual_loadout_data.get("authority", "")))

func _build_action_selection_runtime_context() -> Dictionary:
    var context := super._build_action_selection_runtime_context()
    var player_config: Dictionary = _ten_manual_loadout_data.get("player", {})
    context["martial_loadout"] = _string_values(player_config.get("loadout", []))
    context["martial_mastery_by_manual"] = _dictionary_value(player_config.get("mastery_by_manual", {}))
    return context

func _load_ten_manual_loadout() -> Dictionary:
    if not FileAccess.file_exists(TEN_MANUAL_LOADOUT_PATH):
        push_error("Ten-manual loadout file not found: %s" % TEN_MANUAL_LOADOUT_PATH)
        return {}
    var file := FileAccess.open(TEN_MANUAL_LOADOUT_PATH, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Ten-manual loadout root must be a Dictionary.")
        return {}
    return parsed

func _string_values(value) -> Array:
    var result: Array = []
    if typeof(value) != TYPE_ARRAY and typeof(value) != TYPE_PACKED_STRING_ARRAY:
        return result
    for entry in value:
        result.append(str(entry))
    return result

func _dictionary_value(value) -> Dictionary:
    return (value as Dictionary).duplicate(true) if typeof(value) == TYPE_DICTIONARY else {}
