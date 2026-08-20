extends SceneTree

const SHELL_SCENE_PATH := "res://scenes/run/vertical_slice_shell.tscn"
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
    _expect_true(shell.content_panel.visible, "MAIN must show the non-combat content panel.")
    _expect_false(shell.combat_host.visible, "MAIN must not show CombatBoardPreview.")
    _expect_true(bool(shell.get_meta("technical_shell", false)), "Phase-I shell must identify itself as a technical shell.")
    _expect_true(bool(shell.get_meta("final_visual_reference_pending", false)), "Shell must preserve the pending final visual-reference ceiling.")

    _expect_true(shell.start_new_run(), "Shell must start a new run.")
    _expect_eq(shell.run_state.get_current_screen(), "SETUP", "New run must enter SETUP.")
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
        _expect_eq(shell.combat_host.get_child(0).name, "CombatBoardPreview", "Shell must host the existing CombatBoardPreview scene.")

    _expect_true(shell.complete_combat_for_runtime({"outcome": "win", "duel_index": 1}), "Runtime combat completion must enter REVIEW.")
    _expect_eq(shell.run_state.get_current_screen(), "REVIEW", "Terminal combat must enter REVIEW before RESULT.")
    _expect_true(shell.combat_host.visible, "Combat Review must remain an overlay on the combat screen.")
    _expect_false(shell.content_panel.visible, "Combat Review must not become a separate non-combat screen.")

    _expect_true(shell.complete_review_for_runtime(), "Runtime review completion must enter RESULT.")
    _expect_eq(shell.run_state.get_current_screen(), "RESULT", "Review completion must enter separate RESULT state.")
    _expect_false(shell.combat_host.visible, "RESULT must leave the combat scene.")
    _expect_true(shell.content_panel.visible, "RESULT must use the non-combat shell panel.")

    _expect_true(shell.advance_noncombat(), "RESULT must advance to Growth/Recovery Route.")
    _expect_eq(shell.run_state.get_current_screen(), "ROUTE_GROWTH", "First Route state must be Growth/Recovery.")
    _expect_true(shell.advance_noncombat(), "Growth/Recovery must advance to Info/Preparation.")
    _expect_eq(shell.run_state.get_current_screen(), "ROUTE_INFO", "Second Route state must be Info/Preparation.")
    _expect_true(shell.advance_noncombat(), "Info/Preparation must advance to the next Briefing.")
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
