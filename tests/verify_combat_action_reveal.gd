# 한 수씩 공개하는 대결 연출이 미래 행동을 누설하거나 판정 순서를 바꾸지 않는지 검증한다.
extends SceneTree

const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
const BASIC_ATLAS_PATH := "res://assets/ui/cards/basic_technique_ink_atlas_01_v1.png"
const ATTACK_CLASH_VFX_PATH := "res://assets/vfx/attack_clash_ink_gold_atlas_rgba_v1.png"

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	if board == null:
		failures.append("Action reveal verification requires the combat board.")
		_finish()
		return
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	root.add_child(board)
	for _frame in range(6):
		await process_frame

	var move := _card(board, "basic_move")
	var meditate := _card(board, "basic_meditate")
	if move.is_empty() or meditate.is_empty():
		failures.append("Reveal test requires move and meditate cards.")
		_cleanup(board)
		return
	_expect(board.action_timing_panel.place_card(move, 1), "Timing 1 move must place.")
	_expect(board._begin_targeting_for_anchor(1), "Timing 1 move must enter targeting.")
	board._on_board_tile_clicked(5)
	_expect(board.action_timing_panel.place_card(meditate, 2), "Timing 2 meditate must place.")
	_expect(board.action_timing_panel.place_card(meditate, 3), "Timing 3 meditate must place.")
	_expect(board.combat_progress_button.progress_enabled, "Completed first bundle must enable execution.")
	var resolution_before := int(board.get_layout_snapshot().get("resolution_count", 0))
	board.combat_progress_button.request_progress()
	await process_frame
	_expect(str(board.get_meta("presentation_state", "")) == "plan_locked", "Completed bundle must pause at visible plan lock before action reveal.")
	_expect(int(board.get_layout_snapshot().get("resolution_count", 0)) == resolution_before, "Plan lock must not apply combat resolution.")
	board.combat_progress_button.request_progress()

	var reveal_seen := false
	for _attempt in range(80):
		var overlay := board.get_node_or_null("CombatActionRevealOverlay") as Control
		if overlay != null and overlay is Control and overlay.visible and overlay.has_method("get_snapshot"):
			var snapshot: Dictionary = overlay.call("get_snapshot")
			if int(snapshot.get("timing", 0)) == 1:
				reveal_seen = true
				_expect(not bool(snapshot.get("future_action_visible", true)), "Timing 1 reveal must not expose later timing actions.")
				_expect(int(snapshot.get("event_count", 0)) > 0, "Timing 1 reveal must expose its authoritative events.")
				var player_panel := overlay.get_node_or_null("PlayerActionCard") as PanelContainer
				var enemy_panel := overlay.get_node_or_null("EnemyActionCard") as PanelContainer
				var player_column := player_panel.get_child(0) as VBoxContainer if player_panel != null and player_panel.get_child_count() > 0 else null
				var enemy_column := enemy_panel.get_child(0) as VBoxContainer if enemy_panel != null and enemy_panel.get_child_count() > 0 else null
				var player_art := player_column.get_node_or_null("Illustration") as TextureRect if player_column != null else null
				var enemy_art := enemy_column.get_node_or_null("Illustration") as TextureRect if enemy_column != null else null
				_expect(player_art != null and player_art.texture != null, "Current player action must render a card illustration in the reveal.")
				_expect(enemy_art != null and enemy_art.texture != null, "Current enemy action must render a card illustration in the reveal.")
				if player_art != null and player_art.texture is AtlasTexture:
					_expect((player_art.texture as AtlasTexture).atlas.resource_path == BASIC_ATLAS_PATH, "Current basic action reveal must consume the final-locked technique atlas.")
				var player: Dictionary = board.combat_state.get("player", {})
				_expect(int(player.get("tile", 0)) == 4, "Timing 1 state must not apply before its reveal resolves.")
				_expect(not board.action_selection_dock.visible, "Planning dock must be hidden while the duel reveal is active.")
				break
		await create_timer(0.05).timeout
	_expect(reveal_seen, "A committed bundle must show a timing-1 action reveal overlay.")
	_expect(int(board.get_layout_snapshot().get("resolution_count", 0)) == resolution_before + 1, "A reveal sequence must keep one authoritative resolver call per bundle.")
	board._skip_presentation()
	for _attempt in range(80):
		if str(board.get_meta("presentation_state", "")) == "review_ready":
			break
		await create_timer(0.05).timeout
	_expect(str(board.get_meta("presentation_state", "")) == "review_ready", "Skip must preserve ordered snapshot completion and reach review.")

	board.queue_free()
	await process_frame
	await _verify_public_feedback_surface()
	_finish()

func _verify_public_feedback_surface() -> void:
	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	root.add_child(board)
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	for _frame in range(4):
		await process_frame
	_expect(ResourceLoader.exists(ATTACK_CLASH_VFX_PATH), "Resolved normal attack and clash feedback must ship a final-locked runtime VFX atlas.")
	board._show_feedback_vfx({}, "attack")
	var attack_vfx := board.presentation_vfx.texture as AtlasTexture
	_expect(board.presentation_vfx.visible and attack_vfx != null, "Resolved normal attack must render the attack VFX band.")
	_expect(board.presentation_vfx.material is ShaderMaterial, "The final-locked opaque VFX source must receive a runtime matte so its light checker background never covers the duel.")
	if attack_vfx != null:
		_expect(attack_vfx.atlas.resource_path == ATTACK_CLASH_VFX_PATH, "Normal attack feedback must consume the final-locked attack/clash VFX atlas.")
		_expect(attack_vfx.region.position.y == 0.0, "Normal attack feedback must consume the upper VFX band.")
	board._show_feedback_vfx({}, "clash")
	var clash_vfx := board.presentation_vfx.texture as AtlasTexture
	_expect(board.presentation_vfx.visible and clash_vfx != null, "Resolved clash must render the clash VFX band.")
	if clash_vfx != null:
		_expect(clash_vfx.atlas.resource_path == ATTACK_CLASH_VFX_PATH, "Clash feedback must consume the final-locked attack/clash VFX atlas.")
		_expect(clash_vfx.region.position.y > 0.0, "Clash feedback must consume the lower VFX band.")
	await _verify_feedback_choreography(board)
	board._reduced_motion = true
	await board._present_timing_duel([{
		"type": "action_result",
		"card_id": "basic_quick_attack",
		"category": "attack",
		"card_name": "속공",
		"actor": "player",
		"damage": 6,
		"outcome": "hit"
	}], 1, "quick_attack")
	_expect(bool(board.get_meta("presentation_feedback_reduced_motion_safe", false)), "Reduced Motion must retain a static readable action result.")
	board.queue_free()
	await process_frame

func _verify_feedback_choreography(board: CombatBoardPreview) -> void:
	var attack_event := {
		"type": "action_result",
		"card_id": "basic_quick_attack",
		"category": "attack",
		"card_name": "속공",
		"actor": "player",
		"damage": 6,
		"outcome": "hit"
	}
	board.presentation_vfx.visible = false
	board.presentation_label.visible = false
	await board._present_timing_duel([attack_event], 1, "quick_attack")
	var attack_beats: Array = board.get_meta("presentation_feedback_visibility_history", [])
	_expect(_has_feedback_beat(attack_beats, "windup", false, false, "attack"), "Normal attack must begin with a hidden-feedback windup while the character advances.")
	_expect(_has_feedback_beat(attack_beats, "impact", true, true, "attack"), "Normal attack must reveal VFX and result copy together at impact.")
	_expect(not bool(board.get_meta("presentation_future_action_exposed", true)), "Normal-attack feedback must not expose a future hidden action.")
	_expect(str(board.get_meta("presentation_feedback_phase", "")) == "settled", "Normal attack must settle after its impact feedback.")
	_expect(not board.presentation_vfx.visible and not board.presentation_label.visible, "Normal attack must clear impact feedback before the next event.")

	var clash_event := {
		"type": "clash",
		"card_id": "basic_guard",
		"card_name": "막기",
		"actor": "enemy",
		"damage": 0,
		"outcome": "clash_draw"
	}
	await board._present_timing_duel([clash_event], 1, "clash")
	var clash_beats: Array = board.get_meta("presentation_feedback_visibility_history", [])
	_expect(_has_feedback_beat(clash_beats, "windup", false, false, "clash"), "Clash must show a hidden-feedback central tension phase before collision.")
	_expect(_has_feedback_beat(clash_beats, "impact", true, true, "clash"), "Clash impact must reveal collision VFX and result copy together.")
	_expect(str(board.get_meta("presentation_feedback_phase", "")) == "settled", "Clash must settle after its collision feedback.")
	_expect(not board.presentation_vfx.visible and not board.presentation_label.visible, "Clash must clear collision feedback before the next event.")

	var ultimate_event := {
		"type": "action_result",
		"card_id": "ultimate_ten_paces_wave",
		"category": "attack",
		"card_name": "십보 유파",
		"actor": "player",
		"damage": 8,
		"outcome": "hit"
	}
	await board._present_timing_duel([ultimate_event], 1, "quick_attack")
	var ultimate_beats: Array = board.get_meta("presentation_feedback_visibility_history", [])
	_expect(_has_feedback_beat(ultimate_beats, "windup", false, false, "ultimate"), "Ultimate must begin with a longer hidden-feedback windup.")
	_expect(_has_feedback_beat(ultimate_beats, "impact", true, true, "ultimate"), "Ultimate impact must reveal VFX and result copy together.")
	_expect(str(board.get_meta("presentation_feedback_phase", "")) == "settled", "Ultimate must settle after its impact feedback.")
	_expect(not board.presentation_vfx.visible and not board.presentation_label.visible, "Ultimate must clear impact feedback before the reveal closes.")

func _has_feedback_beat(beats: Array, phase: String, vfx_visible: bool, label_visible: bool, kind: String) -> bool:
	for value in beats:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var beat: Dictionary = value
		if str(beat.get("phase", "")) == phase and bool(beat.get("vfx_visible", false)) == vfx_visible and bool(beat.get("label_visible", false)) == label_visible and str(beat.get("feedback_kind", "")) == kind:
			return true
	return false

func _card(board: CombatBoardPreview, card_id: String) -> Dictionary:
	for value in board.basic_card_tray.cards:
		if str(value.definition.get("id", "")) == card_id:
			return value.definition.duplicate(true)
	return {}

func _cleanup(board: CombatBoardPreview) -> void:
	board.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("COMBAT_ACTION_REVEAL_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("COMBAT_ACTION_REVEAL_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
