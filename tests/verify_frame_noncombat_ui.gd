extends SceneTree
const Run := preload("res://src/run/vertical_slice_run_state.gd")
var failures: Array[String] = []

func _initialize() -> void:
    create_timer(60.0).timeout.connect(func(): printerr("FRAME_NONCOMBAT_UI_TIMEOUT"); quit(1))
    call_deferred("_run")

func _run() -> void:
    if "--capture" in OS.get_cmdline_user_args():
        root.size = Vector2i(1600, 900)
        root.content_scale_size = root.size
    var shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    var fixture = Run.new()
    fixture.start_new_frame_run(550, "noncombat-fixture")
    fixture.advance()
    var ids: Array = preload("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0, 4)
    var mastery := {}
    for id in ids: mastery[id] = 3
    fixture.confirm_setup_loadout(ids, mastery)
    fixture.advance()
    for step in range(3): fixture.advance()
    fixture.complete_frame_practice(20)
    fixture.advance()
    fixture.enter_first_journey()
    fixture.select_first_journey_choice("leave")
    fixture.advance()
    fixture.advance()
    # Recorded fixture verifies presentation/readback, not a human-played victory.
    fixture.mark_combat_finished({"outcome": "win", "player_resources": {"health": [24, 30], "stamina": [5, 5], "internal": [4, 4]},
        "battle_metrics": {"successful_dodges": 1, "clash_wins": 2, "player_health_lost": 6, "rounds_elapsed": 3},
        "review_summary": {"cause_label": "합으로 만든 빈틈", "windows": [{"window_index": 0, "events": [{"tick": 30, "type": "attack", "actor": "player", "text": "검이 닿았다", "damage": 4}]}]}})
    fixture.advance()
    shell.run_state = fixture
    fixture.screen_changed.connect(shell._on_screen_changed)
    shell._render_current_screen()
    await process_frame
    var review_button = shell.find_child("ResultReviewButton", true, false)
    await capture("result-fixture")
    check(review_button != null, "result has a separate recorded-review action")
    if review_button == null:
        finish(shell)
        return
    for dimensions in [Vector2i(960, 640), Vector2i(1280, 720)]:
        root.size = dimensions
        root.content_scale_size = dimensions
        shell._render_current_screen()
        for frame in range(5): await process_frame
        check(root.get_visible_rect().encloses(shell.primary_button.get_global_rect()), "result reward confirmation remains inside " + str(dimensions))
        await capture("result-%dx%d-fixture" % [dimensions.x, dimensions.y])
    review_button = shell.find_child("ResultReviewButton", true, false)
    var before: Dictionary = fixture.export_snapshot()
    review_button.pressed.emit()
    await process_frame
    var review = shell.find_child("RecordedCombatReview", true, false)
    await capture("review-fixture")
    check(review != null and review.visible, "read-only review opens independently")
    var review_text = shell.find_child("RecordedReviewText", true, false)
    check(review_text != null and "검이 닿았다" in review_text.text, "review uses actual recorded event label")
    check(fixture.export_snapshot() == before, "viewing review does not replay rewards or battle")
    shell.find_child("RecordedReviewClose", true, false).pressed.emit()
    check(shell.select_result_reward("free_training"), "actual reward remains selectable")
    check(shell.advance_noncombat(), "reward confirmation opens four-step journey")
    await process_frame
    var map = shell.get_node_or_null("FrameJourneyMap")
    await capture("journey-fixture")
    check(map != null and map.visible, "later journey also renders actual route nodes")
    for i in range(1, map._buttons.size() - 1):
        check(not map._buttons[i].get_global_rect().intersects(map._buttons[i + 1].get_global_rect()), "offered journey nodes do not overlap")
    var event_node = map.find_child("JourneyNode_event", true, false)
    check(event_node != null, "offered event is a selectable node")
    var resources_before: Dictionary = fixture.get_progression_snapshot()
    event_node.pressed.emit()
    await process_frame
    check(fixture.get_progression_snapshot() == resources_before and fixture.get_giyun_state().pending_event.is_empty(), "node preview applies no effects")
    shell.find_child("FrameRouteEnter", true, false).pressed.emit()
    await process_frame
    check(not fixture.get_giyun_state().pending_event.is_empty(), "confirm route enters actual event situation")
    check(shell.get_route_option_count() == 3, "all actual ability choices available")
    await capture("event-fixture")
    finish(shell)

func check(value: bool, message: String) -> void:
    if not value: failures.append(message)

func finish(shell) -> void:
    shell.queue_free()
    for failure in failures: printerr("FRAME_NONCOMBAT_UI_FAIL: " + failure)
    if failures.is_empty(): print("FRAME_NONCOMBAT_UI_PASS")
    quit(0 if failures.is_empty() else 1)

func capture(label: String) -> void:
    if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless": return
    DirAccess.make_dir_recursive_absolute("res://output/frame-noncombat")
    for frame in range(4): await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("res://output/frame-noncombat/" + label + ".png")
