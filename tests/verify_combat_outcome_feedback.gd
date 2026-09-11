extends SceneTree

const BOARD_SCENE_PATH := "res://scenes/combat/combat_board_preview.tscn"
const BRIDGE_SCENE_PATH := "res://scenes/run/vertical_slice_combat_bridge.tscn"
const SOUND_BANK := preload("res://src/ui/combat_sound_bank.gd")
const ORIGINAL_CUES := {
    "metal_clash": [0.26, 1280.0, 0.32],
    "sword_wind": [0.18, 680.0, 0.82],
    "heavy_hit": [0.25, 92.0, 0.52],
    "block": [0.18, 260.0, 0.28],
    "evade": [0.22, 920.0, 0.88],
    "interrupt": [0.20, 170.0, 0.56],
    "momentum_charge": [0.24, 660.0, 0.03],
    "ultimate_reserve": [0.42, 220.0, 0.15],
    "defeat": [0.52, 110.0, 0.10],
}
const TERMINAL_CASES := [
    {"player": 8, "enemy": 0, "outcome": "win", "cue": "victory", "label": "승리 · 결전 종료", "log": "[승리]"},
    {"player": 0, "enemy": 8, "outcome": "loss", "cue": "defeat", "label": "패배 · 결전 종료", "log": "[패배]"},
    {"player": 0, "enemy": 0, "outcome": "draw", "cue": "draw", "label": "무승부 · 결전 종료", "log": "[무승부]"},
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    _verify_domain_outcomes()
    await _verify_board_outcomes()
    await _verify_bridge_outcomes_and_receipts()
    await _verify_sound_bank()
    _finish()


func _verify_domain_outcomes() -> void:
    for resource_kind in ["array", "packed"]:
        for terminal_case in TERMINAL_CASES:
            var state := _outcome_state(terminal_case.player, terminal_case.enemy, resource_kind == "packed")
            var before := state.duplicate(true)
            _assert(CombatResolutionEngine.battle_outcome(state) == terminal_case.outcome, "Domain outcome must classify %s %s." % [resource_kind, terminal_case.outcome])
            _assert(state == before, "Domain outcome must not mutate %s resources." % resource_kind)
    var ongoing := _outcome_state(8, 8, false)
    _assert(CombatResolutionEngine.battle_outcome(ongoing) == "draw", "Both-healthy domain classification must preserve the bridge's else-draw semantics.")


func _verify_board_outcomes() -> void:
    var packed := load(BOARD_SCENE_PATH) as PackedScene
    _assert(packed != null, "Combat board scene must load.")
    if packed == null:
        return
    for terminal_case in TERMINAL_CASES:
        var board = packed.instantiate()
        board.set_anchors_preset(Control.PRESET_TOP_LEFT)
        board.size = Vector2(1440.0, 900.0)
        root.add_child(board)
        for _index in range(4):
            await process_frame
        board._sound_muted = true
        board.combat_state = _state_from_board(board.combat_state, terminal_case.player, terminal_case.enemy, false)
        var before: Dictionary = board.combat_state.duplicate(true)
        var entries_before: int = board.combat_log_panel.entries.size()
        board._finalize_resolved_bundle()
        _assert(board.combat_state == before, "Board terminal presentation must not alter the resolved %s state." % terminal_case.outcome)
        _assert(str(board.get_meta("presentation_state", "")) == "terminal_result_ready", "Board %s must enter terminal result exactly once." % terminal_case.outcome)
        _assert(board.presentation_label.text == terminal_case.label, "Board %s label must match the domain outcome." % terminal_case.outcome)
        _assert(str(board.get_meta("last_sfx_kind", "")) == terminal_case.cue, "Muted board %s must retain the same cue metadata." % terminal_case.outcome)
        _assert(board.combat_log_panel.entries.size() == entries_before + 1, "Board %s must append one terminal log entry." % terminal_case.outcome)
        if board.combat_log_panel.entries.size() > entries_before:
            var entry: Dictionary = board.combat_log_panel.entries[-1]
            _assert(str(entry.get("text", "")).begins_with(terminal_case.log), "Board %s log must match the outcome." % terminal_case.outcome)
        board.queue_free()
        await process_frame

    var ongoing_board = packed.instantiate()
    ongoing_board.set_anchors_preset(Control.PRESET_TOP_LEFT)
    ongoing_board.size = Vector2(1440.0, 900.0)
    root.add_child(ongoing_board)
    for _index in range(4):
        await process_frame
    ongoing_board._sound_muted = true
    ongoing_board.combat_state = _state_from_board(ongoing_board.combat_state, 8, 8, false)
    ongoing_board._finalize_resolved_bundle()
    _assert(str(ongoing_board.get_meta("presentation_state", "")) != "terminal_result_ready", "Both-healthy draw classification must not create a terminal transition.")
    _assert(str(ongoing_board.get_meta("last_sfx_kind", "")) not in ["victory", "defeat", "draw"], "Both-healthy state must not request a terminal cue.")
    ongoing_board.queue_free()
    await process_frame


func _verify_bridge_outcomes_and_receipts() -> void:
    var packed := load(BRIDGE_SCENE_PATH) as PackedScene
    _assert(packed != null, "Vertical slice bridge scene must load.")
    if packed == null:
        return
    for terminal_case in TERMINAL_CASES:
        var bridge = packed.instantiate()
        bridge.set_anchors_preset(Control.PRESET_TOP_LEFT)
        bridge.size = Vector2(1440.0, 900.0)
        root.add_child(bridge)
        for _index in range(4):
            await process_frame
        bridge._sound_muted = true
        bridge.combat_state = _state_from_board(bridge.combat_state, terminal_case.player, terminal_case.enemy, true)
        var packed_before: Dictionary = bridge.combat_state.duplicate(true)
        var packed_result: Dictionary = bridge._build_vertical_slice_terminal_result()
        _assert(packed_result.get("outcome", "") == terminal_case.outcome, "Bridge PackedInt32Array %s must consume the shared outcome." % terminal_case.outcome)
        _assert(bridge.combat_state == packed_before, "Bridge result construction must not alter PackedInt32Array %s state." % terminal_case.outcome)
        bridge.combat_state = _state_from_board(bridge.combat_state, terminal_case.player, terminal_case.enemy, false)
        var terminal_before: Dictionary = bridge.combat_state.duplicate(true)
        bridge._finalize_resolved_bundle()
        await process_frame
        _assert(bridge._vertical_slice_terminal_result.get("outcome", "") == terminal_case.outcome, "Bridge terminal receipt must retain %s." % terminal_case.outcome)
        _assert(bridge.presentation_label.text == terminal_case.label, "Bridge %s label must match the domain outcome." % terminal_case.outcome)
        _assert(str(bridge.get_meta("last_sfx_kind", "")) == terminal_case.cue, "Muted bridge %s must retain the same cue metadata." % terminal_case.outcome)
        _assert(bridge.combat_state == terminal_before, "Bridge terminal presentation must preserve %s state." % terminal_case.outcome)
        bridge.queue_free()
        await process_frame

    var receipt_bridge = packed.instantiate()
    receipt_bridge.set_anchors_preset(Control.PRESET_TOP_LEFT)
    receipt_bridge.size = Vector2(1440.0, 900.0)
    root.add_child(receipt_bridge)
    for _index in range(4):
        await process_frame
    receipt_bridge._sound_muted = true
    receipt_bridge.combat_state = _state_from_board(receipt_bridge.combat_state, 8, 0, false)
    var receipt_state: Dictionary = receipt_bridge.combat_state.duplicate(true)
    var signal_counts := {"ready": 0, "confirmed": 0}
    receipt_bridge.terminal_review_ready.connect(func(_result: Dictionary) -> void: signal_counts.ready += 1)
    receipt_bridge.terminal_review_confirmed.connect(func(_result: Dictionary) -> void: signal_counts.confirmed += 1)
    receipt_bridge._finish_bundle_presentation(true)
    receipt_bridge._finish_bundle_presentation(true)
    receipt_bridge.call_deferred("_confirm_terminal_result_once")
    await process_frame
    await process_frame
    _assert(signal_counts.ready == 1 and signal_counts.confirmed == 1, "Repeated terminal finish must preserve exactly-once ready/confirmed receipts.")
    _assert(receipt_bridge.combat_state == receipt_state, "Terminal receipt emission must preserve the resolved state.")
    _assert(receipt_bridge._vertical_slice_terminal_result.get("outcome", "") == "win", "Terminal receipt must retain the shared win outcome.")
    receipt_bridge.queue_free()
    await process_frame


func _verify_sound_bank() -> void:
    for cue in ORIGINAL_CUES:
        var stream := SOUND_BANK.get_stream(cue)
        _assert(stream != null, "Original cue must remain available: %s" % cue)
        if stream != null:
            # User-approved 2026-09-10 sound redesign preserves cue identity, not old PCM.
            _assert(stream.format == AudioStreamWAV.FORMAT_16_BITS and stream.mix_rate == 22050 and not stream.stereo, "Existing cue format must remain compatible: %s" % cue)
            _assert(stream.data.size() == int(float(SOUND_BANK.CUES[cue][0]) * SOUND_BANK.RATE) * 2, "Cue PCM must match its authored duration: %s" % cue)
            _assert(SOUND_BANK.get_stream(cue) == stream, "Existing cue must remain cached: %s" % cue)
            var original_bytes: PackedByteArray = stream.data.duplicate()
            SOUND_BANK._streams.erase(cue)
            _assert(SOUND_BANK.get_stream(cue).data == original_bytes, "Cue regeneration must remain deterministic: %s" % cue)
            print("CURRENT_CUE_SHA256 %s %s" % [cue, _sha256(stream.data)])
    var new_data := {}
    var total_pcm_bytes := 0
    for cue in ["victory", "draw", "ultimate_release"]:
        var stream := SOUND_BANK.get_stream(cue)
        _assert(stream != null, "New authored cue must be available: %s" % cue)
        if stream == null:
            continue
        _assert(stream.format == AudioStreamWAV.FORMAT_16_BITS, "%s must be 16-bit PCM." % cue)
        _assert(stream.mix_rate == 22050, "%s must use 22050 Hz." % cue)
        _assert(not stream.stereo, "%s must be mono." % cue)
        _assert(not stream.data.is_empty(), "%s PCM must be nonempty." % cue)
        _assert(SOUND_BANK.get_stream(cue) == stream, "%s must be cached by object identity." % cue)
        for offset in range(0, stream.data.size(), 2):
            var sample := stream.data.decode_s16(offset)
            _assert(sample >= -32768 and sample <= 32767, "%s PCM sample must remain in signed 16-bit range." % cue)
        new_data[cue] = stream.data
        total_pcm_bytes += stream.data.size()
    print("NEW_CUE_PCM_BYTES %d" % total_pcm_bytes)
    _assert(total_pcm_bytes < 64 * 1024, "Three new cues must remain below the 64 KiB PCM budget.")
    if new_data.size() == 3:
        _assert(new_data.victory != new_data.draw and new_data.victory != new_data.ultimate_release and new_data.draw != new_data.ultimate_release, "New authored cue PCM must be distinct.")
    for cue in ["victory", "draw", "ultimate_release"]:
        if SOUND_BANK.CUES.has(cue):
            for parameter in SOUND_BANK.CUES[cue]:
                var numeric_parameter := float(parameter)
                _assert(not is_inf(numeric_parameter) and not is_nan(numeric_parameter), "%s synthesis parameters must be finite." % cue)
    _assert(SOUND_BANK.get_stream("unknown_terminal_cue") == null, "Unknown cue lookup must remain null.")
    await _verify_natural_playback_cleanup()


func _verify_natural_playback_cleanup() -> void:
    var stream := SOUND_BANK.get_stream("victory")
    var playback := stream.instantiate_playback()
    playback.start()
    var mixed_frames := 0
    var requested_frames := 0
    while playback.is_playing() and requested_frames <= SOUND_BANK.RATE * 2:
        var mixed := playback.mix_audio(1.0, 512)
        mixed_frames += mixed.size()
        requested_frames += 512
    _assert(not playback.is_playing(), "Victory cue must stop naturally after bounded real mixer pulls.")
    _assert(mixed_frames >= int(float(SOUND_BANK.CUES.victory[0]) * SOUND_BANK.RATE), "Victory cue playback must cross its authored duration before natural end.")
    playback.stop()
    playback = null
    SOUND_BANK._streams.clear()


func _synthesize_original_cue(kind: String, parameters: Array) -> PackedByteArray:
    var duration: float = parameters[0]
    var frequency: float = parameters[1]
    var noise_mix: float = parameters[2]
    var count := int(duration * SOUND_BANK.RATE)
    var pcm := PackedByteArray()
    pcm.resize(count * 2)
    var rng := RandomNumberGenerator.new()
    rng.seed = kind.hash()
    var phase := 0.0
    var filtered_noise := 0.0
    for index in range(count):
        var time := float(index) / SOUND_BANK.RATE
        var progress := float(index) / count
        var rise := minf(time / 0.006, 1.0)
        var envelope := rise * pow(1.0 - progress, 2.5)
        var sweep := 1.0 - 0.4 * progress
        if kind in ["momentum_charge", "ultimate_reserve"]:
            sweep = 1.0 + 0.6 * progress
        phase += TAU * frequency * sweep / SOUND_BANK.RATE
        filtered_noise = lerpf(filtered_noise, rng.randf_range(-1.0, 1.0), 0.60)
        var tone := sin(phase) * 0.6 + sin(phase * 2.71) * 0.25 + sin(phase * 4.13) * 0.15
        var value := clampf(lerpf(tone, filtered_noise, noise_mix) * envelope * 0.65, -1.0, 1.0)
        pcm.encode_s16(index * 2, int(value * 32767.0))
    return pcm


func _outcome_state(player_health: int, enemy_health: int, packed: bool) -> Dictionary:
    var player_pair = PackedInt32Array([player_health, 30]) if packed else [player_health, 30]
    var enemy_pair = PackedInt32Array([enemy_health, 30]) if packed else [enemy_health, 30]
    return {"player": {"health": player_pair}, "enemy": {"health": enemy_pair}}


func _state_from_board(source: Dictionary, player_health: int, enemy_health: int, packed: bool) -> Dictionary:
    var state := source.duplicate(true)
    for actor_key in ["player", "enemy"]:
        var actor: Dictionary = (state.get(actor_key, {}) as Dictionary).duplicate(true)
        var value := player_health if actor_key == "player" else enemy_health
        var prior = actor.get("health", [value, 30])
        var maximum := int(prior[1]) if prior.size() >= 2 else 30
        actor["health"] = PackedInt32Array([value, maximum]) if packed else [value, maximum]
        state[actor_key] = actor
    return state


func _sha256(bytes: PackedByteArray) -> String:
    var context := HashingContext.new()
    context.start(HashingContext.HASH_SHA256)
    context.update(bytes)
    return context.finish().hex_encode()


func _assert(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)


func _finish() -> void:
    if failures.is_empty():
        print("COMBAT_OUTCOME_FEEDBACK_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("COMBAT_OUTCOME_FEEDBACK_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
