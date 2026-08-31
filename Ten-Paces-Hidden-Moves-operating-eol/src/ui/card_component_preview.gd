extends Control

const CATALOG_PATH := "res://data/cards/basic_cards.json"
const CARD_VIEW_SCENE := preload("res://scenes/ui/card_view.tscn")
const DETAIL_SCENE := preload("res://scenes/ui/card_detail_panel.tscn")

var _cards: Array[Dictionary] = []
var _detail_panel: CardDetailPanel

func _ready() -> void:
    _cards = CardCatalog.load_cards(CATALOG_PATH)
    _build_preview()

func _build_preview() -> void:
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    add_child(margin)

    var row := HBoxContainer.new(); row.add_theme_constant_override("separation", 20); margin.add_child(row)
    var left := VBoxContainer.new(); left.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(left)
    var title := Label.new(); title.text = "STEP 0 · 카드 UI 컴포넌트 미리보기"
    title.add_theme_font_size_override("font_size", 34); title.add_theme_color_override("font_color", Color("d6b36c")); left.add_child(title)
    var note := Label.new(); note.text = "소속·사거리·기능·효과·수치는 데이터로 교체된다. 고정되는 것은 위치와 정보 구조다."
    note.add_theme_font_size_override("font_size", 18); note.add_theme_color_override("font_color", Color("b9ad9b")); left.add_child(note)
    var scroll := ScrollContainer.new(); scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL; left.add_child(scroll)
    var cards_row := HBoxContainer.new(); cards_row.add_theme_constant_override("separation", 14); scroll.add_child(cards_row)
    for card in _cards:
        var view := CARD_VIEW_SCENE.instantiate() as CardView
        cards_row.add_child(view); view.set_definition(card); view.card_selected.connect(_on_card_selected)
    _detail_panel = DETAIL_SCENE.instantiate() as CardDetailPanel; row.add_child(_detail_panel)
    if not _cards.is_empty(): _detail_panel.set_definition(_cards[0])

func _on_card_selected(card_id: String) -> void:
    for card in _cards:
        if str(card.get("id", "")) == card_id:
            _detail_panel.set_definition(card)
            return
