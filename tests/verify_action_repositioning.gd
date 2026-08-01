extends SceneTree

var reserve_count := 0
var refund_count := 0
var pointer_move_requests := 0
var pointer_move_from := 0
var pointer_move_to := 0
var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel_scene := load("res://scenes/ui/action_timing_panel.tscn") as PackedScene
    var controller_script := load("res://src/ui/action_selection/action_placement_controller.gd")
    _check(panel_scene != null, "Action timing panel scene must load.")
    _check(controller_script != null, "Action placement controller script must load.")
    if panel_scene == null or controller_script == null:
        _finish()
        return

    var panel := panel_scene.instantiate() as ActionTimingPanel
    get_root().add_child(panel)
    await process_frame

    var two_slot := {
        "id": "technique_flowing_cloud_threefold",
        "name": "유운삼첩",
        "source_kind": "martial",
        "source_label": "유운검결",
        "category": "response",
        "action_slots": 2
    }
    _check(panel.place_card(two_slot, 2), "Two-slot martial technique must be placeable at timing 2.")

    if panel.has_signal("linked_block_move_requested"):
        panel.connect("linked_block_move_requested", Callable(self, "_on_pointer_move_requested"))
    else:
        failures.append("Timing panel must expose linked_block_move_requested.")

    _check(bool(panel.call("begin_linked_block_drag", 2)), "Pointer drag must start for the linked block at timing 2.")
    var drop_slot := panel.get_slot(1)
    _check(is_instance_valid(drop_slot), "Drop target timing slot 1 must exist.")
    if is_instance_valid(drop_slot):
        _check(drop_slot.has_signal("slot_pointer_released"), "Timing slots must expose slot_pointer_released for real pointer drop wiring.")
        if drop_slot.has_signal("slot_pointer_released"):
            drop_slot.emit_signal("slot_pointer_released", 1)
    await process_frame
    _check(pointer_move_requests == 1, "Releasing the pointer over timing 1 must emit exactly one linked-block move request.")
    _check(pointer_move_from == 2, "Pointer move request must originate from timing 2.")
    _check(pointer_move_to == 1, "Pointer move request must target timing 1.")
    _check(int(panel.get_meta("drag_anchor", -1)) == 0, "Pointer drop must clear the active drag anchor.")

    _check(panel.can_move_placement(2, 1), "Two-slot action at timing 2 must be movable to timing 1.")
    _check(panel.move_placement(2, 1), "Direct repositioning from timing 2 to timing 1 must succeed.")
    _check(panel.get_placement(2).is_empty(), "Old placement anchor must clear after moving.")
    _check(not panel.get_placement(1).is_empty(), "New placement anchor must contain the action.")
    _check(panel.move_placement(1, 2), "Direct repositioning back to timing 2 must succeed.")
    _check(not panel.get_placement(2).is_empty(), "Timing 2 must contain the action after moving back.")

    var original_snapshot: Dictionary = panel.get_placement(2)
    _check(panel.can_move_placement(2, 3) == false, "Two-slot action must not cross the current bundle boundary.")
    _check(panel.move_placement(2, 3) == false, "Invalid boundary-crossing move must fail.")
    _check(panel.get_placement(2) == original_snapshot, "Failed boundary move must preserve the original placement.")

    panel.clear_current_bundle()
    var blocker := {
        "id": "basic_guard",
        "name": "막기",
        "source_kind": "basic",
        "category": "response",
        "action_slots": 1
    }
    _check(panel.place_card(blocker, 1), "Blocker must be placeable at timing 1.")
    _check(panel.place_card(two_slot, 2), "Two-slot action must be placeable at timing 2 beside the blocker.")
    var collision_snapshot: Dictionary = panel.get_placement(2)
    _check(panel.can_move_placement(2, 1) == false, "Move into an occupied timing range must be rejected.")
    _check(panel.move_placement(2, 1) == false, "Collision move must fail.")
    _check(panel.get_placement(2) == collision_snapshot, "Failed collision move must preserve the original placement.")

    panel.clear_current_bundle()
    var controller = controller_script.new()
    controller.configure(
        panel,
        Callable(self, "_can_reserve"),
        Callable(self, "_reserve"),
        Callable(self, "_refund"),
        Callable(self, "_begin_targeting")
    )

    var ultimate := {
        "id": "ultimate_cleave_peak",
        "name": "단악결",
        "source_kind": "ultimate",
        "source_label": "기본 절초",
        "category": "response",
        "action_slots": 2
    }
    _check(controller.select_and_place(ultimate), "Ready ultimate must be placed through the controller.")
    _check(reserve_count == 1, "Ultimate placement must reserve momentum once.")
    _check(controller.move_placement(1, 2), "Ultimate placement must move through the controller.")
    _check(refund_count == 1, "Ultimate move must refund the previous reservation once.")
    _check(reserve_count == 2, "Ultimate move must reserve the new timing once.")
    _check(not panel.get_placement(2).is_empty(), "Moved ultimate must exist at timing 2.")
    _check(bool((panel.get_placement(2).get("definition", {}) as Dictionary).get("source_kind", "") == "ultimate"), "Moved placement must remain an ultimate.")

    controller.set_targeting_in_progress(true, 2)
    _check(controller.move_placement(2, 1) == false, "Targeting must block repositioning.")
    _check(not panel.get_placement(2).is_empty(), "Blocked targeting move must preserve placement.")

    controller.set_targeting_in_progress(false)
    controller.set_locked(true)
    _check(controller.move_placement(2, 1) == false, "Committed or locked bundle must block repositioning.")
    _check(not panel.get_placement(2).is_empty(), "Blocked locked move must preserve placement.")

    controller.set_locked(false)
    var valid_anchors: PackedInt32Array = panel.get_valid_move_anchors(2)
    _check(1 in valid_anchors, "Timing 1 must be a valid repositioning anchor.")
    _check(3 not in valid_anchors, "Timing 3 must not be a valid boundary-crossing anchor.")

    panel.queue_free()
    await process_frame
    _finish()

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _on_pointer_move_requested(anchor_index: int, new_anchor_index: int) -> void:
    pointer_move_requests += 1
    pointer_move_from = anchor_index
    pointer_move_to = new_anchor_index

func _can_reserve(_definition: Dictionary) -> bool:
    return true

func _reserve(_anchor_index: int) -> void:
    reserve_count += 1

func _refund(_placement: Dictionary) -> void:
    refund_count += 1

func _begin_targeting(_anchor_index: int) -> bool:
    return false

func _finish() -> void:
    if failures.is_empty():
        print("verify_action_repositioning: PASS")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
        print("ACTION_REPOSITIONING_FAILURE %s" % failure)
    print("verify_action_repositioning: FAIL count=%d" % failures.size())
    quit(1)
