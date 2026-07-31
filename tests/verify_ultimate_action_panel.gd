extends SceneTree

var selected_count := 0
var selected_id := ""

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene := load("res://scenes/ui/action_selection/ultimate_action_panel.tscn")
    assert(scene != null)
    var panel = scene.instantiate()
    get_root().add_child(panel)
    await process_frame

    panel.set_momentum(4, 5)
    await process_frame
    var locked_snapshot: Dictionary = panel.get_panel_snapshot()
    assert(int(locked_snapshot.get("momentum_current", -1)) == 4)
    assert(int(locked_snapshot.get("momentum_maximum", -1)) == 5)
    assert(int(locked_snapshot.get("enabled_count", -1)) == 0)
    assert(int(locked_snapshot.get("action_count", 0)) >= 4)
    assert(panel.get_action("ultimate_ten_paces_wave").get("lock_reason", "") == "기세 4/5")

    panel.set_momentum(5, 5)
    await process_frame
    var ready_snapshot: Dictionary = panel.get_panel_snapshot()
    assert(int(ready_snapshot.get("enabled_count", 0)) == 3)
    assert(not bool(panel.get_action("ultimate_ten_paces_wave").get("locked", true)))
    assert(bool(panel.get_action("ultimate_flowing_cloud_true_intent").get("locked", false)))
    assert(panel.get_action("ultimate_flowing_cloud_true_intent").get("lock_reason", "") == "10성 해금 · 현재 3성")

    panel.set_reservations([
        {
            "action_id": "ultimate_cleave_peak",
            "start_timing": 5,
            "end_timing": 6
        }
    ])
    await process_frame
    var reserved_button: Button = panel.get_action_button("ultimate_cleave_peak")
    assert(is_instance_valid(reserved_button))
    assert("5~6수 예약" in reserved_button.text)

    panel.ultimate_selected.connect(_on_ultimate_selected)
    assert(panel.activate_ultimate("ultimate_flowing_cloud_true_intent") == false)
    assert(selected_count == 0)
    assert(panel.activate_ultimate("ultimate_ten_paces_wave"))
    assert(selected_count == 1)
    assert(selected_id == "ultimate_ten_paces_wave")

    print("verify_ultimate_action_panel: PASS")
    quit(0)

func _on_ultimate_selected(definition: Dictionary) -> void:
    selected_count += 1
    selected_id = str(definition.get("id", ""))
