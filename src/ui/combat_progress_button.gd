class_name CombatProgressButton
extends Control

signal progress_requested(context: Dictionary)

const DATA_PATH := "res://data/combat/combat_progress_preview.json"
const PANEL := Color(0.055, 0.045, 0.035, 0.98)
const GOLD := Color("c79a50")
const PAPER := Color("e0cfaa")
const MUTED := Color("9b8c76")

var progress_data: Dictionary = {}
var progress_enabled := false
var request_count := 0
var last_request_context: Dictionary = {}

var _caption_label: Label
var _button: Button
var _status_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    progress_data = _load_data()
    progress_enabled = bool(progress_data.get("default_enabled", false))
    _build()
    resized.connect(_layout)
    _refresh()
    _layout()

func _load_data() -> Dictionary:
    if not FileAccess.file_exists(DATA_PATH):
        push_error("STEP 8 progress button data was not found: %s" % DATA_PATH)
        return {}
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        push_error("STEP 8 progress button data could not be opened: %s" % DATA_PATH)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("STEP 8 progress button data root must be a Dictionary.")
        return {}
    return parsed

func _build() -> void:
    if _button != null:
        return

    _caption_label = Label.new()
    _caption_label.name = "ProgressCaption"
    _caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _caption_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _caption_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _caption_label.add_theme_font_size_override("font_size", 13)
    _caption_label.add_theme_color_override("font_color", PAPER)
    add_child(_caption_label)

    _button = Button.new()
    _button.name = "ProgressButton"
    _button.focus_mode = Control.FOCUS_NONE
    _button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    _button.add_theme_font_size_override("font_size", 24)
    _button.add_theme_color_override("font_color", Color("f2dfb0"))
    _button.add_theme_color_override("font_hover_color", Color.WHITE)
    _button.add_theme_color_override("font_pressed_color", Color("fff1c9"))
    _button.pressed.connect(request_progress)
    add_child(_button)

    _status_label = Label.new()
    _status_label.name = "ProgressStatus"
    _status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _status_label.add_theme_font_size_override("font_size", 12)
    _status_label.add_theme_color_override("font_color", MUTED)
    add_child(_status_label)

    set_meta("step", 8)
    set_meta("placement_gate_step", int(progress_data.get("placement_gate_step", 9)))
    set_meta("layout_role", "bottom_upper_right")
    set_meta("request_mode", str(progress_data.get("request_mode", "signal_only")))
    set_meta("advances_state", bool(progress_data.get("advances_state", false)))
    set_meta("writes_combat_log", bool(progress_data.get("writes_combat_log", true)))
    set_meta("action_placement_required", bool(progress_data.get("action_placement_required", true)))
    set_meta("request_count", 0)

func set_progress_enabled(value: bool) -> void:
    progress_enabled = value
    set_meta("enabled", progress_enabled)
    _refresh()

func request_progress() -> void:
    if not progress_enabled:
        return
    request_count += 1
    last_request_context = get_request_context()
    set_meta("request_count", request_count)
    _refresh()
    progress_requested.emit(last_request_context.duplicate(true))

func get_request_context() -> Dictionary:
    return {
        "round_number": int(progress_data.get("round_number", 1)),
        "bundle_index": int(progress_data.get("bundle_index", 1)),
        "current_timing": int(progress_data.get("current_timing", 1)),
        "total_timings": int(progress_data.get("total_timings", 10)),
        "request_mode": str(progress_data.get("request_mode", "signal_only")),
        "advances_state": bool(progress_data.get("advances_state", false))
    }

func _refresh() -> void:
    if _button == null:
        return
    _caption_label.text = str(progress_data.get("caption", "행동 묶음 확정"))
    _button.text = str(progress_data.get("button_text", "진행"))
    _button.disabled = not progress_enabled
    if request_count > 0:
        _status_label.text = str(progress_data.get("requested_text", "진행 요청됨"))
        _status_label.add_theme_color_override("font_color", GOLD)
    elif progress_enabled:
        _status_label.text = str(progress_data.get("ready_text", "배치 완료"))
        _status_label.add_theme_color_override("font_color", GOLD)
    else:
        _status_label.text = str(progress_data.get("disabled_text", "행동 배치 필요"))
        _status_label.add_theme_color_override("font_color", MUTED)
    queue_redraw()

func _layout() -> void:
    if _button == null:
        return
    var width := maxf(1.0, size.x)
    var height := maxf(1.0, size.y)
    _caption_label.position = Vector2(6.0, 7.0)
    _caption_label.size = Vector2(maxf(1.0, width - 12.0), 20.0)
    _button.position = Vector2(9.0, 31.0)
    _button.size = Vector2(maxf(1.0, width - 18.0), maxf(44.0, height - 67.0))
    _status_label.position = Vector2(6.0, maxf(78.0, height - 30.0))
    _status_label.size = Vector2(maxf(1.0, width - 12.0), 20.0)
    queue_redraw()

func get_progress_snapshot() -> Dictionary:
    return {
        "step": 8,
        "placement_gate_step": int(progress_data.get("placement_gate_step", 9)),
        "layout_role": "bottom_upper_right",
        "button_text": str(progress_data.get("button_text", "진행")),
        "enabled": progress_enabled,
        "request_count": request_count,
        "request_mode": str(progress_data.get("request_mode", "signal_only")),
        "advances_state": bool(progress_data.get("advances_state", false)),
        "writes_combat_log": bool(progress_data.get("writes_combat_log", true)),
        "action_placement_required": bool(progress_data.get("action_placement_required", true)),
        "last_request_context": last_request_context.duplicate(true),
        "data_path": DATA_PATH
    }

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(GOLD, 0.84 if progress_enabled else 0.42), false, 2.0)
    draw_line(Vector2(8.0, 28.0), Vector2(maxf(8.0, size.x - 8.0), 28.0), Color(GOLD, 0.30), 1.0)
