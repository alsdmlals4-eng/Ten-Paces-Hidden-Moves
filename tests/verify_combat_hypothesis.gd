extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel := OpponentHypothesisPanel.new()
    root.add_child(panel)
    await process_frame
    if panel.snapshot_hypothesis() != {"id": "none", "label": "기록한 가설 없음", "recorded": false}:
        push_error("Unselected hypothesis must remain explicit none.")
        quit(1)
        return
    panel.select_hypothesis("heavy_prepare")
    var snapshot := panel.snapshot_hypothesis()
    if snapshot.get("id") != "heavy_prepare" or snapshot.get("recorded") != true:
        push_error("Selected hypothesis snapshot changed.")
        quit(1)
        return
    var frozen := snapshot.duplicate(true)
    panel.clear_hypothesis()
    if frozen.get("id") != "heavy_prepare" or panel.selected_id() != "none":
        push_error("Committed snapshot must not mutate when panel is cleared.")
        quit(1)
        return
    print("COMBAT_HYPOTHESIS_VERIFY_OK")
    quit(0)
