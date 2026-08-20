extends SceneTree

const STARTER_CATALOG_PATH := "res://src/run/vertical_slice_starter_manual_catalog.gd"
const SHELL_SCENE_PATH := "res://scenes/run/vertical_slice_shell.tscn"

const EXPECTED_STARTER_IDS := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear",
    "mount_hua_purple_mist_art",
    "xiaoyao_lingbo_footwork"
]

const HISTORICAL_ALIASES := [
    "유운검결",
    "금강호체공",
    "태극유전검",
    "추풍창법",
    "청심양생공",
    "무영십보"
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var starter_script := load(STARTER_CATALOG_PATH)
    if starter_script == null:
        failures.append("Starter manual catalog is missing: %s" % STARTER_CATALOG_PATH)
        _finish()
        return

    var starter_catalog = starter_script.new()
    _expect_true(starter_catalog.is_valid(), "Starter manual catalog must resolve against the current ten-manual registry.")
    var options: Array = starter_catalog.get_options()
    _expect_eq(options.size(), 6, "Setup must expose exactly six current starter manuals.")

    var option_ids: Array[String] = []
    var player_facing_text := ""
    for value in options:
        _expect_true(typeof(value) == TYPE_DICTIONARY, "Each starter option must be a Dictionary.")
        if typeof(value) != TYPE_DICTIONARY:
            continue
        var option := value as Dictionary
        option_ids.append(str(option.get("manual_id", "")))
        player_facing_text += " %s %s" % [str(option.get("faction", "")), str(option.get("manual_name", ""))]
        _expect_eq(int(option.get("mastery", 0)), 3, "Each starter manual must begin at mastery 3.")
        _expect_true(str(option.get("star3_card_name", "")).length() > 0, "Each starter option must expose its current star3 technique name.")
    option_ids.sort()
    var expected_ids := EXPECTED_STARTER_IDS.duplicate()
    expected_ids.sort()
    _expect_eq(option_ids, expected_ids, "Starter IDs must match the six current manuals mapped from the historical starter set.")
    for alias in HISTORICAL_ALIASES:
        _expect_false(player_facing_text.contains(alias), "Setup player-facing text must not use historical alias: %s" % alias)

    _expect_false(starter_catalog.validate_selection(EXPECTED_STARTER_IDS.slice(0, 3)), "Three manuals may not confirm Setup.")
    _expect_true(starter_catalog.validate_selection(EXPECTED_STARTER_IDS.slice(0, 4)), "Exactly four legal starter manuals must confirm Setup.")
    _expect_false(starter_catalog.validate_selection(EXPECTED_STARTER_IDS.slice(0, 5)), "Five manuals may not confirm Setup.")
    _expect_false(starter_catalog.validate_selection([EXPECTED_STARTER_IDS[0], EXPECTED_STARTER_IDS[0], EXPECTED_STARTER_IDS[1], EXPECTED_STARTER_IDS[2]]), "Duplicate manuals may not confirm Setup.")

    var shell_scene := load(SHELL_SCENE_PATH) as PackedScene
    _expect_true(shell_scene != null, "Vertical Slice shell scene must load.")
    if shell_scene == null:
        _finish()
        return
    var shell = shell_scene.instantiate()
    root.add_child(shell)
    await process_frame

    _expect_true(shell.start_new_run(), "Shell must enter Setup from Main.")
    await process_frame
    _expect_eq(shell.run_state.get_current_screen(), "SETUP", "Run must be at Setup before manual selection.")
    _expect_eq(shell.get_setup_option_button_count(), 6, "Setup UI must render six selectable manual options.")
    _expect_true(shell.primary_button.disabled, "Setup primary CTA must be disabled before exactly four manuals are selected.")
    _expect_false((shell.title_label.text + shell.description_label.text).contains("덱"), "Setup must not use deck-builder wording.")
    _expect_false((shell.title_label.text + shell.description_label.text).contains("손패"), "Setup must not use hand/draw wording.")

    for index in range(4):
        _expect_true(shell.toggle_setup_manual(EXPECTED_STARTER_IDS[index]), "Legal starter manual selection must succeed.")
    _expect_eq(shell.get_setup_selected_manual_ids().size(), 4, "Setup must hold exactly four selected manuals.")
    _expect_false(shell.toggle_setup_manual(EXPECTED_STARTER_IDS[4]), "Adding a fifth manual must be rejected until one is deselected.")
    _expect_false(shell.primary_button.disabled, "Setup primary CTA must enable at exactly four selections.")

    var selected_before_advance: Array = shell.get_setup_selected_manual_ids()
    _expect_true(shell.advance_noncombat(), "Confirmed Setup must advance to Intro.")
    _expect_eq(shell.run_state.get_current_screen(), "INTRO", "Setup confirmation must advance to Intro.")
    _expect_eq(shell.run_state.get_player_manual_loadout(), selected_before_advance, "RunState must preserve the selected four-manual loadout.")
    for manual_id in selected_before_advance:
        _expect_eq(int(shell.run_state.get_player_mastery_by_manual().get(str(manual_id), 0)), 3, "All selected starter manuals must be preserved at mastery 3.")

    _expect_true(shell.advance_noncombat(), "Intro must advance to Briefing.")
    await process_frame
    _expect_eq(shell.run_state.get_current_screen(), "BRIEFING", "Run must enter Briefing before Combat.")
    var opponent: Dictionary = shell.run_state.get_current_opponent()
    _expect_true(not opponent.is_empty(), "Briefing must have the already-locked current opponent.")
    var briefing_text := "%s\n%s" % [shell.title_label.text, shell.description_label.text]
    _expect_true(briefing_text.contains(str(opponent.get("working_name", ""))), "Briefing must show the locked opponent working name.")
    _expect_true(briefing_text.contains(str(opponent.get("martial_identity", ""))), "Briefing must show the opponent martial identity.")
    _expect_true(briefing_text.contains(str(opponent.get("public_briefing_hook", ""))), "Briefing must show the approved public briefing hook.")
    _expect_true(briefing_text.contains(str(opponent.get("readable_habit", ""))), "Briefing must expose the readable habit as a hypothesis input.")
    _expect_true(briefing_text.contains(str(opponent.get("ambiguity_or_counterexample", ""))), "Briefing must expose the counterexample/ambiguity instead of an answer key.")
    _expect_false(briefing_text.contains(str(opponent.get("candidate_id", ""))), "Briefing must not expose internal candidate IDs.")
    _expect_false(briefing_text.contains(str(opponent.get("behavior_focus", ""))), "Briefing must not expose internal behavior-focus keys.")
    _expect_true(briefing_text.contains("현재 계획"), "Briefing must explicitly mark the current hidden plan as unknown rather than reveal it.")

    _expect_true(shell.advance_noncombat(), "Briefing must advance to Combat.")
    await process_frame
    await process_frame
    var loadout_snapshot: Dictionary = shell.get_active_combat_loadout_snapshot()
    _expect_eq(loadout_snapshot.get("player_loadout", []), selected_before_advance, "Combat bridge must receive the four selected player manuals.")
    _expect_eq(loadout_snapshot.get("enemy_candidate_id", ""), str(opponent.get("candidate_id", "")), "Combat bridge must bind the locked opponent candidate.")
    _expect_eq(loadout_snapshot.get("enemy_loadout", []), [str(opponent.get("signature_manual_id", ""))], "Combat bridge must use the candidate signature manual rather than the legacy PoC enemy loadout.")
    _expect_eq(int((loadout_snapshot.get("enemy_mastery_by_manual", {}) as Dictionary).get(str(opponent.get("signature_manual_id", "")), 0)), int(opponent.get("signature_star_seed", 0)), "Combat bridge must use the candidate-approved signature mastery seed.")

    shell.queue_free()
    _finish()


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_false(value: bool, message: String) -> void:
    if value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _finish() -> void:
    if failures.is_empty():
        print("VERTICAL_SLICE_SETUP_BRIEFING_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("VERTICAL_SLICE_SETUP_BRIEFING_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
