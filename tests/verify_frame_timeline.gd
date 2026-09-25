extends SceneTree

const ENGINE = preload("res://src/combat/frame_timeline_engine.gd")
const HUD_PATH = "res://data/combat/combat_hud_preview.json"
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
    var engine = ENGINE.new()
    _check(engine.configure([], {}, [], {}, {}), "canonical empty martial loadouts configure")
    var state: Dictionary = engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string(HUD_PATH)), 4, 5)
    _check(state.has("frame"), "new combat exposes a serialized integer timeline")
    _check(not engine.validate_plan([], state).ok, "empty plan is rejected")
    _check(not engine.validate_plan([_plan("basic_quick_attack", 0), _plan("basic_guard", 2)], state).ok, "same actor startup/active/recovery overlap is rejected")
    _check(not engine.validate_plan([_plan("basic_quick_attack", 100)], state).ok, "action cannot start beyond current 100 tick window")
    _check(not engine.validate_plan([_plan("not_a_card", 0)], state).ok, "unknown card cannot enter a plan")
    _check(not engine.validate_plan([{"card_id": "basic_quick_attack", "start_tick": 0.5}], state).ok, "subtick placement is rejected")
    var result: Dictionary = engine.resolve_window(_fixture(state, []) if state.has("frame") else state, [_plan("basic_quick_attack", 98)])
    _check(int(result.state.get("frame", {}).get("time_tick", -1)) == 100, "one resolution advances exactly 100 integer ticks")
    if state.has("frame"):
        _behavior_checks(engine, state)
    for failure in failures:
        print("FAIL: ", failure)
    print("FRAME_TIMELINE checks=%d failures=%d" % [checks, failures.size()])
    quit(0 if failures.is_empty() else 1)

func _behavior_checks(engine, state: Dictionary) -> void:
    var quiet := _fixture(state, [])
    var first: Dictionary = engine.resolve_window(quiet, [_plan("basic_quick_attack", 98)])
    _check(first.ok and first.state.player.stamina[0] == 4, "carry charges cost at startup exactly once")
    _check(first.state.enemy.health[0] == 30, "late startup does not attack before next window")
    _check(not first.state.frame.carry.player.is_empty(), "unfinished action is retained at boundary")
    _check(not engine.validate_plan([_plan("basic_guard", 0)], first.state).ok, "carried recovery blocks overlapping next window placement")
    var continued: Dictionary = engine.resolve_window(first.state, [_plan("basic_move", 20, -1)])
    _check(continued.ok and continued.state.player.stamina[0] == 4, "carried attack does not repay stamina")
    _check(continued.state.enemy.health[0] == 25, "carried attack deals canonical damage exactly once")
    var clash := _fixture(state, [_scheduled(engine, "enemy", "basic_quick_attack", 0)])
    var draw: Dictionary = engine.resolve_window(clash, [_plan("basic_quick_attack", 0)])
    if "--frame-contract-sample" in OS.get_cmdline_user_args():
        for event in draw.events:
            if event.type == "action_effect":
                print("FRAME_EVENT_SAMPLE ", JSON.stringify(event))
                break
    _check(draw.state.player.health[0] == 30 and draw.state.enemy.health[0] == 30, "equal simultaneous attacks clash and cancel damage")
    _check(_has_outcome(draw, "clash_draw"), "clash event is available to presentation")
    var dodge := _fixture(state, [_scheduled(engine, "enemy", "basic_quick_attack", 0)])
    var evaded: Dictionary = engine.resolve_window(dodge, [_plan("basic_evade", 0)])
    _check(evaded.state.player.health[0] == 30 and _has_defense(evaded, "evade"), "active evasion blocks an actual in-range attack")
    var late_dodge := _fixture(state, [_scheduled(engine, "enemy", "basic_quick_attack", 20)])
    var expired: Dictionary = engine.resolve_window(late_dodge, [_plan("basic_evade", 0)])
    _check(expired.state.player.health[0] == 25, "expired evasion gives no protection")
    var guarded: Dictionary = engine.resolve_window(dodge, [_plan("basic_guard", 0)])
    _check(guarded.state.player.health[0] == 30 and _has_defense(guarded, "block"), "active guard subtracts canonical defense then halves remaining damage")
    var interrupted: Dictionary = engine.resolve_window(dodge, [_plan("basic_heavy_attack", 0)])
    _check(interrupted.state.player.health[0] == 25 and interrupted.state.enemy.health[0] == 30, "startup damage interrupts unexecuted heavy attack")
    _check(_has_outcome(interrupted, "interrupted"), "interruption is recorded")
    var far := _fixture(state, [])
    far.enemy.tile = 9
    var missed: Dictionary = engine.resolve_window(far, [_plan("basic_quick_attack", 0)])
    _check(missed.state.enemy.health[0] == 30, "attack at an invalid distance does not damage")
    var observe := _fixture(state, [_scheduled(engine, "enemy", "basic_move", 110), _scheduled(engine, "enemy", "basic_move", 140)])
    var observed: Dictionary = engine.resolve_window(observe, [_plan("basic_observe", 90)])
    var observed_next: Dictionary = engine.resolve_window(observed.state, [_plan("basic_move", 20, -1)])
    _check(int(observed_next.state.frame.observation_level) == 1, "observation level grows only when carried observation completes")
    _check(int(observed_next.state.frame.reveal_from_tick) == 105 and int(observed_next.state.frame.reveal_until_tick) == 135, "first observation reveals 30 ticks from completion")
    var revealed: Array = observed_next.state.frame.revealed_enemy_actions
    _check(revealed.size() == 1 and revealed[0].absolute_start_tick == 110, "observation includes future action in horizon and excludes action beyond it")
    var locked: Dictionary = engine.lock_enemy_plan(state)
    var edited := state.duplicate(true)
    edited["uncommitted_plan"] = [_plan("basic_heavy_attack", 0)]
    edited.player["ui_intent"] = "retreat"
    var independently_locked: Dictionary = engine.lock_enemy_plan(edited)
    _check(locked.frame.enemy_queue == independently_locked.frame.enemy_queue, "AI plan is independent of player uncommitted placement and UI intent")
    _check(engine.public_enemy_plan(locked).is_empty(), "unobserved enemy queue is never public")
    var repeated_a: Dictionary = engine.resolve_window(locked, [_plan("basic_guard", 0)])
    var repeated_b: Dictionary = engine.resolve_window(locked, [_plan("basic_guard", 0)])
    _check(repeated_a == repeated_b, "same locked state and plan produce identical state and events")
    _check(locked.frame.time_tick == 0, "resolution does not mutate input state")
    var copied := JSON.parse_string(JSON.stringify(first.state)) as Dictionary
    var restored: Dictionary = engine.resolve_window(copied, [_plan("basic_move", 20, -1)])
    _check(restored.state == continued.state, "JSON round trip preserves cost and hit carry flags")
    var second_lock: Dictionary = engine.lock_enemy_plan(locked)
    _check(second_lock.frame.enemy_queue == locked.frame.enemy_queue, "relocking confirmed enemy actions never rerolls them")
    var manual_ids: Array = engine.martial_registry.get_manual_ids()
    var mastery := {}
    for id in manual_ids: mastery[id] = 10
    _check(engine.configure(manual_ids, mastery, [], {}, {}), "all canonical manuals can configure")
    var count := 0
    for card in engine.cards_for("player"):
        if card.get("source") == "martial_manual": count += 1
        _check(card.get("frame_timing", {}).get("total", 0) > 0, "canonical card has integer duration: " + str(card.id))
    _check(count == 30, "all thirty canonical martial definitions remain available")
    var martial_state := _fixture(engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string(HUD_PATH)), 4, 5), [])
    var defense: Dictionary = engine.resolve_window(martial_state, [_plan("shaolin_arhat_vajra_art_star3", 0)])
    _check(defense.state.player.get("defense", 0) == 3 and defense.state.player.fortitude_next_attack, "martial defense and fortitude use the real effect program")
    var denied: Dictionary = engine.validate_plan([_plan("shaolin_arhat_vajra_art_star10", 0)], martial_state)
    _check(not denied.ok, "martial ultimate requires actual momentum")
    martial_state.player.momentum = [5, 5]
    var ultimate: Dictionary = engine.resolve_window(martial_state, [_plan("ultimate_ten_paces_wave", 0)])
    _check(ultimate.state.player.tile == 5 and ultimate.state.enemy.health[0] == 20, "canonical basic ultimate dashes and uses attack-power scaling")
    _check(ultimate.state.battle_metrics.ultimate_uses == 1, "one ultimate action is counted once across startup/effect/completion events")
    _extended_checks(engine, state, martial_state)

func _extended_checks(engine, base: Dictionary, martial_state: Dictionary) -> void:
    var quiet := _fixture(base, [])
    var guard_state := _fixture(base, [_scheduled(engine, "enemy", "basic_quick_attack", 100)])
    var guarded_first: Dictionary = engine.resolve_window(guard_state, [_plan("basic_guard", 95)])
    var guarded_next: Dictionary = engine.resolve_window(guarded_first.state, [])
    _check(guarded_next.ok and guarded_next.state.player.health[0] == 30 and guarded_next.state.player.stamina[0] == 4, "active guard carry protects next window without recharging its cost")
    var fatal := quiet.duplicate(true)
    fatal.enemy.health = [5, 30]
    var stopped: Dictionary = engine.resolve_window(fatal, [_plan("basic_quick_attack", 0), _plan("basic_observe", 20)])
    _check(stopped.terminal and stopped.state.outcome == "win" and stopped.state.frame.time_tick == 4 and stopped.samples.size() == 4, "death stops ticks at actual lethal strike")
    _check(stopped.state.frame.observation_level == 0, "future scheduled observation cannot execute after death")
    _check(not engine.resolve_window(stopped.state, [_plan("basic_observe", 0)]).ok, "terminal state cannot grant actions or rewards again")
    var observer: Dictionary = engine.resolve_window(quiet, [_plan("basic_observe", 0), _plan("basic_observe", 15), _plan("basic_observe", 30), _plan("basic_observe", 45)])
    _check(observer.state.frame.observation_level == 3 and observer.state.frame.reveal_until_tick == 150, "observation caps at third level with 90 ticks after completion")
    var observation_event := false
    for event in observer.events:
        if event.has("public_enemy_actions") and event.observation_level == 3: observation_event = true
    _check(observation_event, "observation completion provides sanitized timeline information during playback")
    var fortified := _fixture(base, [_scheduled(engine, "enemy", "basic_quick_attack", 10)])
    var fortitude: Dictionary = engine.resolve_window(fortified, [_plan("basic_stance", 0), _plan("basic_heavy_attack", 10)])
    _check(fortitude.state.enemy.health[0] == 17, "prepared heavy attack survives startup hit and adds canonical +2 damage")
    _check(not fortitude.state.player.fortitude_next_attack, "fortitude from prepare is consumed by the next attack")
    var response := _fixture(martial_state, [_scheduled(engine, "enemy", "basic_quick_attack", 4)])
    var counter: Dictionary = engine.resolve_window(response, [_plan("xiaoyao_lingbo_footwork_star7", 0)])
    _check(counter.state.player.health[0] == 30 and counter.state.enemy.health[0] == 23 and counter.state.player.tile == 2, "real evade success resumes martial counterattack and retreat only once")
    var contact := _fixture(martial_state, [_scheduled(engine, "enemy", "basic_quick_attack", 8)])
    var taiji: Dictionary = engine.resolve_window(contact, [_plan("wudang_taiji_sword_star10", 0)])
    _check(taiji.state.player.health[0] == 30 and taiji.state.enemy.health[0] == 22, "contact-dependent martial stance waits for active incoming attack then counters")
    for card in engine.cards_for("player"):
        if card.get("source") != "martial_manual": continue
        var probe := _fixture(martial_state, [])
        probe.player.health = [500, 500]
        probe.enemy.health = [500, 500]
        probe.player.stamina = [100, 100]
        probe.player.internal = [100, 100]
        probe.player.momentum = [5, 5]
        var applied: Dictionary = engine.resolve_window(probe, [_plan(str(card.id), 0)])
        _check(applied.ok and applied.state.frame.time_tick == 100 and engine.validate_state(applied.state).ok, "canonical martial program executes and yields valid next state: " + str(card.id))
    var bad := quiet.duplicate(true)
    bad.player.health = [-1, 30]
    _check(not engine.validate_state(bad).ok, "negative saved resource is rejected")
    bad = guarded_first.state.duplicate(true)
    bad.frame.carry.player.cost_paid = false
    _check(not engine.validate_state(bad).ok, "unpaid active carried response is rejected")
    bad = guarded_first.state.duplicate(true)
    bad.frame.carry.player.active_tick += 1
    _check(not engine.validate_state(bad).ok, "forged carried activation timing is rejected")
    bad = quiet.duplicate(true)
    bad.frame.enemy_queue = [_scheduled(engine, "enemy", "basic_quick_attack", 20)]
    bad.frame.enemy_queue[0].cost_paid = true
    _check(not engine.validate_state(bad).ok, "future locked action cannot claim its cost was already paid")
    bad = quiet.duplicate(true)
    bad.frame.reveal_from_tick = 0
    bad.frame.reveal_until_tick = 90
    _check(not engine.validate_state(bad).ok, "zero observation level cannot carry a forged reveal horizon")
    var saved_program: Dictionary = engine.resolve_window(quiet, [_plan("basic_quick_attack", 96)])
    bad = saved_program.state.duplicate(true)
    bad.frame.carry.player.program.index = -1
    _check(not engine.validate_state(bad).ok, "negative saved program counter is rejected")
    bad = saved_program.state.duplicate(true)
    bad.frame.carry.player.program.runtime = []
    _check(not engine.validate_state(bad).ok, "malformed saved program runtime is rejected before resolving")
    var unhit_fortitude: Dictionary = engine.resolve_window(quiet, [_plan("basic_stance", 0), _plan("basic_quick_attack", 10)])
    _check(not unhit_fortitude.state.player.fortitude_next_attack, "next-attack fortitude expires after its attack even when not struck")
    var spent := _fixture(martial_state, [])
    spent.player.battle_uses = {"purple_mist_ultimate": false}
    var spent_result: Dictionary = engine.resolve_window(spent, [_plan("mount_hua_purple_mist_art_star10", 90)])
    _check(engine.validate_state(spent_result.state).ok, "failed once-per-battle martial remains a valid carried action")
    var spent_next: Dictionary = engine.resolve_window(spent_result.state, [])
    _check(spent_next.ok and engine.validate_state(spent_next.state).ok and _has_outcome(spent_next, "martial_failed"), "once-per-battle rejection completes without replaying resource restoration")
    var ongoing := _fixture(base, [_scheduled(engine, "enemy", "basic_guard", 95)])
    var observer_first: Dictionary = engine.resolve_window(ongoing, [_plan("basic_observe", 90)])
    var observer_second: Dictionary = engine.resolve_window(observer_first.state, [])
    _check(observer_second.state.frame.revealed_enemy_actions.size() == 1, "observation completion reveals an enemy action carried from the previous window")
    var tampered_plan := _plan("basic_quick_attack", 0)
    tampered_plan["definition"] = {"damage": 99999, "stamina_cost": 0}
    var authoritative: Dictionary = engine.resolve_window(quiet, [tampered_plan])
    _check(authoritative.state.enemy.health[0] == 25 and authoritative.state.player.stamina[0] == 4, "caller-supplied definitions cannot alter canonical damage or cost")
    var ultimate_carry := _fixture(base, [])
    ultimate_carry.player.momentum = [5, 5]
    ultimate_carry.enemy.health = [100, 100]
    ultimate_carry.enemy.tile = 7
    var ultimate_first: Dictionary = engine.resolve_window(ultimate_carry, [_plan("ultimate_void_sword_qi", 90)])
    var ultimate_next: Dictionary = engine.resolve_window(ultimate_first.state, [])
    _check(ultimate_first.state.player.momentum[0] == 1 and ultimate_next.state.enemy.health[0] == 66, "carried ultimate pays five momentum once and fires canonical scaled attack")
    var clash_bonus := _fixture(base, [_scheduled(engine, "enemy", "basic_quick_attack", 0)])
    clash_bonus.player.status_counts = {"clash_power_bonus": 1}
    var bonus_win: Dictionary = engine.resolve_window(clash_bonus, [_plan("basic_quick_attack", 0)])
    _check(_has_outcome(bonus_win, "clash_win") and bonus_win.state.player.health[0] == 30 and bonus_win.state.enemy.health[0] == 30, "canonical clash-only bonus wins the contest without becoming raw HP damage")
    _check(bonus_win.state.player.status_counts.clash_power_bonus == 1, "unspecified canonical clash-bonus expiry is not invented")
    var armored_clash := _fixture(base, [_scheduled(engine, "enemy", "basic_quick_attack", 0)])
    armored_clash.player.defense = 3
    armored_clash.enemy.defense = 3
    var no_guard_reward: Dictionary = engine.resolve_window(armored_clash, [_plan("basic_quick_attack", 0)])
    _check(no_guard_reward.state.player.momentum[0] == 1 and no_guard_reward.state.enemy.momentum[0] == 1, "a canceled clash does not award false guard-success momentum")
    var all_ids: Array = engine.martial_registry.get_manual_ids()
    var all_mastery := {}
    for id in all_ids: all_mastery[id] = 10
    _check(engine.configure(all_ids, all_mastery, all_ids, all_mastery, {}), "all owned manuals configure independently for both actors")
    var arhat := engine.make_initial_state(JSON.parse_string(FileAccess.get_file_as_string(HUD_PATH)), 4, 5) as Dictionary
    arhat.player.health = [100, 100]
    arhat.player.internal = [10, 10]
    arhat.player.stamina = [10, 10]
    arhat.player.momentum = [5, 5]
    arhat.enemy.health = [100, 100]
    arhat = _fixture(arhat, [_scheduled(engine, "enemy", "hebei_peng_five_tigers_saber_star3", 0)])
    var arhat_hit: Dictionary = engine.resolve_window(arhat, [_plan("shaolin_arhat_vajra_art_star10", 0)])
    _check(arhat_hit.samples[0].after.player.get("defense", 0) == 4, "documented Arhat ultimate grants defense before startup telegraph")
    _check(arhat_hit.state.player.health[0] == 96 and arhat_hit.state.enemy.health[0] == 86, "Arhat startup fortitude survives hit and adds actual two lost defense to its strike")
    arhat.frame.enemy_queue = [_scheduled(engine, "enemy", "hebei_peng_five_tigers_saber_star3", 100)]
    var arhat_first: Dictionary = engine.resolve_window(arhat, [_plan("shaolin_arhat_vajra_art_star10", 90)])
    var arhat_next: Dictionary = engine.resolve_window(JSON.parse_string(JSON.stringify(arhat_first.state)), [])
    _check(arhat_next.ok and arhat_next.state.player.internal[0] == 7 and arhat_next.state.player.health[0] == 96 and arhat_next.state.enemy.health[0] == 86, "Arhat defense record and prepaid cost survive JSON carry across window")
    _active_interval_checks(engine, base, martial_state)
    _observation_boundary_checks(engine, base)

func _active_interval_checks(engine, base: Dictionary, martial_state: Dictionary) -> void:
    var approaching := _fixture(base, [_scheduled(engine, "enemy", "basic_move", 2)])
    approaching.enemy.tile = 6
    var late_hit: Dictionary = engine.resolve_window(approaching, [_plan("basic_quick_attack", 0)])
    _check(late_hit.state.enemy.health[0] == 25 and late_hit.samples[3].after.enemy.health[0] == 30 and late_hit.samples[4].after.enemy.health[0] == 25, "attack connects when target enters range on its final active tick")
    _check(late_hit.state.player.stamina[0] == 4 and _damage_event_count(late_hit, "player") == 1, "waiting for active contact neither charges again nor applies damage twice")
    approaching.frame.enemy_queue = [_scheduled(engine, "enemy", "basic_move", 3)]
    var too_late: Dictionary = engine.resolve_window(approaching, [_plan("basic_quick_attack", 0)])
    _check(too_late.state.enemy.health[0] == 30 and _has_outcome(too_late, "miss_range"), "contact after the active interval cannot cause a recovery or completion hit")
    approaching.frame.enemy_queue = [_scheduled(engine, "enemy", "basic_move", 98)]
    var carry_first: Dictionary = engine.resolve_window(approaching, [_plan("basic_quick_attack", 96)])
    var carry_next: Dictionary = engine.resolve_window(JSON.parse_string(JSON.stringify(carry_first.state)), [])
    _check(carry_next.ok and carry_first.state.enemy.health[0] == 30 and carry_next.samples[0].after.enemy.health[0] == 25 and carry_next.state.player.stamina[0] == 4, "pending active contact survives JSON carry and connects once at next window boundary")
    var granted := _fixture(martial_state, [_scheduled(engine, "enemy", "basic_move", 11)])
    granted.enemy.tile = 6
    var martial: Dictionary = engine.resolve_window(granted, [_plan("shaolin_arhat_vajra_art_star7", 0)])
    _check(martial.state.enemy.health[0] == 21 and martial.state.player.defense == 2 and _damage_event_count(martial, "player") == 1, "martial attack waits for range without replaying its defense prefix")
    _check(martial.state.player.stamina[0] == 4 and martial.state.player.internal[0] == 3, "martial active retries preserve canonical one-time resource costs")

func _observation_boundary_checks(engine, base: Dictionary) -> void:
    var hidden := _fixture(base, [_scheduled(engine, "enemy", "basic_heavy_attack", 130), _scheduled(engine, "enemy", "basic_move", 160)])
    hidden.enemy.tile = 9
    var first: Dictionary = engine.resolve_window(hidden, [_plan("basic_observe", 90)])
    var second: Dictionary = engine.resolve_window(first.state, [])
    var view: Array = []
    for event in second.events:
        if event.has("public_enemy_actions"): view = event.public_enemy_actions
    _check(view.size() == 1 and int(view[0].absolute_start_tick) == 130 and int(view[0].absolute_active_tick) == 135 and int(view[0].absolute_end_tick) == 135, "observation clips displayed phase boundaries at its exact 135 tick horizon")
    if not view.is_empty():
        var shown: Dictionary = view[0]
        _check(shown.frame_timing == {"startup": 5, "active": 0, "recovery": 0, "total": 5} and bool(shown.get("view_only", false)) and bool(shown.get("clipped_end", false)), "clipped observation exposes only known phase durations and is explicitly view-only")
        _check(not shown.has("actual_active_tick") and not shown.has("actual_end_tick"), "clipped observation does not disclose future activation or completion timestamps")
    var saved_reveal: Array = second.state.frame.revealed_enemy_actions
    _check(saved_reveal.size() == 1 and int(saved_reveal[0].absolute_end_tick) <= 135 and engine.validate_state(second.state).ok, "persisted revealed knowledge is bounded and validates after clipping")
    var later: Dictionary = engine.resolve_window(first.state, [_plan("basic_observe", 5)])
    var expanded: Dictionary = {}
    for event in later.events:
        if event.get("observation_level", 0) == 2:
            for action in event.public_enemy_actions:
                if action.card_id == "basic_heavy_attack": expanded = action
    _check(not expanded.is_empty() and int(expanded.absolute_start_tick) == 130 and int(expanded.absolute_end_tick) == 155 and int(expanded.absolute_active_tick) == 142, "a later actual observation widens the same confirmed action without rerolling it")
    _check(engine.validate_state(later.state).ok, "widened revealed knowledge survives state validation")

func _damage_event_count(result: Dictionary, actor: String) -> int:
    var count := 0
    for event in result.events:
        if event.actor == actor and event.type == "action_effect" and int(event.actions[0].get("damage", 0)) > 0: count += 1
    return count

func _plan(id: String, tick: int, direction: int = 0) -> Dictionary:
    return {"card_id": id, "start_tick": tick, "direction": direction, "move_steps": 1}

func _scheduled(engine, actor: String, id: String, tick: int) -> Dictionary:
    var card: Dictionary = engine.get_actor_card_definition(id, actor)
    var timing: Dictionary = card.frame_timing
    return {"uid": "%s:%d:%s" % [actor, tick, id], "actor": actor, "card_id": id, "start_tick": tick, "active_tick": tick + int(timing.startup), "end_tick": tick + int(timing.total), "frame_timing": timing.duplicate(true), "direction": 0, "move_steps": 1, "cost_paid": false, "effect_applied": false, "cancelled": false}

func _fixture(state: Dictionary, actions: Array) -> Dictionary:
    var result := state.duplicate(true)
    result.frame.enemy_queue = actions.duplicate(true)
    result.frame.enemy_locked_until_tick = 1000
    return result

func _has_outcome(result: Dictionary, expected: String) -> bool:
    for event in result.events:
        for action in event.actions:
            if action.get("outcome") == expected: return true
    return false

func _has_defense(result: Dictionary, expected: String) -> bool:
    for event in result.events:
        for action in event.actions:
            if action.get("defense_outcome") == expected: return true
    return false

func _check(passed: bool, label: String) -> void:
    checks += 1
    if not passed: failures.append(label)
