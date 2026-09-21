extends VBoxContainer

signal allocation_changed
const GROWTH := preload("res://src/run/player_growth_state.gd")
var growth = GROWTH.new()
var allocation: Dictionary = growth.recommended_allocation([])
var manual_ids: Array = []
var rows := {}
var summary: Label
var recommend: Button
var edited := false

func _ready() -> void:
    custom_minimum_size.x = 275
    add_theme_constant_override("separation", 6)
    var heading := Label.new()
    heading.text = "시작 능력 · 자유 배분 6점"
    add_child(heading)
    for key in growth.KEYS:
        var row := HBoxContainer.new()
        add_child(row)
        var label := Label.new()
        label.custom_minimum_size.x = 48
        label.text = growth.rules.stat_labels[key]
        row.add_child(label)
        var minus := Button.new()
        minus.text = "−"
        minus.custom_minimum_size = Vector2(36,32)
        minus.accessibility_name = label.text + " 배분 줄이기"
        minus.pressed.connect(change.bind(key,-1))
        row.add_child(minus)
        var value := Label.new()
        value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        row.add_child(value)
        var plus := Button.new()
        plus.text = "+"
        plus.custom_minimum_size = Vector2(36,32)
        plus.accessibility_name = label.text + " 배분 늘리기"
        plus.pressed.connect(change.bind(key,1))
        row.add_child(plus)
        rows[key] = {"minus":minus,"plus":plus,"value":value}
    summary = Label.new()
    summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_font_size_override("font_size",14)
    add_child(summary)
    recommend = Button.new()
    recommend.text = "선택 무공에 맞춰 추천 배분"
    recommend.pressed.connect(reset_recommendation)
    add_child(recommend)
    var effects := Label.new()
    effects.name = "StatEffects"
    effects.text = "능력의 효과\n외공 · 속공·강공 위력, 외공 무공의 사용 조건\n근골 · 팽가도결 등 근골 무공의 사용 조건\n신법 · 매화검결·소요보결의 사용 조건\n내공 · 장풍·천공 특수 합 위력, 내공 무공의 사용 조건\n심안 · 태극검결·천기암기록 사용 조건, 태극 특수 합 위력\n\n근골이 체력, 신법이 이동 거리, 심안이 관찰량을 자동으로 늘리지는 않습니다. 무공별 효과를 함께 확인하세요."
    effects.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    effects.add_theme_font_size_override("font_size",16)
    effects.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(effects)
    refresh()

func configure(ids: Array) -> void:
    if manual_ids != ids:
        manual_ids = ids.duplicate()
        if not edited: allocation = growth.recommended_allocation(manual_ids)
    refresh()

func reset() -> void:
    edited = false
    manual_ids = []
    allocation = growth.recommended_allocation([])
    refresh()

func reset_recommendation() -> void:
    edited = false
    allocation = growth.recommended_allocation(manual_ids)
    refresh()
    allocation_changed.emit()

func change(key: String, delta: int) -> void:
    var next := allocation.duplicate(true)
    next[key] = int(next[key]) + delta
    if not growth.valid_allocation(next,true): return
    allocation = next
    edited = true
    refresh()
    allocation_changed.emit()

func refresh() -> void:
    if not is_instance_valid(summary): return
    var mastery := {}
    for id in manual_ids: mastery[id] = 3
    var preview: Dictionary = growth.project(allocation,mastery,true)
    var spent := 0
    for value in allocation.values(): spent += int(value)
    var unlocked := 0
    for id in manual_ids:
        for card in growth.registry.build_unlocked_cards(id,3):
            if growth.lock_reason(card,preview.stats).is_empty(): unlocked += 1
    for key in rows:
        rows[key].value.text = "%d  (+%d)" % [int(preview.stats[key]),int(allocation[key])]
        rows[key].minus.disabled = int(allocation[key]) == 0
        rows[key].plus.disabled = spent == int(growth.rules.free_points) or int(allocation[key]) >= int(growth.rules.free_per_stat_max)
    summary.text = "남은 배분 %d점 · 첫 기술 %d/%d 사용 가능\n표시 능력 = 기본 2 + 배분 + 무공 보너스" % [int(growth.rules.free_points)-spent,unlocked,manual_ids.size()]
    recommend.disabled = manual_ids.is_empty()
