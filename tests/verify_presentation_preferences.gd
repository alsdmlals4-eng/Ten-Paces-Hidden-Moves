extends SceneTree

var failures: Array[String] = []
var checks := 0

func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok: failures.append(label)

func _initialize() -> void:
    var source := "res://src/ui/presentation_preferences.gd"
    if not FileAccess.file_exists(source):
        print("PRESENTATION_PREFERENCES FAIL: missing persistent preference owner")
        quit(1)
        return
    var script = load(source)
    var folder := "user://preferences-test-%s" % Time.get_ticks_usec()
    DirAccess.make_dir_recursive_absolute(folder)
    var path := folder.path_join("settings.cfg")
    var store = script.new()
    store.configure(path)
    check(not store.sound_muted and not store.reduced_motion and is_equal_approx(store.sound_volume, 0.65), "missing file defaults")
    check(not FileAccess.file_exists(path), "loading does not write")
    check(store.update(true, 0.25, true) == OK, "save succeeds")
    var restored = script.new()
    restored.configure(path)
    check(restored.sound_muted and restored.reduced_motion and is_equal_approx(restored.sound_volume, 0.25), "new instance restores settings")
    var config := ConfigFile.new()
    config.set_value("presentation", "sound_muted", "false")
    config.set_value("presentation", "reduced_motion", 1)
    config.set_value("presentation", "sound_volume", 9.0)
    config.save(path)
    restored.configure(path)
    check(not restored.sound_muted and not restored.reduced_motion and restored.sound_volume == 1.0, "strict bool and bounded numeric load")
    for value in [-5.0, "loud", NAN, INF]:
        config.set_value("presentation", "sound_volume", value)
        config.save(path)
        restored.configure(path)
        check(restored.sound_volume == (0.0 if value is float and value == -5.0 else 0.65), "invalid volume %s" % str(value))
    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_string("[presentation\nsound_muted=")
    file.close()
    restored.configure(path)
    check(not restored.sound_muted and is_equal_approx(restored.sound_volume, 0.65), "malformed config defaults")
    check(FileAccess.get_file_as_string(path) == "[presentation\nsound_muted=", "load preserves malformed original")
    var blocked := folder.path_join("absent/blocked.cfg")
    restored.configure(blocked)
    check(restored.update(true, 0.4, true) != OK, "write failure surfaced")
    check(restored.sound_muted and restored.reduced_motion and is_equal_approx(restored.sound_volume, 0.4), "failure retains session settings")
    DirAccess.make_dir_recursive_absolute(blocked.get_base_dir())
    check(restored.update(true, 0.4, true) == OK, "same values retry after failure")
    var transient = script.new()
    transient.configure("")
    check(transient.update(true, 0.0, true) == OK and transient.sound_volume == 0.0, "isolated in-memory settings")
    var progress := folder.path_join("run_checkpoint.json")
    file = FileAccess.open(progress, FileAccess.WRITE)
    file.store_string("unchanged run save bytes")
    file.close()
    store.update(false, 0.8, false)
    check(FileAccess.get_file_as_string(progress) == "unchanged run save bytes", "progress file untouched")
    print("PRESENTATION_PREFERENCES ", "PASS" if failures.is_empty() else "FAIL", " checks=", checks, " failures=", failures, " artifacts=", ProjectSettings.globalize_path(folder))
    quit(0 if failures.is_empty() else 1)
