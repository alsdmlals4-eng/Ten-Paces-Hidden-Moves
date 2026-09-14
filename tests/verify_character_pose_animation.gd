extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var script = load("res://src/combat/combat_character_placeholder.gd")
    for actor_role in ["player", "enemy"]:
        var actor = script.new()
        root.add_child(actor)
        actor.configure(actor_role, 1 if actor_role == "player" else -1, 3, 100.0, 1.5, 0.72)
        var idle_texture = actor.get_render_texture()
        if not idle_texture is AtlasTexture:
            push_error("POSE_ANIMATION_MISSING: %s still renders a single legacy texture" % actor_role)
            actor.free()
            quit(1)
            return
        var idle_region: Rect2 = idle_texture.region
        var draw_rect: Rect2 = actor._sprite_rect_local()
        if not is_equal_approx(draw_rect.size.aspect(), idle_region.size.aspect()):
            push_error("POSE_ASPECT_DISTORTED: atlas cell stretched to square")
            quit(1)
            return
        actor.play_attack_motion(0.8)
        await create_timer(0.25).timeout
        var attacking_texture = actor.get_render_texture()
        if attacking_texture.region == idle_region:
            push_error("POSE_FRAME_STUCK: attack never changed the rendered source region")
            actor.free()
            quit(1)
            return
        await create_timer(0.8).timeout
        if actor.get_render_texture().region != idle_region or actor.motion_state != "idle":
            push_error("POSE_RECOVERY_FAILED: attack did not restore idle")
            actor.free()
            quit(1)
            return
        if not actor.material is ShaderMaterial:
            push_error("POSE_CHROMA_MISSING: green source background would render")
            actor.free()
            quit(1)
            return
        for reaction in ["hit", "evade", "block", "clash"]:
            if reaction == "clash":
                actor.play_clash_motion(actor.get_foot_anchor_global(), 0.5)
            else:
                actor.call("play_%s_motion" % reaction, 0.5)
            await process_frame
            var reaction_rect: Rect2 = actor._sprite_rect_local()
            if not is_equal_approx(reaction_rect.size.aspect(), actor.get_render_texture().region.size.aspect()):
                push_error("REACTION_ASPECT_DISTORTED")
                quit(1)
                return
            if actor.get_render_texture().atlas == idle_texture.atlas:
                push_error("REACTION_POSE_MISSING: %s %s still uses attack/idle sheet" % [actor_role, reaction])
                quit(1)
                return
            await create_timer(0.65).timeout
            if actor.get_render_texture().atlas != idle_texture.atlas or actor.motion_state != "idle":
                push_error("REACTION_RECOVERY_FAILED")
                quit(1)
                return
        actor.free()
    print("CHARACTER_POSE_ANIMATION_PASS: both actors change actual source frames and recover")
    quit(0)
