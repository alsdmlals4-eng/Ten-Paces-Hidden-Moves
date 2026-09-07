# Phase 2 관찰의 플레이어 전용 공개 행동유형 노출 경계를 검증한다.
extends SceneTree

const HUD_PATH := "res://data/combat/combat_hud_preview.json"
const CombatResolutionEngineScript := preload("res://src/combat/combat_resolution_engine.gd")
const CombatResolutionEnginePrepareScript := preload("res://src/combat/combat_resolution_engine_prepare.gd")
const TenManualCombatResolutionEngineScript := preload("res://src/combat/combat_resolution_engine_ten_manuals.gd")
const VerticalSliceMetricsCombatResolutionEngineScript := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
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
    _expect_locked_enemy_plan_is_reused(engine, hud)
    _expect_inherited_enemy_plan_types(hud)
    await _expect_board_auto_reveal()
    if failures.is_empty():
        print("PHASE2_OBSERVATION_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _expect_board_auto_reveal() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    var board := packed.instantiate() as CombatBoardPreview if packed != null else null
    if board == null:
        failures.append("Observation request requires the combat board runtime.")
        return
    root.add_child(board)
    await process_frame
    board.resolution_engine.rules["enemy_bundles"] = {
        "1": [
            {"card_id": "basic_quick_attack", "timing": 2, "direction": -1, "action_types": ["이동", "공격"]},
            {"card_id": "basic_quick_attack", "timing": 3, "direction": -1, "action_types": ["공격"]}
        ]
    }
    board.resolution_engine.clear_locked_enemy_bundle()
    board.resolution_engine.lock_enemy_bundle(board.combat_state, 1)
    var player: Dictionary = (board.combat_state.get("player", {}) as Dictionary).duplicate(true)
    player["observation_points"] = 2
    board.combat_state["player"] = player
    board._apply_combat_state_to_view()
    var result: Dictionary = board.reveal_available_locked_enemy_action_types()
    if not bool(result.get("ok", false)) or str(result.get("reveal_level", "")) != "ACTUAL_ACTION_TYPES":
        failures.append("The board must automatically reveal available locked enemy action types after lock.")
    var payload: Dictionary = board.get_meta("observation_reveal_payload", {})
    if not payload.has("action_types") or (payload.get("action_types", []) as Array).is_empty():
        failures.append("The board must render an explicit observation request result for a locked enemy bundle.")
    for forbidden_key in ["name", "target_tile", "damage", "ai_reason", "ai_seed"]:
        if payload.has(forbidden_key):
            failures.append("Board observation UI leaked %s." % forbidden_key)
    if board.observation_reveal_panel == null:
        failures.append("The board must render observation through the dedicated observation panel.")
    elif board.observation_reveal_panel.has_method("get_observation_snapshot"):
        var panel_snapshot = board.observation_reveal_panel.call("get_observation_snapshot") as Dictionary
        if panel_snapshot.get("revealed_types", []) != ["이동", "공격"]:
            failures.append("The board must disclose unique observed action types in player-facing order.")
        if bool(panel_snapshot.get("private_fields_visible", true)):
            failures.append("The observation panel must not render locked-plan private fields.")
    else:
        failures.append("The observation panel must expose its player-facing type-only snapshot.")
    if board.observation_reveal_button != null:
        failures.append("Observation types must be disclosed automatically, without a separate player reveal button.")
    board.queue_free()
    await process_frame

func _expect_locked_enemy_plan_is_reused(engine, hud: Dictionary) -> void:
    var state: Dictionary = engine.make_initial_state(hud, 4, 6)
    state["ai_enabled"] = true
    engine.rules["enemy_bundles"] = {
        "1": [{"card_id": "basic_quick_attack", "timing": 2, "direction": -1, "action_types": ["이동", "공격"]}]
    }
    var locked_types: Array = engine.get_locked_enemy_action_type_entries(state, 1)
    if locked_types != [{"action_types": ["이동", "공격"]}]:
        failures.append("A planning bundle must preserve compound enemy action types front-to-back when it locks the plan.")
    var player: Dictionary = (state.get("player", {}) as Dictionary).duplicate(true)
    player["observation_points"] = 1
    state["player"] = player
    var reveal: Dictionary = engine.reveal_next_locked_enemy_action_types(state, locked_types)
    if not bool(reveal.get("valid", false)):
        failures.append("The locked plan must remain available for an explicit observation request.")
    if (reveal.get("payload", {}) as Dictionary).get("action_types", []) != ["이동", "공격"]:
        failures.append("The engine lock-to-reveal path must expose compound action types front-to-back.")
    var uncommitted_player_placement := [{"definition": engine.cards_by_id.get("basic_meditate", {}), "anchor_index": 1, "span": 1}]
    engine.preview_player_plan(state, uncommitted_player_placement)
    engine.rules["enemy_bundles"] = {
        "1": [{"card_id": "basic_move", "timing": 1, "direction": -1}]
    }
    var result: Dictionary = engine.resolve_bundle(uncommitted_player_placement, {"round_number": 1, "bundle_index": 1, "timing_sequence": [3, 3, 4]}, state)
    var enemy_actions: Array = []
    for action_value in result.get("resolved_actions", []):
        if typeof(action_value) == TYPE_DICTIONARY and str((action_value as Dictionary).get("actor", "")) == "enemy":
            enemy_actions.append({"card_id": str((action_value as Dictionary).get("card_id", "")), "timing": int((action_value as Dictionary).get("timing", 0))})
    if enemy_actions.is_empty() or enemy_actions[0] != {"card_id": "basic_quick_attack", "timing": 2}:
        failures.append("Observation reveal and resolution must consume the same locked enemy action ID and timing after uncommitted player changes.")
    var payload: Dictionary = reveal.get("payload", {})
    for forbidden_key in ["card_id", "timing", "name", "target_tile", "damage", "ai_reason", "ai_seed"]:
        if payload.has(forbidden_key):
            failures.append("Locked-plan observation leaked %s." % forbidden_key)

func _expect_inherited_enemy_plan_types(hud: Dictionary) -> void:
    for engine_script in [CombatResolutionEnginePrepareScript, TenManualCombatResolutionEngineScript, VerticalSliceMetricsCombatResolutionEngineScript]:
        var engine = engine_script.new()
        var state: Dictionary = engine.make_initial_state(hud, 4, 6)
        state["ai_enabled"] = true
        engine.rules["enemy_bundles"] = {
            "1": [{"card_id": "basic_quick_attack", "timing": 2, "direction": -1, "action_types": ["이동", "공격"]}]
        }
        engine.lock_enemy_bundle(state, 1)
        if engine.get_locked_enemy_action_type_entries(state, 1) != [{"action_types": ["이동", "공격"]}]:
            failures.append("%s must preserve compound action types in its locked enemy plan." % str(engine_script.resource_path))

func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
