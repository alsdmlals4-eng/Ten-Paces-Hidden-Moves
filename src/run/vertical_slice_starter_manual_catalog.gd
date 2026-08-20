class_name VerticalSliceStarterManualCatalog
extends RefCounted

const REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const STARTER_MANUAL_IDS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear",
    "mount_hua_purple_mist_art",
    "xiaoyao_lingbo_footwork"
]
const STARTER_MASTERY := 3
const REQUIRED_SELECTION_COUNT := 4

var registry: MartialManualRegistry
var load_errors: Array[String] = []
var _options: Array[Dictionary] = []


func _init() -> void:
    registry = REGISTRY_SCRIPT.new()
    _build_options()


func is_valid() -> bool:
    return load_errors.is_empty() and registry != null and registry.is_valid() and _options.size() == STARTER_MANUAL_IDS.size()


func get_options() -> Array:
    var result: Array = []
    for option in _options:
        result.append(option.duplicate(true))
    return result


func get_option(manual_id: String) -> Dictionary:
    for option in _options:
        if str(option.get("manual_id", "")) == manual_id:
            return option.duplicate(true)
    return {}


func validate_selection(selection) -> bool:
    if typeof(selection) != TYPE_ARRAY and typeof(selection) != TYPE_PACKED_STRING_ARRAY:
        return false
    if selection.size() != REQUIRED_SELECTION_COUNT:
        return false
    var seen := {}
    for value in selection:
        var manual_id := str(value)
        if manual_id.is_empty() or seen.has(manual_id) or not manual_id in STARTER_MANUAL_IDS:
            return false
        seen[manual_id] = true
    return true


func build_mastery(selection) -> Dictionary:
    if not validate_selection(selection):
        return {}
    var result := {}
    for value in selection:
        result[str(value)] = STARTER_MASTERY
    return result


func _build_options() -> void:
    _options.clear()
    load_errors.clear()
    if registry == null or not registry.is_valid():
        load_errors.append("current ten-manual registry must be valid before starter options are built")
        return

    for manual_id in STARTER_MANUAL_IDS:
        var manual: Dictionary = registry.get_manual(manual_id)
        if manual.is_empty():
            load_errors.append("starter manual is missing from current registry: %s" % manual_id)
            continue
        var unlocked: Array = registry.build_unlocked_cards(manual_id, STARTER_MASTERY)
        if unlocked.size() != 1 or typeof(unlocked[0]) != TYPE_DICTIONARY:
            load_errors.append("starter manual must expose exactly its star3 technique at mastery 3: %s" % manual_id)
            continue
        var star3: Dictionary = unlocked[0]
        _options.append({
            "manual_id": manual_id,
            "faction": str(manual.get("faction", "")),
            "manual_name": str(manual.get("manual_name", "")),
            "primary_stat": str(manual.get("primary_stat", "")),
            "secondary_stat": str(manual.get("secondary_stat", "")),
            "mastery": STARTER_MASTERY,
            "star3_card_id": str(star3.get("id", "")),
            "star3_card_name": str(star3.get("name", ""))
        })
