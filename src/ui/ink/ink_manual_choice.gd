extends Button
## A real toggle button owns selection; its illustration never intercepts input.

func configure(option: Dictionary) -> void:
    toggle_mode = true
    custom_minimum_size = Vector2(180, 184)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var title := str(option.get("manual_name", ""))
    var technique := str(option.get("star3_card_name", ""))
    accessibility_name = "%s · %s · 3성 %s · %s / %s" % [option.get("faction", ""), title, technique, option.get("primary_stat", ""), option.get("secondary_stat", "")]
    tooltip_text = accessibility_name
    var box := VBoxContainer.new()
    box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    box.offset_left = 9
    box.offset_right = -9
    box.offset_top = 9
    box.offset_bottom = -9
    box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.add_theme_constant_override("separation", 3)
    add_child(box)
    var art := TextureRect.new()
    art.name = "ManualIllustration"
    art.texture = preload("res://src/ui/approved_blueprint_art.gd").manual_illustration(str(option.manual_id), 3)
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    art.custom_minimum_size.y = 102
    art.size_flags_vertical = Control.SIZE_EXPAND_FILL
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.add_child(art)
    for line in [title, "3성 · " + technique, "%s / %s" % [option.get("primary_stat", ""), option.get("secondary_stat", "")]]:
        var label := Label.new()
        label.text = line
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.add_theme_font_size_override("font_size", 19 if line == title else 14)
        label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        box.add_child(label)
    var seal := Label.new()
    seal.name = "SelectedSeal"
    seal.text = "택"
    seal.position = Vector2(12, 10)
    seal.add_theme_font_size_override("font_size", 24)
    seal.add_theme_color_override("font_color", Color("9f4838"))
    seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
    seal.visible = false
    add_child(seal)
    # set_pressed_no_signal is also used by the loadout controller.
    draw.connect(func():
        seal.visible = button_pressed
        for child in box.get_children():
            if child is Label:
                child.add_theme_color_override("font_color", Color("eee5d2") if button_pressed else Color("272920")))
