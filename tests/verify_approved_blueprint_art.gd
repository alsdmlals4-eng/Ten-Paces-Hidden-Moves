extends SceneTree

const Art := preload("res://src/ui/approved_blueprint_art.gd")
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/blueprint/APPROVED_ART_MANIFEST.json"))
    _check(Art.PORTRAITS == manifest["portraits"], "Portrait map drift")
    _check(Art.MANUALS == manifest["manuals"], "Manual map drift")
    _check(Art.CLASH_EXPLANATION == manifest["clash_explanation"], "Clash map drift")
    _check(Art.portrait("unknown") == null, "Unknown candidate must not borrow another portrait")
    _check(Art.manual_illustration("unknown", 10) == null, "Unknown manual must not borrow art")
    for candidate_id: String in Art.PORTRAITS:
        var texture := Art.portrait(candidate_id)
        _check(texture != null and texture.get_width() > 0, "Portrait failed to load: " + candidate_id)
    for manual_id: String in Art.MANUALS:
        _check(Art.manual_path(manual_id, 2).is_empty(), "Locked manual has no illustration")
        for star: int in [3, 7, 10]:
            var texture := Art.manual_illustration(manual_id, star)
            _check(texture != null and texture.get_width() > 0, "Manual failed to load: %s/%d" % [manual_id, star])
        _check(Art.manual_path(manual_id, 6) == Art.manual_path(manual_id, 3), "3-6 band")
        _check(Art.manual_path(manual_id, 9) == Art.manual_path(manual_id, 7), "7-9 band")
    _check(Art.clash_explanation() != null, "Separate explanatory image failed to load")
    if failures.is_empty():
        print("APPROVED_BLUEPRINT_ART_PASS: 47 textures, exact IDs, milestone bands, unknown-ID boundaries")
        quit(0)
    else:
        for message in failures:
            push_error(message)
        quit(1)

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)
