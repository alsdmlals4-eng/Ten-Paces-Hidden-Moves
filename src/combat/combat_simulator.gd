class_name CombatSimulator
extends RefCounted

const BOARD_MIN := 1
const BOARD_MAX := 10
const PAIRS_PER_ROUND := 5
const MOMENTUM_MAX := 6
const MOMENTUM_PER_TIMING_CAP := 2
const MOMENTUM_PER_PAIR_CAP := 3

const ACTION_ORDER := ["approach", "retreat", "attack", "guard", "evade", "meditate", "ultimate"]
const ACTIONS := {
	"approach": {"name":"접근", "kind":"move", "ap":1, "stamina":1, "internal":0, "description":"상대 방향으로 1칸 이동한다."},
	"retreat": {"name":"후퇴", "kind":"move", "ap":1, "stamina":1, "internal":0, "description":"상대 반대 방향으로 1칸 이동한다."},
	"attack": {"name":"검격", "kind":"attack", "ap":1, "stamina":2, "internal":0, "range":1, "power":3, "clash":3, "description":"거리 1의 기본 공격. 쌍방 공격이면 합을 겨룬다."},
	"guard": {"name":"막기", "kind":"guard", "ap":1, "stamina":1, "internal":0, "guard":2, "description":"이번 타이밍의 단독 공격 피해를 2 줄인다."},
	"evade": {"name":"회피보", "kind":"evade", "ap":1, "stamina":1, "internal":1, "description":"상대 반대 방향으로 1칸 이동해 사거리를 벗어난다."},
	"meditate": {"name":"명상", "kind":"meditate", "ap":1, "stamina":0, "internal":0, "stamina_gain":3, "internal_gain":1, "description":"기력 3과 내공 1을 회복한다."},
	"ultimate": {"name":"절초 · 유성일섬", "kind":"ultimate", "ap":2, "stamina":3, "internal":2, "range":1, "power":7, "clash":7, "description":"기세 6에서 예약 가능. 유효한 공격 성립 시 기세를 전량 소모한다."}
}

var rng := RandomNumberGenerator.new()
var player := {}
var enemy := {}
var round_index := 1
var pair_index := 1
var timing_index := 1
var battle_over := false
var winner := ""
var last_events := []

func _init(seed: int = 20260716) -> void:
	reset(seed)

func reset(seed: int = 20260716) -> void:
	rng.seed = seed
	player = _new_actor("player", "플레이어", 4)
	enemy = _new_actor("enemy", "상대", 6)
	round_index = 1
	pair_index = 1
	timing_index = 1
	battle_over = false
	winner = ""
	last_events = []

func _new_actor(actor_id: String, display_name: String, position: int) -> Dictionary:
	return {"id":actor_id, "name":display_name, "position":position, "hp":20, "max_hp":20, "ap":6, "max_ap":6, "stamina":12, "max_stamina":12, "internal":6, "max_internal":6, "momentum":0, "ultimate_unlocked":true, "ultimate_reserved":false}

func distance() -> int:
	return abs(int(player.position) - int(enemy.position))

func get_actor(actor_id: String) -> Dictionary:
	return player if actor_id == "player" else enemy

func can_queue_action(actor_id: String, action_id: String) -> Dictionary:
	var actor := get_actor(actor_id)
	var action: Dictionary = ACTIONS.get(action_id, {})
	if action.is_empty(): return {"ok":false, "reason":"알 수 없는 행동"}
	if battle_over or int(actor.hp) <= 0: return {"ok":false, "reason":"전투 종료"}
	if action_id == "ultimate":
		if not bool(actor.ultimate_unlocked): return {"ok":false, "reason":"핵심무공 10성 미해금"}
		if int(actor.momentum) < MOMENTUM_MAX: return {"ok":false, "reason":"절초 기세 부족 (%d/%d)" % [actor.momentum, MOMENTUM_MAX]}
	return {"ok":true, "reason":""}

func plan_ai_pair() -> Array:
	if battle_over: return []
	var first := _choose_ai(distance())
	var predicted := int(enemy.position)
	if first == "approach": predicted = _move_toward(predicted, int(player.position))
	elif first == "retreat" or first == "evade": predicted = _move_away(predicted, int(player.position))
	return [first, _choose_ai(abs(predicted - int(player.position)))]

func _choose_ai(current_distance: int) -> String:
	if int(enemy.momentum) >= MOMENTUM_MAX and current_distance <= 1: return "ultimate"
	if int(enemy.stamina) <= 2 or int(enemy.internal) <= 0: return "meditate"
	if current_distance > 1: return "approach"
	var roll := rng.randi_range(0, 99)
	if roll < 45: return "attack"
	if roll < 65: return "guard"
	if roll < 82: return "evade"
	if roll < 92: return "retreat"
	return "meditate"

func resolve_pair(player_pair: Array, enemy_pair: Array) -> Dictionary:
	last_events = []
	if battle_over: return _snapshot()
	if player_pair.size() != 2 or enemy_pair.size() != 2:
		_event("system", "invalid_pair", "양측 모두 두 수를 잠가야 합니다.")
		return _snapshot()
	player.ultimate_reserved = player_pair.has("ultimate")
	enemy.ultimate_reserved = enemy_pair.has("ultimate")
	_event("system", "pair_revealed", "양측의 두 수를 동시에 공개했습니다.")
	_event("player", "reveal", "플레이어: %s → %s" % [_name(player_pair[0]), _name(player_pair[1])])
	_event("enemy", "reveal", "상대: %s → %s" % [_name(enemy_pair[0]), _name(enemy_pair[1])])
	var pair_gain := {"player":0, "enemy":0}
	for slot in range(2):
		if battle_over:
			_event("system", "action_cancelled", "%d수는 전투 종료로 취소되었습니다." % [slot + 1])
			break
		_resolve_timing(String(player_pair[slot]), String(enemy_pair[slot]), {"player":0, "enemy":0}, pair_gain, slot + 1)
		timing_index += 1
		_check_battle_end()
	if not battle_over:
		_gain(player, 1, "2수 묶음 완료", {"player":0,"enemy":0}, pair_gain, false)
		_gain(enemy, 1, "2수 묶음 완료", {"player":0,"enemy":0}, pair_gain, false)
	player.ultimate_reserved = false
	enemy.ultimate_reserved = false
	pair_index += 1
	if pair_index > PAIRS_PER_ROUND and not battle_over: _finish_round()
	return _snapshot()

func _resolve_timing(p_id: String, e_id: String, timing_gain: Dictionary, pair_gain: Dictionary, slot: int) -> void:
	var p_action: Dictionary = ACTIONS.get(p_id, {})
	var e_action: Dictionary = ACTIONS.get(e_id, {})
	_event("system", "timing_start", "타이밍 %d · %d수 해상" % [timing_index, slot])
	var p_valid := _pay(player, p_action, p_id)
	var e_valid := _pay(enemy, e_action, e_id)
	var p_before := int(player.position)
	var e_before := int(enemy.position)
	if p_valid: player.position = _destination(p_before, e_before, p_id)
	if e_valid: enemy.position = _destination(e_before, p_before, e_id)
	if int(player.position) != p_before: _event("player", "move", "플레이어가 %d번 칸으로 이동했습니다." % player.position)
	if int(enemy.position) != e_before: _event("enemy", "move", "상대가 %d번 칸으로 이동했습니다." % enemy.position)
	var p_attack := p_valid and _is_attack(p_action) and _in_range(p_action)
	var e_attack := e_valid and _is_attack(e_action) and _in_range(e_action)
	if p_valid and _is_attack(p_action) and not p_attack: _event("player", "invalid_action", "%s: 이동 후 사거리 밖입니다." % _name(p_id))
	if e_valid and _is_attack(e_action) and not e_attack: _event("enemy", "invalid_action", "%s: 이동 후 사거리 밖입니다." % _name(e_id))
	if p_attack and p_id == "ultimate": _spend_ultimate(player)
	if e_attack and e_id == "ultimate": _spend_ultimate(enemy)
	if p_attack and e_attack:
		_resolve_clash(p_id, e_id, timing_gain, pair_gain)
	elif p_attack:
		_resolve_single(player, enemy, p_action, p_id, e_id, e_valid, timing_gain, pair_gain)
	elif e_attack:
		_resolve_single(enemy, player, e_action, e_id, p_id, p_valid, timing_gain, pair_gain)
	else:
		if p_valid: _resolve_non_attack(player, p_action, p_id)
		if e_valid: _resolve_non_attack(enemy, e_action, e_id)
		_check_evade(player, p_valid, p_id, e_valid, e_id, p_before, e_before, timing_gain, pair_gain)
		_check_evade(enemy, e_valid, e_id, p_valid, p_id, e_before, p_before, timing_gain, pair_gain)

func _pay(actor: Dictionary, action: Dictionary, action_id: String) -> bool:
	if action.is_empty(): return false
	if action_id == "ultimate" and int(actor.momentum) < MOMENTUM_MAX:
		_event(String(actor.id), "invalid_action", "%s: 절초 기세가 부족합니다." % actor.name)
		return false
	for key in ["ap", "stamina", "internal"]:
		if int(actor[key]) < int(action[key]):
			_event(String(actor.id), "invalid_action", "%s: %s이 부족합니다." % [actor.name, key])
			return false
	actor.ap -= int(action.ap)
	actor.stamina -= int(action.stamina)
	actor.internal -= int(action.internal)
	return true

func _destination(own: int, other: int, action_id: String) -> int:
	if action_id == "approach": return _move_toward(own, other)
	if action_id == "retreat" or action_id == "evade": return _move_away(own, other)
	return own

func _move_toward(own: int, other: int) -> int:
	if own == other: return own
	return clampi(own + signi(other - own), BOARD_MIN, BOARD_MAX)

func _move_away(own: int, other: int) -> int:
	var direction := signi(own - other)
	if direction == 0: direction = -1 if own > 5 else 1
	return clampi(own + direction, BOARD_MIN, BOARD_MAX)

func _is_attack(action: Dictionary) -> bool:
	return String(action.get("kind", "")) in ["attack", "ultimate"]

func _in_range(action: Dictionary) -> bool:
	return distance() <= int(action.get("range", -1))

func _spend_ultimate(actor: Dictionary) -> void:
	actor.momentum = 0
	actor.ultimate_reserved = false
	_event(String(actor.id), "ultimate_spent", "%s의 절초 기세가 전량 소모되었습니다." % actor.name)

func _resolve_clash(p_id: String, e_id: String, timing_gain: Dictionary, pair_gain: Dictionary) -> void:
	var p_value := int(ACTIONS[p_id].clash)
	var e_value := int(ACTIONS[e_id].clash)
	_gain(player, 1, "합 참여", timing_gain, pair_gain)
	_gain(enemy, 1, "합 참여", timing_gain, pair_gain)
	_event("system", "clash", "합 발생 · 플레이어 %d 대 상대 %d" % [p_value, e_value])
	if p_value == e_value:
		_event("system", "clash_draw", "합 무승부 · 체력 피해 없음")
	elif p_value > e_value:
		_damage(enemy, p_value - e_value, "합 패배")
		_gain(player, 1, "합 승리", timing_gain, pair_gain)
		_gain(enemy, 1, "피격 버팀", timing_gain, pair_gain)
	else:
		_damage(player, e_value - p_value, "합 패배")
		_gain(enemy, 1, "합 승리", timing_gain, pair_gain)
		_gain(player, 1, "피격 버팀", timing_gain, pair_gain)

func _resolve_single(attacker: Dictionary, defender: Dictionary, action: Dictionary, attack_id: String, defend_id: String, defend_valid: bool, timing_gain: Dictionary, pair_gain: Dictionary) -> void:
	var damage := int(action.power)
	if defend_valid and defend_id == "guard":
		var reduced := min(damage, int(ACTIONS.guard.guard))
		damage -= reduced
		if reduced > 0:
			_event(String(defender.id), "guard", "%s가 피해 %d을 막았습니다." % [defender.name, reduced])
			_gain(defender, 1, "막기 성공", timing_gain, pair_gain)
	_event(String(attacker.id), "attack", "%s가 %s을 사용했습니다." % [attacker.name, _name(attack_id)])
	if damage > 0:
		_damage(defender, damage, "단독 공격")
		_gain(defender, 1, "피격 버팀", timing_gain, pair_gain)
	else:
		_event(String(defender.id), "no_damage", "%s가 피해를 전부 막았습니다." % defender.name)

func _resolve_non_attack(actor: Dictionary, action: Dictionary, action_id: String) -> void:
	if action_id != "meditate": return
	var s_before := int(actor.stamina)
	var i_before := int(actor.internal)
	actor.stamina = mini(int(actor.max_stamina), s_before + int(action.stamina_gain))
	actor.internal = mini(int(actor.max_internal), i_before + int(action.internal_gain))
	_event(String(actor.id), "meditate", "%s가 명상해 기력 %d, 내공 %d을 회복했습니다." % [actor.name, int(actor.stamina)-s_before, int(actor.internal)-i_before])

func _check_evade(actor: Dictionary, own_valid: bool, own_id: String, opposing_valid: bool, opposing_id: String, own_before: int, opposing_before: int, timing_gain: Dictionary, pair_gain: Dictionary) -> void:
	if not own_valid or not opposing_valid or own_id != "evade" or not _is_attack(ACTIONS.get(opposing_id, {})): return
	var attack: Dictionary = ACTIONS[opposing_id]
	if abs(own_before - opposing_before) <= int(attack.range) and distance() > int(attack.range):
		_event(String(actor.id), "evade", "%s가 회피보로 공격 사거리를 벗어났습니다." % actor.name)
		_gain(actor, 1, "회피 성공", timing_gain, pair_gain)

func _damage(actor: Dictionary, amount: int, reason: String) -> void:
	actor.hp = maxi(0, int(actor.hp) - amount)
	_event(String(actor.id), "hit", "%s가 %d 피해를 받았습니다. (%s)" % [actor.name, amount, reason])

func _gain(actor: Dictionary, requested: int, reason: String, timing_gain: Dictionary, pair_gain: Dictionary, use_timing_cap: bool = true) -> void:
	if requested <= 0 or int(actor.momentum) >= MOMENTUM_MAX: return
	var actor_id := String(actor.id)
	var timing_used := int(timing_gain.get(actor_id, 0))
	var pair_used := int(pair_gain.get(actor_id, 0))
	var timing_room := MOMENTUM_PER_TIMING_CAP - timing_used if use_timing_cap else requested
	var granted := mini(requested, mini(timing_room, mini(MOMENTUM_PER_PAIR_CAP - pair_used, MOMENTUM_MAX - int(actor.momentum))))
	if granted <= 0: return
	actor.momentum += granted
	if use_timing_cap: timing_gain[actor_id] = timing_used + granted
	pair_gain[actor_id] = pair_used + granted
	_event(actor_id, "momentum", "%s: 절초 기세 +%d · %s (%d/%d)" % [actor.name, granted, reason, actor.momentum, MOMENTUM_MAX])
	if int(actor.momentum) == MOMENTUM_MAX: _event(actor_id, "ultimate_ready", "%s: 절초 사용 가능" % actor.name)

func _finish_round() -> void:
	pair_index = 1
	round_index += 1
	for actor in [player, enemy]:
		actor.ap = int(actor.max_ap)
		actor.stamina = mini(int(actor.max_stamina), int(actor.stamina) + 2)
		actor.internal = mini(int(actor.max_internal), int(actor.internal) + 1)
	_event("system", "round_end", "라운드 종료 · 행동력 전부, 기력 2, 내공 1 회복")

func _check_battle_end() -> void:
	if int(player.hp) <= 0 and int(enemy.hp) <= 0: winner = "draw"
	elif int(enemy.hp) <= 0: winner = "player"
	elif int(player.hp) <= 0: winner = "enemy"
	else: return
	battle_over = true
	_event("system", "battle_end", "전투 종료 · %s" % winner_text())

func winner_text() -> String:
	if winner == "player": return "플레이어 승리"
	if winner == "enemy": return "상대 승리"
	if winner == "draw": return "무승부"
	return "진행 중"

func momentum_state(actor: Dictionary) -> String:
	if not bool(actor.ultimate_unlocked): return "미해금"
	if bool(actor.ultimate_reserved): return "발동 예약"
	if int(actor.momentum) >= MOMENTUM_MAX: return "절초 가능"
	return "축적 중"

func _name(action_id: String) -> String:
	return String(ACTIONS.get(action_id, {}).get("name", action_id))

func _event(actor_id: String, event_type: String, message: String) -> void:
	last_events.append({"actor":actor_id, "type":event_type, "message":message, "round":round_index, "pair":pair_index, "timing":timing_index})

func _snapshot() -> Dictionary:
	return {"events":last_events.duplicate(true), "player":player.duplicate(true), "enemy":enemy.duplicate(true), "round":round_index, "pair":pair_index, "timing":timing_index, "battle_over":battle_over, "winner":winner}
