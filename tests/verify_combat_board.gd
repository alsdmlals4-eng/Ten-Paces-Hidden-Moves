extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const BACKGROUND_ASSET_PATH := "res://assets/backgrounds/twilight_ink_duel_v1.png"
const EXPECTED_TILE_COUNT := 10
const EXPECTED_PLAYER_TILE := 4
const EXPECTED_ENEMY_TILE := 7
const EXPECTED_HEIGHT_RATIO := 1.5
const EXPECTED_MOMENTUM_SEGMENTS := 5
const EXPECTED_TIMING_SEQUENCE := [3, 3, 4]
const EXPECTED_CARD_IDS := [
    "basic_move",
    "basic_footwork",
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

    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(6):
        await process_frame

    var snapshot := board.get_layout_snapshot()
    _verify_foundation(board, snapshot)
    _verify_hud(board, snapshot)
    _verify_timing_initial(board)
    _verify_cards_and_overlays(board, snapshot)
    await _verify_footwork_targeting(board)
    await _verify_step9_placement(board)
    _verify_rule_resolution(board)
    await _verify_targeting_10_5_and_step10_resolution(board)
    _verify_wrong_attack_direction(board)
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
    if int(snapshot.get("player_tile", 0)) != EXPECTED_PLAYER_TILE:
        failures.append("Player must start on tile %d." % EXPECTED_PLAYER_TILE)
    if int(snapshot.get("enemy_tile", 0)) != EXPECTED_ENEMY_TILE:
        failures.append("Enemy must start on tile %d." % EXPECTED_ENEMY_TILE)
    if int(board.get_meta("player_start_tile", 0)) != EXPECTED_PLAYER_TILE:
        failures.append("Board metadata must expose player start tile %d." % EXPECTED_PLAYER_TILE)
    if int(board.get_meta("enemy_start_tile", 0)) != EXPECTED_ENEMY_TILE:
        failures.append("Board metadata must expose enemy start tile %d." % EXPECTED_ENEMY_TILE)
    if board.get_child_count() == 0 or board.get_child(0) != board.battle_background:
        failures.append("Battle background must render behind the board.")
    if str(board.battle_background.get_meta("source_mode", "")) != "project_original_raster_png":
        failures.append("Battle background must use the approved original raster asset.")
    for tile in board.tiles:
        if not tile.has_signal("tile_clicked"):
            failures.append("Every board tile must expose a tile_clicked signal for TARGETING_10_5.")

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

    var state := board.get_combat_state_snapshot()
    for side in ["player", "enemy"]:
        var actor: Dictionary = state.get(side, {})
        for resource_key in ["health", "stamina", "internal"]:
            var pair: Array = actor.get(resource_key, [])
            if pair.size() < 2 or int(pair[0]) != int(pair[1]):
                failures.append("%s %s must start at maximum unless a start penalty exists." % [side, resource_key])

    var penalized_data: Dictionary = board.top_hud.hud_data.duplicate(true)
    var penalized_player: Dictionary = penalized_data.get("player", {})
    penalized_player["health"] = [1, 20]
    penalized_player["stamina"] = [1, 5]
    penalized_player["internal"] = [1, 4]
    penalized_player["start_penalties"] = {"health": 2, "stamina": 1, "internal": 3}
    penalized_data["player"] = penalized_player
    var penalized_state := CombatResolutionEngine.new().make_initial_state(penalized_data, EXPECTED_PLAYER_TILE, EXPECTED_ENEMY_TILE)
    var result_player: Dictionary = penalized_state.get("player", {})
    if result_player.get("health", []) != [18, 20]:
        failures.append("Health start penalty must reduce maximum health at combat start.")
    if result_player.get("stamina", []) != [4, 5]:
        failures.append("Stamina start penalty must reduce maximum stamina at combat start.")
    if result_player.get("internal", []) != [1, 4]:
        failures.append("Internal-energy start penalty must reduce maximum internal energy at combat start.")

func _verify_timing_initial(board: CombatBoardPreview) -> void:
    if board.action_timing_panel == null:
        failures.append("ActionTimingPanel must exist.")
        return
    var timing := board.action_timing_panel.get_timing_snapshot()
    var timing_sequence: Array = timing.get("timing_sequence", [])
    var normalized_sequence := PackedInt32Array()
    for value in timing_sequence:
        normalized_sequence.append(int(value))
    if normalized_sequence != PackedInt32Array(EXPECTED_TIMING_SEQUENCE):
        failures.append("Timing sequence must be 3, 3, 4. actual=%s" % str(timing_sequence))
    if int(timing.get("current_bundle", 0)) != 1 or int(timing.get("current_timing", 0)) != 1:
        failures.append("STEP 10 combat must allow placement from timing 1.")
    var actionable: PackedInt32Array = timing.get("actionable_indices", PackedInt32Array())
    if actionable != PackedInt32Array([1, 2, 3]):
        failures.append("Initial actionable timings must be 1, 2, and 3.")
    if not bool(timing.get("state_advancement_enabled", false)):
        failures.append("Timing panel must expose STEP 10 state advancement.")
    if not bool(timing.get("targeting_enabled", false)):
        failures.append("Timing panel must expose TARGETING_10_5.")

func _verify_cards_and_overlays(board: CombatBoardPreview, snapshot: Dictionary) -> void:
    if board.basic_card_tray == null:
        failures.append("Basic card tray must exist.")
        return
    var tray := board.basic_card_tray.get_tray_snapshot()
    if int(tray.get("card_count", 0)) != EXPECTED_CARD_IDS.size():
        failures.append("Basic card tray must contain eight cards.")
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

func _verify_footwork_targeting(board: CombatBoardPreview) -> void:
    var footwork := _card_definition(board, "basic_footwork")
    if footwork.is_empty():
        failures.append("Footwork definition was not found.")
        return
    if int(footwork.get("move_range", 0)) != 2 or int(footwork.get("internal_cost", 0)) != 1:
        failures.append("Footwork must cost one internal energy and allow up to two tiles.")
    if not board.action_timing_panel.place_card(footwork, 1):
        failures.append("Footwork must place at timing 1.")
        return
    if not board._begin_targeting_for_anchor(1):
        failures.append("Footwork must enter board-tile targeting mode.")
        board.action_timing_panel.remove_at(1)
        return
    if board.get_tile(5).interaction_state != "movable" or board.get_tile(6).interaction_state != "movable":
        failures.append("Footwork must allow choosing either one tile or two tiles to the right from tile 4.")
    board._on_board_tile_clicked(6)
    await process_frame
    var placement := board.action_timing_panel.get_placement(1)
    if int(placement.get("target_tile", 0)) != 6:
        failures.append("Footwork must store the selected two-tile destination from tile 4 to tile 6.")
    board.action_timing_panel.remove_at(1)
    board._clear_targeting()
    await process_frame

func _verify_step9_placement(board: CombatBoardPreview) -> void:
    var heavy := _card_definition(board, "basic_heavy_attack")
    if heavy.is_empty():
        failures.append("Heavy attack definition was not found.")
        return
    if str(heavy.get("range_text", "")) != "2" or int(heavy.get("internal_cost", 0)) != 1:
        failures.append("Heavy attack must have range 2 and cost one internal energy.")
    if not board.action_timing_panel.place_card(heavy, 1):
        failures.append("STEP 9 must place a two-slot card at timings 1 and 2.")
        return
    if not board.action_timing_panel.has_assignment_at(1) or not board.action_timing_panel.has_assignment_at(2):
        failures.append("Two-slot placement must occupy consecutive timings.")
    if board.action_timing_panel.is_current_bundle_complete():
        failures.append("An attack without a selected direction must not complete the bundle.")
    if not board._begin_targeting_for_anchor(1):
        failures.append("Heavy attack must enter attack-direction targeting mode.")
    elif board.get_tile(5).interaction_state != "attackable" or board.get_tile(6).interaction_state != "attackable":
        failures.append("Heavy attack must expose distance 1 and distance 2 to the right from tile 4.")
    board._clear_targeting()
    var removed := board.action_timing_panel.remove_at(2)
    if str(removed.get("card_id", "")) != "basic_heavy_attack":
        failures.append("Clicking either occupied part must remove the whole card.")
    await process_frame

func _verify_rule_resolution(board: CombatBoardPreview) -> void:
    var engine := CombatResolutionEngine.new()
    engine.rules["enemy_bundles"] = {}
    var footwork := _card_definition(board, "basic_footwork")
    var heavy := _card_definition(board, "basic_heavy_attack")

    var footwork_state := engine.make_initial_state(board.top_hud.hud_data, EXPECTED_PLAYER_TILE, EXPECTED_ENEMY_TILE)
    var footwork_placement := {
        "card_id": "basic_footwork",
        "card_name": "보법",
        "definition": footwork,
        "anchor_index": 1,
        "span": 1,
        "indices": PackedInt32Array([1]),
        "targeting_mode": "move_tile",
        "target_ready": true,
        "target_tile": 6,
        "direction": 1,
        "origin_tile": EXPECTED_PLAYER_TILE
    }
    var footwork_result := engine.resolve_bundle([footwork_placement], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, footwork_state)
    var footwork_player: Dictionary = (footwork_result.get("state", {}) as Dictionary).get("player", {})
    if int(footwork_player.get("tile", 0)) != 6:
        failures.append("Footwork must move the player two tiles when tile 6 is selected from tile 4.")
    var footwork_internal: Array = footwork_player.get("internal", [])
    if footwork_internal.size() < 2 or int(footwork_internal[0]) != int(footwork_internal[1]) - 1:
        failures.append("Footwork must consume exactly one internal energy.")

    var heavy_state := engine.make_initial_state(board.top_hud.hud_data, EXPECTED_PLAYER_TILE, 6)
    var heavy_placement := {
        "card_id": "basic_heavy_attack",
        "card_name": "강공",
        "definition": heavy,
        "anchor_index": 1,
        "span": 2,
        "indices": PackedInt32Array([1, 2]),
        "targeting_mode": "attack_direction",
        "target_ready": true,
        "target_tile": 6,
        "direction": 1,
        "origin_tile": EXPECTED_PLAYER_TILE
    }
    var heavy_result := engine.resolve_bundle([heavy_placement], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, heavy_state)
    var heavy_state_after: Dictionary = heavy_result.get("state", {})
    var heavy_player: Dictionary = heavy_state_after.get("player", {})
    var heavy_enemy: Dictionary = heavy_state_after.get("enemy", {})
    var heavy_internal: Array = heavy_player.get("internal", [])
    var heavy_health: Array = heavy_enemy.get("health", [])
    if heavy_internal.size() < 2 or int(heavy_internal[0]) != int(heavy_internal[1]) - 1:
        failures.append("Heavy attack must consume exactly one internal energy.")
    if heavy_health.size() < 2 or int(heavy_health[0]) >= int(heavy_health[1]):
        failures.append("Heavy attack must hit an enemy at distance two in the selected direction.")

func _verify_targeting_10_5_and_step10_resolution(board: CombatBoardPreview) -> void:
    var move := _card_definition(board, "basic_move")
    var meditate := _card_definition(board, "basic_meditate")
    var quick := _card_definition(board, "basic_quick_attack")
    if move.is_empty() or meditate.is_empty() or quick.is_empty():
        failures.append("STEP 10 targeting test cards were not found.")
        return

    if not board.action_timing_panel.place_card(move, 1):
        failures.append("Move must place at timing 1.")
    if not board.action_timing_panel.place_card(meditate, 2):
        failures.append("Meditate must place at timing 2.")
    if not board.action_timing_panel.place_card(quick, 3):
        failures.append("Quick attack must place at timing 3.")
    await process_frame

    if board.action_timing_panel.is_current_bundle_complete():
        failures.append("Move and attack placements must require targets before progress enables.")
    if board.combat_progress_button.progress_enabled:
        failures.append("Progress must remain disabled while a movement tile or attack direction is unresolved.")
    if board.action_timing_panel.get_pending_target_anchor() != 1:
        failures.append("Move at timing 1 must be the first pending target.")

    if not board._begin_targeting_for_anchor(1):
        failures.append("Move placement must enter board-tile targeting mode.")
        return
    if board.get_tile(5).interaction_state != "movable":
        failures.append("Tile 5 must be marked movable from player tile 4.")
    if board.get_tile(6).interaction_state == "movable":
        failures.append("Basic movement targeting must not exceed one tile.")
    board._on_board_tile_clicked(5)
    await process_frame

    var move_placement := board.action_timing_panel.get_placement(1)
    if not bool(move_placement.get("target_ready", false)) or int(move_placement.get("target_tile", 0)) != 5:
        failures.append("Move targeting must store destination tile 5.")
    if int(move_placement.get("direction", 0)) != 1:
        failures.append("Move targeting must store the rightward direction.")

    if int(board.get_meta("targeting_anchor", 0)) != 3:
        failures.append("After movement targeting, the pending quick attack must become active.")
    if board.get_tile(6).interaction_state != "attackable":
        failures.append("Projected attack origin tile 5 must expose tile 6 as the right attack direction.")
    board._on_board_tile_clicked(6)
    await process_frame

    var quick_placement := board.action_timing_panel.get_placement(3)
    if not bool(quick_placement.get("target_ready", false)) or int(quick_placement.get("direction", 0)) != 1:
        failures.append("Attack targeting must store the selected right direction.")
    if not board.action_timing_panel.is_current_bundle_complete():
        failures.append("The first bundle must complete after all slots and targets are set.")
    if not board.combat_progress_button.progress_enabled:
        failures.append("Progress button must enable when placements and targets are complete.")

    var before_state := board.get_combat_state_snapshot()
    var before_log_count := int(board.combat_log_panel.get_log_snapshot().get("entry_count", 0))
    board.combat_progress_button.request_progress()
    await process_frame
    var presenting_snapshot := board.get_layout_snapshot()
    if not bool(presenting_snapshot.get("inputs_locked", false)):
        failures.append("Committed-to-presentation resolution must lock combat planning inputs.")
    if str(presenting_snapshot.get("presentation_state", "")) not in ["resolving", "presenting_result"]:
        failures.append("Resolution must enter resolving or presenting_result before the next bundle is ready.")
    await create_timer(2.3).timeout

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
    if int(player_before.get("tile", 0)) != EXPECTED_PLAYER_TILE or int(player_after.get("tile", 0)) != 5:
        failures.append("Explicit move target must update the player tile from 4 to 5.")
    if int(enemy_before.get("tile", 0)) != EXPECTED_ENEMY_TILE or int(enemy_after.get("tile", 0)) != 6:
        failures.append("Fixed enemy move direction must update the tile from 7 to 6.")
    var player_stamina: Array = player_after.get("stamina", [])
    if player_stamina.is_empty() or int(player_stamina[0]) != 4:
        failures.append("Meditate and quick attack must produce the expected player stamina value 4.")

    var after_log_count := int(board.combat_log_panel.get_log_snapshot().get("entry_count", 0))
    if after_log_count <= before_log_count:
        failures.append("Targeting and resolution must append combat-log entries.")
    if board.combat_progress_button.progress_enabled:
        failures.append("The next bundle must require new placements before progress enables again.")
    var snapshot := board.get_layout_snapshot()
    if not bool(snapshot.get("targeting_enabled", false)):
        failures.append("Board snapshot must expose TARGETING_10_5.")
    if not bool(snapshot.get("state_advancement_enabled", false)):
        failures.append("Board snapshot must expose enabled state advancement.")
    if not bool(snapshot.get("interruption_enabled", false)):
        failures.append("Issue #11 interruption must be enabled after the combat contract update.")
    var presentation_history: PackedStringArray = snapshot.get("presentation_state_history", PackedStringArray())
    for required_state in ["committed", "resolving", "presenting_result", "next_bundle_ready"]:
        if required_state not in presentation_history:
            failures.append("Presentation state history must include %s." % required_state)

func _verify_wrong_attack_direction(board: CombatBoardPreview) -> void:
    var quick := _card_definition(board, "basic_quick_attack")
    if quick.is_empty():
        return
    var engine := CombatResolutionEngine.new()
    engine.rules["enemy_bundles"] = {}
    var state := engine.make_initial_state(board.top_hud.hud_data, EXPECTED_PLAYER_TILE, 5)
    var placement := {
        "card_id": "basic_quick_attack",
        "card_name": "속공",
        "definition": quick,
        "anchor_index": 1,
        "span": 1,
        "indices": PackedInt32Array([1]),
        "targeting_mode": "attack_direction",
        "target_ready": true,
        "target_tile": 3,
        "direction": -1,
        "origin_tile": EXPECTED_PLAYER_TILE
    }
    var result := engine.resolve_bundle([placement], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    var found_miss_direction := false
    for record_value in result.get("resolved_actions", []):
        var record: Dictionary = record_value
        if str(record.get("actor", "")) == "player" and str(record.get("outcome", "")) == "miss_direction":
            found_miss_direction = true
    if not found_miss_direction:
        failures.append("An attack aimed away from an adjacent enemy must resolve as miss_direction.")

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
        print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_STEP7_STEP8_STEP9_STEP10_TARGETING_10_5_START_4_7_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_STEP7_STEP8_STEP9_STEP10_TARGETING_10_5_START_4_7_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
