class_name OpponentHypothesisPanel
extends VBoxContainer

signal hypothesis_changed(hypothesis_id: String)

const DATA_PATH := "res://data/combat/combat_hypothesis_poc.json"
const NONE_ID := "none"
const NONE_LABEL := "기록한 가설 없음"

var _selected_id := NONE_ID
var _labels: Dictionary = {NONE_ID: NONE_LABEL}

func _ready() -> void:
    _load_options()
    accessibility_name = "상대 행동 가설"
    accessibility_description = "상대가 다음 묶음에 무엇을 할지 선택적으로 기록합니다."

func select_hypothesis(hypothesis_id: String) -> void:
    _selected_id = hypothesis_id if _labels.has(hypothesis_id) else NONE_ID
    hypothesis_changed.emit(_selected_id)

func clear_hypothesis() -> void:
    select_hypothesis(NONE_ID)

func snapshot_hypothesis() -> Dictionary:
    return {
        "id": _selected_id,
        "label": str(_labels.get(_selected_id, NONE_LABEL)),
        "recorded": _selected_id != NONE_ID
    }

func restore_snapshot(snapshot: Dictionary) -> void:
    select_hypothesis(str(snapshot.get("id", NONE_ID)))

func selected_id() -> String:
    return _selected_id

func display_text() -> String:
    return str(_labels.get(_selected_id, NONE_LABEL))

func _load_options() -> void:
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return
    for value in (parsed as Dictionary).get("options", []):
        if typeof(value) == TYPE_DICTIONARY:
            var option: Dictionary = value
            _labels[str(option.get("id", NONE_ID))] = str(option.get("label", NONE_LABEL))
