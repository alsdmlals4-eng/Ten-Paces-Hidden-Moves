class_name VerticalSliceCombatBridge
extends "res://src/combat/combat_board_preview_ten_manuals_auto.gd"

const VERTICAL_SLICE_ENGINE_SCRIPT := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const BATTLE_METRICS_SCRIPT := preload("res://src/run/vertical_slice_battle_metrics.gd")

signal terminal_review_ready(result: Dictionary)
signal terminal_review_confirmed(result: Dictionary)
signal stable_checkpoint_changed(checkpoint: Dictionary)

const COMBAT_CHECKPOINT = preload("res://src/run/combat_checkpoint_codec.gd")
# Synchronous acknowledgment; false freezes the immutable pending boundary.
var checkpoint_writer: Callable
var _stable_checkpoint: Dictionary = {}
var _checkpoint_pending := false
var _checkpoint_restoring := false
var _checkpoint_advancing := false
var _checkpoint_duel := 1
var _checkpoint_attempt := 0
var _applied_restoration := ""

var _vertical_slice_terminal_result: Dictionary = {}
var _terminal_handoff_started := false
var _terminal_confirmation_emitted := false
var _vertical_slice_loadout_snapshot: Dictionary = {}
var _battle_metrics_helper: VerticalSliceBattleMetrics
var _bimu_ui_options: Array = preload("res://src/run/bimu_constraint_model.gd").new().get_options()


func _ready() -> void:
    _battle_metrics_helper = BATTLE_METRICS_SCRIPT.new()
    super._ready()
    set_meta("vertical_slice_bridge", true)
    set_meta("bridge_scope", "TERMINAL_REVIEW_RESULT_LOADOUT_RAW_METRICS_AND_RUN_RESOURCE_PERSISTENCE")


func configure_vertical_slice_loadouts(
    player_loadout,
    player_mastery_by_manual: Dictionary,
    enemy_loadout,
    enemy_mastery_by_manual: Dictionary,
    enemy_candidate_id: String,
    enemy_runtime_binding: Dictionary,
    enemy_identity: Dictionary = {},
    bimu_receipt: Dictionary = {}
) -> bool:
    var player_ids := _string_values(player_loadout)
    var enemy_ids := _string_values(enemy_loadout)
    if player_ids.size() != 4 or enemy_ids.size() != 1 or enemy_candidate_id.is_empty() or not _is_valid_enemy_runtime_binding(enemy_runtime_binding, enemy_candidate_id):
        return false
    for manual_id_value in player_ids:
        var manual_id := str(manual_id_value)
        if int(player_mastery_by_manual.get(manual_id, 0)) <= 0:
            return false
    for manual_id_value in enemy_ids:
        var manual_id := str(manual_id_value)
        if int(enemy_mastery_by_manual.get(manual_id, 0)) <= 0:
            return false

    if not bimu_receipt.is_empty() and (typeof(bimu_receipt.get("selections")) != TYPE_ARRAY or str(bimu_receipt.get("enemy_candidate_id", "")) != enemy_candidate_id):
        return false
    var engine: VerticalSliceMetricsCombatResolutionEngine = VERTICAL_SLICE_ENGINE_SCRIPT.new()
    if not engine.configure_bimu_constraints(bimu_receipt.get("selections", []), player_ids, enemy_ids):
        return false
    if not engine.configure_enemy_runtime_binding(enemy_runtime_binding):
        return false
    var effective_enemy_mastery := engine.get_bimu_enemy_mastery(enemy_mastery_by_manual)
    if not engine.configure_martial_loadouts(player_ids, player_mastery_by_manual.duplicate(true), enemy_ids, effective_enemy_mastery):
        return false
    _ten_manual_loadout_data = {
        "authority": "VERTICAL_SLICE_PHASE_V_RUNTIME_LOADOUT_METRICS_AND_RESOURCE_PERSISTENCE",
        "player": {
            "loadout": player_ids.duplicate(),
            "mastery_by_manual": player_mastery_by_manual.duplicate(true)
        },
        "enemy": {
            "loadout": enemy_ids.duplicate(),
            "mastery_by_manual": effective_enemy_mastery.duplicate(true),
            "candidate_id": enemy_candidate_id
        }
    }

    resolution_engine = engine
    combat_state = resolution_engine.make_initial_state(top_hud.hud_data, _player_tile, _enemy_tile)
    var enemy_state: Dictionary = (combat_state.get("enemy", {}) as Dictionary).duplicate(true)
    enemy_state["candidate_id"] = enemy_candidate_id
    var enemy_name := str(enemy_identity.get("name", ""))
    if not enemy_name.is_empty():
        enemy_state["name"] = enemy_name
    var enemy_epithet := str(enemy_identity.get("epithet", ""))
    if not enemy_epithet.is_empty():
        enemy_state["epithet"] = enemy_epithet
    combat_state["enemy"] = enemy_state
    combat_state["ai_enabled"] = true
    _configure_ultimate_menu()
    _sync_action_placement_controller_state()
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()

    _vertical_slice_loadout_snapshot = {
        "player_loadout": player_ids.duplicate(),
        "player_mastery_by_manual": player_mastery_by_manual.duplicate(true),
        "enemy_candidate_id": enemy_candidate_id,
        "enemy_loadout": enemy_ids.duplicate(),
        "enemy_mastery_by_manual": enemy_mastery_by_manual.duplicate(true),
        "enemy_runtime_binding": enemy_runtime_binding.duplicate(true),
        "effective_enemy_mastery_by_manual": effective_enemy_mastery.duplicate(true),
        "bimu_receipt": bimu_receipt.duplicate(true)
    }
    set_meta("vertical_slice_runtime_loadout_bound", true)
    set_meta("vertical_slice_enemy_candidate_id", enemy_candidate_id)
    set_meta("vertical_slice_battle_metrics_bound", true)
    set_meta("vertical_slice_run_resources_bound", true)
    _vertical_slice_terminal_result.clear()
    _terminal_handoff_started = false
    _terminal_confirmation_emitted = false
    capture_planning_checkpoint()
    return true


func _is_valid_enemy_runtime_binding(binding: Dictionary, enemy_candidate_id: String) -> bool:
    if not bool(binding.get("valid", false)) or str(binding.get("candidate_id", "")) != enemy_candidate_id:
        return false
    if str(binding.get("archetype_id", "")).is_empty() or typeof(binding.get("ai_profile", {})) != TYPE_DICTIONARY:
        return false
    if typeof(binding.get("basic_action_focus_ids", [])) != TYPE_ARRAY:
        return false
    var stats = binding.get("stats", {})
    if typeof(stats) != TYPE_DICTIONARY:
        return false
    var stat_total := 0
    for stat_id in ["external", "constitution", "agility", "internal_power", "insight"]:
        if int((stats as Dictionary).get(stat_id, 0)) < 1:
            return false
        stat_total += int((stats as Dictionary).get(stat_id, 0))
    return stat_total == int(binding.get("final_stat_total_seed", 0))


func apply_vertical_slice_player_resources(resources: Dictionary) -> bool:
    if not _valid_resource_pairs(resources):
        return false
    var player: Dictionary = (combat_state.get("player", {}) as Dictionary).duplicate(true)
    for key in ["health", "stamina", "internal"]:
        var pair: Array = (resources.get(key, []) as Array).duplicate()
        var maximum := maxi(0, int(pair[1]))
        var current := clampi(int(pair[0]), 0, maximum)
        player[key] = [current, maximum]
    combat_state["player"] = player
    _sync_runtime_context()
    _apply_combat_state_to_view()
    _refresh_ultimate_menu()
    _sync_action_selection_dock()
    capture_planning_checkpoint()
    return true


func configure_checkpoint_identity(duel_index: int, attempt_id: int) -> void:
    _checkpoint_duel = duel_index
    _checkpoint_attempt = attempt_id
    if not _stable_checkpoint.is_empty():
        _stable_checkpoint.duel_index = duel_index
        _stable_checkpoint.attempt_id = attempt_id


func get_last_stable_checkpoint() -> Dictionary:
    return _stable_checkpoint.duplicate(true)


func capture_planning_checkpoint() -> bool:
    if _checkpoint_restoring or _vertical_slice_loadout_snapshot.is_empty() or _inputs_locked():
        return false
    if _checkpoint_pending:
        return false
    if not action_timing_panel.get_resolution_placements().is_empty():
        return false
    return _publish_checkpoint(_make_checkpoint("PLANNING", combat_state, action_timing_panel.get_runtime_context()))


func _make_checkpoint(phase: String, state: Dictionary, context: Dictionary) -> Dictionary:
    # ProgressButton requests also contain UI execution flags. The durable domain
    # context owns only timing facts, exactly like ActionTimingPanel's context.
    var timing_context := {}
    for key in ["round_number", "bundle_index", "current_timing", "total_timings", "timing_sequence"]:
        timing_context[key] = context[key]
    return COMBAT_CHECKPOINT.portable({
        "phase": phase, "duel_index": _checkpoint_duel, "attempt_id": _checkpoint_attempt,
        "state": state, "context": timing_context, "enemy_lock": resolution_engine.export_enemy_lock(),
        "binding": _vertical_slice_loadout_snapshot,
        "player_plan": [] if phase == "PLANNING" else _checkpoint_domain_plan(),
        "state_before": {} if phase == "PLANNING" else _committed_state_before,
        "reservation_anchors": [] if phase == "PLANNING" else Array(_ultimate_reservation_anchors),
        "review_summary": _last_review_summary if phase == "BUNDLE_RESOLVED" else {}
    })


func _checkpoint_domain_plan() -> Array:
    # The live dock decorates definitions with labels, art and lock presentation.
    # Accept only an exact current producer definition before replacing it with
    # its engine-owned definition. File validation remains exact and fail-closed.
    var adapter = preload("res://src/ui/action_selection/action_view_model_adapter.gd").new()
    var presentations: Dictionary = {}
    for definition in adapter.build_basic_actions(): presentations[definition.id] = definition
    var binding := _vertical_slice_loadout_snapshot
    for manual in adapter.build_owned_manuals(binding.player_loadout, binding.player_mastery_by_manual):
        for definition in manual.techniques:
            if not definition.locked: presentations[definition.id] = definition
    for definition in adapter.build_ultimate_actions(5, binding.player_loadout, binding.player_mastery_by_manual):
        if not definition.locked: presentations[definition.id] = definition
    var result: Array = []
    for placement in _committed_player_plan_snapshot:
        var id := str(placement.card_id)
        var canonical: Dictionary = resolution_engine.get_actor_card_definition(id, "player")
        if canonical.is_empty(): return []
        var actual = COMBAT_CHECKPOINT.portable(placement.definition)
        if actual != COMBAT_CHECKPOINT.portable(canonical) and actual != COMBAT_CHECKPOINT.portable(presentations.get(id, {})):
            return []
        var row: Dictionary = placement.duplicate(true)
        row.definition = canonical.duplicate(true)
        result.append(row)
    return result


func _publish_checkpoint(dto: Dictionary) -> bool:
    _stable_checkpoint = dto.duplicate(true)
    _checkpoint_pending = checkpoint_writer.is_valid() and not bool(checkpoint_writer.call(dto.duplicate(true)))
    if _checkpoint_pending:
        _set_presentation_state("committed")
    stable_checkpoint_changed.emit(dto.duplicate(true))
    return not _checkpoint_pending


func _accept_committed_boundary(context: Dictionary) -> bool:
    # This is the same lazy lock point used at the start of resolve_bundle.
    resolution_engine.lock_enemy_bundle(_committed_state_before, int(context.bundle_index))
    return _publish_checkpoint(_make_checkpoint("BUNDLE_COMMITTED", _committed_state_before, context))


func _accept_resolved_boundary(result: Dictionary) -> bool:
    return _publish_checkpoint(_make_checkpoint("BUNDLE_RESOLVED", result.state, action_timing_panel.get_runtime_context()))


func retry_checkpoint() -> bool:
    if not _checkpoint_pending:
        return true
    if checkpoint_writer.is_valid() and not bool(checkpoint_writer.call(_stable_checkpoint.duplicate(true))):
        return false
    _checkpoint_pending = false
    match _stable_checkpoint.phase:
        "BUNDLE_COMMITTED":
            await _resolve_and_present(_stable_checkpoint.context)
        "BUNDLE_RESOLVED":
            combat_state = _stable_checkpoint.state.duplicate(true)
            _last_review_summary = _stable_checkpoint.review_summary.duplicate(true)
            _finalize_resolved_bundle()
        "PLANNING":
            _set_presentation_state("next_bundle_ready")
    return not _checkpoint_pending


func _advance_to_next_bundle() -> void:
    _checkpoint_advancing = true
    # Reservation was consumed by the resolved bundle; no refund or re-reservation.
    _ultimate_reservation_anchors.clear()
    super._advance_to_next_bundle()
    _checkpoint_advancing = false
    capture_planning_checkpoint()


func request_locked_enemy_action_type_reveal() -> void:
    if _checkpoint_pending or _checkpoint_restoring or _inputs_locked():
        return
    super.request_locked_enemy_action_type_reveal()


func reveal_available_locked_enemy_action_types() -> Dictionary:
    var result := super.reveal_available_locked_enemy_action_types()
    if result.get("ok", false) and not _checkpoint_advancing and not _checkpoint_restoring and _stable_checkpoint.get("phase") == "PLANNING":
        var baseline := _stable_checkpoint.duplicate(true)
        for key in ["observation_points", "observation_reveal_index", "observation_reveals"]:
            if combat_state.player.has(key): baseline.state.player[key] = COMBAT_CHECKPOINT.portable(combat_state.player[key])
        baseline.enemy_lock = COMBAT_CHECKPOINT.portable(resolution_engine.export_enemy_lock())
        _publish_checkpoint(baseline)
    return result


func restore_combat_checkpoint(dto: Dictionary) -> Dictionary:
    # Complete DTO and configured identity validation precede every live assignment.
    if _vertical_slice_loadout_snapshot.is_empty():
        return {"ok": false, "status": "CORRUPT", "error": "Configure combat binding before restore"}
    var validation: Dictionary = COMBAT_CHECKPOINT.new().validate(dto, _vertical_slice_loadout_snapshot)
    if not validation.ok: return validation
    if dto.phase == "PLANNING" and dto.state.player.health[0] == 0 and COMBAT_CHECKPOINT.portable(dto.state.player.health) != COMBAT_CHECKPOINT.portable(combat_state.player.health):
        return {"ok": false, "status": "CORRUPT", "error": "Apply carried resources before initial zero-health restore"}
    if int(dto.duel_index) != _checkpoint_duel or int(dto.attempt_id) != _checkpoint_attempt:
        return {"ok": false, "status": "CORRUPT", "error": "Combat identity mismatch"}
    var fingerprint: String = preload("res://src/run/run_checkpoint_codec.gd").digest(dto)
    if fingerprint == _applied_restoration: return {"ok": true, "status": "ALREADY_APPLIED"}
    if _checkpoint_pending: return {"ok": false, "status": "IO_FAILURE", "error": "Pending checkpoint"}
    _checkpoint_restoring = true
    _stable_checkpoint = COMBAT_CHECKPOINT.portable(dto)
    combat_state = _stable_checkpoint.state.duplicate(true)
    resolution_engine.import_enemy_lock(_stable_checkpoint.enemy_lock)
    action_timing_panel.restore_boundary_context(_stable_checkpoint.context)
    _committed_player_plan_snapshot = _stable_checkpoint.player_plan.duplicate(true)
    _committed_state_before = _stable_checkpoint.state_before.duplicate(true)
    _ultimate_reservation_anchors = PackedInt32Array(_stable_checkpoint.reservation_anchors)
    _last_review_summary = _stable_checkpoint.review_summary.duplicate(true)
    _terminal_handoff_started = false
    _terminal_confirmation_emitted = false
    _vertical_slice_terminal_result.clear()
    _clear_targeting()
    _sync_action_placement_controller_state()
    _apply_combat_state_to_view()
    _sync_runtime_context()
    _applied_restoration = fingerprint
    _checkpoint_restoring = false
    match _stable_checkpoint.phase:
        "PLANNING":
            _set_presentation_state("next_bundle_ready")
        "BUNDLE_COMMITTED":
            _set_presentation_state("committed")
            var result: Dictionary = resolution_engine.resolve_bundle(_committed_player_plan_snapshot, _stable_checkpoint.context, combat_state)
            _resolution_count += 1
            _last_review_summary = review_summary_builder.build_summary(result, _committed_player_plan_snapshot, _committed_state_before)
            if _accept_resolved_boundary(result):
                combat_state = result.state.duplicate(true)
                _finalize_resolved_bundle()
        "BUNDLE_RESOLVED":
            _finalize_resolved_bundle()
    _sync_action_selection_dock()
    return {"ok": true, "status": "RESTORED", "pending": _checkpoint_pending}


func get_vertical_slice_player_resources() -> Dictionary:
    return _player_resource_snapshot()


func get_vertical_slice_loadout_snapshot() -> Dictionary:
    return _vertical_slice_loadout_snapshot.duplicate(true)


func _build_action_selection_runtime_context() -> Dictionary:
    var context := super._build_action_selection_runtime_context()
    if resolution_engine == null or not resolution_engine.has_method("get_bimu_receipt"):
        return context
    var reasons := {}
    for card_id in resolution_engine.cards_by_id:
        var reason: String = resolution_engine.get_action_lock_reason(str(card_id))
        if not reason.is_empty():
            reasons[str(card_id)] = reason
    context["constraint_lock_reasons"] = reasons
    var receipt: Dictionary = resolution_engine.get_bimu_receipt()
    var effects: Array = receipt.get("disclosed_effects", [])
    var names := PackedStringArray()
    for selection in receipt.get("selections", []):
        for option in _bimu_ui_options:
            if str(option["constraint_id"]) == str(selection.get("constraint_id", "")):
                var label := str(option["display_name_ko"])
                var field := str((option.get("parameter_binding", {}) as Dictionary).get("field", ""))
                if not field.is_empty():
                    var target := str(selection.get(field, ""))
                    label += " (%s)" % str(preload("res://src/ui/bimu_constraint_panel.gd").STAT_LABELS.get(target, resolution_engine.martial_registry.get_manual(target).get("manual_name", target)))
                names.append(label)
    context["constraint_summary"] = "이번 비무 · 제약 없음" if names.is_empty() else "이번 비무 · " + " / ".join(names)
    context["constraint_details"] = "\n".join(effects)
    return context


func _on_progress_requested(context: Dictionary) -> void:
    # Readiness may predate a receipt refresh; reject before commit/presentation mutation.
    if resolution_engine == null or action_timing_panel == null:
        return
    if not resolution_engine.preview_player_plan(combat_state, action_timing_panel.get_resolution_placements()).get("valid", false):
        return
    await super._on_progress_requested(context)


func _finish_bundle_presentation(terminal: bool) -> void:
    if terminal and _terminal_handoff_started:
        return
    if terminal:
        _terminal_handoff_started = true
    super._finish_bundle_presentation(terminal)
    if not terminal:
        return
    _vertical_slice_terminal_result = _build_vertical_slice_terminal_result()
    terminal_review_ready.emit(_vertical_slice_terminal_result.duplicate(true))
    call_deferred("_confirm_terminal_result_once")


func _confirm_terminal_result_once() -> void:
    if _vertical_slice_terminal_result.is_empty() or _terminal_confirmation_emitted:
        return
    _terminal_confirmation_emitted = true
    terminal_review_confirmed.emit(_vertical_slice_terminal_result.duplicate(true))


func _build_vertical_slice_terminal_result() -> Dictionary:
    var player_health := _current_health("player")
    var enemy_health := _current_health("enemy")
    var outcome := CombatResolutionEngine.battle_outcome(combat_state)

    var metrics := _battle_metrics_helper.make_initial_metrics() if _battle_metrics_helper != null else {}
    if combat_state.has("battle_metrics") and typeof(combat_state.get("battle_metrics")) == TYPE_DICTIONARY:
        metrics = _battle_metrics_helper.normalize(combat_state.get("battle_metrics", {})) if _battle_metrics_helper != null else (combat_state.get("battle_metrics", {}) as Dictionary).duplicate(true)

    return {
        "terminal": true,
        "outcome": outcome,
        "player_health": player_health,
        "enemy_health": enemy_health,
        "player_resources": _player_resource_snapshot(),
        "battle_metrics": metrics.duplicate(true),
        "review_summary": _last_review_summary.duplicate(true),
        "presentation_state": _presentation_state
    }


func _player_resource_snapshot() -> Dictionary:
    var player: Dictionary = combat_state.get("player", {})
    var result := {}
    for key in ["health", "stamina", "internal"]:
        var pair = player.get(key, [0, 0])
        if typeof(pair) == TYPE_ARRAY and pair.size() >= 2:
            result[key] = [int(pair[0]), int(pair[1])]
        elif typeof(pair) == TYPE_PACKED_INT32_ARRAY and pair.size() >= 2:
            result[key] = [int(pair[0]), int(pair[1])]
        else:
            result[key] = [0, 0]
    return result


func _valid_resource_pairs(resources: Dictionary) -> bool:
    for key in ["health", "stamina", "internal"]:
        var pair = resources.get(key, null)
        if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
            return false
    return true


func _current_health(actor_key: String) -> int:
    var actor: Dictionary = combat_state.get(actor_key, {})
    var health = actor.get("health", [0, 0])
    if typeof(health) == TYPE_ARRAY and health.size() >= 1:
        return int(health[0])
    if typeof(health) == TYPE_PACKED_INT32_ARRAY and health.size() >= 1:
        return int(health[0])
    return 0
