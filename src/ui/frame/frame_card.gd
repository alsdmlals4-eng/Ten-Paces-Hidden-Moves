extends Button
var card_id := ""
func _get_drag_data(_at_position: Vector2):
    if disabled or card_id.is_empty(): return null
    var preview := Label.new()
    preview.text = text
    preview.theme = theme
    set_drag_preview(preview)
    return {"frame_card_id":card_id,"from_index":-1}
