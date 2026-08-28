extends SceneTree

func _init() -> void:
    var adapter_script := load("res://src/ui/action_selection/action_view_model_adapter.gd")
    assert(adapter_script != null)
    var adapter = adapter_script.new()

    var basics: Array = adapter.build_basic_actions()
    assert(basics.size() == 10)
    assert(str((basics[0] as Dictionary).get("source_kind", "")) == "basic")

    var manuals: Array = adapter.build_owned_manuals()
    assert(manuals.size() == 4)
    for manual_value in manuals:
        var manual: Dictionary = manual_value
        assert(not str(manual.get("manual_id", "")).is_empty())
        assert((manual.get("techniques", []) as Array).size() >= 1)
        for technique_value in manual.get("techniques", []):
            var technique: Dictionary = technique_value
            assert(str(technique.get("source_kind", "")) == "martial")
            assert(str(technique.get("source_id", "")) == str(manual.get("manual_id", "")))
            assert(int(technique.get("telegraph_count", -1)) == maxi(0, int(technique.get("action_slots", 1)) - 1))
            assert(int(technique.get("execution_count", 0)) == 1)

    var locked_ultimates: Array = adapter.build_ultimate_actions(4)
    assert(locked_ultimates.all(func(value): return bool((value as Dictionary).get("locked", false))))

    var ready_ultimates: Array = adapter.build_ultimate_actions(5)
    assert(ready_ultimates.any(func(value): return not bool((value as Dictionary).get("locked", true))))

    print("verify_action_view_model_adapter: PASS")
    quit(0)
