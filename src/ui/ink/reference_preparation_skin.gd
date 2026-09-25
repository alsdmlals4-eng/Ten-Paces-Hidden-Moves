extends RefCounted
## Text-free textures; native Controls own all values and input.
const SIZE := Vector2(1086, 1448)
const PAINTING := preload("res://assets/ui/ink_preparation/reference_painting.png")
const DETAILS := preload("res://assets/ui/ink_preparation/reference_details.png")
const CHARACTERS := preload("res://assets/ui/ink_preparation/standing_characters.png")
const INK := Color("25251f")

static func region(texture: Texture2D, rect: Rect2) -> AtlasTexture:
    var value := AtlasTexture.new()
    value.atlas = texture
    value.region = rect
    value.filter_clip = true
    return value

static func paper(rect := Rect2(44, 893, 144, 211)) -> StyleBoxTexture:
    var value := StyleBoxTexture.new()
    value.texture = region(PAINTING, rect)
    for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
        value.set_texture_margin(side, 5)
        value.set_content_margin(side, 5)
    return value

static func clear_style(margin := 0.0) -> StyleBoxEmpty:
    var value := StyleBoxEmpty.new()
    value.set_content_margin_all(margin)
    return value

static func emphasis(color := Color("b79a59")) -> StyleBoxFlat:
    var value := StyleBoxFlat.new()
    value.bg_color = Color(color, 0.08)
    value.border_color = color
    value.set_border_width_all(2)
    return value

static func character(side: String, candidate_id := "", portrait := false) -> Texture2D:
    if side == "player":
        return region(CHARACTERS, Rect2(104,161,331,427) if portrait else Rect2(0,166,586,814))
    if candidate_id == "slot1_dogyeom":
        return region(CHARACTERS, Rect2(1121,170,411,419) if portrait else Rect2(1085,167,451,813))
    return region(CHARACTERS, Rect2(624,162,388,428) if portrait else Rect2(526,169,559,811))

static func portrait_material() -> ShaderMaterial:
    var shader := Shader.new()
    shader.code = "shader_type canvas_item; void fragment(){ vec4 p=texture(TEXTURE,UV); p.a*=1.0-smoothstep(0.29,0.54,UV.y); COLOR=p; }"
    var material := ShaderMaterial.new()
    material.shader = shader
    return material

static func fit_rect(viewport: Vector2) -> Rect2:
    var factor := minf(viewport.x / SIZE.x, viewport.y / SIZE.y)
    var fitted := SIZE * factor
    return Rect2((viewport - fitted) * 0.5, fitted)

static func place(control: Control, rect: Rect2, fitted: Rect2) -> void:
    var factor := fitted.size.x / SIZE.x
    control.set_anchors_preset(Control.PRESET_TOP_LEFT)
    control.position = fitted.position + rect.position * factor
    control.size = rect.size
    control.scale = Vector2.ONE * factor
    control.z_index = 12

static func label(parent: Node, key: String, value: String, rect: Rect2, font_size: int, color := INK) -> Label:
    var item := parent.get_node_or_null(key) as Label
    if item == null:
        item = Label.new()
        item.name = key
        item.mouse_filter = Control.MOUSE_FILTER_IGNORE
        parent.add_child(item)
    item.text = value
    item.position = rect.position
    item.size = rect.size
    item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    item.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    item.add_theme_font_size_override("font_size", font_size)
    item.add_theme_color_override("font_color", color)
    item.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
    return item

static func standing_material(side: String, candidate_id := "") -> ShaderMaterial:
    var material := ShaderMaterial.new()
    var shader := Shader.new()
    if side == "player":
        shader.code = "shader_type canvas_item; void fragment(){ vec2 p=UV*vec2(1536.0,1024.0); if(p.x>516.0 && p.y<1.5*p.x-55.0){discard;} COLOR=texture(TEXTURE,UV); }"
    elif candidate_id != "slot1_dogyeom":
        shader.code = "shader_type canvas_item; void fragment(){ vec2 p=UV*vec2(1536.0,1024.0); if(p.x<589.0 && p.y>1.5*p.x-55.0){discard;} COLOR=texture(TEXTURE,UV); }"
    else:
        shader.code = "shader_type canvas_item; void fragment(){ COLOR=texture(TEXTURE,UV); }"
    material.shader = shader
    return material

static func basic_art(name_text: String) -> Texture2D:
    var index := ["이동","보법","막기","회피","속공","강공","관찰","명상","준비","장풍"].find(name_text)
    if index < 0:
        return null
    var x := 47 + (index % 5)*150
    return region(DETAILS,Rect2(x,946 if index < 5 else 1175,140,97 if index < 5 else 110))
