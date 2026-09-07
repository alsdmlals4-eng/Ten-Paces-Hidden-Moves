# 재사용 전경 깃발이 전투와 메인 화면에서 동일한 project-owned asset으로 소비되는지 검증한다.
extends SceneTree

const BANNER_SCRIPT := preload("res://src/ui/duel_foreground_banner.gd")
const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
const MAIN_TITLE_SCRIPT := preload("res://src/ui/main_title_screen.gd")
const BACKGROUND_PATH := "res://assets/backgrounds/frontal_courtyard_duel_background_02_v1.png"
const BANNER_PATH := "res://assets/foregrounds/frontal_courtyard_banner_overlay_01_v1.png"

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_expect(ResourceLoader.exists(BACKGROUND_PATH), "The approved modular courtyard background must be a runtime asset.")
	_expect(ResourceLoader.exists(BANNER_PATH), "The approved modular banner overlay must be a runtime asset.")

	var banner := BANNER_SCRIPT.new() as Control
	banner.size = Vector2(1440.0, 900.0)
	root.add_child(banner)
	await process_frame
	var left := banner.get_node_or_null("LeftBanner") as TextureRect
	var right := banner.get_node_or_null("RightBanner") as TextureRect
	_expect(left != null and right != null, "Reusable banner component must expose both side overlays.")
	if left != null and right != null:
		_expect(left.texture != null and left.texture.resource_path == BANNER_PATH, "Left banner must use the registered overlay texture.")
		_expect(right.texture != null and right.texture.resource_path == BANNER_PATH, "Right banner must reuse the registered overlay texture.")
		_expect(not left.flip_h and right.flip_h, "The paired banner should mirror the same project asset instead of adding a one-off duplicate.")
		_expect(left.mouse_filter == Control.MOUSE_FILTER_IGNORE and right.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Decorative banner overlays must not block combat or menu input.")
	banner.queue_free()

	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	root.add_child(board)
	for _frame in range(3):
		await process_frame
	_expect(board.get_node_or_null("DuelForegroundBanner") != null, "Combat board must consume the reusable foreground banner component.")
	board.queue_free()

	var title := MAIN_TITLE_SCRIPT.new() as Control
	title.size = Vector2(1440.0, 900.0)
	root.add_child(title)
	await process_frame
	_expect(title.get_node_or_null("DuelForegroundBanner") != null, "Main title must consume the same reusable foreground banner component.")
	title.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("DUEL_FOREGROUND_BANNER_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("DUEL_FOREGROUND_BANNER_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
