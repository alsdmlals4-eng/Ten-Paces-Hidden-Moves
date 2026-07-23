# 전투 계획의 Tab 포커스 순서가 카드·수 슬롯·대상 타일·진행으로 고정되는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Focus order requires the combat board scene.")
        _finish()
        return
    var board := packed.instantiate() as CombatBoardPreview
    root.add_child(board)
    for _index in range(4):
        await process_frame

    var cards: Array = board.basic_card_tray.cards
    var first_slot := board.action_timing_panel.get_slot(1)
    var last_slot := board.action_timing_panel.get_slot(10)
    var first_tile := board.get_tile(1)
    var last_tile := board.get_tile(10)
    var progress := board.combat_progress_button._button
    if cards.size() < 2:
        failures.append("Focus order requires at least two basic cards.")
    else:
        _require_next(cards[0], cards[1], "first card")
        _require_next(cards[cards.size() - 1], first_slot, "last card")
    _require_next(first_slot, board.action_timing_panel.get_slot(2), "first timing slot")
    _require_next(last_slot, first_tile, "last timing slot")
    _require_next(first_tile, board.get_tile(2), "first target tile")
    _require_next(last_tile, progress, "last target tile")
    _require_next(progress, board.fast_replay_button, "progress button")
    _require_next(board.fast_replay_button, board.skip_presentation_button, "fast playback")
    _require_next(board.skip_presentation_button, board.reduced_motion_button, "skip playback")
    _require_next(board.reduced_motion_button, board.sound_toggle_button, "reduced motion")
    _require_next(board.sound_toggle_button, board.sound_volume_slider, "sound toggle")
    _require_next(board.sound_volume_slider, cards[0], "sound volume")

    board.queue_free()
    await process_frame
    _finish()

func _require_next(control: Control, expected: Control, label: String) -> void:
    if control == null or expected == null:
        failures.append("%s focus controls must exist." % label)
        return
    if control.focus_next != control.get_path_to(expected):
        failures.append("%s must have an explicit next Tab target." % label)

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_FOCUS_ORDER_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_FOCUS_ORDER_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
