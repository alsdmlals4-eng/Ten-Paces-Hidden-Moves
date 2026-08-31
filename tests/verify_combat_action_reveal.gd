# 한 수씩 공개하는 대결 연출이 미래 행동을 누설하거나 판정 순서를 바꾸지 않는지 검증한다.
extends SceneTree

const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
const BASIC_ATLAS_PATH := "res://assets/ui/cards/basic_technique_ink_atlas_01_v1.png"

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

	_cleanup(board)

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
