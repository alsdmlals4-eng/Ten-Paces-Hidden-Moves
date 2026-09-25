extends Control
## Approved key poses and brush texture; animation never writes combat state.
const DATA := "res://data/presentation/ink_combat_stage.json"
var catalog: Dictionary = {}
var textures := {}
var background: Texture2D
var hero: Texture2D
var brush: Texture2D
var pose := {"p":0,"e":0,"px":338.0,"py":622.0,"ex":968.0,"ey":590.0,"pr":0.0,"er":0.0,"zoom":1.0}
var entry_pose: Dictionary = {}
var cue: Dictionary = {}
var clock := 0.0
var progress := 0.0
var effect_time := -1.0
var reduced := false
var _world := Transform2D.IDENTITY
var opponent_id := "__unset__"
var unarmed_enemy := false
var _pose_blends := {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	catalog = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	background = load("res://assets/combat/ink_wuxia/background.png")
	hero = load("res://assets/combat/ink_wuxia/hero-clash.png")
	brush = load("res://assets/combat/ink_wuxia/ink-brush.png")
	for role in ["player","enemy"]:
		textures[role] = []
		for spec in catalog.poses[role]:
			textures[role].append(load(spec.path))
	entry_pose = pose.duplicate()

func configure_opponent(candidate_id: String) -> void:
	if candidate_id == opponent_id:
		return
	opponent_id = candidate_id
	var profile: Dictionary = {}
	if candidate_id in ["","masked_baekmujin"]:
		profile = JSON.parse_string(FileAccess.get_file_as_string("res://data/presentation/masked_ink_opponent.json"))
	elif candidate_id == "slot1_dogyeom":
		profile = JSON.parse_string(FileAccess.get_file_as_string("res://data/presentation/dogyeom_ink_opponent.json"))
	unarmed_enemy = bool(profile.get("unarmed",false))
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	catalog.poses.enemy = profile.poses if not profile.is_empty() else original.poses.enemy
	textures.enemy = []
	for spec in catalog.poses.enemy:
		textures.enemy.append(load(spec.path))
	hero = null if unarmed_enemy else load(profile.hero if not profile.is_empty() else "res://assets/combat/ink_wuxia/hero-clash.png")

func begin(value: Dictionary) -> void:
	entry_pose = pose.duplicate()
	cue = value
	progress = 0.0
	for role in ["player", "enemy"]:
		var index := int(pose.p if role == "player" else pose.e)
		_pose_blends[role] = {"from":index, "to":index, "at":0.0, "weight":1.0}

func sample(value: float, reduce_motion: bool) -> void:
	progress = clampf(value,0.0,1.0)
	reduced = reduce_motion
	clock += 1.0 / 60.0
	effect_time = -1.0
	var kind := str(cue.get("kind", "neutral"))
	var enemy: bool = cue.get("actor") == "enemy"
	if reduced:
		pose = entry_pose.duplicate()
		pose.zoom = 1.0
		_pose_blends.clear()
		queue_redraw()
		return
	if kind == "clash":
		effect_time = lerpf(0.63,2.73,progress)
		pose = _key_pose(effect_time)
	elif kind in ["attack","block","evade","miss"]:
		var follows := bool(cue.get("event", {}).get("motion_from_clash", false))
		effect_time = lerpf(2.73,4.12,progress) if follows else lerpf(1.04,1.61,clampf(progress / 0.68,0,1))
		pose = _key_pose(effect_time)
		if not follows:
			pose.e = 4 if kind == "block" else 6 if kind == "attack" and progress > 0.62 else 8
			if progress > 0.68:
				pose.p = 8
				pose.px = lerpf(float(pose.px),float(entry_pose.px),_ease((progress-0.68)/0.32))
		if kind in ["evade","miss"]:
			pose.ex += 100.0 * sin(progress*PI)
			pose.e = 2 if kind == "evade" and progress < 0.75 else 8
		if cue.get("family", "").contains("palm") or cue.get("family") in ["throw","spear","body"]:
			pose.p = 5 if progress > 0.35 and progress < 0.78 else 1 if progress < 0.35 else 8
	elif kind == "preparation":
		pose = entry_pose.duplicate()
		pose["e" if enemy else "p"] = 1
		pose.zoom = lerpf(float(entry_pose.zoom),1.025,_ease(progress))
	elif kind == "pressure":
		pose = entry_pose.duplicate()
		pose["e" if enemy else "p"] = 1 if progress < 0.55 else 5
		pose.zoom = lerpf(1.0,1.025,sin(progress*PI))
	elif kind == "move":
		pose = entry_pose.duplicate()
		pose["e" if enemy else "p"] = 2 if progress < 0.72 else 8
		var event: Dictionary = cue.get("event", {})
		var initial: Dictionary = event.get("positions_before_bundle", {})
		var direction := signf(float(event.get("actor_tile_after_action",initial.get(cue.actor,0))) - float(initial.get(cue.actor,0)))
		pose["ex" if enemy else "px"] += direction * 60.0 * _ease(progress)
	else:
		pose = entry_pose.duplicate()
		pose["e" if enemy else "p"] = 8
		pose.zoom = lerpf(float(entry_pose.zoom),1.0,_ease(progress))
	# A losing clash does not fabricate a winner's follow-through.
	if enemy and kind in ["clash","attack","block","evade","miss"]:
		var p := int(pose.p)
		pose.p = pose.e
		pose.e = p
		var x := float(pose.px)
		pose.px = 1280.0-float(pose.ex)
		pose.ex = 1280.0-x
		var lean := float(pose.pr)
		pose.pr = -float(pose.er)
		pose.er = -lean
	# Blend roots from the prior action; no neutral-pose or position snap per slot.
	var enter := _ease(minf(progress/0.28,1.0))
	for key in ["px","py","ex","ey","pr","er","zoom"]:
		pose[key] = lerpf(float(entry_pose[key]),float(pose[key]),enter)
	_blend_pose_changes()
	queue_redraw()

func _blend_pose_changes() -> void:
	# Short, foot-aligned overlaps bridge ink key drawings without delaying events.
	var transition := clampf(0.075 / maxf(float(cue.get("duration", 1.0)), 0.1), 0.025, 0.16)
	for role in ["player", "enemy"]:
		var index := int(pose.p if role == "player" else pose.e)
		if not _pose_blends.has(role):
			_pose_blends[role] = {"from":index, "to":index, "at":progress, "weight":1.0}
		var blend: Dictionary = _pose_blends[role]
		if int(blend.to) != index:
			blend.from = blend.to
			blend.to = index
			blend.at = progress
		blend.weight = _ease(clampf((progress-float(blend.at))/transition, 0, 1)) if blend.from != blend.to else 1.0

func close_shot_opacity() -> float:
	if reduced or hero == null or cue.get("kind") != "clash" or not cue.get("contact", false): return 0.0
	return smoothstep(2.27, 2.48, effect_time) * (1.0-smoothstep(2.55, 2.73, effect_time))

func close_shot_rect() -> Rect2:
	var source := hero.get_size() if hero != null else Vector2(1280,720)
	var cover := source * maxf(size.x/source.x, size.y/source.y)
	return Rect2((size-cover)*0.5, cover)

func _key_pose(t: float) -> Dictionary:
	var keys: Array = catalog.keyframes
	var i := 0
	while i < keys.size()-2 and float(keys[i+1][0]) <= t:
		i += 1
	var a: Array = keys[i]
	var b: Array = keys[i+1]
	var u := _ease(clampf((t-float(a[0]))/maxf(0.001,float(b[0])-float(a[0])),0,1))
	return {"p":int(a[1]),"e":int(a[2]),"px":lerpf(a[3],b[3],u),"py":lerpf(a[4],b[4],u),"ex":lerpf(a[5],b[5],u),"ey":lerpf(a[6],b[6],u),"pr":lerpf(a[7],b[7],u),"er":lerpf(a[8],b[8],u),"zoom":lerpf(a[9],b[9],u)}

func _ease(u: float) -> float:
	return u*u*(3.0-2.0*u)

func _draw() -> void:
	if background == null or size.y <= 0:
		return
	var scale_factor := minf(size.x/1280.0,size.y/720.0)
	var offset := (size-Vector2(1280,720)*scale_factor)*0.5
	var zoom := 1.0 if reduced else float(pose.zoom)
	# The scenery follows the same camera centre and zoom as the fighters.
	draw_set_transform_matrix(Transform2D(0, Vector2.ONE*zoom, 0, size*0.5*(1.0-zoom)))
	draw_texture_rect(background,Rect2(Vector2.ZERO,size),false,Color.WHITE)
	_world = Transform2D(0,Vector2.ONE*scale_factor*zoom,0,offset+Vector2(640,360)*scale_factor*(1.0-zoom))
	draw_set_transform_matrix(_world)
	_actor("enemy",int(pose.e),Vector2(pose.ex,pose.ey),1.10,float(pose.er))
	_actor("player",int(pose.p),Vector2(pose.px,pose.py),1.22,float(pose.pr))
	draw_set_transform_matrix(_world)
	if not reduced and cue.get("kind") == "pressure":
		var alpha := sin(progress*PI)*0.65
		var origin := _weapon_point(str(cue.actor),"hilt")
		var direction := -1.0 if cue.actor == "enemy" else 1.0
		draw_texture_rect(brush,Rect2(origin+Vector2(0,-34),Vector2(direction*190*progress,68)),false,Color(1,1,1,alpha))
	if not reduced and effect_time >= 0:
		for swing in catalog.swings:
			_stroke(swing)
		if cue.get("kind") == "clash" and cue.get("contact", false):
			for hit in catalog.contacts:
				var elapsed := effect_time-float(hit)
				if elapsed >= 0 and elapsed < 0.20:
					var point := _contact_point()
					_burst(point,1.0-elapsed/0.20)
		elif cue.get("contact", false) and progress > 0.60 and progress < 0.77:
			_burst(_weapon_point("enemy" if cue.actor == "player" else "player", "hilt"),1.0-(progress-0.60)/0.17)
		if cue.get("family") in ["palm","throw","spear","body"] and cue.get("kind") in ["attack","block","evade","miss"] and progress > 0.35 and progress < 0.85:
			var origin := _weapon_point(str(cue.actor),"hilt")
			var target := _weapon_point("enemy" if cue.actor == "player" else "player","hilt")
			var reach := clampf((progress-0.35)/0.30,0,1)
			var tip := origin.lerp(target,reach)
			var side := (tip-origin).normalized().orthogonal()*22
			draw_polygon(PackedVector2Array([origin-side,origin+side,tip+side,tip-side]),PackedColorArray([Color(1,1,1,0.75*(1.0-clampf((progress-0.65)/0.20,0,1)))]),PackedVector2Array([Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(1,0)]),brush)
	var close_alpha := close_shot_opacity()
	if close_alpha > 0.0:
		# A contact-led dissolve exposes the continuing pose again before recovery.
		draw_set_transform_matrix(Transform2D.IDENTITY)
		draw_texture_rect(hero,close_shot_rect(),false,Color(1,1,1,close_alpha))
	draw_set_transform_matrix(Transform2D.IDENTITY)

func _actor(role: String, index: int, foot: Vector2, actor_scale: float, angle: float) -> void:
	var transform := Transform2D(deg_to_rad(angle),Vector2.ONE*actor_scale,0,foot)
	draw_set_transform_matrix(_world*transform)
	var blend: Dictionary = _pose_blends.get(role, {"from":index,"to":index,"weight":1.0})
	var weight := float(blend.weight)
	if int(blend.from) != index and weight < 1.0:
		var previous: Dictionary = catalog.poses[role][int(blend.from)]
		draw_texture(textures[role][int(blend.from)], -Vector2(previous.foot[0],previous.foot[1]), Color(1,1,1,1.0-weight))
	var spec: Dictionary = catalog.poses[role][index]
	var anchor := Vector2(spec.foot[0],spec.foot[1])
	draw_texture(textures[role][index],-anchor,Color(1,1,1,weight))

func _weapon_point(role: String, point_name: String, state: Dictionary = {}) -> Vector2:
	var s: Dictionary = pose if state.is_empty() else state
	var player := role == "player"
	var spec: Dictionary = catalog.poses[role][int(s.p if player else s.e)]
	var point := Vector2(spec[point_name][0]-spec.foot[0],spec[point_name][1]-spec.foot[1])
	return Vector2(s.px,s.py)+point.rotated(deg_to_rad(float(s.pr)))*1.22 if player else Vector2(s.ex,s.ey)+point.rotated(deg_to_rad(float(s.er)))*1.10

func _contact_point() -> Vector2:
	var ph := _weapon_point("player","hilt")
	var pt := _weapon_point("player","tip")
	var eh := _weapon_point("enemy","hilt")
	var et := _weapon_point("enemy","tip")
	var cross = Geometry2D.segment_intersects_segment(ph,pt,eh,et)
	return cross if cross != null else (pt+et)*0.5

func _stroke(swing: Dictionary) -> void:
	var a := float(swing.a)
	var b := float(swing.b)
	if effect_time < a or effect_time > b+0.20:
		return
	var side := str(swing.side)
	# Solo attacks have only the acting weapon's trail, never a fictitious counterattack.
	if cue.kind != "clash" and side != "player":
		return
	if cue.kind != "clash" and cue.get("family") in ["palm","throw","spear","body"]:
		return
	var role := side
	if cue.actor == "enemy":
		role = "enemy" if side == "player" else "player"
	var from_state := _key_pose(a)
	var from := _weapon_point(side,"tip",from_state)
	if cue.actor == "enemy":
		from.x = 1280.0-from.x
	var to := _weapon_point(role,"tip")
	var control := (from+to)*0.5+Vector2(-35 if role == "player" else 35,-55)
	var fade := 1.0-clampf((effect_time-b)/0.20,0,1)
	var width := float(swing.width)*2.4
	for i in range(24):
		var u := float(i)/24.0
		var v := float(i+1)/24.0
		var start := _bezier(from,control,to,u)
		var end := _bezier(from,control,to,v)
		var normal := (end-start).normalized().orthogonal()*width*0.5
		draw_polygon(PackedVector2Array([start-normal,start+normal,end+normal,end-normal]),PackedColorArray([Color(1,1,1,fade*0.88)]),PackedVector2Array([Vector2(u,0),Vector2(u,1),Vector2(v,1),Vector2(v,0)]),brush)

func _bezier(a: Vector2,b: Vector2,c: Vector2,t: float) -> Vector2:
	return a*(1-t)*(1-t)+2*(1-t)*t*b+t*t*c

func _burst(point: Vector2, alpha: float) -> void:
	for i in range(18):
		var angle := float(i)*2.39996
		var reach := 16.0+fmod(float(i)*19.0,52.0)
		var v := Vector2(cos(angle),sin(angle))*reach
		draw_line(point+v*0.16,point+v,Color(0.13,0.12,0.10,alpha),2 if i%3 == 0 else 1,true)
	draw_line(point-Vector2(14,19),point+Vector2(14,19),Color(0.92,0.85,0.64,alpha),3,true)
