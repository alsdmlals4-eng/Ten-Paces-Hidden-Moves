extends SceneTree

const PANEL_SCENE := "res://scenes/ui/action_selection/basic_action_panel.tscn"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(PANEL_SCENE) as PackedScene
    assert(packed != null)
    var panel = packed.instantiate()
    root.add_child(panel)
    await process_frame

    var snapshot: Dictionary = panel.get_panel_snapshot()
    assert(int(snapshot.get("action_count", 0)) == 10)
    assert(int(snapshot.get("columns", 0)) == 5)
    assert(snapshot.get("action_ids", []) == [
        "basic_move",
        "basic_footwork",
        "basic_guard",
        "basic_evade",
        "basic_quick_attack",
        "basic_heavy_attack",
        "basic_observe",
        "basic_meditate",
        "basic_stance",
        "basic_palm"
    ])
    assert(not bool(snapshot.get("scrolling_enabled", true)))
    assert(panel.buttons.size() == 10)
    assert(panel.buttons[0].custom_minimum_size.y <= 84.0)
    var illustration := panel.buttons[0].get_node_or_null("CardIllustration") as TextureRect
    assert(is_instance_valid(illustration))
    assert(illustration.offset_bottom - illustration.offset_top >= 30.0)

    panel.set_interaction_enabled(false)
    assert(not bool(panel.get_panel_snapshot().get("interaction_enabled", true)))
    panel.set_interaction_enabled(true)
    assert(bool(panel.get_panel_snapshot().get("interaction_enabled", false)))

    print("verify_basic_action_panel: PASS")
    quit(0)
