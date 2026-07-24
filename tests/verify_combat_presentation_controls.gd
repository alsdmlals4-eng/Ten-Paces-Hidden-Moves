# 전투 연출의 즉시 완료 버튼이 진행 중인 절초 대기를 즉시 취소하는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const SKIP_BUDGET_SECONDS := 0.25

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Presentation controls require the combat board scene.")
        _finish()
        return
    var board := packed.instantiate() as CombatBoardPreview
    root.add_child(board)
    for _index in range(4):
        await process_frame
    board._sound_muted = true

    board.remove_meta("presentation_event_count")
    var started_usec := Time.get_ticks_usec()
    board.call_deferred("_present_authoritative_events", [{
        "type": "action_result",
        "card_id": "ultimate_void_sword_qi",
        "card_name": "파공검기",
        "actor": "player",
        "outcome": "hit",
        "damage": 34
    }], 1)
    await process_frame
    await create_timer(0.05).timeout
    board._skip_presentation()
    for _index in range(20):
        if board.has_meta("presentation_event_count"):
            break
        await create_timer(0.05).timeout
    var elapsed_seconds := float(Time.get_ticks_usec() - started_usec) / 1000000.0
    if not board.has_meta("presentation_event_count"):
        failures.append("Skip playback did not finish within the test timeout.")
    if elapsed_seconds >= SKIP_BUDGET_SECONDS:
        failures.append("Skip must cancel an active ultimate wait immediately. elapsed=%.3fs" % elapsed_seconds)
    if not bool(board.get_meta("presentation_skipped", false)):
        failures.append("Skip must record that presentation was skipped.")
    if board.presentation_label.visible or board.presentation_vfx.visible:
        failures.append("Skip must hide active presentation text and VFX.")

    board.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_PRESENTATION_CONTROLS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_PRESENTATION_CONTROLS_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
