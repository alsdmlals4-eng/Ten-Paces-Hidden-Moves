extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)

func _run() -> void:
	var path := "res://src/ui/combat_motion_sequence.gd"
	expect(ResourceLoader.exists(path), "Card choreography compiler must exist before paired clashes can be played once.")
	if not failures.is_empty():
		_finish()
		return
	var sequence = load(path)
	var first := {"type":"clash", "actor":"player", "timing":1, "card_id":"basic_heavy_attack", "outcome":"clash_win", "damage":3, "raw_damage":8, "clash_opponent_raw_damage":5, "defense_outcome":"hit"}
	var second := {"type":"clash", "actor":"enemy", "timing":1, "card_id":"basic_quick_attack", "outcome":"clash_loss", "damage":3, "raw_damage":5, "clash_opponent_raw_damage":8, "defense_outcome":"hit"}
	var original := [first.duplicate(true), second.duplicate(true)]
	var cues: Array = sequence.compile([first, second])
	expect(cues.size() == 2, "A mirrored clash is one contact plus one resolved follow-through, not two clashes.")
	if cues.size() == 2:
		expect(cues[0].outcome == "clash_win" and cues[1].actor == "player", "Winner owns the follow-through.")
		expect(cues[0].damage == 0 and cues[1].damage == 3, "Resolved damage is shown once, after the clash response.")
		expect(cues[0].get("motion_continue", false), "Clash winner holds the link into its technique.")
	expect([first, second] == original, "Compiling must not mutate domain facts.")
	var reverse: Array = sequence.compile([second, first])
	expect(reverse == cues, "Actor record ordering must not reverse the winner or duplicate impact.")
	var martial := {"type":"action_result", "actor":"player", "timing":2, "card_id":"nangong_boundless_sky_sword_star10", "outcome":"martial_completed", "damage":4, "martial_events":[{"op":"SPECIAL_CLASH", "status":"WIN"}, {"op":"ATTACK", "status":"HIT", "health_damage":4}, {"op":"ATTACK", "status":"SKIPPED_REQUIREMENT"}]}
	var parts: Array = sequence.compile([martial])
	expect(parts.size() == 2, "Special clash and executed hit are separate; skipped attacks never animate.")
	if parts.size() == 2:
		expect(parts[0].outcome == "clash_win" and parts[1].damage == 4, "Special clash precedes its factual hit.")
	var blocked := martial.duplicate(true)
	blocked.martial_events = [{"op":"ATTACK", "status":"BLOCKED", "health_damage":0}]
	var blocked_cues: Array = sequence.compile([blocked])
	expect(blocked_cues.size() == 1 and blocked_cues[0].defense_outcome == "block" and blocked_cues[0].damage == 0, "Blocked strike is not a damaging hit.")
	var draw := first.duplicate(true)
	draw.outcome = "clash_draw"
	draw.damage = 0
	expect(sequence.compile([draw]).size() == 1, "Draw never invents a winning attack.")
	var lethal := martial.duplicate(true)
	lethal.damage = 1
	lethal.martial_events = [{"op":"ATTACK","status":"HIT","health_damage":4},{"op":"ATTACK","status":"HIT","health_damage":4}]
	var lethal_cues: Array = sequence.compile([lethal])
	expect(lethal_cues.size()==2 and lethal_cues[0].damage==1 and lethal_cues[1].damage==0,"Overkill potential must never inflate actual HP-loss feedback.")
	var missed := martial.duplicate(true)
	missed.damage = 0
	missed.martial_events = [{"op":"ATTACK","status":"SKIPPED_OUT_OF_RANGE"}]
	var missed_cues: Array = sequence.compile([missed])
	expect(missed_cues.size()==1 and missed_cues[0].outcome=="miss_range","Unexecuted attack shows failure, never a success motion.")
	var presets = load("res://src/ui/combat_motion_presets.gd")
	var quick: Dictionary = presets.for_card("basic_quick_attack")
	var heavy: Dictionary = presets.for_card("basic_heavy_attack")
	expect(quick.duration < heavy.duration, "Quick and heavy attacks have distinct authored timing.")
	expect(quick.travel != heavy.travel, "Card presets own distinct visual travel.")
	expect(presets.for_card("basic_palm").contact == "energy", "Palm does not borrow sword contact.")
	expect(presets.for_card("unknown").pose == "neutral", "Unknown cards use an explicit neutral fallback.")
	quick.duration = 999
	expect(presets.for_card("basic_quick_attack").duration < 1.0, "Caller cannot mutate cached presets.")
	var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
	var ids: Array = engine.martial_registry.get_manual_ids()
	var mastery := {}
	for id in ids:
		mastery[id] = 10
	engine.configure_martial_loadouts(ids,mastery,ids,mastery)
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/presentation/combat_motion_presets.json"))
	for card_id in catalog.cards:
		expect(not engine.get_actor_card_definition(card_id,"player").is_empty(), "Preset points at actual card: "+card_id)
		var preset: Dictionary = presets.for_card(card_id)
		expect(preset.duration > 0.0 and preset.duration <= 1.05 and preset.hit_stop >= 0.0 and preset.hit_stop <= .08, "Bounded presentation timing: "+card_id)
	for manual_id in ids:
		for star in [3,7,10]:
			expect(catalog.cards.has(str(manual_id)+"_star"+str(star)),"Every martial technique is explicitly mapped.")
	_finish()

func _finish() -> void:
	for failure in failures:
		push_error(failure)
	print("CARD_MOTION_PRESETS checks=%d failures=%d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)
