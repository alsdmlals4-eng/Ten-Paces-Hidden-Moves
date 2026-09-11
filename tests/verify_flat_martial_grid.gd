extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel = load("res://scenes/ui/action_selection/martial_action_panel.tscn").instantiate()
    root.add_child(panel)
    await process_frame
    var values: Array[Dictionary] = [
        {"manual_id":"one", "techniques":[{"id":"a", "name":"가", "locked":false}, {"id":"locked", "locked":true}]},
        {"manual_id":"two", "techniques":[{"id":"b", "name":"나", "locked":false}]}
    ]
    panel.set_manuals(values)
    var ids: Array = panel.get_panel_snapshot().technique_ids
    if ids != ["a", "b"] or panel.manual_scroll.visible:
        push_error("MARTIAL_GRID_MUST_SHOW_ALL_UNLOCKED_WITHOUT_MANUAL_SELECTOR")
        panel.free()
        quit(1)
        return
    if not panel.activate_technique("b") or panel.activate_technique("locked"):
        push_error("CROSS_MANUAL_ACTIVATION_OR_UNLOCK_GUARD_FAILED")
        panel.free()
        quit(1)
        return
    panel.set_constraint_lock_reasons({"b":"이번 비무 제약"})
    if panel.activate_technique("b"):
        push_error("CONSTRAINT_MUST_REMAIN_ENFORCED")
        panel.free()
        quit(1)
        return
    panel.free()
    print("FLAT_MARTIAL_GRID_PASS")
    quit(0)
