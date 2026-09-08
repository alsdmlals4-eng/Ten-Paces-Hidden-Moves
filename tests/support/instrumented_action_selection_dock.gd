extends ActionSelectionDock

var owned_manual_build_count := 0

func _build_owned_manuals(loadout: Array, mastery_by_manual: Dictionary) -> Array[Dictionary]:
    owned_manual_build_count += 1
    return super._build_owned_manuals(loadout, mastery_by_manual)
