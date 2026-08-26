# 기본 실행 진입점이 실제 첫 5전 세로 슬라이스 시작 기능을 제공하는지 검증한다.
extends SceneTree

const EXPECTED_WINDOW_TITLE := "십보강호: 첫 5전 Vertical Slice"

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    _expect_true(
        str(ProjectSettings.get_setting("application/config/name", "")) == EXPECTED_WINDOW_TITLE,
        "Default application title must identify the first-five-duel Vertical Slice."
    )
    var main_scene_path := str(ProjectSettings.get_setting("application/run/main_scene", ""))
    var packed := load(main_scene_path) as PackedScene
    _expect_true(packed != null, "Configured main scene must be loadable: %s" % main_scene_path)
    if packed != null:
        var entry = packed.instantiate()
        root.add_child(entry)
        await process_frame
        await process_frame
        _expect_true(entry.has_method("start_new_run"), "Default entry must start the first-five-duel run.")
        _expect_true(bool(entry.get_meta("technical_shell", false)), "Default entry must retain the existing Vertical Slice shell boundary.")
        entry.queue_free()
    _finish()


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _finish() -> void:
    if failures.is_empty():
        print("DEFAULT_VERTICAL_SLICE_ENTRY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("DEFAULT_VERTICAL_SLICE_ENTRY_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
