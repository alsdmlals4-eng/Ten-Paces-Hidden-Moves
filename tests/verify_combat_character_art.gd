# 전투판 전신 원화가 양측 역할에 맞게 로드되고 거리 중심 정면 결투 연출을 보존하는지 검증한다.
extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview
    board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    board.size = Vector2(1440.0, 900.0)
    root.add_child(board)
    for _index in range(4):
        await process_frame

    _require_role_art(board.player_character, "player", "res://assets/characters/player_wanderer_battler_rgba_v2.png")
    _require_role_art(board.enemy_character, "enemy", "res://assets/characters/enemy_masked_battler_rgba_v2.png")
    _require_anchor(board, "player")
    _require_anchor(board, "enemy")
    await _require_art_motion(board.player_character, "player")
    await _require_motion_phase_contract(board.player_character)
    await _require_grounded_presentation_motions(board)

    board.queue_free()
    await process_frame
    _finish()

func _require_role_art(character: CombatCharacterPlaceholder, role: String, expected_path: String) -> void:
    if character == null or not character.has_method("get_render_texture"):
        failures.append("%s combatant must expose its rendered character texture." % role)
        return
    var texture = character.call("get_render_texture") as Texture2D
    if texture == null:
        failures.append("%s combatant must load a rendered full-body texture." % role)
    if str(character.get_meta("character_art_path", "")) != expected_path:
        failures.append("%s combatant must identify its approved character-art path." % role)

func _require_anchor(board: CombatBoardPreview, role: String) -> void:
    var actor: Dictionary = board.combat_state.get(role, {})
    var character: CombatCharacterPlaceholder = board.player_character if role == "player" else board.enemy_character
    if character == null:
        failures.append("%s combatant must remain available for visual composition." % role)
        return
    if character.tile_index != int(actor.get("tile", 0)):
        failures.append("%s full-body art must preserve its logical combat tile identity." % role)
        return
    var actual := board.get_character_foot_anchor(role)
    var opposing := board.get_character_foot_anchor("enemy" if role == "player" else "player")
    if role == "player":
        if actual.x >= opposing.x or absf(actual.y - opposing.y) > board.size.y * 0.01:
            failures.append("Player full-body art must hold the left position on the shared grounded frontal duel line.")
    elif actual.x <= opposing.x or absf(actual.y - opposing.y) > board.size.y * 0.01:
        failures.append("Enemy full-body art must hold the right position on the shared grounded frontal duel line.")

func _require_art_motion(character: CombatCharacterPlaceholder, role: String) -> void:
    var foot_before := character.get_foot_anchor_global()
    character.play_attack_motion(0.12)
    await create_timer(0.03).timeout
    if character.motion_state != "attack" or character.visual_offset.length() <= 0.1:
        failures.append("%s full-body art must retain the short attack lunge motion." % role)
    await create_timer(0.14).timeout
    if character.motion_state != "idle" or character.get_foot_anchor_global().distance_to(foot_before) > 0.1:
        failures.append("%s attack motion must return to the original visual foot anchor." % role)

func _require_motion_phase_contract(character: CombatCharacterPlaceholder) -> void:
    if character == null or not character.has_method("get_motion_snapshot"):
        failures.append("Combat character presentation must expose a motion-state snapshot for phase-aware playback.")
        return

    var foot_before := character.get_foot_anchor_global()
    character.play_attack_motion(0.50)
    await create_timer(0.04).timeout
    var windup: Dictionary = character.get_motion_snapshot()
    if str(windup.get("state", "")) != "attack" or str(windup.get("phase", "")) != "windup":
        failures.append("Attack presentation must enter a distinct windup phase before the active strike.")

    await create_timer(0.12).timeout
    var active: Dictionary = character.get_motion_snapshot()
    if str(active.get("state", "")) != "attack" or str(active.get("phase", "")) != "active":
        failures.append("Attack presentation must expose its active strike phase without changing combat state.")

    await create_timer(0.18).timeout
    var recovery: Dictionary = character.get_motion_snapshot()
    if str(recovery.get("state", "")) != "attack" or str(recovery.get("phase", "")) != "recovery":
        failures.append("Attack presentation must expose a recovery phase after the active strike.")

    await create_timer(0.22).timeout
    var idle: Dictionary = character.get_motion_snapshot()
    if str(idle.get("state", "")) != "idle" or str(idle.get("phase", "")) != "idle":
        failures.append("A completed motion phase sequence must return the character to idle.")
    if character.get_foot_anchor_global().distance_to(foot_before) > 0.1:
        failures.append("Motion phase playback must preserve the original foot anchor after recovery.")

    character.play_attack_motion(0.50)
    await create_timer(0.04).timeout
    character.play_hit_motion(0.24)
    await create_timer(0.03).timeout
    var interrupted: Dictionary = character.get_motion_snapshot()
    if str(interrupted.get("state", "")) != "hit" or str(interrupted.get("phase", "")) != "active":
        failures.append("A new presentation motion must interrupt the prior motion and expose its own active phase.")
    await create_timer(0.26).timeout
    if character.get_foot_anchor_global().distance_to(foot_before) > 0.1:
        failures.append("Interrupted presentation motions must still restore the grounded foot anchor.")

func _require_grounded_presentation_motions(board: CombatBoardPreview) -> void:
    var player := board.player_character
    var enemy := board.enemy_character
    if player == null or enemy == null:
        failures.append("Grounded presentation verification requires both character actors.")
        return
    for motion in ["play_evade_motion", "play_block_motion", "play_hit_motion", "play_ultimate_motion"]:
        var foot_before := player.get_foot_anchor_global()
        player.call(motion, 0.12)
        await create_timer(0.03).timeout
        if player.motion_state == "idle":
            failures.append("%s must enter a visible presentation state before returning to idle." % motion)
        if absf(player.get_foot_anchor_global().y - foot_before.y) > 0.1:
            failures.append("%s must preserve the grounded foot height during presentation." % motion)
        await create_timer(0.14).timeout
        if player.motion_state != "idle" or player.get_foot_anchor_global().distance_to(foot_before) > 0.1:
            failures.append("%s must return to its original grounded foot anchor." % motion)

    var player_foot_before := player.get_foot_anchor_global()
    var enemy_foot_before := enemy.get_foot_anchor_global()
    board._play_clash_motion(0.30)
    await create_timer(0.14).timeout
    var player_foot_at_clash := player.get_foot_anchor_global()
    var enemy_foot_at_clash := enemy.get_foot_anchor_global()
    if player.motion_state != "clash" or enemy.motion_state != "clash":
        failures.append("A clash must animate both combatants toward the shared contact point.")
    if player_foot_at_clash.distance_to(enemy_foot_at_clash) > 4.0:
        failures.append("A clash must visibly converge both combatants on one common action point.")
    if absf(player_foot_at_clash.y - player_foot_before.y) > 0.1 or absf(enemy_foot_at_clash.y - enemy_foot_before.y) > 0.1:
        failures.append("A clash must preserve both combatants on the shared ground line.")
    var clash_snapshot: Dictionary = board.get_presentation_motion_snapshot()
    if not bool(clash_snapshot.get("clash_anchor_valid", false)):
        failures.append("Clash presentation must record the shared grounded anchor for inspection.")
    await create_timer(0.24).timeout
    if player.motion_state != "idle" or enemy.motion_state != "idle" or player.get_foot_anchor_global().distance_to(player_foot_before) > 0.1 or enemy.get_foot_anchor_global().distance_to(enemy_foot_before) > 0.1:
        failures.append("A clash must return both combatants to their original grounded placements.")

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_CHARACTER_ART_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
