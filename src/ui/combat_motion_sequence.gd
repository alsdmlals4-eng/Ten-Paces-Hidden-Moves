extends RefCounted
## Disposable choreography from resolved facts. Never writes domain/save state.

static func compile(events: Array) -> Array:
	var result: Array = []
	var consumed := {}
	for index in range(events.size()):
		if consumed.has(index) or not events[index] is Dictionary:
			continue
		var event: Dictionary = events[index].duplicate(true)
		if str(event.get("type", "")) not in ["action_result", "clash"]:
			continue
		if str(event.get("outcome", "")).begins_with("clash_"):
			for other_index in range(index + 1, events.size()):
				if consumed.has(other_index) or not events[other_index] is Dictionary:
					continue
				var other: Dictionary = events[other_index]
				if _is_mirror(event, other):
					consumed[other_index] = true
					if event.outcome == "clash_loss" or (event.outcome == "clash_draw" and event.actor == "enemy"):
						var previous := event
						event = other.duplicate(true)
						event["opponent_card_id"] = str(previous.get("card_id", ""))
					else:
						event["opponent_card_id"] = str(other.get("card_id", ""))
					break
			# An unmatched loss lacks the winner's card identity: report it, do not invent an attack.
			var follow := event.duplicate(true)
			var has_follow: bool = event.outcome == "clash_win" and (int(event.get("damage", 0)) > 0 or str(event.get("defense_outcome", "")) in ["evade", "block", "sure_hit_block"])
			event["damage"] = 0
			event["motion_continue"] = has_follow
			event["motion_cue"] = "clash"
			result.append(event)
			if has_follow:
				follow["type"] = "action_result"
				follow["outcome"] = "hit"
				follow["motion_cue"] = "strike"
				follow["motion_from_clash"] = true
				result.append(follow)
			continue
		var pieces: Array = []
		var skipped_range := false
		var remaining_damage := maxi(0, int(event.get("damage", 0)))
		if str(event.get("action_stage", "")) != "preparation":
			for fact_value in event.get("martial_events", []):
				if not fact_value is Dictionary:
					continue
				var fact: Dictionary = fact_value
				var op := str(fact.get("op", ""))
				var status := str(fact.get("status", ""))
				if op in ["ATTACK", "INDEPENDENT_ATTACK"] and status == "SKIPPED_OUT_OF_RANGE":
					skipped_range = true
				if op == "SPECIAL_CLASH" and status in ["WIN", "LOSS", "DRAW"]:
					var piece := _piece(event)
					piece.merge({"type":"clash", "outcome":"clash_" + status.to_lower(), "damage":0, "motion_cue":"clash"}, true)
					pieces.append(piece)
				elif op in ["ATTACK", "INDEPENDENT_ATTACK"] and status in ["HIT", "BLOCKED"]:
					var piece := _piece(event)
					# Effect facts report potential post-defense damage, even past HP zero.
					# The original aggregate owns actual HP loss; distribute, never mint damage.
					var actual_damage := mini(remaining_damage, maxi(0, int(fact.get("health_damage", 0)))) if status == "HIT" else 0
					remaining_damage -= actual_damage
					piece.merge({"type":"action_result", "outcome":"hit", "damage":actual_damage, "defense_outcome":"block" if status == "BLOCKED" else "hit", "motion_cue":"strike"}, true)
					piece["martial_events"] = [fact.duplicate(true)]
					pieces.append(piece)
		if pieces.is_empty():
			if skipped_range:
				event["outcome"] = "miss_range"
				event["damage"] = 0
			result.append(event)
		else:
			for i in range(pieces.size()):
				var has_next: bool = i + 1 < pieces.size() and pieces[i + 1].get("motion_cue") == "strike"
				pieces[i]["motion_continue"] = has_next
				if i > 0 and pieces[i - 1].get("motion_cue") == "clash":
					pieces[i]["motion_from_clash"] = true
			result.append_array(pieces)
			if str(event.get("outcome", "")) == "martial_failed":
				var failure := event.duplicate(true)
				failure["damage"] = 0
				result.append(failure)
	return result

static func _piece(event: Dictionary) -> Dictionary:
	var piece := event.duplicate(true)
	# Aggregate failures must not suppress earlier, factually executed hits.
	piece["martial_events"] = []
	piece.erase("failure_reason")
	piece.erase("defense_outcome")
	return piece

static func _is_mirror(a: Dictionary, b: Dictionary) -> bool:
	if str(a.get("actor", "")) not in ["player", "enemy"] or str(b.get("actor", "")) not in ["player", "enemy"] or a.actor == b.actor:
		return false
	if a.get("timing", -1) != b.get("timing", -2):
		return false
	var outcomes := [str(a.get("outcome", "")), str(b.get("outcome", ""))]
	if not ((outcomes.has("clash_win") and outcomes.has("clash_loss")) or outcomes == ["clash_draw", "clash_draw"]):
		return false
	return a.has("raw_damage") and b.has("raw_damage") and a.get("raw_damage") == b.get("clash_opponent_raw_damage") and b.get("raw_damage") == a.get("clash_opponent_raw_damage") and a.get("damage", 0) == b.get("damage", 0)
