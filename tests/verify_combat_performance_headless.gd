# 1440×900 전투 화면의 headless 성능 측정값을 출력한다. Windows GPU 기준선은 별도 수동 측정이 필요하다.
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
    print("PERFORMANCE_HEADLESS_BASELINE " + JSON.stringify(metrics))
    board.queue_free()
    await process_frame
    quit(0)
