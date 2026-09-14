extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1280, 800)
	var board = load("res://scenes/combat/combat_board_preview.tscn").instantiate()
	root.add_child(board)
	await process_frame
	board._set_presentation_state("presenting_result")
	board._set_resolution_surface_visible(false)
	await process_frame
	var original_children: int = board.get_child_count()
	board._show_feedback_vfx({"actor": "player"}, "clash")
	var effect = board.presentation_vfx
	var valid: bool = effect.visible and effect.material == null
	valid = valid and effect.texture.resource_path == "res://assets/vfx/clash_sparks_ink_gold_v2.png"
	valid = valid and absf(effect.size.x - effect.size.y) < 1.0
	if not valid:
		push_error("CLASH_ALPHA_OR_ASPECT_NOT_PRESERVED")
		board.free()
		quit(1)
		return
	board._show_feedback_vfx({"actor": "player"}, "attack")
	if effect.material == null or not effect.texture is AtlasTexture or board.get_child_count() != original_children:
		push_error("ATTACK_MATTE_NOT_RESTORED")
		board.free()
		quit(1)
		return
	var material_before = effect.material
	board._show_feedback_vfx({"actor": "player"}, "clash")
	board._show_feedback_vfx({"actor": "player"}, "attack")
	if effect.material != material_before or board.get_child_count() != original_children:
		push_error("REPEATED_EFFECT_REBUILDS_MATERIAL_OR_SCENE")
		board.free()
		quit(1)
		return
	board.free()
	print("CLASH_ALPHA_VFX_PASS")
	quit(0)
