extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const BACKGROUND_ASSET_PATH := "res://assets/backgrounds/step3_mountain_fortress.svg"
const EXPECTED_TILE_COUNT := 10
const EXPECTED_PLAYER_TILE := 3
const EXPECTED_ENEMY_TILE := 8
const EXPECTED_HEIGHT_RATIO := 1.5
const EXPECTED_MOMENTUM_SEGMENTS := 5
const EXPECTED_TIMING_SEQUENCE := [3, 3, 4]
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
    for _index in range(6):
        await process_frame

    var snapshot := board.get_layout_snapshot()
    _verify_foundation(board, snapshot)
    _verify_hud(board, snapshot)
    _verify_timing_initial(board)
    _verify_cards_and_overlays(board, snapshot)
    await _verify_step9_placement(board)
    await _verify_step10_resolution(board)
    _verify_layout(board, board.get_layout_snapshot())
    _verify_character_anchors(board, board.get_layout_snapshot())

    board.queue_free()
    await process_frame
    _finish()

func _verify_foundation(board: CombatBoardPreview, snapshot: Dictionary) -> void:
    if not bool(snapshot.get("layout_ready", false)):
        failures.append("Combat board layout did not become ready.")
    if not bool(snapshot.get("background_ready", false)):
        failures.append("STEP 3 battle background did not load.")
    if board.tiles.size() != EXPECTED_TILE_COUNT:
        failures.append("Expected ten board tiles.")
    if board.get_child_count() == 0 or board.get_child(0) != board.battle_background:
        failures.append("Battle background must render behind the board.")
    if str(board.battle_background.get_meta("source_mode", "")) != "direct_vector_svg":
        failures.append("Battle background must use direct vector SVG loading.")

func _verify_hud(board: CombatBoardPreview, snapshot: Dictionary) -> void:
    if not bool(snapshot.get("hud_ready", false)) or board.top_hud == null:
        failures.append("STEP 4 top HUD did not instantiate.")
        return
    var hud := board.top_hud.get_hud_snapshot()
    if int(hud.get("momentum_segments", 0)) != EXPECTED_MOMENTUM_SEGMENTS:
        failures.append("Momentum gauges must use five segments.")
    if int(hud.get("round_number", 0)) != 1 or int(hud.get("bundle_index", 0)) != 1:
        failures.append("Combat must start at round 1 bundle 1.")
    if bool(snapshot.get("lower_status_panels", true)):
        failures.append("Status panels must remain in the top HUD.")

func _verify_timing_initial(board: CombatBoardPreview) -> void:
    if board.action_timing_panel == null:
        failures.append("ActionTimingPanel must exist.")
        return
    var timing := board.action_timing_panel.get_timing_snapshot()
    if timing.get("timing_sequence", []) != EXPECTED_TIMING_SEQUENCE:
        failures.append("Timing sequence must be 3, 3, 4.")
    if int(timing.get("current_bundle", 0)) != 1 or int(timing.get("current_timing", 0)) != 1:
        failures.append("STEP 10 combat must allow placement from timing 1.")
    var actionable: PackedInt32Array = timing.get("actionable_indices", PackedInt32Array())
    if actionable != PackedInt32Array([1, 2, 3]):
        failures.append("Initial actionable timings must be 1, 2, and 3.")
    if not bool(timing.get("state_advancement_enabled", false)):
        failures.append("Timing panel must expose STEP 10 state advancement.")

func _verify_cards_and_overlays(board: CombatBoardPreview, snapshot: Dictionary) -> void:
    if board.basic_card_tray == null:
        failures.append("Basic card tray must exist.")
        return
    var tray := board.basic_card_tray.get_tray_snapshot()
    if int(tray.get("card_count", 0)) != EXPECTED_CARD_IDS.size():
        failures.append("Basic card tray must contain seven cards.")
    var card_ids: PackedStringArray = tray.get("card_ids", PackedStringArray())
    for index in range(mini(card_ids.size(), EXPECTED_CARD_IDS.size())):
        if card_ids[index] != EXPECTED_CARD_IDS[index]:
            failures.append("Basic card order mismatch at index %d." % index)
    if not bool(snapshot.get("card_detail_ready", false)):
        failures.append("Card detail overlay must exist.")
    if not bool(snapshot.get("combat_log_ready", false)):
        failures.append("Combat log overlay must exist.")
    if board.combat_progress_button == null:
        failures.append("Progress button must exist.")
    elif board.combat_progress_button.progress_enabled:
        failures.append("Progress button must start disabled before placements.")

func _card_definition(board: CombatBoardPreview, card_id: String) -> Dictionary:
    for card in board.basic_card_tray.cards:
        if str(card.definition.get("id", "")) == card_id:
            return card.definition.duplicate(true)
    return {}

func _verify_step9_placement(board: CombatBoardPreview) -> void:
    var heavy := _card_definition(board, "basic_heavy_attack")
    if heavy.is_empty():
        failures.append("Heavy attack definition was not found.")
        return
    if not board.action_timing_panel.place_card(heavy, 1):
        failures.append("STEP 9 must place a two-slot card at timings 1 and 2.")
        return
    if not board.action_timing_panel.has_assignment_at(1) or not board.action_timing_panel.has_assignment_at(2):
        failures.append("Two-slot placement must occupy consecutive timings.")
    var removed := board.action_timing_panel.remove_at(2)
    if str(removed.get("card_id", "")) != "basic_heavy_attack":
        failures.append("Clicking either occupied part must remove the whole card.")
    await process_frame

func _verify_step10_resolution(board: CombatBoardPreview) -> void:
    var move := _card_definition(board, "basic_move")
    var meditate := _card_definition(board, "basic_meditate")
    var quick := _card_definition(board, "basic_quick_attack")
    if move.is_empty() or meditate.is_empty() or quick.is_empty():
        failures.append("STEP 10 test cards were not found.")
        return

    if not board.action_timing_panel.place_card(move, 1):
        failures.append("Move must place at timing 1.")
    if not board.action_timing_panel.place_card(meditate, 2):
        failures.append("Meditate must place at timing 2.")
    if not board.action_timing_panel.place_card(quick, 3):
        failures.append("Quick attack must place at timing 3.")
    await process_frame

    if not board.action_timing_panel.is_current_bundle_complete():
        failures.append("The first bundle must be complete after filling timings 1-3.")
    if not board.combat_progress_button.progress_enabled:
        failures.append("Progress button must enable when the current bundle is complete.")

    var before_state := board.get_combat_state_snapshot()
    var before_log_count := int(board.combat_log_panel.get_log_snapshot().get("entry_count", 0))
    board.combat_progress_button.request_progress()
    await process_frame
    await process_frame

    var after_state := board.get_combat_state_snapshot()
    var timing := board.action_timing_panel.get_timing_snapshot()
    if int(board.get_meta("resolution_count", 0)) != 1:
        failures.append("STEP 10 progress must execute exactly one bundle resolution.")
    if int(timing.get("current_bundle", 0)) != 2 or int(timing.get("current_timing", 0)) != 4:
        failures.append("Resolving bundle 1 must advance to bundle 2 timing 4.")
    if int(after_state.get("round_number", 0)) != 1 or int(after_state.get("bundle_index", 0)) != 2:
        failures.append("Combat state must advance to round 1 bundle 2.")

    var player_before: Dictionary = before_state.get("player", {})
    var enemy_before: Dictionary = before_state.get("enemy", {})
    var player_after: Dictionary = after_state.get("player", {})
    var enemy_after: Dictionary = after_state.get("enemy", {})
    if int(player_after.get("tile", 0)) != int(player_before.get("tile", 0)) + 1:
        failures.append("Player move must update the board tile from 3 to 4.")
    if int(enemy_after.get("tile", 0)) != int(enemy_before.get("tile", 0)) - 1:
        failures.append("Fixed enemy move must update the tile from 8 to 7.")
    var player_stamina: Array = player_after.get("stamina", [])
    if player_stamina.is_empty() or int(player_stamina[0]) != 4:
        failures.append("Meditate and quick attack must produce the expected player stamina value 4.")

    var after_log_count := int(board.combat_log_panel.get_log_snapshot().get("entry_count", 0))
    if after_log_count <= before_log_count:
        failures.append("STEP 10 resolution must append combat-log entries.")
    if board.combat_progress_button.progress_enabled:
        failures.append("The next bundle must require new placements before progress enables again.")
    if not bool(board.get_layout_snapshot().get("state_advancement_enabled", false)):
        failures.append("Board snapshot must expose enabled state advancement.")
    if bool(board.get_layout_snapshot().get("interruption_enabled", true)):
        failures.append("STEP 11 interruption must remain disabled during STEP 10.")

func _verify_layout(board: CombatBoardPreview, snapshot: Dictionary) -> void:
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

func _verify_character_anchors(board: CombatBoardPreview, snapshot: Dictionary) -> void:
    var player_size: Vector2 = snapshot.get("player_size", Vector2.ZERO)
    var enemy_size: Vector2 = snapshot.get("enemy_size", Vector2.ZERO)
    if player_size.distance_to(enemy_size) > SIZE_TOLERANCE:
        failures.append("Player and enemy placeholders must use identical scale.")
    var tile_width := float(snapshot.get("tile_width", 0.0))
    if tile_width > 0.0 and absf(player_size.y / tile_width - EXPECTED_HEIGHT_RATIO) > SIZE_TOLERANCE:
        failures.append("Character height ratio must remain 1.5.")
    var player_foot: Vector2 = snapshot.get("player_foot", Vector2.ZERO)
    var player_anchor: Vector2 = snapshot.get("player_tile_anchor", Vector2.ZERO)
    var enemy_foot: Vector2 = snapshot.get("enemy_foot", Vector2.ZERO)
    var enemy_anchor: Vector2 = snapshot.get("enemy_tile_anchor", Vector2.ZERO)
    if player_foot.distance_to(player_anchor) > POSITION_TOLERANCE:
        failures.append("Player foot anchor must match the runtime player tile.")
    if enemy_foot.distance_to(enemy_anchor) > POSITION_TOLERANCE:
        failures.append("Enemy foot anchor must match the runtime enemy tile.")

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_STEP7_STEP8_STEP9_STEP10_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_STEP7_STEP8_STEP9_STEP10_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
