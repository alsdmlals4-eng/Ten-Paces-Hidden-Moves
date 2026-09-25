extends RefCounted
## Preparation composition only. Rules, intent selection and resolution stay in
## their existing controllers. All rectangles come from the current viewport.
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
    return maxf(192.0, height - maxf(336.0, height * 0.43) - 104.0)

static func configure(board) -> void:
    var font := SystemFont.new()
    font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "sans-serif"])
    # A local Control override does not propagate to the child card labels.
    # Scope the readable body font to preparation controls. Resolution keeps its
    # original theme and font metrics, including long wrapped result callouts.
    var preparation_theme := preload("res://src/ui/ink/ink_screen_art.gd").theme()
    preparation_theme.default_font = font
    for control in [board.top_hud, board.action_selection_dock, board.action_timing_panel, board.observation_reveal_panel, board.combat_progress_button, board.range_readout_panel]:
        control.theme = preparation_theme
    board.top_hud.custom_minimum_size.y = 0
    board.top_hud.player_panel.custom_minimum_size.y = 0
    board.top_hud.enemy_panel.custom_minimum_size.y = 0
    board.top_hud.set_meta("ink_preparation", true)
    for panel in [board.top_hud.player_panel, board.top_hud.enemy_panel, board.top_hud.round_panel, board.observation_reveal_panel, board.action_timing_panel]:
        panel.set_meta("ink_preparation", true)
        panel.queue_redraw()
    board.action_selection_dock.enable_preparation_layout()
    board.range_readout_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    board.range_readout_label.add_theme_color_override("font_color", INK)
    board.range_readout_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
    board.range_readout_label.add_theme_font_size_override("font_size", 30)
    board.range_engagement_label.add_theme_color_override("font_color", INK)
    board.range_engagement_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
    board.planning_surface.add_theme_stylebox_override("panel", paper_style())
    board.duel_stage_surface.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
    board._background_readability_tint.color = Color(0.93,0.90,0.81,0.04)
    var footer := Label.new()
    footer.name = "PreparationKeyHints"
    footer.text = "TAB  행동 선택     ENTER  배치 / 확정     ← →  계획 이동     ESC  취소"
    footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
    footer.add_theme_color_override("font_color", Color("dcd3bd"))
    footer.add_theme_font_size_override("font_size", 12)
    board.action_selection_dock.add_child(footer)

static func layout(board) -> void:
    var width: float = board.size.x
    var height: float = board.size.y
    var margin := maxf(18.0, width * 0.025)
    var top := planning_top(height)
    board.top_hud.position = Vector2(margin, 8)
    board.top_hud.size = Vector2(width - margin * 2, 106)
    board.top_hud._layout()
    var dock = board.action_selection_dock
    dock.position = Vector2(margin, top + 106)
    dock.size = Vector2(width - margin * 2, height - top - 114)
    dock.layout_preparation()
    var progress_width := clampf(width * 0.16, 132, 205)
    board.action_timing_panel.position = Vector2(margin, top + 2)
    board.action_timing_panel.size = Vector2(width - margin * 2 - progress_width - 20, 96)
    board.action_timing_panel._layout()
    board.combat_progress_button.position = Vector2(width - margin - progress_width, top + 17)
    board.combat_progress_button.size = Vector2(progress_width, 60)
    var button: Button = board.combat_progress_button._button
    button.add_theme_font_size_override("font_size", 23)
    button.add_theme_color_override("font_color", INK)
    button.add_theme_color_override("font_hover_color", INK)
    button.add_theme_stylebox_override("normal", paper_style(Color("b89a54")))
    button.add_theme_stylebox_override("hover", paper_style(Color("d1b56e")))
    button.add_theme_stylebox_override("pressed", paper_style(Color("ac8a45")))
    var obs = board.observation_reveal_panel
    var obs_width := clampf(width * 0.17, 160, 238)
    var obs_height := minf(220, maxf(72, top - 128))
    obs.position = Vector2(width - margin - obs_width, top - obs_height - 14)
    obs.size = Vector2(obs_width, obs_height)
    obs._layout()
    obs.z_index = 6
    board._shift_battlefield_above(top - 24)
    board._layout_screen_surfaces(top)
    board.duel_foreground_banner.visible = false
    for value in [board.sound_toggle_button, board.sound_volume_slider, board.fast_replay_button, board.reduced_motion_button, board.combat_log_panel]:
        if is_instance_valid(value):
            value.visible = false
            value.focus_mode = Control.FOCUS_NONE
    board._hide_legacy_action_ui()
