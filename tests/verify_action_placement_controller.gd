extends SceneTree

var allow_ultimate := true
var reserve_count := 0
var refund_count := 0
var targeting_count := 0
var last_failure_code := ""
var success_count := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var timing_scene := load("res://scenes/ui/action_timing_panel.tscn")
    var controller_script := load("res://src/ui/action_selection/action_placement_controller.gd")
    assert(timing_scene != null)
    assert(controller_script != null)

    var panel = timing_scene.instantiate()
    get_root().add_child(panel)
    await process_frame

    var controller = controller_script.new()
    controller.configure(
        panel,
        Callable(self, "_can_reserve"),
        Callable(self, "_reserve"),
        Callable(self, "_refund"),
        Callable(self, "_begin_targeting")
    )
    controller.placement_failed.connect(_on_failed)
    controller.placement_succeeded.connect(_on_succeeded)

    var one_slot := {
        "id": "basic_guard",
        "name": "막기",
        "source_kind": "basic",
        "category": "response",
        "action_slots": 1
    }
    assert(controller.select_and_place(one_slot))
    assert(success_count == 1)
    assert(panel.has_assignment_at(1))

    panel.clear_current_bundle()
    var two_slot := {
        "id": "technique_flowing_cloud_threefold",
        "name": "유운삼첩",
        "source_kind": "martial",
        "category": "attack",
        "action_slots": 2,
        "targeting_mode": "none"
    }
    assert(controller.select_and_place(two_slot))
    assert(panel.has_assignment_at(1))
    assert(panel.has_assignment_at(2))
    assert(targeting_count == 0)

    panel.clear_current_bundle()
    controller.set_targeting_in_progress(false)
    allow_ultimate = false
    var three_slot_ultimate := {
        "id": "ultimate_void_sword_qi",
        "name": "파공검기",
        "source_kind": "ultimate",
        "category": "attack",
        "action_slots": 3,
        "targeting_mode": "none"
    }
    assert(controller.select_and_place(three_slot_ultimate) == false)
    assert(last_failure_code == "MOMENTUM_INSUFFICIENT")
    assert(reserve_count == 0)

    allow_ultimate = true
    assert(controller.select_and_place(three_slot_ultimate))
    assert(reserve_count == 1)
    var removed: Dictionary = controller.remove_at(1)
    assert(not removed.is_empty())
    assert(refund_count == 1)

    controller.set_targeting_in_progress(false)
    panel.clear_current_bundle()
    assert(controller.select_and_place(three_slot_ultimate))
    assert(reserve_count == 2)
    controller.set_locked(true)
    assert(controller.remove_at(1).is_empty())
    assert(refund_count == 1)

    controller.set_locked(false)
    controller.set_targeting_in_progress(true)
    panel.clear_current_bundle()
    assert(controller.select_and_place(one_slot) == false)
    assert(last_failure_code == "TARGETING_IN_PROGRESS")

    controller.set_targeting_in_progress(false)
    assert(controller.select_and_place(one_slot))
    assert(controller.select_and_place(one_slot))
    assert(controller.select_and_place(one_slot))
    assert(controller.select_and_place(two_slot) == false)
    assert(last_failure_code == "NO_CONTIGUOUS_TIMINGS")

    print("verify_action_placement_controller: PASS")
    quit(0)

func _can_reserve(_definition: Dictionary) -> bool:
    return allow_ultimate

func _reserve(_anchor_index: int) -> void:
    reserve_count += 1

func _refund(_placement: Dictionary) -> void:
    refund_count += 1

func _begin_targeting(_anchor_index: int) -> bool:
    targeting_count += 1
    return true

func _on_failed(code: String, _message: String) -> void:
    last_failure_code = code

func _on_succeeded(_result: Dictionary) -> void:
    success_count += 1
