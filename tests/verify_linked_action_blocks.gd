extends SceneTree

var activated_anchor := 0

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel_scene := load("res://scenes/ui/action_timing_panel.tscn")
    assert(panel_scene != null)
    var panel = panel_scene.instantiate()
    get_root().add_child(panel)
    await process_frame

    panel.slot_clicked.connect(_on_slot_clicked)

    var one_slot := {
        "id": "basic_guard",
        "name": "막기",
        "source_kind": "basic",
        "source_label": "기초",
        "category": "response",
        "action_slots": 1
    }
    assert(panel.place_card(one_slot, 1))
    await process_frame
    _assert_single_block(panel, "basic_guard", 1, 0, ["실행"])
    assert("막기" not in panel.get_slot(1).get_assignment_display_text())
    panel.get_linked_block(1).activate()
    assert(activated_anchor == 1)

    panel.clear_current_bundle()
    await process_frame

    var two_slot := {
        "id": "technique_flowing_cloud_threefold",
        "name": "유운삼첩",
        "source_kind": "martial",
        "source_label": "유운검결",
        "category": "attack",
        "action_slots": 2,
        "targeting_mode": "attack_direction"
    }
    assert(panel.place_card(two_slot, 1))
    await process_frame
    _assert_single_block(panel, "technique_flowing_cloud_threefold", 2, 1, ["전조", "실행"])
    assert("유운삼첩" not in panel.get_slot(1).get_assignment_display_text())
    assert("유운삼첩" not in panel.get_slot(2).get_assignment_display_text())
    assert(panel.get_slot(1).get_stage_label() == "전조")
    assert(panel.get_slot(2).get_stage_label() == "실행")

    panel.clear_current_bundle()
    await process_frame

    var three_slot := {
        "id": "ultimate_void_sword_qi",
        "name": "파공검기",
        "source_kind": "ultimate",
        "source_label": "기본 절초",
        "category": "attack",
        "action_slots": 3,
        "targeting_mode": "attack_direction"
    }
    assert(panel.place_card(three_slot, 1))
    await process_frame
    _assert_single_block(panel, "ultimate_void_sword_qi", 3, 2, ["전조", "전조", "실행"])
    assert(panel.get_slot(1).get_stage_label() == "전조")
    assert(panel.get_slot(2).get_stage_label() == "전조")
    assert(panel.get_slot(3).get_stage_label() == "실행")

    print("verify_linked_action_blocks: PASS")
    quit(0)

func _assert_single_block(panel, action_id: String, span: int, telegraph_count: int, stages: Array) -> void:
    var snapshots: Array = panel.get_linked_block_snapshots()
    assert(snapshots.size() == 1)
    var snapshot: Dictionary = snapshots[0]
    assert(str(snapshot.get("action_id", "")) == action_id)
    assert(int(snapshot.get("anchor_index", 0)) == 1)
    assert(int(snapshot.get("span", 0)) == span)
    assert(int(snapshot.get("telegraph_count", -1)) == telegraph_count)
    assert(snapshot.get("stages", []) == stages)
    assert(is_instance_valid(panel.get_linked_block(1)))

func _on_slot_clicked(timing_index: int) -> void:
    activated_anchor = timing_index
