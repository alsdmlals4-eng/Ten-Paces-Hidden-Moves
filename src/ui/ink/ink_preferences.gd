extends RefCounted
## Local presentation preferences are separate from durable gameplay checkpoints.
const DEFAULTS := {"sound": true, "volume": 0.65, "reduced_motion": false, "fast_replay": false}
var values: Dictionary = DEFAULTS.duplicate()
var path := "user://presentation.cfg"

func _init(storage_path: String = "user://presentation.cfg") -> void:
    path = storage_path
    var config := ConfigFile.new()
    if config.load(path) != OK: return
    for key in DEFAULTS:
        var value = config.get_value("presentation", key, DEFAULTS[key])
        if key == "volume":
            if typeof(value) in [TYPE_FLOAT, TYPE_INT] and is_finite(float(value)):
                values[key] = clampf(value, 0.0, 1.0)
        elif typeof(value) == TYPE_BOOL:
            values[key] = value

func save() -> Error:
    var config := ConfigFile.new()
    for key in DEFAULTS: config.set_value("presentation", key, values[key])
    return config.save(path)

func apply(board: Control) -> void:
    if board._sound_muted == bool(values.sound): board._toggle_sound()
    if board._fast_replay != bool(values.fast_replay): board._toggle_fast_replay()
    if board._reduced_motion != bool(values.reduced_motion): board._toggle_reduced_motion()
    board._set_sound_volume(float(values.volume))
