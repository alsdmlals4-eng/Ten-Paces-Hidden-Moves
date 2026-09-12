class_name CombatSoundBank
extends RefCounted

# Original deterministic synthesis; no third-party recordings or runtime allocation
# after a cue has first been requested. Volume belongs to the player, not PCM data.
static var _streams: Dictionary = {}
const RATE := 22050
const CUES := {
    "metal_clash": [0.46, 1450.0, 0.32],
    "sword_wind": [0.24, 680.0, 0.82],
    "heavy_hit": [0.25, 92.0, 0.52],
    "block": [0.24, 820.0, 0.28],
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
    var slow_noise := 0.0
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
        var white := rng.randf_range(-1.0, 1.0)
        filtered_noise = lerpf(filtered_noise, white, 0.60)
        slow_noise = lerpf(slow_noise, white, 0.08)
        var tone := sin(phase) * 0.6 + sin(phase * 2.71) * 0.25 + sin(phase * 4.13) * 0.15
        var shaped := lerpf(tone, filtered_noise, noise_mix) * envelope * 0.65
        match kind:
            "metal_clash", "block":
                # Unequal, independently damped partials: impact first, steel ring after.
                var ring := sin(TAU*frequency*time) * exp(-time*11.0)*0.30
                ring += sin(TAU*frequency*1.47*time) * exp(-time*16.0)*0.22
                ring += sin(TAU*frequency*2.09*time) * exp(-time*23.0)*0.13
                ring += sin(TAU*frequency*2.73*time) * exp(-time*34.0)*0.08
                var strike := (white-slow_noise)*exp(-time*105.0)*0.34
                var body := sin(TAU*185.0*time)*exp(-time*48.0)*0.16
                shaped = (ring+strike+body)*minf(time/0.002,1.0)
                if kind == "block":
                    shaped *= exp(-time*9.0)*0.83
            "sword_wind", "evade":
                # Air rises toward the pass and falls away; no pitched electronic chirp.
                var gust := pow(sin(PI*progress), 1.8)
                shaped = (filtered_noise-slow_noise)*gust*0.95
                if kind == "sword_wind":
                    shaped += sin(phase*2.09)*gust*exp(-progress*5.0)*0.05
            "heavy_hit", "interrupt":
                var thud := sin(TAU*(frequency*time-45.0*time*time))*exp(-time*22.0)*0.55
                var contact := filtered_noise*exp(-time*65.0)*0.38
                shaped = (thud+contact)*minf(time/0.003,1.0)
            "ultimate_release":
                var rush := (filtered_noise-slow_noise)*pow(sin(PI*progress),1.2)*0.70
                shaped = (rush+sin(phase*0.5)*envelope*0.32)*rise
        # Short terminal fade and headroom remain independent of player volume.
        shaped *= minf((1.0-progress)/0.05,1.0)
        var value := clampf(shaped, -0.75, 0.75)
        pcm.encode_s16(index * 2, int(value * 32767.0))
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = RATE
    stream.data = pcm
    _streams[kind] = stream
    return stream
