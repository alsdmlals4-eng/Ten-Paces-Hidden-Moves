extends SceneTree

const REGISTRY_SCRIPT := preload("res://src/combat/martial_manual_registry.gd")
const ENGINE_ADAPTER_SCRIPT := preload("res://src/combat/combat_resolution_engine_ten_manuals.gd")

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var registry = REGISTRY_SCRIPT.new()
    _assert(registry.is_valid(), "runtime manifest and ten manual files must load without errors: %s" % str(registry.load_errors))
    var ids: PackedStringArray = registry.get_manual_ids()
    _assert(ids.size() == 10, "registry must expose exactly ten manual IDs")
    _assert("shaolin_arhat_vajra_art" in ids, "Shaolin manual must be present")
    _assert("beggars_dragon_subduing_palm" in ids, "Beggars manual must be present")

    _verify_mastery_unlocks(registry)
    _verify_overlay_targets(registry)
    _verify_loadout_merge(registry)
    _verify_source_immutability(registry)
    _verify_engine_adapter()
    _finish()

func _verify_mastery_unlocks(registry) -> void:
    var manual_id := "mount_hua_plum_blossom_sword"
    _assert(registry.build_unlocked_cards(manual_id, 2).is_empty(), "mastery 2 must unlock no technique cards")
    _assert(registry.build_unlocked_cards(manual_id, 3).size() == 1, "mastery 3 must unlock star3 only")
    _assert(registry.build_unlocked_cards(manual_id, 5).size() == 1, "mastery 5 must still expose one star3 card")
    _assert(registry.build_unlocked_cards(manual_id, 7).size() == 2, "mastery 7 must unlock star3 and star7")
    _assert(registry.build_unlocked_cards(manual_id, 9).size() == 2, "mastery 9 must still expose two cards")
    _assert(registry.build_unlocked_cards(manual_id, 10).size() == 3, "mastery 10 must unlock star10")

func _verify_overlay_targets(registry) -> void:
    var manual_id := "mount_hua_plum_blossom_sword"
    var at_four: Array = registry.build_unlocked_cards(manual_id, 4)
    var at_five: Array = registry.build_unlocked_cards(manual_id, 5)
    var at_eight: Array = registry.build_unlocked_cards(manual_id, 8)
    var at_nine: Array = registry.build_unlocked_cards(manual_id, 9)
    var star3_four := _find_card(at_four, manual_id + "_star3")
    var star3_five := _find_card(at_five, manual_id + "_star3")
    var star7_eight := _find_card(at_eight, manual_id + "_star7")
    var star7_nine := _find_card(at_nine, manual_id + "_star7")
    _assert(_overlay_names(star3_four).is_empty(), "star5 overlay must not apply at mastery 4")
    _assert(_overlay_names(star3_five) == PackedStringArray(["낙매유향"]), "star5 overlay must apply only to star3")
    _assert(_overlay_names(star7_eight).is_empty(), "star9 overlay must not apply at mastery 8")
    _assert(_overlay_names(star7_nine) == PackedStringArray(["매화연세"]), "star9 overlay must apply only to star7")
    var base_steps := int(star7_eight.get("effect_steps", []).size())
    var upgraded_steps := int(star7_nine.get("effect_steps", []).size())
    _assert(upgraded_steps == base_steps + 1, "star9 must add exactly one effect step")
    _assert(_overlay_names(_find_card(at_nine, manual_id + "_star3")) == PackedStringArray(["낙매유향"]), "star9 must not alter star3 overlay lineage")

func _verify_loadout_merge(registry) -> void:
    var loadout := ["shaolin_arhat_vajra_art", "beggars_dragon_subduing_palm"]
    var mastery := {
        "shaolin_arhat_vajra_art": 10,
        "beggars_dragon_subduing_palm": 7
    }
    var cards: Dictionary = registry.build_loadout_cards(loadout, mastery)
    _assert(cards.size() == 5, "mastery 10 plus mastery 7 loadout must yield five cards")
    _assert(cards.has("shaolin_arhat_vajra_art_star10"), "Shaolin ultimate must be included")
    _assert(not cards.has("beggars_dragon_subduing_palm_star10"), "locked Beggars ultimate must not be included")
    _assert(str((cards.get("shaolin_arhat_vajra_art_star3", {}) as Dictionary).get("primary_stat", "")) == "외공", "Shaolin runtime card must retain approved external primary stat")
    _assert(str((cards.get("beggars_dragon_subduing_palm_star3", {}) as Dictionary).get("primary_stat", "")) == "내공", "Beggars runtime card must retain approved internal primary stat")

func _verify_source_immutability(registry) -> void:
    var manual_id := "yang_family_spear"
    var first: Array = registry.build_unlocked_cards(manual_id, 9)
    var first_star7 := _find_card(first, manual_id + "_star7")
    first_star7["name"] = "변조"
    first_star7.get("effect_steps", []).append({"op": "GAIN_RESOURCE", "resource": "health", "amount": 999})
    var second: Array = registry.build_unlocked_cards(manual_id, 9)
    var second_star7 := _find_card(second, manual_id + "_star7")
    _assert(str(second_star7.get("name", "")) == "연환쇄로", "registry calls must return deep copies")
    _assert(int(second_star7.get("effect_steps", []).size()) + 1 == int(first_star7.get("effect_steps", []).size()), "mutating a returned card must not mutate source data")

func _verify_engine_adapter() -> void:
    var engine = ENGINE_ADAPTER_SCRIPT.new()
    _assert(engine.cards_by_id.has("basic_move"), "adapter must preserve legacy basic cards")
    _assert(engine.cards_by_id.has("ultimate_ten_paces_wave"), "adapter must preserve generic ultimates")
    _assert(not engine.cards_by_id.has("mount_hua_plum_blossom_sword_star3"), "martial cards must not load without an explicit loadout")
    engine.configure_martial_loadout(["mount_hua_plum_blossom_sword"], {"mount_hua_plum_blossom_sword": 7})
    _assert(engine.cards_by_id.has("mount_hua_plum_blossom_sword_star3"), "adapter must merge unlocked star3 card")
    _assert(engine.cards_by_id.has("mount_hua_plum_blossom_sword_star7"), "adapter must merge unlocked star7 card")
    _assert(not engine.cards_by_id.has("mount_hua_plum_blossom_sword_star10"), "adapter must keep locked star10 absent")
    engine.configure_martial_loadout([], {})
    _assert(not engine.cards_by_id.has("mount_hua_plum_blossom_sword_star3"), "reconfiguration must remove previously loaded martial cards")
    _assert(engine.cards_by_id.has("basic_move") and engine.cards_by_id.has("ultimate_ten_paces_wave"), "reconfiguration must not remove legacy cards")

func _find_card(cards: Array, card_id: String) -> Dictionary:
    for value in cards:
        if typeof(value) == TYPE_DICTIONARY and str((value as Dictionary).get("id", "")) == card_id:
            return value as Dictionary
    failures.append("missing card: %s" % card_id)
    return {}

func _overlay_names(card: Dictionary) -> PackedStringArray:
    var result := PackedStringArray()
    for value in card.get("applied_overlays", []):
        result.append(str(value))
    return result

func _assert(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)

func _finish() -> void:
    if failures.is_empty():
        print("TEN_MANUAL_REGISTRY_VERIFY_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    print("TEN_MANUAL_REGISTRY_VERIFY_FAILED count=%d" % failures.size())
    quit(1)
