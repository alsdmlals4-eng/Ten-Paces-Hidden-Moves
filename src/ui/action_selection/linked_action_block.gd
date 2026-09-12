class_name LinkedActionBlock
extends Control

signal block_activated(anchor_index: int)
signal block_drag_requested(anchor_index: int)
signal block_move_requested(anchor_index: int, direction: int)
signal block_remove_requested(anchor_index: int)

const PANEL := Color(0.10, 0.075, 0.045, 0.96)
const PAPER := Color("ead8b4")
const GOLD := Color("c79a50")
const MUTED := Color("a89982")

@onready var source_label: Label = %SourceLabel
@onready var action_label: Label = %ActionLabel
@onready var stages_label: Label = %StagesLabel

var placement: Dictionary = {}
var anchor_index := 0
var span := 1
var stages: Array[String] = []
var _drag_emitted := false
var _illustration: TextureRect

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    focus_mode = Control.FOCUS_ALL
    gui_input.connect(_on_gui_input)
    mouse_exited.connect(func(): _drag_emitted = false)
    for label in [source_label, action_label, stages_label]:
        label.reparent(self)
    $Content.queue_free()
    _illustration = TextureRect.new()
    _illustration.name = "PlanIllustration"
    _illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    _illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_illustration)
    move_child(_illustration, 0)
    for label in [source_label, action_label, stages_label]:
        label.add_theme_color_override("font_color", Color("211c17"))
        label.add_theme_font_size_override("font_size", 11)
        label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
        var backing := StyleBoxFlat.new()
        backing.bg_color = Color(0.89, 0.84, 0.73, 0.90)
        label.add_theme_stylebox_override("normal", backing)
    resized.connect(_layout_content)
    preload("res://src/ui/wuxia_ui_style.gd").ink_heading(source_label, 11)
    _apply_content()
    _layout_content()

func configure(value: Dictionary) -> void:
    placement = value.duplicate(true)
    anchor_index = int(placement.get("anchor_index", 0))
    span = maxi(1, int(placement.get("span", 1)))
    stages.clear()
    for index in range(span):
        stages.append("실행" if index == span - 1 else "전조")
    if is_node_ready():
        _apply_content()

func activate() -> void:
    if anchor_index <= 0:
        return
    block_activated.emit(anchor_index)

func request_drag() -> void:
    if anchor_index <= 0:
        return
    block_drag_requested.emit(anchor_index)

func request_move(direction: int) -> void:
    if anchor_index <= 0 or direction == 0:
        return
    block_move_requested.emit(anchor_index, signi(direction))

func request_remove() -> void:
    if anchor_index <= 0:
        return
    block_remove_requested.emit(anchor_index)

func get_block_snapshot() -> Dictionary:
    var definition: Dictionary = placement.get("definition", {})
    return {
        "anchor_index": anchor_index,
        "span": span,
        "indices": placement.get("indices", PackedInt32Array()),
        "action_id": str(definition.get("id", placement.get("card_id", ""))),
        "action_name": str(definition.get("name", placement.get("card_name", ""))),
        "source_kind": str(definition.get("source_kind", definition.get("source", ""))),
        "source_label": str(definition.get("source_label", "")),
        "telegraph_count": maxi(0, span - 1),
        "execution_count": 1,
        "stages": stages.duplicate(),
        "target_ready": bool(placement.get("target_ready", true)),
        "resource_ready": bool(placement.get("resource_ready", true))
    }

func _apply_content() -> void:
    if not is_node_ready():
        return
    var snapshot := get_block_snapshot()
    source_label.text = "%d수" % span
    action_label.text = str(snapshot.get("action_name", ""))
    var stage_parts := PackedStringArray()
    for stage in stages:
        stage_parts.append("[%s]" % stage)
    stages_label.text = "  →  ".join(stage_parts)
    var status_parts := PackedStringArray()
    if not bool(snapshot.get("resource_ready", true)):
        status_parts.append("자원 부족")
    if not bool(snapshot.get("target_ready", true)):
        status_parts.append("대상 선택")
    if not status_parts.is_empty():
        stages_label.text = " · ".join(status_parts)
    var definition: Dictionary = placement.get("definition", {})
    var spec: Dictionary = definition.get("illustration", {})
    var atlas_path := str(spec.get("atlas", ""))
    var region: Array = spec.get("region", [])
    _illustration.texture = null
    if not atlas_path.is_empty() and region.size() == 4 and ResourceLoader.exists(atlas_path):
        var atlas := AtlasTexture.new()
        atlas.atlas = load(atlas_path) as Texture2D
        atlas.region = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
        _illustration.texture = atlas
    tooltip_text = "%s · %s · 좌우 이동 / Esc 제거" % [
        str(snapshot.get("action_name", "행동")),
        " · ".join(status_parts) if not status_parts.is_empty() else stages_label.text
    ]
    accessibility_name = "%s, %s, %d수, %s, 좌우 키로 이동, 취소 키로 제거" % [
        str(snapshot.get("action_name", "행동")),
        str(snapshot.get("source_label", "출처 없음")),
        span,
        "에서 ".join(stages)
    ]
    set_meta("anchor_index", anchor_index)
    set_meta("span", span)
    set_meta("stages", stages.duplicate())
    queue_redraw()

func _layout_content() -> void:
    if not is_instance_valid(_illustration):
        return
    _illustration.position = Vector2(4, 2)
    _illustration.size = (size - Vector2(8, 4)).max(Vector2.ONE)
    action_label.position = Vector2(4, 1)
    action_label.size = Vector2(maxf(1.0, size.x - 40.0), 16)
    action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    source_label.position = Vector2(maxf(4.0, size.x - 34.0), 1)
    source_label.size = Vector2(30, 16)
    stages_label.position = Vector2(4, maxf(17.0, size.y - 17.0))
    stages_label.size = Vector2(maxf(1.0, size.x - 8.0), 16)

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key_event := event as InputEventKey
        if not key_event.pressed or key_event.echo:
            return
        if key_event.is_action_pressed("ui_accept"):
            activate()
            accept_event()
            return
        if key_event.is_action_pressed("ui_left"):
            request_move(-1)
            accept_event()
            return
        if key_event.is_action_pressed("ui_right"):
            request_move(1)
            accept_event()
            return
        if key_event.is_action_pressed("ui_cancel"):
            request_remove()
            accept_event()
            return
    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index == MOUSE_BUTTON_LEFT:
            _drag_emitted = false
            if mouse_event.pressed:
                activate()
                accept_event()
            return
    if event is InputEventMouseMotion:
        var motion := event as InputEventMouseMotion
        var left_pressed := (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0
        if left_pressed and not _drag_emitted and motion.relative.length() >= 2.0:
            _drag_emitted = true
            request_drag()
            accept_event()

func _draw() -> void:
    var snapshot := get_block_snapshot()
    var border := GOLD
    if not bool(snapshot.get("resource_ready", true)):
        border = Color("b85a4a")
    elif not bool(snapshot.get("target_ready", true)):
        border = Color("e6a84f")
    draw_style_box(preload("res://src/ui/wuxia_ui_style.gd").paper_surface(), Rect2(Vector2.ZERO, size))
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), border, false, 2.0)
    if has_focus():
        draw_rect(Rect2(Vector2(4.0, 4.0), size - Vector2(8.0, 8.0)), Color.WHITE, false, 2.0)
