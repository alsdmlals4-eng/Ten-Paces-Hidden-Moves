extends SceneTree

func _initialize() -> void:
	var bank = preload("res://src/ui/combat_sound_bank.gd")
	var clash = bank.get_stream("metal_clash")
	if clash.get_length() < 0.40:
		push_error("METAL_RESONANCE_TAIL_TOO_SHORT")
		quit(1)
		return
	var wind = bank.get_stream("sword_wind")
	if _rms(wind.data, 0.35, 0.65) <= _rms(wind.data, 0.0, 0.12) * 2.0:
		push_error("WIND_HAS_NO_APPROACH_AND_PASS_ENVELOPE")
		quit(1)
		return
	for cue in bank.CUES:
		var stream = bank.get_stream(cue)
		var args := OS.get_cmdline_user_args()
		if args.size() == 1 and args[0].is_absolute_path():
			DirAccess.make_dir_recursive_absolute(args[0])
			if stream.save_to_wav(args[0].path_join(cue + ".wav")) != OK:
				quit(1)
				return
		if stream != bank.get_stream(cue) or abs(stream.data.decode_s16(0)) > 50 or abs(stream.data.decode_s16(stream.data.size()-2)) > 50:
			push_error("SOUND_CACHE_OR_CLICK_BOUNDARY " + cue)
			quit(1)
			return
		for i in range(stream.data.size()/2):
			if abs(stream.data.decode_s16(i*2)) > 26000:
				push_error("SOUND_HEADROOM_EXCEEDED " + cue)
				quit(1)
				return
	print("WUXIA_SOUND_ENVELOPES_PASS")
	quit(0)

func _rms(data: PackedByteArray, begin: float, end: float) -> float:
	var count := data.size()/2
	var first := int(count*begin)
	var last := int(count*end)
	var energy := 0.0
	for i in range(first,last):
		var sample := float(data.decode_s16(i*2))/32768.0
		energy += sample*sample
	return sqrt(energy/maxi(1,last-first))
