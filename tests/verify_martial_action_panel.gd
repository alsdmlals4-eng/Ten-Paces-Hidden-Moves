extends SceneTree

var selected_count := 0
var selected_id := ""

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene := load("res://scenes/ui/action_selection/martial_action_panel.tscn")
    assert(scene != null)
    var panel = scene.instantiate()
    get_root().add_child(panel)
    await process_frame

    var snapshot: Dictionary = panel.get_panel_snapshot()
    assert(int(snapshot.get("manual_count", 0)) == 4)
    assert(str(snapshot.get("selected_manual_id", "")) == "manual_flowing_cloud_sword")
    assert((snapshot.get("manual_ids", []) as Array).size() == 4)
    assert(int(snapshot.get("unlocked_technique_count", 0)) == 1)
    assert(int(snapshot.get("locked_technique_count", 0)) == 1)

    assert(panel.manual_buttons.size() == 4)
    assert(panel.technique_buttons.size() == 2)

    var unlocked_button: Button
    var locked_button: Button
    for button_value in panel.technique_buttons:
        var button := button_value as Button
        if bool(button.get_meta("locked", false)):
            locked_button = button
        else:
            unlocked_button = button

    assert(is_instance_valid(unlocked_button))
    assert(is_instance_valid(locked_button))
    assert(not unlocked_button.disabled)
    assert(locked_button.disabled)
    assert(locked_button.focus_mode == Control.FOCUS_ALL)
    assert(locked_button.text == "낙영추검 · 7성 해금 · 현재 3성")

    panel.technique_selected.connect(_on_technique_selected)

    panel.manual_buttons[1].emit_signal("pressed")
    await process_frame
    assert(selected_count == 0)
    assert(panel.get_selected_manual_id() == "manual_vajra_body")

    assert(panel.select_manual("manual_flowing_cloud_sword"))
    await process_frame
    assert(panel.activate_technique("technique_falling_shadow_pursuit") == false)
    assert(selected_count == 0)
    assert(panel.activate_technique("technique_flowing_cloud_threefold"))
    assert(selected_count == 1)
    assert(selected_id == "technique_flowing_cloud_threefold")

    print("verify_martial_action_panel: PASS")
    quit(0)

func _on_technique_selected(definition: Dictionary) -> void:
    selected_count += 1
    selected_id = str(definition.get("id", ""))
