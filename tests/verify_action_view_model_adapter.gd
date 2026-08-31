extends SceneTree

const MANUAL_LOADOUT := [
    "mount_hua_plum_blossom_sword",
    "sichuan_tang_hidden_weapons",
    "yang_family_spear",
    "shaolin_arhat_vajra_art"
]

const MANUAL_MASTERY := {
    "mount_hua_plum_blossom_sword": 5,
    "sichuan_tang_hidden_weapons": 10,
    "yang_family_spear": 5,
    "shaolin_arhat_vajra_art": 5
}

func _init() -> void:
    var adapter_script := load("res://src/ui/action_selection/action_view_model_adapter.gd")
    assert(adapter_script != null)
    var adapter = adapter_script.new()

    var basics: Array = adapter.build_basic_actions()
    assert(basics.size() == 10)
    assert(str((basics[0] as Dictionary).get("source_kind", "")) == "basic")
    for action_value in basics:
        var action: Dictionary = action_value
        var expected_targeting := "move_intent" if str(action.get("category", "")) == "move" else "none"
        assert(str(action.get("targeting_mode", "")) == expected_targeting)

    assert(adapter.build_owned_manuals().is_empty())
    var manuals: Array = adapter.build_owned_manuals(MANUAL_LOADOUT, MANUAL_MASTERY)
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
            assert(technique.has("illustration"))
            var expected_targeting := "move_intent" if str(technique.get("category", "")) == "move" else "none"
            assert(str(technique.get("targeting_mode", "")) == expected_targeting)

    var locked_ultimates: Array = adapter.build_ultimate_actions(4, MANUAL_LOADOUT, MANUAL_MASTERY)
    assert(locked_ultimates.all(func(value): return bool((value as Dictionary).get("locked", false))))

    var ready_ultimates: Array = adapter.build_ultimate_actions(5, MANUAL_LOADOUT, MANUAL_MASTERY)
    assert(ready_ultimates.any(func(value): return not bool((value as Dictionary).get("locked", true))))
    assert(ready_ultimates.all(func(value): return (value as Dictionary).has("illustration")))
    assert(ready_ultimates.all(func(value): return str((value as Dictionary).get("targeting_mode", "")) == "none"))

    print("verify_action_view_model_adapter: PASS")
    quit(0)
