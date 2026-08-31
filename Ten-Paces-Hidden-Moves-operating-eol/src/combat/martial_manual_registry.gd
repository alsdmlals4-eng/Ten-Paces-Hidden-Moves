class_name MartialManualRegistry
extends RefCounted

const DEFAULT_MANIFEST_PATH := "res://data/cards/martial_manual_cards.json"
const CARD_STAGES := ["star3", "star7", "star10"]
const OVERLAY_STAGES := ["star5", "star9"]

var manifest_path: String = DEFAULT_MANIFEST_PATH
var manifest: Dictionary = {}
var manuals: Dictionary = {}
var load_errors: Array[String] = []

func _init(path: String = DEFAULT_MANIFEST_PATH) -> void:
    manifest_path = path
    _load_manifest()

func is_valid() -> bool:
    return load_errors.is_empty() and manuals.size() == 10

func get_manual_ids() -> PackedStringArray:
    var result := PackedStringArray()
    for manual_id in manuals.keys():
        result.append(str(manual_id))
    result.sort()
    return result

func get_manual(manual_id: String) -> Dictionary:
    if not manuals.has(manual_id):
        return {}
    return (manuals.get(manual_id, {}) as Dictionary).duplicate(true)

func build_unlocked_cards(manual_id: String, mastery: int) -> Array:
    var manual: Dictionary = manuals.get(manual_id, {})
    if manual.is_empty():
        return []
    var result: Array = []
    var cards: Dictionary = manual.get("cards", {})
    for stage_value in CARD_STAGES:
        var stage := str(stage_value)
        var card_source: Dictionary = cards.get(stage, {})
        if card_source.is_empty() or mastery < int(card_source.get("unlock_star", 99)):
            continue
        var card := card_source.duplicate(true)
        card["faction"] = str(manual.get("faction", ""))
        card["manual_name"] = str(manual.get("manual_name", ""))
        card["primary_stat"] = str(manual.get("primary_stat", ""))
        card["secondary_stat"] = str(manual.get("secondary_stat", ""))
        card["mastery"] = mastery
        card["applied_overlays"] = []
        _apply_unlocked_overlays(manual, stage, mastery, card)
        result.append(card)
    return result

func build_loadout_cards(loadout: Array, mastery_by_manual: Dictionary) -> Dictionary:
    var result: Dictionary = {}
    for manual_value in loadout:
        var manual_id := str(manual_value)
        var mastery := int(mastery_by_manual.get(manual_id, 0))
        for card_value in build_unlocked_cards(manual_id, mastery):
            if typeof(card_value) != TYPE_DICTIONARY:
                continue
            var card: Dictionary = card_value
            var card_id := str(card.get("id", ""))
            if card_id.is_empty():
                continue
            result[card_id] = card.duplicate(true)
    return result

func build_product_validation_snapshot(manual_id: String, mastery: int) -> Dictionary:
    var manual: Dictionary = manuals.get(manual_id, {})
    if manual.is_empty() or mastery < 0 or mastery > 10:
        return {}
    var cards: Array = build_unlocked_cards(manual_id, mastery)
    var star5_overlay_count := 0
    var star9_overlay_count := 0
    for card_value in cards:
        if typeof(card_value) != TYPE_DICTIONARY:
            continue
        var card: Dictionary = card_value
        var card_id := str(card.get("id", ""))
        var overlays_value = card.get("applied_overlays", [])
        if typeof(overlays_value) != TYPE_ARRAY:
            continue
        var overlays: Array = overlays_value
        if card_id.ends_with("_star3"):
            star5_overlay_count += overlays.size()
        elif card_id.ends_with("_star7"):
            star9_overlay_count += overlays.size()
    return {
        "manual_id": manual_id,
        "manual_name": str(manual.get("manual_name", "")),
        "faction": str(manual.get("faction", "")),
        "primary_stat": str(manual.get("primary_stat", "")),
        "secondary_stat": str(manual.get("secondary_stat", "")),
        "mastery": mastery,
        "star3_unlocked": mastery >= 3,
        "star7_unlocked": mastery >= 7,
        "star10_unlocked": mastery >= 10,
        "star5_overlay_count": star5_overlay_count,
        "star9_overlay_count": star9_overlay_count,
        "card_count": cards.size(),
        "cards": cards.duplicate(true)
    }

func _apply_unlocked_overlays(manual: Dictionary, card_stage: String, mastery: int, card: Dictionary) -> void:
    var overlays: Dictionary = manual.get("overlays", {})
    var applied: Array = card.get("applied_overlays", [])
    var steps: Array = card.get("effect_steps", [])
    for overlay_stage_value in OVERLAY_STAGES:
        var overlay_stage := str(overlay_stage_value)
        var overlay: Dictionary = overlays.get(overlay_stage, {})
        if overlay.is_empty():
            continue
        if mastery < int(overlay.get("unlock_star", 99)):
            continue
        if str(overlay.get("target", "")) != card_stage:
            continue
        for step_value in overlay.get("effect_steps", []):
            if typeof(step_value) == TYPE_DICTIONARY:
                steps.append((step_value as Dictionary).duplicate(true))
        applied.append(str(overlay.get("name", overlay_stage)))
    card["effect_steps"] = steps
    card["applied_overlays"] = applied

func _load_manifest() -> void:
    manifest = _load_json(manifest_path, "martial manual manifest")
    if manifest.is_empty():
        return
    var files_value = manifest.get("manual_files", {})
    if typeof(files_value) != TYPE_DICTIONARY:
        load_errors.append("martial manual manifest manual_files must be a Dictionary")
        return
    var files: Dictionary = files_value
    for manual_key in files.keys():
        var manual_id := str(manual_key)
        var relative_path := str(files.get(manual_key, ""))
        var resource_path := relative_path if relative_path.begins_with("res://") else "res://" + relative_path
        var manual := _load_json(resource_path, "martial manual %s" % manual_id)
        if manual.is_empty():
            continue
        if str(manual.get("manual_id", "")) != manual_id:
            load_errors.append("manual ID mismatch for %s" % manual_id)
            continue
        if manuals.has(manual_id):
            load_errors.append("duplicate manual ID: %s" % manual_id)
            continue
        manuals[manual_id] = manual.duplicate(true)

func _load_json(path: String, label: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        load_errors.append("%s file was not found: %s" % [label, path])
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        load_errors.append("%s file could not be opened: %s" % [label, path])
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        load_errors.append("%s root must be a Dictionary" % label)
        return {}
    return parsed as Dictionary
