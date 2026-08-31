# 사용자 final-lock 정면 결투 자산이 정본/런타임/카드 소비자로 함께 연결되는지 검증한다.
extends SceneTree

const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
const PLAYER_BATTLER_PATH := "res://assets/characters/player_wanderer_battler_rgba_v1.png"
const DOGYEOM_BATTLER_PATH := "res://assets/characters/dogyeom_combat_battler_01_v1.png"
const GENERIC_ENEMY_BATTLER_PATH := "res://assets/characters/enemy_masked_battler_rgba_v1.png"
const BASIC_ATLAS_PATH := "res://assets/ui/cards/basic_technique_ink_atlas_01_v1.png"
const EXPECTED_IDS := [
	"basic_move", "basic_footwork", "basic_guard", "basic_evade", "basic_quick_attack",
	"basic_heavy_attack", "basic_observe", "basic_meditate", "basic_stance", "basic_palm"
]

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_expect(ResourceLoader.exists(PLAYER_BATTLER_PATH), "Player frontal battler must exist.")
	_expect(ResourceLoader.exists(DOGYEOM_BATTLER_PATH), "Dogyeom frontal battler must exist.")
	_expect(ResourceLoader.exists(BASIC_ATLAS_PATH), "Final-locked basic-technique atlas must be registered as a runtime asset.")

	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	if board == null:
		failures.append("Frontal-duel asset verification requires the combat board.")
		_finish()
		return
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	root.add_child(board)
	for _frame in range(4):
		await process_frame

	_expect(str(board.player_character.get_meta("character_art_path", "")) == PLAYER_BATTLER_PATH, "Player must consume the approved frontal battler.")
	_expect(str(board.enemy_character.get_meta("character_art_path", "")) == GENERIC_ENEMY_BATTLER_PATH, "Generic combat preview must retain its non-Dogyeom fallback battler.")
	_expect(board.player_character.get_render_texture() != null, "Player frontal battler texture must load.")
	_expect(board.enemy_character.get_render_texture() != null, "Generic enemy frontal battler texture must load.")

	var cards: Dictionary = {}
	for value in board.basic_card_tray.cards:
		var definition: Dictionary = value.definition
		cards[str(definition.get("id", ""))] = definition
	for id in EXPECTED_IDS:
		var definition: Dictionary = cards.get(id, {})
		_expect(not definition.is_empty(), "Basic card %s must remain registered." % id)
		_expect(str((definition.get("illustration", {}) as Dictionary).get("atlas", "")) == BASIC_ATLAS_PATH, "Basic card %s must consume the final-locked technique atlas." % id)

	board.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("FRONTAL_DUEL_ASSETS_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("FRONTAL_DUEL_ASSETS_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
