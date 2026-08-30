extends SceneTree

const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
const VIEWPORT_SIZE := Vector2(1440.0, 900.0)

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	if board == null:
		failures.append("Ink-paper presentation requires the combat board scene.")
		_finish()
		return
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = VIEWPORT_SIZE
	root.add_child(board)
	for _frame in range(6):
		await process_frame

	_expect(is_instance_valid(board.range_readout_label), "Combat must create a live player-facing range readout.")
	_expect(is_instance_valid(board.range_engagement_label), "Combat must create a live engaged-state label.")
	if is_instance_valid(board.range_readout_label):
		_expect(board.range_readout_label.text == "거리 2", "Initial player-facing range must be 거리 2.")
	if is_instance_valid(board.range_engagement_label):
		_expect(not board.range_engagement_label.visible, "Engaged-state label must be hidden while distance is non-zero.")

	if not board.tiles.is_empty():
		var first_tile := board.tiles[0]
		_expect(is_instance_valid(first_tile._number_label), "Board tile must retain an absolute-number label for contextual targeting.")
		if is_instance_valid(first_tile._number_label):
			_expect(not first_tile._number_label.visible, "Resting board tiles must not show persistent absolute numerals.")
		first_tile.set_interaction_state("movable")
		await process_frame
		if is_instance_valid(first_tile._number_label):
			_expect(first_tile._number_label.visible, "Targetable tiles must expose their contextual absolute numeral.")

	var player: Dictionary = board.combat_state.get("player", {})
	var enemy: Dictionary = board.combat_state.get("enemy", {})
	enemy["tile"] = int(player.get("tile", 4))
	board.combat_state["enemy"] = enemy
	board._apply_combat_state_to_view()
	for _frame in range(3):
		await process_frame
	if is_instance_valid(board.range_readout_label):
		_expect(board.range_readout_label.text == "거리 0", "A shared tile must display distance zero.")
	if is_instance_valid(board.range_engagement_label):
		_expect(board.range_engagement_label.visible and board.range_engagement_label.text == "[밀착]", "A shared tile must display the engaged state.")

	_expect(is_instance_valid(board.action_timing_panel), "Ink-paper composition must retain the live action plan strip.")
	_expect(is_instance_valid(board.combat_progress_button), "Ink-paper composition must retain the live execution control.")
	_expect(is_instance_valid(board.action_selection_dock) and board.action_selection_dock.visible, "Ink-paper composition must retain the actual visible action-selection dock.")
	if is_instance_valid(board.action_timing_panel):
		var timing_sequence: Array = board.action_timing_panel.get_timing_snapshot().get("timing_sequence", [])
		var normalized_timing := PackedInt32Array()
		for value in timing_sequence:
			normalized_timing.append(int(value))
		_expect(normalized_timing == PackedInt32Array([3, 3, 4]), "Plan strip must preserve the 3/3/4 sequence.")
	if is_instance_valid(board.combat_progress_button):
		_expect(not board.combat_progress_button.progress_enabled, "Execution must remain disabled before action placement.")
		var progress_style := board.combat_progress_button._button.get_theme_stylebox("normal") as StyleBoxFlat
		_expect(progress_style != null and progress_style.bg_color.is_equal_approx(Color("b99254")), "Execution control must render as a restrained gold paper CTA.")
	if is_instance_valid(board.action_timing_panel):
		_expect(board.action_timing_panel._title_label.get_theme_color("font_color").is_equal_approx(Color("211c17")), "Plan-strip title must render with readable charcoal ink on paper.")
	if is_instance_valid(board.action_selection_dock):
		var dock: ActionSelectionDock = board.action_selection_dock as ActionSelectionDock
		_expect(dock.get_dock_snapshot().get("active_source", "") == "basic", "Actual product dock must begin on the basic-action source.")
		_expect(int(dock.basic_panel.get_panel_snapshot().get("action_count", 0)) == 10, "Actual product dock must retain all ten registered basic actions.")
		var tab_style := dock.basic_tab.get_theme_stylebox("normal") as StyleBoxFlat
		_expect(tab_style != null and tab_style.bg_color.is_equal_approx(Color("d9ccb1")), "Selected basic source tab must render as a warm paper surface.")
		var action_style := dock.basic_panel.buttons[0].get_theme_stylebox("normal") as StyleBoxFlat
		_expect(action_style != null and action_style.bg_color.is_equal_approx(Color("d9ccb1")), "Basic action controls must render as warm paper cards.")
		dock.set_active_source("martial")
		await process_frame
		_expect(not dock.martial_panel.manual_buttons.is_empty(), "Martial source must retain its live manual controls.")
		if not dock.martial_panel.manual_buttons.is_empty():
			var manual_style := dock.martial_panel.manual_buttons[0].get_theme_stylebox("normal") as StyleBoxFlat
			_expect(manual_style != null and manual_style.bg_color.is_equal_approx(Color("d9ccb1")), "Martial manual controls must render as warm paper cards.")
		var momentum_player: Dictionary = board.combat_state.get("player", {})
		momentum_player["momentum"] = [5, 5]
		board.combat_state["player"] = momentum_player
		board._sync_action_selection_dock()
		dock.set_active_source("ultimate")
		await process_frame
		var available_ultimate: Button = null
		for button in dock.ultimate_panel.action_buttons:
			if not bool(button.get_meta("locked", true)):
				available_ultimate = button
				break
		_expect(is_instance_valid(available_ultimate), "Ultimate source must retain a live available action at full momentum.")
		if is_instance_valid(available_ultimate):
			var ultimate_style := available_ultimate.get_theme_stylebox("normal") as StyleBoxFlat
			_expect(ultimate_style != null and ultimate_style.bg_color.is_equal_approx(Color("d9ccb1")), "Ultimate action controls must render as warm paper cards.")

	board.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("INK_PAPER_COMBAT_PRESENTATION_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("INK_PAPER_COMBAT_PRESENTATION_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
