extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for height in [38.0, 42.0, 56.0, 90.0]:
		var slot = load("res://src/ui/action_timing_slot.gd").new()
		root.add_child(slot)
		slot.size = Vector2(175, height)
		slot.configure(1, 1, 1, "current")
		for state in ["empty", "assigned", "target", "resource"]:
			if state != "empty":
				slot.set_assignment({"id":"basic_move", "name":"이동", "category":"move", "timing_cost":1}, 1, 1, 0)
			if state == "target":
				slot.set_target_info("", false, "board_tile")
			if state == "resource":
				slot.set_resource_info(false, "기력 부족")
			await process_frame
			var rects: Array[Rect2] = []
			for label in [slot._timing_label, slot._placeholder_label, slot._status_label]:
				if not label.visible:
					continue
				var rect: Rect2 = label.get_rect()
				if not Rect2(Vector2.ZERO, slot.size).encloses(rect):
					push_error("TIMING_LABEL_OUTSIDE %s %s" % [height, state])
					quit(1)
					return
				for prior in rects:
					if prior.intersects(rect):
						push_error("TIMING_LABEL_OVERLAP %s %s" % [height, state])
						quit(1)
						return
				rects.append(rect)
			if (state in ["target", "resource"] and slot._status_label.text.is_empty()) or not slot._status_label.visible:
				push_error("TIMING_STATE_HIDDEN")
				quit(1)
				return
		slot.free()
	print("COMPACT_TIMING_LABELS_PASS")
	quit(0)
