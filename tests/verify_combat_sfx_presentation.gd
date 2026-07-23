# 확정 상태와 방어 결과가 절차적 SFX 종류를 실제로 요청하는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame
    board._sound_muted = true

    var initial_player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    initial_player["momentum"] = [0, 5]
    board.combat_state["player"] = initial_player
    var next_state := board.combat_state.duplicate(true)
    var player: Dictionary = (next_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [1, 5]
    next_state["player"] = player
    await board._apply_timing_snapshot(next_state)
    if str(board.get_meta("last_sfx_kind", "")) != "momentum_charge":
        failures.append("An authoritative momentum increase must request momentum_charge SFX.")

    board._play_event_sfx({"defense_outcome": "block", "raw_damage": 20, "damage": 10})
    if str(board.get_meta("last_sfx_kind", "")) != "metal_clash":
        failures.append("A damaging block must request the metallic clash SFX.")

    board._play_event_sfx({"defense_outcome": "block", "raw_damage": 8, "damage": 0})
    if str(board.get_meta("last_sfx_kind", "")) != "block":
        failures.append("A fully stopped block must retain the separate block SFX.")

    board.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_SFX_PRESENTATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_SFX_PRESENTATION_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
