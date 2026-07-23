# STEP 12 공개 상태 AI와 STEP 13 재시작 초기화를 검증한다.
extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"
const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var hud := _load_json(HUD_PATH)
    _verify_public_state_ai(hud)
    await _verify_restart()
    if failures.is_empty():
        print("STEP12_13_RESTART_AI_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _verify_public_state_ai(hud: Dictionary) -> void:
    var engine := CombatResolutionEngine.new()
    var state := engine.make_initial_state(hud, 4, 7)
    state["ai_enabled"] = true
    var first := engine._build_enemy_actions(1, state)
    var second := engine._build_enemy_actions(1, state)
    if first.is_empty() or first != second:
        failures.append("Public-state AI must produce a deterministic bundle plan.")
    if not first.is_empty() and str((first[0] as Dictionary).get("card_id", "")) != "basic_move":
        failures.append("AI must approach from public distance three without reading player placements.")
    var ultimate_state := engine.make_initial_state(hud, 4, 7)
    ultimate_state["ai_enabled"] = true
    var enemy: Dictionary = (ultimate_state.get("enemy", {}) as Dictionary).duplicate(true)
    enemy["momentum"] = [5, 5]
    ultimate_state["enemy"] = enemy
    var ultimate_plan := engine._build_enemy_actions(1, ultimate_state)
    if ultimate_plan.is_empty() or str((ultimate_plan[0] as Dictionary).get("definition", {}).get("id", "")) != "ultimate_void_sword_qi":
        failures.append("AI with exact momentum five and public range three must reserve its three-slot ultimate.")
    var spent: Array = ((ultimate_state.get("enemy", {}) as Dictionary).get("momentum", [5, 5]) as Array)
    if int(spent[0]) != 0:
        failures.append("AI ultimate reservation must consume exact momentum immediately.")

func _verify_restart() -> void:
    var board := BOARD_SCENE.instantiate() as CombatBoardPreview
    root.add_child(board)
    await process_frame
    await process_frame
    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["health"] = [0, 30]
    board.combat_state["player"] = player
    board.restart_combat()
    var reset_player: Dictionary = board.combat_state.get("player", {})
    var reset_enemy: Dictionary = board.combat_state.get("enemy", {})
    if int(reset_player.get("tile", 0)) != 4 or int(reset_enemy.get("tile", 0)) != 7 or int((reset_player.get("health", [0, 0]) as Array)[0]) != 30:
        failures.append("Restart must restore the 4/7 and 30 health combat baseline.")
    if str(board.get_meta("presentation_state", "")) != "planning" or board._inputs_locked() or not bool(board.combat_state.get("ai_enabled", false)):
        failures.append("Restart must return to unlocked planning state.")
    board.queue_free()

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
