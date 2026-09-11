class_name VerticalSliceRunState
extends RefCounted

signal screen_changed(previous_screen: String, current_screen: String)

const PROGRESSION_SCRIPT := preload("res://src/run/vertical_slice_progression_state.gd")
const ROUTE_MODEL_SCRIPT := preload("res://src/run/vertical_slice_route_model.gd")
const STARTER_CATALOG_SCRIPT := preload("res://src/run/vertical_slice_starter_manual_catalog.gd")
const CONSTRAINT_SCRIPT := preload("res://src/run/bimu_constraint_model.gd")
const CHECKPOINT_CODEC := preload("res://src/run/run_checkpoint_codec.gd")
# An explicit versioned domain DTO, never Object.get_property_list serialization.
const SNAPSHOT_FIELDS := {
    "duel_index": "duel_index", "completed_duels": "completed_duels", "route_visits": "route_visits", "last_combat_result": "last_combat_result",
    "current_screen": "_current_screen", "flow_history": "_flow_history", "run_seed": "_run_seed", "current_opponent_id": "_current_opponent_id", "next_opponent_id": "_next_opponent_id",
    "player_manual_loadout": "_player_manual_loadout", "player_mastery_by_manual": "_player_mastery_by_manual", "pending_result_reward": "_pending_result_reward", "reward_history": "_reward_history", "duel_history": "_duel_history",
    "pending_growth_route": "_pending_growth_route", "pending_route_intel": "_pending_route_intel", "route_history": "_route_history", "intel_by_candidate": "_intel_by_candidate", "pre_battle_snapshot": "_pre_battle_snapshot",
    "retry_count": "_retry_count", "attempt_id": "_attempt_id", "failure_receipt": "_failure_receipt", "jianghu_step": "jianghu_step", "pending_jianghu": "_pending_jianghu", "pending_bimu_constraints": "_pending_bimu_constraints", "frozen_bimu_receipt": "_frozen_bimu_receipt"
}


const ROSTER_FIELDS := ["ruleset_id", "roster_version", "roster_seed", "roster_save_id", "resolved_encounters", "roster_digest"]
var _roster: Dictionary = {}

func export_snapshot() -> Dictionary:
    var snapshot := {"progression": _progression.get_snapshot()}
    for key in SNAPSHOT_FIELDS: snapshot[key] = get(SNAPSHOT_FIELDS[key])
    snapshot.merge(_roster, true)
    return snapshot.duplicate(true)


func validate_snapshot(snapshot: Dictionary) -> Dictionary:
    var bad := CHECKPOINT_CODEC.error("CORRUPT", "Invalid run snapshot")
    var variable: bool = snapshot.has("ruleset_id")
    if not CHECKPOINT_CODEC.json_safe(snapshot, 0, [0]) or snapshot.size() != SNAPSHOT_FIELDS.size() + 1 + (ROSTER_FIELDS.size() if variable else 0): return bad
    if variable and not _valid_roster(snapshot): return bad
    var template := {"progression": _progression.get_snapshot()}
    for key in SNAPSHOT_FIELDS: template[key] = get(SNAPSHOT_FIELDS[key])
    for key in template:
        if not snapshot.has(key): return bad
        if typeof(template[key]) == TYPE_INT:
            if not CHECKPOINT_CODEC.integer(snapshot[key]): return bad
        elif typeof(template[key]) != typeof(snapshot[key]): return bad
    var s: Dictionary = CHECKPOINT_CODEC.normalized(snapshot)
    var screens := [SCREEN_MAIN, SCREEN_SETUP, SCREEN_INTRO, SCREEN_BRIEFING, SCREEN_COMBAT, SCREEN_REVIEW, SCREEN_FAILURE_RETRY, SCREEN_RESULT, SCREEN_JIANGHU, SCREEN_COMPLETION]
    if s.current_screen not in screens or s.flow_history.is_empty() or s.flow_history[-1] != s.current_screen: return bad
    for screen in s.flow_history:
        if typeof(screen) != TYPE_STRING or screen not in screens: return bad
    if not CHECKPOINT_CODEC.integer(s.duel_index, 1, MAX_DUELS) or not CHECKPOINT_CODEC.integer(s.completed_duels, 0, MAX_DUELS) or not CHECKPOINT_CODEC.integer(s.route_visits, 0, 36) or not CHECKPOINT_CODEC.integer(s.jianghu_step, 0, 4): return bad
    if not CHECKPOINT_CODEC.integer(s.retry_count, 0, 1) or s.attempt_id != s.retry_count: return bad
    if not _progression.validate_snapshot(s.progression).ok: return bad
    var catalog = _catalog_for_snapshot(snapshot)
    if not catalog.is_valid(): return bad
    if s.current_screen != SCREEN_MAIN and s.current_opponent_id != catalog.select_campaign_candidate_id(s.duel_index): return bad
    if not s.next_opponent_id.is_empty() and (s.completed_duels >= MAX_DUELS or s.next_opponent_id != catalog.select_campaign_candidate_id(s.completed_duels + 1)): return bad
    for id in s.player_manual_loadout:
        if typeof(id) != TYPE_STRING: return bad
    if not s.player_manual_loadout.is_empty():
        if not _starter_catalog.validate_selection(s.player_manual_loadout) or s.player_mastery_by_manual.size() != STARTER_SELECTION_COUNT: return bad
        for id in s.player_manual_loadout:
            if s.player_mastery_by_manual.get(id) != STARTER_MASTERY or not CHECKPOINT_CODEC.integer(s.player_mastery_by_manual.get(id), 3, 3) or id not in s.progression.owned_manual_ids: return bad
    elif s.current_screen not in [SCREEN_MAIN, SCREEN_SETUP] or not s.player_mastery_by_manual.is_empty() or not s.progression.owned_manual_ids.is_empty(): return bad
    for key in ["reward_history", "duel_history", "route_history", "pending_bimu_constraints"]:
        for row in s[key]:
            if typeof(row) != TYPE_DICTIONARY: return bad
    if s.duel_history.size() != s.completed_duels or s.route_history.size() != s.route_visits: return bad
    for i in range(s.duel_history.size()):
        var row: Dictionary = s.duel_history[i]
        if row.get("duel_index") != i + 1 or not CHECKPOINT_CODEC.integer(row.get("duel_index"), 1, 10) or row.get("opponent_candidate_id") != catalog.select_campaign_candidate_id(i + 1) or row.get("outcome") not in ["win", "draw"]: return bad
        if typeof(row.get("battle_metrics")) != TYPE_DICTIONARY or typeof(row.get("review_summary")) != TYPE_DICTIONARY: return bad
        for value in row.battle_metrics.values():
            if not CHECKPOINT_CODEC.integer(value): return bad
    var terminal_success: bool = s.current_screen in [SCREEN_RESULT, SCREEN_JIANGHU, SCREEN_COMPLETION] or (s.current_screen == SCREEN_REVIEW and s.last_combat_result.get("outcome") in ["win", "draw"])
    if s.completed_duels != s.duel_index - (0 if terminal_success else 1): return bad
    var unconfirmed: bool = s.current_screen == SCREEN_RESULT or (s.current_screen == SCREEN_REVIEW and terminal_success)
    if s.reward_history.size() != s.completed_duels - (1 if unconfirmed else 0): return bad
    if s.current_screen == SCREEN_COMPLETION and s.completed_duels != MAX_DUELS: return bad
    if s.current_screen == SCREEN_JIANGHU:
        if s.completed_duels < 1 or s.completed_duels >= 10 or s.jianghu_step >= 4 or s.next_opponent_id.is_empty(): return bad
        if s.route_visits != (s.completed_duels - 1) * 4 + s.jianghu_step: return bad
    elif s.route_visits != mini(s.duel_index - 1, 9) * 4: return bad
    if not s.pending_growth_route.is_empty() or not s.pending_route_intel.is_empty(): return bad # Retired two-node flow is not schema 1.
    for i in range(s.reward_history.size()):
        var row: Dictionary = s.reward_history[i]
        if row.get("duel_index") != i + 1 or row.get("opponent_candidate_id") != catalog.select_campaign_candidate_id(i + 1) or not _valid_reward(row, s.player_manual_loadout, catalog.get_candidate(catalog.select_campaign_candidate_id(i + 1))): return bad
    if not s.pending_result_reward.is_empty() and (s.current_screen != SCREEN_RESULT or not _valid_reward(s.pending_result_reward, s.player_manual_loadout, catalog.get_candidate(s.current_opponent_id))): return bad
    for i in range(s.route_history.size()):
        if not _valid_jianghu_receipt(s.route_history[i], i / 4 + 1, i % 4, catalog): return bad
    if not s.pending_jianghu.is_empty() and (s.current_screen != SCREEN_JIANGHU or not _valid_jianghu_receipt(s.pending_jianghu, s.completed_duels, s.jianghu_step, catalog)): return bad
    if not _valid_progression_history(s, catalog): return bad
    # Rebuild accumulated public intel from saved receipts, without applying their effects.
    var intel_candidate = get_script().new()
    for receipt in s.route_history:
        if receipt.get("id") in ["recon", "investigate"]: intel_candidate._record_candidate_intel(receipt)
    if s.pending_jianghu.get("id") in ["recon", "investigate"]: intel_candidate._record_candidate_intel(s.pending_jianghu)
    if intel_candidate._intel_by_candidate != s.intel_by_candidate: return bad
    var enemy_candidate: Dictionary = catalog.get_candidate(s.current_opponent_id)
    if variable: enemy_candidate = catalog.for_stage(s.duel_index)
    var receipt: Dictionary = _bimu_model.validate_selection(s.pending_bimu_constraints, s.player_manual_loadout, _manual_ids(enemy_candidate))
    if not receipt.valid or receipt.selections != s.pending_bimu_constraints: return bad
    if not s.frozen_bimu_receipt.is_empty():
        receipt["duel_index"] = s.duel_index
        receipt["run_seed"] = s.run_seed
        receipt["enemy_candidate_id"] = s.current_opponent_id
        if receipt != s.frozen_bimu_receipt: return bad
    if s.current_screen in [SCREEN_COMBAT, SCREEN_REVIEW, SCREEN_RESULT, SCREEN_FAILURE_RETRY, SCREEN_COMPLETION] and (s.frozen_bimu_receipt.is_empty() or s.pre_battle_snapshot.is_empty()): return bad
    if not s.pre_battle_snapshot.is_empty() and not _valid_prebattle(s, catalog): return bad
    if s.current_screen == SCREEN_FAILURE_RETRY or (s.current_screen == SCREEN_REVIEW and not terminal_success):
        if s.last_combat_result.get("outcome") != "loss" or s.failure_receipt.get("duel_index") != s.duel_index or s.failure_receipt.get("attempt_id") != s.attempt_id or s.failure_receipt.get("retry_count") != s.retry_count or typeof(s.failure_receipt.get("review_causes")) != TYPE_ARRAY: return bad
    elif not s.failure_receipt.is_empty(): return bad
    if not s.last_combat_result.is_empty():
        if s.last_combat_result.get("outcome") not in ["win", "loss", "draw"] or not CHECKPOINT_CODEC.integer(s.last_combat_result.get("attempt_id"), 0, 1): return bad
        if s.last_combat_result.has("player_resources") and not PROGRESSION_SCRIPT.validate_resource_snapshot(s.last_combat_result.player_resources): return bad
    return {"ok": true, "status": "VALID"}


func _valid_reward(receipt: Dictionary, loadout: Array, opponent: Dictionary) -> bool:
    match receipt.get("reward_type"):
        "free_training":
            return CHECKPOINT_CODEC.integer(receipt.get("free_training"), 6, 6) and CHECKPOINT_CODEC.integer(receipt.get("focused_training", 0), 0, 0)
        "focused_training":
            return CHECKPOINT_CODEC.integer(receipt.get("free_training"), 3, 3) and CHECKPOINT_CODEC.integer(receipt.get("focused_training"), 5, 5) and typeof(receipt.get("target_manual_id")) == TYPE_STRING and receipt.target_manual_id in loadout
        "faction_transfer":
            return receipt.get("manual_id") == opponent.get("signature_manual_id") and CHECKPOINT_CODEC.integer(receipt.get("mastery"), 3, 3)
    return false


func _valid_progression_history(s: Dictionary, catalog) -> bool:
    # Validate accounting in a disposable domain model. Import never replays effects on live state.
    var audit = get_script().new()
    audit.configure_opponents(catalog, s.run_seed)
    if s.has("ruleset_id"):
        for key in ROSTER_FIELDS: audit._roster[key] = s[key]
    if not s.player_manual_loadout.is_empty():
        audit.start_new_run()
        if not audit.confirm_setup_loadout(s.player_manual_loadout, s.player_mastery_by_manual): return false
    for row in s.reward_history:
        var receipt: Dictionary = row.duplicate(true)
        receipt.erase("duel_index")
        receipt.erase("opponent_candidate_id")
        if audit._progression.apply_reward_receipt(receipt).is_empty(): return false
    var routes: Array = s.route_history.duplicate(true)
    if not s.pending_jianghu.is_empty(): routes.append(s.pending_jianghu)
    for index in range(routes.size()):
        var duel := index / JIANGHU_CHOICES + 1
        var step := index % JIANGHU_CHOICES
        audit._current_screen = SCREEN_JIANGHU
        audit.completed_duels = duel
        audit.duel_index = duel
        audit.jianghu_step = step
        audit._next_opponent_id = catalog.select_campaign_candidate_id(duel + 1)
        audit._pending_jianghu.clear()
        if not audit.select_jianghu_node(routes[index].id, step): return false
    var expected: Dictionary = audit.get_progression_snapshot()
    for key in ["owned_manual_ids", "mastery_by_manual", "training_by_manual", "free_training_pool", "pending_duplicate_transfers"]:
        if expected[key] != s.progression[key]: return false
    return true


func _valid_jianghu_receipt(receipt: Dictionary, duel: int, step: int, catalog) -> bool:
    var expected := {}
    for option in _route_model.get_jianghu_options(duel, step):
        if option.id == receipt.get("id"): expected = option.duplicate(true)
    if expected.is_empty(): return false
    if expected.id in ["recon", "investigate"]:
        var candidate: Dictionary = catalog.for_stage(duel + 1) if catalog.has_method("for_stage") else catalog.get_candidate(catalog.select_campaign_candidate_id(duel + 1))
        if candidate.has("encounter_id"): expected["encounter_id"] = candidate.encounter_id
        expected["category"] = "MANUAL_RUMOR" if expected.id == "recon" else "FOOTWORK_SIGHTING"
        expected["candidate_id"] = candidate.candidate_id
        expected["text"] = _route_model.build_public_intel(expected.category, candidate)
    expected["node_id"] = "J%d-%d" % [duel, step + 1]
    expected["route_type"] = expected.id
    return expected == receipt


func _valid_prebattle(s: Dictionary, _catalog) -> bool:
    var p: Dictionary = s.pre_battle_snapshot
    var expected_keys := ["run_seed", "duel_index", "completed_duels", "route_visits", "current_opponent_id", "next_opponent_id", "bimu_receipt", "progression", "duel_history", "reward_history", "route_history", "intel_by_candidate"]
    if p.size() != expected_keys.size(): return false
    for key in expected_keys:
        if not p.has(key): return false
    for key in ["run_seed", "duel_index", "route_visits", "current_opponent_id"]:
        if p[key] != s[key]: return false
    if not CHECKPOINT_CODEC.integer(p.completed_duels, 0, 9) or p.completed_duels != s.duel_index - 1 or p.next_opponent_id != "" or p.bimu_receipt != s.frozen_bimu_receipt: return false
    if typeof(p.progression) != TYPE_DICTIONARY or not _progression.validate_snapshot(p.progression).ok: return false
    var expected_progression: Dictionary = p.progression
    if s.current_screen == SCREEN_COMPLETION:
        var check_progression = PROGRESSION_SCRIPT.new()
        check_progression.import_snapshot(p.progression)
        var final_reward: Dictionary = s.reward_history[-1].duplicate(true)
        final_reward.erase("duel_index")
        final_reward.erase("opponent_candidate_id")
        if check_progression.apply_reward_receipt(final_reward).is_empty(): return false
        expected_progression = check_progression.get_snapshot()
    for key in ["owned_manual_ids", "mastery_by_manual", "training_by_manual", "free_training_pool", "pending_duplicate_transfers"]:
        if expected_progression[key] != s.progression[key]: return false
    if s.last_combat_result.get("outcome") not in ["win", "draw"] and p.progression.player_resources != s.progression.player_resources: return false
    for key in ["duel_history", "reward_history", "route_history"]:
        if typeof(p[key]) != TYPE_ARRAY or p[key].size() > s[key].size() or p[key] != s[key].slice(0, p[key].size()): return false
    return p.duel_history.size() == p.completed_duels and p.reward_history.size() == p.completed_duels and p.route_history == s.route_history and p.intel_by_candidate == s.intel_by_candidate


func import_snapshot(snapshot: Dictionary) -> Dictionary:
    var validation := validate_snapshot(snapshot)
    if not validation.ok: return validation
    var next: Dictionary = CHECKPOINT_CODEC.normalized(snapshot)
    var progression = PROGRESSION_SCRIPT.new()
    progression.import_snapshot(next.progression)
    var catalog = _catalog_for_snapshot(snapshot)
    # All validation/model reconstruction precedes live assignment. No signals or effects replay.
    for key in SNAPSHOT_FIELDS:
        var property: String = SNAPSHOT_FIELDS[key]
        if typeof(next[key]) == TYPE_ARRAY:
            get(property).assign(next[key])
        else:
            set(property, next[key])
    _progression = progression
    _roster = {}
    if snapshot.has("ruleset_id"):
        for key in ROSTER_FIELDS: _roster[key] = next[key]
    _opponent_catalog = catalog
    return {"ok": true, "status": "VALID"}

const SCREEN_MAIN := "MAIN"
const SCREEN_SETUP := "SETUP"
const SCREEN_INTRO := "INTRO"
const SCREEN_BRIEFING := "BRIEFING"
const SCREEN_COMBAT := "COMBAT"
const SCREEN_REVIEW := "REVIEW"
const SCREEN_FAILURE_RETRY := "FAILURE_RETRY"
const SCREEN_RESULT := "RESULT"
const SCREEN_ROUTE_GROWTH := "ROUTE_GROWTH"
const SCREEN_ROUTE_INFO := "ROUTE_INFO"
const SCREEN_COMPLETION := "COMPLETION"
const MAX_DUELS := 10
const SCREEN_JIANGHU := "JIANGHU"
const JIANGHU_CHOICES := 4
const STARTER_SELECTION_COUNT := 4
const STARTER_MASTERY := 3

var duel_index: int = 1
var completed_duels: int = 0
var route_visits: int = 0
var last_combat_result: Dictionary = {}

var _current_screen: String = SCREEN_MAIN
var _flow_history: Array[String] = [SCREEN_MAIN]
var _opponent_catalog = null
var _run_seed: int = 0
var _current_opponent_id: String = ""
var _next_opponent_id: String = ""
var _player_manual_loadout: Array[String] = []
var _player_mastery_by_manual: Dictionary = {}
var _pending_result_reward: Dictionary = {}
var _reward_history: Array[Dictionary] = []
var _duel_history: Array[Dictionary] = []
var _progression: RefCounted
var _route_model: RefCounted
var _starter_catalog: RefCounted
var _pending_growth_route: Dictionary = {}
var _pending_route_intel: Dictionary = {}
var _route_history: Array[Dictionary] = []
var _intel_by_candidate: Dictionary = {}
var _pre_battle_snapshot: Dictionary = {}
var _retry_count: int = 0
var _attempt_id: int = 0
var _failure_receipt: Dictionary = {}
var jianghu_step: int = 0
var _pending_jianghu: Dictionary = {}
var _pending_bimu_constraints: Array = []
var _frozen_bimu_receipt: Dictionary = {}
var _bimu_model = CONSTRAINT_SCRIPT.new()


func select_bimu_constraints(selection: Array) -> bool:
    if _current_screen != SCREEN_BRIEFING or not _frozen_bimu_receipt.is_empty():
        return false
    var receipt := validate_bimu_constraints(selection)
    if not receipt.get("valid", false):
        return false
    _pending_bimu_constraints = receipt["selections"].duplicate(true)
    return true


func validate_bimu_constraints(selection: Array) -> Dictionary:
    var enemy_ids: Array = _manual_ids(get_current_opponent())
    return _bimu_model.validate_selection(selection, get_player_manual_loadout(), enemy_ids)


func get_pending_bimu_constraints() -> Array:
    return _pending_bimu_constraints.duplicate(true)


func get_frozen_bimu_receipt() -> Dictionary:
    return _frozen_bimu_receipt.duplicate(true)


func _freeze_bimu_constraints() -> bool:
    var receipt := validate_bimu_constraints(_pending_bimu_constraints)
    if not receipt.get("valid", false):
        return false
    receipt["duel_index"] = duel_index
    receipt["run_seed"] = _run_seed
    receipt["enemy_candidate_id"] = _current_opponent_id
    _frozen_bimu_receipt = receipt.duplicate(true)
    return true


func _reset_bimu_constraints() -> void:
    _pending_bimu_constraints.clear()
    _frozen_bimu_receipt.clear()


func get_jianghu_options() -> Array:
    if _current_screen != SCREEN_JIANGHU or _route_model == null:
        return []
    return _route_model.get_jianghu_options(completed_duels, jianghu_step)


func get_pending_jianghu() -> Dictionary:
    return _pending_jianghu.duplicate(true)


func select_jianghu_node(node_id: String, expected_step: int) -> bool:
    if _current_screen != SCREEN_JIANGHU or _progression == null or _route_model == null:
        return false
    if completed_duels < 1 or completed_duels >= MAX_DUELS or duel_index != completed_duels:
        return false
    if expected_step != jianghu_step or expected_step < 0 or expected_step >= JIANGHU_CHOICES or not _pending_jianghu.is_empty():
        return false
    var selected: Dictionary = {}
    for option in get_jianghu_options():
        if typeof(option) == TYPE_DICTIONARY and str((option as Dictionary).get("id", "")) == node_id:
            selected = (option as Dictionary).duplicate(true)
            break
    if selected.is_empty():
        return false
    var candidate := get_route_target_opponent()
    match node_id:
        "rest":
            _progression.apply_recovery(0.25, 1, 1)
        "training":
            if not _progression.add_free_training(3):
                return false
        "event":
            if not _progression.add_free_training(2):
                return false
            _progression.apply_recovery(0.0, 0, 1)
        "recon", "investigate":
            if candidate.is_empty():
                return false
            var category := "MANUAL_RUMOR" if node_id == "recon" else "FOOTWORK_SIGHTING"
            var text: String = _route_model.build_public_intel(category, candidate)
            if text.is_empty():
                return false
            selected["text"] = text
            selected["candidate_id"] = candidate["candidate_id"]
            if candidate.has("encounter_id"): selected["encounter_id"] = candidate.encounter_id
            selected["category"] = category
            if node_id == "investigate":
                if not _progression.add_free_training(1):
                    return false
        _:
            return false
    selected["route_type"] = node_id
    selected["node_id"] = "J%d-%d" % [completed_duels, jianghu_step + 1]
    if node_id in ["recon", "investigate"]:
        _record_candidate_intel(selected)
    _pending_jianghu = selected
    return true


func _init() -> void:
    _progression = PROGRESSION_SCRIPT.new()
    _progression.reset()
    _route_model = ROUTE_MODEL_SCRIPT.new()
    _starter_catalog = STARTER_CATALOG_SCRIPT.new()


func get_current_screen() -> String:
    return _current_screen


func get_run_seed() -> int:
    return _run_seed


func get_retry_remaining() -> int:
    return 1 if _retry_count == 0 and not _pre_battle_snapshot.is_empty() else 0


func get_failure_receipt() -> Dictionary:
    return _failure_receipt.duplicate(true)


func get_flow_history() -> Array[String]:
    return _flow_history.duplicate()


func configure_opponents(catalog, run_seed: int) -> bool:
    if _current_screen != SCREEN_MAIN:
        return false
    if catalog == null or not catalog.has_method("is_valid") or not catalog.is_valid():
        return false
    if not catalog.has_method("select_campaign_candidate_id") or not catalog.has_method("get_candidate"):
        return false
    _opponent_catalog = catalog
    _run_seed = run_seed
    _current_opponent_id = ""
    _next_opponent_id = ""
    return true


func get_current_opponent() -> Dictionary:
    if _opponent_catalog == null or _current_opponent_id.is_empty():
        return {}
    return _opponent_catalog.for_stage(duel_index) if not _roster.is_empty() else _opponent_catalog.get_candidate(_current_opponent_id)


func get_route_target_opponent() -> Dictionary:
    if _opponent_catalog == null or _next_opponent_id.is_empty():
        return {}
    return _opponent_catalog.for_stage(completed_duels + 1) if not _roster.is_empty() else _opponent_catalog.get_candidate(_next_opponent_id)


func confirm_setup_loadout(loadout, mastery_by_manual: Dictionary) -> bool:
    if _current_screen != SCREEN_SETUP:
        return false
    if _starter_catalog == null or not _starter_catalog.is_valid() or not _starter_catalog.validate_selection(loadout):
        return false
    if typeof(loadout) != TYPE_ARRAY and typeof(loadout) != TYPE_PACKED_STRING_ARRAY:
        return false
    if loadout.size() != STARTER_SELECTION_COUNT:
        return false
    var next_loadout: Array[String] = []
    var seen := {}
    for value in loadout:
        var manual_id := str(value)
        if manual_id.is_empty() or seen.has(manual_id):
            return false
        if int(mastery_by_manual.get(manual_id, 0)) != STARTER_MASTERY:
            return false
        seen[manual_id] = true
        next_loadout.append(manual_id)
    if not _progression.initialize_from_setup(next_loadout, mastery_by_manual):
        return false
    _player_manual_loadout = next_loadout
    _player_mastery_by_manual = mastery_by_manual.duplicate(true)
    return true


func get_player_manual_loadout() -> Array:
    return _player_manual_loadout.duplicate()


func get_player_mastery_by_manual() -> Dictionary:
    if _progression != null:
        return (_progression.get_snapshot().get("mastery_by_manual", {}) as Dictionary).duplicate(true)
    return _player_mastery_by_manual.duplicate(true)


func get_player_run_resources() -> Dictionary:
    return _progression.get_player_resources() if _progression != null else {}


func get_progression_snapshot() -> Dictionary:
    return _progression.get_snapshot() if _progression != null else {}


func get_duel_history() -> Array:
    var result: Array = []
    for receipt in _duel_history:
        result.append(receipt.duplicate(true))
    return result


func has_pending_growth_route() -> bool:
    return not _pending_growth_route.is_empty()


func get_growth_route_options() -> Array:
    if _current_screen != SCREEN_ROUTE_GROWTH or _route_model == null or _progression == null:
        return []
    var node_id: String = _route_model.growth_node_id(completed_duels)
    return _route_model.get_growth_options(node_id, _progression.owned_manual_ids)


func get_info_route_options() -> Array:
    if _current_screen != SCREEN_ROUTE_INFO or _route_model == null:
        return []
    var node_id: String = _route_model.info_node_id(completed_duels)
    return _route_model.get_info_options(node_id, get_route_target_opponent())


func select_growth_route(choice_type: String, target_manual_id: String = "") -> bool:
    if _current_screen != SCREEN_ROUTE_GROWTH or _progression == null or _route_model == null:
        return false
    if not _pending_growth_route.is_empty():
        return false
    var node_id: String = _route_model.growth_node_id(completed_duels)
    var options: Array = _route_model.get_growth_options(node_id, _progression.owned_manual_ids)
    var selected: Dictionary = {}
    for value in options:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("choice_type", "")) == choice_type:
            selected = (value as Dictionary).duplicate(true)
            break
    if selected.is_empty():
        return false
    match choice_type:
        "recovery":
            _progression.apply_recovery(
                float(selected.get("health_fraction", 0.0)),
                int(selected.get("stamina", 0)),
                int(selected.get("internal", 0))
            )
        "focused_training":
            if target_manual_id.is_empty() or not _progression.add_focused_training(target_manual_id, int(selected.get("focused_training", 0))):
                return false
            selected["target_manual_id"] = target_manual_id
        "free_training":
            if not _progression.add_free_training(int(selected.get("free_training", 0))):
                return false
        _:
            return false
    selected["node_id"] = node_id
    selected["route_type"] = "growth"
    _pending_growth_route = selected
    return true


func select_info_route(category: String) -> bool:
    if _current_screen != SCREEN_ROUTE_INFO or _route_model == null:
        return false
    if not _pending_route_intel.is_empty():
        return false
    var candidate := get_route_target_opponent()
    if candidate.is_empty():
        return false
    var node_id: String = _route_model.info_node_id(completed_duels)
    var valid := false
    for value in _route_model.get_info_options(node_id, candidate):
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("category", "")) == category:
            valid = true
            break
    if not valid:
        return false
    var text: String = _route_model.build_public_intel(category, candidate)
    if text.is_empty():
        return false
    _pending_route_intel = {
        "node_id": node_id,
        "route_type": "info",
        "candidate_id": str(candidate.get("candidate_id", "")),
        "category": category,
        "text": text
    }
    return true


func get_pending_route_intel() -> Dictionary:
    return _pending_route_intel.duplicate(true)


func get_current_opponent_intel() -> Dictionary:
    var intel_key := str(get_current_encounter().get("encounter_id", _current_opponent_id))
    if intel_key.is_empty() or not _intel_by_candidate.has(intel_key):
        return {}
    return (_intel_by_candidate[intel_key] as Dictionary).duplicate(true)


func get_route_history() -> Array:
    var result: Array = []
    for receipt in _route_history:
        result.append(receipt.duplicate(true))
    return result


func set_pending_result_reward(receipt: Dictionary) -> bool:
    if _current_screen != SCREEN_RESULT or receipt.is_empty() or not _pending_result_reward.is_empty():
        return false
    var reward_type := str(receipt.get("reward_type", ""))
    if reward_type not in ["free_training", "focused_training", "faction_transfer"]:
        return false
    _pending_result_reward = receipt.duplicate(true)
    return true


func get_pending_result_reward() -> Dictionary:
    return _pending_result_reward.duplicate(true)


func get_reward_history() -> Array:
    var result: Array = []
    for receipt in _reward_history:
        result.append(receipt.duplicate(true))
    return result


func start_new_run() -> bool:
    if _current_screen != SCREEN_MAIN:
        return false
    _reset_bimu_constraints()
    duel_index = 1
    completed_duels = 0
    route_visits = 0
    last_combat_result.clear()
    _flow_history = [SCREEN_MAIN]
    _current_opponent_id = ""
    _next_opponent_id = ""
    _player_manual_loadout.clear()
    _player_mastery_by_manual.clear()
    _pending_result_reward.clear()
    _reward_history.clear()
    _duel_history.clear()
    _pending_growth_route.clear()
    _pending_route_intel.clear()
    _route_history.clear()
    _intel_by_candidate.clear()
    _pre_battle_snapshot.clear()
    _failure_receipt.clear()
    _retry_count = 0
    _attempt_id = 0
    _progression.reset()
    jianghu_step = 0
    _pending_jianghu.clear()
    if _opponent_catalog != null:
        _current_opponent_id = str(_opponent_catalog.select_campaign_candidate_id(1))
        if _current_opponent_id.is_empty():
            return false
    return _transition_to(SCREEN_SETUP)


func advance() -> bool:
    match _current_screen:
        SCREEN_SETUP:
            return _transition_to(SCREEN_INTRO)
        SCREEN_INTRO:
            return _transition_to(SCREEN_BRIEFING)
        SCREEN_BRIEFING:
            if not _freeze_bimu_constraints():
                return false
            _capture_pre_battle_snapshot_if_needed()
            return _transition_to(SCREEN_COMBAT)
        SCREEN_COMBAT:
            return false
        SCREEN_REVIEW:
            if str(last_combat_result.get("outcome", "")) == "loss":
                return _transition_to(SCREEN_FAILURE_RETRY)
            return _transition_to(SCREEN_RESULT)
        SCREEN_RESULT:
            if _pending_result_reward.is_empty():
                return false
            if completed_duels >= MAX_DUELS:
                if not _confirm_pending_result_reward():
                    return false
                return _transition_to(SCREEN_COMPLETION)
            if not _lock_next_opponent_if_configured():
                return false
            if not _confirm_pending_result_reward():
                return false
            _pending_growth_route.clear()
            _pending_route_intel.clear()
            _pre_battle_snapshot.clear()
            jianghu_step = 0
            _pending_jianghu.clear()
            return _transition_to(SCREEN_JIANGHU)
        SCREEN_JIANGHU:
            if completed_duels < 1 or completed_duels >= MAX_DUELS or duel_index != completed_duels:
                return false
            if jianghu_step < 0 or jianghu_step >= JIANGHU_CHOICES or _pending_jianghu.is_empty():
                return false
            if str(_pending_jianghu.get("node_id", "")) != "J%d-%d" % [completed_duels, jianghu_step + 1]:
                return false
            if jianghu_step == JIANGHU_CHOICES - 1 and _opponent_catalog != null and _next_opponent_id.is_empty():
                return false
            _route_history.append(_pending_jianghu.duplicate(true))
            _pending_jianghu.clear()
            jianghu_step += 1
            route_visits += 1
            if jianghu_step < JIANGHU_CHOICES:
                screen_changed.emit(SCREEN_JIANGHU, SCREEN_JIANGHU)
                return true
            duel_index += 1
            _promote_next_opponent_if_configured()
            _reset_bimu_constraints()
            _pre_battle_snapshot.clear()
            _retry_count = 0
            _attempt_id = 0
            return _transition_to(SCREEN_BRIEFING)
        SCREEN_ROUTE_GROWTH:
            if _pending_growth_route.is_empty():
                return false
            _route_history.append(_pending_growth_route.duplicate(true))
            _pending_growth_route.clear()
            return _transition_to(SCREEN_ROUTE_INFO)
        SCREEN_ROUTE_INFO:
            if _pending_route_intel.is_empty():
                return false
            var intel_receipt := _pending_route_intel.duplicate(true)
            _route_history.append(intel_receipt)
            _record_candidate_intel(intel_receipt)
            _pending_route_intel.clear()
            duel_index += 1
            _promote_next_opponent_if_configured()
            _reset_bimu_constraints()
            _pre_battle_snapshot.clear()
            _retry_count = 0
            _attempt_id = 0
            return _transition_to(SCREEN_BRIEFING)
        _:
            return false


func mark_combat_finished(result: Dictionary) -> bool:
    if _current_screen != SCREEN_COMBAT:
        return false
    if duel_index < 1 or duel_index > MAX_DUELS or completed_duels != duel_index - 1:
        return false
    var outcome := str(result.get("outcome", ""))
    if outcome not in ["win", "loss", "draw"]:
        return false
    if not _has_valid_result_resources(result):
        return false
    if _opponent_catalog != null:
        var expected_opponent_id := str(_opponent_catalog.select_campaign_candidate_id(duel_index))
        if expected_opponent_id.is_empty() or _current_opponent_id != expected_opponent_id or get_current_opponent().is_empty():
            return false
    last_combat_result = result.duplicate(true)
    last_combat_result["attempt_id"] = _attempt_id
    if outcome == "loss":
        _failure_receipt = {
            "duel_index": duel_index,
            "attempt_id": _attempt_id,
            "retry_count": _retry_count,
            "review_causes": _extract_review_causes(result)
        }
        last_combat_result["review_causes"] = _failure_receipt["review_causes"]
        return _transition_to(SCREEN_REVIEW)
    var resources = result.get("player_resources", null)
    if typeof(resources) == TYPE_DICTIONARY and not _progression.set_player_resources(resources as Dictionary):
        return false
    _duel_history.append(_build_duel_history_row(result))
    _pending_result_reward.clear()
    completed_duels += 1
    return _transition_to(SCREEN_REVIEW)


func retry_failed_duel() -> bool:
    if _current_screen != SCREEN_FAILURE_RETRY or _retry_count != 0 or _pre_battle_snapshot.is_empty():
        return false
    var snapshot := _pre_battle_snapshot.duplicate(true)
    if not _restore_pre_battle_snapshot(snapshot):
        return false
    _retry_count = 1
    _attempt_id += 1
    _failure_receipt.clear()
    last_combat_result.clear()
    return _transition_to(SCREEN_COMBAT)


func end_failed_run() -> bool:
    if _current_screen != SCREEN_FAILURE_RETRY:
        return false
    _reset_bimu_constraints()
    last_combat_result.clear()
    _failure_receipt.clear()
    _pre_battle_snapshot.clear()
    _pending_result_reward.clear()
    _pending_growth_route.clear()
    _pending_route_intel.clear()
    _pending_jianghu.clear()
    _duel_history.clear()
    _reward_history.clear()
    _route_history.clear()
    _intel_by_candidate.clear()
    _player_manual_loadout.clear()
    _player_mastery_by_manual.clear()
    _current_opponent_id = ""
    _next_opponent_id = ""
    duel_index = 1
    completed_duels = 0
    route_visits = 0
    jianghu_step = 0
    _retry_count = 0
    _attempt_id = 0
    _progression.reset()
    return _transition_to(SCREEN_MAIN)


func _capture_pre_battle_snapshot_if_needed() -> void:
    if not _pre_battle_snapshot.is_empty():
        return
    _pre_battle_snapshot = {
        "run_seed": _run_seed,
        "duel_index": duel_index,
        "completed_duels": completed_duels,
        "route_visits": route_visits,
        "current_opponent_id": _current_opponent_id,
        "next_opponent_id": _next_opponent_id,
        "bimu_receipt": _frozen_bimu_receipt.duplicate(true),
        "progression": _progression.get_snapshot(),
        "duel_history": _duel_history.duplicate(true),
        "reward_history": _reward_history.duplicate(true),
        "route_history": _route_history.duplicate(true),
        "intel_by_candidate": _intel_by_candidate.duplicate(true)
    }


func _restore_pre_battle_snapshot(snapshot: Dictionary) -> bool:
    if snapshot.is_empty() or typeof(snapshot.get("progression", {})) != TYPE_DICTIONARY:
        return false
    var progression_snapshot: Dictionary = snapshot.get("progression", {})
    var duel_history_value = snapshot.get("duel_history", [])
    var reward_history_value = snapshot.get("reward_history", [])
    var route_history_value = snapshot.get("route_history", [])
    var intel_value = snapshot.get("intel_by_candidate", {})
    if typeof(duel_history_value) != TYPE_ARRAY or typeof(reward_history_value) != TYPE_ARRAY or typeof(route_history_value) != TYPE_ARRAY or typeof(intel_value) != TYPE_DICTIONARY:
        return false
    var receipt_value = snapshot.get("bimu_receipt", {})
    if typeof(receipt_value) != TYPE_DICTIONARY:
        return false
    var restored_receipt: Dictionary = receipt_value
    # Missing legacy receipt is only compatible with the explicit no-constraint default.
    if restored_receipt.is_empty():
        if not _pending_bimu_constraints.is_empty():
            return false
    else:
        if restored_receipt.get("duel_index") != snapshot.get("duel_index") or restored_receipt.get("run_seed") != snapshot.get("run_seed") or restored_receipt.get("enemy_candidate_id") != snapshot.get("current_opponent_id"):
            return false
        if restored_receipt != _frozen_bimu_receipt or typeof(restored_receipt.get("selections")) != TYPE_ARRAY:
            return false
        if not validate_bimu_constraints(restored_receipt["selections"]).get("valid", false):
            return false
    if not _progression.restore_snapshot(progression_snapshot):
        return false
    _frozen_bimu_receipt = restored_receipt.duplicate(true)
    _pending_bimu_constraints = restored_receipt.get("selections", []).duplicate(true)
    _run_seed = int(snapshot.get("run_seed", _run_seed))
    duel_index = int(snapshot.get("duel_index", duel_index))
    completed_duels = int(snapshot.get("completed_duels", completed_duels))
    route_visits = int(snapshot.get("route_visits", route_visits))
    _current_opponent_id = str(snapshot.get("current_opponent_id", ""))
    _next_opponent_id = str(snapshot.get("next_opponent_id", ""))
    _duel_history.assign((duel_history_value as Array).duplicate(true))
    _reward_history.assign((reward_history_value as Array).duplicate(true))
    _route_history.assign((route_history_value as Array).duplicate(true))
    _intel_by_candidate = (intel_value as Dictionary).duplicate(true)
    _pending_result_reward.clear()
    _pending_growth_route.clear()
    _pending_route_intel.clear()
    _pending_jianghu.clear()
    jianghu_step = 0
    return true


func _extract_review_causes(result: Dictionary) -> Array:
    var causes: Array = []
    if typeof(result.get("review_causes", [])) == TYPE_ARRAY:
        for value in result.get("review_causes", []):
            if typeof(value) == TYPE_DICTIONARY:
                causes.append((value as Dictionary).duplicate(true))
            if causes.size() >= 3:
                break
    if causes.is_empty():
        causes.append({"event": "combat_loss", "label": "전투에서 패배했습니다."})
    return causes


func _record_candidate_intel(receipt: Dictionary) -> void:
    var candidate_id := str(receipt.get("candidate_id", ""))
    var receipt_text := str(receipt.get("text", ""))
    if candidate_id.is_empty() or receipt_text.is_empty():
        return
    var entries: Array = []
    var intel_key := str(receipt.get("encounter_id", candidate_id))
    var existing_value = _intel_by_candidate.get(intel_key, {})
    if typeof(existing_value) == TYPE_DICTIONARY:
        var existing: Dictionary = existing_value
        var existing_entries = existing.get("entries", [])
        if existing.has("entries") and typeof(existing_entries) == TYPE_ARRAY:
            for value in existing_entries:
                if typeof(value) == TYPE_DICTIONARY:
                    entries.append((value as Dictionary).duplicate(true))
        elif not str(existing.get("text", "")).is_empty():
            entries.append(existing.duplicate(true))
    for entry in entries:
        if str((entry as Dictionary).get("text", "")) == receipt_text:
            return
    entries.append(receipt.duplicate(true))
    var combined := receipt.duplicate(true)
    var texts: Array[String] = []
    for entry in entries:
        var text := str((entry as Dictionary).get("text", ""))
        if not text.is_empty():
            texts.append(text)
    combined["entries"] = entries
    combined["text"] = "\n".join(texts)
    _intel_by_candidate[intel_key] = combined


func _has_valid_result_resources(result: Dictionary) -> bool:
    if not result.has("player_resources"):
        return true
    var resources = result.get("player_resources")
    if typeof(resources) != TYPE_DICTIONARY:
        return false
    for key in ["health", "stamina", "internal"]:
        var pair = (resources as Dictionary).get(key, null)
        if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
            return false
    return true


func is_complete() -> bool:
    return _current_screen == SCREEN_COMPLETION and completed_duels == MAX_DUELS


func _build_duel_history_row(result: Dictionary) -> Dictionary:
    var opponent := get_current_opponent()
    var review_source = result.get("review_summary", {})
    var review: Dictionary = review_source if typeof(review_source) == TYPE_DICTIONARY else {}
    var metrics_source = result.get("battle_metrics", {})
    var metrics: Dictionary = metrics_source if typeof(metrics_source) == TYPE_DICTIONARY else {}
    return {
        "duel_index": duel_index,
        "opponent_candidate_id": _current_opponent_id,
        "opponent_working_name": str(opponent.get("working_name", "")),
        "outcome": str(result.get("outcome", "draw")),
        "review_summary": {
            "cause_code": str(review.get("cause_code", "")),
            "cause_label": str(review.get("cause_label", "")),
            "review_focus": str(review.get("review_focus", ""))
        },
        "battle_metrics": {
            "successful_dodges": maxi(0, int(metrics.get("successful_dodges", 0))),
            "clash_wins": maxi(0, int(metrics.get("clash_wins", 0))),
            "player_health_lost": maxi(0, int(metrics.get("player_health_lost", 0))),
            "rounds_elapsed": maxi(0, int(metrics.get("rounds_elapsed", 0))),
            "ultimate_uses": maxi(0, int(metrics.get("ultimate_uses", 0)))
        }
    }


func _confirm_pending_result_reward() -> bool:
    if _pending_result_reward.is_empty() or _progression == null:
        return false
    var receipt := _pending_result_reward.duplicate(true)
    var applied: Dictionary = _progression.apply_reward_receipt(receipt)
    if applied.is_empty():
        return false
    applied["duel_index"] = completed_duels
    applied["opponent_candidate_id"] = _current_opponent_id
    _reward_history.append(applied)
    _pending_result_reward.clear()
    return true


func _lock_next_opponent_if_configured() -> bool:
    if _opponent_catalog == null:
        return true
    if not _next_opponent_id.is_empty():
        return true
    var next_slot := completed_duels + 1
    if next_slot > MAX_DUELS:
        return true
    _next_opponent_id = str(_opponent_catalog.select_campaign_candidate_id(next_slot))
    return not _next_opponent_id.is_empty()


func _promote_next_opponent_if_configured() -> void:
    if _opponent_catalog == null:
        return
    _current_opponent_id = _next_opponent_id
    _next_opponent_id = ""


func _transition_to(next_screen: String) -> bool:
    if next_screen == _current_screen:
        return false
    var previous_screen := _current_screen
    _current_screen = next_screen
    if next_screen == SCREEN_ROUTE_GROWTH or next_screen == SCREEN_ROUTE_INFO:
        route_visits += 1
    _flow_history.append(next_screen)
    screen_changed.emit(previous_screen, next_screen)
    return true


static func _manual_ids(candidate: Dictionary) -> Array:
    var ids: Array = []
    if candidate.has("manuals"):
        for item in candidate.manuals: ids.append(item.id)
    elif not str(candidate.get("signature_manual_id", "")).is_empty():
        ids.append(candidate.signature_manual_id)
    return ids

func get_current_encounter() -> Dictionary:
    if _roster.is_empty() or duel_index < 1 or duel_index > 10: return {}
    return _roster.resolved_encounters[duel_index - 1].duplicate(true)

static func _valid_roster(s: Dictionary) -> bool:
    for key in ROSTER_FIELDS:
        if not s.has(key): return false
    if s.ruleset_id != "ten-duel-variable-roster-v2" or not CHECKPOINT_CODEC.integer(s.roster_version, 1, 1): return false
    if not CHECKPOINT_CODEC.integer(s.roster_seed) or s.roster_seed != s.run_seed: return false
    if typeof(s.roster_save_id) != TYPE_STRING or s.roster_save_id.is_empty() or typeof(s.resolved_encounters) != TYPE_ARRAY: return false
    if typeof(s.roster_digest) != TYPE_STRING or s.roster_digest != CHECKPOINT_CODEC.digest(s.resolved_encounters): return false
    var provider = load("res://src/run/variable_opponent_roster.gd").new()
    return provider.validate(s.resolved_encounters, s.roster_seed, s.roster_save_id)

static func _catalog_for_snapshot(s: Dictionary):
    if s.has("ruleset_id"):
        return load("res://src/run/frozen_opponent_catalog.gd").new(s.resolved_encounters)
    return load("res://src/run/vertical_slice_opponent_catalog.gd").new()

func start_new_variable_run(seed_value: int, save_identity: String) -> bool:
    if _current_screen != SCREEN_MAIN or seed_value < 0 or save_identity.is_empty(): return false
    var provider = load("res://src/run/variable_opponent_roster.gd").new()
    var encounters: Array = provider.generate(seed_value, save_identity)
    if not provider.validate(encounters, seed_value, save_identity): return false
    var catalog = load("res://src/run/frozen_opponent_catalog.gd").new(encounters)
    if not configure_opponents(catalog, seed_value): return false
    _roster = {"ruleset_id": "ten-duel-variable-roster-v2", "roster_version": 1, "roster_seed": seed_value,
        "roster_save_id": save_identity, "resolved_encounters": encounters, "roster_digest": CHECKPOINT_CODEC.digest(encounters)}
    return start_new_run()
