extends SceneTree

const PANEL_SCENE := preload("res://scenes/ui/opponent_hypothesis_panel.tscn")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel := PANEL_SCENE.instantiate() as OpponentHypothesisPanel
    root.add_child(panel)
    await process_frame

    var initial := panel.get_current_hypothesis_snapshot()
    _expect(str(initial.get("id", "")) == "none", "Initial hypothesis must be none.")
    _expect(str(initial.get("label", "")) == "기록한 가설 없음", "None label changed.")
    _expect(not bool(initial.get("recorded", true)), "None must not be recorded.")

    _expect(panel.select_hypothesis("quick_attack"), "Known hypothesis selection must succeed.")
    var selected := panel.get_current_hypothesis_snapshot()
    _expect(str(selected.get("id", "")) == "quick_attack", "Selected hypothesis id changed.")
    _expect(bool(selected.get("recorded", false)), "Known hypothesis must be recorded.")

    selected["id"] = "mutated"
    _expect(str(panel.get_current_hypothesis_snapshot().get("id", "")) == "quick_attack", "Snapshot must be detached from panel state.")

    panel.set_locked(true)
    _expect(not panel.select_hypothesis("ultimate"), "Locked panel must reject selection changes.")
    _expect(str(panel.get_current_hypothesis_snapshot().get("id", "")) == "quick_attack", "Locked panel state changed.")

    panel.set_locked(false)
    _expect(panel.select_hypothesis("missing") == false, "Unknown hypothesis must be rejected.")
    _expect(str(panel.get_current_hypothesis_snapshot().get("id", "")) == "none", "Unknown hypothesis must degrade to none.")

    panel.select_hypothesis("approach")
    panel.reset_to_initial()
    _expect(str(panel.get_current_hypothesis_snapshot().get("id", "")) == "none", "Reset must restore none.")
    _expect(panel.get_hypothesis_ids() == ["approach", "quick_attack", "heavy_prepare", "response_or_recover", "ultimate", "none"], "Hypothesis ids changed.")

    panel.queue_free()
    await process_frame
    if failures.is_empty():
        print("COMBAT_HYPOTHESIS_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
