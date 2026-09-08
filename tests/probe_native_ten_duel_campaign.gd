extends "res://tests/probe_sequential_ten_duel_campaign.gd"

var activations := 0
var shell
var started_ms := 0
var last_input := "none"
var terminal_outcomes := {"win": 0, "draw": 0}
const WALL_TIMEOUT_MS := 900000

func run_probe() -> void:
    var disabled := Button.new()
    root.add_child(disabled)
    disabled.disabled = true
    var disabled_signals := [0]
    disabled.pressed.connect(func(): disabled_signals[0] += 1)
    var before := activations
    _require(not await _activate(disabled), "disabled control must be rejected")
    _require(activations == before, "rejected activation must not count as progress")
    _require(disabled_signals[0] == 0, "disabled control must not activate")
    disabled.queue_free()
    if failures.is_empty():
        print("NATIVE_HELPER_DISABLED PASS")
    var duplicate := Button.new()
    root.add_child(duplicate)
    # This isolated fixture simulates a broken consumer's extra pressed signal.
    duplicate.pressed.connect(func(): duplicate.call_deferred("emit_signal", "pressed"), CONNECT_ONE_SHOT)
    before = activations
    _require(not await _activate(duplicate), "duplicate pressed must be rejected")
    _require(activations == before, "duplicate pressed must not count as progress")
    duplicate.queue_free()
    var forged := {"terminal": true, "outcome": "win", "duel_index": 1, "player_health": 10, "enemy_health": 0}
    _require(not _terminal_success({"player": {"health": [10, 30]}, "enemy": {"health": [10, 30]}}, forged, [{"duel_index": 1, "outcome": "win"}], 1), "review receipt must not fake terminal HP")
    var won := {"player": {"health": [10, 30]}, "enemy": {"health": [0, 30]}}
    _require(_terminal_success(won, forged, [{"duel_index": 1, "outcome": "win"}], 1), "consistent terminal win must pass")
    _require(not _terminal_success(won, forged, [{"duel_index": 1, "outcome": "draw"}], 1), "contradictory history must fail")
    _require(not _terminal_success(won, forged, [{"duel_index": 2, "outcome": "win"}], 1), "wrong duel history must fail")
    var drawn := {"terminal": true, "outcome": "draw", "duel_index": 1, "player_health": 0, "enemy_health": 0}
    _require(_terminal_success({"player": {"health": [0, 30]}, "enemy": {"health": [0, 30]}}, drawn, [{"duel_index": 1, "outcome": "draw"}], 1), "consistent terminal draw remains contract-legal")
    var route := {"id": "rest", "route_type": "rest", "node_id": "J1-1"}
    _require(_route_matches(route, "rest", "J1-1"), "matching route identity must pass")
    _require(not _route_matches(route, "training", "J1-1"), "wrong selected route must fail")
    _require(not _route_matches(route, "rest", "J1-2"), "stale route node must fail")
    if failures.is_empty():
        print("NATIVE_HELPER_GUARDS PASS")
    if "--guards-only" in OS.get_cmdline_user_args():
        for failure in failures:
            printerr("NATIVE_GUARD_FAIL: ", failure)
        quit(1 if not failures.is_empty() else 0)
        return
    if not failures.is_empty():
        for failure in failures:
            printerr("NATIVE_GUARD_FAIL: ", failure)
        quit(1)
        return
    shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
    root.add_child(shell)
    await process_frame
    await process_frame
    started_ms = Time.get_ticks_msec()
    await _click(shell.find_child("MainStartButton", true, false), "title start")
    _require(shell.run_state.get_current_screen() == VerticalSliceRunState.SCREEN_SETUP, "title must reach setup")
    for manual_id in STARTERS:
        await _click(_meta_button(shell, "manual_id", manual_id), "starter " + manual_id)
        _require(manual_id in shell.get_setup_selected_manual_ids(), "starter must be selected")
    await _advance("setup", VerticalSliceRunState.SCREEN_INTRO)
    await _advance("intro", VerticalSliceRunState.SCREEN_BRIEFING)
    var run: VerticalSliceRunState = shell.run_state
    while failures.is_empty() and not run.is_complete():
        _require(Time.get_ticks_msec() - started_ms < WALL_TIMEOUT_MS, "global wall timeout")
        await _advance("briefing zero constraint receipt", VerticalSliceRunState.SCREEN_COMBAT)
        var bridge = shell._combat_view
        _require(bridge.get_vertical_slice_player_resources() == run.get_player_run_resources(), "shell resources must exactly reach bridge")
        # The production frontal layout hides replay settings; preserve defaults.
        _require(not bridge._fast_replay and not bridge._reduced_motion, "ordinary animation defaults required")
        var terminal := false
        for turn in range(MAX_BUNDLES):
            if not failures.is_empty():
                break
            var bundle := int(bridge.combat_state.get("bundle_index", 1))
            var placements := _native_schedule(_public_policy(bridge.resolution_engine, bridge.combat_state.duplicate(true), bundle, 0), bundle)
            for placement in placements:
                await _place(bridge, placement)
                if not failures.is_empty():
                    break
            if not failures.is_empty():
                break
            _require(bridge.action_timing_panel.is_current_bundle_complete(), "native plan must be complete")
            var resolution_before := int(bridge.get_meta("resolution_count", 0))
            await _click(bridge.combat_progress_button._button, "execute plan")
            _require(int(bridge.get_meta("resolution_count", 0)) == resolution_before + 1, "one execute activation must start exactly one resolution")
            var deadline := Time.get_ticks_msec() + 30000
            while not bridge.combat_review_panel.is_visible_in_tree() and Time.get_ticks_msec() < deadline and Time.get_ticks_msec() - started_ms < WALL_TIMEOUT_MS:
                await process_frame
            _require(bridge.combat_review_panel.is_visible_in_tree(), "bounded review wait stalled: " + _diagnostic(bridge))
            if not failures.is_empty():
                break
            _remember_public_player_cards(bridge.combat_state)
            terminal = run.get_current_screen() == VerticalSliceRunState.SCREEN_REVIEW
            if terminal:
                _require(_terminal_success(bridge.combat_state, run.last_combat_result, run.get_duel_history(), run.duel_index), "terminal HP/result/history must consistently prove success: " + _diagnostic(bridge))
                if not failures.is_empty():
                    break
                var outcome := str(run.last_combat_result.outcome)
                terminal_outcomes[outcome] += 1
                _require(run.get_player_run_resources() == bridge.get_vertical_slice_player_resources(), "terminal bridge resources must exactly reach shell")
            print("NATIVE_BUNDLE duel=%d turn=%d player=%s enemy_hp=%s terminal=%s" % [run.duel_index, turn + 1, bridge.get_vertical_slice_player_resources(), bridge.combat_state.enemy.health, terminal])
            await _click(bridge.combat_review_panel.get_continue_button(), "review continue")
            if terminal:
                break
            _require(bridge._presentation_state == "next_bundle_ready" and not bridge.combat_review_panel.is_visible_in_tree(), "review must reach next bundle")
        _require(terminal, "duel must reach real terminal review")
        if not failures.is_empty():
            break
        _require(run.get_current_screen() == VerticalSliceRunState.SCREEN_RESULT, "terminal success must reach reward")
        if not failures.is_empty():
            break
        var target := _reward_target_for_duel(run.duel_index)
        var manual_name := str(shell.manual_registry.get_manual(target).get("manual_name", target))
        await _click(_text_button(shell.result_options_container, "집중 수련 · " + manual_name), "earned focused reward")
        _require(str(run.get_pending_result_reward().get("target_manual_id", "")) == target, "reward target must match")
        var count := run.get_reward_history().size()
        await _click(shell.primary_button, "reward continue")
        _require(run.get_reward_history().size() == count + 1, "reward must be applied once")
        if run.is_complete():
            break
        for step in range(4):
            var choice := _choose_public_route(run.get_jianghu_options())
            var node_id := "J%d-%d" % [run.completed_duels, step + 1]
            await _click(shell.find_child("Jianghu_" + choice, true, false), "route " + choice)
            _require(_route_matches(run.get_pending_jianghu(), choice, node_id), "pending route identity must match native choice")
            var route_count := run.get_route_history().size()
            await _click(shell.primary_button, "route continue")
            _require(run.get_route_history().size() == route_count + 1, "route must apply exactly once")
            if failures.is_empty():
                _require(_route_matches(run.get_route_history().back(), choice, node_id), "new route history identity must match native choice")
        _require(run.get_current_screen() == VerticalSliceRunState.SCREEN_BRIEFING, "routes must reach next briefing")
    _require(run.is_complete() and run.get_duel_history().size() == 10, "ten real terminal successes required")
    _require(run.get_reward_history().size() == 10, "ten earned rewards required")
    _require(run.get_route_history().size() == 36, "36 native route choices required")
    _require(publicly_used_player_cards.has("shaolin_arhat_vajra_art_star7"), "Shaolin seven star must resolve")
    _require(publicly_used_player_cards.has("yang_family_spear_star7"), "Yang seven star must resolve")
    var ultimate_used := false
    for card_id in BASIC_ULTIMATES:
        ultimate_used = ultimate_used or publicly_used_player_cards.has(card_id)
    _require(ultimate_used, "base ultimate must resolve")
    print("NATIVE_CAMPAIGN_SUMMARY ", JSON.stringify({"complete": run.is_complete(), "duels": run.get_duel_history().size(), "outcomes": terminal_outcomes, "rewards": run.get_reward_history().size(), "routes": run.get_route_history().size(), "activations": activations, "cards": publicly_used_player_cards.keys(), "elapsed_ms": Time.get_ticks_msec() - started_ms, "mode": "ordinary_defaults", "failures": failures}))
    shell.queue_free()
    await process_frame
    await process_frame
    for failure in failures:
        printerr("NATIVE_CAMPAIGN_FAIL: ", failure)
    quit(1 if not failures.is_empty() else 0)

func _activate(button: Button) -> bool:
    if not is_instance_valid(button) or not button.is_visible_in_tree() or button.disabled or button.focus_mode == Control.FOCUS_NONE:
        print("NATIVE_REJECT prerequisites button=%s visible=%s disabled=%s focus_mode=%s" % [str(button), button.is_visible_in_tree() if is_instance_valid(button) else false, button.disabled if is_instance_valid(button) else true, button.focus_mode if is_instance_valid(button) else -1])
        return false
    button.grab_focus()
    await process_frame
    if not is_instance_valid(button) or not button.has_focus() or button.disabled or not button.is_visible_in_tree():
        print("NATIVE_REJECT focus button=%s owner=%s" % [str(button), str(root.gui_get_focus_owner())])
        return false
    var observed := [0]
    var witness := func(): observed[0] += 1
    button.pressed.connect(witness)
    var event := InputEventAction.new()
    event.action = "ui_accept"
    event.pressed = true
    Input.parse_input_event(event)
    await process_frame
    var released := InputEventAction.new()
    released.action = "ui_accept"
    released.pressed = false
    Input.parse_input_event(released)
    await process_frame
    await process_frame
    if is_instance_valid(button) and button.pressed.is_connected(witness):
        button.pressed.disconnect(witness)
    if observed[0] != 1:
        print("NATIVE_REJECT signal button=%s observed=%d" % [str(button), observed[0]])
        return false
    activations += 1
    return true

func _click(button: Button, label: String) -> void:
    if not failures.is_empty():
        return
    last_input = label
    _require(await _activate(button), "native activation rejected: " + label)
    if not failures.is_empty() and is_instance_valid(shell):
        print("NATIVE_DIAGNOSTIC label=%s screen=%s button=%s" % [label, shell.run_state.get_current_screen(), str(button)])

func _advance(label: String, expected: String) -> void:
    await _click(shell.primary_button, label)
    _require(shell.run_state.get_current_screen() == expected, label + " transition must reach " + expected)

func _meta_button(node: Node, key: String, value: String) -> Button:
    for child in node.find_children("*", "Button", true, false):
        if child.is_visible_in_tree() and str(child.get_meta(key, "")) == value:
            return child
    return null

func _text_button(node: Node, text: String) -> Button:
    for child in node.find_children("*", "Button", true, false):
        if child.is_visible_in_tree() and text in child.text:
            return child
    return null

func _place(bridge, placement: Dictionary) -> void:
    if not failures.is_empty():
        return
    var definition: Dictionary = placement.definition
    var card_id := str(placement.card_id)
    var dock = bridge.action_selection_dock
    var source := "ultimate" if _is_ultimate(definition) else ("basic" if card_id.begins_with("basic_") else "martial")
    if dock.active_source != source:
        await _click(dock.get(source + "_tab"), "source " + source)
        _require(dock.active_source == source, "source must switch")
    if source == "martial":
        var manual_id := str(definition.get("manual_id", ""))
        await _click(_meta_button(dock.martial_panel, "manual_id", manual_id), "manual " + manual_id)
        _require(dock.martial_panel.selected_manual_id == manual_id, "manual must switch")
    await _click(_meta_button(dock, "action_id", card_id), "action " + card_id)
    var actual: Dictionary = bridge.action_timing_panel.get_placement(int(placement.anchor_index))
    _require(str(actual.get("card_id", "")) == card_id, "native action must occupy expected anchor: " + card_id)
    if not bool(actual.get("target_ready", true)):
        var target_button: Button = null
        for button in dock.action_intent_panel.intent_buttons:
            if int(button.action_definition.get("resolver_direction", 0)) == int(placement.direction) and int(button.action_definition.get("steps", 1)) == 1:
                target_button = button
                break
        await _click(target_button, "public movement intent")
        actual = bridge.action_timing_panel.get_placement(int(placement.anchor_index))
        _require(bool(actual.get("target_ready", false)), "native movement intent must complete target")

func _native_schedule(placements: Array, bundle: int) -> Array:
    # Public UI reserves an ultimate atomically and locks source tabs. Select the
    # same policy actions, placing the ultimate last so no source switch follows.
    var result: Array = []
    for ultimate in [false, true]:
        for placement in placements:
            if _is_ultimate(placement.definition) == ultimate:
                result.append(placement.duplicate(true))
    var anchor: int = [1, 4, 7][bundle - 1]
    for placement in result:
        placement.anchor_index = anchor
        anchor += int(placement.span)
    return result

func _terminal_success(state: Dictionary, result: Dictionary, history: Array, duel: int) -> bool:
    for actor in ["player", "enemy"]:
        if typeof(state.get(actor)) != TYPE_DICTIONARY:
            return false
        var health = state[actor].get("health")
        if typeof(health) != TYPE_ARRAY or health.size() != 2 or typeof(health[0]) != TYPE_INT:
            return false
    var player_hp := int(state.player.health[0])
    var enemy_hp := int(state.enemy.health[0])
    # A review screen is insufficient: actual HP must prove a win or legal draw.
    if enemy_hp > 0 or player_hp < 0 or enemy_hp < 0:
        return false
    var outcome := "win" if player_hp > 0 else "draw"
    if not bool(result.get("terminal", false)) or str(result.get("outcome", "")) != outcome:
        return false
    if int(result.get("player_health", -1)) != player_hp or int(result.get("enemy_health", -1)) != enemy_hp or int(result.get("duel_index", -1)) != duel:
        return false
    if history.size() != duel or typeof(history.back()) != TYPE_DICTIONARY:
        return false
    return str(history.back().get("outcome", "")) == outcome and int(history.back().get("duel_index", -1)) == duel

func _route_matches(receipt: Dictionary, choice: String, node_id: String) -> bool:
    return not choice.is_empty() and str(receipt.get("id", "")) == choice and str(receipt.get("route_type", "")) == choice and str(receipt.get("node_id", "")) == node_id

func _diagnostic(bridge) -> String:
    return JSON.stringify({"duel": shell.run_state.duel_index, "bundle": bridge.combat_state.get("bundle_index", -1), "screen": shell.run_state.get_current_screen(), "presentation_state": bridge._presentation_state, "last_input": last_input})
