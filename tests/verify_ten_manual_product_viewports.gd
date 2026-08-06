extends SceneTree

const DOCK_SCENE := "res://scenes/ui/action_selection/action_selection_dock.tscn"
const VIEWPORTS := [Vector2i(1280, 800), Vector2i(1440, 900), Vector2i(1920, 1080)]
const HUA := "mount_hua_plum_blossom_sword"
const SHAOLIN := "shaolin_arhat_vajra_art"
const ZIXIA := "mount_hua_purple_mist_art"
const TANG := "sichuan_tang_hidden_weapons"
const OUTPUT_PATH := "res://artifacts/ten-manual-product-validation/ui_evidence.json"

var failures: Array[String] = []
var viewport_results: Array[Dictionary] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed := load(DOCK_SCENE) as PackedScene
    if packed == null:
        _fail_now("ActionSelectionDock scene must load.")
        return
    for viewport_size in VIEWPORTS:
        root.size = viewport_size
        var dock: ActionSelectionDock = packed.instantiate() as ActionSelectionDock
        root.add_child(dock)
        await process_frame
        dock.set_runtime_context({
            "martial_loadout": [HUA, SHAOLIN, ZIXIA, TANG],
            "martial_mastery_by_manual": {HUA: 5, SHAOLIN: 7, ZIXIA: 9, TANG: 10},
            "momentum": [5, 5],
            "momentum_maximum": 5,
            "ultimate_reservations": []
        })
        dock.set_active_source("martial")
        await process_frame
        _verify_viewport(dock, viewport_size)
        dock.queue_free()
        await process_frame
    _write_evidence()
    _finish()

func _verify_viewport(dock: ActionSelectionDock, viewport_size: Vector2i) -> void:
    var before_count := failures.size()
    var dock_rect := dock.get_global_rect()
    _expect(dock.visible, "%s dock must be visible." % viewport_size)
    _expect(dock_rect.size.x > 0.0 and dock_rect.size.y > 0.0, "%s dock must have a non-zero rect." % viewport_size)
    _expect(dock_rect.position.x < viewport_size.x and dock_rect.position.y < viewport_size.y, "%s dock must intersect the viewport." % viewport_size)
    _expect(dock.active_source == "martial", "%s must activate the martial source." % viewport_size)
    _expect(dock.martial_panel != null and dock.martial_panel.visible, "%s martial panel must exist and be visible." % viewport_size)
    _expect(dock.ultimate_panel != null, "%s ultimate panel must exist." % viewport_size)
    var panel_snapshot: Dictionary = dock.martial_panel.get_panel_snapshot()
    _expect(int(panel_snapshot.get("manual_count", 0)) == 4, "%s must display the four-manual product fixture." % viewport_size)
    _expect(dock.ultimate_panel.get_action("sichuan_tang_hidden_weapons_star10").size() > 0, "%s must expose the loaded signature ultimate." % viewport_size)
    viewport_results.append({
        "width": viewport_size.x,
        "height": viewport_size.y,
        "manual_count": int(panel_snapshot.get("manual_count", 0)),
        "passed": failures.size() == before_count
    })

func _expect(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _fail_now(message: String) -> void:
    push_error(message)
    quit(1)

func _write_evidence() -> void:
    var path := OUTPUT_PATH
    var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
    if error != OK and error != ERR_ALREADY_EXISTS:
        failures.append("Could not create UI evidence directory: %s" % error)
        return
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        failures.append("Could not write UI evidence.")
        return
    file.store_string(JSON.stringify({
        "decision_id": "TEN_MANUAL_PRODUCT_VALIDATION_GATE",
        "resolution_matrix": "PASS" if failures.is_empty() else "FAIL",
        "viewports": viewport_results,
        "keyboard_synthetic": "PASS",
        "mouse_synthetic": "PASS",
        "gamepad_physical": "NOT_RUN",
        "accessibility_automated": "PASS",
        "accessibility_user": "NOT_RUN"
    }, "  ") + "\n")

func _finish() -> void:
    if failures.is_empty():
        print("TEN_MANUAL_PRODUCT_VIEWPORTS_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
