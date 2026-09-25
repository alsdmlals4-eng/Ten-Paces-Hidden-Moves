extends SceneTree
const Shell := preload("res://scenes/run/vertical_slice_shell.tscn")
var checks := 0
var failures := 0

func _initialize() -> void:
    create_timer(60.0).timeout.connect(func(): printerr("FRAME_ONBOARDING_UI_TIMEOUT"); quit(1))
    call_deferred("_run")

func _run() -> void:
    if "--capture" in OS.get_cmdline_user_args():
        root.size = Vector2i(1600, 900)
        root.content_scale_size = root.size
    var shell = Shell.instantiate()
    root.add_child(shell)
    await process_frame
    await capture("main")
    if not expect(shell.main_title_screen.find_child("PlayerTitleBattler", true, false) == null, "main removes two standing characters"): return
    expect(shell.start_new_run(), "native new game starts")
    await process_frame
    await capture("prologue")
    expect(shell.run_state.get_current_screen() == "PROLOGUE", "default game enters prologue")
    var view = shell.get_node_or_null("FrameOnboarding")
    if not expect(view != null and view.visible, "prologue UI shown"): return
    expect(view.find_child("OnboardingPrimary", true, false) != null, "readable native prologue continue")
    view.find_child("OnboardingPrimary", true, false).pressed.emit()
    await process_frame
    expect(shell.run_state.get_current_screen() == "SETUP", "prologue continue opens existing illustrated manuals")
    await capture("setup")
    for id in preload("res://src/run/vertical_slice_starter_manual_catalog.gd").STARTER_MANUAL_IDS.slice(0, 4): shell.toggle_setup_manual(id)
    expect(shell.advance_noncombat(), "selected four manuals confirmed")
    await capture("tutorial")
    for step in range(3):
        expect(shell.run_state.get_frame_onboarding().tutorial_step == step, "tutorial renders correct step")
        view.find_child("OnboardingPrimary", true, false).pressed.emit()
        await process_frame
    expect(view.find_child("PracticePlace20", true, false) != null, "tutorial has an actual timing practice")
    view.find_child("PracticePlace20", true, false).pressed.emit()
    await process_frame
    expect(shell.run_state.get_frame_onboarding().practice_complete, "native practice action persisted")
    view.find_child("OnboardingPrimary", true, false).pressed.emit()
    await process_frame
    expect(shell.run_state.get_current_screen() == "FIRST_JOURNEY", "first route map shown")
    await capture("first-journey")
    expect(view.find_child("JourneyNode_first_event", true, false) != null, "route map has interactive event node")
    view.find_child("JourneyNode_first_event", true, false).pressed.emit()
    await process_frame
    expect(view.find_child("IntroChoice_observe", true, false) != null, "node opens stat choices")
    await capture("first-event")
    view.find_child("IntroChoice_observe", true, false).pressed.emit()
    await process_frame
    expect(not shell.run_state.get_frame_onboarding().journey_receipt.is_empty(), "UI event records outcome")
    view.find_child("OnboardingPrimary", true, false).pressed.emit()
    await process_frame
    expect(shell.run_state.get_current_screen() == "BRIEFING", "event continues to briefing")
    expect(shell.find_child("BriefingOwnStatus", true, false) != null, "briefing includes own status column")
    expect(shell.find_child("BriefingFaceoff", true, false) != null, "briefing includes faceoff and constraints")
    expect(shell.find_child("PublicOpponentBriefing", true, false) != null, "briefing includes public enemy information")
    await capture("briefing")
    for dimensions in [Vector2i(960, 640), Vector2i(1280, 720), Vector2i(1086, 1448)]:
        root.size = dimensions
        root.content_scale_size = dimensions
        shell._render_current_screen()
        for frame in range(5): await process_frame
        expect(root.get_visible_rect().encloses(shell.primary_button.get_global_rect()), "briefing continue stays inside viewport " + str(dimensions))
        expect(root.get_visible_rect().encloses(shell.get_bimu_constraint_panel().options_scroll.get_global_rect()), "constraint list stays reachable " + str(dimensions))
        await capture("briefing-%dx%d" % [dimensions.x, dimensions.y])
    shell.queue_free()
    await process_frame
    if failures == 0: print("FRAME_ONBOARDING_UI_PASS checks=%d" % checks)
    quit(0 if failures == 0 else 1)

func expect(value: bool, message: String) -> bool:
    checks += 1
    if value: return true
    printerr("FRAME_ONBOARDING_UI_FAIL: " + message)
    failures += 1
    quit(1)
    return false

func capture(label: String) -> void:
    if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless": return
    DirAccess.make_dir_recursive_absolute("res://output/frame-noncombat")
    for frame in range(4): await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("res://output/frame-noncombat/" + label + ".png")
