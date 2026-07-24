# 밀착·파공검기 VFX·긴 로그가 함께 열린 1440×900 전투 화면의 headless 성능 측정값을 출력한다. Windows GPU 기준선은 별도 수동 측정이 필요하다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const SAMPLE_FRAMES := 120

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    if packed == null:
        push_error("PERFORMANCE_HEADLESS_VERIFY_FAILED: board scene was not available.")
        quit(1)
        return
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    board._sound_muted = true
    var state := board.combat_state.duplicate(true)
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    var enemy: Dictionary = (state.get("enemy", {}) as Dictionary).duplicate(true)
    player["tile"] = 5
    enemy["tile"] = 5
    state["player"] = player
    state["enemy"] = enemy
    board.combat_state = state
    board._apply_combat_state_to_view()
    board.combat_log_panel.set_collapsed(false)
    for log_index in range(48):
        board.combat_log_panel.append_entry("[성능 표본 %d] 밀착 상태의 파공검기 판정과 긴 한국어 결과 문구를 기록합니다." % (log_index + 1), "resolution")
    board.presentation_label.text = "파공검기 · 피해 34 · 밀착 · 전투 불능 직전의 긴 결과 문구"
    board.presentation_label.visible = true
    board._show_ultimate_vfx({"card_id": "ultimate_void_sword_qi"})
    if board._player_tile != 5 or board._enemy_tile != 5 or not board.presentation_vfx.visible:
        push_error("PERFORMANCE_HEADLESS_VERIFY_FAILED: engagement ultimate scenario was not prepared.")
        board.queue_free()
        quit(1)
        return
    var started_usec := Time.get_ticks_usec()
    for _index in range(SAMPLE_FRAMES):
        await process_frame
    var elapsed_ms := float(Time.get_ticks_usec() - started_usec) / 1000.0
    var metrics := {
        "sample_frames": SAMPLE_FRAMES,
        "elapsed_ms": snappedf(elapsed_ms, 0.01),
        "avg_frame_ms": snappedf(elapsed_ms / float(SAMPLE_FRAMES), 0.01),
        "process_monitor": Performance.get_monitor(Performance.TIME_PROCESS),
        "physics_monitor": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
        "static_memory_bytes": Performance.get_monitor(Performance.MEMORY_STATIC),
        "object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
        "node_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
        "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
        "video_memory_bytes": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
    }
    metrics["scenario"] = "engagement_void_sword_qi_vfx_expanded_log"
    metrics["log_entries"] = board.combat_log_panel.entries.size()
    print("PERFORMANCE_HEADLESS_ENGAGEMENT_ULTIMATE_LOG " + JSON.stringify(metrics))
    board.queue_free()
    await process_frame
    quit(0)
