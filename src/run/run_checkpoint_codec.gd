class_name RunCheckpointCodec
extends RefCounted

const MAX_BYTES := 8 * 1024 * 1024
const MAX_DEPTH := 64
const MAX_NODES := 100000
const SCHEMA_VERSION := 1
# Bump for code-owned combat/reward/route/save semantics; presentation changes do not bump it.
const SEMANTIC_CONTRACT_VERSION := "ten-duel-four-route-one-retry-bimu-save-v1"
var _content_identity: String = ""
var _number_pattern := RegEx.create_from_string("-?(0|[1-9][0-9]*)(\\.[0-9]+)?([eE][+-]?[0-9]+)?")

static func integer(value, minimum: int = 0, maximum: int = 9007199254740991) -> bool:
    return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= minimum and value <= maximum

static func json_safe(value, depth: int = 0, count: Array = [0]) -> bool:
    count[0] += 1
    if depth > MAX_DEPTH or count[0] > MAX_NODES:
        return false
    match typeof(value):
        TYPE_NIL, TYPE_BOOL, TYPE_STRING:
            return true
        TYPE_INT, TYPE_FLOAT:
            return is_finite(float(value)) and abs(float(value)) <= 9007199254740991.0
        TYPE_ARRAY:
            for item in value:
                if not json_safe(item, depth + 1, count): return false
            return true
        TYPE_DICTIONARY:
            for key in value:
                if typeof(key) != TYPE_STRING or not json_safe(value[key], depth + 1, count): return false
            return true
    return false

static func normalized(value):
    match typeof(value):
        TYPE_FLOAT:
            return int(value) if integer(value, -9007199254740991) else value
        TYPE_ARRAY:
            var items: Array = []
            for item in value: items.append(normalized(item))
            return items
        TYPE_DICTIONARY:
            var result := {}
            var keys: Array = value.keys()
            keys.sort()
            for key in keys: result[key] = normalized(value[key])
            return result
    return value

static func digest(value) -> String:
    return JSON.stringify(normalized(value), "", true, true).sha256_text()

static func error(status: String, detail: String) -> Dictionary:
    return {"ok": false, "status": status, "error": detail}

func content_identity() -> String:
    if _content_identity.is_empty():
        var manuals = load("res://src/combat/martial_manual_registry.gd").new()
        var opponents = load("res://src/run/vertical_slice_opponent_catalog.gd").new()
        var constraints = load("res://src/run/bimu_constraint_model.gd").new()
        var runtime_binding = load("res://src/run/vertical_slice_opponent_runtime_binding.gd").new()
        var engine = load("res://src/combat/combat_resolution_engine.gd").new()
        var route_script = load("res://src/run/vertical_slice_route_model.gd")
        var progression_script = load("res://src/run/vertical_slice_progression_state.gd")
        if not manuals.is_valid() or not opponents.is_valid() or not runtime_binding.is_valid() or constraints.get_options().is_empty() or engine.rules.is_empty() or engine.cards_by_id.is_empty():
            return ""
        var bindings: Array = []
        for candidate in opponents.get_all_candidates():
            var binding: Dictionary = runtime_binding.build(candidate)
            if not binding.get("valid", false): return ""
            bindings.append(binding)
        # Domain-owned catalogs supply compatibility input; the codec never opens save files.
        _content_identity = digest({"contract": SEMANTIC_CONTRACT_VERSION, "manuals": manuals.manuals, "opponents": opponents.get_all_candidates(), "runtime_bindings": bindings, "constraints": constraints.get_options(), "constraint_policy": constraints.get_selection_policy(), "resolution_rules": engine.rules, "basic_and_ultimate_cards": engine.cards_by_id, "route_options": route_script.JIANGHU_ALTERNATIVES, "growth_seeds": route_script.GROWTH_SEEDS, "next_star_costs": progression_script.NEXT_STAR_COSTS, "default_resources": progression_script.DEFAULT_RESOURCES})
    return _content_identity

func validate_payload(run_state, combat_checkpoint = {}) -> Dictionary:
    if typeof(run_state) != TYPE_DICTIONARY or typeof(combat_checkpoint) != TYPE_DICTIONARY or not json_safe([run_state, combat_checkpoint], 0, [0]):
        return error("CORRUPT", "Unsupported or unbounded payload")
    var candidate = load("res://src/run/vertical_slice_run_state.gd").new()
    var validation: Dictionary = candidate.validate_snapshot(run_state)
    if not validation.get("ok", false): return validation
    if not combat_checkpoint.is_empty():
        if run_state.current_screen != "COMBAT": return error("CORRUPT", "Combat payload outside combat")
        var combat_validation: Dictionary = load("res://src/run/combat_checkpoint_codec.gd").new().validate(combat_checkpoint)
        if not combat_validation.ok: return combat_validation
        var s: Dictionary = normalized(run_state)
        var c: Dictionary = normalized(combat_checkpoint)
        if c.duel_index != s.duel_index or c.attempt_id != s.attempt_id or c.binding.enemy_candidate_id != s.current_opponent_id or c.binding.player_loadout != s.player_manual_loadout or c.binding.player_mastery_by_manual != s.progression.mastery_by_manual or c.binding.bimu_receipt != s.frozen_bimu_receipt:
            return error("CORRUPT", "Combat/run identity mismatch")
        if c.phase == "PLANNING" and c.state.player.health[0] == 0:
            if c.state.player.health != s.progression.player_resources.health or c.state.player.health != s.pre_battle_snapshot.progression.player_resources.health:
                return error("CORRUPT", "Initial zero-health planning does not match carried resources")
        return {"ok": true, "status": "VALID", "run_state": s, "combat_checkpoint": c}
    if run_state.current_screen in ["COMBAT", "REVIEW", "MAIN"]:
        return error("CORRUPT", "Not a durable run-only boundary")
    return {"ok": true, "status": "VALID", "run_state": normalized(run_state), "combat_checkpoint": {}}

func encode(save_id: String, checkpoint_id: String, revision: int, run_state: Dictionary, combat_checkpoint: Dictionary = {}, active: bool = true) -> Dictionary:
    if save_id.is_empty() or checkpoint_id.is_empty() or revision < 1 or content_identity().is_empty():
        return error("CORRUPT", "Missing checkpoint identity")
    if active:
        var validation := validate_payload(run_state, combat_checkpoint)
        if not validation.ok: return validation
    elif not run_state.is_empty() or not combat_checkpoint.is_empty():
        return error("CORRUPT", "Tombstone contains active state")
    var envelope := {"schema_version": SCHEMA_VERSION, "save_id": save_id, "checkpoint_id": checkpoint_id, "revision": revision, "active": active, "written_at_utc": Time.get_datetime_string_from_system(true) + "Z", "app_version": str(ProjectSettings.get_setting("application/config/version", "1")), "content_identity": content_identity(), "run_state": run_state.duplicate(true), "combat_checkpoint": combat_checkpoint.duplicate(true)}
    if envelope.app_version.is_empty(): envelope.app_version = "unversioned-schema1"
    envelope["integrity_hash"] = digest(envelope)
    var text := JSON.stringify(normalized(envelope), "", true, true)
    if text.to_utf8_buffer().size() > MAX_BYTES: return error("CORRUPT", "Input exceeds size bound")
    return {"ok": true, "status": "VALID", "payload": normalized(envelope), "text": text}

func decode(text: String) -> Dictionary:
    if text.to_utf8_buffer().size() > MAX_BYTES: return error("CORRUPT", "Input exceeds size bound")
    # Bound nesting before JSON parsing, ignoring brackets inside escaped strings.
    var depth := 0
    var quoted := false
    var escaped := false
    for ch in text:
        if quoted:
            if escaped: escaped = false
            elif ch == "\\": escaped = true
            elif ch == '"': quoted = false
        elif ch == '"': quoted = true
        elif ch in ["[", "{"]:
            depth += 1
            if depth > MAX_DEPTH: return error("CORRUPT", "Input exceeds depth bound")
        elif ch in ["]", "}"]: depth -= 1
    var cursor := [0]
    if not _strict_value(text, cursor, 0, [0]): return error("CORRUPT", "Non-strict JSON or duplicate object key")
    _skip_space(text, cursor)
    if cursor[0] != text.length(): return error("CORRUPT", "Trailing JSON content")
    var parser := JSON.new()
    if parser.parse(text) != OK or typeof(parser.data) != TYPE_DICTIONARY or not json_safe(parser.data, 0, [0]):
        return error("CORRUPT", "Malformed JSON")
    var envelope: Dictionary = parser.data
    if not integer(envelope.get("schema_version"), 1):
        return error("CORRUPT", "Malformed schema version")
    # An explicit future numeric schema owns the slot even when its format is unknown.
    if envelope.schema_version != SCHEMA_VERSION:
        return error("INCOMPATIBLE", "Unsupported schema")
    var keys := ["schema_version", "save_id", "checkpoint_id", "revision", "active", "written_at_utc", "app_version", "content_identity", "run_state", "combat_checkpoint", "integrity_hash"]
    if envelope.size() != keys.size(): return error("CORRUPT", "Unexpected envelope fields")
    for key in keys:
        if not envelope.has(key): return error("CORRUPT", "Missing envelope field")
    for key in ["save_id", "checkpoint_id", "written_at_utc", "app_version", "content_identity", "integrity_hash"]:
        if typeof(envelope[key]) != TYPE_STRING or envelope[key].is_empty(): return error("CORRUPT", "Malformed envelope identity")
    if not integer(envelope.revision, 1) or typeof(envelope.active) != TYPE_BOOL: return error("CORRUPT", "Malformed revision or active state")
    var hash_input := envelope.duplicate(true)
    hash_input.erase("integrity_hash")
    if digest(hash_input) != envelope.integrity_hash: return error("CORRUPT", "Integrity mismatch")
    if typeof(envelope.run_state) != TYPE_DICTIONARY or typeof(envelope.combat_checkpoint) != TYPE_DICTIONARY: return error("CORRUPT", "Malformed payload")
    # Current-schema metadata damage must recover from backup, not masquerade as
    # a genuinely incompatible, intact checkpoint and suppress recovery.
    if envelope.content_identity != content_identity() or content_identity().is_empty():
        return error("INCOMPATIBLE", "Incompatible content")
    if envelope.active:
        var validation := validate_payload(envelope.run_state, envelope.combat_checkpoint)
        if not validation.ok: return validation
    elif not envelope.run_state.is_empty() or not envelope.combat_checkpoint.is_empty():
        return error("CORRUPT", "Tombstone contains active data")
    return {"ok": true, "status": "VALID", "payload": normalized(envelope)}

func _skip_space(text: String, cursor: Array) -> void:
    while cursor[0] < text.length() and text[cursor[0]] in [" ", "\n", "\r", "\t"]: cursor[0] += 1

func _string_end(text: String, cursor: Array) -> bool:
    cursor[0] += 1
    while cursor[0] < text.length():
        var ch := text[cursor[0]]
        cursor[0] += 1
        if ch == '"': return true
        if ch.unicode_at(0) < 32: return false
        if ch == "\\":
            if cursor[0] >= text.length(): return false
            ch = text[cursor[0]]
            cursor[0] += 1
            if ch == "u":
                for _i in range(4):
                    if cursor[0] >= text.length() or text[cursor[0]] not in "0123456789abcdefABCDEF": return false
                    cursor[0] += 1
            elif ch not in ['"', "\\", "/", "b", "f", "n", "r", "t"]: return false
    return false

func _strict_value(text: String, cursor: Array, depth: int, count: Array) -> bool:
    count[0] += 1
    if depth > MAX_DEPTH or count[0] > MAX_NODES: return false
    _skip_space(text, cursor)
    if cursor[0] >= text.length(): return false
    var ch := text[cursor[0]]
    if ch == '"': return _string_end(text, cursor)
    if ch in ["{", "["]:
        var object: bool = ch == "{"
        var closing := "}" if object else "]"
        var seen := {}
        cursor[0] += 1
        _skip_space(text, cursor)
        if cursor[0] < text.length() and text[cursor[0]] == closing:
            cursor[0] += 1
            return true
        while cursor[0] < text.length():
            _skip_space(text, cursor)
            if object:
                if cursor[0] >= text.length() or text[cursor[0]] != '"': return false
                var start: int = cursor[0]
                if not _string_end(text, cursor): return false
                var key = JSON.parse_string(text.substr(start, cursor[0] - start))
                if typeof(key) != TYPE_STRING or seen.has(key): return false
                seen[key] = true
                _skip_space(text, cursor)
                if cursor[0] >= text.length() or text[cursor[0]] != ":": return false
                cursor[0] += 1
            if not _strict_value(text, cursor, depth + 1, count): return false
            _skip_space(text, cursor)
            if cursor[0] >= text.length(): return false
            ch = text[cursor[0]]
            cursor[0] += 1
            if ch == closing: return true
            if ch != ",": return false
        return false
    for literal in ["true", "false", "null"]:
        if text.substr(cursor[0], literal.length()) == literal:
            cursor[0] += literal.length()
            return true
    var number := _number_pattern.search(text, cursor[0])
    if number == null or number.get_start() != cursor[0]: return false
    cursor[0] = number.get_end()
    return true
