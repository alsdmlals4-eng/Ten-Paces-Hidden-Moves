extends SceneTree

const SHELL_SCENE_PATH := "res://scenes/run/vertical_slice_shell.tscn"

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
    _expect_true(shell.advance_noncombat(), "SETUP must advance to INTRO.")
    _expect_true(shell.advance_noncombat(), "INTRO must advance to BRIEFING.")
    _expect_true(shell.advance_noncombat(), "BRIEFING must advance to COMBAT.")
    for _index in range(4):
        await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "COMBAT", "Bridge test must begin in COMBAT.")
    _expect_eq(shell.combat_host.get_child_count(), 1, "Combat host must contain exactly one runtime combat view.")
    if shell.combat_host.get_child_count() != 1:
        shell.queue_free()
        await process_frame
        _finish()
        return

    var bridge = shell.combat_host.get_child(0)
    _expect_true(bool(bridge.get_meta("vertical_slice_bridge", false)), "Combat view must identify itself as the Vertical Slice bridge.")
    _expect_true(bridge.has_signal("terminal_review_ready"), "Bridge must expose terminal_review_ready.")
    _expect_true(bridge.has_signal("terminal_review_confirmed"), "Bridge must expose terminal_review_confirmed.")

    var state: Dictionary = bridge.get("combat_state")
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    var enemy: Dictionary = (state.get("enemy", {}) as Dictionary).duplicate(true)
    player["health"] = [10, 10]
    enemy["health"] = [0, 10]
    state["player"] = player
    state["enemy"] = enemy
    bridge.set("combat_state", state)
    bridge.set("_last_review_summary", {
        "headline": "테스트 복기",
        "decisive_facts": ["enemy_health_zero"]
    })

    bridge.call("_show_review_panel", true)
    await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "REVIEW", "Terminal combat review-ready event must advance RunState to REVIEW.")
    _expect_true(shell.combat_host.visible, "REVIEW must remain on the combat host.")
    _expect_false(shell.content_panel.visible, "REVIEW must not render the separate result panel yet.")
    _expect_eq(str(shell.run_state.last_combat_result.get("outcome", "")), "win", "Enemy health zero must map to a win result.")
    _expect_eq(int(shell.run_state.last_combat_result.get("duel_index", 0)), 1, "Shell must attach the current duel index to the terminal result.")
    _expect_true(bool(shell.run_state.last_combat_result.get("terminal", false)), "Runtime result must be explicitly terminal.")
    var review_summary = shell.run_state.last_combat_result.get("review_summary", {})
    _expect_true(typeof(review_summary) == TYPE_DICTIONARY, "Terminal result must retain the review summary as structured data.")
    if typeof(review_summary) == TYPE_DICTIONARY:
        _expect_eq(str((review_summary as Dictionary).get("headline", "")), "테스트 복기", "Review summary must survive the bridge.")

    bridge.call("_on_review_continue_requested")
    await process_frame

    _expect_eq(shell.run_state.get_current_screen(), "RESULT", "Terminal Review continue must advance to separate RESULT instead of restarting combat.")
    _expect_false(shell.combat_host.visible, "RESULT must leave the combat host.")
    _expect_true(shell.content_panel.visible, "RESULT must render the non-combat result shell.")
    _expect_eq(str(bridge.get_meta("presentation_state", "")), "review_ready", "Bridge confirmation must not restart/reset the terminal combat before Result consumes it.")
    var final_state: Dictionary = bridge.get("combat_state")
    var final_enemy: Dictionary = final_state.get("enemy", {})
    var final_enemy_health = final_enemy.get("health", [999, 999])
    _expect_eq(int((final_enemy_health as Array)[0]), 0, "Terminal confirmation must preserve the resolved combat state rather than restart it.")

    shell.queue_free()
    await process_frame
    _finish()


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
        print("VERTICAL_SLICE_COMBAT_BRIDGE_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_COMBAT_BRIDGE_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
