extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var panel = load("res://src/ui/action_selection/action_detail_panel.gd").new()
    root.add_child(panel)
    await process_frame
    panel.show_action({"name":"매화삼첩", "source_label":"매화검결", "category":"attack", "action_slots":2, "stamina_cost":1, "internal_cost":1, "illustration":{"atlas":"res://assets/ui/cards/basic_technique_ink_atlas_01_v1.png", "region":[1231,0,305,509]}, "detail":{"effect_text":"후퇴 → 자원 획득 → 연속 공격 3회"}})
    if panel.find_child("DetailIllustration", true, false) == null:
        push_error("DETAIL_ILLUSTRATION_MISSING")
        panel.free()
        quit(1)
        return
    var snapshot: Dictionary = panel.get_detail_snapshot()
    for key in ["출처", "계열", "소모"]:
        if snapshot.row_keys.has(key):
            push_error("DUPLICATED_DETAIL_ROW_" + key)
            panel.free()
            quit(1)
            return
    if snapshot.section_titles.has("효과 상세") or not snapshot.section_titles.has("효과"):
        push_error("EFFECT_MUST_HAVE_ONE_COMPLETE_SECTION")
        panel.free()
        quit(1)
        return
    panel.free()
    print("COMPACT_ACTION_DETAIL_PASS")
    quit(0)
