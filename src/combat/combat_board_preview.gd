class_name CombatBoardPreview
extends Control

const CONTRACT_PATH := "res://data/combat/combat_board_poc.json"
const BACKGROUND_SCENE := preload("res://scenes/combat/battle_background.tscn")
const TOP_HUD_SCENE := preload("res://scenes/ui/top_combat_hud.tscn")
const TILE_SCENE := preload("res://scenes/combat/combat_board_tile.tscn")
const CHARACTER_SCENE := preload("res://scenes/combat/combat_character_placeholder.tscn")

const CANVAS_COLOR := Color("171411")
const GUIDE_COLOR := Color("b99254")

var contract: Dictionary = {}
var tiles: Array[CombatBoardTile] = []
var battle_background: BattleBackground
var top_hud: TopCombatHud
var player_character: CombatCharacterPlaceholder
var enemy_character: CombatCharacterPlaceholder

var _tile_layer: Control
var _character_layer: Control
var _anchor_line: ColorRect
var _layout_ready := false
var _tile_width := 0.0
var _tile_height := 0.0
var _tile_gap := 0.0

func _ready() -> void:
    contract = _load_contract()
    _build_structure()
    resized.connect(_layout_board)
    call_deferred("_layout_board")

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
    _tile_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _tile_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_tile_layer)

    _character_layer = Control.new()
    _character_layer.name = "CharacterLayer"
    _character_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _character_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_character_layer)

    top_hud = TOP_HUD_SCENE.instantiate() as TopCombatHud
    top_hud.name = "TopCombatHud"
    add_child(top_hud)

    var tile_count := int(contract.get("tile_count", 10))
    var anchor_ratio := float(contract.get("foot_anchor_y_ratio", 0.68))
    for index in range(1, tile_count + 1):
        var tile := TILE_SCENE.instantiate() as CombatBoardTile
        tile.name = "Tile%02d" % index
        tile.configure(index, anchor_ratio)
        _tile_layer.add_child(tile)
        tiles.append(tile)

    player_character = CHARACTER_SCENE.instantiate() as CombatCharacterPlaceholder
    player_character.name = "PlayerCharacter"
    _character_layer.add_child(player_character)

    enemy_character = CHARACTER_SCENE.instantiate() as CombatCharacterPlaceholder
    enemy_character.name = "EnemyCharacter"
    _character_layer.add_child(enemy_character)

    set_meta("step", 4)
    set_meta("background_component", "BattleBackground")
    set_meta("background_asset", "res://assets/backgrounds/step3_mountain_fortress.svg")
    set_meta("hud_component", "TopCombatHud")
    set_meta("hud_layout", "player_status|player_momentum|round|enemy_momentum|enemy_status")
    set_meta("lower_status_panels", false)
    set_meta("tile_count", tile_count)
    set_meta("player_start_tile", int(contract.get("player_start_tile", 3)))
    set_meta("enemy_start_tile", int(contract.get("enemy_start_tile", 8)))
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
    var desired_top := size.y * 0.48
    var minimum_top := 240.0
    var maximum_top := maxf(minimum_top, size.y - _tile_height - 92.0)
    var board_top := clampf(desired_top, minimum_top, maximum_top)

    for index in range(tile_count):
        var tile := tiles[index]
        tile.position = Vector2(board_left + float(index) * (_tile_width + _tile_gap), board_top)
        tile.size = Vector2(_tile_width, _tile_height)
        tile.custom_minimum_size = tile.size
        tile.set_occupied("")

    var player_tile := int(contract.get("player_start_tile", 3))
    var enemy_tile := int(contract.get("enemy_start_tile", 8))
    get_tile(player_tile).set_occupied("player")
    get_tile(enemy_tile).set_occupied("enemy")

    var height_ratio := float(contract.get("character_height_to_tile_width", 1.5))
    var body_width_ratio := float(contract.get("character_body_width_to_tile_width", 0.72))
    player_character.configure("player", 1, player_tile, _tile_width, height_ratio, body_width_ratio)
    enemy_character.configure("enemy", -1, enemy_tile, _tile_width, height_ratio, body_width_ratio)
    player_character.place_foot_at(get_tile_foot_anchor(player_tile))
    enemy_character.place_foot_at(get_tile_foot_anchor(enemy_tile))

    var anchor_y := get_tile_foot_anchor(player_tile).y
    _anchor_line.position = Vector2(board_left, anchor_y - 1.0)
    _anchor_line.size = Vector2(board_width, 2.0)

    _layout_ready = true
    set_meta("layout_ready", true)
    set_meta("tile_width", _tile_width)
    set_meta("tile_height", _tile_height)
    set_meta("tile_gap", _tile_gap)

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

func get_layout_snapshot() -> Dictionary:
    var hud_snapshot := top_hud.get_hud_snapshot() if is_instance_valid(top_hud) else {}
    return {
        "layout_ready": _layout_ready,
        "background_ready": is_instance_valid(battle_background) and battle_background.texture != null,
        "background_path": "res://assets/backgrounds/step3_mountain_fortress.svg",
        "hud_ready": is_instance_valid(top_hud),
        "hud_snapshot": hud_snapshot,
        "lower_status_panels": false,
        "tile_count": tiles.size(),
        "player_tile": int(contract.get("player_start_tile", 3)),
        "enemy_tile": int(contract.get("enemy_start_tile", 8)),
        "tile_width": _tile_width,
        "tile_height": _tile_height,
        "tile_gap": _tile_gap,
        "player_foot": get_character_foot_anchor("player"),
        "enemy_foot": get_character_foot_anchor("enemy"),
        "player_tile_anchor": get_tile_foot_anchor(int(contract.get("player_start_tile", 3))),
        "enemy_tile_anchor": get_tile_foot_anchor(int(contract.get("enemy_start_tile", 8))),
        "player_size": player_character.size if is_instance_valid(player_character) else Vector2.ZERO,
        "enemy_size": enemy_character.size if is_instance_valid(enemy_character) else Vector2.ZERO
    }
