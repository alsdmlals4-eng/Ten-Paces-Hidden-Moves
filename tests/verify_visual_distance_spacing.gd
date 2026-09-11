extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
    root.add_child(board)
    await process_frame
    var previous := -1.0
    for distance in range(10):
        var pair: Dictionary = board._frontal_anchor_pair(1, 1 + distance, 400.0)
        var gap: float = pair.enemy.x - pair.player.x
        if gap <= previous + 1.0:
            push_error("DISTANCE_SPACING_SATURATES_AT_%d" % distance)
            board.free()
            quit(1)
            return
        previous = gap
    var close: Dictionary = board._frontal_anchor_pair(5, 5, 400.0)
    var far: Dictionary = board._frontal_anchor_pair(1, 10, 400.0)
    if far.enemy.x - far.player.x < (close.enemy.x - close.player.x) * 1.8:
        push_error("DISTANCE_CHANGE_NOT_LEGIBLE")
        board.free()
        quit(1)
        return
    board.free()
    print("VISUAL_DISTANCE_SPACING_PASS")
    quit(0)
