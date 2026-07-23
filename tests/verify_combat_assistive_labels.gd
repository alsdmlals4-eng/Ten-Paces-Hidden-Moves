# 전투 조작 요소가 보조기기에 읽을 한국어 접근성 이름과 설명을 제공하는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if int(ProjectSettings.get_setting("accessibility/general/accessibility_support", 0)) != 1:
        failures.append("Project accessibility support must be Always Active for Windows assistive-app verification.")
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Assistive labels require the combat board scene.")
        _finish()
        return
    var board := packed.instantiate() as CombatBoardPreview
    root.add_child(board)
    for _index in range(4):
        await process_frame

    _require_label(board.basic_card_tray.cards[0], "basic card")
    _require_label(board.action_timing_panel.get_slot(1), "timing slot")
    _require_label(board.get_tile(1), "combat tile")
    _require_label(board.combat_progress_button._button, "progress button")
    _require_label(board.fast_replay_button, "fast playback")
    _require_label(board.skip_presentation_button, "skip playback")
    _require_label(board.reduced_motion_button, "reduced motion")
    _require_label(board.sound_toggle_button, "sound toggle")
    _require_label(board.sound_volume_slider, "sound volume")

    board.queue_free()
    await process_frame
    _finish()

func _require_label(control: Control, label: String) -> void:
    if control == null:
        failures.append("%s must exist." % label)
        return
    if control.accessibility_name.strip_edges().is_empty():
        failures.append("%s must have an accessibility name." % label)
    if control.accessibility_description.strip_edges().is_empty():
        failures.append("%s must have an accessibility description." % label)

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_ASSISTIVE_LABELS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_ASSISTIVE_LABELS_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
