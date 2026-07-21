class_name TopCombatHud
extends Control

const DATA_PATH := "res://data/combat/combat_hud_preview.json"
const STATUS_PANEL_SCENE := preload("res://scenes/ui/combatant_status_panel.tscn")
const MOMENTUM_SCENE := preload("res://scenes/ui/momentum_gauge.tscn")
const ROUND_SCENE := preload("res://scenes/ui/round_hud_panel.tscn")

var hud_data: Dictionary = {}

var player_panel: CombatantStatusPanel
var player_momentum: MomentumGauge
var round_panel: RoundHudPanel
var enemy_momentum: MomentumGauge
var enemy_panel: CombatantStatusPanel

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud_data = _load_data()
    _build()
    resized.connect(_layout)
    _layout()

func _load_data() -> Dictionary:
    if not FileAccess.file_exists(DATA_PATH):
        push_error("Combat HUD preview data was not found: %s" % DATA_PATH)
        return {}
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        push_error("Combat HUD preview data could not be opened: %s" % DATA_PATH)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Combat HUD preview data root must be a Dictionary.")
        return {}
    return parsed

func _build() -> void:
    player_panel = STATUS_PANEL_SCENE.instantiate() as CombatantStatusPanel
    player_panel.name = "PlayerStatusPanel"
    add_child(player_panel)

    player_momentum = MOMENTUM_SCENE.instantiate() as MomentumGauge
    player_momentum.name = "PlayerMomentumGauge"
    add_child(player_momentum)

    round_panel = ROUND_SCENE.instantiate() as RoundHudPanel
    round_panel.name = "RoundHudPanel"
    add_child(round_panel)

    enemy_momentum = MOMENTUM_SCENE.instantiate() as MomentumGauge
    enemy_momentum.name = "EnemyMomentumGauge"
    add_child(enemy_momentum)

    enemy_panel = STATUS_PANEL_SCENE.instantiate() as CombatantStatusPanel
    enemy_panel.name = "EnemyStatusPanel"
    add_child(enemy_panel)

    var segments := int(hud_data.get("momentum_segments", 5))
    var player_data: Dictionary = hud_data.get("player", {})
    var enemy_data: Dictionary = hud_data.get("enemy", {})
    player_panel.configure("player", player_data)
    enemy_panel.configure("enemy", enemy_data)
    player_momentum.configure("player", player_data.get("momentum", [0, segments]), segments)
    enemy_momentum.configure("enemy", enemy_data.get("momentum", [0, segments]), segments)
    round_panel.configure(hud_data.get("round", {}))

    set_meta("layout", "player_status|player_momentum|round|enemy_momentum|enemy_status")
    set_meta("momentum_segments", segments)
    set_meta("lower_status_panels", false)

func _layout() -> void:
    if not is_instance_valid(player_panel):
        return

    var gap := maxf(4.0, size.x * 0.004)
    var total_gap := gap * 4.0
    var usable_width := maxf(1.0, size.x - total_gap)
    var status_width := usable_width * 0.225
    var momentum_width := usable_width * 0.13
    var round_width := usable_width - status_width * 2.0 - momentum_width * 2.0
    var panel_height := maxf(116.0, size.y)

    var cursor := 0.0
    player_panel.position = Vector2(cursor, 0.0)
    player_panel.size = Vector2(status_width, panel_height)
    cursor += status_width + gap

    player_momentum.position = Vector2(cursor, 0.0)
    player_momentum.size = Vector2(momentum_width, panel_height)
    cursor += momentum_width + gap

    round_panel.position = Vector2(cursor, 0.0)
    round_panel.size = Vector2(round_width, panel_height)
    cursor += round_width + gap

    enemy_momentum.position = Vector2(cursor, 0.0)
    enemy_momentum.size = Vector2(momentum_width, panel_height)
    cursor += momentum_width + gap

    enemy_panel.position = Vector2(cursor, 0.0)
    enemy_panel.size = Vector2(status_width, panel_height)

func get_hud_snapshot() -> Dictionary:
    return {
        "player_panel": is_instance_valid(player_panel),
        "player_momentum": is_instance_valid(player_momentum),
        "round_panel": is_instance_valid(round_panel),
        "enemy_momentum": is_instance_valid(enemy_momentum),
        "enemy_panel": is_instance_valid(enemy_panel),
        "momentum_segments": int(get_meta("momentum_segments", 0)),
        "lower_status_panels": bool(get_meta("lower_status_panels", true)),
        "layout": str(get_meta("layout", ""))
    }