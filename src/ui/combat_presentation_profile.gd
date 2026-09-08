class_name CombatPresentationProfile
extends RefCounted

const ULTIMATE_BANDS := {
	"ultimate_ten_paces_wave": 0,
	"ultimate_cleave_peak": 1,
	"ultimate_void_sword_qi": 2,
	"beggars_dragon_subduing_palm_star10": 0,
	"shaolin_arhat_vajra_art_star10": 0,
	"mount_hua_plum_blossom_sword_star10": 1,
	"hebei_peng_five_tigers_saber_star10": 1,
	"nangong_boundless_sky_sword_star10": 2,
	"sichuan_tang_hidden_weapons_star10": 2,
	"yang_family_spear_star10": 2,
	"mount_hua_purple_mist_art_star10": 0,
	"wudang_taiji_sword_star10": 0,
	"xiaoyao_lingbo_footwork_star10": 2,
}

const SELF_ANCHORED_ULTIMATES := {
	"mount_hua_purple_mist_art_star10": true,
}


static func for_event(definition: Dictionary, event: Dictionary) -> Dictionary:
	var card_id := str(event.get("card_id", ""))
	var is_ultimate := _is_canonical_ultimate(definition, card_id)
	var is_martial := _matches_definition(definition, card_id) and str(definition.get("source", "")) == "martial_manual"
	var result := {
		"is_ultimate": is_ultimate,
		"kind": "",
		"motion": "",
		"band": -1,
		"anchor": "impact",
	}
	var outcome := str(event.get("outcome", ""))
	if str(event.get("action_stage", "")) == "preparation" or outcome == "preparation":
		return result
	if str(event.get("type", "")) == "clash" or outcome.begins_with("clash_"):
		result.kind = "clash"
		result.motion = "clash"
		return result

	var category := str(event.get("category", definition.get("category", "")))
	var self_anchor := category in ["recovery", "response"] or SELF_ANCHORED_ULTIMATES.has(card_id)
	if is_ultimate and self_anchor:
		result.anchor = "self"
	if _is_failure(outcome) or _target_defended(event) or _requirement_unmet(event) or _all_attacks_blocked(event):
		result.kind = "outcome"
		return result
	if is_martial and category == "response" and outcome in ["response", "response_combo"] and not _has_execution_facts(event):
		result.kind = "outcome"
		result.anchor = "self"
		return result

	if is_ultimate:
		result.kind = "ultimate"
		result.band = int(ULTIMATE_BANDS.get(card_id, -1))
		if category == "attack" or (category == "response" and int(event.get("damage", 0)) > 0):
			result.motion = "ultimate"
			result.anchor = "impact"
		return result

	if category == "attack" or int(event.get("damage", 0)) > 0:
		result.kind = "attack"
		result.motion = "attack"
	return result


static func _is_canonical_ultimate(definition: Dictionary, card_id: String) -> bool:
	if not _matches_definition(definition, card_id):
		return false
	return str(definition.get("source", "")) == "ultimate" or str(definition.get("source_kind", "")) == "ultimate"


static func _matches_definition(definition: Dictionary, card_id: String) -> bool:
	return not definition.is_empty() and not card_id.is_empty() and str(definition.get("id", "")) == card_id


static func _is_failure(outcome: String) -> bool:
	return outcome in ["interrupted", "miss_direction", "miss_range", "move_invalid", "martial_failed"]


static func _target_defended(event: Dictionary) -> bool:
	var defense_outcome := str(event.get("defense_outcome", ""))
	var outcome := str(event.get("outcome", ""))
	return defense_outcome in ["evade", "block", "sure_hit_block"] or outcome in ["evade", "evaded", "block", "blocked", "sure_hit_block"]


static func _requirement_unmet(event: Dictionary) -> bool:
	for value in event.get("martial_events", []):
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var martial_event: Dictionary = value
		var status := str(martial_event.get("status", ""))
		if status == "SKIPPED_REQUIREMENT" or (status == "FAILED" and str(martial_event.get("op", "")).begins_with("REQUIRE_")):
			return true
	return false


static func _all_attacks_blocked(event: Dictionary) -> bool:
	if int(event.get("damage", 0)) > 0:
		return false
	var attempted := 0
	for value in event.get("martial_events", []):
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var martial_event: Dictionary = value
		if str(martial_event.get("op", "")) not in ["ATTACK", "INDEPENDENT_ATTACK"]:
			continue
		var status := str(martial_event.get("status", ""))
		if status.begins_with("SKIPPED_"):
			continue
		attempted += 1
		if status != "BLOCKED":
			return false
	return attempted > 0


static func _has_execution_facts(event: Dictionary) -> bool:
	if event.has("martial_events") and typeof(event.get("martial_events")) == TYPE_ARRAY and not (event.get("martial_events") as Array).is_empty():
		return true
	for key in ["actual_hp_hits", "clash_won", "evade_succeeded", "failure_reason"]:
		if event.has(key):
			return true
	return false
