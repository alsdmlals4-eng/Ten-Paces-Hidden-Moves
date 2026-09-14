extends SceneTree

const POSES := preload("res://src/combat/character_pose_library.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    for i in range(6):
        await process_frame
    var missing := 0
    for entry in [[POSES.PLAYER_PATH, 7], [POSES.ENEMY_PATH, 8], [POSES.PLAYER_REACTIONS, 4], [POSES.ENEMY_REACTIONS, 4]]:
        for index in range(entry[1]):
            if not POSES._source_frames.has("%s:%d" % [entry[0], index]):
                missing += 1
    board.free()
    if missing > 0:
        push_error("COMBAT_FRAME_CACHE_NOT_READY count=%d" % missing)
        quit(1)
        return
    print("POSE_CACHE_READY_PASS")
    quit(0)
