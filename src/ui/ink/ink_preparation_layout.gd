extends RefCounted
## Reference geometry applies only to preparation. Existing controllers own play.
const SKIN := preload("res://src/ui/ink/reference_preparation_skin.gd")
const PAPER := Color("e3dac5")
const INK := Color("262720")

static func paper_style(fill: Color = PAPER, margin: float = 10.0) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = Color("817760")
    style.set_border_width_all(1)
    style.set_content_margin_all(margin)
    return style

static func planning_top(height: float) -> float:
    return height * 637.0 / SKIN.SIZE.y

static func configure(board) -> void:
    var theme := preload("res://src/ui/ink/ink_screen_art.gd").theme()
    var font := SystemFont.new()
    font.font_names = PackedStringArray(["Gungsuh","Noto Serif CJK KR","serif"])
    theme.default_font = font
    for control in [board.top_hud, board.action_selection_dock, board.action_timing_panel, board.observation_reveal_panel, board.combat_progress_button]:
        control.theme = theme
    board.top_hud.custom_minimum_size.y = 0
    board.top_hud.player_panel.custom_minimum_size.y = 0
    board.top_hud.enemy_panel.custom_minimum_size.y = 0
    board.action_selection_dock.enable_preparation_layout()
    var surround := ColorRect.new()
    surround.name = "PreparationLetterbox"
    surround.color = Color("151612")
    surround.mouse_filter = Control.MOUSE_FILTER_IGNORE
    surround.z_index = 8
    board.add_child(surround)
    var painting := TextureRect.new()
    painting.name = "ReferencePreparationPainting"
    painting.texture = SKIN.PAINTING
    painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    painting.mouse_filter = Control.MOUSE_FILTER_IGNORE
    painting.z_index = 9
    painting.theme = theme
    board.add_child(painting)
    var plan_paper := TextureRect.new()
    plan_paper.name = "ReferencePlanPaper"
    plan_paper.texture = SKIN.region(SKIN.PAINTING,Rect2(121,646,711,28))
    plan_paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    plan_paper.position = Vector2(105,674)
    plan_paper.size = Vector2(738,77)
    plan_paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
    painting.add_child(plan_paper)
    for key in ["ReferencePlayer", "ReferenceOpponent"]:
        var actor := TextureRect.new()
        actor.name = key
        actor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        actor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
        painting.add_child(actor)
    SKIN.label(painting, "DistanceHeading", "거리", Rect2(473,320,141,35), 27)
    SKIN.label(painting, "DistanceNumber", "", Rect2(483,347,121,82), 77)
    SKIN.label(painting, "DistanceArrows", "←           →", Rect2(410,357,267,55), 35, Color("5b584c"))
    SKIN.label(painting, "DistanceBand", "", Rect2(520,450,48,61), 24)
    SKIN.label(painting, "CommitHint", "※ 진행 후 수정 불가", Rect2(370,755,345,30), 17, Color("555043"))
    var footer := Label.new()
    footer.name = "PreparationKeyHints"
    footer.text = "TAB  행동 선택   ENTER  배치·확정   ← →  계획 이동   ESC  취소"
    footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    footer.add_theme_font_size_override("font_size", 18)
    footer.add_theme_color_override("font_color", Color("dcd3bd"))
    board.action_selection_dock.add_child(footer)

static func set_active(board, active: bool) -> void:
    if board.get_node_or_null("ReferencePreparationPainting") == null:
        return
    board.get_node("ReferencePreparationPainting").visible = active
    board.get_node("PreparationLetterbox").visible = active
    for panel in [board.top_hud, board.top_hud.player_panel, board.top_hud.enemy_panel, board.top_hud.round_panel, board.observation_reveal_panel, board.action_timing_panel, board.combat_progress_button]:
        panel.set_meta("reference_preparation", active)
        panel.set_meta("ink_preparation", true)
        panel.queue_redraw()
    board.player_character.visible = not active
    board.enemy_character.visible = not active
    board.range_readout_panel.visible = not active
    if not active:
        for control in [board.top_hud, board.action_timing_panel, board.combat_progress_button, board.range_readout_panel, board.inline_result_label]:
            control.scale = Vector2.ONE
        board.combat_progress_button._apply_ink_paper_button_style()
        board.combat_progress_button._button.add_theme_font_size_override("font_size", 18)
        board.combat_progress_button._refresh()
        for panel in [board.top_hud.player_panel, board.top_hud.enemy_panel]:
            panel._portrait.hide()
            panel._portrait.material = null

static func layout(board) -> void:
    if board.get_node_or_null("ReferencePreparationPainting") == null:
        return
    set_active(board, true)
    var fitted := SKIN.fit_rect(board.size)
    board.set_meta("reference_preparation_rect", fitted)
    var surround = board.get_node("PreparationLetterbox")
    surround.size = board.size
    var painting = board.get_node("ReferencePreparationPainting")
    painting.position = fitted.position
    painting.size = SKIN.SIZE
    painting.scale = Vector2.ONE * (fitted.size.x / SKIN.SIZE.x)
    var player = painting.get_node("ReferencePlayer")
    player.texture = SKIN.character("player")
    if player.material == null: player.material = SKIN.standing_material("player")
    player.position = Vector2(119,195)
    player.size = Vector2(328,410)
    var opponent = painting.get_node("ReferenceOpponent")
    var candidate := str((board.combat_state.get("enemy", {}) as Dictionary).get("candidate_id", ""))
    opponent.texture = SKIN.character("enemy", candidate)
    if str(opponent.get_meta("candidate_id","")) != candidate or opponent.material == null:
        opponent.material = SKIN.standing_material("enemy",candidate)
        opponent.set_meta("candidate_id",candidate)
    opponent.position = Vector2(643,307)
    opponent.size = Vector2(172,239)
    var public_distance := str(board.range_readout_label.text).trim_prefix("거리 ")
    painting.get_node("DistanceNumber").text = public_distance
    painting.get_node("DistanceBand").text = "밀\n착" if public_distance == "0" else ("중\n간" if public_distance == "2" else "거\n리")
    SKIN.place(board.top_hud, Rect2(15,15,1056,197), fitted)
    board.top_hud._layout()
    SKIN.place(board.action_selection_dock, Rect2(28,825,1030,612), fitted)
    board.action_selection_dock.layout_preparation()
    SKIN.place(board.action_timing_panel, Rect2(101,646,740,105), fitted)
    board.action_timing_panel._layout()
    SKIN.place(board.combat_progress_button, Rect2(870,674,166,78), fitted)
    var button: Button = board.combat_progress_button._button
    for state in ["normal","disabled","hover","pressed"]:
        button.add_theme_stylebox_override(state, SKIN.clear_style())
    button.add_theme_stylebox_override("focus", SKIN.emphasis(INK))
    for state in ["font_color","font_disabled_color","font_hover_color","font_pressed_color"]:
        button.add_theme_color_override(state, INK)
    button.add_theme_font_size_override("font_size", 38)
    button.text = "진행  ›"
    board.combat_progress_button._layout()
    SKIN.place(board.observation_reveal_panel, Rect2(871,253,204,295), fitted)
    board.observation_reveal_panel._layout()
    board.duel_foreground_banner.visible = false
    for value in [board.sound_toggle_button, board.sound_volume_slider, board.fast_replay_button, board.reduced_motion_button, board.combat_log_panel]:
        if is_instance_valid(value):
            value.visible = false
            value.focus_mode = Control.FOCUS_NONE
    layout_inline_result(board)
    board._shift_battlefield_above(board.action_timing_panel.position.y - 8)
    board._hide_legacy_action_ui()

static func layout_inline_result(board) -> void:
    SKIN.place(board.inline_result_label, Rect2(182,605,690,30), SKIN.fit_rect(board.size))
    board.inline_result_label.add_theme_font_size_override("font_size", 18)
    board.inline_result_label.add_theme_color_override("font_color", INK)
    board.inline_result_label.add_theme_stylebox_override("normal", SKIN.clear_style())
