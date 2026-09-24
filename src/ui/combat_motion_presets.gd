extends RefCounted

const PATH := "res://data/presentation/combat_motion_presets.json"
static var _catalog: Dictionary = {}

static func for_card(card_id: String) -> Dictionary:
	if _catalog.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary:
			_catalog = parsed
	var cards: Dictionary = _catalog.get("cards", {})
	var selection: Dictionary = cards.get(card_id, {})
	var families: Dictionary = _catalog.get("families", {})
	var family := str(selection.get("family", "neutral"))
	var result: Dictionary = families.get(family, {"duration":0.4, "travel":0.0, "windup":0.4, "hit_stop":0.0, "pose":"neutral", "contact":"none", "curve":"sine", "camera":0.0}).duplicate(true)
	result.merge(selection.get("overrides", {}), true)
	result["family"] = family
	result["card_id"] = card_id
	return result
