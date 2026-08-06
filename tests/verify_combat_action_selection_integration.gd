extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var combat_scene := load("res://scenes/combat/combat_board_preview.tscn")
    assert(combat_scene != null)
    var combat = combat_scene.instantiate()
    get_root().add_child(combat)
    await process_frame
    await process_frame

    assert(is_instance_valid(combat.action_selection_dock))
    assert(combat.action_selection_dock.get_dock_snapshot().get("active_source", "") == "basic")
    assert(combat.basic_card_tray.visible == false)
    assert(combat.ultimate_list_panel.visible == false)
    assert(combat.card_detail_panel.visible == false)

    combat.action_timing_panel.clear_current_bundle()
    combat.action_selection_dock.basic_panel.buttons[2].emit_signal("pressed")
    await process_frame
    assert(not combat.action_timing_panel.get_placement(1).is_empty())
    assert(str((combat.action_timing_panel.get_placement(1).get("definition", {}) as Dictionary).get("id", "")) == "basic_guard")

    combat._on_timing_slot_clicked(1)
    await process_frame
    combat.action_selection_dock.set_active_source("martial")
    assert(combat.action_selection_dock.martial_panel.select_manual("manual_vajra_body"))
    assert(combat.action_selection_dock.martial_panel.activate_technique("technique_vajra_guard"))
    await process_frame
    assert(not combat.action_timing_panel.get_placement(1).is_empty())
    assert(str((combat.action_timing_panel.get_placement(1).get("definition", {}) as Dictionary).get("source_kind", "")) == "martial")

    combat._on_timing_slot_clicked(1)
    await process_frame
    _set_player_momentum(combat, 4, 5)
    combat._sync_action_selection_dock()
    var locked_ultimate: Dictionary = combat.action_selection_dock.ultimate_panel.get_action("ultimate_ten_paces_wave")
    assert(bool(locked_ultimate.get("locked", false)))

    _set_player_momentum(combat, 5, 5)
    combat._sync_action_selection_dock()
    combat.action_selection_dock.set_active_source("ultimate")
    assert(combat.action_selection_dock.ultimate_panel.activate_ultimate("ultimate_ten_paces_wave"))
    await process_frame
    assert(combat._ultimate_reservation_anchors.size() == 1)
    assert(combat.action_selection_dock.get_dock_snapshot().get("switching_enabled", true) == false)

    combat._on_timing_slot_clicked(1)
    await process_frame
    combat.action_selection_dock.set_active_source("martial")
    combat._set_presentation_state("resolving")
    assert(combat.action_selection_dock.get_dock_snapshot().get("switching_enabled", true) == false)
    combat._set_presentation_state("review_ready")
    assert(combat.action_selection_dock.get_dock_snapshot().get("switching_enabled", true) == false)
    combat._set_presentation_state("next_bundle_ready")
    assert(combat.action_selection_dock.get_dock_snapshot().get("active_source", "") == "martial")
    assert(combat.action_selection_dock.get_dock_snapshot().get("switching_enabled", false))

    combat.restart_combat()
    await process_frame
    assert(combat.action_selection_dock.get_dock_snapshot().get("active_source", "") == "basic")

    print("verify_combat_action_selection_integration: PASS")
    quit(0)

func _set_player_momentum(combat, current: int, maximum: int) -> void:
    var player: Dictionary = (combat.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [current, maximum]
    combat.combat_state["player"] = player
