extends Control
## Local draft only. The shell owns the domain command and durable transaction.
signal close_requested
signal apply_requested(allocations: Dictionary, expected_revision: int)

var panel: PanelContainer
var scroll: ScrollContainer
var list: VBoxContainer
var pool_label: Label
var status_label: Label
var apply_button: Button
var cancel_button: Button
var reset_button: Button
var manual_rows: Dictionary = {}
var allocations: Dictionary = {}
var expected_revision := 0
var model
var registry
var available := true

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    var shade := ColorRect.new()
    shade.color = Color(0.015,0.02,0.025,0.88)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(shade)
    panel = PanelContainer.new()
    panel.add_theme_stylebox_override("panel", WuxiaUiStyle.paper_surface())
    add_child(panel)
    var margin := MarginContainer.new()
    for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_" + side,16)
    panel.add_child(margin)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation",8)
    margin.add_child(stack)
    var heading := _label("무공 수련")
    WuxiaUiStyle.ink_heading(heading,24)
    stack.add_child(heading)
    pool_label = _label("")
    stack.add_child(pool_label)
    status_label = _label("배분을 비교한 뒤 적용하세요. 닫으면 배분을 취소합니다.")
    stack.add_child(status_label)
    scroll = ScrollContainer.new()
    scroll.name = "TrainingManualScroll"
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.follow_focus = true
    scroll.custom_minimum_size.y = 100
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stack.add_child(scroll)
    list = VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation",12)
    scroll.add_child(list)
    var actions := HBoxContainer.new()
    stack.add_child(actions)
    reset_button = _button("배분 초기화", "TrainingReset")
    cancel_button = _button("취소 · Esc", "TrainingCancel")
    apply_button = _button("수련 적용", "TrainingApply")
    for button in [reset_button,cancel_button,apply_button]: actions.add_child(button)
    reset_button.pressed.connect(func(): allocations.clear(); _refresh())
    cancel_button.pressed.connect(func(): close_requested.emit())
    apply_button.pressed.connect(func():
        if available and not allocations.is_empty(): apply_requested.emit(allocations.duplicate(true),expected_revision))
    resized.connect(_layout_panel)
    _layout_panel()
    hide()

func _label(text: String) -> Label:
    var label := Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    label.add_theme_font_size_override("font_size",17)
    label.add_theme_color_override("font_color",Color("211c17"))
    return label

func _button(text: String, node_name: String) -> Button:
    var button := Button.new()
    button.text = text
    button.name = node_name
    button.custom_minimum_size.y = 44
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return button

func configure(run, manuals) -> void:
    model = run
    registry = manuals
    expected_revision = run.get_training_revision()
    allocations.clear()
    manual_rows.clear()
    for child in list.get_children(): list.remove_child(child); child.queue_free()
    for id in run.get_owned_player_manuals():
        var row := VBoxContainer.new()
        list.add_child(row)
        var title := _label(str(registry.get_manual(id).get("manual_name",id)))
        row.add_child(title)
        var status := _label("")
        row.add_child(status)
        var buttons := HBoxContainer.new()
        row.add_child(buttons)
        var minus := _button("-1", "TrainingMinus_" + id)
        var plus := _button("+1", "TrainingPlus_" + id)
        var next := _button("다음 성까지", "TrainingNext_" + id)
        minus.accessibility_name = title.text + " 수련 배분 1 취소"
        plus.accessibility_name = title.text + " 수련 1 배분"
        next.accessibility_name = title.text + " 다음 성까지 수련 배분"
        for button in [minus,plus,next]: buttons.add_child(button)
        minus.pressed.connect(func(): _adjust(id,-1))
        plus.pressed.connect(func(): _adjust(id,1))
        next.pressed.connect(func(): _adjust(id,int(manual_rows[id].next_amount)))
        manual_rows[id] = {"status":status,"minus":minus,"plus":plus,"next":next,"next_amount":0}
    available = true
    _refresh()
    scroll.scroll_vertical = 0

func set_available(value: bool) -> void:
    if available == value: return
    available = value
    if model != null: _refresh()

func _adjust(id: String, amount: int) -> void:
    if not available: return
    var proposed := allocations.duplicate(true)
    var next := int(proposed.get(id,0)) + amount
    if next < 0: return
    if next == 0: proposed.erase(id)
    else: proposed[id] = next
    if not proposed.is_empty() and not model.preview_training(proposed).get("ok",false): return
    allocations = proposed
    _refresh()

func _refresh() -> void:
    var options: Dictionary = model.get_training_options(allocations)
    if not options.get("ok",false):
        available = false
        status_label.text = "현재는 수련할 수 없습니다. 닫은 뒤 진행 상태를 확인하세요."
    else:
        pool_label.text = "자유 수련 %d → 적용 후 %d" % [options.pool_before,options.pool_after]
        for item in options.manuals:
            var row: Dictionary = manual_rows[item.id]
            row.status.text = "%d성 → %d성 · 배분 %d · 누적 수련 %d · %s" % [item.current_mastery,item.mastery,item.allocated,item.training,"최고 성수" if item.mastery == 10 else "다음 성까지 %d" % item.next_cost]
            row.minus.disabled = not available or item.allocated == 0
            row.plus.disabled = not available or item.remaining_capacity == 0 or options.pool_after == 0
            row.next.disabled = not available or item.next_amount == 0
            row.next_amount = item.next_amount
    apply_button.disabled = not available or allocations.is_empty()
    reset_button.disabled = not available or allocations.is_empty()
    _focus_cycle()

func _focus_cycle() -> void:
    var controls: Array[Control] = []
    for row in manual_rows.values():
        for button in [row.minus,row.plus,row.next]:
            if not button.disabled: controls.append(button)
    for button in [reset_button,cancel_button,apply_button]:
        if not button.disabled: controls.append(button)
    for index in range(controls.size()):
        controls[index].focus_next = controls[index].get_path_to(controls[(index+1)%controls.size()])
        controls[index].focus_previous = controls[index].get_path_to(controls[(index-1+controls.size())%controls.size()])

func focus_first() -> void:
    for row in manual_rows.values():
        if not row.plus.disabled: row.plus.grab_focus(); return
    cancel_button.grab_focus()

func _layout_panel() -> void:
    if panel == null: return
    panel.size = Vector2(minf(760,maxf(320,size.x-32)),minf(640,maxf(320,size.y-32)))
    panel.position = (size-panel.size)*0.5
