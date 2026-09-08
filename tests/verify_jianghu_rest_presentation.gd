extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    shell.start_new_run()
    for manual in ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]:
        shell.toggle_setup_manual(manual)
    for step in range(3):
        shell.advance_noncombat()
    # Terminal injection is a UI fixture, not evidence of a won duel.
    shell.complete_combat_for_runtime({
        "outcome": "win",
        "player_resources": {"health": [12, 40], "stamina": [2, 5], "internal": [1, 4]}
    })
    shell.complete_review_for_runtime()
    shell.select_result_reward("free_training")
    shell.advance_noncombat()
    for step in range(2):
        var options: Array = shell.run_state.get_jianghu_options()
        shell._choose_jianghu(str(options[0]["id"]), step)
        shell.advance_noncombat()
    var before_rest: Dictionary = shell.run_state.get_player_run_resources()
    check(before_rest == {"health": [12, 40], "stamina": [2, 5], "internal": [1, 4]}, "Rest fixture must reach the inn with damaged valid resources.")
    shell._choose_jianghu("rest", 2)
    await process_frame
    var backdrop = shell.get_node("ShellBackdrop")
    check(backdrop.texture.resource_path == "res://assets/backgrounds/jianghu_rest_inn_v1.png", "Rest must consume the original inn illustration.")
    check(shell.content_panel.anchor_left >= 0.5, "Rest text must leave the seated traveller visible.")
    check(not shell.route_options_container.visible, "Resolved rest must not retain disabled choice cards.")
    check(not shell.primary_button.disabled, "Rest must expose a working continuation.")
    var resources: Dictionary = shell.run_state.get_player_run_resources()
    check(resources == {"health": [22, 40], "stamina": [3, 5], "internal": [2, 4]}, "One rest must heal 25% max health and restore one stamina and internal power exactly once.")
    check(resources["health"][0] < resources["health"][1], "Rest fixture health must remain below cap before duplicate input.")
    check(resources["stamina"][0] < resources["stamina"][1], "Rest fixture stamina must remain below cap before duplicate input.")
    check(resources["internal"][0] < resources["internal"][1], "Rest fixture internal power must remain below cap before duplicate input.")
    shell._choose_jianghu("rest", 2)
    check(shell.run_state.get_player_run_resources() == resources, "Duplicate rest must not heal again.")
    shell.advance_noncombat()
    await process_frame
    check(backdrop.texture.resource_path == "res://assets/backgrounds/atlas_blue_ink_courtyard_v1.png", "Next choice must restore the route backdrop.")
    check(is_equal_approx(shell.content_panel.anchor_left, 0.14), "Next choice must restore the full choice layout.")
    check(shell.route_options_container.visible and shell.get_route_option_count() == 3, "Next step must expose three choices.")
    shell.queue_free()
    await process_frame
    await create_timer(0.1).timeout
    for failure in failures:
        push_error(failure)
    print("JIANGHU_REST_PRESENTATION_OK" if failures.is_empty() else "JIANGHU_REST_PRESENTATION_FAILED")
    quit(0 if failures.is_empty() else 1)

func check(value: bool, message: String) -> void:
    if not value:
        failures.append(message)
