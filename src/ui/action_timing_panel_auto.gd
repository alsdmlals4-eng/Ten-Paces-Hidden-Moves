extends ActionTimingPanel

signal linked_block_drag_requested(anchor_index: int)

const LINKED_BLOCK_SCENE := preload("res://scenes/ui/action_selection/linked_action_block.tscn")

var linked_blocks: Dictionary = {}
var _linked_block_layer: Control

func _ready() -> void:
    super._ready()
    _build_linked_block_layer()
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
        _linked_block_layer.add_child(block)
        linked_blocks[anchor_index] = block
    _layout_linked_blocks()
    set_meta("linked_block_count", linked_blocks.size())

func _layout_linked_blocks() -> void:
    if not is_instance_valid(_linked_block_layer):
        return
    _linked_block_layer.position = Vector2.ZERO
    _linked_block_layer.size = size
    for anchor_value in linked_blocks.keys():
        var anchor_index := int(anchor_value)
        var block := get_linked_block(anchor_index)
        if not is_instance_valid(block):
            continue
        var block_rect := get_anchor_rect(anchor_index)
        block.position = block_rect.position
        block.size = block_rect.size

func _on_linked_block_activated(anchor_index: int) -> void:
    slot_clicked.emit(anchor_index)

func _on_linked_block_drag_requested(anchor_index: int) -> void:
    linked_block_drag_requested.emit(anchor_index)
