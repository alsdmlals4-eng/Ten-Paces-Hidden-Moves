class_name BasicCardTray
extends Control

signal card_hovered(definition)
signal card_unhovered(card_id)
signal card_clicked(definition)
signal action_card_selected(definition)

const DATA_PATH := "res://data/cards/basic_cards.json"
const CARD_SCENE := preload("res://scenes/ui/basic_card_tray_item.tscn")

const PANEL := Color(0.045, 0.038, 0.030, 0.98)
const PAPER := Color("e0cfaa")
const GOLD := Color("c79a50")
const MUTED := Color("9b8c76")

var card_data: Dictionary = {}
var cards: Array[BasicCardTrayItem] = []
var pinned_card_id := ""
var selected_card_id := ""
var virtual_definitions: Dictionary = {}

var _title_label: Label
var _status_label: Label

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS
    card_data = _load_data()
    _build_content()
    resized.connect(_layout)
    _refresh_status()
    _layout()

func _load_data() -> Dictionary:
    if not FileAccess.file_exists(DATA_PATH):
        push_error("STEP 6 basic card data was not found: %s" % DATA_PATH)
        return {}
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        push_error("STEP 6 basic card data could not be opened: %s" % DATA_PATH)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("STEP 6 basic card data root must be a Dictionary.")
        return {}
    return parsed

func _build_content() -> void:
    _title_label = _make_label(15, PAPER, HORIZONTAL_ALIGNMENT_LEFT)
    _title_label.name = "BasicCardTrayTitle"
    _title_label.text = "기초 행동"

    _status_label = _make_label(12, MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
    _status_label.name = "BasicCardTrayStatus"

    var definitions: Array = card_data.get("cards", [])
    for definition_value in definitions:
        if typeof(definition_value) != TYPE_DICTIONARY:
            continue
        var definition: Dictionary = definition_value
        var card := CARD_SCENE.instantiate() as BasicCardTrayItem
        card.name = "BasicCard%02d" % (cards.size() + 1)
        card.configure(definition)
        card.detail_hovered.connect(_on_card_hovered)
        card.detail_unhovered.connect(_on_card_unhovered)
        card.detail_clicked.connect(_on_card_clicked)
        add_child(card)
        cards.append(card)

    set_meta("step", 6)
    set_meta("information_interaction_step", 7)
    set_meta("placement_step", 9)
    set_meta("response_combo_patch", "10.6")
    set_meta("layout_role", "bottom_lower")
    set_meta("card_count", cards.size())
    set_meta("card_ids", "|".join(get_card_ids()))
    set_meta("data_path", DATA_PATH)
    set_meta("compact_variant", true)
    set_meta("information_interactions_enabled", true)
    set_meta("action_placement_enabled", true)
    set_meta("stance_response_combo_enabled", true)
    set_meta("interactions_enabled", true)
    set_meta("action_timing_above", true)
    set_meta("selected_card_id", "")

func _on_card_hovered(definition: Dictionary) -> void:
    card_hovered.emit(definition)

func _on_card_unhovered(card_id: String) -> void:
    card_unhovered.emit(card_id)

func _on_card_clicked(definition: Dictionary) -> void:
    var emitted_definition := definition.duplicate(true)
    var previous := get_card_definition(selected_card_id)
    if _can_build_stance_response_combo(previous, definition):
        emitted_definition = build_stance_response_combo(previous, definition)
    if not emitted_definition.is_empty():
        virtual_definitions[str(emitted_definition.get("id", ""))] = emitted_definition.duplicate(true)
    card_clicked.emit(emitted_definition)
    action_card_selected.emit(emitted_definition)

func _can_build_stance_response_combo(first: Dictionary, second: Dictionary) -> bool:
    if first.is_empty() or second.is_empty():
        return false
    var first_id := str(first.get("base_card_id", first.get("id", "")))
    var second_id := str(second.get("base_card_id", second.get("id", "")))
    var first_is_stance := first_id == "basic_stance"
    var second_is_stance := second_id == "basic_stance"
    var first_is_response := str(first.get("category", "")) == "response"
    var second_is_response := str(second.get("category", "")) == "response"
    return (first_is_stance and second_is_response) or (second_is_stance and first_is_response)

func build_stance_response_combo(first: Dictionary, second: Dictionary) -> Dictionary:
    if not _can_build_stance_response_combo(first, second):
        return {}
    var response: Dictionary = first if str(first.get("category", "")) == "response" else second
    var stance: Dictionary = first if str(first.get("base_card_id", first.get("id", ""))) == "basic_stance" else second
    var response_id := str(response.get("base_card_id", response.get("id", "")))
    var combo := response.duplicate(true)
    combo["id"] = "combo_stance_%s" % response_id
    combo["base_card_id"] = response_id
    combo["modifier_card_id"] = "basic_stance"
    combo["name"] = "태세+%s" % str(response.get("name", "대응"))
    combo["source_label"] = "기초"
    combo["stance_response_combo"] = true
    combo["combo_parts"] = PackedStringArray(["basic_stance", response_id])
    combo["action_slots"] = 1
    combo["stamina_cost"] = maxi(0, int(response.get("stamina_cost", 0))) + maxi(0, int(stance.get("stamina_cost", 0)))
    combo["internal_cost"] = maxi(0, int(response.get("internal_cost", 0))) + maxi(0, int(stance.get("internal_cost", 0)))
    var response_name := str(response.get("name", "대응"))
    if response_id == "basic_evade":
        combo["effect_text"] = "태세와 회피를 같은 슬롯에 결합한다. 완전 회피 범위가 현재 행동 묶음 전체로 확장된다."
    else:
        combo["effect_text"] = "태세와 막기를 같은 슬롯에 결합한다. 막기 범위가 현재 행동 묶음 전체로 확장되고 방어도가 50% 증가한다."
    combo["condition"] = "태세와 %s 연계" % response_name
    combo["tags"] = ["태세", response_name, "대응 강화"]
    combo["flavor"] = "한 수에 형과 응을 겹쳐, 한 묶음의 공세를 받아낸다."
    return combo

func set_pinned_card(card_id: String) -> void:
    pinned_card_id = card_id
    var focused_ids := _focus_ids_for_definition(get_card_definition(pinned_card_id))
    for card in cards:
        var id := str(card.definition.get("id", ""))
        card.set_pinned(id in focused_ids and not pinned_card_id.is_empty())
    set_meta("pinned_card_id", pinned_card_id)

func set_selected_card(card_id: String) -> void:
    selected_card_id = card_id
    var focused_ids := _focus_ids_for_definition(get_card_definition(selected_card_id))
    for card in cards:
        var id := str(card.definition.get("id", ""))
        card.set_selected_for_placement(id in focused_ids and not selected_card_id.is_empty())
    set_meta("selected_card_id", selected_card_id)
    _refresh_status()

func _focus_ids_for_definition(definition: Dictionary) -> PackedStringArray:
    var result := PackedStringArray()
    if definition.is_empty():
        return result
    var combo_parts = definition.get("combo_parts", [])
    if typeof(combo_parts) == TYPE_PACKED_STRING_ARRAY or typeof(combo_parts) == TYPE_ARRAY:
        for value in combo_parts:
            result.append(str(value))
    else:
        result.append(str(definition.get("id", "")))
    return result

func clear_card_focus() -> void:
    set_pinned_card("")

func clear_action_selection() -> void:
    set_selected_card("")

func get_card_definition(card_id: String) -> Dictionary:
    if virtual_definitions.has(card_id):
        return (virtual_definitions[card_id] as Dictionary).duplicate(true)
    for card in cards:
        if str(card.definition.get("id", "")) == card_id:
            return card.definition.duplicate(true)
    return {}

func _refresh_status() -> void:
    if _status_label == null:
        return
    if selected_card_id.is_empty():
        _status_label.text = "카드 선택 → 현재 묶음 슬롯 클릭"
        _status_label.add_theme_color_override("font_color", MUTED)
        return
    var definition := get_card_definition(selected_card_id)
    var combo_text := " · 한 슬롯 연계" if bool(definition.get("stance_response_combo", false)) else ""
    _status_label.text = "%s 선택 · %d슬롯 배치%s" % [
        str(definition.get("name", "")),
        int(definition.get("action_slots", 1)),
        combo_text
    ]
    _status_label.add_theme_color_override("font_color", GOLD)

func _make_label(font_size: int, color: Color, alignment: int) -> Label:
    var label := Label.new()
    label.horizontal_alignment = alignment
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.clip_text = true
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(label)
    return label

func _layout() -> void:
    if _title_label == null or cards.is_empty():
        return

    var side_margin := 10.0
    var width := maxf(1.0, size.x - side_margin * 2.0)
    _title_label.position = Vector2(side_margin, 3.0)
    _title_label.size = Vector2(width * 0.35, 23.0)
    _status_label.position = Vector2(side_margin + width * 0.35, 3.0)
    _status_label.size = Vector2(width * 0.65, 23.0)

    var gap := clampf(size.x * 0.004, 3.0, 7.0)
    var total_gap := gap * float(cards.size() - 1)
    var card_width := maxf(96.0, (width - total_gap) / float(cards.size()))
    var card_y := 29.0
    var card_height := maxf(96.0, size.y - card_y - 8.0)
    var x := side_margin

    for card in cards:
        card.position = Vector2(x, card_y)
        card.size = Vector2(card_width, card_height)
        x += card_width + gap

    queue_redraw()

func get_card_ids() -> PackedStringArray:
    var ids := PackedStringArray()
    for card in cards:
        ids.append(str(card.definition.get("id", "")))
    return ids

func get_tray_snapshot() -> Dictionary:
    return {
        "step": 6,
        "information_interaction_step": 7,
        "placement_step": 9,
        "response_combo_patch": "10.6",
        "layout_role": "bottom_lower",
        "card_count": cards.size(),
        "card_ids": get_card_ids(),
        "source": "basic",
        "compact_variant": true,
        "information_interactions_enabled": true,
        "action_placement_enabled": true,
        "stance_response_combo_enabled": true,
        "interactions_enabled": true,
        "pinned_card_id": pinned_card_id,
        "selected_card_id": selected_card_id,
        "action_timing_above": true
    }

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(GOLD, 0.72), false, 2.0)
    draw_line(Vector2(10.0, 27.0), Vector2(maxf(10.0, size.x - 10.0), 27.0), Color(GOLD, 0.30), 1.0)
