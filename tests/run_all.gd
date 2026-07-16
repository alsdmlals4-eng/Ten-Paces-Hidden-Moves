extends SceneTree

const CombatSimulator = preload("res://src/combat/combat_simulator.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
	print("Ten Paces combat tests · Godot 4.7.1 target")
	_test_initial_state()
	_test_ai_is_deterministic()
	_test_clash_and_momentum_caps()
	_test_guard_charge()
	_test_ultimate_valid_spend()
	_test_ultimate_out_of_range_not_spent()
	_test_second_action_cancelled_on_death()
	_test_invalid_defense_does_not_apply()
	_test_round_recovery()
	print("Checks: %d · Failures: %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _expect(condition: bool, message: String) -> void:
	checks += 1
	if condition: print("PASS · " + message)
	else:
		failures += 1
		push_error("FAIL · " + message)

func _test_initial_state() -> void:
	var sim = CombatSimulator.new()
	_expect(sim.distance() == 2, "초기 거리는 2")
	_expect(sim.player.position == 4 and sim.enemy.position == 6, "초기 위치는 4번과 6번")
	_expect(sim.player.momentum == 0, "전투 시작 기세는 0")
	_expect(not sim.can_queue_action("player", "ultimate").ok, "기세 부족 시 절초 선택 불가")

func _test_ai_is_deterministic() -> void:
	var a = CombatSimulator.new(77)
	var b = CombatSimulator.new(77)
	_expect(a.plan_ai_pair() == b.plan_ai_pair(), "같은 시드와 공개 상태의 AI 두 수는 동일")

func _test_clash_and_momentum_caps() -> void:
	var sim = CombatSimulator.new()
	sim.player.position = 5
	sim.enemy.position = 6
	var result = sim.resolve_pair(["attack", "attack"], ["attack", "attack"])
	_expect(sim.player.hp == 20 and sim.enemy.hp == 20, "동률 합은 체력 피해 없음")
	_expect(sim.player.momentum == 3 and sim.enemy.momentum == 3, "한 묶음 기세 획득은 최대 3")
	_expect(result.events.size() > 0, "구조화 이벤트 반환")

func _test_guard_charge() -> void:
	var sim = CombatSimulator.new()
	sim.player.position = 5
	sim.enemy.position = 6
	sim.resolve_pair(["guard", "meditate"], ["attack", "meditate"])
	_expect(sim.player.hp == 19, "막기가 기본 피해 3을 1로 경감")
	_expect(sim.player.momentum == 3, "막기 성공·피격·묶음 완료가 상한 3까지 충전")

func _test_ultimate_valid_spend() -> void:
	var sim = CombatSimulator.new()
	sim.player.position = 5
	sim.enemy.position = 6
	sim.player.momentum = 6
	sim.resolve_pair(["ultimate", "meditate"], ["guard", "meditate"])
	_expect(sim.player.momentum == 1, "유효한 절초는 전량 소모 후 묶음 완료로 1 충전")
	_expect(sim.enemy.hp == 15, "절초 7 피해가 막기 2로 줄어 5 피해")

func _test_ultimate_out_of_range_not_spent() -> void:
	var sim = CombatSimulator.new()
	sim.player.position = 2
	sim.enemy.position = 8
	sim.player.momentum = 6
	sim.resolve_pair(["ultimate", "meditate"], ["guard", "meditate"])
	_expect(sim.player.momentum == 6, "사거리 불성립 절초는 기세를 소모하지 않음")

func _test_second_action_cancelled_on_death() -> void:
	var sim = CombatSimulator.new()
	sim.player.position = 5
	sim.enemy.position = 6
	sim.enemy.hp = 1
	sim.resolve_pair(["attack", "meditate"], ["guard", "attack"])
	_expect(sim.battle_over and sim.winner == "player", "1수에서 체력 0이면 전투 종료")
	_expect(sim.player.hp == 20, "종료 뒤 상대 2수는 실행되지 않음")

func _test_invalid_defense_does_not_apply() -> void:
	var sim = CombatSimulator.new()
	sim.player.position = 5
	sim.enemy.position = 6
	sim.player.stamina = 0
	sim.resolve_pair(["guard", "meditate"], ["attack", "meditate"])
	_expect(sim.player.hp == 17, "기력 부족 막기는 피해를 경감하지 않음")
	_expect(sim.player.stamina == 3, "유효한 둘째 명상만 회복을 적용")

func _test_round_recovery() -> void:
	var sim = CombatSimulator.new()
	for index in range(5): sim.resolve_pair(["meditate", "meditate"], ["meditate", "meditate"])
	_expect(sim.round_index == 2 and sim.pair_index == 1, "5개 묶음 뒤 다음 라운드")
	_expect(sim.player.ap == sim.player.max_ap, "라운드 종료 행동력 전부 회복")
