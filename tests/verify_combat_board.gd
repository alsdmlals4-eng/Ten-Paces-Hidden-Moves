extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const BACKGROUND_ASSET_PATH := "res://assets/backgrounds/step3_mountain_fortress.svg"
const EXPECTED_CARD_IDS := [
    "basic_move",
    "basic_guard",
    "basic_evade",
    "basic_quick_attack",
    "basic_heavy_attack",
    "basic_meditate",
    "basic_stance"
]
const POSITION_TOLERANCE := 0.75
const SIZE_TOLERANCE := 0.01

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    if not ResourceLoader.exists(BACKGROUND_ASSET_PATH):
        failures.append("STEP 3 battle background asset was not found.")
    if not ResourceLoader.exists(BOARD_SCENE_PATH):
        failures.append("Combat board preview scene was not found.")
        _finish()
        return

    var packed := load(BOARD_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Combat board preview scene could not be loaded.")
        _finish()
        return

    var board := packed.instantiate() as CombatBoardPreview
    if board == null:
        failures.append("Combat board preview scene could not instantiate as CombatBoardPreview.")
        _finish()
        return

    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _frame in range(6):
        await process_frame

    _verify_foundation(board)
    await _verify_step7_information(board)
    await _verify_step9_placement(board)
    _verify_layout(board)

    board.queue_free()
    await process_frame
    _finish()

func _verify_foundation(board: CombatBoardPreview) -> void:
    var snapshot := board.get_layout_snapshot()
    if not bool(snapshot.get("layout_ready", false)):
        failures.append("Combat board layout did not become ready.")
    if not bool(snapshot.get("background_ready", false)):
        failures.append("STEP 3 background did not load.")
    if board.battle_background == null or board.battle_background.texture == null:
        failures.append("BattleBackground texture must exist.")
    if board.tiles.size() != 10:
        failures.append("Board must contain exactly ten tiles.")
    if int(snapshot.get("player_tile", 0)) != 3 or int(snapshot.get("enemy_tile", 0)) != 8:
        failures.append("Player and enemy must start on tiles 3 and 8.")

    if board.top_hud == null:
        failures.append("TopCombatHud must exist.")
    else:
        var hud := board.top_hud.get_hud_snapshot()
        if int(hud.get("momentum_segments", 0)) != 5:
            failures.append("Ultimate momentum must use five segments.")
        if str(hud.get("layout", "")) != "player_status|player_momentum|round|enemy_momentum|enemy_status":
            failures.append("Top HUD order is incorrect.")

    if board.action_timing_panel == null:
        failures.append("ActionTimingPanel must exist.")
    else:
        var timing := board.action_timing_panel.get_timing_snapshot()
        if timing.get("timing_sequence", []) != [3, 3, 4]:
            failures.append("Action timing sequence must be 3, 3, 4.")
        if int(timing.get("total_timings", 0)) != 10:
            failures.append("Action timing must contain ten slots.")
        if int(timing.get("round_number", 0)) != 1:
            failures.append("Preview round must be 1.")
        if int(timing.get("current_bundle", 0)) != 2 or int(timing.get("current_timing", 0)) != 5:
            failures.append("Preview must use bundle 2 and timing 5.")
        if int(timing.get("placement_step", 0)) != 9:
            failures.append("Action placement must be introduced by STEP 9.")
        if not bool(timing.get("placement_enabled", false)):
            failures.append("STEP 9 action timing placement must be enabled.")
        var actionable: PackedInt32Array = timing.get("actionable_indices", PackedInt32Array())
        if actionable.size() != 2 or int(actionable[0]) != 5 or int(actionable[1]) != 6:
            failures.append("Only timings 5 and 6 must be actionable in the preview.")
        if bool(timing.get("current_bundle_complete", true)):
            failures.append("Current bundle must start incomplete.")

    if board.basic_card_tray == null or board.basic_card_tray.cards.size() != 7:
        failures.append("Basic card tray must contain seven cards.")
    else:
        var ids := board.basic_card_tray.get_card_ids()
        for index in range(EXPECTED_CARD_IDS.size()):
            if index >= ids.size() or ids[index] != EXPECTED_CARD_IDS[index]:
                failures.append("Basic card order mismatch at index %d." % index)
        var tray := board.basic_card_tray.get_tray_snapshot()
        if int(tray.get("placement_step", 0)) != 9:
            failures.append("Basic card placement must declare STEP 9.")
        if not bool(tray.get("action_placement_enabled", false)):
            failures.append("Basic cards must enable placement in STEP 9.")

    if board.combat_progress_button == null:
        failures.append("CombatProgressButton must exist.")
    else:
        var progress := board.combat_progress_button.get_progress_snapshot()
        if bool(progress.get("enabled", true)):
            failures.append("Progress must start disabled until the current bundle is complete.")
        if not bool(progress.get("action_placement_required", false)):
            failures.append("Progress must require action placement.")
        if bool(progress.get("advances_state", true)):
            failures.append("STEP 9 progress must still be signal-only.")

    var player_size: Vector2 = snapshot.get("player_size", Vector2.ZERO)
    var enemy_size: Vector2 = snapshot.get("enemy_size", Vector2.ZERO)
    if player_size.distance_to(enemy_size) > SIZE_TOLERANCE:
        failures.append("Player and enemy placeholders must use equal scale.")
    var tile_width := float(snapshot.get("tile_width", 0.0))
    if tile_width <= 0.0 or absf(player_size.y / tile_width - 1.5) > SIZE_TOLERANCE:
        failures.append("Character height must remain 1.5 tile widths.")
    var player_foot: Vector2 = snapshot.get("player_foot", Vector2.ZERO)
    var player_anchor: Vector2 = snapshot.get("player_tile_anchor", Vector2.ZERO)
    var enemy_foot: Vector2 = snapshot.get("enemy_foot", Vector2.ZERO)
    var enemy_anchor: Vector2 = snapshot.get("enemy_tile_anchor", Vector2.ZERO)
    if player_foot.distance_to(player_anchor) > POSITION_TOLERANCE:
        failures.append("Player foot anchor must match tile 3.")
    if enemy_foot.distance_to(enemy_anchor) > POSITION_TOLERANCE:
        failures.append("Enemy foot anchor must match tile 8.")

func _verify_step7_information(board: CombatBoardPreview) -> void:
    if board.card_detail_panel == null or board.combat_log_panel == null:
        failures.append("STEP 7 detail and log overlays must exist.")
        return
    if board.card_detail_panel.visible:
        failures.append("Card detail must start hidden.")
    if not bool(board.combat_log_panel.get_log_snapshot().get("collapsed", false)):
        failures.append("Combat log must start collapsed.")

    var quick := _find_card_definition(board, "basic_quick_attack")
    board._on_card_hovered(quick)
    if not board.card_detail_panel.visible or board.card_detail_panel.pinned:
        failures.append("Card hover must show an unpinned detail preview.")
    board._on_card_unhovered("basic_quick_attack")
    if board.card_detail_panel.visible:
        failures.append("Card unhover must close an unpinned preview.")

    board.combat_log_panel.set_collapsed(false)
    await process_frame
    if bool(board.combat_log_panel.get_log_snapshot().get("collapsed", true)):
        failures.append("Combat log must expand.")
    board.combat_log_panel.set_collapsed(true)
    await process_frame

func _verify_step9_placement(board: CombatBoardPreview) -> void:
    var timing := board.action_timing_panel
    var progress := board.combat_progress_button
    var log_count_before := int(board.combat_log_panel.get_log_snapshot().get("entry_count", 0))
    var quick := _find_card_definition(board, "basic_quick_attack")
    var guard := _find_card_definition(board, "basic_guard")
    var heavy := _find_card_definition(board, "basic_heavy_attack")

    if quick.is_empty() or guard.is_empty() or heavy.is_empty():
        failures.append("STEP 9 verification cards were not found.")
        return

    board._on_action_card_selected(quick)
    if str(board.basic_card_tray.selected_card_id) != "basic_quick_attack":
        failures.append("Clicking a card must select it for placement.")
    if not board.card_detail_panel.visible or not board.card_detail_panel.pinned:
        failures.append("Placement selection must also pin card detail.")
    board._on_timing_slot_clicked(5)
    if not timing.has_assignment_at(5):
        failures.append("A one-slot card must occupy timing 5.")
    if not board.basic_card_tray.selected_card_id.is_empty():
        failures.append("Card selection must clear after successful placement.")
    if progress.progress_enabled:
        failures.append("Progress must remain disabled while timing 6 is empty.")

    board._on_action_card_selected(guard)
    board._on_timing_slot_clicked(6)
    if not timing.has_assignment_at(6):
        failures.append("A one-slot card must occupy timing 6.")
    if not timing.is_current_bundle_complete():
        failures.append("Timings 5 and 6 filled must complete the current bundle.")
    if not progress.progress_enabled:
        failures.append("Progress must enable when all remaining current-bundle slots are filled.")

    var round_before := int(timing.get_timing_snapshot().get("round_number", 0))
    var current_before := int(timing.get_timing_snapshot().get("current_timing", 0))
    var request_before := progress.request_count
    progress.request_progress()
    await process_frame
    if progress.request_count != request_before + 1:
        failures.append("Enabled progress must emit one request.")
    if int(timing.get_timing_snapshot().get("round_number", 0)) != round_before:
        failures.append("STEP 9 progress must not advance the round.")
    if int(timing.get_timing_snapshot().get("current_timing", 0)) != current_before:
        failures.append("STEP 9 progress must not advance the timing.")

    board._on_timing_slot_clicked(5)
    if timing.has_assignment_at(5):
        failures.append("Clicking an occupied one-slot timing must remove it.")
    if progress.progress_enabled:
        failures.append("Removing a placement must disable progress again.")
    board._on_timing_slot_clicked(6)

    board._on_action_card_selected(heavy)
    board._on_timing_slot_clicked(5)
    if not timing.has_assignment_at(5) or not timing.has_assignment_at(6):
        failures.append("A two-slot card must occupy consecutive timings 5 and 6.")
    var slot5 := timing.get_slot(5)
    var slot6 := timing.get_slot(6)
    if slot5.assignment_anchor_index != 5 or slot6.assignment_anchor_index != 5:
        failures.append("Both parts of a two-slot card must share one anchor.")
    if not progress.progress_enabled:
        failures.append("A two-slot card filling both timings must enable progress.")
    board._on_timing_slot_clicked(6)
    if timing.has_assignment_at(5) or timing.has_assignment_at(6):
        failures.append("Clicking either part of a two-slot card must remove the whole card.")

    board._on_action_card_selected(heavy)
    board._on_timing_slot_clicked(6)
    if timing.has_assignment_at(6):
        failures.append("A two-slot card must not start at the final actionable timing.")
    board._clear_action_selection()
    if timing.place_card(quick, 4):
        failures.append("Passed timing 4 must reject placement.")
    if timing.place_card(quick, 7):
        failures.append("Locked timing 7 must reject placement.")

    var log_count_after := int(board.combat_log_panel.get_log_snapshot().get("entry_count", 0))
    if log_count_after <= log_count_before:
        failures.append("Placement, removal, and progress must write combat log entries.")

func _find_card_definition(board: CombatBoardPreview, card_id: String) -> Dictionary:
    if board.basic_card_tray == null:
        return {}
    return board.basic_card_tray.get_card_definition(card_id)

func _verify_layout(board: CombatBoardPreview) -> void:
    var snapshot := board.get_layout_snapshot()
    var board_bottom := float(snapshot.get("board_bottom", 0.0))
    var timing_top := float(snapshot.get("action_timing_top", 0.0))
    var timing_bottom := float(snapshot.get("action_timing_bottom", 0.0))
    var tray_top := float(snapshot.get("basic_card_tray_top", 0.0))
    var tray_bottom := float(snapshot.get("basic_card_tray_bottom", 0.0))
    if timing_top <= board_bottom:
        failures.append("Action timing panel must not overlap the board.")
    if tray_top <= timing_bottom:
        failures.append("Card tray must not overlap action timing.")
    if tray_bottom > board.size.y + SIZE_TOLERANCE:
        failures.append("Card tray must remain inside the viewport.")
    if float(snapshot.get("progress_button_left", 0.0)) <= board.action_timing_panel.position.x + board.action_timing_panel.size.x:
        failures.append("Progress button must remain to the right of action timing.")
    if absf(float(snapshot.get("progress_button_top", 0.0)) - timing_top) > SIZE_TOLERANCE:
        failures.append("Progress button and action timing must share a row.")

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_STEP7_STEP8_STEP9_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_STEP7_STEP8_STEP9_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
