extends SceneTree
func _initialize():
    create_timer(90.0).timeout.connect(func(): printerr("verify_variable_enemy_information TIMEOUT"); quit(1))
    var engine = load("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd").new()
    engine.set("variable_opponent_rules", true)
    var ids = ["sichuan_tang_hidden_weapons"]
    var mastery = {"sichuan_tang_hidden_weapons": 5}
    assert(engine.configure_martial_loadouts(ids, mastery, ids, mastery))
    var forbidden := ""
    for id in engine.get_player_martial_card_ids():
        var definition: Dictionary = engine.get_actor_card_definition(id, "player")
        for step in definition.effect_steps:
            if step.get("status") == "observation": forbidden = id
    assert(not forbidden.is_empty())
    assert(engine.get_actor_card_definition(forbidden, "enemy").is_empty(), "Enemy observation card must be unavailable, not rewritten")
    assert(not engine.get_actor_cards_by_id("enemy").has(forbidden))
    print("VARIABLE_ENEMY_INFORMATION_BOUNDARY_PASS")
    quit()
