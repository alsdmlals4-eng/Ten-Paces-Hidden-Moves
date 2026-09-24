extends RefCounted
## Read-only projection of resolver snapshots. It never awards damage or resources.
const Sequence = preload("res://src/ui/combat_motion_sequence.gd")
const Profile = preload("res://src/ui/combat_presentation_profile.gd")
const Presets = preload("res://src/ui/combat_motion_presets.gd")
const ACTORS := ["player", "enemy"]
const RESOURCES := ["health", "stamina", "internal", "momentum"]

static func build(result: Dictionary, before: Dictionary, placements: Array, definitions: Dictionary) -> Dictionary:
	var response: Dictionary = {}
	for tick in result.get("timing_results", []):
		if int(tick.get("timing", -1)) == 0:
			response = tick
	var previous: Dictionary = response.get("state", before)
	var bundle := {"index":int(result.get("bundle_index", 1)), "round":int(result.get("round_number", 1)), "steps":[], "before":before.duplicate(true), "response_delta":delta(before, previous)}
	for timing in range(int(result.get("bundle_start", 1)), int(result.get("bundle_end", 3)) + 1):
		var tick: Dictionary = {}
		for value in result.get("timing_results", []):
			if int(value.get("timing", -1)) == timing:
				tick = value
		var after: Dictionary = tick.get("state", previous)
		var events: Array = tick.get("events", []).duplicate(true)
		var actions := {}
		for actor in ACTORS:
			var action_event := {}
			var prepaid := false
			for event in events:
				if event.get("actor") == actor:
					action_event = event
			if action_event.is_empty():
				for event in response.get("events", []):
					if event.get("actor") == actor and int(event.get("timing", -1)) == timing:
						action_event = event
						prepaid = true
			var placement := {}
			if actor == "player":
				for entry in placements:
					if timing >= int(entry.get("anchor_index", 0)) and timing < int(entry.get("anchor_index", 0)) + int(entry.get("span", 1)):
						placement = entry
			actions[actor] = action(action_event, placement, timing)
			actions[actor]["response_prepaid"] = prepaid
		var cues: Array = []
		for event in Sequence.compile(events):
			cues.append(cue_for(event, definitions))
		if cues.is_empty():
			cues.append({"kind":"neutral", "actor":"player", "event":{}, "contact":false, "duration":0.65, "family":"neutral"})
		bundle.steps.append({"timing":timing,"actions":actions,"cues":cues,"before":previous.duplicate(true),"after":after.duplicate(true),"delta":delta(previous,after)})
		previous = after
	bundle["after"] = result.get("state", previous).duplicate(true)
	bundle["completion_delta"] = delta(previous, bundle.after)
	return bundle

static func action(event: Dictionary, placement: Dictionary, timing: int) -> Dictionary:
	var definition: Dictionary = placement.get("definition", {})
	if event.is_empty() and definition.is_empty():
		return {"label":"행동 없음", "stage":"empty", "event":{}}
	var stage := str(event.get("action_stage", "preparation" if timing < int(placement.get("anchor_index", timing)) + int(placement.get("span", 1)) - 1 else "execution"))
	var label := str(event.get("card_name", definition.get("name", "행동")))
	if int(event.get("action_slots", placement.get("span", 1))) > 1:
		label += " · 전조" if stage == "preparation" else " · 실행"
	return {"label":label, "stage":stage, "event":event.duplicate(true)}

static func cue_for(event: Dictionary, definitions: Dictionary) -> Dictionary:
	var id := str(event.get("card_id", ""))
	var definition: Dictionary = definitions.get(id, {})
	var preset: Dictionary = Presets.for_card(id)
	var cue := {"kind":"neutral", "actor":str(event.get("actor", "player")), "event":event.duplicate(true), "contact":false, "duration":0.7, "family":preset.get("family", "neutral"), "contact_type":preset.get("contact","none")}
	if definition.is_empty():
		return cue
	var profile := Profile.for_event(definition, event)
	var outcome := str(event.get("outcome", ""))
	var category := str(event.get("category", definition.get("category", "")))
	if event.get("action_stage") == "preparation" or outcome == "preparation":
		cue.kind = "preparation"
	elif outcome in ["interrupted", "martial_failed", "move_invalid", "insufficient_resource", "resource_insufficient", "insufficient"]:
		cue.kind = "failure"
	elif event.get("motion_cue") == "clash" or profile.kind == "clash":
		var opponent: Dictionary = Presets.for_card(str(event.get("opponent_card_id","")))
		var matched: bool = definitions.has(str(event.get("opponent_card_id","")))
		var blades: bool = preset.get("contact") == "metal" and opponent.get("contact") == "metal"
		cue.kind = "clash" if matched and blades else "pressure"
		cue.contact = matched and blades
		cue.duration = 2.75 if cue.contact else 1.0
	elif category == "move" or outcome == "move":
		cue.kind = "move"
		cue.duration = 0.95
	elif category == "attack" or event.get("motion_cue") == "strike" or profile.motion in ["attack", "ultimate"]:
		var defense := str(event.get("defense_outcome", ""))
		cue.kind = "miss" if outcome in ["miss_range", "miss_direction"] else "evade" if defense == "evade" else "block" if defense in ["block", "sure_hit_block"] else "attack"
		cue.contact = cue.kind == "block" or (cue.kind == "attack" and int(event.get("damage", 0)) > 0)
		cue.duration = 1.25 if event.get("motion_from_clash", false) else 1.05 + float(preset.get("duration",0.4))
	elif category in ["recovery", "strengthen", "observation", "response"]:
		cue.kind = "utility"
	return cue

static func public_slots(bundle: Dictionary, current: int) -> Array:
	var slots: Array = []
	for i in range(bundle.steps.size()):
		var step: Dictionary = bundle.steps[i]
		slots.append({"timing":step.timing, "player":step.actions.player.label, "enemy":step.actions.enemy.label if i <= current else "미공개", "status":"완료" if i < current else "진행" if i == current else "대기"})
	return slots

static func delta(before: Dictionary, after: Dictionary) -> Dictionary:
	var out := {}
	for actor in ACTORS:
		out[actor] = {}
		for key in RESOURCES:
			out[actor][key] = value(after,actor,key) - value(before,actor,key)
	return out

static func value(state: Dictionary, actor: String, key: String) -> int:
	var resource = state.get(actor, {}).get(key, [0,0])
	return int(resource[0]) if resource is Array and not resource.is_empty() else 0

static func changes(d: Dictionary, include_costs: bool = true) -> String:
	var parts := PackedStringArray()
	var names := {"health":"체력","stamina":"기력","internal":"내력","momentum":"기세"}
	for actor in ACTORS:
		for key in RESOURCES:
			if not include_costs and key in ["stamina","internal"]:
				continue
			var amount := int(d.get(actor, {}).get(key, 0))
			if amount != 0:
				parts.append("%s %s %+d" % ["내" if actor == "player" else "상대", names[key], amount])
	return " · ".join(parts) if not parts.is_empty() else "자원 변화 없음"
