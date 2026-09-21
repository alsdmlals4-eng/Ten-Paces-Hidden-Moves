extends SceneTree

var failures: Array[String] = []
var checks := 0
func expect(value: bool, message: String) -> void:
    checks += 1
    if not value: failures.append(message)

func _initialize() -> void:
    create_timer(40).timeout.connect(func(): push_error("FEEDBACK_TIMEOUT"); quit(1))
    call_deferred("run")

func run() -> void:
    var sequence = load("res://src/ui/combat_motion_sequence.gd")
    var event := {"type":"action_result", "actor":"player", "timing":1, "card_id":"yang_family_spear_star3", "outcome":"martial_completed", "damage":0, "defense_outcome":"martial_pipeline", "martial_events":[{"op":"ATTACK", "status":"EVADED", "health_damage":0}]}
    var cues: Array = sequence.compile([event])
    expect(cues.size() == 1 and cues[0].get("defense_outcome") == "evade", "Martial EVADED must visibly evade.")
    event.damage = 4
    event.martial_events = [{"op":"ATTACK","status":"HIT","health_damage":4},{"op":"INDEPENDENT_ATTACK","status":"EVADED","health_damage":0}]
    cues = sequence.compile([event])
    expect(cues.size()==2 and cues[0].damage==4 and cues[1].damage==0 and cues[1].defense_outcome=="evade", "Mixed hit and evasion preserve order and factual total.")
    var art = load("res://src/ui/approved_blueprint_art.gd")
    var hud = load("res://src/ui/combatant_status_panel.gd").new()
    root.add_child(hud)
    hud.side = "enemy"
    var paths := {}
    for id in art.PORTRAITS:
        hud.combatant = {"candidate_id":id}
        var texture: Texture2D = hud._portrait_for_current_combatant()
        var path: String = texture.atlas.resource_path if texture is AtlasTexture else texture.resource_path
        expect(path == art.portrait_path(id), "HUD must show approved identity: " + id)
        paths[path] = true
    expect(paths.size() == 16, "Sixteen opponents must not share one HUD identity.")
    hud.free()
    var title = load("res://src/ui/main_title_screen.gd").new()
    root.add_child(title)
    title.configure_continue({}, "EMPTY")
    expect(title.find_child("MainSettingsButton",true,false) != null, "Title needs the reference Settings action.")
    expect(title.find_child("EnemyTitleBattler",true,false) == null, "Restore travel title instead of a combat pairing.")
    expect(title.find_child("MainContinueButton",true,false).visible, "Three reference menu actions stay visible without a save.")
    var artwork := title.find_child("JourneyTitleArtwork",true,false) as TextureRect
    expect(artwork != null and artwork.texture != null, "Restored title artwork must actually load.")
    expect(artwork.texture is AtlasTexture and artwork.texture.region.position.y == 32, "Title excludes the reference-only page caption.")
    title.configure_continue({"run_state":{"duel_index":3,"current_screen":"JIANGHU","jianghu_step":1},"combat_checkpoint":{}}, "VALID")
    expect("비무 3" in title.get_node("MainContinueButton").tooltip_text and "행로 2/4" in title.get_node("MainContinueButton").tooltip_text, "Continue retains saved location.")
    title.free()
    var stats = load("res://src/ui/starting_stats_panel.gd").new()
    root.add_child(stats)
    expect(stats.find_child("StatEffects",true,false) != null, "Stat effects must be readable before committing allocation.")
    stats.free()
    var catalog = load("res://src/run/vertical_slice_starter_manual_catalog.gd").new()
    for option in catalog.get_options():
        expect(not str(option.get("effect_text", "")).is_empty(), "Starter effect missing: " + str(option.manual_id))
        expect(option.has("stamina_cost") and option.has("internal_cost") and option.has("action_slots"), "Starter costs missing: " + str(option.manual_id))
    var sky: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/cards/martial_manuals/nangong_boundless_sky_sword.json"))
    var sky_text: String = load("res://src/ui/martial_effect_description.gd").describe(sky.cards.star3)
    expect("준비" in sky_text and "소비했을 때" in sky_text and "특수 합 위력 8 + 내공" in sky_text and not "CONSUME_STATUS" in sky_text, "Sky sword describes conditional defense and stat-scaled clash.")
    var actor = load("res://src/combat/combat_character_placeholder.gd").new()
    root.add_child(actor)
    actor.configure("player",1,1,160,1.5,0.72)
    var preset: Dictionary = load("res://src/ui/combat_motion_presets.gd").for_card("basic_palm")
    actor.play_preset_motion(preset,0.8)
    await create_timer(0.22).timeout
    expect(actor.visual_offset != Vector2.ZERO or absf(actor.visual_scale-1.0)>0.001, "Neutral/ranged caster must visibly anticipate without a fake sword strike.")
    actor.reset_choreography()
    expect(actor.visual_offset == Vector2.ZERO and actor.visual_scale == 1.0, "Cancel restores caster.")
    actor.free()
    for failure in failures: push_error(failure)
    print("PLAYER_FEEDBACK_CORRECTIONS checks=%d failures=%d" % [checks,failures.size()])
    quit(0 if failures.is_empty() else 1)
