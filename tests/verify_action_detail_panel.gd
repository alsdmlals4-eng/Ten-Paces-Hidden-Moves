extends SceneTree

const MANUAL_LOADOUT := ["mount_hua_plum_blossom_sword"]
const MANUAL_MASTERY := {"mount_hua_plum_blossom_sword": 5}

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene := load("res://scenes/ui/action_selection/action_detail_panel.tscn")
    var adapter_script := load("res://src/ui/action_selection/action_view_model_adapter.gd")
    assert(scene != null)
    assert(adapter_script != null)

    var panel = scene.instantiate()
    get_root().add_child(panel)
    await process_frame

    var adapter = adapter_script.new()
    var basic: Dictionary = adapter.build_basic_actions()[0]
    panel.show_action(basic, false)
    var basic_snapshot: Dictionary = panel.get_detail_snapshot()
    assert(str(basic_snapshot.get("mode", "")) == "action")
    assert("출처" in basic_snapshot.get("row_keys", []))
    assert("수 점유" in basic_snapshot.get("row_keys", []))
    assert("기력" in basic_snapshot.get("row_keys", []))
    assert("내력" in basic_snapshot.get("row_keys", []))
    assert("사거리" in basic_snapshot.get("row_keys", []))
    assert("절초기세" not in basic_snapshot.get("row_keys", []))

    assert(adapter.build_owned_manuals().is_empty())
    var manuals: Array = adapter.build_owned_manuals(MANUAL_LOADOUT, MANUAL_MASTERY)
    var manual: Dictionary = manuals[0]
    var martial: Dictionary = (manual.get("techniques", []) as Array)[0]
    panel.show_action(martial, true)
    var martial_snapshot: Dictionary = panel.get_detail_snapshot()
    assert(bool(martial_snapshot.get("pinned", false)))
    assert(str((martial_snapshot.get("rows", {}) as Dictionary).get("출처", "")) == "[화산파] 매화검결")
    assert("전조" in martial_snapshot.get("row_keys", []))
    assert("실행" in martial_snapshot.get("row_keys", []))
    assert("해금 성급" in martial_snapshot.get("row_keys", []))
    assert("현재 성급" in martial_snapshot.get("row_keys", []))
    assert("타격" in martial_snapshot.get("row_keys", []))

    var ultimate: Dictionary = adapter.build_ultimate_actions(5, MANUAL_LOADOUT, MANUAL_MASTERY)[0]
    ultimate["reserved"] = true
    ultimate["reservation_text"] = "5~6수 예약"
    ultimate["refund_before_commit"] = true
    panel.show_action(ultimate, false)
    var ultimate_snapshot: Dictionary = panel.get_detail_snapshot()
    assert("절초기세" in ultimate_snapshot.get("row_keys", []))
    assert("예약 상태" in ultimate_snapshot.get("row_keys", []))
    assert("진행 전 환불" in ultimate_snapshot.get("row_keys", []))
    assert(str((ultimate_snapshot.get("rows", {}) as Dictionary).get("예약 상태", "")) == "5~6수 예약")

    panel.show_manual(manual, false)
    var manual_snapshot: Dictionary = panel.get_detail_snapshot()
    assert(str(manual_snapshot.get("mode", "")) == "manual")
    assert("성급 계보" in manual_snapshot.get("section_titles", []))
    assert("1성 패시브" in str(manual_snapshot.get("lineage_text", "")))
    assert("10성 절초 또는 진의" in str(manual_snapshot.get("lineage_text", "")))

    panel.clear_detail()
    assert(panel.visible == false)

    print("verify_action_detail_panel: PASS")
    quit(0)
