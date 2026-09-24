extends SceneTree

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)

func run() -> void:
	var path := "res://src/ui/ink/ink_resolution_model.gd"
	if not ResourceLoader.exists(path):
		check(false, "Approved ink presentation has no runtime result adapter")
		finish()
		return
	var model = load(path)
	var fixture = JSON.parse_string(FileAccess.get_file_as_string("res://docs/visual-assets/candidates/TEN-INK-STYLES-20260924/clash-v2/bundle-fixtures.json"))
	var engine = load("res://src/combat/combat_resolution_engine.gd").new()
	for item in fixture.bundles:
		var original := JSON.stringify(item)
		var bundle: Dictionary = model.build(item.result, item.input.before, item.input.placements, engine.cards_by_id)
		check(bundle.steps.size() == [3,3,4][int(item.result.bundle_index)-1], "Current bundle retains all timing slots")
		var concealed: Array = model.public_slots(bundle, -1)
		for slot in concealed:
			check(slot.enemy == "미공개", "Future enemy action concealed")
		for index in range(bundle.steps.size()):
			var slots: Array = model.public_slots(bundle, index)
			for later in range(index + 1, slots.size()):
				check(slots[later].enemy == "미공개", "Only current or completed enemy actions revealed")
		check(JSON.stringify(item) == original, "Presentation does not mutate resolver input")
		if bundle.index == 1:
			check(bundle.steps[0].actions.player.stage == "preparation", "Heavy attack retains windup slot")
			check(bundle.steps[0].cues.all(func(c): return c.kind == "preparation"), "Windup does not invent attacks")
			check(bundle.steps[1].delta.enemy.health == -2, "Mirrored clash damage counted once")
			check(bundle.steps[1].cues.filter(func(c): return c.kind == "clash").size() == 1, "One mirrored clash choreography")
		if bundle.index == 2:
			check(bundle.response_delta.player.stamina == -1, "Guard cost paid at response phase")
			check(bundle.steps[2].delta.player.stamina == 0, "Guard does not pay again at execution")
		if bundle.index == 3:
			check(bundle.completion_delta.player.momentum == 0, "Capped momentum not invented")
	for outcome in ["miss_range", "miss_direction", "interrupted", "martial_failed"]:
		var cue: Dictionary = model.cue_for({"type":"action_result","actor":"player","card_id":"basic_heavy_attack","category":"attack","outcome":outcome,"damage":0}, engine.cards_by_id)
		check(not cue.contact, "Failed action has no contact: " + outcome)
	var unknown: Dictionary = model.cue_for({"type":"action_result","actor":"player","card_id":"unknown","damage":7}, engine.cards_by_id)
	check(unknown.kind == "neutral" and not unknown.contact, "Unknown card uses neutral feedback")
	var pressure: Dictionary = model.cue_for({"type":"clash","actor":"enemy","card_id":"basic_palm","outcome":"clash_win","opponent_card_id":"basic_heavy_attack","damage":0},engine.cards_by_id)
	check(pressure.kind == "pressure" and not pressure.contact,"Energy clash does not fabricate blade contact")
	var unpaired: Dictionary = model.cue_for({"type":"clash","actor":"player","card_id":"basic_heavy_attack","outcome":"clash_loss","damage":0},engine.cards_by_id)
	check(unpaired.kind == "pressure" and not unpaired.contact,"Unmatched clash does not invent an opposing blade")
	for outcome in ["resource_insufficient","insufficient"]:
		var failed: Dictionary = model.cue_for({"type":"action_result","actor":"player","card_id":"basic_heavy_attack","category":"attack","outcome":outcome,"damage":0},engine.cards_by_id)
		check(failed.kind == "failure" and not failed.contact,"Resource failure cannot fabricate an attack")
	finish()

func finish() -> void:
	for failure in failures:
		push_error(failure)
	print("INK_RESOLUTION_MODEL checks=%d failures=%d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)
