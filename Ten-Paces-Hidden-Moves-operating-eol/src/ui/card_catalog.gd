class_name CardCatalog
extends RefCounted

const REQUIRED_FIELDS := ["id", "name", "source_label", "source_badge", "range_text", "category", "category_label", "category_badge", "illustration", "target", "damage", "condition", "effect_text", "tags", "action_slots", "stamina_cost", "internal_cost", "flavor"]
const FORBIDDEN_FIELDS := ["action_point_cost", "guard_reduction"]

static func load_cards(path: String) -> Array[Dictionary]:
    if not FileAccess.file_exists(path):
        push_error("Card catalog not found: %s" % path)
        return []
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("cards", [])) != TYPE_ARRAY:
        push_error("Invalid card catalog: %s" % path)
        return []
    var result: Array[Dictionary] = []
    for raw in parsed.cards:
        if typeof(raw) != TYPE_DICTIONARY:
            continue
        var missing: Array[String] = []
        var forbidden: Array[String] = []
        for field in REQUIRED_FIELDS:
            if not raw.has(field): missing.append(field)
        for field in FORBIDDEN_FIELDS:
            if raw.has(field): forbidden.append(field)
        if not missing.is_empty() or not forbidden.is_empty():
            push_error("Invalid card %s missing=%s forbidden=%s" % [raw.get("id", "?"), missing, forbidden])
            continue
        result.append(raw)
    return result
