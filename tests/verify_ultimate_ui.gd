# 제품 ActionSelectionDock의 절초 조건·자동 예약·진행 전 취소·연속 수 점유를 UI 수준에서 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const CASES := [
    ["ultimate_ten_paces_wave", 1, 0],
    ["ultimate_cleave_peak", 2, 1],
    ["ultimate_void_sword_qi", 3, 2]
]

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    await _verify_disabled_reason_copy()
    for case_value in CASES:
        var case: Array = case_value
        await _verify_reservation(str(case[0]), int(case[1]))
    for case_value in CASES:
        var case: Array = case_value
        await _verify_ultimate_playback_visibility(str(case[0]), int(case[1]), int(case[2]))
    _finish()

func _verify_disabled_reason_copy() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    if not is_instance_valid(board.action_selection_dock):
        failures.append("The product ActionSelectionDock must exist on the combat screen.")
        board.queue_free()
        await process_frame
        return
    if board.ultimate_list_panel.visible or board.ultimate_menu.visible:
        failures.append("Legacy ultimate controls must remain hidden after the product dock migration.")

    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [4, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    board.action_selection_dock.set_active_source("ultimate")
    var momentum_locked: Button = board.action_selection_dock.ultimate_panel.get_action_button("ultimate_ten_paces_wave")
    if not board.action_selection_dock.ultimate_panel.visible:
        failures.append("The ultimate source panel must be reachable from the product dock during planning.")
    if not is_instance_valid(momentum_locked) or not momentum_locked.disabled:
        failures.append("Base ultimates must be disabled below five momentum.")
    elif not momentum_locked.tooltip_text.contains("기세 4/5"):
        failures.append("Disabled product ultimate actions must explain the current and required momentum.")

    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    var meditate := _card_definition(board, "basic_meditate")
    board.action_timing_panel.place_card(meditate, 1)
    board.action_timing_panel.place_card(meditate, 2)
    board.action_timing_panel.place_card(meditate, 3)
    board._refresh_ultimate_menu()
    var entries_before := board.combat_log_panel.entries.size()
    if not board.action_selection_dock.ultimate_panel.activate_ultimate("ultimate_cleave_peak"):
        failures.append("A momentum-ready ultimate must reach the shared placement controller.")
    if board.combat_log_panel.entries.size() <= entries_before:
        failures.append("A contiguous-timing failure must append an explanatory combat log entry.")
    else:
        var latest_entry: Dictionary = board.combat_log_panel.entries[-1]
        if not str(latest_entry.get("text", "")).contains("연속된 빈 행동 슬롯"):
            failures.append("A failed multi-slot ultimate must explain the missing contiguous timings.")
    if not board._ultimate_reservation_anchors.is_empty():
        failures.append("A failed ultimate placement must not create a momentum reservation.")

    board._set_presentation_state("resolving")
    var resolving_button: Button = board.action_selection_dock.ultimate_panel.get_action_button("ultimate_ten_paces_wave")
    if board.action_selection_dock.switching_enabled:
        failures.append("Resolving must lock product action-source switching.")
    if not is_instance_valid(resolving_button) or not resolving_button.disabled:
        failures.append("Resolving must disable product ultimate actions.")

    board.queue_free()
    await process_frame

func _verify_reservation(card_id: String, span: int) -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    board.action_selection_dock.set_active_source("ultimate")
    await process_frame
    await process_frame

    var product_button: Button = board.action_selection_dock.ultimate_panel.get_action_button(card_id)
    if not is_instance_valid(product_button) or product_button.disabled:
        failures.append("The product ultimate panel must offer %s at exactly five momentum." % card_id)
    if not bool(board.get_layout_snapshot().get("ultimate_vfx_ready", false)):
        failures.append("Approved RGBA ultimate VFX sheet must load into the combat screen.")

    if not board.action_selection_dock.ultimate_panel.activate_ultimate(card_id):
        failures.append("Ultimate definition was missing or unavailable in the product panel: %s" % card_id)
    else:
        await process_frame
        var reserved_player: Dictionary = board.combat_state.get("player", {})
        var momentum: Array = reserved_player.get("momentum", [5, 5])
        if int(momentum[0]) != 0:
            failures.append("Ultimate automatic reservation must immediately spend all momentum: %s" % card_id)
        var placement := board.action_timing_panel.get_placement(1)
        var definition: Dictionary = placement.get("definition", {})
        if str(definition.get("id", "")) != card_id or int(placement.get("span", 0)) != span:
            failures.append("Ultimate selection must auto-reserve its declared consecutive timings: %s" % card_id)
        for slot_index in range(1, span + 1):
            if not board.action_timing_panel.has_assignment_at(slot_index):
                failures.append("Ultimate %s must occupy timing %d." % [card_id, slot_index])
        var linked_block: LinkedActionBlock = board.action_timing_panel.get_linked_block(1)
        if not is_instance_valid(linked_block) or not linked_block.tooltip_text.contains("제거"):
            failures.append("Reserved ultimate blocks must explain pre-commit removal: %s" % card_id)
        if str(board.get_layout_snapshot().get("presentation_state", "")) != "planning":
            failures.append("Reservation VFX rejection must be observed in actual planning: %s" % card_id)
        board._show_ultimate_vfx({"card_id": card_id})
        var planning_lane: Rect2 = board.get_layout_snapshot().get("presentation_vfx_rect", Rect2())
        if board.presentation_vfx.visible or planning_lane.has_area():
            failures.append("Planning must reject ultimate VFX without a valid execution lane: %s" % card_id)
        if board._presentation_vfx_tween != null and board._presentation_vfx_tween.is_valid():
            failures.append("Rejected planning VFX must not start an animation: %s" % card_id)
        board._on_timing_slot_clicked(span)
        if not board.action_timing_panel.get_placement(1).is_empty():
            failures.append("Reserved ultimate must be removable before progress: %s" % card_id)
        var refunded_player: Dictionary = board.combat_state.get("player", {})
        var refunded_momentum: Array = refunded_player.get("momentum", [0, 5])
        if int(refunded_momentum[0]) != 5:
            failures.append("Cancelling an ultimate reservation must refund momentum before progress: %s" % card_id)
        if not board._ultimate_reservation_anchors.is_empty():
            failures.append("Cancelling an ultimate reservation must clear its reservation lock: %s" % card_id)
        if not board.action_selection_dock.ultimate_panel.activate_ultimate(card_id):
            failures.append("The refunded ultimate must be selectable again before progress: %s" % card_id)
        board._set_presentation_state("resolving")
        board._on_timing_slot_clicked(1)
        var locked_player: Dictionary = board.combat_state.get("player", {})
        var locked_momentum: Array = locked_player.get("momentum", [5, 5])
        if board.action_timing_panel.get_placement(1).is_empty() or int(locked_momentum[0]) != 0:
            failures.append("Ultimate cancellation must remain locked after progress begins: %s" % card_id)

    board.queue_free()
    await process_frame

func _verify_ultimate_playback_visibility(card_id: String, execution_timing: int, expected_band: int) -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    # Legal nonattacking opponent isolates successful atlas routing. The real
    # dock, lock, resolver and CTA playback still execute; no outcome is injected.
    board.combat_state["ai_enabled"] = false
    board.resolution_engine.rules["enemy_bundles"] = {"1": [
        {"timing": 1, "card_id": "basic_meditate"},
        {"timing": 2, "card_id": "basic_meditate"},
        {"timing": 3, "card_id": "basic_meditate"}
    ]}
    board.resolution_engine.clear_locked_enemy_bundle()
    board.resolution_engine.lock_enemy_bundle(board.combat_state, 1)
    print("ULTIMATE_UI_LAWFUL_OPPONENT_FIXTURE id=%s enemy=three_basic_meditate actual_CTA=true" % card_id)
    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["momentum"] = [5, 5]
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    board.action_selection_dock.set_active_source("ultimate")
    if not board.action_selection_dock.ultimate_panel.activate_ultimate(card_id):
        failures.append("Playback VFX test could not select the ultimate through the product panel: %s" % card_id)
    else:
        board.action_timing_panel.set_placement_target(1, {"direction": 1, "target_tile": 5, "origin_tile": 4})
        board._clear_targeting()
        var meditate := _card_definition(board, "basic_meditate")
        var prepare := _card_definition(board, "basic_stance")
        for slot_index in range(execution_timing + 1, 4):
            board.action_timing_panel.place_card(meditate if slot_index == 2 else prepare, slot_index)
        board._sync_progress_availability()
        if not board.combat_progress_button.progress_enabled:
            failures.append("Playback VFX test could not complete the first bundle: %s" % card_id)
        else:
            board.combat_progress_button.request_progress()
            var ultimate_timing_seen := false
            var deadline := Time.get_ticks_msec() + 8000
            for _attempt in range(320):
                await process_frame
                var event: Dictionary = board.get_meta("presentation_feedback_event", {})
                if int(board.get_meta("presentation_timing", -1)) == execution_timing and str(event.get("card_id", "")) == card_id and str(event.get("actor", "")) == "player" and str(event.get("action_stage", "")) == "execution" and str(board.get_meta("presentation_feedback_kind", "")) == "ultimate" and str(board._visible_vfx_event.get("card_id", "")) == card_id and board._visible_vfx_kind == "ultimate" and board.presentation_vfx.is_visible_in_tree() and board.presentation_vfx.modulate.a > 0.0:
                    ultimate_timing_seen = true
                    break
                if Time.get_ticks_msec() >= deadline:
                    break
                await create_timer(0.025).timeout
            if not ultimate_timing_seen:
                failures.append("Ultimate playback must show positive-alpha execution VFX at timing %d within the bounded wait: %s" % [execution_timing, card_id])
            else:
                var atlas := board.presentation_vfx.texture as AtlasTexture
                if atlas == null or atlas.atlas == null:
                    failures.append("Actual ultimate playback must use the loaded atlas: %s" % card_id)
                else:
                    var sheet_size := atlas.atlas.get_size()
                    var expected_region := Rect2(0.0, float(expected_band) * sheet_size.y / 3.0, sheet_size.x, sheet_size.y / 3.0)
                    if not atlas.region.is_equal_approx(expected_region):
                        failures.append("Actual ultimate playback must select band %d: %s" % [expected_band, card_id])
                var lane: Rect2 = board.get_layout_snapshot().get("presentation_vfx_rect", Rect2())
                var global_lane := _transformed_rect(lane, board.get_global_transform())
                var global_effect := _transformed_rect(Rect2(Vector2.ZERO, board.presentation_vfx.size), board.presentation_vfx.get_global_transform())
                if not _positive_finite_rect(global_lane) or not _positive_finite_rect(global_effect) or not global_lane.grow(0.01).encloses(global_effect):
                    failures.append("Actual ultimate VFX must have positive global geometry contained in its execution lane: %s" % card_id)
                print("ULTIMATE_UI_ACTUAL_PLAYBACK id=%s timing=%d expected_band=%d actual_region=%s alpha=%.6f effect=%s lane=%s" % [card_id, int(board.get_meta("presentation_timing", -1)), expected_band, atlas.region if atlas != null else Rect2(), board.presentation_vfx.modulate.a, global_effect, global_lane])
            if board.action_selection_dock.switching_enabled:
                failures.append("The product action dock must remain locked during authoritative playback.")

    board.queue_free()
    await process_frame

func _transformed_rect(rect: Rect2, transform: Transform2D) -> Rect2:
    var result := Rect2(transform * rect.position, Vector2.ZERO)
    for point in [Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
        result = result.expand(transform * point)
    return result

func _positive_finite_rect(rect: Rect2) -> bool:
    return rect.position.is_finite() and rect.size.is_finite() and rect.has_area()

func _card_definition(board: CombatBoardPreview, card_id: String) -> Dictionary:
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == card_id:
            return card.definition.duplicate(true)
    return {}

func _finish() -> void:
    if failures.is_empty():
        print("ULTIMATE_UI_RESERVATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("ULTIMATE_UI_RESERVATION_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
