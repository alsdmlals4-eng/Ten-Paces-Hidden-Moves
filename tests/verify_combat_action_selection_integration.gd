extends SceneTree

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var combat_scene := load("res://scenes/combat/combat_board_preview.tscn")
    _expect(combat_scene != null, "Combat scene loads")
    var combat = combat_scene.instantiate()
    get_root().add_child(combat)
    await process_frame
    await process_frame

    _expect(is_instance_valid(combat.action_selection_dock), "Product action dock exists")
    _expect(combat.action_selection_dock.get_dock_snapshot().get("active_source", "") == "basic", "Basic source starts active")
    _expect(combat.basic_card_tray.visible == false, "Legacy basic tray stays hidden")
    _expect(combat.ultimate_list_panel.visible == false, "Legacy ultimate list stays hidden")
    _expect(combat.card_detail_panel.visible == false, "Legacy detail panel stays hidden")

    combat.action_timing_panel.clear_current_bundle()
    combat.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
    await process_frame
    _expect(not combat.action_timing_panel.get_placement(1).is_empty(), "Basic card places")
    _expect(str((combat.action_timing_panel.get_placement(1).get("definition", {}) as Dictionary).get("id", "")) == "basic_guard", "Placed card identity is preserved")

    combat._on_timing_slot_clicked(1)
    await process_frame
    combat.action_selection_dock.set_active_source("martial")
    _expect(combat.action_selection_dock.martial_panel.select_manual("shaolin_arhat_vajra_art"), "Martial manual selects")
    _expect(combat.action_selection_dock.martial_panel.activate_technique("shaolin_arhat_vajra_art_star3"), "Martial technique activates")
    await process_frame
    _expect(not combat.action_timing_panel.get_placement(1).is_empty(), "Martial card places")
    _expect(str((combat.action_timing_panel.get_placement(1).get("definition", {}) as Dictionary).get("source_kind", "")) == "martial", "Martial source is preserved")
    _expect(str((combat.action_timing_panel.get_placement(1).get("definition", {}) as Dictionary).get("faction", "")) == "소림사", "Martial faction is preserved")

    combat._on_timing_slot_clicked(1)
    await process_frame
    _set_player_momentum(combat, 4, 5)
    combat._sync_action_selection_dock()
    var locked_ultimate: Dictionary = combat.action_selection_dock.ultimate_panel.get_action("ultimate_ten_paces_wave")
    _expect(bool(locked_ultimate.get("locked", false)), "Ultimate remains locked below exact momentum")

    _set_player_momentum(combat, 5, 5)
    combat._sync_action_selection_dock()
    combat.action_selection_dock.set_active_source("ultimate")
    _expect(combat.action_selection_dock.ultimate_panel.activate_ultimate("ultimate_ten_paces_wave"), "Ultimate activates at exact momentum")
    await process_frame
    _expect(combat._ultimate_reservation_anchors.size() == 1, "Ultimate reserves one anchor")
    _expect(combat.action_selection_dock.get_dock_snapshot().get("switching_enabled", true) == false, "Reservation locks source switching")

    combat._on_timing_slot_clicked(1)
    await process_frame
    combat.action_selection_dock.set_active_source("martial")
    combat._set_presentation_state("resolving")
    _expect(combat.action_selection_dock.get_dock_snapshot().get("switching_enabled", true) == false, "Resolving locks source switching")
    combat._set_presentation_state("next_bundle_ready")
    _expect(combat.action_selection_dock.get_dock_snapshot().get("active_source", "") == "martial", "Automatic next bundle retains selected source")
    _expect(combat.action_selection_dock.get_dock_snapshot().get("switching_enabled", false), "Automatic next bundle unlocks switching")

    combat.restart_combat()
    await process_frame
    _expect(combat.action_selection_dock.get_dock_snapshot().get("active_source", "") == "basic", "Restart restores basic source")

    if failures.is_empty():
        print("verify_combat_action_selection_integration: PASS")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)

func _set_player_momentum(combat, current: int, maximum: int) -> void:
    var player: Dictionary = (combat.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [current, maximum]
    combat.combat_state["player"] = player

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
