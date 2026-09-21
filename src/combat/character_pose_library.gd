extends RefCounted

const PLAYER_PATH := "res://assets/characters/motion/player_sword_sequence_v1.png"
const ENEMY_PATH := "res://assets/characters/motion/enemy_sword_sequence_v1.png"
const DOGYEOM_PATH := "res://assets/characters/dogyeom_combat_battler_01_v1.png"
const PLAYER_REACTIONS := "res://assets/characters/motion/player_reactions_candidate_v2.png"
const ENEMY_REACTIONS := "res://assets/characters/motion/enemy_reactions_candidate_v2.png"
const CHROMA := preload("res://src/combat/character_chroma.gdshader")
static var _source_frames: Dictionary = {}
static var _prepared_roles: Dictionary = {}

static func prepare_combat_frames(role: String) -> void:
    if _prepared_roles.has(role):
        return
    var path := PLAYER_PATH if role == "player" else ENEMY_PATH
    var reaction_path := PLAYER_REACTIONS if role == "player" else ENEMY_REACTIONS
    for index in range(7 if role == "player" else 8):
        frame(path, index)
    for index in range(4):
        frame(reaction_path, index)
    _prepared_roles[role] = true

static func battler_path(role: String, candidate_id: String = "") -> String:
    if role == "player":
        return PLAYER_PATH
    return DOGYEOM_PATH if candidate_id == "slot1_dogyeom" else ENEMY_PATH

static func frame(path: String, index: int = 0) -> AtlasTexture:
    var cache_key := "%s:%d" % [path, index]
    if _source_frames.has(cache_key):
        return _source_frames[cache_key]
    var sheet := load(path) as Texture2D
    if sheet == null:
        return null
    var reactions := path in [PLAYER_REACTIONS, ENEMY_REACTIONS]
    var columns := 2 if reactions else (3 if path == PLAYER_PATH else 4)
    var rows := 2 if reactions else 3
    var cell := Vector2(sheet.get_width() / columns, sheet.get_height() / rows)
    var safe_index := clampi(index, 0, columns * rows - 1)
    var result := AtlasTexture.new()
    result.atlas = sheet
    result.region = Rect2(Vector2(safe_index % columns, safe_index / columns) * cell, cell)
    result.filter_clip = true
    # Read the keyed source; do not rewrite its pixels. Cache the foot anchor
    # on the immutable frame so differing green margins cannot float a pose.
    var pixels := result.get_image()
    if pixels != null:
        var minimum := Vector2i(pixels.get_width(), pixels.get_height())
        var maximum := Vector2i(-1, -1)
        for y in range(pixels.get_height()):
            for x in range(pixels.get_width()):
                var color := pixels.get_pixel(x, y)
                # Same key support as the display shader; source pixels remain intact.
                if color.a > 0.01 and color.g - maxf(color.r, color.b) < 0.42:
                    minimum = minimum.min(Vector2i(x, y))
                    maximum = maximum.max(Vector2i(x, y))
        if maximum.x >= minimum.x:
            result.set_meta("visible_used_rect", Rect2(Vector2(minimum), Vector2(maximum - minimum + Vector2i.ONE)))
        for y in range(pixels.get_height() - 1, -1, -1):
            var found := false
            for x in range(pixels.get_width()):
                var color := pixels.get_pixel(x, y)
                if color.a > 0.5 and color.g - maxf(color.r, color.b) < 0.1:
                    result.set_meta("foot_ratio", float(y + 1) / pixels.get_height())
                    found = true
                    break
            if found:
                break
    _source_frames[cache_key] = result
    return result

static func chroma_material() -> ShaderMaterial:
    var result := ShaderMaterial.new()
    result.shader = CHROMA
    return result

static func attack_frame(actor_role: String, progress: float) -> int:
    var sequence := [0, 1, 2, 3, 4, 5, 6, 0] if actor_role == "player" else [0, 1, 2, 3, 4, 5, 6, 7, 0]
    return sequence[mini(int(clampf(progress, 0.0, 1.0) * sequence.size()), sequence.size() - 1)]
