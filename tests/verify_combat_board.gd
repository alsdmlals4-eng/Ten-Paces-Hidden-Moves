extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const BACKGROUND_ASSET_PATH := "res://assets/backgrounds/step3_mountain_fortress.svg"
const EXPECTED_TILE_COUNT := 10
const EXPECTED_PLAYER_TILE := 3
const EXPECTED_ENEMY_TILE := 8
const EXPECTED_HEIGHT_RATIO := 1.5
const EXPECTED_MOMENTUM_SEGMENTS := 6
const EXPECTED_TIMING_SEQUENCE := [3, 3, 4]
const EXPECTED_TIMING_COUNT := 10
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
        failures.append("STEP 3 battle background asset was not found: %s" % BACKGROUND_ASSET_PATH)

    if not ResourceLoader.exists(BOARD_SCENE_PATH):
        failures.append("Combat board preview scene was not found: %s" % BOARD_SCENE_PATH)
        _finish()
        return

    var packed := load(BOARD_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("Combat board preview scene could not be loaded.")
        _finish()
        return

    var board := packed.instantiate() as CombatBoardPreview
    if board == null:
        failures.append("Combat board preview scene could not be instantiated as CombatBoardPreview.")
        _finish()
        return

    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    await process_frame
    await process_frame
    await process_frame
    await process_frame

    var snapshot := board.get_layout_snapshot()
    if not bool(snapshot.get("layout_ready", false)):
        failures.append("Combat board layout did not become ready.")

    if not bool(snapshot.get("background_ready", false)):
        failures.append("STEP 3 battle background did not load a texture.")
    if str(snapshot.get("background_path", "")) != BACKGROUND_ASSET_PATH:
        failures.append("STEP 3 background path does not match the approved asset.")
    if board.battle_background == null:
        failures.append("BattleBackground component must exist.")
    else:
        if board.get_child_count() == 0 or board.get_child(0) != board.battle_background:
            failures.append("BattleBackground must be the first rendered child behind the board.")
        if str(board.battle_background.get_meta("contrast_role", "")) != "below_board_and_characters":
            failures.append("BattleBackground must declare the low-contrast presentation role.")
        if str(board.battle_background.get_meta("source_mode", "")) != "direct_vector_svg":
            failures.append("BattleBackground must load the pure vector SVG directly.")
        if board.battle_background.texture == null:
            failures.append("BattleBackground direct SVG texture must not be null.")

    if not bool(snapshot.get("hud_ready", false)):
        failures.append("STEP 4 top combat HUD did not instantiate.")
    if bool(snapshot.get("lower_status_panels", true)):
        failures.append("Player and enemy status panels must not be placed at the bottom.")
    if board.top_hud == null:
        failures.append("TopCombatHud component must exist.")
    else:
        var hud_snapshot := board.top_hud.get_hud_snapshot()
        if not bool(hud_snapshot.get("player_panel", false)):
            failures.append("Top HUD must include the player status panel on the left.")
        if not bool(hud_snapshot.get("player_momentum", false)):
            failures.append("Top HUD must include player ultimate momentum.")
        if not bool(hud_snapshot.get("round_panel", false)):
            failures.append("Top HUD must include the central round panel.")
        if not bool(hud_snapshot.get("enemy_momentum", false)):
            failures.append("Top HUD must include enemy ultimate momentum.")
        if not bool(hud_snapshot.get("enemy_panel", false)):
            failures.append("Top HUD must include the enemy status panel on the right.")
        if int(hud_snapshot.get("momentum_segments", 0)) != EXPECTED_MOMENTUM_SEGMENTS:
            failures.append("Both ultimate momentum gauges must use six segments.")
        if str(hud_snapshot.get("layout", "")) != "player_status|player_momentum|round|enemy_momentum|enemy_status":
            failures.append("Top HUD component order does not match the approved layout.")

        var status_panels := board.top_hud.find_children("*", "CombatantStatusPanel", true, false)
        var momentum_gauges := board.top_hud.find_children("*", "MomentumGauge", true, false)
        var round_panels := board.top_hud.find_children("*", "RoundHudPanel", true, false)
        if status_panels.size() != 2:
            failures.append("Top HUD must have exactly two combatant status panels. actual=%d" % status_panels.size())
        if momentum_gauges.size() != 2:
            failures.append("Top HUD must have exactly two momentum gauges. actual=%d" % momentum_gauges.size())
        if round_panels.size() != 1:
            failures.append("Top HUD must have exactly one round panel. actual=%d" % round_panels.size())

    if not bool(snapshot.get("action_timing_ready", false)):
        failures.append("STEP 5 action timing panel did not instantiate.")
    if board.action_timing_panel == null:
        failures.append("ActionTimingPanel component must exist.")
    else:
        var timing_snapshot := board.action_timing_panel.get_timing_snapshot()
        if timing_snapshot.get("timing_sequence", []) != EXPECTED_TIMING_SEQUENCE:
            failures.append("Action timing sequence must be 3, 3, 4.")
        if int(timing_snapshot.get("total_timings", 0)) != EXPECTED_TIMING_COUNT:
            failures.append("Action timing panel must contain exactly ten timings.")
        if int(timing_snapshot.get("current_bundle", 0)) != 2:
            failures.append("STEP 5 preview must highlight the second action bundle.")
        if int(timing_snapshot.get("current_timing", 0)) != 5:
            failures.append("STEP 5 preview must highlight timing 5 of 10.")
        if str(timing_snapshot.get("progress_scope", "")) != "round":
            failures.append("The 10 timings must be identified as round progress, not battle duration.")
        if bool(timing_snapshot.get("cards_inserted", true)):
            failures.append("STEP 5 action slots must remain card-free before action placement.")
        if bool(timing_snapshot.get("interactions_enabled", true)):
            failures.append("STEP 5 must not enable action placement interaction.")
        if str(timing_snapshot.get("layout_role", "")) != "bottom_upper":
            failures.append("Action timing panel must use the bottom-upper layout role.")

        var timing_slots := board.action_timing_panel.find_children("TimingSlot*", "ActionTimingSlot", true, false)
        if timing_slots.size() != EXPECTED_TIMING_COUNT:
            failures.append("Action timing panel must instantiate ten independent slots. actual=%d" % timing_slots.size())
        var group_counts := {1: 0, 2: 0, 3: 0}
        for slot_node in timing_slots:
            var group_index := int(slot_node.get_meta("bundle_index", 0))
            group_counts[group_index] = int(group_counts.get(group_index, 0)) + 1
            if bool(slot_node.get_meta("card_content", true)):
                failures.append("Timing slots must remain card-free until STEP 9.")
        if int(group_counts.get(1, 0)) != 3 or int(group_counts.get(2, 0)) != 3 or int(group_counts.get(3, 0)) != 4:
            failures.append("Independent timing slots must be grouped as 3, 3, 4.")

        var state_counts: Dictionary = timing_snapshot.get("state_counts", {})
        if int(state_counts.get("passed", 0)) != 4:
            failures.append("STEP 5 preview must show four passed timings.")
        if int(state_counts.get("current", 0)) != 1:
            failures.append("STEP 5 preview must show exactly one current timing.")
        if int(state_counts.get("available", 0)) != 1:
            failures.append("STEP 5 preview must show one selectable timing in the current bundle.")
        if int(state_counts.get("locked", 0)) != 4:
            failures.append("STEP 5 preview must keep the final four timings locked.")

    if not bool(snapshot.get("basic_card_tray_ready", false)):
        failures.append("STEP 6 basic card tray did not instantiate.")
    if not bool(snapshot.get("lower_skill_panel", false)):
        failures.append("STEP 6 must expose the lower basic-card tray.")
    if board.basic_card_tray == null:
        failures.append("BasicCardTray component must exist.")
    else:
        var tray_snapshot := board.basic_card_tray.get_tray_snapshot()
        if int(tray_snapshot.get("card_count", 0)) != EXPECTED_CARD_IDS.size():
            failures.append("Basic card tray must contain seven cards.")
        if str(tray_snapshot.get("layout_role", "")) != "bottom_lower":
            failures.append("Basic card tray must use the bottom-lower layout role.")
        if not bool(tray_snapshot.get("compact_variant", false)):
            failures.append("Combat view must use the compact card variant.")
        if bool(tray_snapshot.get("interactions_enabled", true)):
            failures.append("STEP 6 cards must be display-only.")
        if not bool(tray_snapshot.get("action_timing_above", false)):
            failures.append("Action timing panel must remain above the basic card tray.")

        var card_ids: PackedStringArray = tray_snapshot.get("card_ids", PackedStringArray())
        if card_ids.size() != EXPECTED_CARD_IDS.size():
            failures.append("Basic card tray id list must contain seven entries.")
        else:
            for index in range(EXPECTED_CARD_IDS.size()):
                if card_ids[index] != EXPECTED_CARD_IDS[index]:
                    failures.append("Basic card order mismatch at index %d." % index)

        var card_nodes := board.basic_card_tray.find_children("BasicCard*", "BasicCardTrayItem", true, false)
        if card_nodes.size() != EXPECTED_CARD_IDS.size():
            failures.append("Basic card tray must instantiate seven independent compact card nodes. actual=%d" % card_nodes.size())
        for card_node in card_nodes:
            if str(card_node.get_meta("source", "")) != "basic":
                failures.append("Every STEP 6 card must use the basic source.")
            if bool(card_node.get_meta("interactions_enabled", true)):
                failures.append("Compact cards must not accept interaction in STEP 6.")
            if not card_node.definition.has("action_slots") or not card_node.definition.has("stamina_cost") or not card_node.definition.has("internal_cost"):
                failures.append("Every compact card must expose slot, stamina, and internal costs.")

    var board_bottom := float(snapshot.get("board_bottom", 0.0))
    var timing_top := float(snapshot.get("action_timing_top", 0.0))
    var timing_bottom := float(snapshot.get("action_timing_bottom", 0.0))
    var tray_top := float(snapshot.get("basic_card_tray_top", 0.0))
    var tray_bottom := float(snapshot.get("basic_card_tray_bottom", 0.0))
    if timing_top <= board_bottom:
        failures.append("Bottom-upper action timing panel must not overlap the ten-tile board.")
    if tray_top <= timing_bottom:
        failures.append("Bottom-lower card tray must not overlap the action timing panel.")
    if tray_bottom > board.size.y + SIZE_TOLERANCE:
        failures.append("Basic card tray must remain inside the viewport.")

    if int(snapshot.get("tile_count", 0)) != EXPECTED_TILE_COUNT:
        failures.append("Expected ten board tiles. actual=%s" % snapshot.get("tile_count", 0))
    if int(snapshot.get("player_tile", 0)) != EXPECTED_PLAYER_TILE:
        failures.append("Player must start on tile 3.")
    if int(snapshot.get("enemy_tile", 0)) != EXPECTED_ENEMY_TILE:
        failures.append("Enemy must start on tile 8.")

    var tile_nodes := board.find_children("Tile*", "CombatBoardTile", true, false)
    if tile_nodes.size() != EXPECTED_TILE_COUNT:
        failures.append("Expected ten CombatBoardTile nodes. actual=%d" % tile_nodes.size())

    for index in range(1, EXPECTED_TILE_COUNT + 1):
        var tile := board.get_tile(index)
        if tile == null:
            failures.append("Missing tile index: %d" % index)
            continue
        if tile.tile_index != index:
            failures.append("Tile index mismatch. expected=%d actual=%d" % [index, tile.tile_index])
        if tile.name != "Tile%02d" % index:
            failures.append("Tile node name mismatch at index %d: %s" % [index, tile.name])

    if board.player_character == null or board.enemy_character == null:
        failures.append("Player and enemy character placeholders must exist.")
    else:
        if board.player_character.tile_index != EXPECTED_PLAYER_TILE:
            failures.append("Player placeholder tile metadata must be 3.")
        if board.enemy_character.tile_index != EXPECTED_ENEMY_TILE:
            failures.append("Enemy placeholder tile metadata must be 8.")

        var player_size: Vector2 = snapshot.get("player_size", Vector2.ZERO)
        var enemy_size: Vector2 = snapshot.get("enemy_size", Vector2.ZERO)
        if player_size.distance_to(enemy_size) > SIZE_TOLERANCE:
            failures.append("Player and enemy placeholders must use identical scale.")

        var tile_width := float(snapshot.get("tile_width", 0.0))
        if tile_width <= 0.0:
            failures.append("Tile width must be greater than zero.")
        else:
            var actual_ratio := player_size.y / tile_width
            if absf(actual_ratio - EXPECTED_HEIGHT_RATIO) > SIZE_TOLERANCE:
                failures.append("Character height ratio must be 1.5. actual=%.4f" % actual_ratio)

    var player_foot: Vector2 = snapshot.get("player_foot", Vector2.ZERO)
    var player_anchor: Vector2 = snapshot.get("player_tile_anchor", Vector2.ZERO)
    var enemy_foot: Vector2 = snapshot.get("enemy_foot", Vector2.ZERO)
    var enemy_anchor: Vector2 = snapshot.get("enemy_tile_anchor", Vector2.ZERO)
    if player_foot.distance_to(player_anchor) > POSITION_TOLERANCE:
        failures.append("Player foot anchor does not match tile 3 anchor. delta=%.4f" % player_foot.distance_to(player_anchor))
    if enemy_foot.distance_to(enemy_anchor) > POSITION_TOLERANCE:
        failures.append("Enemy foot anchor does not match tile 8 anchor. delta=%.4f" % enemy_foot.distance_to(enemy_anchor))

    var player_tile := board.get_tile(EXPECTED_PLAYER_TILE)
    var enemy_tile := board.get_tile(EXPECTED_ENEMY_TILE)
    if player_tile != null and player_tile.occupied_role != "player":
        failures.append("Tile 3 must expose player occupancy.")
    if enemy_tile != null and enemy_tile.occupied_role != "enemy":
        failures.append("Tile 8 must expose enemy occupancy.")

    board.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_VERIFY_OK")
        quit(0)
        return

    for failure in failures:
        push_error(failure)
    print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_STEP5_STEP6_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
