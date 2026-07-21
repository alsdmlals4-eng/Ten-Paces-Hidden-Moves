class_name ActionTimingPanel
extends Control

signal slot_clicked(timing_index: int)
signal placement_changed(snapshot: Dictionary)
signal bundle_advanced(snapshot: Dictionary)

const DATA_PATH := "res://data/combat/combat_action_timing_preview.json"
const SLOT_SCENE := preload("res://scenes/ui/action_timing_slot.tscn")

const PANEL := Color(0.055, 0.045, 0.035, 0.97)
const PAPER := Color("e0cfaa")
const GOLD := Color("c79a50")
const MUTED := Color("948875")

var timing_data: Dictionary = {}
var slots: Array[ActionTimingSlot] = []
var placements: Dictionary = {}

var _title_label: Label
var _sequence_label: Label
var _progress_label: Label
var _group_labels: Array[Label] = []
var _separator_x: Array[float] = []

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS
    timing_data = _load_data()
    _build_content()
    resized.connect(_layout)
    _refresh()
    _layout()

func _load_data() -> Dictionary:
    if not FileAccess.file_exists(DATA_PATH):
        push_error("STEP 5 action timing data was not found: %s" % DATA_PATH)
        return {}
    var file := FileAccess.open(DATA_PATH, FileAccess.READ)
    if file == null:
        push_error("STEP 5 action timing data could not be opened: %s" % DATA_PATH)
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("STEP 5 action timing data root must be a Dictionary.")
        return {}
    return parsed

func _build_content() -> void:
    _title_label = _make_label(16, PAPER, HORIZONTAL_ALIGNMENT_LEFT)
    _title_label.name = "ActionTimingTitle"
    _sequence_label = _make_label(15, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
    _sequence_label.name = "TimingSequenceLabel"
    _progress_label = _make_label(14, PAPER, HORIZONTAL_ALIGNMENT_RIGHT)
    _progress_label.name = "TimingProgressLabel"

    var sequence: Array = timing_data.get("timing_sequence", [3, 3, 4])
    var labels: Array = timing_data.get("bundle_labels", ["1묶음", "2묶음", "3묶음"])
    var global_index := 1
    for group_index in range(sequence.size()):
        var count := int(sequence[group_index])
        var group_label := _make_label(12, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
        group_label.name = "BundleLabel%d" % (group_index + 1)
        var label_text := str(labels[group_index]) if group_index < labels.size() else "%d묶음" % (group_index + 1)
        group_label.text = "%s · %d수" % [label_text, count]
        _group_labels.append(group_label)
        var group_end := global_index + count - 1
        for local_index in range(1, count + 1):
            var slot := SLOT_SCENE.instantiate() as ActionTimingSlot
            slot.name = "TimingSlot%02d" % global_index
            slot.configure(global_index, group_index + 1, local_index, _resolve_state(global_index, group_index + 1, group_end))
            slot.slot_clicked.connect(_on_slot_clicked)
            add_child(slot)
            slots.append(slot)
            global_index += 1

    set_meta("step", 5)
    set_meta("placement_step", 9)
    set_meta("runtime_step", 10)
    set_meta("layout_role", "bottom_upper")
    set_meta("timing_sequence", "3|3|4")
    set_meta("total_timings", slots.size())
    set_meta("progress_scope", "round")
    set_meta("interactions_enabled", true)
    set_meta("placement_enabled", true)
    set_meta("state_advancement_enabled", true)
    _update_runtime_meta()

func _resolve_state(global_index: int, group_index: int, _group_end: int) -> String:
    var current_bundle := int(timing_data.get("current_bundle", 1))
    var current_timing := int(timing_data.get("current_timing", 1))
    if global_index < current_timing:
        return "passed"
    if group_index < current_bundle:
        return "passed"
    if group_index > current_bundle:
        return "locked"
    if global_index == current_timing:
        return "current"
    return "available"

func _refresh_slot_states() -> void:
    for slot in slots:
        slot.configure(slot.timing_index, slot.bundle_index, slot.local_index, _resolve_state(slot.timing_index, slot.bundle_index, slot.timing_index))
    _update_group_colors()

func _update_group_colors() -> void:
    var current_bundle := int(timing_data.get("current_bundle", 1))
    for index in range(_group_labels.size()):
        _group_labels[index].add_theme_color_override("font_color", GOLD if index + 1 == current_bundle else MUTED)

func _on_slot_clicked(timing_index: int) -> void:
    slot_clicked.emit(timing_index)

func get_slot(timing_index: int) -> ActionTimingSlot:
    if timing_index < 1 or timing_index > slots.size():
        return null
    return slots[timing_index - 1]

func get_bundle_bounds(bundle_index: int) -> Vector2i:
    var sequence: Array = timing_data.get("timing_sequence", [3, 3, 4])
    var start := 1
    for group_index in range(maxi(0, bundle_index - 1)):
        if group_index < sequence.size():
            start += int(sequence[group_index])
    if bundle_index < 1 or bundle_index > sequence.size():
        return Vector2i(start, start)
    return Vector2i(start, start + int(sequence[bundle_index - 1]) - 1)

func get_current_bundle_indices() -> PackedInt32Array:
    var result := PackedInt32Array()
    var bounds := get_bundle_bounds(int(timing_data.get("current_bundle", 1)))
    for timing_index in range(maxi(bounds.x, int(timing_data.get("current_timing", bounds.x))), bounds.y + 1):
        result.append(timing_index)
    return result

func is_index_actionable(timing_index: int) -> bool:
    return timing_index in get_current_bundle_indices()

func has_assignment_at(timing_index: int) -> bool:
    var slot := get_slot(timing_index)
    return slot != null and slot.has_assignment()

func get_assignment_anchor(timing_index: int) -> int:
    var slot := get_slot(timing_index)
    if slot == null or not slot.has_assignment():
        return 0
    return slot.assignment_anchor_index

func place_card(definition: Dictionary, start_index: int) -> bool:
    if definition.is_empty() or not is_index_actionable(start_index):
        return false
    var span := maxi(1, int(definition.get("action_slots", 1)))
    var target_indices := PackedInt32Array()
    for offset in range(span):
        var timing_index := start_index + offset
        if not is_index_actionable(timing_index) or has_assignment_at(timing_index):
            return false
        target_indices.append(timing_index)

    var placement := {
        "card_id": str(definition.get("id", "")),
        "card_name": str(definition.get("name", "")),
        "definition": definition.duplicate(true),
        "anchor_index": start_index,
        "span": span,
        "indices": target_indices
    }
    placements[start_index] = placement
    for part_index in range(target_indices.size()):
        var slot := get_slot(int(target_indices[part_index]))
        if slot != null:
            slot.set_assignment(definition, start_index, span, part_index)
    _emit_placement_changed()
    return true

func remove_at(timing_index: int) -> Dictionary:
    var anchor_index := get_assignment_anchor(timing_index)
    if anchor_index <= 0 or not placements.has(anchor_index):
        return {}
    var placement: Dictionary = placements[anchor_index]
    var indices: PackedInt32Array = placement.get("indices", PackedInt32Array())
    for index_value in indices:
        var slot := get_slot(int(index_value))
        if slot != null:
            slot.clear_assignment()
    placements.erase(anchor_index)
    _emit_placement_changed()
    return placement.duplicate(true)

func clear_current_bundle() -> void:
    var anchors := placements.keys().duplicate()
    for anchor_value in anchors:
        var anchor_index := int(anchor_value)
        if is_index_actionable(anchor_index):
            _clear_placement_without_signal(anchor_index)
    _emit_placement_changed()

func _clear_placement_without_signal(anchor_index: int) -> void:
    if not placements.has(anchor_index):
        return
    var placement: Dictionary = placements[anchor_index]
    var indices: PackedInt32Array = placement.get("indices", PackedInt32Array())
    for index_value in indices:
        var slot := get_slot(int(index_value))
        if slot != null:
            slot.clear_assignment()
    placements.erase(anchor_index)

func is_current_bundle_complete() -> bool:
    var actionable := get_current_bundle_indices()
    if actionable.is_empty():
        return false
    for timing_index in actionable:
        if not has_assignment_at(int(timing_index)):
            return false
    return true

func get_occupied_actionable_count() -> int:
    var count := 0
    for timing_index in get_current_bundle_indices():
        if has_assignment_at(int(timing_index)):
            count += 1
    return count

func get_placement_list() -> Array:
    var result: Array = []
    var anchors := placements.keys()
    anchors.sort()
    for anchor_value in anchors:
        var placement: Dictionary = placements[anchor_value]
        result.append({
            "card_id": str(placement.get("card_id", "")),
            "card_name": str(placement.get("card_name", "")),
            "anchor_index": int(placement.get("anchor_index", 0)),
            "span": int(placement.get("span", 0)),
            "indices": placement.get("indices", PackedInt32Array())
        })
    return result

func get_resolution_placements() -> Array:
    var result: Array = []
    var anchors := placements.keys()
    anchors.sort()
    for anchor_value in anchors:
        var anchor_index := int(anchor_value)
        if not is_index_actionable(anchor_index):
            continue
        var placement: Dictionary = placements[anchor_index]
        result.append(placement.duplicate(true))
    return result

func get_runtime_context() -> Dictionary:
    return {
        "round_number": int(timing_data.get("round_number", 1)),
        "bundle_index": int(timing_data.get("current_bundle", 1)),
        "current_timing": int(timing_data.get("current_timing", 1)),
        "total_timings": slots.size(),
        "timing_sequence": timing_data.get("timing_sequence", [3, 3, 4])
    }

func advance_after_resolution() -> Dictionary:
    var resolved_bundle := int(timing_data.get("current_bundle", 1))
    var resolved_bounds := get_bundle_bounds(resolved_bundle)
    var anchors := placements.keys().duplicate()
    for anchor_value in anchors:
        _clear_placement_without_signal(int(anchor_value))

    var sequence: Array = timing_data.get("timing_sequence", [3, 3, 4])
    var next_bundle := resolved_bundle + 1
    var next_round := int(timing_data.get("round_number", 1))
    if next_bundle > sequence.size():
        next_round += 1
        next_bundle = 1
    var next_bounds := get_bundle_bounds(next_bundle)
    timing_data["round_number"] = next_round
    timing_data["current_bundle"] = next_bundle
    timing_data["current_timing"] = next_bounds.x

    _refresh_slot_states()
    _refresh()
    _update_runtime_meta()
    _emit_placement_changed()
    var snapshot := get_timing_snapshot()
    snapshot["resolved_bundle"] = resolved_bundle
    snapshot["resolved_start"] = resolved_bounds.x
    snapshot["resolved_end"] = resolved_bounds.y
    bundle_advanced.emit(snapshot)
    return snapshot

func _emit_placement_changed() -> void:
    set_meta("cards_inserted", not placements.is_empty())
    set_meta("current_bundle_complete", is_current_bundle_complete())
    placement_changed.emit(get_timing_snapshot())

func _update_runtime_meta() -> void:
    set_meta("round_number", int(timing_data.get("round_number", 1)))
    set_meta("current_bundle", int(timing_data.get("current_bundle", 1)))
    set_meta("current_timing", int(timing_data.get("current_timing", 1)))

func _make_label(font_size: int, color: Color, alignment: int) -> Label:
    var label := Label.new()
    label.horizontal_alignment = alignment
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
    label.add_theme_constant_override("shadow_offset_x", 1)
    label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(label)
    return label

func _refresh() -> void:
    if _title_label == null:
        return
    var sequence: Array = timing_data.get("timing_sequence", [3, 3, 4])
    var sequence_texts := PackedStringArray()
    for value in sequence:
        sequence_texts.append("%d수" % int(value))
    _title_label.text = "행동 진행"
    _sequence_label.text = " → ".join(sequence_texts)
    _progress_label.text = "라운드 %d" % int(timing_data.get("round_number", 1))
    _update_group_colors()

func _layout() -> void:
    if _title_label == null or slots.is_empty():
        return
    var side_margin := 12.0
    var width := maxf(1.0, size.x - side_margin * 2.0)
    _title_label.position = Vector2(side_margin, 5.0)
    _title_label.size = Vector2(width * 0.30, 24.0)
    _sequence_label.position = Vector2(side_margin + width * 0.30, 5.0)
    _sequence_label.size = Vector2(width * 0.40, 24.0)
    _progress_label.position = Vector2(side_margin + width * 0.70, 5.0)
    _progress_label.size = Vector2(width * 0.30, 24.0)

    var sequence: Array = timing_data.get("timing_sequence", [3, 3, 4])
    var base_gap := 6.0
    var group_extra_gap := 16.0
    var total_gap := base_gap * float(slots.size() - 1) + group_extra_gap * float(maxi(0, sequence.size() - 1))
    var slot_width := maxf(48.0, (width - total_gap) / float(slots.size()))
    var slot_y := 50.0
    var slot_height := maxf(56.0, size.y - slot_y - 9.0)
    var x := side_margin
    var slot_cursor := 0
    _separator_x.clear()

    for group_index in range(sequence.size()):
        var count := int(sequence[group_index])
        var group_start_x := x
        for _local_index in range(count):
            var slot := slots[slot_cursor]
            slot.position = Vector2(x, slot_y)
            slot.size = Vector2(slot_width, slot_height)
            x += slot_width
            slot_cursor += 1
            if slot_cursor < slots.size():
                x += base_gap
        var group_end_x := x - base_gap if slot_cursor < slots.size() else x
        if group_index < _group_labels.size():
            var group_label := _group_labels[group_index]
            group_label.position = Vector2(group_start_x, 29.0)
            group_label.size = Vector2(maxf(1.0, group_end_x - group_start_x), 18.0)
        if group_index < sequence.size() - 1:
            _separator_x.append(x + group_extra_gap * 0.5 - base_gap * 0.5)
            x += group_extra_gap
    queue_redraw()

func get_timing_snapshot() -> Dictionary:
    var state_counts := {"passed": 0, "current": 0, "available": 0, "locked": 0}
    for slot in slots:
        var state := str(slot.slot_state)
        state_counts[state] = int(state_counts.get(state, 0)) + 1
    return {
        "step": 5,
        "placement_step": 9,
        "runtime_step": 10,
        "layout_role": "bottom_upper",
        "round_number": int(timing_data.get("round_number", 1)),
        "timing_sequence": timing_data.get("timing_sequence", [3, 3, 4]),
        "total_timings": slots.size(),
        "current_bundle": int(timing_data.get("current_bundle", 1)),
        "current_timing": int(timing_data.get("current_timing", 1)),
        "progress_scope": "round",
        "state_counts": state_counts,
        "cards_inserted": not placements.is_empty(),
        "interactions_enabled": true,
        "placement_enabled": true,
        "state_advancement_enabled": true,
        "current_bundle_complete": is_current_bundle_complete(),
        "occupied_actionable_count": get_occupied_actionable_count(),
        "actionable_indices": get_current_bundle_indices(),
        "placements": get_placement_list()
    }

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 2.0)), Color(GOLD, 0.72), false, 2.0)
    draw_line(Vector2(12.0, 31.0), Vector2(maxf(12.0, size.x - 12.0), 31.0), Color(GOLD, 0.30), 1.0)
    for separator in _separator_x:
        draw_line(Vector2(separator, 31.0), Vector2(separator, maxf(31.0, size.y - 8.0)), Color(GOLD, 0.38), 2.0)
