## 도겸 상태 패널 초상 라우팅과 일반 적군 fallback을 검증한다.
extends SceneTree

const STATUS_PANEL_SCRIPT := preload("res://src/ui/combatant_status_panel.gd")
const DOGYEOM_PORTRAIT_PATH := "res://assets/portraits/dogyeom_status_portrait_01_v1.png"
const GENERIC_ENEMY_PORTRAIT_PATH := "res://assets/portraits/enemy_masked_ink_v1.png"

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var dogyeom_panel = _make_enemy_panel("slot1_dogyeom")
	_expect_eq(
		_portrait_path(dogyeom_panel),
		DOGYEOM_PORTRAIT_PATH,
		"Dogyeom must use the approved status portrait asset."
	)
	_expect_eq(
		_portrait_stretch_mode(dogyeom_panel),
		TextureRect.STRETCH_KEEP_ASPECT_COVERED,
		"Status portraits must preserve the existing covered aspect behavior."
	)
	dogyeom_panel.queue_free()

	var generic_enemy_panel = _make_enemy_panel("slot1_yeongyo")
	_expect_eq(
		_portrait_path(generic_enemy_panel),
		GENERIC_ENEMY_PORTRAIT_PATH,
		"Non-Dogyeom enemies must retain the generic enemy portrait."
	)
	generic_enemy_panel.queue_free()

	var missing_id_enemy_panel = _make_enemy_panel("")
	_expect_eq(
		_portrait_path(missing_id_enemy_panel),
		GENERIC_ENEMY_PORTRAIT_PATH,
		"Enemies without a candidate ID must retain the generic enemy portrait."
	)
	missing_id_enemy_panel.queue_free()

	await process_frame
	_finish()


func _make_enemy_panel(candidate_id: String):
	var panel = STATUS_PANEL_SCRIPT.new()
	root.add_child(panel)
	panel.configure("enemy", {
		"candidate_id": candidate_id,
		"name": "테스트 상대",
		"epithet": "검증용",
		"health": [30, 30],
		"stamina": [5, 5],
		"internal": [4, 4]
	})
	return panel


func _portrait_path(panel) -> String:
	var portrait := panel.get_node_or_null("CombatantInkPortrait") as TextureRect
	if portrait == null or portrait.texture == null:
		return ""
	return portrait.texture.resource_path


func _portrait_stretch_mode(panel) -> int:
	var portrait := panel.get_node_or_null("CombatantInkPortrait") as TextureRect
	return portrait.stretch_mode if portrait != null else -1


func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _finish() -> void:
	if failures.is_empty():
		print("DOGYEOM_STATUS_PORTRAIT_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("DOGYEOM_STATUS_PORTRAIT_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
