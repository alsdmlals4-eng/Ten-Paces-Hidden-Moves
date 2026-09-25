extends Control
## Readable native controls laid over the approved ink landscape.
signal command_requested(command: String, value: String)
const JourneyMap := preload("res://src/ui/ink/ink_journey_map.gd")
const PAPER := Color("eee5d2")
const INK := Color("272920")
var _run

func configure(run_state) -> void:
    _run = run_state
    for child in get_children():
        remove_child(child)
        child.queue_free()
    var screen: String = _run.get_current_screen()
    var content: Dictionary = _run.get_frame_intro_content()
    var state: Dictionary = _run.get_frame_onboarding()
    var heading := _label("출사표" if screen == "PROLOGUE" else "수 읽기의 첫걸음" if screen == "TUTORIAL" else "강호행로", 46)
    heading.anchor_left = 0.03
    heading.anchor_top = 0.025
    heading.anchor_right = 0.46
    heading.anchor_bottom = 0.17
    heading.add_theme_color_override("font_color", PAPER)
    heading.add_theme_color_override("font_shadow_color", Color.BLACK)
    heading.add_theme_constant_override("shadow_offset_x", 2)
    heading.add_theme_constant_override("shadow_offset_y", 2)
    add_child(heading)
    var panel := PanelContainer.new()
    panel.name = "OnboardingPaper"
    panel.anchor_left = 0.49
    panel.anchor_top = 0.10
    panel.anchor_right = 0.96
    panel.anchor_bottom = 0.88
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.94, 0.90, 0.80, 0.97)
    style.border_color = Color("ad8c50")
    style.set_border_width_all(2)
    for edge in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]: style.set_content_margin(edge, 22)
    panel.add_theme_stylebox_override("panel", style)
    add_child(panel)
    var scroll := ScrollContainer.new()
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.follow_focus = true
    panel.add_child(scroll)
    var page := VBoxContainer.new()
    page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page.add_theme_constant_override("separation", 18)
    scroll.add_child(page)
    if screen == "PROLOGUE":
        var title := _label("한 장의 출사표", 31)
        _ink_heading(title)
        page.add_child(title)
        page.add_child(_label(str(content.prologue.text), 23))
        page.add_child(HSeparator.new())
        var concepts := HBoxContainer.new()
        concepts.add_theme_constant_override("separation", 12)
        for item in [{"id": "mount_hua_plum_blossom_sword", "label": "무공 선택"}, {"id": "xiaoyao_lingbo_footwork", "label": "10초 행동설계"}, {"id": "wudang_taiji_sword", "label": "관찰과 수읽기"}]:
            var concept := VBoxContainer.new()
            concept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            var illustration := TextureRect.new()
            illustration.texture = preload("res://src/ui/approved_blueprint_art.gd").manual_illustration(item.id, 3)
            illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            illustration.custom_minimum_size.y = 118
            concept.add_child(illustration)
            var caption := _label(item.label, 18)
            caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            concept.add_child(caption)
            concepts.add_child(concept)
        page.add_child(concepts)
        page.add_child(_label("선딜 · 발동 · 후딜을 익히고 첫 길에 나섭니다.", 19))
        page.add_child(_button("OnboardingPrimary", "무공 고르기  ›", "advance"))
    elif screen == "TUTORIAL":
        var lesson: Dictionary = content.lessons[int(state.tutorial_step)]
        page.add_child(_label("규칙 익히기  %d / 4" % (int(state.tutorial_step) + 1), 18))
        page.add_child(_label(str(lesson.title), 28))
        page.add_child(_label(str(lesson.text), 20))
        _add_lesson_diagram(page, int(state.tutorial_step), bool(state.practice_complete))
        if int(state.tutorial_step) == 3:
            var practice := _button("PracticePlace20", "연습 기술을 2.0초에 놓기", "practice", "20")
            practice.disabled = bool(state.practice_complete)
            page.add_child(practice)
            if state.practice_complete: page.add_child(_label("배치 완료 · 2.0초에 준비하여 3.0초에 발동, 5.0초에 동작을 마칩니다.", 18))
        var next := _button("OnboardingPrimary", "첫 행로로  ›" if int(state.tutorial_step) == 3 else "다음 규칙  ›", "advance")
        next.disabled = int(state.tutorial_step) == 3 and not state.practice_complete
        page.add_child(next)
    else:
        var map := JourneyMap.new()
        map.name = "FirstJourneyMap"
        map.anchor_left = 0.03
        map.anchor_top = 0.24
        map.anchor_right = 0.46
        map.anchor_bottom = 0.80
        add_child(map)
        map.configure([{"id": "first_event", "label": "산길\n갈림길의 나그네", "disabled": state.journey_entered}], "출발\n첫 길", "first_event" if state.journey_entered else "")
        map.node_selected.connect(func(_id): command_requested.emit("enter_journey", ""))
        page.add_child(_label("첫 행로 · 비전투 사건", 18))
        page.add_child(_label(str(content.event.title), 29))
        var resources: Dictionary = _run.get_player_run_resources()
        page.add_child(_label("체력 %d/%d  ·  기력 %d/%d  ·  내력 %d/%d" % [resources.health[0],resources.health[1],resources.stamina[0],resources.stamina[1],resources.internal[0],resources.internal[1]], 17))
        page.add_child(_label(str(content.event.text), 21))
        if not state.journey_entered:
            page.add_child(_label("지도에서 산길을 고르거나 아래 버튼으로 사건에 들어갑니다.", 18))
            page.add_child(_button("OnboardingPrimary", "이곳으로 향한다  ›", "enter_journey"))
        elif state.journey_receipt.is_empty():
            page.add_child(_label("능력치와 성공률을 비교해 선택하세요.", 18))
            for option in _run.get_first_journey_options():
                var button := _button("IntroChoice_" + str(option.id), str(option.label) + "\n" + str(option.effect), "choice", str(option.id))
                button.add_theme_font_size_override("font_size", 18)
                page.add_child(button)
        else:
            var rules = preload("res://src/run/giyun_rules.gd").new()
            page.add_child(HSeparator.new())
            page.add_child(_label(str(state.journey_receipt.choice_label), 20))
            page.add_child(_label(rules.outcome_text(state.journey_receipt), 23))
            page.add_child(_label("길을 확인했습니다. 첫 상대가 기다리는 비무터로 갑니다.", 18))
            page.add_child(_button("OnboardingPrimary", "첫 비무 브리핑  ›", "advance"))
    var progress := _label("출사표   —   무공 선택   —   규칙 익히기   —   첫 행로   —   첫 비무", 18)
    progress.name = "OnboardingProgress"
    progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    progress.anchor_left = 0.03
    progress.anchor_top = 0.92
    progress.anchor_right = 0.97
    progress.anchor_bottom = 0.98
    progress.add_theme_color_override("font_color", PAPER)
    progress.add_theme_color_override("font_shadow_color", Color.BLACK)
    progress.add_theme_constant_override("shadow_offset_x", 2)
    progress.add_theme_constant_override("shadow_offset_y", 2)
    _ink_heading(progress)
    add_child(progress)

func _ink_heading(label: Label) -> void:
    var box := StyleBoxFlat.new()
    box.bg_color = Color("272920")
    box.content_margin_left = 16
    box.content_margin_right = 16
    box.content_margin_top = 8
    box.content_margin_bottom = 8
    label.add_theme_stylebox_override("normal", box)
    label.add_theme_color_override("font_color", PAPER)

func _add_lesson_diagram(page: VBoxContainer, step: int, completed: bool) -> void:
    var timeline := HBoxContainer.new()
    timeline.name = "PracticeTimeline"
    timeline.add_theme_constant_override("separation", 2)
    page.add_child(timeline)
    for i in range(10):
        var cell := Label.new()
        cell.text = str(i) + "초"
        cell.custom_minimum_size.y = 54
        cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        cell.add_theme_font_size_override("font_size", 14)
        var box := StyleBoxFlat.new()
        box.bg_color = Color("d7c6a7")
        if step == 1 or (step == 3 and completed):
            if i == 2: box.bg_color = Color("c1a35a")
            elif i == 3: box.bg_color = Color("ac5541")
            elif i == 4: box.bg_color = Color("94a49a")
        elif step == 2 and i >= 2 and i < 5: box.bg_color = Color("c1a35a")
        cell.add_theme_stylebox_override("normal", box)
        timeline.add_child(cell)
    var markers := HBoxContainer.new()
    for i in range(3):
        var marker := _label(["0.0초", "5.0초", "10.0초"][i], 14)
        marker.horizontal_alignment = [HORIZONTAL_ALIGNMENT_LEFT, HORIZONTAL_ALIGNMENT_CENTER, HORIZONTAL_ALIGNMENT_RIGHT][i]
        markers.add_child(marker)
    page.add_child(markers)
    if step == 1 or step == 3: page.add_child(_label("준비(선딜)  →  효과가 생기는 발동  →  회복(후딜)", 16))
    elif step == 2: page.add_child(_label("예시: 2초에 관찰 1단계를 마치면 5초까지 확인", 16))

func _label(text: String, font_size: int) -> Label:
    var label := Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", INK)
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return label

func _button(node_name: String, text: String, command: String, value: String = "") -> Button:
    var button := Button.new()
    button.name = node_name
    button.text = text
    button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    button.custom_minimum_size.y = 58
    button.add_theme_font_size_override("font_size", 22)
    button.accessibility_name = text
    if node_name == "OnboardingPrimary":
        var gold := StyleBoxFlat.new()
        gold.bg_color = Color("d3b575")
        gold.border_color = Color("7b5b2e")
        gold.set_border_width_all(2)
        gold.content_margin_top = 12
        gold.content_margin_bottom = 12
        button.add_theme_stylebox_override("normal", gold)
    button.pressed.connect(func(): command_requested.emit(command, value))
    return button
