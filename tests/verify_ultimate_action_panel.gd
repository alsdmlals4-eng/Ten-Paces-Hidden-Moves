extends SceneTree

var selected_count := 0
var selected_id := ""
var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene := load("res://scenes/ui/action_selection/ultimate_action_panel.tscn") as PackedScene
    if scene == null:
        failures.append("UltimateActionPanel scene must load.")
        _finish()
        return
    var panel := scene.instantiate() as UltimateActionPanel
    get_root().add_child(panel)
    await process_frame

    panel.set_momentum(4, 5)
    await process_frame
    var locked_snapshot: Dictionary = panel.get_panel_snapshot()
    _check(int(locked_snapshot.get("momentum_current", -1)) == 4, "Momentum current must be 4.")
    _check(int(locked_snapshot.get("momentum_maximum", -1)) == 5, "Momentum maximum must be 5.")
    _check(int(locked_snapshot.get("enabled_count", -1)) == 0, "No ultimate may be enabled below five momentum.")
    _check(int(locked_snapshot.get("action_count", 0)) >= 4, "Base and mastery ultimates must both be represented.")
    _check(str(locked_snapshot.get("illustration_policy", "")) == "semantic_atlas", "Ultimate cards must publish the semantic-atlas policy.")
    _check(int(locked_snapshot.get("action_columns", 0)) == 5, "Ultimate cards must use the shared five-column grid.")
    _check(not panel.momentum_label.visible and not panel.segment_row.visible, "Ultimate momentum belongs in the shared status HUD, not above the card grid.")
    _check(str(panel.get_action("ultimate_ten_paces_wave").get("lock_reason", "")) == "기세 4/5", "Momentum lock reason must show 4/5.")
    var locked_button: Button = panel.get_action_button("ultimate_ten_paces_wave")
    _check(is_instance_valid(locked_button) and is_instance_valid(locked_button.find_child("CardIllustration", false, false)), "Locked ultimates must retain their semantic illustration.")

    panel.set_momentum(5, 5)
    await process_frame
    var ready_snapshot: Dictionary = panel.get_panel_snapshot()
    _check(int(ready_snapshot.get("enabled_count", 0)) == 3, "Exactly three base ultimates must be enabled at five momentum.")
    _check(not bool(panel.get_action("ultimate_ten_paces_wave").get("locked", true)), "Base ultimate must unlock at five momentum.")
    _check(bool(panel.get_action("ultimate_flowing_cloud_true_intent").get("locked", false)), "Mastery ultimate must remain locked below ten mastery.")
    _check(str(panel.get_action("ultimate_flowing_cloud_true_intent").get("lock_reason", "")) == "10성 해금 · 현재 3성", "Mastery lock reason must show 10 and 3 mastery.")

    panel.set_reservations([
        {
            "action_id": "ultimate_cleave_peak",
            "start_timing": 5,
            "end_timing": 6
        }
    ])
    await process_frame
    var reserved_button: Button = panel.get_action_button("ultimate_cleave_peak")
    _check(is_instance_valid(reserved_button), "Reserved ultimate button must exist.")
    if is_instance_valid(reserved_button):
        _check(reserved_button.find_child("CardStatus", false, false) == null, "Compact ultimate cards must not add an extra state row below their core tag.")
        _check("5~6수 예약" in reserved_button.accessibility_name, "Reserved ultimate timing must remain available to assistive output.")

    panel.ultimate_selected.connect(_on_ultimate_selected)
    _check(panel.activate_ultimate("ultimate_flowing_cloud_true_intent") == false, "Locked mastery ultimate must not activate.")
    _check(selected_count == 0, "Locked mastery ultimate must not emit selection.")
    _check(panel.activate_ultimate("ultimate_ten_paces_wave"), "Ready base ultimate must activate.")
    _check(selected_count == 1, "Ready base ultimate must emit exactly one selection.")
    _check(selected_id == "ultimate_ten_paces_wave", "Selected ultimate ID must match the activated action.")

    panel.queue_free()
    await process_frame
    _finish()

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _on_ultimate_selected(definition: Dictionary) -> void:
    selected_count += 1
    selected_id = str(definition.get("id", ""))

func _finish() -> void:
    if failures.is_empty():
        print("verify_ultimate_action_panel: PASS")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
        print("ULTIMATE_PANEL_FAILURE %s" % failure)
    print("verify_ultimate_action_panel: FAIL count=%d" % failures.size())
    quit(1)
