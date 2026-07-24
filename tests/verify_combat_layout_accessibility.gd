# 전투 UI가 최소 및 기준 해상도에서 화면 밖으로 밀리지 않는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const VIEWPORT_SIZES := [Vector2(960.0, 640.0), Vector2(1440.0, 900.0)]

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    for viewport_size in VIEWPORT_SIZES:
        await _verify_viewport(viewport_size)
    _finish()

func _verify_viewport(viewport_size: Vector2) -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = viewport_size
    root.add_child(board)
    for _index in range(4):
        await process_frame

    var bounds := Rect2(Vector2.ZERO, viewport_size)
    _require_inside("top HUD", Rect2(board.top_hud.position, board.top_hud.size), bounds, viewport_size)
    _require_inside("player HUD", _hud_rect(board, board.top_hud.player_panel), bounds, viewport_size)
    _require_inside("player momentum", _hud_rect(board, board.top_hud.player_momentum), bounds, viewport_size)
    _require_inside("round HUD", _hud_rect(board, board.top_hud.round_panel), bounds, viewport_size)
    _require_inside("enemy momentum", _hud_rect(board, board.top_hud.enemy_momentum), bounds, viewport_size)
    _require_inside("enemy HUD", _hud_rect(board, board.top_hud.enemy_panel), bounds, viewport_size)
    _require_inside("ultimate list", Rect2(board.ultimate_list_panel.position, board.ultimate_list_panel.size), bounds, viewport_size)
    _require_inside("action timing", Rect2(board.action_timing_panel.position, board.action_timing_panel.size), bounds, viewport_size)
    _require_inside("progress", Rect2(board.combat_progress_button.position, board.combat_progress_button.size), bounds, viewport_size)
    _require_inside("card tray", Rect2(board.basic_card_tray.position, board.basic_card_tray.size), bounds, viewport_size)

    board.presentation_label.text = "파공검기 적중으로 상대의 다음 행동이 중단되어 전투 불능 직전입니다."
    if board.presentation_label.autowrap_mode == TextServer.AUTOWRAP_OFF:
        failures.append("Presentation results must wrap long Korean explanations at %s." % str(viewport_size))
    elif board.presentation_label.get_minimum_size().y > board.presentation_label.size.y + 0.5:
        failures.append("Presentation results must have enough vertical space for long Korean explanations at %s. required=%s actual=%s" % [str(viewport_size), str(board.presentation_label.get_minimum_size()), str(board.presentation_label.size)])

    var timing_rect := Rect2(board.action_timing_panel.position, board.action_timing_panel.size)
    var tray_rect := Rect2(board.basic_card_tray.position, board.basic_card_tray.size)
    if timing_rect.end.y > tray_rect.position.y:
        failures.append("Action timing must remain above the card tray at %s." % str(viewport_size))
    board.queue_free()
    await process_frame

func _hud_rect(board: CombatBoardPreview, child: Control) -> Rect2:
    return Rect2(board.top_hud.position + child.position, child.size)

func _require_inside(label: String, rect: Rect2, bounds: Rect2, viewport_size: Vector2) -> void:
    if rect.position.x < -0.5 or rect.position.y < -0.5 or rect.end.x > bounds.end.x + 0.5 or rect.end.y > bounds.end.y + 0.5:
        failures.append("%s must remain inside %s. actual=%s" % [label, str(viewport_size), str(rect)])

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_LAYOUT_ACCESSIBILITY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_LAYOUT_ACCESSIBILITY_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
