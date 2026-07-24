class_name CombatReviewPanel
extends Control

signal detail_requested
signal continue_requested

const PANEL := Color(0.035, 0.030, 0.026, 0.985)
const GOLD := Color("c79a50")
const PAPER := Color("e0cfaa")

var _summary: Dictionary = {}
var _terminal := false
var _title: Label
var _content: RichTextLabel
var _detail_button: Button
var _continue_button: Button

func _ready() -> void:
    visible = false
    mouse_filter = Control.MOUSE_FILTER_STOP
    _build()
    resized.connect(_layout)
    _layout()

func _build() -> void:
    if _content != null:
        return
    _title = Label.new()
    _title.name = "ReviewTitle"
    _title.text = "결정적 복기"
    _title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _title.add_theme_font_size_override("font_size", 22)
    _title.add_theme_color_override("font_color", Color.WHITE)
    add_child(_title)

    _content = RichTextLabel.new()
    _content.name = "ReviewContent"
    _content.bbcode_enabled = false
    _content.fit_content = false
    _content.scroll_active = true
    _content.selection_enabled = true
    _content.add_theme_font_size_override("normal_font_size", 16)
    _content.add_theme_color_override("default_color", PAPER)
    _content.accessibility_name = "결정적 복기 내용"
    _content.accessibility_description = "내 가설, 상대 실제 행동, 결정적 원인, 전후 거리와 다음 검토 내용을 읽습니다."
    add_child(_content)

    _detail_button = Button.new()
    _detail_button.name = "ReviewDetailButton"
    _detail_button.text = "상세 기록"
    _detail_button.focus_mode = Control.FOCUS_ALL
    _detail_button.accessibility_name = "상세 전투 기록 열기"
    _detail_button.accessibility_description = "기존 전투 기록 패널을 펼쳐 수별 판정 기록을 확인합니다."
    _detail_button.pressed.connect(func() -> void: detail_requested.emit())
    add_child(_detail_button)

    _continue_button = Button.new()
    _continue_button.name = "ReviewContinueButton"
    _continue_button.focus_mode = Control.FOCUS_ALL
    _continue_button.accessibility_name = "복기 확인 후 계속"
    _continue_button.pressed.connect(func() -> void: continue_requested.emit())
    add_child(_continue_button)

    set_meta("read_only_summary", true)
    set_meta("recalculates_combat", false)
    set_meta("review_hierarchy", "내 가설|상대 실제 행동|결정적 원인|전후 거리|다음 검토")

func show_summary(summary_value: Dictionary, terminal: bool) -> void:
    _summary = summary_value.duplicate(true)
    _terminal = terminal
    _refresh()
    visible = true
    move_to_front()
    if is_instance_valid(_continue_button):
        _continue_button.grab_focus.call_deferred()

func hide_review() -> void:
    visible = false
    _summary.clear()
    _terminal = false

func get_detail_button() -> Button:
    return _detail_button

func get_continue_button() -> Button:
    return _continue_button

func get_display_text() -> String:
    return _content.text if is_instance_valid(_content) else ""

func _refresh() -> void:
    if not is_instance_valid(_content) or not is_instance_valid(_continue_button):
        return
    var hypothesis: Dictionary = _summary.get("hypothesis", {})
    var hypothesis_text := str(hypothesis.get("label", "기록한 가설 없음"))
    if not bool(hypothesis.get("recorded", false)):
        hypothesis_text = "기록한 가설 없음"
    var timing := int(_summary.get("decisive_timing", 0))
    var timing_text := "%d수" % timing if timing > 0 else "수 정보 없음"
    var lines := PackedStringArray([
        "내 가설 · %s" % hypothesis_text,
        "상대 실제 행동 · %s" % str(_summary.get("opponent_actual", "행동 정보 없음")),
        "결정적 원인 · %s · %s" % [timing_text, str(_summary.get("cause_label", "행동 순서와 실행 시점이 결과를 결정했다."))],
        "전후 거리 · %d → %d" % [int(_summary.get("distance_before", 0)), int(_summary.get("distance_after", 0))],
        "다음 검토 · %s" % str(_summary.get("review_dimension", "다음 묶음의 실행 순서를 다시 확인한다."))
    ])
    _content.text = "\n\n".join(lines)
    _continue_button.text = "결전 다시 시작" if _terminal else "다음 묶음"
    _continue_button.accessibility_description = "결전을 초기 상태로 다시 시작합니다." if _terminal else "복기를 닫고 다음 행동 묶음 계획으로 이동합니다."
    set_meta("terminal", _terminal)
    set_meta("cause_code", str(_summary.get("cause_code", "order")))

func _layout() -> void:
    if not is_instance_valid(_title) or not is_instance_valid(_content) or not is_instance_valid(_detail_button) or not is_instance_valid(_continue_button):
        return
    _title.position = Vector2(22.0, 18.0)
    _title.size = Vector2(maxf(1.0, size.x - 44.0), 34.0)
    _content.position = Vector2(28.0, 62.0)
    _content.size = Vector2(maxf(1.0, size.x - 56.0), maxf(1.0, size.y - 132.0))
    var button_y := maxf(1.0, size.y - 56.0)
    _detail_button.position = Vector2(28.0, button_y)
    _detail_button.size = Vector2(maxf(120.0, (size.x - 68.0) * 0.46), 38.0)
    _continue_button.position = Vector2(size.x - 28.0 - maxf(150.0, (size.x - 68.0) * 0.46), button_y)
    _continue_button.size = Vector2(maxf(150.0, (size.x - 68.0) * 0.46), 38.0)
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _layout()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), PANEL, true)
    draw_rect(Rect2(Vector2.ONE, size - Vector2(2.0, 2.0)), Color(GOLD, 0.92), false, 3.0)
