extends RefCounted
## Presentation preferences have a different lifetime from a run checkpoint.
## Empty storage keeps isolated previews and script tests away from user files.

var sound_muted := false
var sound_volume := 0.65
var reduced_motion := false
var last_save_error: Error = OK
var _path := ""

func configure(path: String) -> void:
    _path = path
    sound_muted = false
    sound_volume = 0.65
    reduced_motion = false
    last_save_error = OK
    if path.is_empty(): return
    var config := ConfigFile.new()
    if config.load(path) != OK: return
    var muted = config.get_value("presentation", "sound_muted", false)
    var motion = config.get_value("presentation", "reduced_motion", false)
    sound_muted = muted if muted is bool else false
    reduced_motion = motion if motion is bool else false
    sound_volume = _validated_volume(config.get_value("presentation", "sound_volume", 0.65))

func update(muted: bool, volume: float, motion: bool) -> Error:
    sound_muted = muted
    sound_volume = _validated_volume(volume)
    reduced_motion = motion
    last_save_error = OK
    if _path.is_empty(): return OK
    var config := ConfigFile.new()
    config.set_value("presentation", "sound_muted", sound_muted)
    config.set_value("presentation", "sound_volume", sound_volume)
    config.set_value("presentation", "reduced_motion", reduced_motion)
    # Finish writing before replacing the last readable settings file.
    var pending := _path + ".pending"
    last_save_error = config.save(pending)
    if last_save_error == OK:
        last_save_error = DirAccess.rename_absolute(pending, _path)
    return last_save_error

func _validated_volume(value: Variant) -> float:
    if (value is float or value is int) and is_finite(float(value)):
        return clampf(float(value), 0.0, 1.0)
    return 0.65
