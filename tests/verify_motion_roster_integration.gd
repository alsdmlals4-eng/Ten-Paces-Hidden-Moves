extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var art = load("res://src/ui/approved_blueprint_art.gd")
    var panel = load("res://src/ui/action_selection/action_detail_panel.gd").new()
    root.add_child(panel)
    await process_frame
    var action := {"id":"mount_hua_plum_blossom_sword_star3", "name":"매화삼첩", "manual_id":"mount_hua_plum_blossom_sword", "unlock_star":3, "action_slots":2, "stamina_cost":1, "internal_cost":1, "illustration":{"atlas":"res://assets/ui/cards/basic_technique_ink_atlas_01_v1.png", "region":[1231,0,305,509]}, "detail":{"effect_text":"후퇴 후 연속 공격"}}
    panel.show_action(action)
    var images: Array[Node] = panel._content.find_children("*", "TextureRect", true, false)
    if images.size() != 1 or images[0].texture != art.action_illustration(action):
        push_error("APPROVED_ACTION_MUST_HAVE_ONE_ILLUSTRATION images=%d" % images.size())
        panel.free()
        quit(1)
        return
    panel.show_action({"name":"기본 공격", "illustration":action.illustration})
    images = panel._content.find_children("*", "TextureRect", true, false)
    if images.size() != 1 or not images[0].texture is AtlasTexture:
        push_error("BASIC_ACTION_ATLAS_FALLBACK_MISSING")
        panel.free()
        quit(1)
        return
    panel.free()
    print("MOTION_ROSTER_INTEGRATION_PASS")
    quit(0)
