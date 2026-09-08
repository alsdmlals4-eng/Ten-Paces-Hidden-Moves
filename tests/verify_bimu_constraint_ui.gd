extends SceneTree

const STARTERS := ["mount_hua_plum_blossom_sword", "shaolin_arhat_vajra_art", "wudang_taiji_sword", "yang_family_spear"]
const Adapter := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func check(value: bool, message: String) -> void:
    if not value: failures.append(message)

func _run() -> void:
    var model = preload("res://src/run/bimu_constraint_model.gd").new()
    var policy: Dictionary = model.get_selection_policy()
    policy["max_selected_constraints"] = 99
    check(model.get_selection_policy().get("max_selected_constraints") == 2, "selection policy deep copy")
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    shell.start_new_run()
    for id in STARTERS: shell.toggle_setup_manual(id)
    shell.advance_noncombat()
    shell.advance_noncombat()
    await process_frame
    check(shell.has_method("get_bimu_constraint_panel"), "native briefing constraint panel missing")
    if shell.has_method("get_bimu_constraint_panel"):
        await _briefing(shell)
    await _panel_context_refresh(shell)
    await _unchanged_panels()
    shell.queue_free()
    await process_frame
    for failure in failures: push_error(failure)
    if failures.is_empty(): print("BIMU_CONSTRAINT_UI_OK")
    quit(0 if failures.is_empty() else 1)

func _panel_context_refresh(shell) -> void:
    # Isolated panel-binding fixture, never a campaign outcome or durable write.
    var run = VerticalSliceRunState.new()
    check(run.configure_opponents(shell.opponent_catalog, 20260820), "panel context fixture binds actual opponent catalog")
    var mastery := {}
    for id in STARTERS: mastery[id] = 3
    check(run.start_new_run() and run.confirm_setup_loadout(STARTERS, mastery) and run.advance() and run.advance(), "panel context fixture reaches actual briefing")
    var panel = preload("res://src/ui/bimu_constraint_panel.gd").new()
    root.add_child(panel)
    panel.configure(run, shell.manual_registry)
    var button = panel.option_buttons.CST_TECH_MANUAL_SEAL
    var scroll = panel.options_scroll
    panel.configure(run, shell.manual_registry)
    check(panel.option_buttons.CST_TECH_MANUAL_SEAL == button and panel.options_scroll == scroll, "same acknowledged context preserves widgets and scroll")
    var previous_manual: String = run.get_current_opponent().signature_manual_id
    for candidate in run._opponent_catalog.get_all_candidates():
        if candidate.signature_manual_id != previous_manual:
            run._current_opponent_id = candidate.candidate_id
            break
    run.duel_index += 1
    panel.configure(run, shell.manual_registry)
    check(panel.option_buttons.CST_TECH_MANUAL_SEAL != button, "changed duel opponent rebuilds bindings")
    check(panel.target_selectors.CST_ENEMY_MASTERED_MANUAL.get_item_metadata(0) == run.get_current_opponent().signature_manual_id, "changed opponent has current enemy manual target")
    button = panel.option_buttons.CST_TECH_MANUAL_SEAL
    run._player_manual_loadout.reverse()
    panel.configure(run, shell.manual_registry)
    check(panel.option_buttons.CST_TECH_MANUAL_SEAL != button, "changed loadout rebuilds bindings")
    check(panel.target_selectors.CST_TECH_MANUAL_SEAL.get_item_metadata(0) == run.get_player_manual_loadout()[0], "changed loadout has current player target order")
    panel.queue_free()
    await process_frame

func _briefing(shell) -> void:
    var panel = shell.get_bimu_constraint_panel()
    check(panel.option_buttons.size() == 9, "nine native options")
    check(shell.primary_button.text.contains("제약 없이"), "explicit zero confirmation")
    check(panel.summary_label.text.get_slice("\n", 0) == "선택 0/2 · 제약 점수 0/3", "catalog policy exact integer counter")
    for button in panel.option_buttons.values():
        check(button.text.begins_with("[미선택]"), "unchecked state has explicit text cue")
        check(button.has_theme_stylebox_override("normal") and button.has_theme_stylebox_override("pressed") and button.has_theme_stylebox_override("focus"), "native option has explicit normal selected focus styles")
        if button.has_theme_stylebox_override("normal"):
            var normal: StyleBoxFlat = button.get_theme_stylebox("normal")
            var pressed: StyleBoxFlat = button.get_theme_stylebox("pressed")
            var focus: StyleBoxFlat = button.get_theme_stylebox("focus")
            check(_contrast(button.get_theme_color("font_color"), normal.bg_color) >= 4.5, "unchecked text contrast >= 4.5")
            check(_contrast(button.get_theme_color("font_pressed_color"), pressed.bg_color) >= 4.5, "selected text contrast >= 4.5")
            check(_contrast(normal.border_color, normal.bg_color) >= 3.0 and normal.border_width_left >= 1, "unchecked boundary contrast >= 3")
            check(_contrast(focus.border_color, normal.bg_color) >= 3.0 and focus.border_width_left >= 2, "focus boundary contrast >= 3")
            check(_contrast(focus.border_color, pressed.bg_color) >= 3.0, "selected focus boundary contrast >= 3")
    var intel: Dictionary = shell.run_state.get("_intel_by_candidate")
    intel[str(shell.run_state.get_current_opponent()["candidate_id"])] = {"text": "공개 단서 회귀 검증"}
    shell.call("_render_current_screen")
    check(shell.description_label.text.contains("행로에서 얻은 단서 · 공개 단서 회귀 검증"), "actual route shell intel preserved")
    var public_copy: String = shell.description_label.text
    check(public_copy.contains("알려진 습관") and public_copy.contains("나의 보유 무공"), "public opponent and own mastery preserved")
    check(panel.toggle_constraint("CST_TECH_MANUAL_SEAL"), "manual target selection")
    check(panel.target_selectors["CST_TECH_MANUAL_SEAL"].item_count == 4, "owned target options")
    check(panel.toggle_constraint("CST_ENEMY_STAT_DISCIPLINE"), "stat selection")
    check(panel.target_selectors["CST_ENEMY_STAT_DISCIPLINE"].item_count == 5, "stat target options")
    check(not panel.toggle_constraint("CST_TECH_ULTIMATE_SEAL"), "third choice rejected")
    check(not panel.reason_label.text.is_empty(), "rejection reason visible")
    check(shell.run_state.get_pending_bimu_constraints().size() == 2, "invalid change atomic")
    for height in [720, 800]:
        root.size = Vector2i(1280, height)
        shell.size = Vector2(1280, height)
        await process_frame
        await process_frame
        var first: Control = panel.option_buttons.values()[0]
        var last: Control = panel.option_buttons.values()[8]
        first.grab_focus()
        await process_frame
        check(first.has_focus(), "first option keyboard focus %d" % height)
        last.grab_focus()
        await process_frame
        await process_frame
        check(last.has_focus(), "last option keyboard focus %d" % height)
        check(panel.options_scroll.get_global_rect().intersects(last.get_global_rect()), "last option scrolled into view %d" % height)
        var selected_count: int = shell.run_state.get_pending_bimu_constraints().size()
        var accept := InputEventAction.new()
        accept.action = "ui_accept"
        accept.pressed = true
        root.push_input(accept)
        accept = InputEventAction.new()
        accept.action = "ui_accept"
        accept.pressed = false
        root.push_input(accept)
        await process_frame
        check(shell.run_state.get_pending_bimu_constraints().size() != selected_count, "last option keyboard activation %d" % height)
        check(shell.primary_button.get_global_rect().end.y <= height, "CTA in viewport %d" % height)
        check(shell.primary_button.get_global_rect().position.y >= panel.get_global_rect().end.y - 1, "no options CTA overlap %d" % height)
        # Reproduce the capture: click the last unchecked option with a short
        # footer, then let the newly selected effect expand the summary.
        shell.run_state.select_bimu_constraints([{"constraint_id": "CST_TECH_MANUAL_SEAL", "target_manual_id": STARTERS[0]}])
        panel.call("_refresh")
        await process_frame
        await process_frame
        last = panel.option_buttons.values()[8]
        last.grab_focus()
        panel.options_scroll.ensure_control_visible(last)
        await process_frame
        last.set_pressed_no_signal(true)
        last.toggled.emit(true)
        await process_frame
        await process_frame
        await process_frame
        last = panel.option_buttons.values()[8]
        check(panel.summary_label.text.get_slice("\n", 0) == "선택 2/2 · 제약 점수 2/3", "selected exact integer counter %d" % height)
        check(last.text.begins_with("[선택]"), "selected state has explicit text cue")
        var target: Control = panel.target_selectors["CST_ENEMY_STAT_DISCIPLINE"]
        var scroll_rect: Rect2 = panel.options_scroll.get_global_rect()
        check(scroll_rect.encloses(last.get_global_rect()) and scroll_rect.encloses(target.get_global_rect()), "selected final row and target fully visible after footer grows %d" % height)
        check(shell.primary_button.get_global_rect().end.y <= height and shell.primary_button.get_global_rect().position.y >= panel.get_global_rect().end.y - 1, "expanded summary preserves CTA bounds %d" % height)
    shell.advance_noncombat()
    await process_frame
    await process_frame
    var bridge = shell.get("_combat_view")
    var dock = bridge.action_selection_dock
    check(dock.constraint_summary.text.contains("이번 비무"), "active preparation summary")
    dock.set_active_source("martial")
    var martial = dock.martial_panel
    var blocked_id := str(martial.technique_buttons[0].get_meta("technique_id"))
    check(martial.technique_buttons[0].disabled, "sealed manual card disabled")
    check(martial.technique_buttons[0].tooltip_text.contains("문파 단절"), "actual engine reason in card")
    check(not martial.activate_technique(blocked_id), "normal activation forbidden")
    check(martial.get_panel_snapshot().get("unlocked_technique_count") == 0, "snapshot reports constraint locked techniques")
    var placements: Array = bridge.action_timing_panel.get_resolution_placements()
    dock.request_action({"id": blocked_id, "source": "basic"})
    check(bridge.action_timing_panel.get_resolution_placements() == placements, "dock injection cannot place")
    var snapshot: Dictionary = bridge.get_vertical_slice_loadout_snapshot()
    var full_mastery := {}
    for id in STARTERS: full_mastery[id] = 10
    var receipt := {"selections": [{"constraint_id": "CST_TECH_ULTIMATE_SEAL"}], "enemy_candidate_id": snapshot["enemy_candidate_id"]}
    check(bridge.configure_vertical_slice_loadouts(STARTERS, full_mastery, snapshot["enemy_loadout"], snapshot["enemy_mastery_by_manual"], snapshot["enemy_candidate_id"], snapshot["enemy_runtime_binding"], {}, receipt), "changed receipt and mastery binds")
    bridge.combat_state["player"]["momentum"] = [5, 5]
    bridge.call("_sync_action_selection_dock")
    await process_frame
    dock.set_active_source("ultimate")
    var ultimate = dock.ultimate_panel
    var sealed_id := STARTERS[0] + "_star10"
    var sealed: Button = ultimate.get_action_button(sealed_id)
    check(sealed != null and sealed.disabled and sealed.tooltip_text.contains("비무 제약: 절초 봉인"), "ultimate engine reason visible after receipt refresh")
    check(not ultimate.activate_ultimate(sealed_id), "sealed ultimate cannot reserve")
    check(not ultimate.get_action_button("ultimate_ten_paces_wave").disabled, "base ultimate remains available")
    check(not martial.technique_buttons[0].disabled, "changed receipt unlocks ordinary manual technique")
    for height in [720, 800]:
        root.size = Vector2i(1280, height)
        shell.size = Vector2(1280, height)
        await process_frame
        await process_frame
        check(dock.constraint_summary.get_global_rect().position.x >= dock.ultimate_tab.get_global_rect().end.x, "active summary does not overlap source tabs %d" % height)
        check(dock.constraint_summary.get_global_rect().end.y <= dock.content_host.get_global_rect().position.y + 8, "active summary above cards %d" % height)

func _unchanged_panels() -> void:
    var martial = load("res://scenes/ui/action_selection/martial_action_panel.tscn").instantiate()
    var ultimate = load("res://scenes/ui/action_selection/ultimate_action_panel.tscn").instantiate()
    ultimate.set_momentum(0, 5)
    root.add_child(martial)
    root.add_child(ultimate)
    martial.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
    martial.size = Vector2(600, 340)
    await process_frame

    check(ultimate.action_buttons.size() > 0, "default momentum initializes actions")
    var mastery := {}
    for id in STARTERS: mastery[id] = 10
    var manuals: Array[Dictionary] = Adapter.new().build_owned_manuals(STARTERS, mastery)
    martial.set_manuals(manuals)
    ultimate.set_martial_context(STARTERS, mastery)
    ultimate.set_momentum(5, 5)
    await process_frame
    var manual_id: int = martial.manual_buttons[0].get_instance_id()
    var technique_id: int = martial.technique_buttons[0].get_instance_id()
    var ultimate_id: int = ultimate.action_buttons[0].get_instance_id()
    martial.manual_buttons[0].grab_focus()
    await process_frame
    martial.manual_scroll.scroll_horizontal = 35
    await process_frame
    var focus_id: int = root.gui_get_focus_owner().get_instance_id()
    var scroll: int = martial.manual_scroll.scroll_horizontal
    check(scroll > 0, "nonzero scroll fixture")
    var changed := 0
    var no_reservations: Array[Dictionary] = []
    for index in 10:
        martial.set_manuals(manuals)
        ultimate.set_martial_context(STARTERS, mastery)
        ultimate.set_momentum(5, 5)
        ultimate.set_reservations(no_reservations)
        if martial.manual_buttons[0].get_instance_id() != manual_id: changed += 1
    print("BIMU_UI_IDENTICAL_UPDATES=10 CHANGED_MANUAL_LISTS=%d" % changed)
    await process_frame
    check(changed == 0, "identical manual list identity preserved")
    check(martial.technique_buttons[0].get_instance_id() == technique_id, "identical techniques identity preserved")
    check(ultimate.action_buttons[0].get_instance_id() == ultimate_id, "identical ultimate identity preserved")
    check(root.gui_get_focus_owner() != null and root.gui_get_focus_owner().get_instance_id() == focus_id, "same-data focus preserved")
    check(martial.manual_scroll.scroll_horizontal == scroll, "same-data scroll preserved")
    mastery[STARTERS[0]] = 3
    martial.set_manuals(Adapter.new().build_owned_manuals(STARTERS, mastery))
    ultimate.set_martial_context(STARTERS, mastery)
    check(martial.technique_buttons[0].get_instance_id() != technique_id, "mastery change refreshes manual")
    check(ultimate.action_buttons[0].get_instance_id() != ultimate_id, "mastery change refreshes ultimate")
    var next_id: int = ultimate.action_buttons[0].get_instance_id()
    ultimate.set_momentum(0, 5)
    check(ultimate.action_buttons[0].get_instance_id() != next_id, "momentum change refreshes ultimate")
    var reserved: Array[Dictionary] = [{"action_id": "ultimate_ten_paces_wave", "start_timing": 1, "end_timing": 2}]
    next_id = ultimate.action_buttons[0].get_instance_id()
    ultimate.set_reservations(reserved)
    check(ultimate.action_buttons[0].get_instance_id() != next_id, "reservation change refreshes ultimate")
    next_id = ultimate.action_buttons[0].get_instance_id()
    ultimate.set_reservations(reserved)
    check(ultimate.action_buttons[0].get_instance_id() == next_id, "same reservation preserves identity")
    martial.queue_free()
    ultimate.queue_free()
    await process_frame

func _contrast(first: Color, second: Color) -> float:
    var a := first.srgb_to_linear().get_luminance()
    var b := second.srgb_to_linear().get_luminance()
    return (maxf(a, b) + 0.05) / (minf(a, b) + 0.05)
