extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("run_check")

func run_check() -> void:
    var bank = preload("res://src/ui/combat_sound_bank.gd")
    var cold_start := Time.get_ticks_usec()
    for cue in bank.CUES:
        check(bank.get_stream(cue).data.size() > 0, "every cue has PCM")
    var cold_us := Time.get_ticks_usec() - cold_start
    var warm_start := Time.get_ticks_usec()
    for repeat in range(100):
        for cue in bank.CUES:
            bank.get_stream(cue)
    print("SOUND_CACHE_MEASUREMENT cold_9_cues_us=%d warm_900_lookups_us=%d" % [cold_us, Time.get_ticks_usec() - warm_start])
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    await process_frame
    await process_frame
    var background = board.battle_background
    check(background.texture.resource_path == "res://assets/backgrounds/atlas_blue_ink_courtyard_v1.png", "combat must consume atlas successor")
    check(background.modulate == Color.WHITE, "do not tint blue source back to sepia")
    check(not board.duel_foreground_banner.visible, "legacy sepia foreground must not cover atlas courtyard")
    var status = board.top_hud.player_panel
    check(status.get_node("StatusHudFrame").show_behind_parent, "resource fill must render above authored frame")
    check(not status.get_node("StatusHudFrame").visible, "retire duplicated baked bar wells in live status UI")
    check(not status.get_node("CombatantInkPortrait").visible, "status reserves space for resources instead of portrait")
    check(board.top_hud.enemy_panel.call("get_visible_resource_ratio", "health") == -1.0, "hidden enemy resources must not leak through bar length")
    check(status.call("get_visible_resource_ratio", "health") == 1.0, "player bar shows actual fraction")
    status.size = Vector2(340.0, 128.0)
    status.configure("player", {"name": "검증", "health": [30,30], "stamina": [5,5], "internal": [4,4], "statuses": [{"label": "방", "kind": "defense"}, {"label": "강", "kind": "fortitude"}]})
    for chip in status._status_labels:
        check(not Rect2(chip.position, chip.size).intersects(status.call("get_momentum_rect")), "720p status and momentum must not overlap")
    board.call("_play_procedural_sfx", "metal_clash")
    var first = board.procedural_sfx_player.stream
    board.call("_play_procedural_sfx", "metal_clash")
    check(first == board.procedural_sfx_player.stream, "repeated sounds reuse cached stream")
    board.call("_play_procedural_sfx", "momentum_charge")
    check(first == board.procedural_sfx_player.stream, "momentum reward must not replace clash audio")
    board.call("_play_procedural_sfx", "evade")
    check(first.data != board.procedural_sfx_player.stream.data, "evade differs from clash")
    board.call("_toggle_sound")
    board.call("_play_procedural_sfx", "heavy_hit")
    check(not board.procedural_sfx_player.playing, "mute prevents sound")
    board.queue_free()
    await process_frame
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    check(shell.get_node("ShellBackdrop") is TextureRect, "noncombat screens share atlas artwork")
    shell.queue_free()
    await process_frame
    await create_timer(0.1).timeout
    for failure in failures:
        printerr(failure)
    if failures.is_empty():
        print("ATLAS_PRESENTATION_SUCCESSOR_OK")
    quit(0 if failures.is_empty() else 1)

func check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
