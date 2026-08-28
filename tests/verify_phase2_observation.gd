# Phase 2 관찰의 플레이어 전용 공개 행동유형 노출 경계를 검증한다.
extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"
const CombatResolutionEngineScript := preload("res://src/combat/combat_resolution_engine.gd")
const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var engine := CombatResolutionEngineScript.new()
    var hud := _load_json(HUD_PATH)
    var observe: Dictionary = (engine.cards_by_id.get("basic_observe", {}) as Dictionary).duplicate(true)
    var state := engine.make_initial_state(hud, 4, 6)
    var resolved := engine.resolve_bundle([{"definition": observe, "anchor_index": 1, "span": 1}], {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    var after_observe: Dictionary = resolved.get("state", {})
    var player: Dictionary = after_observe.get("player", {})
    if int(player.get("observation_points", 0)) != 1:
        failures.append("A successful player observation must grant exactly one point.")
    var locked_enemy_actions := [{"action_types": ["이동", "공격"], "name": "비공개 기술", "target_tile": 4, "damage": 99}]
    var before_locked := locked_enemy_actions.duplicate(true)
    var reveal: Dictionary = engine.reveal_next_locked_enemy_action_types(after_observe, locked_enemy_actions)
    if not bool(reveal.get("valid", false)):
        failures.append("One observation point must reveal the next locked enemy action types.")
    var payload: Dictionary = reveal.get("payload", {})
    if payload.get("action_types", []) != ["이동", "공격"]:
        failures.append("Observation must retain compound action types front-to-back.")
    for forbidden_key in ["name", "target_tile", "damage", "ai_weight", "recommended_counter"]:
        if payload.has(forbidden_key):
            failures.append("Observation payload leaked %s." % forbidden_key)
    if locked_enemy_actions != before_locked:
        failures.append("Observation must not mutate the locked enemy plan.")
    var after_reveal: Dictionary = reveal.get("state", {})
    if int((after_reveal.get("player", {}) as Dictionary).get("observation_points", 0)) != 0:
        failures.append("Observation must consume exactly one stored point.")
    await _expect_board_reveal_request()
    if failures.is_empty():
        print("PHASE2_OBSERVATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _expect_board_reveal_request() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview if packed != null else null
    if board == null:
        failures.append("Observation request requires the combat board runtime.")
        return
    root.add_child(board)
    await process_frame
    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["observation_points"] = 1
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    board.request_locked_enemy_action_type_reveal()
    var payload: Dictionary = board.get_meta("observation_reveal_payload", {})
    if not payload.has("action_types") or (payload.get("action_types", []) as Array).is_empty():
        failures.append("The board must render an explicit observation request result for a locked enemy bundle.")
    for forbidden_key in ["name", "target_tile", "damage", "ai_reason", "ai_seed"]:
        if payload.has(forbidden_key):
            failures.append("Board observation UI leaked %s." % forbidden_key)
    if board.observation_reveal_status == null or not board.observation_reveal_status.text.begins_with("관찰 기록 · "):
        failures.append("The board must render accessible observation history/status text.")
    board.queue_free()
    await process_frame

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
