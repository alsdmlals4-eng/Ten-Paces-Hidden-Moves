# 도겸 전장 Battler 라우팅과 일반 적군 fallback, 발 앵커 보존을 검증한다.
extends SceneTree

const CHARACTER_SCENE := preload("res://scenes/combat/combat_character_placeholder.tscn")
const DOGYEOM_BATTLER_PATH := "res://assets/characters/dogyeom_combat_battler_01_v1.png"
const GENERIC_ENEMY_BATTLER_PATH := "res://assets/characters/enemy_masked_battler_rgba_v1.png"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_require_enemy_art("slot1_dogyeom", DOGYEOM_BATTLER_PATH, "Dogyeom must use the approved combat battler.")
	_require_enemy_art("slot1_yeongyo", GENERIC_ENEMY_BATTLER_PATH, "Other enemies must retain the generic combat battler.")
	_require_enemy_art("", GENERIC_ENEMY_BATTLER_PATH, "Enemies without a candidate ID must retain the generic combat battler.")
	_finish()


func _require_enemy_art(candidate_id: String, expected_path: String, message: String) -> void:
	var character = CHARACTER_SCENE.instantiate() as CombatCharacterPlaceholder
	root.add_child(character)
	character.configure("enemy", -1, 7, 100.0, 1.5, 0.72, candidate_id)
	var texture := character.get_render_texture()
	var actual_path := texture.resource_path if texture != null else ""
	_expect_eq(actual_path, expected_path, message)
	_expect_eq(character.get_foot_anchor_local(), Vector2(character.size.x * 0.5, character.size.y), "Battler routing must preserve the local foot anchor.")
	character.queue_free()


func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s expected=%s actual=%s" % [message, str(expected), str(actual)])


func _finish() -> void:
	if failures.is_empty():
		print("DOGYEOM_COMBAT_BATTLER_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("DOGYEOM_COMBAT_BATTLER_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
