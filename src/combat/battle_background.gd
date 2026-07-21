class_name BattleBackground
extends TextureRect

const BACKGROUND_SOURCE_PATH := "res://assets/backgrounds/step3_mountain_fortress.svg"
const JPEG_DATA_PREFIX := "data:image/jpeg;base64,"

func _ready() -> void:
    name = "BattleBackground"
    texture = _load_embedded_jpeg_texture()
    if texture == null:
        push_error("STEP 3 battle background JPEG could not be decoded from: %s" % BACKGROUND_SOURCE_PATH)

    expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    modulate = Color(0.82, 0.80, 0.76, 1.0)
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    set_meta("step", 3)
    set_meta("art_direction", "approved_ink_wash_mountain_fortress")
    set_meta("contrast_role", "below_board_and_characters")
    set_meta("source_mode", "embedded_jpeg_runtime_decode")

func _load_embedded_jpeg_texture() -> Texture2D:
    if not FileAccess.file_exists(BACKGROUND_SOURCE_PATH):
        push_error("STEP 3 battle background source was not found: %s" % BACKGROUND_SOURCE_PATH)
        return null

    var file := FileAccess.open(BACKGROUND_SOURCE_PATH, FileAccess.READ)
    if file == null:
        push_error("STEP 3 battle background source could not be opened: %s" % BACKGROUND_SOURCE_PATH)
        return null

    var svg_text := file.get_as_text()
    var data_start := svg_text.find(JPEG_DATA_PREFIX)
    if data_start < 0:
        push_error("Embedded JPEG data prefix was not found in STEP 3 background source.")
        return null

    data_start += JPEG_DATA_PREFIX.length()
    var data_end := svg_text.find("\"", data_start)
    if data_end < 0:
        push_error("Embedded JPEG data terminator was not found in STEP 3 background source.")
        return null

    var encoded_jpeg := svg_text.substr(data_start, data_end - data_start)
    var jpeg_bytes := Marshalls.base64_to_raw(encoded_jpeg)
    if jpeg_bytes.is_empty():
        push_error("Embedded STEP 3 JPEG decoded to an empty byte array.")
        return null

    var image := Image.new()
    var load_error := image.load_jpg_from_buffer(jpeg_bytes)
    if load_error != OK:
        push_error("Embedded STEP 3 JPEG could not be loaded. error=%d" % load_error)
        return null

    return ImageTexture.create_from_image(image)
