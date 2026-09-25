extends SceneTree

const RUN = preload("res://src/run/vertical_slice_run_state.gd")
const CODEC = preload("res://src/run/run_checkpoint_codec.gd")
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
    var run = RUN.new()
    _check(run.start_new_frame_run(521, "frame-save-test"), "new frame run starts")
    var codec = CODEC.new()
    var encoded: Dictionary = codec.encode("frame-save-test", "intro-1", 1, run.export_snapshot())
    _check(encoded.ok, "prologue is durable")
    if encoded.ok:
        _check(encoded.payload.schema_version == 7, "frame rules use their own save schema")
        var decoded: Dictionary = codec.decode(encoded.text)
        _check(decoded.ok, "frame prologue JSON round trip: " + str(decoded.get("error", "")))
        var forged: Dictionary = encoded.payload.duplicate(true)
        forged.schema_version = 6
        forged.content_identity = codec.content_identity_for_schema(6)
        forged.erase("integrity_hash")
        forged.integrity_hash = CODEC.digest(forged)
        _check(not codec.decode(JSON.stringify(forged)).ok, "old schema cannot silently acquire frame rules")
    var old = RUN.new()
    _check(old.start_new_giyun_run(521, "legacy-test"), "legacy fixture starts")
    var legacy: Dictionary = codec.encode("legacy-test", "legacy-1", 1, old.export_snapshot())
    _check(legacy.ok and legacy.payload.schema_version == 6, "legacy saves remain schema six")
    if legacy.ok:
        var decoded: Dictionary = codec.decode(legacy.text)
        _check(decoded.ok, "legacy round trip still works: " + str(decoded.get("error", "")))
    for failure in failures: print("FAIL: ", failure)
    print("FRAME_SAVE checks=%d failures=%d" % [checks, failures.size()])
    quit(0 if failures.is_empty() else 1)

func _check(value: bool, label: String) -> void:
    checks += 1
    if not value: failures.append(label)
