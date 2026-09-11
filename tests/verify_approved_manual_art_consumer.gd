extends SceneTree
const Card := preload("res://src/ui/action_selection/action_choice_card.gd")
const Detail := preload("res://src/ui/action_selection/action_detail_panel.gd")
const Adapter := preload("res://src/ui/action_selection/action_view_model_adapter.gd")
var failures: Array[String] = []
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/blueprint/APPROVED_ART_MANIFEST.json"))
    var adapter := Adapter.new()
    var detail := Detail.new()
    root.add_child(detail)
    var count := 0
    for manual_id: String in manifest["manuals"]:
        var manual: Dictionary = adapter.build_owned_manuals([manual_id], {manual_id: 10})[0]
        var actions: Array = manual["techniques"].duplicate(true)
        for ultimate: Dictionary in adapter.build_ultimate_actions(5, [manual_id], {manual_id: 10}):
            if str(ultimate.get("manual_id", "")) == manual_id:
                actions.append(ultimate)
        for action: Dictionary in actions:
            var original := action.duplicate(true)
            var star := str(int(action.get("unlock_star", action.get("unlock_mastery", 0))))
            var expected: String = manifest["manuals"][manual_id][star]
            var card := Card.new()
            card.configure_action(action, "semantic_atlas")
            root.add_child(card)
            var art := card.get_node_or_null("CardIllustration") as TextureRect
            _check(art != null and art.texture != null and art.texture.resource_path == expected, "Choice must show exact technique illustration: " + expected)
            if art != null:
                _check(art.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Choice must preserve full composition")
                _check(art.offset_bottom <= (card.get_node("CardName") as Control).offset_top, "No name overlap")
            detail.show_action(action)
            var detail_art := detail.find_child("ApprovedManualIllustration", true, false) as TextureRect
            _check(detail_art != null and detail_art.texture != null and detail_art.texture.resource_path == expected, "Detail must show exact technique illustration")
            _check(action == original, "Presentation must not mutate gameplay definition")
            card.free()
            count += 1
        detail.show_manual(manual)
        _check(detail.find_child("ApprovedManualIllustration", true, false) != null, "Manual overview illustration")
    _check(count == 30, "All30 selected manual techniques consumed")
    var basic: Dictionary = adapter.build_basic_actions()[0]
    var basic_card := Card.new()
    basic_card.configure_action(basic, "basic_atlas_only")
    root.add_child(basic_card)
    _check((basic_card.get_node("CardIllustration") as TextureRect).texture is AtlasTexture, "Basic atlas preserved")
    detail.show_action(basic)
    _check(detail.find_child("ApprovedManualIllustration", true, false) == null, "No stale manual art on basic action")
    detail.clear_detail()
    _check(not detail.visible, "Empty panel remains hidden")
    basic_card.free()
    detail.free()
    if failures.is_empty():
        print("APPROVED_MANUAL_ART_CONSUMER_PASS:30 real adapter actions, choice/detail textures, gameplay untouched, fallback and no stale art")
        quit(0)
    else:
        for message in failures:
            push_error(message)
        quit(1)
func _check(ok: bool, message: String) -> void:
    if not ok:
        failures.append(message)
