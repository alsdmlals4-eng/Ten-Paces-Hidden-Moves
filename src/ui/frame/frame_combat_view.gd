extends Control
## Native controls over text-free approved art. This view never resolves combat.
signal place_requested(card_id: String, tick: int, from_index: int)
signal remove_requested(index: int)
signal execute_requested
signal clear_requested
signal playback_finished
const SKIN = preload("res://src/ui/ink/reference_preparation_skin.gd")
const ART = preload("res://src/ui/ink/ink_screen_art.gd")
const MODEL = preload("res://src/ui/ink/ink_resolution_model.gd")
const INK := Color("292d28")
const PAPER := Color("eee4cf")
var prep: Control
var movie: Control
var stage: Control
var timeline: Control
var movie_timeline: Control
var details: RichTextLabel
var hud_player: Label
var hud_enemy: Label
var observation: Label
var distance: Label
var heading: Label
var hint: Label
var execute: Button
var cards_host: Control
var movie_result: Label
var movie_actions: Label
var movie_player: Label
var movie_enemy: Label
var movie_clock: Label
var pause_button: Button
var next_button: Button
var definitions := {}
var selected := "basic_quick_attack"
var current_tab := "basic"
var current_state := {}
var plan: Array = []
var _result := {}
var _elapsed := 0.0
var _duration := 10.0
var _event_index := -1
var _cue_start := 0.0
var _cue_end := 1.0
var playing := false
var paused := false
var suspended := false
var reduced_motion := false
var speed := 1.0
var reverse_direction := false
var move_steps := 1
var _textures := {}
var _actor_labels := {"player":"대기","enemy":"미관찰"}
var _initial_revealed: Array = []

func _ready() -> void:
    theme = ART.theme()
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    prep = Control.new()
    prep.name = "FramePreparation"
    prep.size = Vector2(1086,1448)
    add_child(prep)
    var backdrop := TextureRect.new()
    backdrop.texture = SKIN.region(load("res://assets/ui/ink_frame/preparation_background.png"),Rect2(0,350,1086,1060))
    backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    backdrop.stretch_mode = TextureRect.STRETCH_SCALE
    backdrop.size = Vector2(1086,617)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    prep.add_child(backdrop)
    _panel(prep, Rect2(12,12,1062,1424), Color.TRANSPARENT, 3)
    _portrait("player", Rect2(20,15,154,218))
    _portrait("enemy", Rect2(912,15,154,218))
    _panel(prep,Rect2(160,25,262,190),Color(PAPER,0.94))
    _panel(prep,Rect2(686,25,226,190),Color(PAPER,0.94))
    hud_player = _label(prep, "", Rect2(165,35,260,170), 26)
    hud_enemy = _label(prep, "", Rect2(688,35,222,170), 24)
    hud_enemy.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _panel(prep,Rect2(430,20,235,106), Color("29312b"))
    heading = _label(prep,"행 동 설 계\n0 — 10초",Rect2(430,24,235,98),28,PAPER)
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _fighter("player", Rect2(135,194,334,400))
    _fighter("enemy", Rect2(652,277,220,300))
    _panel(prep,Rect2(483,340,116,159),Color(PAPER,0.82))
    distance = _label(prep,"거리\n2\n중간",Rect2(478,337,125,162),39)
    distance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _panel(prep,Rect2(863,252,194,264),Color("e4dac3"))
    _label(prep,"관찰 정보",Rect2(878,266,171,40),25)
    observation = _label(prep,"",Rect2(878,318,164,191),22)
    observation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _panel(prep,Rect2(35,617,1016,290),Color("e9ddc3"))
    _label(prep,"다음 열 초에 놓을 초식",Rect2(54,628,540,44),29)
    _button(prep,"비우기",Rect2(665,630,110,42),func():clear_requested.emit())
    execute = _button(prep,"진행  〉",Rect2(800,625,229,54),func():execute_requested.emit(),31)
    timeline = preload("res://src/ui/frame/frame_timeline.gd").new()
    timeline.name = "PlanTimeline"
    _place(prep,timeline,Rect2(49,680,988,210))
    timeline.placement_requested.connect(func(id,tick,index):place_requested.emit(id,tick,index))
    timeline.remove_requested.connect(func(index):remove_requested.emit(index))
    _panel(prep,Rect2(35,901,1016,50),PAPER)
    hint = _label(prep,"삽화를 끌어 놓으세요 · 0.1초씩 배치",Rect2(49,908,650,42),23)
    var direction_button:=_button(prep,"상대 방향",Rect2(706,909,168,40),func():reverse_direction=not reverse_direction,22)
    direction_button.pressed.connect(func():direction_button.text="반대 방향" if reverse_direction else "상대 방향")
    var steps_button:=_button(prep,"이동 1칸",Rect2(885,909,149,40),func():move_steps=2 if move_steps==1 else 1,22)
    steps_button.pressed.connect(func():steps_button.text="이동 %d칸" % move_steps)
    _panel(prep,Rect2(23,956,1040,439),Color("242b27"))
    for i in range(3):
        var tab: String = ["basic","martial","ultimate"][i]
        _button(prep,["기초","무공","절초"][i],Rect2(34+i*251,965,240,48),func():current_tab=tab;_render_cards(),29)
    cards_host = Control.new()
    _place(prep,cards_host,Rect2(34,1025,756,352))
    _panel(prep,Rect2(808,1025,240,351),PAPER)
    details = RichTextLabel.new()
    details.bbcode_enabled = true
    details.scroll_active = true
    details.add_theme_font_size_override("normal_font_size",24)
    _place(prep,details,Rect2(820,1037,214,329))
    _panel(prep,Rect2(23,1394,1040,42),Color("242b27"))
    _label(prep,"기술 클릭 → 시간축 클릭  ·  드래그로 위치 수정  ·  우클릭 삭제",Rect2(34,1397,1018,35),21,PAPER)
    _build_movie()
    resized.connect(_layout)
    _layout()

func _build_movie() -> void:
    movie = Control.new()
    movie.name = "FrameResolution"
    movie.size = Vector2(1440,1000)
    movie.visible = false
    add_child(movie)
    _panel(movie,Rect2(0,0,1440,1000),PAPER,3)
    stage = preload("res://src/ui/ink/ink_combat_stage.gd").new()
    _place(movie,stage,Rect2(4,4,1432,565))
    _panel(movie,Rect2(25,20,332,137),Color(PAPER,0.90))
    _panel(movie,Rect2(1083,20,332,137),Color(PAPER,0.90))
    movie_player = _label(movie,"",Rect2(43,32,294,122),28)
    movie_enemy = _label(movie,"",Rect2(1097,32,300,122),28)
    movie_clock = _label(movie,"",Rect2(554,26,332,91),31)
    movie_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    movie_timeline = preload("res://src/ui/frame/frame_timeline.gd").new()
    movie_timeline.editable = false
    _place(movie,movie_timeline,Rect2(25,578,1390,196))
    _panel(movie,Rect2(25,780,1390,151),Color("e5d7b7"),3)
    movie_actions = _label(movie,"",Rect2(49,790,1342,56),31)
    movie_actions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    movie_result = _label(movie,"",Rect2(49,847,1342,70),29)
    movie_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    movie_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    pause_button = _button(movie,"잠시 멈춤",Rect2(35,944,230,43),_pause_or_replay,23)
    _button(movie,"속도 전환",Rect2(282,944,210,43),func():speed=2.0 if speed==1.0 else 1.0,23)
    next_button = _button(movie,"다음 행동 설계  〉",Rect2(1015,944,390,43),func():playback_finished.emit(),25)
    next_button.visible = false

func set_data(state: Dictionary, cards: Array, player_plan: Array, revealed: Array, locked: bool = false) -> void:
    current_state = state.duplicate(true)
    plan = player_plan.duplicate(true)
    definitions.clear()
    for card in cards: definitions[str(card.id)] = card
    var f: Dictionary = state.get("frame", {})
    var t := int(f.get("time_tick",0))
    hud_player.text = "강호낭인\n" + _resources(state.get("player",{}))
    hud_enemy.text = str(state.get("enemy",{}).get("name","무명 검객")) + "\n체력  ? / ?\n기력  ?   내력  ?"
    heading.text = "행 동 설 계\n%d — %d초" % [t/10,t/10+10]
    var d := absi(int(state.get("enemy",{}).get("tile",6))-int(state.get("player",{}).get("tile",4)))
    distance.text = "거리\n%d\n%s" % [d,"밀착" if d==0 else "근접" if d==1 else "중간" if d<=3 else "원거리"]
    var level := int(f.get("observation_level",0))
    observation.text = "관찰 %d단계\n완료 후 %d초\n\n%s" % [level,level*3,"읽어 낸 행동은\n아래 시간축에 표시" if not revealed.is_empty() else "상대의 다음 초식은\n아직 알 수 없음"]
    var carried: Dictionary = f.get("carry",{}).get("player",{}).duplicate(true)
    if not carried.is_empty(): carried["remaining_ticks"] = maxi(0,int(carried.get("end_tick",t))-t)
    timeline.configure(definitions,plan,revealed,carried)
    timeline.selected_card = selected
    timeline.editable = not locked
    execute.disabled = locked or (plan.is_empty() and carried.is_empty())
    _render_cards()

func configure_opponent(id: String) -> void:
    stage.configure_opponent(id)
    for node_name in ["OpponentPortrait","OpponentFighter"]:
        var node := prep.get_node_or_null(node_name) as TextureRect
        if node != null:
            node.texture = SKIN.character("enemy",id,node_name.ends_with("Portrait"))
            node.material = SKIN.portrait_material() if node_name.ends_with("Portrait") else SKIN.standing_material("enemy",id)

func show_message(text: String) -> void:
    hint.text = text

func show_preparation() -> void:
    playing = false
    prep.show()
    movie.hide()
    _layout()

func play(result: Dictionary, before: Dictionary, committed: Array, revealed: Array) -> void:
    _initial_revealed=revealed.duplicate(true)
    _result = result
    plan = committed.duplicate(true)
    current_state = before
    _elapsed = 0.0
    _event_index = -1
    _actor_labels={"player":"대기","enemy":"미관찰"}
    _duration = maxf(0.1,float(result.state.frame.time_tick - before.frame.time_tick)*0.1)
    var carried: Dictionary = before.get("frame",{}).get("carry",{}).get("player",{}).duplicate(true)
    if not carried.is_empty(): carried["remaining_ticks"] = maxi(0,int(carried.get("end_tick",0))-int(before.frame.time_tick))
    movie_timeline.configure(definitions,plan,revealed,carried)
    movie_result.text = "서로의 움직임을 살핀다"
    movie_actions.text = "전 투 진 행"
    movie_player.text = "강호낭인\n" + _resources(before.player)
    movie_enemy.text = str(before.enemy.get("name","상대")) + "\n체력 ? / ?"
    stage.begin({"kind":"neutral","actor":"player","duration":0.5})
    _cue_start = 0.0
    _cue_end = 0.5
    playing = true
    paused = false
    next_button.visible = false
    pause_button.text = "잠시 멈춤"
    prep.hide()
    movie.show()
    _layout()

func _process(delta: float) -> void:
    if not playing or paused or suspended: return
    _elapsed = minf(_duration,_elapsed + delta*speed)
    var tick := _elapsed*10.0
    var events: Array = _result.get("events",[])
    while _event_index+1 < events.size() and int(events[_event_index+1].get("window_tick",0)) <= tick:
        _event_index += 1
        _show_event(events[_event_index])
    stage.sample(clampf((_elapsed-_cue_start)/maxf(0.1,_cue_end-_cue_start),0,1),reduced_motion)
    movie_timeline.playback_tick = tick
    movie_timeline.queue_redraw()
    movie_clock.text = "전 투 진 행\n%.1f / %.1f초" % [_elapsed,_duration]
    if _elapsed >= _duration:
        playing = false
        next_button.text = "비무 결과  〉" if _result.get("terminal",false) else "다음 열 초를 설계  〉"
        next_button.visible = true
        pause_button.text = "다시 보기"

func _pause_or_replay() -> void:
    if not playing:_replay();return
    paused=not paused
    pause_button.text="계속 보기" if paused else "잠시 멈춤"

func _replay() -> void:
    play(_result,current_state,plan,_initial_revealed)

func _show_event(event: Dictionary) -> void:
    if event.has("public_enemy_actions"):
        var revealed: Array=event.public_enemy_actions.duplicate(true)
        for action in revealed:
            action.start_tick=int(action.absolute_start_tick)-int(current_state.frame.time_tick)
            action.active_tick=int(action.absolute_active_tick)-int(current_state.frame.time_tick)
            action.end_tick=int(action.absolute_end_tick)-int(current_state.frame.time_tick)
        movie_timeline.public_enemy=revealed
        movie_timeline.queue_redraw()
    var actions: Array = event.get("actions",[])
    var lines := PackedStringArray()
    var best: Dictionary = {}
    for action in actions:
        var id := str(action.get("card_id", ""))
        var actor := str(action.get("actor",event.get("actor","player")))
        var def: Dictionary = definitions.get(id,{})
        var name_text:=str(action.get("card_name",def.get("name",id)))
        var phase_text: String=" · 선딜" if action.get("outcome")=="startup" else " · 후딜 완료" if action.get("outcome") in ["complete","completed"] else " · 발동"
        _actor_labels[actor]=name_text+phase_text
        if action.has("raw_damage"):_actor_labels[actor]+="  위력 %d" % int(action.raw_damage)
        elif action.has("clash_power"):_actor_labels[actor]+="  합 %d" % int(action.clash_power)
        lines.append(("나  " if actor=="player" else "상대  ")+name_text)
        if actor=="enemy" and action.has("start_tick"):
            var past: Dictionary=action.duplicate(true)
            past.start_tick=int(action.start_tick)-int(current_state.frame.time_tick)
            if action.has("active_tick"):past.active_tick=int(action.active_tick)-int(current_state.frame.time_tick)
            if action.has("end_tick"):past.end_tick=int(action.end_tick)-int(current_state.frame.time_tick)
            past.name=name_text
            var exists:=false
            for i in range(movie_timeline.public_enemy.size()):
                var known: Dictionary=movie_timeline.public_enemy[i]
                if (not str(past.get("uid","")).is_empty() and known.get("uid")==past.uid) or (known.get("card_id")==past.card_id and known.get("start_tick")==past.start_tick):
                    movie_timeline.public_enemy[i]=past
                    exists=true
                    break
            if not exists:movie_timeline.public_enemy.append(past)
        if best.is_empty() or str(action.get("outcome","")).contains("clash"): best=action.duplicate(true)
    if best.is_empty() and not str(event.get("card_id","")).is_empty():
        best=event.duplicate(true)
    if not best.is_empty() and event.get("type") != "action_complete":
        if best.get("outcome")=="startup":best.action_stage="preparation"
        var cue := MODEL.cue_for(best,definitions)
        _cue_start = _elapsed
        _cue_end = _cue_start + maxf(0.4,float(cue.get("duration",0.7)))
        stage.begin(cue)
    movie_actions.text = "나  %s     對     상대  %s" % [_actor_labels.player,_actor_labels.enemy]
    var delta := MODEL.delta(event.get("before",{}),event.get("after",{}))
    var outcome_names: Dictionary={"martial_completed":"초식 발동","completed":"후딜 완료","complete":"후딜 완료","startup":"선딜","clash_win":"합 승리","clash_loss":"합 밀림","clash_draw":"합 균형","move":"이동","hit":"적중","miss_range":"사거리 밖","miss_direction":"방향 빗나감","interrupted":"동작 중단","evade":"회피 성공","block":"방어","resource_insufficient":"자원 부족","observation":"관찰 완료","meditate":"운기","resources":"구간 완료"}
    var result_text:=str(event.get("text",""))
    for key in outcome_names:result_text=result_text.replace(key,outcome_names[key])
    if event.get("type") not in ["action_complete"] and event.get("outcome")!="startup":
        movie_result.text = result_text+"\n"+MODEL.changes(delta)
    if event.has("after"):
        movie_player.text = "강호낭인\n"+_resources(event.after.get("player",{}))

func _render_cards() -> void:
    if cards_host == null: return
    for child in cards_host.get_children(): child.queue_free()
    var ids: Array = []
    for id in definitions:
        var card: Dictionary = definitions[id]
        var ultimate := str(id).ends_with("star10") or str(card.get("source","")).contains("ultimate")
        if (current_tab=="basic" and str(card.get("source",""))=="basic") or (current_tab=="ultimate" and ultimate) or (current_tab=="martial" and card.get("source")=="martial_manual" and not ultimate): ids.append(id)
    if current_tab=="basic":
        var order: Array=["basic_move","basic_footwork","basic_guard","basic_evade","basic_quick_attack","basic_heavy_attack","basic_observe","basic_meditate","basic_stance","basic_palm"]
        ids.sort_custom(func(a,b):return order.find(a)<order.find(b))
    var scroll := ScrollContainer.new()
    scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    cards_host.add_child(scroll)
    var grid := GridContainer.new()
    grid.columns=5
    grid.add_theme_constant_override("h_separation",7)
    grid.add_theme_constant_override("v_separation",8)
    scroll.add_child(grid)
    for id in ids:
        var card: Dictionary = definitions[id]
        var button := preload("res://src/ui/frame/frame_card.gd").new()
        button.name = str(id)
        button.card_id = id
        button.custom_minimum_size=Vector2(143,168)
        button.theme=theme
        button.add_theme_stylebox_override("normal",SKIN.paper())
        if id==selected:
            var highlight:=StyleBoxFlat.new()
            highlight.bg_color=PAPER
            highlight.border_color=Color("bc873b")
            highlight.set_border_width_all(3)
            button.add_theme_stylebox_override("normal",highlight)
        grid.add_child(button)
        var illustration := TextureRect.new()
        illustration.texture = _illustration(card)
        illustration.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
        illustration.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        illustration.mouse_filter=Control.MOUSE_FILTER_IGNORE
        _place(button,illustration,Rect2(8,34,127,95))
        var title := _label(button,str(card.get("name",id)),Rect2(7,4,129,31),23)
        title.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
        var timing: Dictionary = card.get("frame_timing",{})
        _label(button,"%.1f초 · 기%d 내%d" % [float(timing.get("total",0))*0.1,int(card.get("stamina_cost",0)),int(card.get("internal_cost",0))],Rect2(5,131,134,32),18)
        button.pressed.connect(func():selected=id;timeline.selected_card=id;_render_cards())
    _detail()

func _detail() -> void:
    var card: Dictionary = definitions.get(selected,{})
    if card.is_empty(): details.text="기술을 선택하세요";return
    var t: Dictionary = card.get("frame_timing",{})
    details.text="[b]%s[/b]\n\n선딜  %.1f초\n발동  %.1f초\n후딜  %.1f초\n\n기력 %d · 내력 %d\n사거리 %s\n\n%s" % [card.get("name",""),float(t.get("startup",0))*0.1,float(t.get("active",0))*0.1,float(t.get("recovery",0))*0.1,int(card.get("stamina_cost",0)),int(card.get("internal_cost",0)),card.get("range_text","—"),card.get("frame_effect_text",card.get("effect_text",""))]

func _illustration(card: Dictionary) -> Texture2D:
    var spec: Dictionary = card.get("illustration",{})
    var path := str(spec.get("atlas",spec.get("path","")))
    if path.is_empty(): return null
    if not _textures.has(path): _textures[path] = load(path)
    var texture = _textures[path]
    if spec.has("region"):
        var r: Array = spec.region
        return SKIN.region(texture,Rect2(r[0],r[1],r[2],r[3]))
    return texture

func _fighter(role: String, rect: Rect2) -> void:
    var node := TextureRect.new()
    node.name="OpponentFighter" if role=="enemy" else "PlayerFighter"
    node.texture=SKIN.character(role)
    node.material=SKIN.standing_material(role)
    node.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    node.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE
    _place(prep,node,rect)

func _portrait(role: String, rect: Rect2) -> void:
    var node := TextureRect.new()
    node.name="OpponentPortrait" if role=="enemy" else "PlayerPortrait"
    node.texture=SKIN.character(role,"",true)
    node.material=SKIN.portrait_material()
    node.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    node.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE
    _place(prep,node,rect)

func _layout() -> void:
    for surface in [prep,movie]:
        if surface==null:continue
        var factor := minf(size.x/surface.size.x,size.y/surface.size.y)
        surface.scale=Vector2.ONE*factor
        surface.position=(size-surface.size*factor)*0.5

func _resources(actor: Dictionary) -> String:
    var h: Array = actor.get("health",[0,0])
    var s: Array = actor.get("stamina",[0,0])
    var n: Array = actor.get("internal",[0,0])
    return "체력  %d / %d\n기력  %d / %d\n내력  %d / %d" % [h[0],h[1],s[0],s[1],n[0],n[1]]

func _place(parent: Node,node: Control,rect: Rect2) -> void:
    node.position=rect.position
    node.size=rect.size
    parent.add_child(node)

func _panel(parent: Node,rect: Rect2,color: Color,border: int=1) -> Panel:
    var node:=Panel.new()
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE
    var box:=StyleBoxFlat.new()
    box.bg_color=color
    box.border_color=Color("8a7957")
    box.set_border_width_all(border)
    node.add_theme_stylebox_override("panel",box)
    _place(parent,node,rect)
    return node

func _label(parent: Node,text: String,rect: Rect2,point: int,color: Color=INK) -> Label:
    var node:=Label.new()
    node.text=text
    node.mouse_filter=Control.MOUSE_FILTER_IGNORE
    node.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    node.add_theme_font_size_override("font_size",point)
    node.add_theme_color_override("font_color",color)
    _place(parent,node,rect)
    return node

func _button(parent: Node,text: String,rect: Rect2,callback: Callable,point: int=23) -> Button:
    var node:=Button.new()
    node.text=text
    node.add_theme_font_size_override("font_size",point)
    node.pressed.connect(callback)
    _place(parent,node,rect)
    return node
