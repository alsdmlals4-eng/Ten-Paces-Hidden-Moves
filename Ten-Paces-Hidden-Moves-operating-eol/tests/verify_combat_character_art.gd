# 전투판 전신 원화가 양측 역할에 맞게 로드되고 발 앵커를 보존하는지 검증한다.
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

    _require_role_art(board.player_character, "player", "res://assets/characters/player_wanderer_battler_rgba_v1.png")
    _require_role_art(board.enemy_character, "enemy", "res://assets/characters/enemy_masked_battler_rgba_v1.png")
    _require_anchor(board, "player")
    _require_anchor(board, "enemy")
    await _require_art_motion(board.player_character, "player")

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
    var expected := board.get_tile_foot_anchor(int(actor.get("tile", 0)))
    var actual := board.get_character_foot_anchor(role)
    if actual.distance_to(expected) > 0.1:
        failures.append("%s full-body art must retain the tile foot anchor." % role)

func _require_art_motion(character: CombatCharacterPlaceholder, role: String) -> void:
    var foot_before := character.get_foot_anchor_global()
    character.play_attack_motion(0.12)
    await create_timer(0.03).timeout
    if character.motion_state != "attack" or character.visual_offset.length() <= 0.1:
        failures.append("%s full-body art must retain the short attack lunge motion." % role)
    await create_timer(0.14).timeout
    if character.motion_state != "idle" or character.get_foot_anchor_global().distance_to(foot_before) > 0.1:
        failures.append("%s attack motion must return to the original tile foot anchor." % role)

func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_CHARACTER_ART_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
