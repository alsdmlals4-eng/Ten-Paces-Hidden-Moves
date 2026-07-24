class_name CombatReviewPanel
extends PanelContainer

signal review_continue_requested
signal detail_log_requested

@onready var hypothesis_value: Label = %HypothesisValue
@onready var enemy_action_value: Label = %EnemyActionValue
@onready var cause_value: Label = %CauseValue
@onready var distance_value: Label = %DistanceValue
@onready var next_dimension_value: Label = %NextDimensionValue
@onready var detail_button: Button = %DetailButton
@onready var continue_button: Button = %ContinueButton

var _summary: Dictionary = {}

func _ready() -> void:
    visible = false
    detail_button.pressed.connect(func(): detail_log_requested.emit())
    continue_button.pressed.connect(func(): review_continue_requested.emit())
    accessibility_name = "결정적 복기"
    accessibility_description = "내 가설, 상대 실제 행동, 결정적 원인, 전후 거리와 다음 검토 차원을 읽습니다."

func apply_summary(summary: Dictionary, combat_ended: bool = false) -> void:
    _summary = summary.duplicate(true)
    var hypothesis: Dictionary = _summary.get("hypothesis", {})
    hypothesis_value.text = str(hypothesis.get("label", "기록한 가설 없음"))
    var enemy_actions: Array = _summary.get("enemy_actions", [])
    enemy_action_value.text = "행동 기록 없음" if enemy_actions.is_empty() else ", ".join(PackedStringArray(enemy_actions))
    cause_value.text = "%d수 · %s" % [int(_summary.get("decisive_timing", 0)), str(_summary.get("cause_text", "원인 기록 없음"))]
    distance_value.text = "%d → %d" % [int(_summary.get("distance_before", 0)), int(_summary.get("distance_after", 0))]
    next_dimension_value.text = str(_summary.get("next_review_dimension", "다음 묶음에서 바꿀 한 가지"))
    continue_button.text = "결전 다시 시작" if combat_ended else "다음 묶음"
    continue_button.tooltip_text = "복기를 확인한 뒤 %s로 이동합니다." % continue_button.text
    set_continue_enabled(true)
    visible = true
    continue_button.grab_focus.call_deferred()

func set_continue_enabled(enabled: bool) -> void:
    continue_button.disabled = not enabled
    continue_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE

func hide_review() -> void:
    visible = false
    _summary.clear()

func current_summary() -> Dictionary:
    return _summary.duplicate(true)

func review_text() -> String:
    return "내 가설: %s\n상대 실제 행동: %s\n결정적 수·원인: %s\n전후 거리: %s\n다음 검토 차원: %s\n상세 기록\n다음 묶음 또는 재시작" % [
        hypothesis_value.text,
        enemy_action_value.text,
        cause_value.text,
        distance_value.text,
        next_dimension_value.text
    ]
