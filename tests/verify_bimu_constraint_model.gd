extends SceneTree

const MODEL_SCRIPT := preload("res://src/run/bimu_constraint_model.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var model = MODEL_SCRIPT.new()
    _expect(model.get_options().size() == 9, "catalog exposes exactly nine options")
    _expect(model.validate_selection([], [], []).get("valid") == true, "empty selection is valid")
    var policy_owner_model = MODEL_SCRIPT.new()
    policy_owner_model._catalog["selection_policy"]["selection_point_budget"] = 0
    _expect(policy_owner_model.validate_selection([{"constraint_id": "CST_TECH_RESPONSE_SEAL"}], [], []).get("valid") == false, "runtime JSON policy is consumed instead of duplicated literals")
    var malformed_catalog_model = MODEL_SCRIPT.new()
    malformed_catalog_model._catalog = {}
    _expect(malformed_catalog_model.validate_selection([], [], []).get("valid") == false, "missing catalog fails closed")

    var response := model.validate_selection([{"constraint_id": "CST_TECH_RESPONSE_SEAL"}], ["wudang_taiji_sword"], [])
    _expect(response.get("valid") == true and response.get("selection_point_spent") == 1, "response seal validates")
    _expect(model.action_lock_reason({"source": "martial_manual", "manual_id": "wudang_taiji_sword", "unlock_star": 3, "category": "response", "action_slots": 1}, response) == "비무 제약: 대응 봉인", "response seal matches actual normalized fields")

    var recovery := model.validate_selection([{"constraint_id": "CST_TECH_RECOVERY_SEAL"}], ["mount_hua_purple_mist_art"], [])
    _expect(model.action_lock_reason({"source": "martial_manual", "manual_id": "mount_hua_purple_mist_art", "unlock_star": 3, "category": "recovery", "action_slots": 1}, recovery) == "비무 제약: 회복 봉인", "recovery seal matches")

    var ultimate := model.validate_selection([{"constraint_id": "CST_TECH_ULTIMATE_SEAL"}], ["wudang_taiji_sword"], [])
    _expect(model.action_lock_reason({"source": "martial_manual", "manual_id": "wudang_taiji_sword", "unlock_star": 10, "category": "response", "action_slots": 3}, ultimate) == "비무 제약: 절초 봉인", "star10 seal matches")
    var multi := model.validate_selection([{"constraint_id": "CST_TECH_MULTI_SLOT_SEAL"}], ["wudang_taiji_sword"], [])
    _expect(model.action_lock_reason({"source": "martial_manual", "manual_id": "wudang_taiji_sword", "unlock_star": 7, "category": "attack", "action_slots": 2}, multi) == "비무 제약: 연속 수 봉인", "multi-slot seal matches")
    var manual := model.validate_selection([{"constraint_id": "CST_TECH_MANUAL_SEAL", "target_manual_id": "wudang_taiji_sword"}], ["wudang_taiji_sword", "shaolin_arhat_vajra_art"], [])
    _expect(manual.get("valid") == true, "owned manual seal validates when at least two manuals are owned")
    _expect(model.action_lock_reason({"source": "martial_manual", "manual_id": "wudang_taiji_sword", "unlock_star": 3, "category": "response", "action_slots": 1}, manual) == "비무 제약: 문파 단절", "manual seal matches manual identity")

    _expect(model.action_lock_reason({"source": "basic", "category": "response", "unlock_star": 10, "action_slots": 3}, response).is_empty(), "base actions remain unsealed")
    _expect(model.action_lock_reason({"source": "ultimate", "category": "response", "unlock_star": 10, "action_slots": 3}, ultimate).is_empty(), "base ultimates remain unsealed")
    _expect(model.action_lock_reason({"source": "martial_manual", "category": "response", "unlock_star": 3, "action_slots": 1}, {"valid": true}).is_empty(), "valid flag alone cannot forge a receipt")

    _expect(model.validate_selection([{"constraint_id": "CST_TECH_RESPONSE_SEAL"}, {"constraint_id": "CST_TECH_RESPONSE_SEAL"}], [], []).get("valid") == false, "duplicates fail closed")
    _expect(model.validate_selection([{"constraint_id": "CST_TECH_RESPONSE_SEAL"}, {"constraint_id": "CST_TECH_RECOVERY_SEAL"}, {"constraint_id": "CST_TECH_ULTIMATE_SEAL"}], [], []).get("valid") == false, "more than two constraints fail closed")
    _expect(model.validate_selection([{"constraint_id": "CST_TECH_MULTI_SLOT_SEAL"}, {"constraint_id": "CST_ENEMY_MASTERED_MANUAL", "target_enemy_manual_id": "wudang_taiji_sword"}], [], ["wudang_taiji_sword"]).get("valid") == false, "point budget is enforced")
    _expect(model.validate_selection([{"constraint_id": "CST_ENEMY_START_MOMENTUM_1"}, {"constraint_id": "CST_ENEMY_RESOURCE_SURPLUS"}], [], []).get("valid") == false, "only one enemy reinforcement is allowed")
    _expect(model.validate_selection([{"constraint_id": "CST_TECH_MANUAL_SEAL", "target_manual_id": "missing"}], ["wudang_taiji_sword", "shaolin_arhat_vajra_art"], []).get("valid") == false, "manual ownership is enforced")
    _expect(model.validate_selection([{"constraint_id": "CST_ENEMY_MASTERED_MANUAL", "target_enemy_manual_id": "missing"}], [], ["wudang_taiji_sword"]).get("valid") == false, "enemy manual ownership is enforced")
    _expect(model.validate_selection([{"constraint_id": "CST_ENEMY_STAT_DISCIPLINE", "target_stat_key": "luck"}], [], []).get("valid") == false, "stat allow-list is enforced")
    _expect(model.validate_selection([{"constraint_id": "CST_ENEMY_STAT_DISCIPLINE", "target_stat_key": 7}], [], []).get("valid") == false, "wrong parameter type fails closed")
    _expect(model.validate_selection(["bad"], [], []).get("valid") == false, "non-dictionary selection fails closed")
    _expect(model.validate_selection([{"constraint_id": 3}], [], []).get("valid") == false, "wrong constraint ID type fails closed")
    _expect(model.validate_selection([{"constraint_id": "CST_TECH_RESPONSE_SEAL", "extra": true}], [], []).get("valid") == false, "extra keys fail closed")

    var options := model.get_options()
    options[0]["selection_cost"] = 99
    _expect(model.get_options()[0].get("selection_cost") != 99, "catalog options are deep copied")
    var disclosed: Array = response.get("disclosed_effects", [])
    disclosed.append("tampered")
    _expect((model.validate_selection([{"constraint_id": "CST_TECH_RESPONSE_SEAL"}], [], []).get("disclosed_effects") as Array).size() == 1, "receipts do not mutate catalog")

    var mastery := model.enemy_mastery_overlay({"wudang_taiji_sword": 9}, model.validate_selection([{"constraint_id": "CST_ENEMY_MASTERED_MANUAL", "target_enemy_manual_id": "wudang_taiji_sword"}], [], ["wudang_taiji_sword"]))
    _expect(mastery.get("wudang_taiji_sword") == 10, "enemy mastery is capped at ten")
    var original_mastery := {"wudang_taiji_sword": 9}
    model.enemy_mastery_overlay(original_mastery, model.validate_selection([{"constraint_id": "CST_ENEMY_MASTERED_MANUAL", "target_enemy_manual_id": "wudang_taiji_sword"}], [], ["wudang_taiji_sword"]))
    _expect(original_mastery.get("wudang_taiji_sword") == 9, "mastery overlay does not mutate input")

    var enemy := {"momentum": 4, "momentum_max": 5, "stamina": 3, "stamina_max": 3, "internal": 2, "internal_max": 4, "external": 7}
    var state_receipt := model.validate_selection([{"constraint_id": "CST_ENEMY_RESOURCE_SURPLUS"}], [], [])
    var state := model.enemy_state_overlay(enemy, state_receipt)
    _expect(state.get("stamina") == 3 and state.get("internal") == 3, "current resources gain one and clamp to current maximum")
    _expect(enemy.get("internal") == 2, "state overlay does not mutate input")
    var momentum_state := model.enemy_state_overlay(enemy, model.validate_selection([{"constraint_id": "CST_ENEMY_START_MOMENTUM_1"}], [], []))
    _expect(momentum_state.get("momentum") == 5, "momentum gains one and clamps")
    var stat_state := model.enemy_state_overlay(enemy, model.validate_selection([{"constraint_id": "CST_ENEMY_STAT_DISCIPLINE", "target_stat_key": "external"}], [], []))
    _expect(stat_state.get("external") == 8, "selected stat gains one")
    var runtime_enemy := {"momentum": [4, 5], "stamina": [3, 3], "internal": [2, 4], "stats": {"external": 7}}
    var runtime_resource_state := model.enemy_state_overlay(runtime_enemy, state_receipt)
    _expect(runtime_resource_state.get("stamina") == [3, 3] and runtime_resource_state.get("internal") == [3, 4], "runtime resource pairs gain current only and clamp")
    var runtime_stat_state := model.enemy_state_overlay(runtime_enemy, model.validate_selection([{"constraint_id": "CST_ENEMY_STAT_DISCIPLINE", "target_stat_key": "external"}], [], []))
    _expect((runtime_stat_state.get("stats") as Dictionary).get("external") == 8, "runtime nested stat gains one")
    _expect(model.enemy_state_overlay(enemy, {}).hash() == enemy.hash(), "empty receipt is identity")

    if failures.is_empty():
        print("BIMU_CONSTRAINT_MODEL_OK cases=37")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
