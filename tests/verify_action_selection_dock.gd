extends SceneTree

const DOCK_SCENE := "res://scenes/ui/action_selection/action_selection_dock.tscn"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(DOCK_SCENE) as PackedScene
    assert(packed != null)
    var dock = packed.instantiate()
    root.add_child(dock)
    await process_frame

    var initial: Dictionary = dock.get_dock_snapshot()
    assert(initial.get("sources", []) == ["basic", "martial", "ultimate"])
    assert(str(initial.get("active_source", "")) == "basic")
    assert(bool(initial.get("switching_enabled", false)))

    dock.set_active_source("martial")
    assert(str(dock.get_dock_snapshot().get("active_source", "")) == "martial")

    dock.set_interaction_state("next_bundle_ready")
    assert(str(dock.get_dock_snapshot().get("active_source", "")) == "martial")
    assert(bool(dock.get_dock_snapshot().get("switching_enabled", false)))

    for locked_state in ["targeting", "committed", "resolving", "presenting_result", "review"]:
        dock.set_interaction_state(locked_state)
        var before := str(dock.get_dock_snapshot().get("active_source", ""))
        dock.set_active_source("ultimate")
        var snapshot: Dictionary = dock.get_dock_snapshot()
        assert(not bool(snapshot.get("switching_enabled", true)))
        assert(str(snapshot.get("active_source", "")) == before)

    dock.set_interaction_state("new_combat")
    var reset_snapshot: Dictionary = dock.get_dock_snapshot()
    assert(str(reset_snapshot.get("active_source", "")) == "basic")
    assert(bool(reset_snapshot.get("switching_enabled", false)))

    print("verify_action_selection_dock: PASS")
    quit(0)
