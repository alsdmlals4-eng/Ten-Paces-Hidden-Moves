class_name CombatProgressButton
extends Control

signal progress_requested(context: Dictionary)

const DATA_PATH := "res://data/combat/combat_progress_preview.json"
const PANEL := Color("d9ccb1")
const GOLD := Color("b99254")
const PAPER := Color("211c17")
const MUTED := Color("665b4b")

var progress_data: Dictionary = {}
var runtime_context: Dictionary = {}
var progress_enabled := false
var request_count := 0
var last_request_context: Dictionary = {}
var resolution_applied := false

var _caption_label: Label
var _button: Button
var _status_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    progress_data = _load_data()
    runtime_context = {
        "round_number": int(progress_data.get("round_number", 1)),
        "bundle_index": int(progress_data.get("bundle_index", 1)),
        "current_timing": int(progress_data.get("current_timing", 1)),
        "total_timings": int(progress_data.get("total_timings", 10)),
        "timing_sequence": [3, 3, 4]
    }
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
    _caption_label.visible = false
    _caption_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _caption_label.add_theme_font_size_override("font_size", 13)
    _caption_label.add_theme_color_override("font_color", PAPER)
    add_child(_caption_label)

    _button = Button.new()
    _button.name = "ProgressButton"
    _button.focus_mode = Control.FOCUS_ALL
    _apply_keyboard_focus_ring()
    _button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    _button.add_theme_font_size_override("font_size", 18)
    _button.add_theme_color_override("font_color", Color("211c17"))
    _button.add_theme_color_override("font_hover_color", Color("211c17"))
    _button.add_theme_color_override("font_pressed_color", Color("211c17"))
    _button.add_theme_color_override("font_disabled_color", Color("d2c6ab"))
    _apply_ink_paper_button_style()
    _button.pressed.connect(request_progress)
    add_child(_button)

    _status_label = Label.new()
    _status_label.name = "ProgressStatus"
    _status_label.visible = false
    _status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _status_label.add_theme_font_size_override("font_size", 12)
    _status_label.add_theme_color_override("font_color", MUTED)
    add_child(_status_label)

    set_meta("step", 8)
    set_meta("runtime_step", int(progress_data.get("runtime_step", 10)))
    set_meta("placement_gate_step", int(progress_data.get("placement_gate_step", 9)))
    set_meta("layout_role", "bottom_upper_right")
    set_meta("request_mode", str(progress_data.get("request_mode", "resolve_bundle")))
    set_meta("advances_state", bool(progress_data.get("advances_state", true)))
    set_meta("writes_combat_log", bool(progress_data.get("writes_combat_log", true)))
    set_meta("action_placement_required", bool(progress_data.get("action_placement_required", true)))
    set_meta("request_count", 0)

func _apply_keyboard_focus_ring() -> void:
    if _button == null:
        return
    var focus_style := StyleBoxFlat.new()
    focus_style.bg_color = Color(1.0, 1.0, 1.0, 0.08)
    focus_style.border_color = Color.WHITE
    focus_style.set_border_width_all(2)
    focus_style.set_corner_radius_all(4)
    focus_style.content_margin_left = 3.0
    focus_style.content_margin_right = 3.0
    focus_style.content_margin_top = 2.0
    focus_style.content_margin_bottom = 2.0
    _button.add_theme_stylebox_override("focus", focus_style)
    _button.set_meta("keyboard_focus_ring", true)

func _apply_ink_paper_button_style() -> void:
    if _button == null:
        return
    var normal := StyleBoxFlat.new()
    normal.bg_color = GOLD
    normal.border_color = Color("211c17")
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(4)
    normal.content_margin_left = 8.0
    normal.content_margin_right = 8.0
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("d3b878")
    hover.border_color = Color.WHITE
    hover.set_border_width_all(3)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("9d7640")
    pressed.border_color = Color("211c17")
    var disabled := normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color("665b4b")
    disabled.border_color = Color("4b4035")
    _button.add_theme_stylebox_override("normal", normal)
    _button.add_theme_stylebox_override("hover", hover)
    _button.add_theme_stylebox_override("pressed", pressed)
    _button.add_theme_stylebox_override("disabled", disabled)

func set_runtime_context(value: Dictionary) -> void:
    runtime_context = value.duplicate(true)
    resolution_applied = false
    set_meta("runtime_context", runtime_context.duplicate(true))
    _refresh()

func set_progress_enabled(value: bool) -> void:
    progress_enabled = value
    resolution_applied = false
    set_meta("enabled", progress_enabled)
    _refresh()

func mark_resolution_applied() -> void:
    resolution_applied = true
    progress_enabled = false
    set_meta("enabled", false)
    _refresh()

func request_progress() -> void:
    if not progress_enabled:
        return
    request_count += 1
    resolution_applied = false
    last_request_context = get_request_context()
    set_meta("request_count", request_count)
    _refresh()
    progress_requested.emit(last_request_context.duplicate(true))

func get_request_context() -> Dictionary:
    return {
        "round_number": int(runtime_context.get("round_number", progress_data.get("round_number", 1))),
        "bundle_index": int(runtime_context.get("bundle_index", progress_data.get("bundle_index", 1))),
        "current_timing": int(runtime_context.get("current_timing", progress_data.get("current_timing", 1))),
        "total_timings": int(runtime_context.get("total_timings", progress_data.get("total_timings", 10))),
        "timing_sequence": runtime_context.get("timing_sequence", [3, 3, 4]),
        "request_mode": str(progress_data.get("request_mode", "resolve_bundle")),
        "advances_state": bool(progress_data.get("advances_state", true))
    }

func _refresh() -> void:
    if _button == null:
        return
    _button.text = get_button_text()
    _button.tooltip_text = "%s · 현재 행동 묶음을 실행합니다." % _button.text
    _button.disabled = not progress_enabled
    if resolution_applied:
        _status_label.text = str(progress_data.get("requested_text", "판정 완료"))
        _status_label.add_theme_color_override("font_color", GOLD)
    elif progress_enabled:
        _status_label.text = str(progress_data.get("ready_text", "배치 완료"))
        _status_label.add_theme_color_override("font_color", GOLD)
    else:
        _status_label.text = str(progress_data.get("disabled_text", "행동 배치 필요"))
        _status_label.add_theme_color_override("font_color", MUTED)
    queue_redraw()

func get_button_text() -> String:
    var sequence: Array = runtime_context.get("timing_sequence", [3, 3, 4])
    var bundle_index := maxi(1, int(runtime_context.get("bundle_index", 1)))
    var sequence_index := clampi(bundle_index - 1, 0, maxi(0, sequence.size() - 1))
    var action_count := int(sequence[sequence_index]) if not sequence.is_empty() else 3
    return "%d수 실행" % action_count

func _layout() -> void:
    if _button == null:
        return
    var width := maxf(1.0, size.x)
    var height := maxf(1.0, size.y)
    _button.position = Vector2(4.0, 4.0)
    _button.size = Vector2(maxf(1.0, width - 8.0), maxf(1.0, height - 8.0))
    queue_redraw()

func get_progress_snapshot() -> Dictionary:
    return {
        "step": 8,
        "runtime_step": int(progress_data.get("runtime_step", 10)),
        "placement_gate_step": int(progress_data.get("placement_gate_step", 9)),
        "layout_role": "bottom_upper_right",
        "button_text": get_button_text(),
        "enabled": progress_enabled,
        "request_count": request_count,
        "request_mode": str(progress_data.get("request_mode", "resolve_bundle")),
        "advances_state": bool(progress_data.get("advances_state", true)),
        "writes_combat_log": bool(progress_data.get("writes_combat_log", true)),
        "action_placement_required": bool(progress_data.get("action_placement_required", true)),
        "resolution_applied": resolution_applied,
        "runtime_context": runtime_context.duplicate(true),
        "last_request_context": last_request_context.duplicate(true),
        "data_path": DATA_PATH
    }

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color("211c17"), false, 2.0)
    draw_rect(Rect2(Vector2(4.0, 4.0), size - Vector2(8.0, 8.0)), Color(GOLD, 0.72 if progress_enabled else 0.34), false, 1.0)
