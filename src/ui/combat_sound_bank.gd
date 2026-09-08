class_name CombatSoundBank
extends RefCounted

# Original deterministic synthesis; no third-party recordings or runtime allocation
# after a cue has first been requested. Volume belongs to the player, not PCM data.
static var _streams: Dictionary = {}
const RATE := 22050
const CUES := {
    "metal_clash": [0.26, 1280.0, 0.32],
    "sword_wind": [0.18, 680.0, 0.82],
    "heavy_hit": [0.25, 92.0, 0.52],
    "block": [0.18, 260.0, 0.28],
    "evade": [0.22, 920.0, 0.88],
    "interrupt": [0.20, 170.0, 0.56],
    "momentum_charge": [0.24, 660.0, 0.03],
    "ultimate_reserve": [0.42, 220.0, 0.15],
    "defeat": [0.52, 110.0, 0.10],
    "victory": [0.46, 523.25, 0.03],
    "draw": [0.36, 220.0, 0.04],
    "ultimate_release": [0.30, 165.0, 0.26]
}

static func get_stream(kind: String) -> AudioStreamWAV:
    if not CUES.has(kind):
        return null
    if _streams.has(kind):
        return _streams[kind]
    var parameters: Array = CUES[kind]
    var duration: float = parameters[0]
    var frequency: float = parameters[1]
    var noise_mix: float = parameters[2]
    var count := int(duration * RATE)
    var pcm := PackedByteArray()
    pcm.resize(count * 2)
    var rng := RandomNumberGenerator.new()
    rng.seed = kind.hash()
    var phase := 0.0
    var filtered_noise := 0.0
    for index in range(count):
        var time := float(index) / RATE
        var progress := float(index) / count
        var rise := minf(time / 0.006, 1.0)
        var envelope := rise * pow(1.0 - progress, 2.5)
        var sweep := 1.0 - 0.4 * progress
        if kind in ["momentum_charge", "ultimate_reserve", "victory"]:
            sweep = 1.0 + 0.6 * progress
        elif kind == "draw":
            sweep = 1.0
        phase += TAU * frequency * sweep / RATE
        filtered_noise = lerpf(filtered_noise, rng.randf_range(-1.0, 1.0), 0.60)
        var tone := sin(phase) * 0.6 + sin(phase * 2.71) * 0.25 + sin(phase * 4.13) * 0.15
        var value := clampf(lerpf(tone, filtered_noise, noise_mix) * envelope * 0.65, -1.0, 1.0)
        pcm.encode_s16(index * 2, int(value * 32767.0))
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = RATE
    stream.data = pcm
    _streams[kind] = stream
    return stream
