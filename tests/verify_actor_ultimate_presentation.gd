extends SceneTree

const ENGINE := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const PROFILE_PATH := "res://src/ui/combat_presentation_profile.gd"
const LEGACY_CASES := {
	"ultimate_ten_paces_wave": 0,
	"ultimate_cleave_peak": 1,
	"ultimate_void_sword_qi": 2,
}
const MANUAL_CASES := {
	"beggars_dragon_subduing_palm": [0, "impact"],
	"shaolin_arhat_vajra_art": [0, "impact"],
	"mount_hua_plum_blossom_sword": [1, "impact"],
	"hebei_peng_five_tigers_saber": [1, "impact"],
	"nangong_boundless_sky_sword": [2, "impact"],
	"sichuan_tang_hidden_weapons": [2, "impact"],
	"yang_family_spear": [2, "impact"],
	"mount_hua_purple_mist_art": [0, "self"],
	"wudang_taiji_sword": [0, "impact"],
	"xiaoyao_lingbo_footwork": [2, "impact"],
}

var failures: Array[String] = []
var profile_script: Script


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	profile_script = ResourceLoader.load(PROFILE_PATH, "Script", ResourceLoader.CACHE_MODE_IGNORE) as Script
	_expect(profile_script != null, "A pure combat presentation profile must exist.")
	if profile_script == null:
		_finish()
		return
	_verify_pure_profile_identity_and_priorities()
	_verify_transient_projection_deep_copy()
	await _verify_actual_routes_and_board_consumers()
	_finish()


func _verify_pure_profile_identity_and_priorities() -> void:
	var engine = ENGINE.new()
	var manual_ids := Array(engine.martial_registry.get_manual_ids())
	manual_ids.sort()
	_expect(manual_ids.size() == 10, "The actor profile fixture must enumerate the ten canonical manuals.")
	for manual_id_value in manual_ids:
		var manual_id := str(manual_id_value)
		_expect(MANUAL_CASES.has(manual_id), "Every canonical manual needs an explicit locked atlas mapping: " + manual_id)
		engine.configure_martial_loadouts([manual_id], {manual_id: 10}, [manual_id], {manual_id: 7})
		var star10_id := manual_id + "_star10"
		var star7_id := manual_id + "_star7"
		var star10: Dictionary = engine.get_actor_card_definition(star10_id, "player")
		var star7: Dictionary = engine.get_actor_card_definition(star7_id, "player")
		_expect(not star10.is_empty() and str(star10.get("source_kind", "")) == "ultimate", "Player mastery 10 owns canonical star10: " + manual_id)
		_expect(not star7.is_empty() and str(star7.get("source_kind", "")) != "ultimate", "Star7 remains a non-ultimate control: " + manual_id)
		_expect(engine.get_actor_card_definition(star10_id, "enemy").is_empty(), "Enemy mastery 7 cannot borrow player's star10: " + manual_id)

		var category := str(star10.get("category", ""))
		var nominal := {
			"type": "action_result", "actor": "player", "card_id": star10_id,
			"category": category, "outcome": "martial_completed", "damage": 0,
			"martial_events": [], "actual_hp_hits": 0,
		}
		if category == "attack" or category == "response":
			nominal["damage"] = 3
			nominal["actual_hp_hits"] = 1
			nominal["martial_events"] = [{"op": "ATTACK", "status": "HIT", "damage": 3}]
		var profile := _profile(star10, nominal)
		var profile_keys: Array = profile.keys()
		profile_keys.sort()
		_expect(profile_keys == ["anchor", "band", "is_ultimate", "kind", "motion"], "Profile exposes exactly the five approved transient keys: " + manual_id)
		var expected: Array = MANUAL_CASES[manual_id]
		_expect(bool(profile.get("is_ultimate", false)), "Canonical star10 identity is definition-owned: " + manual_id)
		_expect(int(profile.get("band", -1)) == int(expected[0]), "Canonical star10 selects its explicit atlas band: " + manual_id)
		_expect(str(profile.get("anchor", "")) == str(expected[1]), "Canonical star10 selects its explicit anchor: " + manual_id)
		_expect(str(profile.get("kind", "")) == "ultimate", "Synthetic eligible star10 fixture gets ultimate emphasis: " + manual_id)
		_expect(str(profile.get("motion", "")) == ("" if category == "recovery" else "ultimate"), "Synthetic eligible star10 fixture gets category-safe motion: " + manual_id)
		print("SYNTHETIC_PROFILE_FIXTURE manual=%s purpose=nominal_mapping profile=%s" % [manual_id, JSON.stringify(profile)])

		var star7_profile := _profile(star7, {
			"type": "action_result", "actor": "player", "card_id": star7_id,
			"category": str(star7.get("category", "")), "outcome": "hit", "damage": 2,
		})
		_expect(not bool(star7_profile.get("is_ultimate", true)), "Star7 does not gain ultimate identity: " + manual_id)

	for legacy_id in LEGACY_CASES:
		var definition: Dictionary = engine.get_actor_card_definition(str(legacy_id), "player")
		var profile := _profile(definition, {"type": "action_result", "actor": "player", "card_id": legacy_id, "category": "attack", "outcome": "hit", "damage": 5})
		_expect(bool(profile.get("is_ultimate", false)) and str(profile.get("kind", "")) == "ultimate", "Legacy canonical ultimate remains classified: " + str(legacy_id))
		_expect(int(profile.get("band", -1)) == int(LEGACY_CASES[legacy_id]), "Legacy ultimate retains atlas band: " + str(legacy_id))

	for fake_id in ["ultimate_forged_prefix", "forged_star10"]:
		var fake := _profile({}, {"type": "action_result", "actor": "player", "card_id": fake_id, "category": "attack", "outcome": "hit", "damage": 99})
		_expect(not bool(fake.get("is_ultimate", true)) and str(fake.get("kind", "")) == "attack", "An unowned fake ID can only use ordinary event facts: " + fake_id)

	var future_definition := {"id": "future_manual_star10", "source": "martial_manual", "source_kind": "ultimate", "category": "attack"}
	var future_profile := _profile(future_definition, {"type": "action_result", "actor": "player", "card_id": "future_manual_star10", "category": "attack", "outcome": "martial_completed", "damage": 4})
	_expect(bool(future_profile.get("is_ultimate", false)) and str(future_profile.get("kind", "")) == "ultimate", "A future canonical ultimate retains text emphasis.")
	_expect(int(future_profile.get("band", 0)) == -1, "An unknown canonical ultimate hides unmapped VFX.")

	engine.configure_martial_loadouts(["hebei_peng_five_tigers_saber"], {"hebei_peng_five_tigers_saber": 10})
	var ultimate: Dictionary = engine.get_actor_card_definition("hebei_peng_five_tigers_saber_star10", "player")
	var base := {"type": "action_result", "actor": "player", "card_id": ultimate.id, "category": "attack", "outcome": "martial_completed", "damage": 8, "actual_hp_hits": 1, "martial_events": [{"op": "ATTACK", "status": "HIT"}]}
	_expect(str(_profile(ultimate, _merged(base, {"type": "clash", "outcome": "clash_win"})).get("kind", "")) == "clash", "Outer clash outranks ultimate identity.")
	for failure_outcome in ["interrupted", "miss_direction", "miss_range", "move_invalid", "martial_failed"]:
		var failed := _profile(ultimate, _merged(base, {"outcome": failure_outcome, "failure_reason": "TEST_FAILURE"}))
		_expect(str(failed.get("kind", "")) == "outcome" and str(failed.get("motion", "x")) == "" and int(failed.get("band", 0)) == -1, "Failure suppresses ultimate success emphasis: " + failure_outcome)
	var target_evade := _profile(ultimate, _merged(base, {"defense_outcome": "evade", "damage": 0, "actual_hp_hits": 0}))
	_expect(str(target_evade.get("kind", "")) == "outcome" and str(target_evade.get("motion", "x")) == "", "Actual target evade outranks ultimate success.")
	var blocked := _profile(ultimate, _merged(base, {"damage": 0, "actual_hp_hits": 0, "martial_events": [{"op": "ATTACK", "status": "BLOCKED"}]}))
	_expect(str(blocked.get("kind", "")) == "outcome" and int(blocked.get("band", 0)) == -1, "All attempted attacks blocked with zero damage get outcome feedback.")
	var mixed := _profile(ultimate, _merged(base, {"damage": 3, "actual_hp_hits": 1, "martial_events": [{"op": "ATTACK", "status": "BLOCKED"}, {"op": "ATTACK", "status": "HIT"}]}))
	_expect(str(mixed.get("kind", "")) == "ultimate" and str(mixed.get("motion", "")) == "ultimate", "Mixed blocked and hit completion keeps actual ultimate impact.")
	var partial := _profile(ultimate, _merged(base, {"outcome": "martial_failed", "damage": 3, "actual_hp_hits": 1, "failure_reason": "UNKNOWN_EFFECT_OP"}))
	_expect(str(partial.get("kind", "")) == "outcome" and str(partial.get("motion", "x")) == "", "Failed partial hit retains facts without full success bloom.")
	var unmet := _profile(ultimate, _merged(base, {"damage": 0, "actual_hp_hits": 0, "martial_events": [{"op": "REQUIRE_EVADE_SUCCESS", "status": "FAILED"}, {"op": "ATTACK", "status": "SKIPPED_REQUIREMENT"}]}))
	_expect(str(unmet.get("kind", "")) == "outcome" and str(unmet.get("motion", "x")) == "", "Requirement-unmet synthetic profile cannot claim success.")
	print("SYNTHETIC_PROFILE_FIXTURE purpose=requirement_unmet profile=%s" % JSON.stringify(unmet))

	engine.configure_martial_loadouts(["wudang_taiji_sword"], {"wudang_taiji_sword": 10})
	var counter_definition: Dictionary = engine.get_actor_card_definition("wudang_taiji_sword_star10", "player")
	var own_evade_counter := _profile(counter_definition, {"type": "action_result", "actor": "player", "card_id": counter_definition.id, "category": "response", "outcome": "martial_completed", "evade_succeeded": true, "damage": 4, "actual_hp_hits": 1, "martial_events": [{"op": "REQUIRE_EVADE_SUCCESS", "status": "PASSED"}, {"op": "ATTACK", "status": "HIT"}]})
	_expect(str(own_evade_counter.get("kind", "")) == "ultimate" and str(own_evade_counter.get("motion", "")) == "ultimate" and str(own_evade_counter.get("anchor", "")) == "impact", "Own evade context does not masquerade as target evade.")
	print("SYNTHETIC_PROFILE_FIXTURE purpose=unreachable_current_counter_success profile=%s" % JSON.stringify(own_evade_counter))
	var internal_clash := _profile(counter_definition, {"type": "action_result", "actor": "player", "card_id": counter_definition.id, "category": "response", "outcome": "martial_completed", "damage": 1, "actual_hp_hits": 1, "martial_events": [{"op": "SPECIAL_CLASH", "status": "WIN"}, {"op": "ATTACK", "status": "HIT"}]})
	_expect(str(internal_clash.get("kind", "")) == "ultimate", "Internal SPECIAL_CLASH is not an outer clash.")


func _verify_transient_projection_deep_copy() -> void:
	var engine = ENGINE.new()
	var state := _state(engine)
	var lock_before: Dictionary = engine.export_enemy_lock()
	var resolved := [{
		"actor": "player", "card_id": "probe", "card_name": "Probe", "timing": 1,
		"action_stage": "execution", "outcome": "martial_failed", "failure_reason": "TEST_FAILURE",
		"martial_events": [{"op": "ATTACK", "status": "HIT", "detail": {"damage": 3}}],
		"actual_hp_hits": 1, "clash_won": false, "evade_succeeded": true,
	}]
	var resolved_before := resolved.duplicate(true)
	var events: Array = engine._build_presentation_events(state, state, resolved, [], false)
	_expect(events.size() == 1, "Projection emits one transient event for one resolved action.")
	if events.size() == 1:
		var event: Dictionary = events[0]
		for key in ["failure_reason", "martial_events", "actual_hp_hits", "clash_won", "evade_succeeded"]:
			_expect(event.has(key), "Projection forwards existing martial fact: " + key)
		if event.has("martial_events"):
			event.martial_events[0].detail.damage = 999
	_expect(resolved == resolved_before, "Projected nested martial facts cannot alias authoritative resolved actions.")
	var legacy: Array = engine._build_presentation_events(state, state, [{"actor": "player", "card_id": "basic_guard", "card_name": "막기", "timing": 1, "action_stage": "execution", "outcome": "response"}], [], false)
	if not legacy.is_empty():
		for key in ["failure_reason", "martial_events", "actual_hp_hits", "clash_won", "evade_succeeded"]:
			_expect(not (legacy[0] as Dictionary).has(key), "Legacy projection preserves absence instead of inventing martial fact: " + key)
	_expect(engine.export_enemy_lock() == lock_before and state == _state(engine), "Transient projection preserves state and enemy lock.")


func _verify_actual_routes_and_board_consumers() -> void:
	var actual_by_manual := {}
	for manual_id in MANUAL_CASES:
		var entry := _actual_bundle(str(manual_id))
		actual_by_manual[manual_id] = entry
		_expect(not entry.is_empty() and not (entry.get("event", {}) as Dictionary).is_empty(), "Actual bundle must emit the requested canonical event.")
		if not entry.is_empty():
			var event: Dictionary = entry.get("event", {})
			var definition: Dictionary = entry.get("definition", {})
			print("ACTUAL_PRESENTATION_ROUTE manual=%s outcome=%s facts=%s profile=%s" % [entry.get("manual", ""), event.get("outcome", ""), JSON.stringify(_fact_presence(event)), JSON.stringify(_profile(definition, event))])

	var actual_attack: Dictionary = actual_by_manual.get("hebei_peng_five_tigers_saber", {})
	var actual_recovery: Dictionary = actual_by_manual.get("mount_hua_purple_mist_art", {})
	var actual_wudang: Dictionary = actual_by_manual.get("wudang_taiji_sword", {})
	var actual_xiaoyao: Dictionary = actual_by_manual.get("xiaoyao_lingbo_footwork", {})
	for star in [3, 7]:
		var nonultimate_response := _actual_bundle("xiaoyao_lingbo_footwork", star)
		var response_event: Dictionary = nonultimate_response.get("event", {})
		var response_profile := _profile(nonultimate_response.get("definition", {}), response_event)
		_expect(str(response_event.get("outcome", "")) in ["response", "response_combo"], "Actual Xiaoyao star%d route remains the observed generic response fallback." % star)
		_expect(not bool(response_profile.get("is_ultimate", true)) and str(response_profile.get("kind", "")) == "outcome" and str(response_profile.get("motion", "x")) == "" and int(response_profile.get("band", 0)) == -1 and str(response_profile.get("anchor", "")) == "self", "Actor-owned non-ultimate martial response fallback is conservative at star%d." % star)
		print("ACTUAL_PRESENTATION_ROUTE manual=xiaoyao_lingbo_footwork star=%d outcome=%s facts=%s profile=%s" % [star, response_event.get("outcome", ""), JSON.stringify(_fact_presence(response_event)), JSON.stringify(response_profile)])
	var basic_guard: Dictionary = (actual_xiaoyao.get("engine")).get_actor_card_definition("basic_guard", "player")
	var basic_guard_profile := _profile(basic_guard, {"type": "action_result", "actor": "player", "card_id": "basic_guard", "category": "response", "outcome": "response"})
	_expect(str(basic_guard_profile.get("kind", "sentinel")) == "", "Ordinary basic guard keeps its existing unclassified presentation behavior.")
	if not actual_attack.is_empty():
		var attack_profile := _profile(actual_attack.definition, actual_attack.event)
		_expect(int(actual_attack.event.get("damage", 0)) > 0, "Actual Hebei star10 route must reach a real positive-damage attack fixture.")
		_expect(str(attack_profile.get("kind", "")) == "ultimate" and str(attack_profile.get("motion", "")) == "ultimate", "Actual reachable Hebei attack gets ultimate impact presentation.")
	if not actual_recovery.is_empty():
		var recovery_profile := _profile(actual_recovery.definition, actual_recovery.event)
		_expect(str(actual_recovery.event.get("outcome", "")) == "martial_completed", "Actual Purple Mist star10 reaches martial recovery completion.")
		_expect(str(recovery_profile.get("kind", "")) == "ultimate" and str(recovery_profile.get("motion", "x")) == "" and str(recovery_profile.get("anchor", "")) == "self", "Actual recovery uses self-anchored non-attack ultimate feedback.")
	for response_entry in [actual_wudang, actual_xiaoyao]:
		if response_entry.is_empty():
			continue
		var response_event: Dictionary = response_entry.event
		var response_profile := _profile(response_entry.definition, response_event)
		_expect(str(response_event.get("outcome", "")) in ["response", "response_combo"], "Actual current response route is honestly observed as generic defense fallback.")
		_expect(not response_event.has("martial_events") and not response_event.has("actual_hp_hits"), "Current generic response fallback has no invented martial execution facts.")
		_expect(str(response_profile.get("kind", "")) == "outcome" and str(response_profile.get("motion", "x")) == "" and int(response_profile.get("band", 0)) == -1, "Actual current response fallback has no counterattack success bloom.")

	var packed := load(BOARD_SCENE_PATH) as PackedScene
	var board := packed.instantiate() as CombatBoardPreview
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	root.add_child(board)
	for _index in range(4):
		await process_frame
	_expect(board.has_method("_presentation_profile_for_event"), "Board must resolve one actor-owned shared presentation profile.")
	if not board.has_method("_presentation_profile_for_event"):
		board.queue_free()
		await process_frame
		return

	var configured = actual_attack.get("engine")
	board.resolution_engine = configured
	board.combat_state = (actual_attack.get("state_before", {}) as Dictionary).duplicate(true)
	board._apply_combat_state_to_view()
	var event: Dictionary = (actual_attack.get("event", {}) as Dictionary).duplicate(true)
	var definitions_before: Dictionary = configured.get_actor_cards_by_id("player")
	var lock_before: Dictionary = configured.export_enemy_lock()
	var state_before: Dictionary = board.combat_state.duplicate(true)
	var profile: Dictionary = board.call("_presentation_profile_for_event", event)
	_expect(str(profile.get("kind", "")) == "ultimate", "Board uses actor-owned definition for actual Hebei event.")
	_expect(is_equal_approx(board._event_presentation_duration(event), 0.70), "Successful actor-owned ultimate retains 0.70 presentation duration.")
	_expect(is_equal_approx(board._feedback_windup_duration(event, 0.70), 0.294), "Successful actor-owned ultimate retains the existing windup proportion.")
	board._play_character_action_motion(event, 0.50)
	_expect(str(board.player_character.motion_state) == "ultimate", "Actual eligible ultimate selects ultimate actor motion.")
	board._show_presentation_feedback(event)
	_expect(str(board.get_meta("presentation_feedback_kind", "")) == "ultimate", "Board publishes ultimate feedback kind from shared profile.")
	_expect(board.presentation_vfx.visible and board.presentation_vfx.texture is AtlasTexture, "Mapped actual ultimate displays the existing atlas.")
	if board.presentation_vfx.texture is AtlasTexture:
		var atlas := board.presentation_vfx.texture as AtlasTexture
		_expect(is_equal_approx(atlas.region.position.y, atlas.atlas.get_size().y / 3.0), "Hebei star10 selects locked atlas band 1.")
	var impact_anchor := board.player_character.get_foot_anchor_global().lerp(board.enemy_character.get_foot_anchor_global(), 0.72)
	var displayed_anchor := board.presentation_vfx.position + Vector2(board.presentation_vfx.size.x * 0.5, board.presentation_vfx.size.y * 0.66)
	_expect(displayed_anchor.distance_to(impact_anchor) < 0.2, "Attack ultimate VFX remains impact anchored.")
	board._sound_muted = true
	board._play_event_sfx(event)
	_expect(str(board.get_meta("last_sfx_kind", "")) == "ultimate_release", "Successful eligible ultimate requests authored release cue even while muted.")
	_expect(not board.procedural_sfx_player.playing, "Muted profile check never starts audio playback.")

	var partial := event.duplicate(true)
	partial.outcome = "martial_failed"
	partial.failure_reason = "UNKNOWN_EFFECT_OP"
	partial.damage = 3
	partial.actual_hp_hits = 1
	board._play_event_sfx(partial)
	_expect(str(board.get_meta("last_sfx_kind", "")) == "sword_wind", "Failed partial damage uses actual hit sound instead of success release.")
	board.enemy_character.motion_state = "idle"
	board._play_character_impact_motion(partial, 0.20)
	_expect(str(board.enemy_character.motion_state) == "hit", "Failed partial damage retains actual defender hit motion.")
	_expect(str(board._presentation_summary_for_event(partial, "fallback")).contains("UNKNOWN_EFFECT_OP"), "Failed partial summary exposes the actual failure reason.")
	for priority_case in [
		[{"defense_outcome": "evade", "damage": 0}, "evade"],
		[{"defense_outcome": "block", "damage": 0}, "block"],
		[{"outcome": "interrupted", "damage": 0}, "interrupt"],
		[{"type": "clash", "outcome": "clash_win", "damage": 4}, "metal_clash"],
	]:
		var priority_event := _merged(event, priority_case[0])
		board._play_event_sfx(priority_event)
		_expect(str(board.get_meta("last_sfx_kind", "")) == str(priority_case[1]), "Actual defense/interruption/clash cue outranks ultimate release: " + str(priority_case[1]))

	var block_event := event.duplicate(true)
	block_event.damage = 0
	block_event.actual_hp_hits = 0
	block_event.martial_events = [{"op": "ATTACK", "status": "BLOCKED"}]
	_expect(str(board._presentation_summary_for_event(block_event, "fallback")).contains("막기"), "All-blocked martial completion reports block feedback.")
	board.enemy_character.motion_state = "idle"
	board._play_character_impact_motion(block_event, 0.20)
	_expect(str(board.enemy_character.motion_state) == "block", "All-blocked martial completion uses existing defender block motion.")
	var unmet_event := event.duplicate(true)
	unmet_event.damage = 0
	unmet_event.actual_hp_hits = 0
	unmet_event.martial_events = [{"op": "REQUIRE_EVADE_SUCCESS", "status": "FAILED"}, {"op": "ATTACK", "status": "SKIPPED_REQUIREMENT"}]
	_expect(str(board._presentation_summary_for_event(unmet_event, "fallback")).contains("조건 미충족"), "Requirement failure reports condition unmet without rollback claims.")

	var response_event: Dictionary = (actual_wudang.get("event", {}) as Dictionary).duplicate(true)
	board.resolution_engine = actual_wudang.get("engine")
	_expect(str(board._presentation_summary_for_event(response_event, "fallback")) == "방어 준비", "Actual generic response fallback reports defense preparation only.")
	board._show_presentation_feedback(response_event)
	_expect(not board.presentation_vfx.visible, "Generic response fallback suppresses success VFX.")

	var recovery_event: Dictionary = (actual_recovery.get("event", {}) as Dictionary).duplicate(true)
	board.resolution_engine = actual_recovery.get("engine")
	board._show_presentation_feedback(recovery_event)
	var self_anchor := board.player_character.get_foot_anchor_global()
	var recovery_anchor := board.presentation_vfx.position + Vector2(board.presentation_vfx.size.x * 0.5, board.presentation_vfx.size.y * 0.66)
	_expect(board.presentation_vfx.visible and recovery_anchor.distance_to(self_anchor) < 0.2, "Successful recovery VFX anchors at the actor's foot.")

	board.resolution_engine = configured
	var enemy_only: Dictionary = configured.get_actor_card_definition(str(event.get("card_id", "")), "enemy")
	_expect(enemy_only.is_empty(), "Actual board fixture retains opposite actor ownership boundary.")
	var forged := {"type": "action_result", "actor": "enemy", "card_id": event.card_id, "category": "attack", "outcome": "martial_completed", "damage": 9}
	var forged_profile: Dictionary = board.call("_presentation_profile_for_event", forged)
	_expect(not bool(forged_profile.get("is_ultimate", true)), "Board cannot borrow player-owned ultimate for an enemy event.")

	board._show_presentation_feedback(event)
	var saved_sheet = board._ultimate_vfx_sheet
	board._ultimate_vfx_sheet = null
	board._show_presentation_feedback(event)
	_expect(not board.presentation_vfx.visible, "Missing locked VFX texture fails hidden instead of leaving stale art visible.")
	board._ultimate_vfx_sheet = saved_sheet

	board._reduced_motion = true
	var sequence_before := int(board.player_character.get_motion_snapshot().get("sequence_id", 0))
	board._play_character_action_motion(event, 0.50)
	_expect(int(board.player_character.get_motion_snapshot().get("sequence_id", -1)) == sequence_before, "Reduced motion suppresses actor motion without changing state.")
	board._reduced_motion = false
	board._presentation_skip_requested = false
	board.call("_present_resolved_event_feedback", event)
	await process_frame
	board._skip_presentation()
	for _index in range(3):
		await process_frame
	_expect(bool(board.get_meta("presentation_skipped", false)) and not board.presentation_vfx.visible, "Skip ends the transient presentation promptly.")
	_expect(board.combat_state == state_before and configured.get_actor_cards_by_id("player") == definitions_before and configured.export_enemy_lock() == lock_before, "Motion, VFX, mute, reduced motion, and skip preserve state, definitions, and locks.")

	board.queue_free()
	await process_frame


func _actual_bundle(manual_id: String, star: int = 10) -> Dictionary:
	var engine = ENGINE.new()
	engine.configure_martial_loadouts([manual_id], {manual_id: star}, [], {})
	engine.rules["enemy_bundles"] = {}
	var definition: Dictionary = engine.get_actor_card_definition(manual_id + "_star" + str(star), "player")
	if definition.is_empty():
		failures.append("Missing actual star%d definition: %s" % [star, manual_id])
		return {}
	var state := _state(engine)
	state["ai_enabled"] = false
	var before := state.duplicate(true)
	var placement := {
		"card_id": definition.id, "definition": definition.duplicate(true), "anchor_index": 1,
		"span": maxi(1, int(definition.get("action_slots", 1))), "target_ready": true,
		"direction": 1, "target_tile": int((state.enemy as Dictionary).get("tile", 5)),
		"origin_tile": int((state.player as Dictionary).get("tile", 4)),
	}
	var result: Dictionary = engine.resolve_bundle([placement], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
	var event := _event_for_card(result.get("presentation_events", []), definition.id)
	return {"manual": manual_id, "engine": engine, "definition": definition, "state_before": before, "result": result, "event": event}


func _event_for_card(events: Array, card_id: String) -> Dictionary:
	for value in events:
		if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("card_id", "")) == card_id and str((value as Dictionary).get("action_stage", "execution")) == "execution":
			return (value as Dictionary).duplicate(true)
	return {}


func _state(engine) -> Dictionary:
	var actor := {
		"name": "검증자", "health": [100, 100], "stamina": [30, 30], "internal": [30, 30], "momentum": [5, 5],
		"stats": {"external": 10, "constitution": 10, "agility": 10, "internal_power": 10, "insight": 10},
	}
	return engine.make_initial_state({"player": actor, "enemy": actor}, 4, 5)


func _profile(definition: Dictionary, event: Dictionary) -> Dictionary:
	return profile_script.call("for_event", definition.duplicate(true), event.duplicate(true)) as Dictionary


func _merged(base: Dictionary, overrides: Dictionary) -> Dictionary:
	var result := base.duplicate(true)
	result.merge(overrides, true)
	return result


func _fact_presence(event: Dictionary) -> Dictionary:
	var result := {}
	for key in ["failure_reason", "martial_events", "actual_hp_hits", "clash_won", "evade_succeeded", "damage", "defense_outcome"]:
		if event.has(key):
			result[key] = event[key]
	return result


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("ACTOR_ULTIMATE_PRESENTATION_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("ACTOR_ULTIMATE_PRESENTATION_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
