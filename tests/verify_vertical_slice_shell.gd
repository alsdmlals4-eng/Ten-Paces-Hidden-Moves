extends SceneTree

const SHELL_SCENE_PATH := "res://scenes/run/vertical_slice_shell.tscn"
const TITLE_LOGO_PATH := "res://assets/ui/logo/ten_paces_hidden_moves_title_logo_01_v1.png"
const DEFAULT_STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var packed := load(SHELL_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Vertical Slice shell scene is missing: %s" % SHELL_SCENE_PATH)
        _finish()
        return

    var shell = packed.instantiate()
    root.add_child(shell)
    if shell is Control:
        shell.set_anchors_preset(Control.PRESET_TOP_LEFT)
        shell.size = Vector2(1440.0, 900.0)
    for _index in range(4):
        await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "MAIN", "Shell must start at MAIN.")
    _expect_false(shell.content_panel.visible, "MAIN must reserve the non-combat content panel for setup and route screens, not the title surface.")
    _expect_false(shell.combat_host.visible, "MAIN must not show CombatBoardPreview.")
    _expect_false(bool(shell.get_meta("final_visual_reference_pending", true)), "Shell must record that the combat visual reference is approved.")
    var main_title_screen := shell.find_child("MainTitleScreen", true, false) as Control
    _expect_true(main_title_screen != null and main_title_screen.visible, "MAIN must render the player-facing title screen.")
    _expect_true(ResourceLoader.exists(TITLE_LOGO_PATH), "MAIN must ship the final-locked title logo as a runtime asset.")
    var title_logo := shell.find_child("GameTitleLogo", true, false) as TextureRect
    _expect_true(title_logo != null and title_logo.visible and title_logo.texture != null, "MAIN must render the final-locked game title logo.")
    if title_logo != null and title_logo.texture != null:
        _expect_eq(title_logo.texture.resource_path, TITLE_LOGO_PATH, "MAIN title logo must consume the final-locked runtime PNG.")
    var start_button := shell.find_child("MainStartButton", true, false) as Button
    _expect_true(start_button != null and not start_button.disabled, "MAIN must expose one enabled real start action.")
    _expect_false(shell.find_child("VisualReferenceStatus", true, false) != null, "MAIN must not expose technical visual-reference status copy to players.")

    if start_button != null:
        start_button.emit_signal("pressed")
        await process_frame
    _expect_eq(shell.run_state.get_current_screen(), "SETUP", "The visible MAIN start action must start a new run.")
    _select_default_setup(shell)
    _expect_true(shell.advance_noncombat(), "SETUP with four selected manuals must advance.")
    _expect_true(shell.advance_noncombat(), "INTRO must advance.")
    _expect_eq(shell.run_state.get_current_screen(), "BRIEFING", "Intro must lead to briefing.")
    _expect_true(shell.advance_noncombat(), "BRIEFING must enter COMBAT.")
    await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "COMBAT", "Shell must enter COMBAT.")
    _expect_false(shell.content_panel.visible, "COMBAT must hide the non-combat content panel.")
    _expect_true(shell.combat_host.visible, "COMBAT must show the combat host.")
    _expect_eq(shell.combat_host.get_child_count(), 1, "Combat host must reuse exactly one combat scene instance.")
    if shell.combat_host.get_child_count() == 1:
        var combat_view = shell.combat_host.get_child(0)
        _expect_eq(combat_view.name, "CombatBoardPreview", "Shell must host the existing CombatBoardPreview scene.")
        _expect_true(combat_view.action_timing_panel != null, "The fresh combat screen needs the current action bundle panel.")
        if combat_view.action_timing_panel != null:
            _expect_eq(combat_view.action_timing_panel.get_occupied_actionable_count(), 0, "A newly entered combat must not inherit pre-placed actions from an earlier attempt.")
            _expect_eq(combat_view.action_timing_panel.get_placement_list().size(), 0, "A newly entered combat must start with no persisted action placements.")

    _expect_true(shell.complete_combat_for_runtime({"outcome": "win", "duel_index": 1}), "Runtime combat completion must enter REVIEW.")
    _expect_eq(shell.run_state.get_current_screen(), "REVIEW", "Terminal combat must enter REVIEW before RESULT.")
    _expect_true(shell.combat_host.visible, "Combat Review must remain an overlay on the combat screen.")
    _expect_false(shell.content_panel.visible, "Combat Review must not become a separate non-combat screen.")

    _expect_true(shell.complete_review_for_runtime(), "Runtime review completion must enter RESULT.")
    _expect_eq(shell.run_state.get_current_screen(), "RESULT", "Review completion must enter separate RESULT state.")
    _expect_false(shell.combat_host.visible, "RESULT must leave the combat scene.")
    _expect_true(shell.content_panel.visible, "RESULT must use the non-combat shell panel.")
    _expect_false(shell.advance_noncombat(), "RESULT must wait for one reward choice.")
    _expect_true(shell.select_result_reward("free_training"), "A valid Result reward must be selectable.")

    _expect_true(shell.advance_noncombat(), "Reward-confirmed RESULT must advance to Growth/Recovery Route.")
    _expect_eq(shell.run_state.get_current_screen(), "ROUTE_GROWTH", "First Route state must be Growth/Recovery.")
    _expect_false(shell.advance_noncombat(), "Growth Route must wait for one explicit choice.")
    _expect_true(shell.select_growth_route("free_training"), "Shell regression must select one legal Growth Route choice.")
    _expect_true(shell.advance_noncombat(), "Confirmed Growth/Recovery must advance to Info/Preparation.")
    _expect_eq(shell.run_state.get_current_screen(), "ROUTE_INFO", "Second Route state must be Info/Preparation.")
    _expect_false(shell.advance_noncombat(), "Info Route must wait for one explicit clue category.")
    var info_options: Array = shell.run_state.get_info_route_options()
    _expect_eq(info_options.size(), 3, "Info Route must expose exactly three options.")
    if info_options.size() == 3:
        _expect_true(shell.select_info_route(str((info_options[0] as Dictionary).get("category", ""))), "Shell regression must select one legal Info Route category.")
    _expect_true(shell.advance_noncombat(), "Confirmed Info/Preparation must advance to the next Briefing.")
    _expect_eq(shell.run_state.get_current_screen(), "BRIEFING", "Two Route nodes must return to next Briefing.")
    _expect_eq(shell.run_state.duel_index, 2, "Shell flow must reach Duel 2 without recreating RunState.")

    shell.queue_free()
    await process_frame
    _finish()


func _select_default_setup(shell) -> void:
    for manual_id in DEFAULT_STARTERS:
        _expect_true(shell.toggle_setup_manual(manual_id), "Default starter selection must succeed: %s" % manual_id)


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_false(value: bool, message: String) -> void:
    if value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _finish() -> void:
    if failures.is_empty():
        print("VERTICAL_SLICE_SHELL_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_SHELL_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
