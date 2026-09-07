extends SceneTree

const ADAPTER_SCRIPT := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
const HUA := "mount_hua_plum_blossom_sword"
const TANG := "sichuan_tang_hidden_weapons"
const HUA_STAR3 := "mount_hua_plum_blossom_sword_star3"
const HUA_STAR7 := "mount_hua_plum_blossom_sword_star7"

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
    panel.set_manuals(ADAPTER_SCRIPT.new().build_owned_manuals([HUA, TANG], {HUA: 5, TANG: 10}))
    await process_frame

    var snapshot: Dictionary = panel.get_panel_snapshot()
    assert(int(snapshot.get("manual_count", 0)) == 2)
    assert(str(snapshot.get("selected_manual_id", "")) == HUA)
    assert(snapshot.get("manual_ids", []) == [HUA, TANG])
    assert(int(snapshot.get("unlocked_technique_count", 0)) == 1)
    assert(int(snapshot.get("locked_technique_count", 0)) == 1)
    assert(snapshot.get("card_surface", "") == "shared_action_card_grid")
    assert(snapshot.get("illustration_policy", "") == "semantic_atlas")
    assert(int(snapshot.get("technique_columns", 0)) == 5)

    assert(panel.manual_buttons.size() == 2)
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
    assert(is_instance_valid(unlocked_button.find_child("CardIllustration", false, false)))
    assert(is_instance_valid(locked_button.find_child("CardIllustration", false, false)))
    assert(not unlocked_button.disabled)
    assert(locked_button.disabled)
    assert(locked_button.focus_mode == Control.FOCUS_ALL)
    assert(locked_button.find_child("CardStatus", false, false) == null)
    assert(locked_button.accessibility_name.contains("7성 해금 · 현재 5성"))

    panel.technique_selected.connect(_on_technique_selected)

    panel.manual_buttons[1].emit_signal("pressed")
    await process_frame
    assert(selected_count == 0)
    assert(panel.get_selected_manual_id() == TANG)

    assert(panel.select_manual(HUA))
    await process_frame
    assert(panel.activate_technique(HUA_STAR7) == false)
    assert(selected_count == 0)
    assert(panel.activate_technique(HUA_STAR3))
    assert(selected_count == 1)
    assert(selected_id == HUA_STAR3)

    print("verify_martial_action_panel: PASS")
    quit(0)

func _on_technique_selected(definition: Dictionary) -> void:
    selected_count += 1
    selected_id = str(definition.get("id", ""))
