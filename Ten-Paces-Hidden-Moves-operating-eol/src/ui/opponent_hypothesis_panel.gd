class_name OpponentHypothesisPanel
extends Control

signal hypothesis_changed(snapshot: Dictionary)

const DATA_PATH := "res://data/combat/combat_hypothesis_poc.json"
const PANEL := Color(0.040, 0.034, 0.028, 0.96)
const GOLD := Color("c79a50")
const PAPER := Color("e0cfaa")

var hypothesis_data: Dictionary = {}
var hypotheses: Array = []
var _selected_id := "none"
var _locked := false

var _title: Label
var _selector: OptionButton
var _description: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    hypothesis_data = _load_data()
    hypotheses = (hypothesis_data.get("hypotheses", []) as Array).duplicate(true)
    _selected_id = str(hypothesis_data.get("default_id", "none"))
    _build()
    resized.connect(_layout)
    _refresh()
    _layout()

func _load_data() -> Dictionary:
    if not FileAccess.file_exists(DATA_PATH):
        push_error("Opponent hypothesis data was not found: %s" % DATA_PATH)
        return {"default_id": "none", "hypotheses": []}
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Opponent hypothesis data root must be a Dictionary.")
        return {"default_id": "none", "hypotheses": []}
    return parsed

func _build() -> void:
    if _selector != null:
        return
    _title = Label.new()
    _title.name = "HypothesisTitle"
    _title.text = "상대 의도 가설"
    _title.add_theme_font_size_override("font_size", 15)
    _title.add_theme_color_override("font_color", PAPER)
    add_child(_title)

    _selector = OptionButton.new()
    _selector.name = "HypothesisSelector"
    _selector.focus_mode = Control.FOCUS_ALL
    _selector.tooltip_text = "이번 행동 묶음에서 상대가 무엇을 하려는지 직접 기록합니다. 기록하지 않아도 됩니다."
    _selector.item_selected.connect(_on_item_selected)
    _selector.accessibility_name = "상대 의도 가설 선택"
    _selector.accessibility_description = "접근, 속공, 강공 준비, 대응·회복, 절초 또는 기록한 가설 없음 중 하나를 선택합니다."
    add_child(_selector)

    for value in hypotheses:
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var entry: Dictionary = value
        _selector.add_item(str(entry.get("label", entry.get("id", "가설"))))
        _selector.set_item_metadata(_selector.item_count - 1, str(entry.get("id", "none")))

    _description = Label.new()
    _description.name = "HypothesisDescription"
    _description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _description.add_theme_font_size_override("font_size", 12)
    _description.add_theme_color_override("font_color", Color(PAPER, 0.84))
    _description.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(_description)

    set_meta("component", "OpponentHypothesisPanel")
    set_meta("default_id", str(hypothesis_data.get("default_id", "none")))
    set_meta("system_inference", false)

func select_hypothesis(id_value: String) -> bool:
    if _locked:
        return false
    var found_index := -1
    for index in range(hypotheses.size()):
        var entry: Dictionary = hypotheses[index]
        if str(entry.get("id", "")) == id_value:
            found_index = index
            break
    if found_index < 0:
        _selected_id = "none"
        _select_current_in_control()
        _refresh()
        hypothesis_changed.emit(get_current_hypothesis_snapshot())
        return false
    _selected_id = id_value
    _selector.select(found_index)
    _refresh()
    hypothesis_changed.emit(get_current_hypothesis_snapshot())
    return true

func get_current_hypothesis_snapshot() -> Dictionary:
    var entry := _entry_for_id(_selected_id)
    return {
        "id": str(entry.get("id", "none")),
        "label": str(entry.get("label", "기록한 가설 없음")),
        "recorded": bool(entry.get("recorded", false))
    }

func get_hypothesis_ids() -> Array:
    var result: Array = []
    for value in hypotheses:
        if typeof(value) == TYPE_DICTIONARY:
            result.append(str((value as Dictionary).get("id", "")))
    return result

func get_focus_control() -> Control:
    return _selector

func set_locked(value: bool) -> void:
    _locked = value
    if is_instance_valid(_selector):
        _selector.disabled = value
    set_meta("locked", value)

func reset_to_initial() -> void:
    _locked = false
    _selected_id = str(hypothesis_data.get("default_id", "none"))
    if is_instance_valid(_selector):
        _selector.disabled = false
        _select_current_in_control()
    _refresh()
    hypothesis_changed.emit(get_current_hypothesis_snapshot())

func _on_item_selected(index: int) -> void:
    if _locked or not is_instance_valid(_selector):
        _select_current_in_control()
        return
    _selected_id = str(_selector.get_item_metadata(index))
    _refresh()
    hypothesis_changed.emit(get_current_hypothesis_snapshot())

func _entry_for_id(id_value: String) -> Dictionary:
    for value in hypotheses:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("id", "")) == id_value:
            return (value as Dictionary).duplicate(true)
    return {
        "id": "none",
        "label": "기록한 가설 없음",
        "recorded": false,
        "description": "이번 묶음에는 상대 의도를 기록하지 않는다."
    }

func _select_current_in_control() -> void:
    if not is_instance_valid(_selector):
        return
    for index in range(_selector.item_count):
        if str(_selector.get_item_metadata(index)) == _selected_id:
            _selector.select(index)
            return

func _refresh() -> void:
    if not is_instance_valid(_description):
        return
    var entry := _entry_for_id(_selected_id)
    _description.text = str(entry.get("description", ""))
    set_meta("selected_id", str(entry.get("id", "none")))
    set_meta("recorded", bool(entry.get("recorded", false)))

func _layout() -> void:
    if not is_instance_valid(_title) or not is_instance_valid(_selector) or not is_instance_valid(_description):
        return
    _title.position = Vector2(12.0, 8.0)
    _title.size = Vector2(maxf(1.0, size.x - 24.0), 22.0)
    _selector.position = Vector2(12.0, 32.0)
    _selector.size = Vector2(maxf(1.0, size.x - 24.0), 32.0)
    _description.position = Vector2(12.0, 69.0)
    _description.size = Vector2(maxf(1.0, size.x - 24.0), maxf(1.0, size.y - 77.0))
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _layout()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2.ONE, size - Vector2(2.0, 2.0)), Color(GOLD, 0.78), false, 2.0)
