extends SceneTree

const CATALOG_PATH := "res://data/cards/basic_cards.json"
const PREVIEW_SCENE_PATH := "res://scenes/ui/card_component_preview.tscn"
const REQUIRED_FIELDS := [
    "id", "name", "source_label", "source_badge", "range_text",
    "category", "category_label", "category_badge", "illustration",
    "target", "damage", "condition", "effect_text", "tags",
    "action_slots", "stamina_cost", "internal_cost", "flavor"
]
const FORBIDDEN_FIELDS := ["action_point_cost", "guard_reduction"]
const REQUIRED_CATEGORIES := ["move", "attack", "response", "recovery", "enhancement"]

var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    _verify_catalog()
    await _verify_preview_scene()

    if failures.is_empty():
        print("STEP0_GODOT_VERIFY_OK")
        quit(0)
        return

    for failure in failures:
        push_error(failure)
    print("STEP0_GODOT_VERIFY_FAILED count=%d" % failures.size())
    quit(1)

func _verify_catalog() -> void:
    if not FileAccess.file_exists(CATALOG_PATH):
        failures.append("카드 카탈로그가 없습니다: %s" % CATALOG_PATH)
        return

    var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
    if file == null:
        failures.append("카드 카탈로그를 열 수 없습니다: %s" % CATALOG_PATH)
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        failures.append("카드 카탈로그 루트는 Dictionary여야 합니다.")
        return

    var cards = parsed.get("cards", [])
    if typeof(cards) != TYPE_ARRAY:
        failures.append("cards 필드는 Array여야 합니다.")
        return
    if cards.size() != 7:
        failures.append("기초 카드는 정확히 7장이어야 합니다. actual=%d" % cards.size())

    var ids: Dictionary = {}
    var found_categories: Dictionary = {}
    for raw in cards:
        if typeof(raw) != TYPE_DICTIONARY:
            failures.append("카드 항목은 Dictionary여야 합니다.")
            continue

        var card: Dictionary = raw
        var card_id := str(card.get("id", "<missing>"))
        if ids.has(card_id):
            failures.append("중복 카드 ID: %s" % card_id)
        ids[card_id] = true

        for field in REQUIRED_FIELDS:
            if not card.has(field):
                failures.append("%s 필수 필드 누락: %s" % [card_id, field])
        for field in FORBIDDEN_FIELDS:
            if card.has(field):
                failures.append("%s 금지 필드 존재: %s" % [card_id, field])

        if str(card.get("source_label", "")) != "기초":
            failures.append("%s 소속 배지는 기초여야 합니다." % card_id)

        var category := str(card.get("category", ""))
        found_categories[category] = true

        for spec_key in ["source_badge", "category_badge", "illustration"]:
            var spec = card.get(spec_key, {})
            if typeof(spec) != TYPE_DICTIONARY:
                failures.append("%s.%s는 Dictionary여야 합니다." % [card_id, spec_key])
                continue
            var atlas_path := str(spec.get("atlas", ""))
            var region = spec.get("region", [])
            if atlas_path.is_empty() or not ResourceLoader.exists(atlas_path):
                failures.append("%s.%s 자산 경로가 없습니다: %s" % [card_id, spec_key, atlas_path])
            if typeof(region) != TYPE_ARRAY or region.size() != 4:
                failures.append("%s.%s region은 숫자 4개여야 합니다." % [card_id, spec_key])

        for cost_key in ["action_slots", "stamina_cost", "internal_cost"]:
            if int(card.get(cost_key, -1)) < 0:
                failures.append("%s.%s 비용은 0 이상이어야 합니다." % [card_id, cost_key])

    for category in REQUIRED_CATEGORIES:
        if not found_categories.has(category):
            failures.append("필수 기능 분류 누락: %s" % category)

func _verify_preview_scene() -> void:
    if not ResourceLoader.exists(PREVIEW_SCENE_PATH):
        failures.append("미리보기 씬이 없습니다: %s" % PREVIEW_SCENE_PATH)
        return

    var packed := load(PREVIEW_SCENE_PATH) as PackedScene
    if packed == null:
        failures.append("미리보기 씬을 로드하지 못했습니다.")
        return

    var preview := packed.instantiate()
    if preview == null:
        failures.append("미리보기 씬을 인스턴스화하지 못했습니다.")
        return

    root.add_child(preview)
    await process_frame
    await process_frame

    var card_views := preview.find_children("*", "CardView", true, false)
    if card_views.size() != 7:
        failures.append("미리보기 CardView는 7개여야 합니다. actual=%d" % card_views.size())

    var detail_panels := preview.find_children("*", "CardDetailPanel", true, false)
    if detail_panels.size() != 1:
        failures.append("CardDetailPanel은 정확히 1개여야 합니다. actual=%d" % detail_panels.size())

    preview.queue_free()
    await process_frame
