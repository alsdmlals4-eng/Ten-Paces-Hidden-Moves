extends SceneTree

const PolicyScript := preload("res://src/validation/vertical_slice_balance_public_policy.gd")
const EngineScript := preload("res://src/run/vertical_slice_metrics_combat_resolution_engine.gd")
const HUD_PATH := "res://data/combat/combat_hud_preview.json"
const PLAYER_LOADOUT := [
    "mount_hua_plum_blossom_sword",
    "shaolin_arhat_vajra_art",
    "wudang_taiji_sword",
    "yang_family_spear"
]

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    _expect_eq(PolicyScript.get_policy_ids(), [
        "public_approach_pressure",
        "public_guarded_exchange",
        "public_recovery_range"
    ], "Only the three approved public policies may run.")

    var engine = EngineScript.new()
    var mastery := {}
    for manual_id in PLAYER_LOADOUT:
        mastery[manual_id] = 3
    engine.configure_martial_loadouts(PLAYER_LOADOUT, mastery, [], {})
    var state: Dictionary = engine.make_initial_state(_load_json(HUD_PATH), 4, 6)
    var private_state := state.duplicate(true)
    private_state["debug_hidden_player_plan"] = [{"card_id": "ultimate_void_sword_qi"}]
    private_state["pointer_focus"] = "must_not_leak"
    private_state["uncommitted_target_preview"] = {"direction": 1, "tile": 6}
    private_state["observation_answer"] = "must_not_leak"

    for policy_id in PolicyScript.get_policy_ids():
        var placements: Array = PolicyScript.build_placements(
            policy_id,
            state,
            engine.cards_by_id,
            engine.get_player_martial_card_ids(),
            1,
            [3, 3, 4]
        )
        var private_placements: Array = PolicyScript.build_placements(
            policy_id,
            private_state,
            engine.cards_by_id,
            engine.get_player_martial_card_ids(),
            1,
            [3, 3, 4]
        )
        _expect_eq(private_placements, placements, "%s must not read hidden plan, pointer, preview, or observation fields." % policy_id)
        _expect_true(not placements.is_empty(), "%s must produce a legal public placement." % policy_id)
        var preview: Dictionary = engine.preview_player_plan(state, placements)
        _expect_true(bool(preview.get("valid", false)), "%s placements must pass the real engine legality boundary: %s" % [policy_id, str(preview)])
        _expect_bundle_bounds(placements, 1, [3, 3, 4], policy_id)

    _expect_true(
        PolicyScript.build_placements("unknown_policy", state, engine.cards_by_id, engine.get_player_martial_card_ids(), 1, [3, 3, 4]).is_empty(),
        "Unknown policies must fail closed without a fallback placement."
    )

    if failures.is_empty():
        print("VERTICAL_SLICE_BALANCE_PUBLIC_POLICY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)


func _expect_bundle_bounds(placements: Array, bundle_index: int, sequence: Array, policy_id: String) -> void:
    var start := 1
    for index in range(bundle_index - 1):
        start += int(sequence[index])
    var finish := start + int(sequence[bundle_index - 1]) - 1
    for value in placements:
        if typeof(value) != TYPE_DICTIONARY:
            failures.append("%s placement must be a Dictionary." % policy_id)
            continue
        var placement: Dictionary = value
        var anchor := int(placement.get("anchor_index", 0))
        var span := maxi(1, int(placement.get("span", 1)))
        _expect_true(anchor >= start and anchor + span - 1 <= finish, "%s placement must stay inside the active 3/3/4 bundle." % policy_id)


func _load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text()) if file != null else {}
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _expect_true(value: bool, message: String) -> void:
    if not value:
        failures.append(message)


func _expect_eq(actual, expected, message: String) -> void:
    if actual != expected:
        failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])
