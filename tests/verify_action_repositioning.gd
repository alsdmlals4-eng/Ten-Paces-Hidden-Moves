extends SceneTree

var reserve_count := 0
var refund_count := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel_scene := load("res://scenes/ui/action_timing_panel.tscn")
    var controller_script := load("res://src/ui/action_selection/action_placement_controller.gd")
    assert(panel_scene != null)
    assert(controller_script != null)

    var panel = panel_scene.instantiate()
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
    assert(panel.place_card(two_slot, 2))
    assert(panel.can_move_placement(2, 1))
    assert(panel.move_placement(2, 1))
    assert(panel.get_placement(2).is_empty())
    assert(not panel.get_placement(1).is_empty())
    assert(panel.move_placement(1, 2))
    assert(not panel.get_placement(2).is_empty())

    var original_snapshot: Dictionary = panel.get_placement(2)
    assert(panel.can_move_placement(2, 3) == false)
    assert(panel.move_placement(2, 3) == false)
    assert(panel.get_placement(2) == original_snapshot)

    panel.clear_current_bundle()
    var blocker := {
        "id": "basic_guard",
        "name": "막기",
        "source_kind": "basic",
        "category": "response",
        "action_slots": 1
    }
    assert(panel.place_card(blocker, 1))
    assert(panel.place_card(two_slot, 2))
    var collision_snapshot: Dictionary = panel.get_placement(2)
    assert(panel.can_move_placement(2, 1) == false)
    assert(panel.move_placement(2, 1) == false)
    assert(panel.get_placement(2) == collision_snapshot)

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
    assert(controller.select_and_place(ultimate))
    assert(reserve_count == 1)
    assert(controller.move_placement(1, 2))
    assert(refund_count == 1)
    assert(reserve_count == 2)
    assert(not panel.get_placement(2).is_empty())
    assert(bool((panel.get_placement(2).get("definition", {}) as Dictionary).get("source_kind", "") == "ultimate"))

    controller.set_targeting_in_progress(true, 2)
    assert(controller.move_placement(2, 1) == false)
    assert(not panel.get_placement(2).is_empty())

    controller.set_targeting_in_progress(false)
    controller.set_locked(true)
    assert(controller.move_placement(2, 1) == false)
    assert(not panel.get_placement(2).is_empty())

    controller.set_locked(false)
    var valid_anchors: PackedInt32Array = panel.get_valid_move_anchors(2)
    assert(1 in valid_anchors)
    assert(3 not in valid_anchors)

    print("verify_action_repositioning: PASS")
    quit(0)

func _can_reserve(_definition: Dictionary) -> bool:
    return true

func _reserve(_anchor_index: int) -> void:
    reserve_count += 1

func _refund(_placement: Dictionary) -> void:
    refund_count += 1

func _begin_targeting(_anchor_index: int) -> bool:
    return false
