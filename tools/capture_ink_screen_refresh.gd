extends SceneTree
## Native UI fixtures with isolated saves. Result/rest inject only documented fixture facts.
var shell
var shots: Array = []
var fixture_seed := -1
const OUT := "res://docs/blueprint/evidence/ink-screens-20260925/"

func _initialize() -> void:
	call_deferred("capture")

func shot(key: String, source := "ordinary_screen_navigation") -> void:
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+key+".png") == OK)
	shots.append({"key":key,"source":source,"path":OUT+key+".png","sha256":FileAccess.get_sha256(OUT+key+".png"),"size":[root.size.x,root.size.y]})

func capture() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	shell = load("res://scenes/run/vertical_slice_shell.tscn").instantiate()
	# Each capture starts at a clean title; a prior test save is never user data.
	shell._save_storage_override = "res://output/ink-screen-validation/fixture-save-%d.json" % OS.get_process_id()
	root.add_child(shell)
	await create_timer(0.5).timeout
	await shot("main")
	# Select a reproducible current-art opponent without changing the random public start command.
	var roster := VariableOpponentRoster.new()
	for seed in range(1000):
		if roster.generate(seed)[0].candidate_id == "slot1_dogyeom":
			fixture_seed = seed
			break
	assert(fixture_seed >= 0)
	assert(shell.session.transact(func(): return shell.run_state.start_new_giyun_run(fixture_seed, shell.session.save_id), true))
	await shot("setup")
	for manual in ["mount_hua_plum_blossom_sword","shaolin_arhat_vajra_art","wudang_taiji_sword","yang_family_spear"]:
		shell.toggle_setup_manual(manual)
	shell.advance_noncombat()
	shell.advance_noncombat()
	await shot("briefing")
	shell.advance_noncombat()
	await shot("preparation")
	shell.complete_combat_for_runtime({"outcome":"win","player_resources":{"health":[12,40],"stamina":[2,5],"internal":[1,4]}})
	shell.complete_review_for_runtime()
	await shot("result","terminal_UI_fixture_not_a_won_duel")
	shell.select_result_reward("free_training")
	shell.advance_noncombat()
	await shot("journey","post_result_UI_fixture")
	# Display the actual shell's resting layout; no rewards are awarded here.
	shell._set_route_composition(true)
	shell.title_label.text = "주막에서 휴식"
	shell.description_label.text = "빗소리를 들으며 잠시 몸을 추스릅니다.\n\n휴식 후 실제 회복량은 선택 결과에 표시됩니다."
	shell.route_options_container.visible = false
	await shot("rest","rest_composition_fixture_reward_rules_verified_separately")
	var f := FileAccess.open(OUT+"capture.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"project":ProjectSettings.globalize_path("res://"),"save_isolation":shell._save_storage_override,"fixture_seed":fixture_seed,"opponent":"slot1_dogyeom","shots":shots},"\t"))
	print("INK_SCREEN_CAPTURE count=",shots.size())
	quit()
