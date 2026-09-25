class_name ActionChoiceCard
extends Button

const APPROVED_ART := preload("res://src/ui/approved_blueprint_art.gd")

const PAPER_SURFACE := Color("d9ccb1")
const PAPER_HOVER := Color("eee2c9")
const CHARCOAL_INK := Color("211c17")
const RESTRAINED_GOLD := Color("b99254")
const RESOLUTION_ENGINE_SCRIPT := preload("res://src/combat/combat_resolution_engine.gd")
const CARD_CONTENT_TOP := 79.0
const CARD_BOTTOM_PADDING := 4.0
const CROSS_PLATFORM_CARD_HEIGHT := 136.0

var action_definition: Dictionary = {}
var reference_layout := false
var _reference_styling := false

func _ready() -> void:
    var ancestor := get_parent()
    while ancestor != null:
        if ancestor.has_method("layout_preparation") and bool(ancestor.get("preparation_layout")):
            enable_reference_layout()
            break
        ancestor = ancestor.get_parent()


func configure_action(definition: Dictionary, illustration_policy: String, status_text: String = "", preview_actor: Dictionary = {}) -> void:
    action_definition = definition.duplicate(true)
    for child in get_children():
        child.queue_free()
    custom_minimum_size = Vector2(0.0, CROSS_PLATFORM_CARD_HEIGHT)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    focus_mode = Control.FOCUS_ALL
    text = ""
    tooltip_text = _tooltip_text(status_text)
    accessibility_name = _accessibility_name(status_text)
    accessibility_description = _accessibility_description(status_text)
    _apply_paper_style(_category(), bool(action_definition.get("locked", false)))
    set_meta("card_surface", "shared_action_card_grid")
    set_meta("illustration_policy", illustration_policy)
    set_meta("action_id", str(action_definition.get("id", "")))
    set_meta("locked", bool(action_definition.get("locked", false)))
    set_meta("keyboard_focus_ring", true)
    var has_illustration := illustration_policy in ["basic_atlas_only", "semantic_atlas"] and (not APPROVED_ART.action_illustration_path(action_definition).is_empty() or _has_illustration_spec())
    if has_illustration:
        _add_illustration()
    _add_name_label()
    _add_summary(preview_actor)
    if not resized.is_connected(_layout_summary): resized.connect(_layout_summary)
    if not theme_changed.is_connected(_layout_summary): theme_changed.connect(_layout_summary)
    call_deferred("_layout_summary")

func _add_illustration() -> void:
    var illustration := TextureRect.new()
    illustration.name = "CardIllustration"
    var approved_texture := APPROVED_ART.action_illustration(action_definition)
    illustration.texture = approved_texture if approved_texture != null else _texture_from_spec(action_definition.get("illustration", {}))
    illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
    illustration.modulate = Color.WHITE
    illustration.anchor_right = 1.0
    illustration.anchor_bottom = 1.0
    illustration.offset_left = 7.0
    illustration.offset_top = 27.0
    illustration.offset_right = -7.0
    illustration.offset_bottom = -37.0
    add_child(illustration)

func _add_name_label() -> void:
    var label := Label.new()
    label.name = "CardName"
    label.text = "%s  %d수" % [str(action_definition.get("name", "")), int(action_definition.get("action_slots", 1))]
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.clip_text = true
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", CHARCOAL_INK)
    label.set_anchors_preset(Control.PRESET_TOP_WIDE)
    label.anchor_left = 0.0
    label.offset_left = 2.0
    label.offset_right = -5.0
    label.offset_top = 3.0
    label.offset_bottom = 26.0
    add_child(label)

func _add_summary(preview_actor: Dictionary) -> void:
    var summary := VBoxContainer.new()
    summary.name = "CardSummary"
    summary.mouse_filter = Control.MOUSE_FILTER_IGNORE
    summary.add_theme_constant_override("separation", 0)
    summary.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    summary.anchor_left = 0.0
    summary.offset_left = 2.0
    summary.offset_right = -4.0
    summary.offset_top = -35.0
    summary.offset_bottom = -CARD_BOTTOM_PADDING
    add_child(summary)
    var momentum_text := " · 기세 %d" % int(action_definition.get("momentum_cost", 0)) if int(action_definition.get("momentum_cost", 0)) > 0 else ""
    _add_summary_line(summary, "%d수 · 기력 %d · 내력 %d%s" % [int(action_definition.get("action_slots", 1)), int(action_definition.get("stamina_cost", 0)), int(action_definition.get("internal_cost", 0)), momentum_text])
    var range_line := "거리 %s" % str(action_definition.get("range_text", "-"))
    var movement := maxi(0, int(action_definition.get("move_range", 0)))
    if bool(action_definition.get("dash_before_attack", false)):
        movement = maxi(movement, 1)
    if movement > 0:
        range_line += " · 이동 %d칸" % movement
    _add_summary_line(summary, range_line)
    # Full effect belongs in the adjacent detail, leaving room for the illustration.
    set_meta("primary_effect", _primary_summary(preview_actor))
    tooltip_text += "\n" + _primary_summary(preview_actor)
    _fit_card_to_summary(summary)

func _fit_card_to_summary(summary: VBoxContainer) -> void:
    # Linux and Windows can resolve the Korean fallback font to different line
    # heights. Size from the actual native labels, with a small cross-platform
    # floor, so the cost/range lines do not rely on one platform's metrics.
    var required_height := ceilf(CARD_CONTENT_TOP + summary.get_combined_minimum_size().y + CARD_BOTTOM_PADDING)
    custom_minimum_size.y = maxf(CROSS_PLATFORM_CARD_HEIGHT, required_height)
    summary.offset_bottom = -CARD_BOTTOM_PADDING

func _add_summary_line(parent: VBoxContainer, value: String) -> void:
    var label := Label.new()
    label.text = value
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.clip_text = true
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", 13)
    label.add_theme_color_override("font_color", Color("4d4032"))
    parent.add_child(label)

func _primary_summary(preview_actor: Dictionary) -> String:
    if not str(action_definition.get("constraint_lock_reason", "")).is_empty():
        return str(action_definition.get("constraint_lock_reason"))
    var preview: Dictionary = _resolution_engine().preview_action_magnitude(action_definition, preview_actor)
    if bool(preview.get("available", false)):
        if _category() == "attack":
            return "예상 위력 %d" % int(preview.get("value", 0))
        return str(preview.get("label", ""))
    if _category() == "attack":
        if not str(preview.get("label", "")).is_empty():
            return str(preview.get("label", ""))
        return _formula_baseline_text()
    return "효과 조건부 · 상세 확인"

func _resolution_engine() -> RefCounted:
    return RESOLUTION_ENGINE_SCRIPT.shared_preview_engine()

func _formula_baseline_text() -> String:
    var formula: Dictionary = action_definition.get("damage_formula", {}) as Dictionary
    if not formula.is_empty():
        var stat_label := str({"external": "외공", "internal_power": "내공"}.get(str(formula.get("stat_key", "")), "능력"))
        return "위력식 기본%d+%s×%.2f" % [int(formula.get("base", 0)), stat_label, float(formula.get("coefficient", 0.0))]
    return "위력식 %s" % str(action_definition.get("damage", "조건부"))

func _detail_summary() -> String:
    var detail: Dictionary = action_definition.get("detail", {}) as Dictionary
    var effect_text := str(detail.get("effect_text", action_definition.get("effect_text", "")))
    if not effect_text.is_empty():
        return effect_text
    var tags: Array = action_definition.get("tags", []) as Array
    if typeof(tags) == TYPE_ARRAY and not tags.is_empty():
        return str(tags[0])
    return "상세 효과는 우측 패널에서 확인"

func _tooltip_text(status_text: String) -> String:
    var state: String = status_text if not status_text.is_empty() else (str(action_definition.get("lock_reason", "")) if bool(action_definition.get("locked", false)) else "사용 가능")
    return "%s · %s · %d수 · %s" % [
        str(action_definition.get("name", "")),
        str(action_definition.get("source_label", "행동")),
        int(action_definition.get("action_slots", 1)),
        state
    ]

func _accessibility_name(status_text: String) -> String:
    var state: String = status_text if not status_text.is_empty() else (str(action_definition.get("lock_reason", "")) if bool(action_definition.get("locked", false)) else "사용 가능")
    var parts := PackedStringArray([
        str(action_definition.get("name", "")),
        str(action_definition.get("source_label", "행동")),
        _category_label(),
        "%d수" % int(action_definition.get("action_slots", 1)),
        "기력 %d" % int(action_definition.get("stamina_cost", 0)),
        "내력 %d" % int(action_definition.get("internal_cost", 0))
    ])
    parts.append("사거리 %s" % str(action_definition.get("range_text", "-")))
    var momentum := int(action_definition.get("momentum_cost", 0))
    if momentum > 0:
        parts.append("기세 %d" % momentum)
    parts.append(state)
    return ", ".join(parts)

func _accessibility_description(status_text: String) -> String:
    var state: String = status_text if not status_text.is_empty() else (str(action_definition.get("lock_reason", "")) if bool(action_definition.get("locked", false)) else "선택하면 현재 묶음에 자동 배치")
    return "%s. %s." % [_detail_summary(), state]

func _category_label() -> String:
    var explicit_label := str(action_definition.get("category_label", "")).strip_edges()
    if not explicit_label.is_empty():
        return explicit_label
    match _category():
        "move":
            return "이동"
        "attack":
            return "공격"
        "response":
            return "대응"
        "observation":
            return "관찰"
        "recovery":
            return "회복"
        "strengthen":
            return "강화"
        _:
            return "행동"

func _texture_from_spec(spec: Dictionary) -> Texture2D:
    var path := str(spec.get("atlas", ""))
    var region: Array = spec.get("region", [])
    if path.is_empty() or region.size() != 4 or not ResourceLoader.exists(path):
        return null
    var texture := AtlasTexture.new()
    texture.atlas = load(path) as Texture2D
    texture.region = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
    return texture

func _has_illustration_spec() -> bool:
    var illustration: Dictionary = action_definition.get("illustration", {}) as Dictionary
    var atlas_path := str(illustration.get("atlas", ""))
    var region: Array = illustration.get("region", []) as Array
    return not atlas_path.is_empty() and region.size() == 4 and ResourceLoader.exists(atlas_path)

func _apply_paper_style(category: String, locked: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = PAPER_SURFACE if not locked else Color("777064")
    normal.border_color = Color("746b59") if not locked else Color("5d5448")
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(0)
    normal.content_margin_left = 8.0
    normal.content_margin_right = 8.0
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = PAPER_HOVER
    hover.border_color = RESTRAINED_GOLD
    hover.set_border_width_all(3)
    var pressed := normal.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("c8b68f")
    pressed.border_color = CHARCOAL_INK
    var disabled := normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color("777064")
    disabled.border_color = Color("5d5448")
    var focus := StyleBoxFlat.new()
    focus.bg_color = Color(1.0, 1.0, 1.0, 0.08)
    focus.border_color = Color.WHITE
    focus.set_border_width_all(2)
    focus.set_corner_radius_all(3)
    add_theme_stylebox_override("normal", normal)
    add_theme_stylebox_override("hover", hover)
    add_theme_stylebox_override("pressed", pressed)
    add_theme_stylebox_override("disabled", disabled)
    add_theme_stylebox_override("focus", focus)
    add_theme_color_override("font_color", CHARCOAL_INK)
    add_theme_color_override("font_hover_color", CHARCOAL_INK)
    add_theme_color_override("font_pressed_color", CHARCOAL_INK)
    add_theme_color_override("font_disabled_color", Color("d2c6ab"))

func _category() -> String:
    return str(action_definition.get("category", ""))

func _category_accent(category: String) -> Color:
    match category:
        "move":
            return Color("3f7f5b")
        "attack":
            return Color("9a443d")
        "response":
            return Color("3f668d")
        "recovery":
            return Color("a37a32")
        "strengthen":
            return Color("705184")
        _:
            return RESTRAINED_GOLD

func _layout_summary() -> void:
    if reference_layout:
        _layout_reference_card()
        return
    var summary := get_node_or_null("CardSummary") as VBoxContainer
    var art := get_node_or_null("CardIllustration") as TextureRect
    var title := get_node_or_null("CardName") as Label
    if summary == null:
        return
    var height := ceilf(summary.get_combined_minimum_size().y) + CARD_BOTTOM_PADDING
    summary.offset_top = -height
    summary.offset_bottom = -CARD_BOTTOM_PADDING
    if art != null:
        art.offset_top = maxf(28, title.get_combined_minimum_size().y + 6)
        art.offset_bottom = -height - 3

func enable_reference_layout() -> void:
    if reference_layout:
        return
    reference_layout = true
    var skin = preload("res://src/ui/ink/reference_preparation_skin.gd")
    add_theme_stylebox_override("normal",skin.paper())
    add_theme_stylebox_override("disabled",skin.paper())
    add_theme_stylebox_override("hover",skin.paper())
    add_theme_stylebox_override("pressed",skin.paper())
    add_theme_stylebox_override("focus",skin.emphasis(Color("926e2f")))
    custom_minimum_size.y = 220
    _layout_reference_card()

func _layout_reference_card() -> void:
    if _reference_styling:
        return
    _reference_styling = true
    var title := get_node_or_null("CardName") as Label
    var art := get_node_or_null("CardIllustration") as TextureRect
    var summary := get_node_or_null("CardSummary") as VBoxContainer
    if title != null:
        var name_text := str(action_definition.get("name",""))
        var number := ["이동","보법","막기","회피","속공","강공","관찰","명상","준비","장풍"].find(name_text) + 1
        title.text = ("%d " % number if number > 0 else "") + name_text
        title.offset_left = 8
        title.offset_right = -29
        title.offset_top = 8
        title.offset_bottom = 36
        title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        title.add_theme_font_size_override("font_size",24 if name_text.length() < 4 else 19)
        var cost := get_node_or_null("ReferenceSlots") as Label
        if cost == null:
            cost = Label.new()
            cost.name = "ReferenceSlots"
            cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
            add_child(cost)
        cost.text = "%d수" % int(action_definition.get("action_slots",1))
        cost.set_anchors_preset(Control.PRESET_TOP_RIGHT)
        cost.offset_left = -37
        cost.offset_right = -8
        cost.offset_top = 8
        cost.offset_bottom = 36
        cost.add_theme_font_size_override("font_size",18)
        cost.add_theme_color_override("font_color",CHARCOAL_INK)
    if art != null:
        var reference_art = preload("res://src/ui/ink/reference_preparation_skin.gd").basic_art(str(action_definition.get("name","")))
        if reference_art != null:
            art.texture = reference_art
        art.offset_left = 9
        art.offset_right = -9
        art.offset_top = 43
        art.offset_bottom = -55
    if summary != null and summary.get_child_count() >= 2:
        var cost_line := summary.get_child(0) as Label
        cost_line.text = "기력 %d · 내력 %d" % [int(action_definition.get("stamina_cost",0)),int(action_definition.get("internal_cost",0))]
        for line in summary.get_children():
            line.add_theme_font_size_override("font_size",17)
            line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        summary.offset_left = 8
        summary.offset_right = -6
        summary.offset_top = -51
        summary.offset_bottom = -8
    _reference_styling = false
