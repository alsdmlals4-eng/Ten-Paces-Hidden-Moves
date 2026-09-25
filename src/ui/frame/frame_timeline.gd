extends Control
## Public view only. Hidden enemy actions never enter this Control.
signal placement_requested(card_id: String, tick: int, from_index: int)
signal remove_requested(index: int)
signal cursor_changed(tick: int)
var cards: Dictionary = {}
var player_plan: Array = []
var public_enemy: Array = []
var carry: Dictionary = {}
var cursor_tick := 0
var playback_tick := -1.0
var selected_card := ""
var editable := true
var font: Font
var _drag_index := -1
const LEFT := 94.0
const RIGHT := 18.0
const PAPER := Color("ece1c9")
const INK := Color("282c28")
const PHASES := [Color("b5a36d"), Color("8b3f30"), Color("526b68")]

func _ready() -> void:
    focus_mode = Control.FOCUS_ALL
    mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    font = get_theme_default_font()
    tooltip_text = "삽화를 끌어 내 시간축에 놓습니다. 클릭으로 배치 · 오른쪽 클릭으로 삭제 · 방향키 0.1초 이동 · Enter 배치"

func configure(definitions: Dictionary, plan: Array, revealed: Array, carried: Dictionary = {}) -> void:
    cards = definitions
    player_plan = plan.duplicate(true)
    public_enemy = revealed.duplicate(true)
    carry = carried.duplicate(true)
    queue_redraw()

func tick_at(x: float) -> int:
    return clampi(roundi((x - LEFT) / maxf(1, size.x - LEFT - RIGHT) * 100), 0, 99)

func _x(tick: float) -> float:
    return LEFT + clampf(tick, 0, 100) / 100.0 * (size.x - LEFT - RIGHT)

func _draw() -> void:
    if font == null: return
    draw_rect(Rect2(Vector2.ZERO, size), PAPER)
    for i in range(11):
        var x := _x(i * 10)
        draw_line(Vector2(x, 34), Vector2(x, size.y - 26), Color(0.2,0.2,0.15,0.18), 1)
        draw_string(font, Vector2(x - (35 if i==10 else 7), 25), str(i) + "초", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, INK)
    draw_string(font, Vector2(12, 76), "나", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, INK)
    draw_string(font, Vector2(12, 142), "상대", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, INK)
    draw_rect(Rect2(LEFT, 110, size.x - LEFT - RIGHT, 51), Color("c9c1af"))
    if public_enemy.is_empty():draw_string(font, Vector2(LEFT + 14, 143), "미관찰 구간", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("6b685c"))
    for action in public_enemy: _block(action, 112, true)
    if not carry.is_empty():
        var end := int(carry.get("remaining_ticks", 0))
        draw_rect(Rect2(LEFT, 43, _x(end) - LEFT, 52), Color("667b73"))
        draw_string(font, Vector2(LEFT + 5, 75), "이월", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, PAPER)
    for action in player_plan: _block(action, 43, false)
    var x := _x(playback_tick if playback_tick >= 0 else cursor_tick)
    draw_line(Vector2(x, 31), Vector2(x, 166), Color("9b392c"), 3)
    draw_string(font, Vector2(LEFT, size.y - 4), "선딜  ━ 황토     발동  ━ 주홍     후딜  ━ 청묵", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, INK)
    if has_focus(): draw_rect(Rect2(Vector2.ONE * 2, size - Vector2.ONE * 4), Color("ad7b33"), false, 2)

func _block(action: Dictionary, y: float, enemy: bool) -> void:
    var card: Dictionary = cards.get(str(action.get("card_id", "")), {})
    var timing: Dictionary = action.get("frame_timing", card.get("frame_timing", {}))
    var t := float(action.get("start_tick", 0))
    var begin := t
    for i in range(3):
        var duration := float(timing.get(["startup", "active", "recovery"][i], 1))
        var r := Rect2(_x(t), y, maxf(0, _x(t + duration) - _x(t)), 49)
        draw_rect(r, Color(PHASES[i], 0.78 if enemy else 0.97))
        t += duration
    var width := _x(t) - _x(begin)
    if width > 24:
        draw_string(font, Vector2(_x(begin) + 5, y + 29), str(action.get("name", card.get("name", "관찰"))), HORIZONTAL_ALIGNMENT_LEFT, width - 8, 20, Color("fff7e7"))

func _index_at(point: Vector2) -> int:
    if point.y < 40 or point.y > 98: return -1
    var tick := tick_at(point.x)
    for i in range(player_plan.size()):
        var p: Dictionary = player_plan[i]
        var timing: Dictionary = cards.get(p.card_id, {}).get("frame_timing", {})
        if tick >= int(p.start_tick) and tick < int(p.start_tick) + int(timing.get("total", 0)): return i
    return -1

func _gui_input(event: InputEvent) -> void:
    if not editable: return
    if event is InputEventMouseButton and event.pressed:
        grab_focus()
        if event.button_index == MOUSE_BUTTON_RIGHT:
            var index := _index_at(event.position)
            if index >= 0: remove_requested.emit(index)
        elif event.button_index == MOUSE_BUTTON_LEFT:
            cursor_tick = tick_at(event.position.x)
            cursor_changed.emit(cursor_tick)
            if event.position.y < 105 and _index_at(event.position) < 0 and not selected_card.is_empty():
                placement_requested.emit(selected_card, cursor_tick, -1)
        queue_redraw()
        accept_event()
    elif event is InputEventKey and event.pressed:
        if event.keycode in [KEY_LEFT, KEY_RIGHT]:
            cursor_tick = clampi(cursor_tick + (1 if event.keycode == KEY_RIGHT else -1), 0, 99)
            cursor_changed.emit(cursor_tick)
        elif event.keycode in [KEY_ENTER, KEY_KP_ENTER] and not selected_card.is_empty():
            placement_requested.emit(selected_card, cursor_tick, -1)
        elif event.keycode == KEY_DELETE:
            var index := _index_at(Vector2(_x(cursor_tick), 60))
            if index >= 0: remove_requested.emit(index)
        queue_redraw()
        accept_event()

func _get_drag_data(at_position: Vector2):
    if not editable: return null
    _drag_index = _index_at(at_position)
    if _drag_index < 0: return null
    var card: Dictionary = player_plan[_drag_index]
    var preview := Label.new()
    preview.text = str(cards.get(card.card_id, {}).get("name", "기술"))
    set_drag_preview(preview)
    return {"frame_card_id":card.card_id,"from_index":_drag_index}

func _can_drop_data(at_position: Vector2, data) -> bool:
    return editable and at_position.y < 105 and data is Dictionary and cards.has(data.get("frame_card_id", ""))

func _drop_data(at_position: Vector2, data) -> void:
    placement_requested.emit(str(data.frame_card_id), tick_at(at_position.x), int(data.get("from_index", -1)))
