class_name BattleBackground
extends TextureRect

const BACKGROUND_SOURCE_PATH := "res://assets/backgrounds/step3_mountain_fortress.svg"
const JPEG_DATA_PREFIX := "data:image/jpeg;base64,"
const BASE64_ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

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
    set_meta("source_mode", "embedded_jpeg_relaxed_base64_decode")

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
    var jpeg_bytes := _decode_base64_relaxed(encoded_jpeg)
    if jpeg_bytes.size() < 3:
        push_error("Embedded STEP 3 JPEG decoded to an empty or invalid byte array.")
        return null
    if jpeg_bytes[0] != 0xFF or jpeg_bytes[1] != 0xD8 or jpeg_bytes[2] != 0xFF:
        push_error("Embedded STEP 3 JPEG does not start with a valid JPEG signature.")
        return null

    var image := Image.new()
    var load_error := image.load_jpg_from_buffer(jpeg_bytes)
    if load_error != OK:
        push_error("Embedded STEP 3 JPEG could not be loaded. error=%d bytes=%d" % [load_error, jpeg_bytes.size()])
        return null

    set_meta("decoded_byte_count", jpeg_bytes.size())
    set_meta("texture_width", image.get_width())
    set_meta("texture_height", image.get_height())
    return ImageTexture.create_from_image(image)

func _decode_base64_relaxed(encoded: String) -> PackedByteArray:
    var output := PackedByteArray()
    var bit_buffer: int = 0
    var bit_count: int = 0

    for index in range(encoded.length()):
        var code := encoded.unicode_at(index)
        if code == 61:
            break

        var value := _base64_value(code)
        if value < 0:
            continue

        bit_buffer = (bit_buffer << 6) | value
        bit_count += 6

        while bit_count >= 8:
            bit_count -= 8
            output.append((bit_buffer >> bit_count) & 0xFF)
            if bit_count > 0:
                bit_buffer &= (1 << bit_count) - 1
            else:
                bit_buffer = 0

    return output

func _base64_value(code: int) -> int:
    if code >= 65 and code <= 90:
        return code - 65
    if code >= 97 and code <= 122:
        return code - 97 + 26
    if code >= 48 and code <= 57:
        return code - 48 + 52
    if code == 43 or code == 45:
        return 62
    if code == 47 or code == 95:
        return 63
    return -1
