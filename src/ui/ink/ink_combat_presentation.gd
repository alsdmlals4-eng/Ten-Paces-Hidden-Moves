extends Control
const Model = preload("res://src/ui/ink/ink_resolution_model.gd")
const Stage = preload("res://src/ui/ink/ink_combat_stage.gd")
const PAPER := Color("e8dfcc")
const INK := Color("272920")
const GOLD := Color("ad8b4d")
var stage: Control
var heading: Label
var player_hud: Label
var enemy_hud: Label
var left: Label
var right: Label
var comparison: Label
var result_label: Label
var slots: Array[Label] = []
var controls: HBoxContainer
var volume: HSlider
var bundle: Dictionary = {}
var step: Dictionary = {}
var current := -1
var verdict := false
var applied := false
var completed := false
var snapshot := {}
var board: Control
var typeface := SystemFont.new()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 50
	typeface.font_names = PackedStringArray(["Batang","Noto Serif CJK KR","serif"])
	stage = Stage.new()
	stage.name = "ApprovedInkStage"
	add_child(stage)
	heading = label("RoundAndBundle",26,HORIZONTAL_ALIGNMENT_CENTER)
	player_hud = label("PlayerPublicState",17)
	enemy_hud = label("EnemyPublicState",17,HORIZONTAL_ALIGNMENT_RIGHT)
	left = label("PlayerResolvedAction",24,HORIZONTAL_ALIGNMENT_CENTER)
	right = label("EnemyResolvedAction",24,HORIZONTAL_ALIGNMENT_CENTER)
	comparison = label("AuthoritativeComparison",32,HORIZONTAL_ALIGNMENT_CENTER)
	result_label = label("AuthoritativeResourceChanges",21,HORIZONTAL_ALIGNMENT_CENTER)
	for node in [left,right,comparison,result_label]:
		node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for node in [left,right,result_label]:
		node.add_theme_color_override("font_color",PAPER)
	for i in range(4):
		slots.append(label("TimingSlot%d" % (i+1),18,HORIZONTAL_ALIGNMENT_CENTER))
	controls = HBoxContainer.new()
	controls.add_theme_constant_override("separation",10)
	add_child(controls)
	for text in ["빠르게", "모션 줄임", "소리", "연출 건너뛰기"]:
		var button := Button.new()
		button.text = text
		button.custom_minimum_size = Vector2(112,30)
		button.add_theme_font_size_override("font_size",15)
		button.add_theme_font_override("font",typeface)
		button.add_theme_color_override("font_color",INK)
		for theme_color in ["font_focus_color","font_hover_color","font_pressed_color","font_hover_pressed_color"]:
			button.add_theme_color_override(theme_color,INK)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("ded1b4")
		style.border_color = GOLD
		style.set_border_width_all(1)
		style.content_margin_left = 10
		style.content_margin_right = 10
		button.add_theme_stylebox_override("normal",style)
		button.pressed.connect(func():
			if text == "빠르게": board._toggle_fast_replay()
			elif text == "모션 줄임": board._toggle_reduced_motion()
			elif text == "소리": board._toggle_sound()
			else: board._skip_presentation())
		controls.add_child(button)
	volume = HSlider.new()
	volume.name = "EffectVolume"
	volume.min_value = 0
	volume.max_value = 1
	volume.step = 0.05
	volume.custom_minimum_size = Vector2(95,30)
	volume.tooltip_text = "효과음 음량"
	volume.value_changed.connect(func(value): board._set_sound_volume(value))
	controls.add_child(volume)
	for i in range(controls.get_child_count()):
		var control: Control = controls.get_child(i)
		control.focus_next = control.get_path_to(controls.get_child((i+1)%controls.get_child_count()))
		control.focus_previous = control.get_path_to(controls.get_child((i-1+controls.get_child_count())%controls.get_child_count()))
	resized.connect(layout)
	visible = false

func label(node_name: String, font_size: int, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var node := Label.new()
	node.name = node_name
	node.horizontal_alignment = align
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.autowrap_mode = TextServer.AUTOWRAP_OFF
	node.clip_text = true
	node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_color_override("font_color",INK)
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_font_override("font",typeface)
	add_child(node)
	return node

func begin(value: Dictionary, owner_board: Control) -> void:
	bundle = value
	board = owner_board
	stage.configure_opponent(str(bundle.before.get("enemy",{}).get("candidate_id","")))
	current = -1
	completed = false
	verdict = false
	applied = false
	stage.pose = {"p":0,"e":0,"px":338.0,"py":622.0,"ex":968.0,"ey":590.0,"pr":0.0,"er":0.0,"zoom":1.0}
	step = {}
	visible = true
	volume.set_value_no_signal(board._sound_volume)
	(controls.get_child(0) as Button).grab_focus()
	refresh()
	layout()

func begin_step(index: int) -> void:
	current = index
	step = bundle.steps[index]
	verdict = false
	applied = false
	refresh()

func refresh() -> void:
	if bundle.is_empty():
		return
	var state: Dictionary = step.get("after" if applied else "before",bundle.before)
	if completed:
		state = bundle.after
	var distance := absi(int(state.get("player",{}).get("tile",4))-int(state.get("enemy",{}).get("tile",6)))
	heading.text = "제 %d 라운드 · %d묶음\n%s · 거리 %d" % [bundle.round,bundle.index,"묶음 완료" if completed else "전투 진행",distance]
	player_hud.text = "%s\n체력 %d · 기력 %d · 내력 %d · 기세 %d" % [state.get("player",{}).get("name","강호낭인"),Model.value(state,"player","health"),Model.value(state,"player","stamina"),Model.value(state,"player","internal"),Model.value(state,"player","momentum")]
	# The enemy's undisclosed absolute resources remain hidden even during resolution.
	enemy_hud.text = "%s\n체력 ? · 기력 ? · 내력 ? · 기세 ?" % state.get("enemy",{}).get("name","상대")
	var public: Array = Model.public_slots(bundle,bundle.steps.size() if completed else current)
	for i in range(slots.size()):
		slots[i].visible = i < public.size()
		if i < public.size():
			var item: Dictionary = public[i]
			slots[i].text = "%d수 · %s\n내 %s\n상대 %s" % [item.timing,item.status,item.player,item.enemy]
			slots[i].add_theme_color_override("font_color",PAPER if i == current else INK)
			slots[i].tooltip_text = slots[i].text
	left.text = "내 확정 행동" if step.is_empty() else "플레이어\n%s\n%s" % [step.actions.player.label,cost_text("player")]
	right.text = "상대 · 미공개" if step.is_empty() else "상대\n%s\n%s" % [step.actions.enemy.label,cost_text("enemy")]
	comparison.text = compare_text()
	result_label.text = "내 대응 선지불 · " + Model.changes({"player":bundle.response_delta.player}) if step.is_empty() else Model.changes(step.delta) if applied else "행동 공개 · 이 수를 해결하고 있습니다"
	if applied and not step.is_empty() and step.delta.player.health >= 0 and step.delta.enemy.health >= 0 and step.cues.any(func(c): return c.kind in ["clash","attack","block","evade","miss"]):
		result_label.text = "피해 0 · " + result_label.text
	if completed:
		result_label.text = "묶음 완료 · " + Model.changes(bundle.completion_delta) + "  |  다음 묶음 준비"
	for node in [left,right,comparison,result_label,player_hud,enemy_hud]:
		node.tooltip_text = node.text
	snapshot = {"bundle":bundle.index,"timing":step.get("timing",0),"slots":public,"result":result_label.text,"verdict":comparison.text,"applied":applied,"completed":completed,"enemy_resources_hidden":true}
	if board != null:
		(controls.get_child(0) as Button).text = "빠르게: " + ("켬" if board._fast_replay else "끔")
		(controls.get_child(1) as Button).text = "모션 줄임: " + ("켬" if board._reduced_motion else "끔")
		(controls.get_child(2) as Button).text = "소리: " + ("끔" if board._sound_muted else "켬")
	queue_redraw()

func cost_text(actor: String) -> String:
	if step.is_empty():
		return ""
	if step.actions[actor].get("response_prepaid", false):
		return "기력 %d · 묶음 시작에 지불" % int(step.actions[actor].event.get("stamina_cost",0))
	var parts := PackedStringArray()
	for key in ["stamina","internal"]:
		var d := int(step.delta[actor][key])
		if d != 0 and applied:
			parts.append("%s %+d" % ["기력" if key == "stamina" else "내력",d])
	return " · ".join(parts) if not parts.is_empty() else ""

func compare_text() -> String:
	if completed:
		return "행동 묶음 해결"
	if step.is_empty():
		return "수를 펼치다"
	var p: Dictionary = step.actions.player.event
	var e: Dictionary = step.actions.enemy.event
	if p.get("type") == "clash" or e.get("type") == "clash":
		var title := "합 · 위력 비교"
		if verdict:
			title = "내 합 승리" if p.get("outcome") == "clash_win" else "상대 합 승리" if e.get("outcome") == "clash_win" else "합 상쇄"
		return "%s\n%s  對  %s" % [title,p.get("raw_damage","—"),e.get("raw_damage","—")]
	if not verdict:
		return "전조 · 다음 수로" if step.actions.player.stage == "preparation" or step.actions.enemy.stage == "preparation" else "한 수를 잇다"
	var results := PackedStringArray()
	for action in [p,e]:
		var outcome := str(action.get("defense_outcome",action.get("outcome","")))
		var names := {"evade":"회피 성공", "evaded":"회피 성공", "block":"막기", "sure_hit_block":"필중 · 막기", "miss_range":"사거리 밖", "miss_direction":"방향 빗나감", "interrupted":"중단", "martial_failed":"조건 미충족", "move":"이동", "preparation":"전조", "hit":"공격 적중"}
		if names.has(outcome) and not results.has(names[outcome]):
			results.append(names[outcome])
	var summary := " · ".join(results) if not results.is_empty() else "행동 적용"
	for event in [p,e]:
		if event.has("raw_damage"):
			return summary + "\n위력 %s → 피해 %s" % [event.raw_damage,event.get("damage",0)]
	return summary

func panel_height() -> float:
	return clampf(size.y * 0.36,306.0,370.0)

func layout() -> void:
	if stage == null:
		return
	var w := size.x
	var bottom := size.y-panel_height()
	stage.position = Vector2(0,76)
	stage.size = Vector2(w,maxf(1,bottom-80))
	place(heading,Rect2(w*0.33,4,w*0.34,72))
	place(player_hud,Rect2(24,6,w*0.32-24,64))
	place(enemy_hud,Rect2(w*0.67,6,w*0.33-24,64))
	var count := maxi(3,int(bundle.get("steps",[]).size()))
	var cell := (w-48.0)/float(count)
	for i in range(4):
		place(slots[i],Rect2(26+i*cell,bottom+6,cell-8,76))
	place(left,Rect2(32,bottom+95,w*0.31-40,90))
	place(right,Rect2(w*0.69+8,bottom+95,w*0.31-40,90))
	place(comparison,Rect2(w*0.32,bottom+90,w*0.36,100))
	place(result_label,Rect2(32,bottom+202,w-64,panel_height()-248))
	controls.position = Vector2(w-654,size.y-34)
	controls.size = Vector2(630,30)
	queue_redraw()

func place(node: Control, rect: Rect2) -> void:
	node.position = rect.position
	node.size = rect.size

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),PAPER)
	var y := size.y-panel_height()
	draw_line(Vector2(24,y),Vector2(size.x-24,y),GOLD,2)
	var count := maxi(3,int(bundle.get("steps",[]).size()))
	var cell := (size.x-48)/float(count)
	for i in range(count):
		var box := Rect2(24+i*cell,y+5,cell-4,78)
		draw_rect(box,Color("304c4d") if i == current else Color("e0d6be"))
		draw_rect(box,GOLD if i == current else Color("c0b69f"),false,2 if i == current else 1)
	draw_line(Vector2(24,y+87),Vector2(size.x-24,y+87),GOLD,1)
	brush_band(Rect2(24,y+95,size.x*0.31-24,90),Color("284b59"))
	brush_band(Rect2(size.x*0.69,y+95,size.x*0.31-24,90),Color("7c3c32"))
	brush_band(Rect2(20,y+200,size.x-40,panel_height()-244),INK)

func brush_band(rect: Rect2, color: Color) -> void:
	# Native UI brush edge, independent of damage/VFX timing.
	var points := PackedVector2Array()
	for i in range(25):
		points.append(rect.position + Vector2(rect.size.x*i/24.0,2.0+fmod(i*7.0,5.0)))
	for i in range(24,-1,-1):
		points.append(rect.position + Vector2(rect.size.x*i/24.0,rect.size.y-fmod(i*11.0,4.0)))
	draw_colored_polygon(points,color)
