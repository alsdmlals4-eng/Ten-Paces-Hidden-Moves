class_name CombatLogPanel
extends Control

signal layout_requested

const DATA_PATH := "res://data/combat/combat_log_preview.json"
const PANEL := Color(0.040, 0.034, 0.028, 0.97)
const GOLD := Color("c79a50")
const PAPER := Color("e0cfaa")
const MUTED := Color("9b8c76")

var log_data: Dictionary = {}
var entries: Array = []
var collapsed := true

var _toggle_button: Button
var _content: RichTextLabel

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    log_data = _load_data()
    entries = (log_data.get("entries", []) as Array).duplicate(true)
    collapsed = bool(log_data.get("default_collapsed", true))
    _build()
    resized.connect(_layout)
    _refresh()
    _layout()

func _load_data() -> Dictionary:
    if not FileAccess.file_exists(DATA_PATH):
        push_error("STEP 7 combat log preview data was not found: %s" % DATA_PATH)
        return {}
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        push_error("STEP 7 combat log preview data could not be opened: %s" % DATA_PATH)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("STEP 7 combat log preview data root must be a Dictionary.")
        return {}
    return parsed

func _build() -> void:
    if _toggle_button != null:
        return

    _toggle_button = Button.new()
    _toggle_button.name = "CombatLogToggle"
    _toggle_button.focus_mode = Control.FOCUS_NONE
    _toggle_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    _toggle_button.add_theme_font_size_override("font_size", 14)
    _toggle_button.add_theme_color_override("font_color", PAPER)
    _toggle_button.add_theme_color_override("font_hover_color", Color.WHITE)
    _toggle_button.pressed.connect(toggle_collapsed)
    add_child(_toggle_button)

    _content = RichTextLabel.new()
    _content.name = "CombatLogContent"
    _content.fit_content = false
    _content.scroll_active = true
    _content.selection_enabled = false
    _content.mouse_filter = Control.MOUSE_FILTER_STOP
    _content.add_theme_font_size_override("normal_font_size", 14)
    _content.add_theme_color_override("default_color", PAPER)
    add_child(_content)

    set_meta("step", 7)
    set_meta("layout_role", "right_overlay")
    set_meta("collapsible", true)
    set_meta("default_collapsed", bool(log_data.get("default_collapsed", true)))
    set_meta("output_interface", true)
    set_meta("entry_count", entries.size())

func toggle_collapsed() -> void:
    set_collapsed(not collapsed)

func set_collapsed(value: bool) -> void:
    if collapsed == value and _toggle_button != null:
        _refresh()
        _layout()
        return
    collapsed = value
    _refresh()
    _layout()
    layout_requested.emit()

func append_entry(text: String, kind: String = "system") -> void:
    entries.append({"kind": kind, "text": text})
    set_meta("entry_count", entries.size())
    _refresh()

func clear_entries() -> void:
    entries.clear()
    set_meta("entry_count", 0)
    _refresh()

func _refresh() -> void:
    if _toggle_button == null:
        return
    _toggle_button.text = "기록" if collapsed else "전투 기록 ◀"
    _content.visible = not collapsed
    if _content == null:
        return
    var lines := PackedStringArray()
    for entry_value in entries:
        if typeof(entry_value) != TYPE_DICTIONARY:
            continue
        var entry: Dictionary = entry_value
        lines.append(str(entry.get("text", "")))
    _content.text = "\n\n".join(lines)
    queue_redraw()

func _layout() -> void:
    if _toggle_button == null:
        return
    if collapsed:
        _toggle_button.position = Vector2.ZERO
        _toggle_button.size = size
        _content.visible = false
    else:
        _toggle_button.position = Vector2(8.0, 7.0)
        _toggle_button.size = Vector2(maxf(1.0, size.x - 16.0), 30.0)
        _content.position = Vector2(14.0, 44.0)
        _content.size = Vector2(maxf(1.0, size.x - 28.0), maxf(1.0, size.y - 58.0))
        _content.visible = true
    queue_redraw()

func get_preferred_width(expanded_width: float) -> float:
    return 48.0 if collapsed else expanded_width

func get_log_snapshot() -> Dictionary:
    return {
        "step": 7,
        "layout_role": "right_overlay",
        "collapsible": true,
        "collapsed": collapsed,
        "default_collapsed": bool(log_data.get("default_collapsed", true)),
        "entry_count": entries.size(),
        "output_interface": true,
        "data_path": DATA_PATH
    }

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(GOLD, 0.78), false, 2.0)
    if not collapsed:
        draw_line(Vector2(10.0, 40.0), Vector2(maxf(10.0, size.x - 10.0), 40.0), Color(GOLD, 0.34), 1.0)
