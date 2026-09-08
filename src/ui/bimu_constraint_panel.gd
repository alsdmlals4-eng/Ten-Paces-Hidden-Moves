extends VBoxContainer

signal selection_changed(receipt: Dictionary)

const Model := preload("res://src/run/bimu_constraint_model.gd")
const STAT_LABELS := {"external": "외공", "constitution": "체질", "agility": "민첩", "internal_power": "내공", "insight": "통찰"}
var option_buttons: Dictionary = {}
var target_selectors: Dictionary = {}
var options_scroll: ScrollContainer
var summary_label: Label
var reason_label: Label
var _run_state: VerticalSliceRunState
var _manual_registry: MartialManualRegistry
var _options: Array = Model.new().get_options()
var _policy: Dictionary = Model.new().get_selection_policy()

func configure(run_state: VerticalSliceRunState, registry: MartialManualRegistry) -> void:
    _run_state = run_state
    _manual_registry = registry
    for child in get_children():
        remove_child(child)
        child.queue_free()
    option_buttons.clear()
    target_selectors.clear()
    add_theme_constant_override("separation", 8)
    var heading := Label.new()
    heading.text = "이번 비무의 제약 · 선택 사항"
    heading.add_theme_font_size_override("font_size", 20)
    add_child(heading)
    options_scroll = ScrollContainer.new()
    options_scroll.name = "ConstraintOptionsScroll"
    options_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    options_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    options_scroll.follow_focus = true
    add_child(options_scroll)
    var rows := VBoxContainer.new()
    rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    rows.add_theme_constant_override("separation", 12)
    options_scroll.add_child(rows)
    for option in _options:
        var id := str(option["constraint_id"])
        var row := VBoxContainer.new()
        row.name = id
        rows.add_child(row)
        var button := CheckBox.new()
        button.name = "SelectConstraint"
        button.text = "%s · %d점" % [option["display_name_ko"], option["selection_cost"]]
        button.accessibility_name = button.text
        button.custom_minimum_size.y = 38
        button.toggled.connect(func(_enabled: bool): toggle_constraint(id))
        row.add_child(button)
        option_buttons[id] = button
        var effect := Label.new()
        effect.text = str(option["effect_summary_ko"])
        effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        effect.add_theme_font_size_override("font_size", 15)
        effect.add_theme_color_override("font_color", Color("c9bca8"))
        row.add_child(effect)
        var binding: Dictionary = option.get("parameter_binding", {})
        if not binding.is_empty():
            var target := OptionButton.new()
            target.name = "ConstraintTarget"
            target.custom_minimum_size.y = 36
            target.accessibility_name = str(option["display_name_ko"]) + " 대상"
            var field := str(binding.get("field", ""))
            var values: Array = binding.get("allowed_values", [])
            if field == "target_manual_id":
                values = _run_state.get_player_manual_loadout()
            elif field == "target_enemy_manual_id":
                values = [_run_state.get_current_opponent().get("signature_manual_id", "")]
            for value in values:
                var label := str(STAT_LABELS.get(str(value), ""))
                if label.is_empty():
                    label = str(_manual_registry.get_manual(str(value)).get("manual_name", value))
                target.add_item(label)
                target.set_item_metadata(target.item_count - 1, str(value))
            row.add_child(target)
            target_selectors[id] = target
            target.item_selected.connect(_on_target_changed.bind(id))
    summary_label = Label.new()
    summary_label.name = "ConstraintSelectionSummary"
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary_label.add_theme_font_size_override("font_size", 15)
    add_child(summary_label)
    reason_label = Label.new()
    reason_label.name = "ConstraintSelectionReason"
    reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    reason_label.add_theme_font_size_override("font_size", 15)
    reason_label.add_theme_color_override("font_color", Color("f1c788"))
    add_child(reason_label)
    _refresh()

func toggle_constraint(id: String) -> bool:
    var proposed := _run_state.get_pending_bimu_constraints()
    var found := -1
    for index in proposed.size():
        if str(proposed[index].get("constraint_id", "")) == id:
            found = index
    if found >= 0:
        proposed.remove_at(found)
    else:
        proposed.append(_selection_item(id))
    return _submit(proposed)

func _selection_item(id: String) -> Dictionary:
    var item := {"constraint_id": id}
    for option in _options:
        if str(option["constraint_id"]) != id:
            continue
        var field := str((option.get("parameter_binding", {}) as Dictionary).get("field", ""))
        if not field.is_empty() and target_selectors.has(id):
            var target: OptionButton = target_selectors[id]
            if target.selected >= 0:
                item[field] = str(target.get_item_metadata(target.selected))
    return item

func _on_target_changed(_index: int, id: String) -> void:
    var proposed := _run_state.get_pending_bimu_constraints()
    for index in proposed.size():
        if str(proposed[index].get("constraint_id", "")) == id:
            proposed[index] = _selection_item(id)
            _submit(proposed)
            return

func _submit(proposed: Array) -> bool:
    var receipt := _run_state.validate_bimu_constraints(proposed)
    if not receipt.get("valid", false):
        _refresh(" ".join(receipt.get("errors", [])))
        return false
    if not _run_state.select_bimu_constraints(proposed):
        _refresh("비무가 시작되어 제약을 바꿀 수 없습니다.")
        return false
    _refresh()
    return true

func _refresh(reason: String = "") -> void:
    var selected := _run_state.get_pending_bimu_constraints()
    var receipt := _run_state.validate_bimu_constraints(selected)
    for button in option_buttons.values():
        button.set_pressed_no_signal(false)
    var effects := PackedStringArray()
    for item in selected:
        var id := str(item["constraint_id"])
        if not option_buttons.has(id):
            continue
        option_buttons[id].set_pressed_no_signal(true)
        for option in _options:
            if str(option["constraint_id"]) != id:
                continue
            var effect := str(option["briefing_disclosure"])
            if target_selectors.has(id):
                var target: OptionButton = target_selectors[id]
                var field := str(option["parameter_binding"]["field"])
                for index in target.item_count:
                    if str(target.get_item_metadata(index)) == str(item.get(field, "")):
                        target.select(index)
                effect += " · " + target.get_item_text(target.selected)
            effects.append(effect)
    var counter := str(_policy.get("selection_counter_format_ko", "선택 {selected} · 제약 점수 {spent}")).format({"selected": selected.size(), "max_selected": _policy.get("max_selected_constraints", "?"), "spent": int(receipt.get("selection_point_spent", 0)), "point_budget": _policy.get("selection_point_budget", "?")})
    summary_label.text = "%s\n%s" % [counter, "제약 없이 시작할 수 있습니다." if effects.is_empty() else "\n".join(effects)]
    reason_label.text = reason
    reason_label.visible = not reason.is_empty()
    selection_changed.emit(receipt)
