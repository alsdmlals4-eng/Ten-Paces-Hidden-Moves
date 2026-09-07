# 이 회귀가 막는 결함: 확정된 모듈 프레임을 파일만 복사하고 실제 준비/결투 UI가 소비하지 않거나,
# 적 숫자와 관찰의 숨은 정보를 노출하고, 표현 중 하단 계획 UI를 남겨 두는 변경.
extends SceneTree

const BOARD_SCENE := preload("res://scenes/combat/combat_board_preview.tscn")
const STATUS_FRAME_PATH := "res://assets/ui/duel/status_hud_frame_01_v1.png"
const ACTION_SLOT_FRAME_PATH := "res://assets/ui/duel/current_action_slot_frame_01_v1.png"
const DETAIL_FRAME_PATH := "res://assets/ui/duel/technique_detail_frame_01_v1.png"
const OBSERVATION_FRAME_PATH := "res://assets/ui/duel/observation_reveal_frame_01_v1.png"

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var board := BOARD_SCENE.instantiate() as CombatBoardPreview
	if board == null:
		failures.append("Modular duel UI verification requires the combat board.")
		_finish()
		return
	board.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board.size = Vector2(1440.0, 900.0)
	root.add_child(board)
	for _frame in range(5):
		await process_frame

	_expect(ResourceLoader.exists(STATUS_FRAME_PATH), "Status HUD needs its final-locked runtime frame.")
	_expect(ResourceLoader.exists(ACTION_SLOT_FRAME_PATH), "Current action slot needs its final-locked runtime frame.")
	_expect(ResourceLoader.exists(DETAIL_FRAME_PATH), "Technique detail needs its final-locked runtime frame.")
	_expect(ResourceLoader.exists(OBSERVATION_FRAME_PATH), "Observation reveal needs its final-locked runtime frame.")
	_expect(board.has_method("get_modular_duel_ui_snapshot"), "Combat board must expose the real modular UI consumer snapshot.")
	_expect(board.get_node_or_null("ObservationRevealPanel") != null, "Preparation screen needs a separate observation frame control.")
	_expect(board.top_hud.player_panel != null and bool(board.top_hud.player_panel.get_meta("status_hud_frame_loaded", false)), "Player status must consume the locked HUD frame.")
	_expect(board.top_hud.enemy_panel != null and bool(board.top_hud.enemy_panel.get_meta("status_hud_frame_loaded", false)), "Enemy status must consume the locked HUD frame.")
	_expect(board.action_timing_panel.get_slot(1) != null and bool(board.action_timing_panel.get_slot(1).get_meta("current_action_slot_frame_loaded", false)), "Current action slot must consume the locked slot frame.")
	_expect(board.card_detail_panel != null and bool(board.card_detail_panel.get_meta("technique_detail_frame_loaded", false)), "Detail panel must consume the locked detail frame.")

	if board.has_method("get_modular_duel_ui_snapshot"):
		var snapshot: Dictionary = board.call("get_modular_duel_ui_snapshot")
		_expect(bool(snapshot.get("player_numeric_values_visible", false)), "Player health, stamina, and internal values must show current and maximum numbers.")
		_expect(not bool(snapshot.get("enemy_numeric_values_visible", true)), "Enemy health, stamina, and internal numbers must remain hidden.")
		_expect(int(snapshot.get("momentum_segments", 0)) == 5, "Both combatants must render the five-step ultimate momentum gauge.")
		_expect(not bool(snapshot.get("observation_private_fields_visible", true)), "Observation panel must not expose card name, target, damage, direction, cost, or hidden plan.")

	board.queue_free()
	await process_frame
	_finish()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("MODULAR_DUEL_UI_PRESENTATION_VERIFY_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("MODULAR_DUEL_UI_PRESENTATION_VERIFY_FAILED count=%d" % failures.size())
	quit(1)
