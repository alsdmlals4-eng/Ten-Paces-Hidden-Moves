# 절초로 전투 불능이 된 묶음은 결과 연출 뒤 terminal review로 잠기고, 복기 확인 뒤 완전 재시작되는지 검증한다.
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
    # Headless audio does not own an output device; mute keeps this state-machine test free of AudioServer leaks.
    board._sound_muted = true

    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()

    var ultimate_index := _ultimate_index(board, "ultimate_void_sword_qi")
    if ultimate_index < 0:
        failures.append("Terminal presentation test requires 파공검기.")
    else:
        board._on_ultimate_menu_id_pressed(ultimate_index)
        board._on_timing_slot_clicked(1)
        board.action_timing_panel.set_placement_target(1, {"direction": 1, "target_tile": 7, "origin_tile": 4})
        board._sync_progress_availability()
        if not board.combat_progress_button.progress_enabled:
            failures.append("A complete 3-slot terminal ultimate must enable progress.")
        else:
            board.combat_progress_button.request_progress()
            for _attempt in range(120):
                await process_frame
                if str(board.get_meta("presentation_state", "")) == "review_ready":
                    break
                await create_timer(0.05).timeout
            if str(board.get_meta("presentation_state", "")) != "review_ready":
                failures.append("A defeated combatant must stop in terminal review_ready before restart.")
            if not board._inputs_locked():
                failures.append("Terminal review must keep planning inputs locked.")
            if board.combat_review_panel == null or not board.combat_review_panel.visible:
                failures.append("Terminal result must show the combat review panel.")
            elif board.combat_review_panel.get_continue_button().text != "결전 다시 시작":
                failures.append("Terminal review continue action must be 결전 다시 시작.")
            if str(board.get_meta("last_sfx_kind", "")) != "defeat":
                failures.append("A terminal result must request the defeat SFX after its hit presentation.")

            board._on_review_continue_requested()
            await process_frame
            if str(board.get_meta("presentation_state", "")) != "planning":
                failures.append("Terminal review confirmation must restart into planning.")
            if not board._last_review_summary.is_empty():
                failures.append("Terminal restart must clear the review summary.")
            if board.combat_review_panel != null and board.combat_review_panel.visible:
                failures.append("Terminal restart must hide the review panel.")
            var restarted := board.get_combat_state_snapshot()
            if int(((restarted.get("player", {}) as Dictionary).get("tile", 0))) != 4 or int(((restarted.get("enemy", {}) as Dictionary).get("tile", 0))) != 7:
                failures.append("Terminal restart must restore start tiles 4 and 7.")

    board.queue_free()
    await process_frame
    _finish()

func _ultimate_index(board: CombatBoardPreview, card_id: String) -> int:
    for index in range(board._ultimate_definitions.size()):
        if str((board._ultimate_definitions[index] as Dictionary).get("id", "")) == card_id:
            return index
    return -1

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_TERMINAL_PRESENTATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_TERMINAL_PRESENTATION_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
