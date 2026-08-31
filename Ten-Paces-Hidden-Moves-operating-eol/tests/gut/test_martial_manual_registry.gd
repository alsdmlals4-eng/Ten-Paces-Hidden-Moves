extends GutTest


func test_registry_loads_exactly_ten_manuals() -> void:
    var registry := MartialManualRegistry.new()

    assert_true(registry.is_valid(), "registry errors: %s" % str(registry.load_errors))
    assert_eq(registry.get_manual_ids().size(), 10)


func test_mastery_unlock_boundaries() -> void:
    var registry := MartialManualRegistry.new()
    assert_true(registry.is_valid(), "registry errors: %s" % str(registry.load_errors))

    var manual_ids := registry.get_manual_ids()
    assert_eq(manual_ids.size(), 10)
    var manual_id := str(manual_ids[0])

    assert_eq(registry.build_unlocked_cards(manual_id, 2).size(), 0)
    assert_eq(registry.build_unlocked_cards(manual_id, 3).size(), 1)
    assert_eq(registry.build_unlocked_cards(manual_id, 6).size(), 1)
    assert_eq(registry.build_unlocked_cards(manual_id, 7).size(), 2)
    assert_eq(registry.build_unlocked_cards(manual_id, 9).size(), 2)
    assert_eq(registry.build_unlocked_cards(manual_id, 10).size(), 3)
