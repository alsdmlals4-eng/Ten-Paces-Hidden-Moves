extends SceneTree

const DOCK_SCENE := preload("res://scenes/ui/action_selection/action_selection_dock.tscn")
const INSTRUMENTED_DOCK_SCRIPT := preload("res://tests/support/instrumented_action_selection_dock.gd")
const STARTERS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear",
]

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var dock = DOCK_SCENE.instantiate()
    dock.set_script(INSTRUMENTED_DOCK_SCRIPT)
    root.add_child(dock)
    await process_frame

    var empty_context := {"martial_loadout": [], "martial_mastery_by_manual": {}}
    dock.set_runtime_context(empty_context)
    _expect_eq(dock.owned_manual_build_count, 1, "An explicit initial empty context must initialize the manual consumer once.")
    dock.set_runtime_context(empty_context)
    _expect_eq(dock.owned_manual_build_count, 1, "An identical empty manual context must not rebuild view models.")

    var mastery := _mastery(3)
    var context := {
        "martial_loadout": STARTERS.duplicate(),
        "martial_mastery_by_manual": mastery,
        "preview_actor": {"external": 1, "internal_power": 1, "stamina": 8, "internal_energy": 7},
        "constraint_lock_reasons": {},
        "constraint_summary": "제약 없음",
        "momentum": [4, 5],
        "ultimate_reservations": [],
    }
    dock.set_runtime_context(context)
    _expect_eq(dock.owned_manual_build_count, 2, "A changed loadout must build owned manual view models.")
    var initial_snapshot: Dictionary = dock.get_dock_snapshot()
    var initial_preview_text := _first_technique_preview_text(dock)
    _expect_eq((initial_snapshot.get("martial_snapshot", {}) as Dictionary).get("manual_count", -1), 4, "Changed loadout must reach the martial panel.")
    _expect_eq((initial_snapshot.get("ultimate_snapshot", {}) as Dictionary).get("momentum_current", -1), 4, "Momentum must reach the ultimate panel.")

    dock.set_runtime_context(context)
    _expect_eq(dock.owned_manual_build_count, 2, "An identical populated manual context must not rebuild view models.")

    context["martial_loadout"][0] = "emei_water_moon_sword"
    context["martial_mastery_by_manual"][STARTERS[0]] = 10
    var retained: Dictionary = dock.get_dock_snapshot().get("runtime_context", {})
    _expect_eq((retained.get("martial_loadout", []) as Array)[0], STARTERS[0], "The dock must own its loadout input copy.")
    _expect_eq(int((retained.get("martial_mastery_by_manual", {}) as Dictionary).get(STARTERS[0], -1)), 3, "The dock must own its mastery input copy.")

    var dynamic_only := {
        "martial_loadout": STARTERS.duplicate(),
        "martial_mastery_by_manual": _mastery(3),
        "preview_actor": {"external": 9, "internal_power": 9, "stamina": 1, "internal_energy": 2},
        "constraint_lock_reasons": {"mount_hua_plum_blossom_sword_star3": "검증 잠금"},
        "constraint_summary": "검증 제약",
        "constraint_details": "검증 제약 상세",
        "momentum": [5, 5],
        "ultimate_reservations": [{"action_id": "ultimate_ten_paces_wave", "start_timing": 1, "end_timing": 1}],
    }
    dock.set_runtime_context(dynamic_only)
    _expect_eq(dock.owned_manual_build_count, 2, "Dynamic-only changes must bypass manual view-model reconstruction.")
    var dynamic_snapshot: Dictionary = dock.get_dock_snapshot()
    _expect_eq(str(dock.constraint_summary.text), "검증 제약", "Constraint summary must still update.")
    _expect_eq((dynamic_snapshot.get("ultimate_snapshot", {}) as Dictionary).get("momentum_current", -1), 5, "Dynamic momentum must still update.")
    _expect_eq((dynamic_snapshot.get("ultimate_snapshot", {}) as Dictionary).get("reservation_count", -1), 1, "Dynamic reservations must still update.")
    _expect_true(int((dynamic_snapshot.get("martial_snapshot", {}) as Dictionary).get("locked_technique_count", -1)) > int((initial_snapshot.get("martial_snapshot", {}) as Dictionary).get("locked_technique_count", -1)), "Dynamic constraint locks must still update.")
    _expect_true(_first_technique_preview_text(dock) != initial_preview_text, "Dynamic actor/resource preview inputs must still rebuild consumer summaries.")

    var changed_mastery := _mastery(3)
    changed_mastery[STARTERS[0]] = 7
    dynamic_only["martial_mastery_by_manual"] = changed_mastery
    dock.set_runtime_context(dynamic_only)
    _expect_eq(dock.owned_manual_build_count, 3, "Changed mastery must rebuild owned manual view models.")
    var mastery_snapshot: Dictionary = dock.get_dock_snapshot().get("martial_snapshot", {})
    _expect_true((mastery_snapshot.get("technique_ids", []) as Array).size() >= 2, "Changed mastery must expose the newly unlocked technique view model.")

    var changed_loadout := STARTERS.duplicate()
    changed_loadout[0] = "mount_hua_purple_mist_art"
    dynamic_only["martial_loadout"] = changed_loadout
    dock.set_runtime_context(dynamic_only)
    _expect_eq(dock.owned_manual_build_count, 4, "Changed loadout identity must rebuild owned manual view models.")
    _expect_true("mount_hua_purple_mist_art" in ((dock.get_dock_snapshot().get("martial_snapshot", {}) as Dictionary).get("manual_ids", []) as Array), "Changed loadout must reach the rendered manual identities.")

    dock.set_runtime_context(dynamic_only)
    var samples: Array[int] = []
    for _sample in range(3):
        var started_usec := Time.get_ticks_usec()
        for _update in range(100):
            dock.set_runtime_context(dynamic_only)
        samples.append(Time.get_ticks_usec() - started_usec)
    _expect_eq(dock.owned_manual_build_count, 4, "Warmed identical updates must keep the manual reconstruction path cold.")
    print("ACTION_DOCK_REFRESH_MEASUREMENT identical_100_usec=%s" % str(samples))

    dock.queue_free()
    await process_frame
    if failures.is_empty():
        print("ACTION_DOCK_CONTEXT_INVALIDATION_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("ACTION_DOCK_CONTEXT_INVALIDATION_FAILED count=%d" % failures.size())
    quit(1)

func _mastery(value: int) -> Dictionary:
    var result := {}
    for manual_id in STARTERS:
        result[manual_id] = value
    return result

func _first_technique_preview_text(dock) -> String:
    if dock.martial_panel.technique_buttons.is_empty():
        return ""
    var summary: Node = dock.martial_panel.technique_buttons[0].get_node_or_null("CardSummary")
    if not is_instance_valid(summary) or summary.get_child_count() < 2:
        return ""
    return str(summary.get_child(1).text)

func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)

func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])
