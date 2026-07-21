class_name CombatBoardPreview
extends Control

const CONTRACT_PATH := "res://data/combat/combat_board_poc.json"
const BACKGROUND_SCENE := preload("res://scenes/combat/battle_background.tscn")
const TOP_HUD_SCENE := preload("res://scenes/ui/top_combat_hud.tscn")
const ACTION_TIMING_SCENE := preload("res://scenes/ui/action_timing_panel.tscn")
const PROGRESS_BUTTON_SCENE := preload("res://scenes/ui/combat_progress_button.tscn")
const BASIC_CARD_TRAY_SCENE := preload("res://scenes/ui/basic_card_tray.tscn")
const CARD_DETAIL_SCENE := preload("res://scenes/ui/card_detail_panel.tscn")
const COMBAT_LOG_SCENE := preload("res://scenes/ui/combat_log_panel.tscn")
const TILE_SCENE := preload("res://scenes/combat/combat_board_tile.tscn")
const CHARACTER_SCENE := preload("res://scenes/combat/combat_character_placeholder.tscn")

const CANVAS_COLOR := Color("171411")
const GUIDE_COLOR := Color("b99254")

var contract: Dictionary = {}
var tiles: Array[CombatBoardTile] = []
var battle_background: BattleBackground
var top_hud: TopCombatHud
var action_timing_panel: ActionTimingPanel
var combat_progress_button: CombatProgressButton
var basic_card_tray: BasicCardTray
var card_detail_panel: CardDetailPanel
var combat_log_panel: CombatLogPanel
var player_character: CombatCharacterPlaceholder
var enemy_character: CombatCharacterPlaceholder
var resolution_engine: CombatResolutionEngine
var combat_state: Dictionary = {}

var _tile_layer: Control
var _character_layer: Control
var _anchor_line: ColorRect
var _layout_ready := false
var _tile_width := 0.0
var _tile_height := 0.0
var _tile_gap := 0.0
var _board_top := 0.0
var _player_tile := 3
var _enemy_tile := 8
var _detail_pinned := false
var _pinned_card_id := ""
var _selected_action_definition: Dictionary = {}
var _progress_request_count := 0
var _resolution_count := 0
var _targeting_anchor := 0
var _targeting_mode := ""
var _targeting_origin_tile := 0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS
    contract = _load_contract()
    _player_tile = int(contract.get("player_start_tile", 3))
    _enemy_tile = int(contract.get("enemy_start_tile", 8))
    _build_structure()
    resolution_engine = CombatResolutionEngine.new()
    combat_state = resolution_engine.make_initial_state(top_hud.hud_data, _player_tile, _enemy_tile)
    _sync_runtime_context()
    _apply_combat_state_to_view()
    resized.connect(_layout_board)
    call_deferred("_layout_board")
    call_deferred("_sync_progress_availability")

func _load_contract() -> Dictionary:
    if not FileAccess.file_exists(CONTRACT_PATH):
        push_error("Combat board contract was not found: %s" % CONTRACT_PATH)
        return {}
    var file := FileAccess.open(CONTRACT_PATH, FileAccess.READ)
    if file == null:
        push_error("Combat board contract could not be opened: %s" % CONTRACT_PATH)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Combat board contract root must be a Dictionary.")
        return {}
    return parsed

func _build_structure() -> void:
    battle_background = BACKGROUND_SCENE.instantiate() as BattleBackground
    battle_background.name = "BattleBackground"
    add_child(battle_background)

    var canvas := ColorRect.new()
    canvas.name = "BackgroundReadabilityTint"
    canvas.color = Color(CANVAS_COLOR, 0.20)
    canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(canvas)

    _anchor_line = ColorRect.new()
    _anchor_line.name = "FootAnchorGuide"
    _anchor_line.color = Color(GUIDE_COLOR, 0.42)
    _anchor_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_anchor_line)

    _tile_layer = Control.new()
    _tile_layer.name = "TileLayer"
    _tile_layer.mouse_filter = Control.MOUSE_FILTER_PASS
    _tile_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_tile_layer)

    _character_layer = Control.new()
    _character_layer.name = "CharacterLayer"
    _character_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _character_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_character_layer)

    action_timing_panel = ACTION_TIMING_SCENE.instantiate() as ActionTimingPanel
    action_timing_panel.name = "ActionTimingPanel"
    action_timing_panel.slot_clicked.connect(_on_timing_slot_clicked)
    action_timing_panel.placement_changed.connect(_on_placement_changed)
    add_child(action_timing_panel)

    combat_progress_button = PROGRESS_BUTTON_SCENE.instantiate() as CombatProgressButton
    combat_progress_button.name = "CombatProgressButton"
    combat_progress_button.progress_requested.connect(_on_progress_requested)
    add_child(combat_progress_button)

    basic_card_tray = BASIC_CARD_TRAY_SCENE.instantiate() as BasicCardTray
    basic_card_tray.name = "BasicCardTray"
    basic_card_tray.card_hovered.connect(_on_card_hovered)
    basic_card_tray.card_unhovered.connect(_on_card_unhovered)
    basic_card_tray.action_card_selected.connect(_on_action_card_selected)
    add_child(basic_card_tray)

    top_hud = TOP_HUD_SCENE.instantiate() as TopCombatHud
    top_hud.name = "TopCombatHud"
    add_child(top_hud)

    card_detail_panel = CARD_DETAIL_SCENE.instantiate() as CardDetailPanel
    card_detail_panel.name = "CardDetailOverlay"
    card_detail_panel.visible = false
    add_child(card_detail_panel)

    combat_log_panel = COMBAT_LOG_SCENE.instantiate() as CombatLogPanel
    combat_log_panel.name = "CombatLogOverlay"
    combat_log_panel.layout_requested.connect(_layout_board)
    add_child(combat_log_panel)

    var tile_count := int(contract.get("tile_count", 10))
    var anchor_ratio := float(contract.get("foot_anchor_y_ratio", 0.68))
    for index in range(1, tile_count + 1):
        var tile := TILE_SCENE.instantiate() as CombatBoardTile
        tile.name = "Tile%02d" % index
        tile.configure(index, anchor_ratio)
        tile.tile_clicked.connect(_on_board_tile_clicked)
        _tile_layer.add_child(tile)
        tiles.append(tile)

    player_character = CHARACTER_SCENE.instantiate() as CombatCharacterPlaceholder
    player_character.name = "PlayerCharacter"
    _character_layer.add_child(player_character)

    enemy_character = CHARACTER_SCENE.instantiate() as CombatCharacterPlaceholder
    enemy_character.name = "EnemyCharacter"
    _character_layer.add_child(enemy_character)

    set_meta("step", 10)
    set_meta("targeting_patch", "10.5")
    set_meta("background_component", "BattleBackground")
    set_meta("background_asset", "res://assets/backgrounds/step3_mountain_fortress.svg")
    set_meta("hud_component", "TopCombatHud")
    set_meta("hud_layout", "player_status|player_momentum|round|enemy_momentum|enemy_status")
    set_meta("action_timing_component", "ActionTimingPanel")
    set_meta("action_timing_layout", "bottom_upper")
    set_meta("action_timing_sequence", "3|3|4")
    set_meta("progress_button_component", "CombatProgressButton")
    set_meta("progress_button_layout", "bottom_upper_right")
    set_meta("progress_request_mode", "resolve_bundle")
    set_meta("state_advancement_enabled", true)
    set_meta("resolution_order", "response|quick_attack|move|general")
    set_meta("basic_card_tray_component", "BasicCardTray")
    set_meta("basic_card_tray_layout", "bottom_lower")
    set_meta("basic_card_count", 8)
    set_meta("card_detail_component", "CardDetailPanel")
    set_meta("combat_log_component", "CombatLogPanel")
    set_meta("information_interactions_enabled", true)
    set_meta("action_placement_enabled", true)
    set_meta("targeting_enabled", true)
    set_meta("move_target_mode", "board_tile")
    set_meta("attack_target_mode", "left_or_right")
    set_meta("progress_requires_complete_bundle", true)
    set_meta("interruption_enabled", false)
    set_meta("lower_status_panels", false)
    set_meta("lower_skill_panel", true)
    set_meta("card_interactions_enabled", true)
    set_meta("tile_count", tile_count)
    set_meta("player_start_tile", _player_tile)
    set_meta("enemy_start_tile", _enemy_tile)
    set_meta("character_height_to_tile_width", float(contract.get("character_height_to_tile_width", 1.5)))

func _layout_board() -> void:
    if tiles.is_empty() or not is_instance_valid(player_character) or not is_instance_valid(enemy_character):
        return
    if size.x <= 0.0 or size.y <= 0.0:
        return

    if is_instance_valid(top_hud):
        var hud_margin := maxf(10.0, size.x * 0.012)
        top_hud.position = Vector2(hud_margin, 10.0)
        top_hud.size = Vector2(maxf(1.0, size.x - hud_margin * 2.0), 124.0)

    var lower_margin := maxf(10.0, size.x * 0.014)
    var lower_bottom := maxf(8.0, size.y * 0.012)
    var tray_height := clampf(size.y * 0.17, 126.0, 150.0)
    var timing_height := clampf(size.y * 0.145, 112.0, 130.0)
    var panel_gap := 8.0

    if is_instance_valid(basic_card_tray):
        basic_card_tray.position = Vector2(lower_margin, size.y - tray_height - lower_bottom)
        basic_card_tray.size = Vector2(maxf(1.0, size.x - lower_margin * 2.0), tray_height)

    var tray_top := basic_card_tray.position.y if is_instance_valid(basic_card_tray) else size.y - tray_height - lower_bottom
    var timing_row_y := tray_top - timing_height - panel_gap
    var timing_row_width := maxf(1.0, size.x - lower_margin * 2.0)
    var progress_width := clampf(size.x * 0.095, 120.0, 142.0)
    var progress_gap := 8.0
    var timing_width := maxf(1.0, timing_row_width - progress_width - progress_gap)

    if is_instance_valid(action_timing_panel):
        action_timing_panel.position = Vector2(lower_margin, timing_row_y)
        action_timing_panel.size = Vector2(timing_width, timing_height)

    if is_instance_valid(combat_progress_button):
        combat_progress_button.position = Vector2(lower_margin + timing_width + progress_gap, timing_row_y)
        combat_progress_button.size = Vector2(progress_width, timing_height)

    var overlay_top := 145.0
    var overlay_bottom := timing_row_y - 10.0
    var overlay_height := maxf(1.0, overlay_bottom - overlay_top)
    var overlay_margin := maxf(12.0, size.x * 0.014)

    if is_instance_valid(card_detail_panel):
        var detail_width := clampf(size.x * 0.275, 310.0, 360.0)
        card_detail_panel.position = Vector2(overlay_margin, overlay_top)
        card_detail_panel.size = Vector2(detail_width, minf(420.0, overlay_height))

    if is_instance_valid(combat_log_panel):
        var expanded_width := clampf(size.x * 0.28, 300.0, 360.0)
        var log_width := combat_log_panel.get_preferred_width(expanded_width)
        combat_log_panel.position = Vector2(size.x - overlay_margin - log_width, overlay_top)
        combat_log_panel.size = Vector2(log_width, overlay_height)

    var tile_count := tiles.size()
    var gap_ratio := float(contract.get("tile_gap_to_tile_width", 0.06))
    var horizontal_margin := maxf(40.0, size.x * 0.045)
    var available_width := maxf(1.0, size.x - horizontal_margin * 2.0)
    _tile_width = minf(132.0, available_width / (float(tile_count) + float(tile_count - 1) * gap_ratio))
    _tile_width = maxf(64.0, _tile_width)
    _tile_gap = _tile_width * gap_ratio
    _tile_height = _tile_width * float(contract.get("tile_height_to_tile_width", 1.35))

    var board_width := _tile_width * float(tile_count) + _tile_gap * float(tile_count - 1)
    var board_left := (size.x - board_width) * 0.5
    var desired_top := size.y * 0.43
    var maximum_top := maxf(150.0, timing_row_y - _tile_height - 48.0)
    var minimum_top := minf(220.0, maximum_top)
    _board_top = clampf(desired_top, minimum_top, maximum_top)

    for index in range(tile_count):
        var tile := tiles[index]
        tile.position = Vector2(board_left + float(index) * (_tile_width + _tile_gap), _board_top)
        tile.size = Vector2(_tile_width, _tile_height)
        tile.custom_minimum_size = tile.size
        tile.set_occupied("")

    get_tile(_player_tile).set_occupied("player")
    get_tile(_enemy_tile).set_occupied("enemy")

    var height_ratio := float(contract.get("character_height_to_tile_width", 1.5))
    var body_width_ratio := float(contract.get("character_body_width_to_tile_width", 0.72))
    player_character.configure("player", 1, _player_tile, _tile_width, height_ratio, body_width_ratio)
    enemy_character.configure("enemy", -1, _enemy_tile, _tile_width, height_ratio, body_width_ratio)
    player_character.place_foot_at(get_tile_foot_anchor(_player_tile))
    enemy_character.place_foot_at(get_tile_foot_anchor(_enemy_tile))

    var anchor_y := get_tile_foot_anchor(_player_tile).y
    _anchor_line.position = Vector2(board_left, anchor_y - 1.0)
    _anchor_line.size = Vector2(board_width, 2.0)

    _layout_ready = true
    set_meta("layout_ready", true)
    set_meta("tile_width", _tile_width)
    set_meta("tile_height", _tile_height)
    set_meta("tile_gap", _tile_gap)

func _on_card_hovered(definition: Dictionary) -> void:
    if _detail_pinned:
        return
    card_detail_panel.show_definition(definition, false)

func _on_card_unhovered(_card_id: String) -> void:
    if _detail_pinned:
        return
    card_detail_panel.clear_definition()

func _on_action_card_selected(definition: Dictionary) -> void:
    if _targeting_anchor > 0:
        basic_card_tray.clear_action_selection()
        if is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[대상 선택] 먼저 배치한 행동의 이동 칸 또는 공격 방향을 지정해야 합니다.", "system")
        return
    var card_id := str(definition.get("id", ""))
    var selected_id := str(_selected_action_definition.get("id", ""))
    if not selected_id.is_empty() and selected_id == card_id:
        _clear_action_selection()
        _clear_card_detail()
        return
    _selected_action_definition = definition.duplicate(true)
    basic_card_tray.set_selected_card(card_id)
    _detail_pinned = true
    _pinned_card_id = card_id
    basic_card_tray.set_pinned_card(card_id)
    card_detail_panel.show_definition(definition, true)

func _on_timing_slot_clicked(timing_index: int) -> void:
    if action_timing_panel.has_assignment_at(timing_index):
        var removed := action_timing_panel.remove_at(timing_index)
        if int(removed.get("anchor_index", 0)) == _targeting_anchor:
            _clear_targeting()
        if not removed.is_empty() and is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[배치 해제] %s · %s" % [str(removed.get("card_name", "")), _placement_timing_text(removed)], "system")
        _begin_next_pending_target()
        return
    if _targeting_anchor > 0:
        return
    if _selected_action_definition.is_empty():
        return
    var placed := action_timing_panel.place_card(_selected_action_definition, timing_index)
    if placed:
        var span := maxi(1, int(_selected_action_definition.get("action_slots", 1)))
        var placement := {"card_name": str(_selected_action_definition.get("name", "")), "indices": _make_timing_indices(timing_index, span)}
        if is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[배치] %s · %s" % [str(placement.get("card_name", "")), _placement_timing_text(placement)], "system")
        _clear_action_selection()
        _clear_card_detail()
        if not _begin_targeting_for_anchor(timing_index):
            _begin_next_pending_target()
    elif is_instance_valid(combat_log_panel):
        combat_log_panel.append_entry("[배치 불가] 연속된 빈 행동 슬롯이 부족합니다.", "system")

func _make_timing_indices(start_index: int, span: int) -> PackedInt32Array:
    var result := PackedInt32Array()
    for offset in range(span):
        result.append(start_index + offset)
    return result

func _placement_timing_text(placement: Dictionary) -> String:
    var indices: PackedInt32Array = placement.get("indices", PackedInt32Array())
    if indices.is_empty():
        return ""
    if indices.size() == 1:
        return "%d수" % int(indices[0])
    return "%d~%d수" % [int(indices[0]), int(indices[indices.size() - 1])]

func _begin_targeting_for_anchor(anchor_index: int) -> bool:
    var placement := action_timing_panel.get_placement(anchor_index)
    if placement.is_empty() or bool(placement.get("target_ready", true)):
        return false
    var mode := str(placement.get("targeting_mode", "none"))
    if mode == "none":
        return false

    _targeting_anchor = anchor_index
    _targeting_mode = mode
    _targeting_origin_tile = _projected_player_tile_before(anchor_index)
    _clear_tile_interactions()

    if mode == "move_tile":
        var definition: Dictionary = placement.get("definition", {})
        var movement_steps := maxi(1, int(definition.get("move_range", resolution_engine.rules.get("movement_steps", 1))))
        for direction in [-1, 1]:
            for step in range(1, movement_steps + 1):
                var target_index: int = _targeting_origin_tile + int(direction) * int(step)
                if target_index < 1 or target_index > tiles.size() or target_index == _enemy_tile:
                    continue
                get_tile(target_index).set_interaction_state("movable")
        if is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[이동 칸 선택] %s · 출발 %d번 · 최대 %d칸 내 녹색 칸을 선택하세요." % [str(placement.get("card_name", "이동")), _targeting_origin_tile, movement_steps], "system")
    elif mode == "attack_direction":
        var definition: Dictionary = placement.get("definition", {})
        var attack_range := maxi(1, int(str(definition.get("range_text", "1"))))
        for direction in [-1, 1]:
            for step in range(1, attack_range + 1):
                var target_index: int = _targeting_origin_tile + int(direction) * int(step)
                if target_index < 1 or target_index > tiles.size():
                    continue
                get_tile(target_index).set_interaction_state("attackable")
        if is_instance_valid(combat_log_panel):
            combat_log_panel.append_entry("[공격 방향 선택] %s · 붉은 칸으로 좌·우 방향을 지정하세요." % str(placement.get("card_name", "공격")), "system")
    else:
        _clear_targeting()
        return false

    set_meta("targeting_anchor", _targeting_anchor)
    set_meta("targeting_mode", _targeting_mode)
    set_meta("targeting_origin_tile", _targeting_origin_tile)
    return true

func _projected_player_tile_before(anchor_index: int) -> int:
    var projected := _player_tile
    var current := action_timing_panel.get_placement(anchor_index)
    var current_execution := anchor_index + maxi(1, int(current.get("span", 1))) - 1
    for placement_value in action_timing_panel.get_placement_list():
        var placement: Dictionary = placement_value
        var execution := int(placement.get("anchor_index", 0)) + maxi(1, int(placement.get("span", 1))) - 1
        if execution >= current_execution:
            continue
        if str(placement.get("targeting_mode", "none")) == "move_tile" and bool(placement.get("target_ready", false)):
            projected = int(placement.get("target_tile", projected))
    return clampi(projected, 1, tiles.size())

func _on_board_tile_clicked(tile_index: int) -> void:
    if _targeting_anchor <= 0:
        return
    var tile := get_tile(tile_index)
    if tile == null:
        return
    if _targeting_mode == "move_tile" and tile.interaction_state != "movable":
        return
    if _targeting_mode == "attack_direction" and tile.interaction_state != "attackable":
        return

    var direction := signi(tile_index - _targeting_origin_tile)
    if direction == 0:
        return
    var arrow := "→" if direction > 0 else "←"
    var target_text := "%s %d번" % [arrow, tile_index] if _targeting_mode == "move_tile" else "%s 공격" % arrow
    var placement := action_timing_panel.get_placement(_targeting_anchor)
    var target_data := {
        "direction": direction,
        "target_tile": tile_index,
        "origin_tile": _targeting_origin_tile,
        "target_text": target_text
    }
    if not action_timing_panel.set_placement_target(_targeting_anchor, target_data):
        return

    if is_instance_valid(combat_log_panel):
        if _targeting_mode == "move_tile":
            combat_log_panel.append_entry("[이동 칸] %s · %d번 → %d번" % [str(placement.get("card_name", "이동")), _targeting_origin_tile, tile_index], "system")
        else:
            combat_log_panel.append_entry("[공격 방향] %s · %s" % [str(placement.get("card_name", "공격")), "오른쪽" if direction > 0 else "왼쪽"], "system")
    _clear_targeting()
    _begin_next_pending_target()

func _begin_next_pending_target() -> void:
    if _targeting_anchor > 0:
        return
    var pending_anchor := action_timing_panel.get_pending_target_anchor()
    if pending_anchor > 0:
        _begin_targeting_for_anchor(pending_anchor)

func _clear_tile_interactions() -> void:
    for tile in tiles:
        tile.set_interaction_state("default")

func _clear_targeting() -> void:
    _targeting_anchor = 0
    _targeting_mode = ""
    _targeting_origin_tile = 0
    _clear_tile_interactions()
    set_meta("targeting_anchor", 0)
    set_meta("targeting_mode", "")
    set_meta("targeting_origin_tile", 0)

func _on_placement_changed(_snapshot: Dictionary) -> void:
    _sync_progress_availability()

func _sync_runtime_context() -> void:
    if not is_instance_valid(action_timing_panel) or not is_instance_valid(combat_progress_button):
        return
    combat_progress_button.set_runtime_context(action_timing_panel.get_runtime_context())

func _sync_progress_availability() -> void:
    if not is_instance_valid(action_timing_panel) or not is_instance_valid(combat_progress_button):
        return
    var complete := action_timing_panel.is_current_bundle_complete()
    combat_progress_button.set_progress_enabled(complete)
    set_meta("current_bundle_complete", complete)
    set_meta("targets_ready", action_timing_panel.are_current_bundle_targets_ready())

func _on_progress_requested(context: Dictionary) -> void:
    if not action_timing_panel.is_current_bundle_complete():
        return
    _clear_targeting()
    _progress_request_count += 1
    set_meta("progress_request_count", _progress_request_count)

    var result := resolution_engine.resolve_bundle(action_timing_panel.get_resolution_placements(), context, combat_state)
    combat_state = (result.get("state", {}) as Dictionary).duplicate(true)
    _resolution_count += 1
    set_meta("resolution_count", _resolution_count)
    _append_resolution_logs(result.get("logs", []))

    var advanced := action_timing_panel.advance_after_resolution()
    combat_state["round_number"] = int(advanced.get("round_number", combat_state.get("round_number", 1)))
    combat_state["bundle_index"] = int(advanced.get("current_bundle", combat_state.get("bundle_index", 1)))
    _clear_action_selection()
    _clear_card_detail()
    _sync_runtime_context()
    combat_progress_button.mark_resolution_applied()
    _apply_combat_state_to_view()
    if is_instance_valid(combat_log_panel):
        combat_log_panel.append_entry("[판정 완료] 다음 행동 묶음을 준비합니다.", "system")

func _append_resolution_logs(values) -> void:
    if not is_instance_valid(combat_log_panel) or typeof(values) != TYPE_ARRAY:
        return
    for value in values:
        combat_log_panel.append_entry(str(value), "resolution")

func _apply_combat_state_to_view() -> void:
    if combat_state.is_empty():
        return
    var player: Dictionary = combat_state.get("player", {})
    var enemy: Dictionary = combat_state.get("enemy", {})
    _player_tile = clampi(int(player.get("tile", _player_tile)), 1, tiles.size())
    _enemy_tile = clampi(int(enemy.get("tile", _enemy_tile)), 1, tiles.size())
    if is_instance_valid(top_hud):
        top_hud.apply_combat_state(combat_state, action_timing_panel.timing_data.get("timing_sequence", [3, 3, 4]))
    set_meta("player_tile", _player_tile)
    set_meta("enemy_tile", _enemy_tile)
    call_deferred("_layout_board")

func _clear_action_selection() -> void:
    _selected_action_definition.clear()
    if is_instance_valid(basic_card_tray):
        basic_card_tray.clear_action_selection()

func _clear_card_detail() -> void:
    _detail_pinned = false
    _pinned_card_id = ""
    if is_instance_valid(basic_card_tray):
        basic_card_tray.clear_card_focus()
    if is_instance_valid(card_detail_panel):
        card_detail_panel.clear_definition()

func _gui_input(event: InputEvent) -> void:
    if (_detail_pinned or not _selected_action_definition.is_empty()) and event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
            return
        var point := mouse_event.position
        if _control_contains_point(card_detail_panel, point):
            return
        if _control_contains_point(combat_log_panel, point):
            return
        if _control_contains_point(combat_progress_button, point):
            return
        if _control_contains_point(action_timing_panel, point):
            return
        if _control_contains_point(basic_card_tray, point):
            return
        _clear_action_selection()
        _clear_card_detail()

func _control_contains_point(control: Control, point: Vector2) -> bool:
    if not is_instance_valid(control) or not control.visible:
        return false
    return Rect2(control.position, control.size).has_point(point)

func get_tile(index: int) -> CombatBoardTile:
    if index < 1 or index > tiles.size():
        return null
    return tiles[index - 1]

func get_tile_foot_anchor(index: int) -> Vector2:
    var tile := get_tile(index)
    if tile == null:
        return Vector2.ZERO
    return tile.position + tile.get_foot_anchor_local()

func get_character_foot_anchor(role: String) -> Vector2:
    if role == "player" and is_instance_valid(player_character):
        return player_character.position + player_character.get_foot_anchor_local()
    if role == "enemy" and is_instance_valid(enemy_character):
        return enemy_character.position + enemy_character.get_foot_anchor_local()
    return Vector2.ZERO

func get_combat_state_snapshot() -> Dictionary:
    return combat_state.duplicate(true)

func get_layout_snapshot() -> Dictionary:
    var hud_snapshot := top_hud.get_hud_snapshot() if is_instance_valid(top_hud) else {}
    var timing_snapshot := action_timing_panel.get_timing_snapshot() if is_instance_valid(action_timing_panel) else {}
    var progress_snapshot := combat_progress_button.get_progress_snapshot() if is_instance_valid(combat_progress_button) else {}
    var tray_snapshot := basic_card_tray.get_tray_snapshot() if is_instance_valid(basic_card_tray) else {}
    var detail_snapshot := card_detail_panel.get_detail_snapshot() if is_instance_valid(card_detail_panel) else {}
    var log_snapshot := combat_log_panel.get_log_snapshot() if is_instance_valid(combat_log_panel) else {}
    return {
        "layout_ready": _layout_ready,
        "background_ready": is_instance_valid(battle_background) and battle_background.texture != null,
        "background_path": "res://assets/backgrounds/step3_mountain_fortress.svg",
        "hud_ready": is_instance_valid(top_hud),
        "hud_snapshot": hud_snapshot,
        "action_timing_ready": is_instance_valid(action_timing_panel),
        "action_timing_snapshot": timing_snapshot,
        "action_timing_top": action_timing_panel.position.y if is_instance_valid(action_timing_panel) else 0.0,
        "action_timing_bottom": action_timing_panel.position.y + action_timing_panel.size.y if is_instance_valid(action_timing_panel) else 0.0,
        "progress_button_ready": is_instance_valid(combat_progress_button),
        "progress_button_snapshot": progress_snapshot,
        "progress_button_left": combat_progress_button.position.x if is_instance_valid(combat_progress_button) else 0.0,
        "progress_button_right": combat_progress_button.position.x + combat_progress_button.size.x if is_instance_valid(combat_progress_button) else 0.0,
        "progress_button_top": combat_progress_button.position.y if is_instance_valid(combat_progress_button) else 0.0,
        "progress_button_bottom": combat_progress_button.position.y + combat_progress_button.size.y if is_instance_valid(combat_progress_button) else 0.0,
        "progress_request_count": _progress_request_count,
        "resolution_count": _resolution_count,
        "basic_card_tray_ready": is_instance_valid(basic_card_tray),
        "basic_card_tray_snapshot": tray_snapshot,
        "basic_card_tray_top": basic_card_tray.position.y if is_instance_valid(basic_card_tray) else 0.0,
        "basic_card_tray_bottom": basic_card_tray.position.y + basic_card_tray.size.y if is_instance_valid(basic_card_tray) else 0.0,
        "card_detail_ready": is_instance_valid(card_detail_panel),
        "card_detail_snapshot": detail_snapshot,
        "combat_log_ready": is_instance_valid(combat_log_panel),
        "combat_log_snapshot": log_snapshot,
        "selected_action_card_id": str(_selected_action_definition.get("id", "")),
        "current_bundle_complete": action_timing_panel.is_current_bundle_complete() if is_instance_valid(action_timing_panel) else false,
        "targets_ready": action_timing_panel.are_current_bundle_targets_ready() if is_instance_valid(action_timing_panel) else false,
        "targeting_enabled": true,
        "targeting_anchor": _targeting_anchor,
        "targeting_mode": _targeting_mode,
        "targeting_origin_tile": _targeting_origin_tile,
        "information_interactions_enabled": true,
        "action_placement_enabled": true,
        "state_advancement_enabled": true,
        "interruption_enabled": false,
        "combat_state": get_combat_state_snapshot(),
        "lower_status_panels": false,
        "lower_skill_panel": true,
        "tile_count": tiles.size(),
        "player_tile": _player_tile,
        "enemy_tile": _enemy_tile,
        "tile_width": _tile_width,
        "tile_height": _tile_height,
        "tile_gap": _tile_gap,
        "board_top": _board_top,
        "board_bottom": _board_top + _tile_height,
        "player_foot": get_character_foot_anchor("player"),
        "enemy_foot": get_character_foot_anchor("enemy"),
        "player_tile_anchor": get_tile_foot_anchor(_player_tile),
        "enemy_tile_anchor": get_tile_foot_anchor(_enemy_tile),
        "player_size": player_character.size if is_instance_valid(player_character) else Vector2.ZERO,
        "enemy_size": enemy_character.size if is_instance_valid(enemy_character) else Vector2.ZERO
    }
