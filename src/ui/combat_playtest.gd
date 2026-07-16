extends Control

const CombatSimulator = preload("res://src/combat/combat_simulator.gd")

var simulator
var selected_actions: Array = []
var enemy_locked_pair: Array = []
var action_buttons := {}
var board_cells: Array = []
var phase_label: Label
var enemy_status_label: Label
var enemy_momentum_label: Label
var player_status_label: Label
var player_momentum_label: Label
var enemy_lock_label: Label
var slot_one_label: Label
var slot_two_label: Label
var lock_button: Button
var clear_button: Button
var log_view: RichTextLabel

func _ready() -> void:
	_build_ui()
	_start_battle()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)
	var title := Label.new()
	title.text = "십보강호 · 2수 전투 / 절초 기세 플레이테스트"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	root.add_child(title)
	var help := Label.new()
	help.text = "상대는 먼저 두 수를 잠급니다. 행동 두 개를 고른 뒤 잠금·동시 공개를 누르세요. 절초는 기세 6에서 예약합니다."
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(help)
	phase_label = Label.new()
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phase_label.add_theme_font_size_override("font_size", 18)
	root.add_child(phase_label)
	var enemy_panel := _make_status_panel("상대")
	enemy_status_label = enemy_panel.status
	enemy_momentum_label = enemy_panel.momentum
	root.add_child(enemy_panel.panel)
	var board := HBoxContainer.new()
	board.alignment = BoxContainer.ALIGNMENT_CENTER
	board.add_theme_constant_override("separation", 4)
	for cell_index in range(1, 11):
		var cell := Label.new()
		cell.custom_minimum_size = Vector2(76, 58)
		cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cell.text = str(cell_index)
		cell.add_theme_font_size_override("font_size", 18)
		board.add_child(cell)
		board_cells.append(cell)
	root.add_child(board)
	var player_panel := _make_status_panel("플레이어")
	player_status_label = player_panel.status
	player_momentum_label = player_panel.momentum
	root.add_child(player_panel.panel)
	enemy_lock_label = Label.new()
	enemy_lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(enemy_lock_label)
	var slots := HBoxContainer.new()
	slots.alignment = BoxContainer.ALIGNMENT_CENTER
	slots.add_theme_constant_override("separation", 12)
	slot_one_label = _slot("1수 · 미선택")
	slot_two_label = _slot("2수 · 미선택")
	slots.add_child(slot_one_label)
	slots.add_child(slot_two_label)
	root.add_child(slots)
	var actions := GridContainer.new()
	actions.columns = 4
	actions.add_theme_constant_override("h_separation", 8)
	actions.add_theme_constant_override("v_separation", 8)
	root.add_child(actions)
	for action_id in CombatSimulator.ACTION_ORDER:
		var action: Dictionary = CombatSimulator.ACTIONS[action_id]
		var button := Button.new()
		button.custom_minimum_size = Vector2(235, 54)
		button.text = "%s [행%d/기%d/내%d]" % [action.name, action.ap, action.stamina, action.internal]
		button.tooltip_text = String(action.description)
		button.pressed.connect(_on_action_pressed.bind(action_id))
		actions.add_child(button)
		action_buttons[action_id] = button
	var commands := HBoxContainer.new()
	commands.alignment = BoxContainer.ALIGNMENT_CENTER
	commands.add_theme_constant_override("separation", 12)
	clear_button = Button.new()
	clear_button.text = "선택 초기화"
	clear_button.pressed.connect(_on_clear_pressed)
	commands.add_child(clear_button)
	lock_button = Button.new()
	lock_button.text = "잠금 · 동시 공개"
	lock_button.custom_minimum_size = Vector2(260, 46)
	lock_button.pressed.connect(_on_lock_pressed)
	commands.add_child(lock_button)
	var restart := Button.new()
	restart.text = "전투 다시 시작"
	restart.pressed.connect(_start_battle)
	commands.add_child(restart)
	root.add_child(commands)
	log_view = RichTextLabel.new()
	log_view.custom_minimum_size = Vector2(0, 205)
	log_view.bbcode_enabled = true
	log_view.scroll_active = true
	root.add_child(log_view)

func _make_status_panel(title_text: String) -> Dictionary:
	var panel := PanelContainer.new()
	var box := VBoxContainer.new()
	panel.add_child(box)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var status := Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(status)
	var momentum := Label.new()
	momentum.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	momentum.add_theme_font_size_override("font_size", 17)
	box.add_child(momentum)
	return {"panel":panel, "status":status, "momentum":momentum}

func _slot(text_value: String) -> Label:
	var label := Label.new()
	label.custom_minimum_size = Vector2(340, 44)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = text_value
	return label

func _start_battle() -> void:
	simulator = CombatSimulator.new(20260716)
	selected_actions.clear()
	enemy_locked_pair = simulator.plan_ai_pair()
	log_view.clear()
	_log("[b]플레이테스트 시작[/b] · 시드 20260716")
	_log("상대는 플레이어 선택 전에 두 수를 잠갔습니다.")
	_refresh()

func _on_action_pressed(action_id: String) -> void:
	if simulator.battle_over or selected_actions.size() >= 2: return
	var check: Dictionary = simulator.can_queue_action("player", action_id)
	if not bool(check.ok):
		_log("[color=orange]선택 불가[/color] · %s" % check.reason)
		return
	selected_actions.append(action_id)
	_refresh()

func _on_clear_pressed() -> void:
	if simulator.battle_over: return
	selected_actions.clear()
	_refresh()

func _on_lock_pressed() -> void:
	if simulator.battle_over or selected_actions.size() != 2: return
	var result: Dictionary = simulator.resolve_pair(selected_actions, enemy_locked_pair)
	for event in result.events: _event_log(event)
	selected_actions.clear()
	if not simulator.battle_over:
		enemy_locked_pair = simulator.plan_ai_pair()
		_log("[color=gray]상대가 다음 두 수를 먼저 잠갔습니다.[/color]")
	_refresh()

func _event_log(event: Dictionary) -> void:
	var prefix := "[color=gold]판정[/color] · "
	if event.actor == "player": prefix = "[color=sky_blue]플레이어[/color] · "
	elif event.actor == "enemy": prefix = "[color=salmon]상대[/color] · "
	_log(prefix + String(event.message))

func _log(text_value: String) -> void:
	log_view.append_text(text_value + "\n")
	log_view.scroll_to_line(maxi(0, log_view.get_line_count() - 1))

func _refresh() -> void:
	var p: Dictionary = simulator.player
	var e: Dictionary = simulator.enemy
	phase_label.text = "라운드 %d · 묶음 %d/%d · 다음 타이밍 %d" % [simulator.round_index, simulator.pair_index, CombatSimulator.PAIRS_PER_ROUND, simulator.timing_index]
	if simulator.battle_over: phase_label.text = "전투 종료 · %s" % simulator.winner_text()
	enemy_status_label.text = _status_text(e)
	player_status_label.text = _status_text(p)
	enemy_momentum_label.text = _momentum_text(e)
	player_momentum_label.text = _momentum_text(p)
	for index in range(board_cells.size()):
		var number := index + 1
		var occupant := ""
		if int(p.position) == number: occupant += "P"
		if int(e.position) == number: occupant += "E"
		board_cells[index].text = "%d\n%s" % [number, occupant]
	slot_one_label.text = "1수 · %s" % _selected_name(0)
	slot_two_label.text = "2수 · %s" % _selected_name(1)
	lock_button.disabled = simulator.battle_over or selected_actions.size() != 2
	clear_button.disabled = simulator.battle_over or selected_actions.is_empty()
	enemy_lock_label.text = "전투 종료" if simulator.battle_over else "🔒 상대 2수 잠금 완료 · 내용은 동시 공개 전 비공개"
	for action_id in action_buttons:
		var check: Dictionary = simulator.can_queue_action("player", action_id)
		var button: Button = action_buttons[action_id]
		button.disabled = simulator.battle_over or selected_actions.size() >= 2 or not bool(check.ok)
		button.tooltip_text = String(CombatSimulator.ACTIONS[action_id].description)
		if not bool(check.ok): button.tooltip_text += "\n잠금 이유: " + String(check.reason)

func _status_text(actor: Dictionary) -> String:
	return "체력 %d/%d · 행동력 %d/%d · 기력 %d/%d · 내공 %d/%d · 위치 %d" % [actor.hp, actor.max_hp, actor.ap, actor.max_ap, actor.stamina, actor.max_stamina, actor.internal, actor.max_internal, actor.position]

func _selected_name(index: int) -> String:
	if index >= selected_actions.size(): return "미선택"
	return String(CombatSimulator.ACTIONS[selected_actions[index]].name)

func _momentum_text(actor: Dictionary) -> String:
	var cells := ""
	for index in range(CombatSimulator.MOMENTUM_MAX): cells += "■" if index < int(actor.momentum) else "□"
	return "절초 기세 [%s] %d/%d · %s" % [cells, actor.momentum, CombatSimulator.MOMENTUM_MAX, simulator.momentum_state(actor)]
