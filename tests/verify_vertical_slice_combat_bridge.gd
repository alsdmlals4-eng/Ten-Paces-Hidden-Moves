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

    _expect_true(shell.start_new_run(), "Shell must start a new run.")
    for manual_id in DEFAULT_STARTERS:
        _expect_true(shell.toggle_setup_manual(manual_id), "Default starter selection must succeed: %s" % manual_id)
    _expect_true(shell.advance_noncombat(), "SETUP → INTRO")
    _expect_true(shell.advance_noncombat(), "INTRO → BRIEFING")
    _expect_true(shell.advance_noncombat(), "BRIEFING → COMBAT")
    for _index in range(4):
        await process_frame

    var bridge = shell.combat_host.get_child(0)
    var duel_one_instance_id: int = int(bridge.get_instance_id())
    _expect_true(bool(bridge.get_meta("vertical_slice_bridge", false)), "Combat view must identify the Vertical Slice bridge.")
    _expect_true(bool(bridge.get_meta("vertical_slice_run_resources_bound", false)), "Bridge must support run-resource persistence.")

    var state: Dictionary = bridge.get("combat_state")
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    var enemy: Dictionary = (state.get("enemy", {}) as Dictionary).duplicate(true)
    player["health"] = [10, 30]
    player["stamina"] = [2, 5]
    player["internal"] = [1, 4]
    enemy["health"] = [0, 30]
    state["player"] = player
    state["enemy"] = enemy
    bridge.set("combat_state", state)
    bridge.set("_last_review_summary", {"headline": "테스트 복기", "decisive_facts": ["enemy_health_zero"]})
    bridge.call("_show_review_panel", true)
    await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "REVIEW", "Terminal review must enter REVIEW.")
    _expect_eq((shell.run_state.last_combat_result.get("player_resources", {}) as Dictionary).get("stamina", []), [2, 5], "Terminal bridge must carry player stamina pair.")
    bridge.call("_on_review_continue_requested")
    await process_frame
    _expect_eq(shell.run_state.get_current_screen(), "RESULT", "Terminal Review continue must enter RESULT.")

    _expect_true(shell.select_result_reward("free_training"), "Result reward must be selected.")
    _expect_true(shell.advance_noncombat(), "RESULT → Growth Route")
    _expect_true(shell.select_growth_route("recovery"), "Recovery Route must be selectable.")
    _expect_true(shell.advance_noncombat(), "Growth Route → Info Route")
    var info_options: Array = shell.run_state.get_info_route_options()
    _expect_eq(info_options.size(), 3, "Info Route must expose three options.")
    if info_options.size() == 3:
        _expect_true(shell.select_info_route(str((info_options[0] as Dictionary).get("category", ""))), "One Info Route option must be selected.")
    _expect_true(shell.advance_noncombat(), "Info Route → Duel 2 Briefing")
    _expect_true(shell.advance_noncombat(), "Duel 2 Briefing → Combat")
    for _index in range(4):
        await process_frame

    _expect_eq(shell.run_state.duel_index, 2, "The new combat instance must belong to Duel 2.")
    _expect_eq(shell.combat_host.get_child_count(), 1, "Next duel must host exactly one combat instance.")
    if shell.combat_host.get_child_count() == 1:
        var duel_two_bridge = shell.combat_host.get_child(0)
        _expect_true(duel_two_bridge.get_instance_id() != duel_one_instance_id, "Duel 2 must not reuse Duel 1 instance.")
        _expect_true(bool(duel_two_bridge.get_meta("vertical_slice_runtime_loadout_bound", false)), "Duel 2 must rebind locked opponent loadout.")
        var resources := duel_two_bridge.call("get_vertical_slice_player_resources") as Dictionary
        _expect_eq(resources.get("health", []), [18, 30], "Recovery must persist 25% max HP rounded to nearest integer: +8 on max 30.")
        _expect_eq(resources.get("stamina", []), [3, 5], "Recovered stamina must persist into Duel 2.")
        _expect_eq(resources.get("internal", []), [2, 4], "Recovered internal must persist into Duel 2.")

    shell.queue_free()
    await process_frame
    _finish()

func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)

func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])

func _finish() -> void:
    if failures.is_empty():
        print("VERTICAL_SLICE_COMBAT_BRIDGE_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_COMBAT_BRIDGE_VERIFY_FAILED count=%d" % failures.size())
    quit(1)