extends SceneTree

const PANEL_SCENE := "res://scenes/ui/action_selection/basic_action_panel.tscn"

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(PANEL_SCENE) as PackedScene
    _check(packed != null, "Basic action panel scene must load.")
    if packed == null:
        _finish()
        return
    var panel = packed.instantiate()
    root.add_child(panel)
    for frame in range(5):
        await process_frame

    var snapshot: Dictionary = panel.get_panel_snapshot()
    _check(int(snapshot.get("action_count", 0)) == 10, "Basic panel must expose ten actions.")
    _check(int(snapshot.get("columns", 0)) == 5, "Basic panel must retain five columns.")
    _check(snapshot.get("action_ids", []) == [
        "basic_move",
        "basic_footwork",
        "basic_guard",
        "basic_evade",
        "basic_quick_attack",
        "basic_heavy_attack",
        "basic_observe",
        "basic_meditate",
        "basic_stance",
        "basic_palm"
    ], "Basic action order must remain stable.")
    _check(not bool(snapshot.get("scrolling_enabled", true)), "The bounded five-by-two basic grid must not scroll.")
    _check(panel.buttons.size() == 10, "Basic panel must render ten cards.")
    for button_value in panel.buttons:
        var button := button_value as Button
        var summary := button.get_node_or_null("CardSummary") as VBoxContainer
        var illustration := button.get_node_or_null("CardIllustration") as TextureRect
        var name_label := button.get_node_or_null("CardName") as Label
        _check(is_instance_valid(summary), "Every basic card must retain its two-line summary.")
        _check(is_instance_valid(illustration), "Every basic card must retain its illustration.")
        _check(is_instance_valid(name_label), "Every basic card must retain its readable name.")
        _check(button.custom_minimum_size.y <= 112.0, "Every basic card must fit the cross-platform two-row height budget.")
        if is_instance_valid(summary):
            _check(summary.get_child_count() == 2, "Every basic card must retain exactly two summary lines.")
            _check(button.custom_minimum_size.y >= 52.0 + summary.get_combined_minimum_size().y + 4.0, "Basic card height must contain native summary metrics plus bottom padding.")
        if is_instance_valid(illustration):
            _check(illustration.size.y >= 50.0, "Basic card illustration must retain a readable visual band.")
            _check(Rect2(Vector2.ZERO, button.size).encloses(illustration.get_rect()), "Basic card illustration must stay inside the card.")
        if is_instance_valid(illustration) and is_instance_valid(name_label):
            _check(name_label.get_rect().end.y <= illustration.get_rect().end.y, "The outlined name overlay must stay inside the illustration band.")
            _check(button.get_node_or_null("ActionDurationBadge") != null, "Duration must remain separate from the two summary lines.")

    panel.set_interaction_enabled(false)
    _check(not bool(panel.get_panel_snapshot().get("interaction_enabled", true)), "Basic panel must report disabled interaction.")
    panel.set_interaction_enabled(true)
    _check(bool(panel.get_panel_snapshot().get("interaction_enabled", false)), "Basic panel must report restored interaction.")

    panel.queue_free()
    await process_frame
    _finish()

func _check(condition: bool, message: String) -> void:
    if condition:
        return
    failures.append(message)
    push_error(message)

func _finish() -> void:
    if failures.is_empty():
        print("verify_basic_action_panel: PASS")
        quit(0)
        return
    print("verify_basic_action_panel: FAIL count=%d" % failures.size())
    quit(1)
