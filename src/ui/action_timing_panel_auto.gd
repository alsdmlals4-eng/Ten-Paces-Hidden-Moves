extends ActionTimingPanel

signal linked_block_drag_requested(anchor_index: int)
signal linked_block_move_requested(anchor_index: int, new_anchor_index: int)
signal linked_block_move_failed(anchor_index: int, requested_anchor: int)

const LINKED_BLOCK_SCENE := preload("res://scenes/ui/action_selection/linked_action_block.tscn")

var linked_blocks: Dictionary = {}
var _linked_block_layer: Control
var _drag_anchor := 0

func _ready() -> void:
    super._ready()
    _build_linked_block_layer()
    _connect_pointer_drop_targets()
    _refresh_linked_blocks()

func find_earliest_open_anchor(span: int) -> int:
    var required := maxi(1, span)
    for start_value in get_current_bundle_indices():
        var start := int(start_value)
        var fits := true
        for offset in range(required):
            var timing_index := start + offset
            if not is_index_actionable(timing_index) or has_assignment_at(timing_index):
                fits = false
                break
        if fits:
            return start
    return 0

func get_linked_block(anchor_index: int) -> LinkedActionBlock:
    if not linked_blocks.has(anchor_index):
        return null
    var block = linked_blocks[anchor_index]
    return block as LinkedActionBlock if is_instance_valid(block) else null

func get_linked_block_snapshots() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var anchors := linked_blocks.keys()
    anchors.sort()
    for anchor_value in anchors:
        var block := get_linked_block(int(anchor_value))
        if is_instance_valid(block):
            result.append(block.get_block_snapshot())
    return result

func get_anchor_rect(anchor_index: int) -> Rect2:
    var placement := get_placement(anchor_index)
    if placement.is_empty():
        return Rect2()
    var indices: PackedInt32Array = placement.get("indices", PackedInt32Array())
    if indices.is_empty():
        return Rect2()
    var first_slot := get_slot(int(indices[0]))
    var last_slot := get_slot(int(indices[indices.size() - 1]))
    if first_slot == null or last_slot == null:
        return Rect2()
    var left := first_slot.position.x + 3.0
    var right := last_slot.position.x + last_slot.size.x - 3.0
    var top := first_slot.position.y + 23.0
    var height := maxf(30.0, first_slot.size.y - 27.0)
    return Rect2(Vector2(left, top), Vector2(maxf(1.0, right - left), height))

func can_move_placement(anchor_index: int, new_anchor_index: int) -> bool:
    if anchor_index <= 0 or new_anchor_index <= 0 or not placements.has(anchor_index):
        return false
    if anchor_index == new_anchor_index:
        return true
    var placement: Dictionary = placements[anchor_index]
    var span := maxi(1, int(placement.get("span", 1)))
    for offset in range(span):
        var timing_index := new_anchor_index + offset
        if not is_index_actionable(timing_index):
            return false
        if has_assignment_at(timing_index) and get_assignment_anchor(timing_index) != anchor_index:
            return false
    return true

func get_valid_move_anchors(anchor_index: int) -> PackedInt32Array:
    var result := PackedInt32Array()
    if not placements.has(anchor_index):
        return result
    for timing_value in get_current_bundle_indices():
        var candidate := int(timing_value)
        if candidate != anchor_index and can_move_placement(anchor_index, candidate):
            result.append(candidate)
    return result

func move_placement(anchor_index: int, new_anchor_index: int) -> bool:
    if anchor_index == new_anchor_index:
        return placements.has(anchor_index)
    if not can_move_placement(anchor_index, new_anchor_index):
        linked_block_move_failed.emit(anchor_index, new_anchor_index)
        return false

    var original: Dictionary = placements[anchor_index].duplicate(true)
    var original_indices: PackedInt32Array = original.get("indices", PackedInt32Array())
    var span := maxi(1, int(original.get("span", original_indices.size())))
    var candidate_indices := PackedInt32Array()
    for offset in range(span):
        candidate_indices.append(new_anchor_index + offset)

    for timing_value in original_indices:
        var old_slot := get_slot(int(timing_value))
        if old_slot != null:
            old_slot.clear_assignment()
    placements.erase(anchor_index)

    var candidate := original.duplicate(true)
    candidate["anchor_index"] = new_anchor_index
    candidate["indices"] = candidate_indices
    var targeting_mode := str(candidate.get("targeting_mode", "none"))
    if targeting_mode != "none":
        candidate["target_ready"] = false
        candidate["target_tile"] = 0
        candidate["direction"] = 0
        candidate["origin_tile"] = 0
        candidate["target_text"] = ""
    placements[new_anchor_index] = candidate

    var definition: Dictionary = candidate.get("definition", {})
    for part_index in range(candidate_indices.size()):
        var slot := get_slot(int(candidate_indices[part_index]))
        if slot != null:
            slot.set_assignment(definition, new_anchor_index, span, part_index)
    _sync_placement_slots(candidate)
    _emit_placement_changed()
    return true

func begin_linked_block_drag(anchor_index: int) -> bool:
    if not placements.has(anchor_index):
        return false
    _drag_anchor = anchor_index
    set_meta("drag_anchor", _drag_anchor)
    set_meta("valid_drag_anchors", get_valid_move_anchors(anchor_index))
    return true

func drop_linked_block_at(new_anchor_index: int) -> bool:
    if _drag_anchor <= 0:
        return false
    var original_anchor := _drag_anchor
    _drag_anchor = 0
    set_meta("drag_anchor", 0)
    set_meta("valid_drag_anchors", PackedInt32Array())
    if not can_move_placement(original_anchor, new_anchor_index):
        linked_block_move_failed.emit(original_anchor, new_anchor_index)
        return false
    linked_block_move_requested.emit(original_anchor, new_anchor_index)
    return true

func cancel_linked_block_drag() -> void:
    _drag_anchor = 0
    set_meta("drag_anchor", 0)
    set_meta("valid_drag_anchors", PackedInt32Array())

func focus_linked_block(anchor_index: int) -> void:
    var block := get_linked_block(anchor_index)
    if is_instance_valid(block):
        block.grab_focus()

func _emit_placement_changed() -> void:
    super._emit_placement_changed()
    call_deferred("_refresh_linked_blocks")

func _layout() -> void:
    super._layout()
    _layout_linked_blocks()

func _notification(what: int) -> void:
    super._notification(what)
    if what == NOTIFICATION_RESIZED:
        call_deferred("_layout_linked_blocks")

func _build_linked_block_layer() -> void:
    if is_instance_valid(_linked_block_layer):
        return
    _linked_block_layer = Control.new()
    _linked_block_layer.name = "LinkedActionBlockLayer"
    _linked_block_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _linked_block_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_linked_block_layer)
    set_meta("linked_action_blocks_enabled", true)

func _connect_pointer_drop_targets() -> void:
    var release_callback := Callable(self, "_on_slot_pointer_released")
    for timing_index in range(1, 11):
        var slot := get_slot(timing_index)
        if slot == null or not slot.has_signal("slot_pointer_released"):
            continue
        if not slot.is_connected("slot_pointer_released", release_callback):
            slot.connect("slot_pointer_released", release_callback)

func _refresh_linked_blocks() -> void:
    if not is_instance_valid(_linked_block_layer):
        return
    for block_value in linked_blocks.values():
        if is_instance_valid(block_value):
            var old_block := block_value as LinkedActionBlock
            _linked_block_layer.remove_child(old_block)
            old_block.queue_free()
    linked_blocks.clear()

    var anchors := placements.keys()
    anchors.sort()
    for anchor_value in anchors:
        var anchor_index := int(anchor_value)
        var placement := get_placement(anchor_index)
        if placement.is_empty():
            continue
        var block := LINKED_BLOCK_SCENE.instantiate() as LinkedActionBlock
        block.name = "LinkedActionBlock%02d" % anchor_index
        block.configure(placement)
        block.block_activated.connect(_on_linked_block_activated)
        block.block_drag_requested.connect(_on_linked_block_drag_requested)
        block.block_move_requested.connect(_on_linked_block_move_requested)
        block.block_remove_requested.connect(_on_linked_block_remove_requested)
        _linked_block_layer.add_child(block)
        linked_blocks[anchor_index] = block
    _layout_linked_blocks()
    set_meta("linked_block_count", linked_blocks.size())

func _layout_linked_blocks() -> void:
    if not is_instance_valid(_linked_block_layer):
        return
    _linked_block_layer.position = Vector2.ZERO
    for anchor_value in linked_blocks.keys():
        var anchor_index := int(anchor_value)
        var block := get_linked_block(anchor_index)
        if not is_instance_valid(block):
            continue
        var block_rect := get_anchor_rect(anchor_index)
        block.position = block_rect.position
        block.size = block_rect.size

func _on_slot_pointer_released(timing_index: int) -> void:
    if _drag_anchor <= 0:
        return
    drop_linked_block_at(timing_index)

func _on_linked_block_activated(anchor_index: int) -> void:
    slot_clicked.emit(anchor_index)

func _on_linked_block_drag_requested(anchor_index: int) -> void:
    if begin_linked_block_drag(anchor_index):
        linked_block_drag_requested.emit(anchor_index)

func _on_linked_block_move_requested(anchor_index: int, direction: int) -> void:
    var requested_anchor := anchor_index + signi(direction)
    if can_move_placement(anchor_index, requested_anchor):
        linked_block_move_requested.emit(anchor_index, requested_anchor)
    else:
        linked_block_move_failed.emit(anchor_index, requested_anchor)

func _on_linked_block_remove_requested(anchor_index: int) -> void:
    slot_clicked.emit(anchor_index)
