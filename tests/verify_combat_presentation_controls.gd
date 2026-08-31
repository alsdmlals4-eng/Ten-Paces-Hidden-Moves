# 전투 연출의 즉시 완료 버튼이 진행 중인 절초 대기를 즉시 취소하는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

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
    # 건너뛰기는 현재 프레임에서 표시물과 상태를 즉시 정리해야 한다.
    # 전체 wall-clock 시간에는 deferred 시작과 엔진 스케줄링이 포함되므로,
    # 여기서는 실제 계약인 즉시 상태와 다음 프레임의 대기 해제를 검사한다.
    if not bool(board.get_meta("presentation_skipped", false)):
        failures.append("Skip must record its state synchronously.")
    if board.presentation_label.visible or board.presentation_vfx.visible:
        failures.append("Skip must hide active presentation text and VFX synchronously.")
    for _index in range(2):
        if board.has_meta("presentation_event_count"):
            break
        await process_frame
    if not board.has_meta("presentation_event_count"):
        failures.append("Skip playback must release the active ultimate wait on the next frame.")

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
