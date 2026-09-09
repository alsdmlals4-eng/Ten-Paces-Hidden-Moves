# 전투 UI가 최소 및 기준 해상도에서 화면 밖으로 밀리지 않는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const VIEWPORT_SIZES := [Vector2(960.0, 640.0), Vector2(1440.0, 900.0), Vector2(1280, 720), Vector2(1280, 800), Vector2(1920, 1080)]

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

    var timing_rect := Rect2(board.action_timing_panel.position, board.action_timing_panel.size)
    var tray_rect := Rect2(board.basic_card_tray.position, board.basic_card_tray.size)
    if timing_rect.end.y > tray_rect.position.y:
        failures.append("Action timing must remain above the card tray at %s." % str(viewport_size))
    await _verify_execution_text(board, viewport_size)
    board.queue_free()
    await process_frame

func _verify_execution_text(board: CombatBoardPreview, viewport_size: Vector2) -> void:
    var snapshot := board.get_layout_snapshot()
    _expect(snapshot.has("presentation_compare_rect"), "Board must expose execution lane diagnostics.")
    _expect(not (snapshot.get("presentation_compare_rect", Rect2()) as Rect2).has_area(), "Planning has no comparison lane.")
    # Explicit long-copy presentation fixture, separate from the ordinary CTA
    # test. It does not inject resolver success or modify combat state.
    var state := board.get_combat_state_snapshot()
    board.position = Vector2(17, 23)
    board._set_presentation_state("presenting_result")
    board._set_resolution_surface_visible(false)
    var long_name := "창궁무애검법 연속 행동 조건과 방어 파괴 결과 확인"
    var long_result := "파공검기 적중으로 상대의 다음 행동이 중단되어 전투 불능 직전입니다."
    board.action_reveal_overlay.show_timing(3, "attack", [{"type": "action_result", "actor": "player", "card_name": long_name, "category": "attack", "action_slots": 3, "range_text": "1~3", "raw_damage": 22, "stamina_cost": 3, "internal_cost": 2, "damage": 9, "outcome": "hit"}], true)
    board.presentation_label.text = long_result
    board.presentation_label.visible = true
    for _frame in range(6):
        await process_frame
    var stage := _global_bounds(board.duel_stage_surface)
    var compare := Rect2(stage.position, Vector2(stage.size.x, clampf(stage.size.y * 0.40, 270, 340)))
    var label_bounds := _global_bounds(board.presentation_label)
    _expect(stage.encloses(compare) and stage.grow(0.5).encloses(label_bounds) and not compare.intersects(label_bounds), "Execution label must be contained below comparison at %s: %s / %s" % [viewport_size, compare, label_bounds])
    _expect(board.presentation_label.text == long_result and board.presentation_label.autowrap_mode != TextServer.AUTOWRAP_OFF, "Exact long result must remain wrapped and unmodified.")
    _verify_label(board.presentation_label, label_bounds, viewport_size)
    var overlay: Control = board.action_reveal_overlay
    var player_panel := overlay.get_node("PlayerActionCallout") as Control
    _expect((player_panel.find_child("ActionName", true, false) as Label).text == long_name, "Exact long action name is not shortened.")
    for child in overlay.get_children():
        if child is Control and child.visible:
            _expect(compare.grow(0.5).encloses(_global_bounds(child)), "Settled comparison child %s outside %s at %s: %s min=%s" % [child.name, compare, viewport_size, _global_bounds(child), child.get_combined_minimum_size()])
            _verify_text_descendants(child, compare, viewport_size)
    var result := overlay.get_node("RevealResult") as Control
    for panel_name in ["PlayerActionCallout", "EnemyActionCallout"]:
        _expect(not _global_bounds(result).intersects(_global_bounds(overlay.get_node(panel_name))), "Settled result cannot intersect actual callout at %s." % viewport_size)
    print("SETTLED_TEXT_BOUNDS viewport=%s compare=%s player=%s player_min=%s result=%s label=%s label_min=%s" % [viewport_size, compare, _global_bounds(player_panel), player_panel.get_combined_minimum_size(), _global_bounds(result), label_bounds, board.presentation_label.get_combined_minimum_size()])
    board._sound_muted = true
    board._reduced_motion = true
    board._layout_board()
    for _frame in range(3):
        await process_frame
    _expect(board.presentation_label.text == long_result and board.get_combat_state_snapshot() == state, "Layout/mute/reduced motion preserve exact text and domain state.")
    board._set_presentation_state("next_bundle_ready")
    board._set_resolution_surface_visible(true)
    snapshot = board.get_layout_snapshot()
    for key in ["presentation_compare_rect", "presentation_label_rect", "presentation_vfx_rect"]:
        _expect(not (snapshot.get(key, Rect2()) as Rect2).has_area(), "Planning clears " + key)
    _expect(not overlay.visible and not board.presentation_label.visible and not board.presentation_vfx.visible, "Planning clears all transient presentation surfaces.")

func _verify_text_descendants(node: Control, bounds: Rect2, viewport_size: Vector2) -> void:
    if node is Label:
        _verify_label(node, bounds, viewport_size)
    for child in node.get_children():
        if child is Control and child.is_visible_in_tree():
            _expect(_global_bounds(node).grow(0.5).encloses(_global_bounds(child)), "Settled child %s escapes its actual %s container at %s." % [child.name, node.name, viewport_size])
            _verify_text_descendants(child, bounds, viewport_size)

func _verify_label(label: Label, bounds: Rect2, viewport_size: Vector2) -> void:
    _expect(bounds.grow(0.5).encloses(_global_bounds(label)), "Visible text %s escapes lane at %s." % [label.name, viewport_size])
    _expect(label.size.y + 0.5 >= label.get_combined_minimum_size().y, "Text %s needs %s but has %s at %s." % [label.name, label.get_combined_minimum_size(), label.size, viewport_size])

func _global_bounds(node: Control) -> Rect2:
    var transform := node.get_global_transform()
    var rect := Rect2(transform * Vector2.ZERO, Vector2.ZERO)
    for corner in [Vector2(node.size.x, 0), node.size, Vector2(0, node.size.y)]:
        rect = rect.expand(transform * corner)
    return rect

func _expect(condition: bool, message: String) -> void:
    if not condition and not failures.has(message):
        failures.append(message)

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
