extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const BACKGROUND_ASSET_PATH := "res://assets/backgrounds/step3_mountain_fortress.svg"
const EXPECTED_TILE_COUNT := 10
const EXPECTED_PLAYER_TILE := 3
const EXPECTED_ENEMY_TILE := 8
const EXPECTED_HEIGHT_RATIO := 1.5
const EXPECTED_MOMENTUM_SEGMENTS := 6
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
        else:
            if board.battle_background.texture.get_width() < 1000:
                failures.append("BattleBackground texture width is unexpectedly small.")
            if board.battle_background.texture.get_height() < 600:
                failures.append("BattleBackground texture height is unexpectedly small.")

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
        if bool(hud_snapshot.get("lower_status_panels", true)):
            failures.append("Top HUD metadata must explicitly reject lower status panels.")
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
        print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_VERIFY_OK")
        quit(0)
        return

    for failure in failures:
        push_error(failure)
    print("COMBAT_BOARD_STEP1_STEP2_STEP3_STEP4_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
