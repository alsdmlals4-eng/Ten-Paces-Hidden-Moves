class_name CombatScreenSurface
extends Panel

# Reusable non-interactive surface that separates a combat screen into readable
# information, duel, and planning regions without coupling to combat state.
const INK := Color("171411")
const PAPER_INK := Color("2b2118")
const GOLD := Color("b99254")

var surface_role := ""

func configure_surface(value_role: String) -> void:
	surface_role = value_role
	name = _node_name_for_role(surface_role) if name.is_empty() else name
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("surface_role", surface_role)
	set_meta("input_policy", "ignore")
	_apply_surface_style()

func _node_name_for_role(value_role: String) -> String:
	match value_role:
		"top_hud":
			return "TopHudSurface"
		"duel_stage":
			return "DuelStageSurface"
		"planning":
			return "PlanningSurface"
		_:
			return "CombatScreenSurface"

func _apply_surface_style() -> void:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(4)
	match surface_role:
		"top_hud":
			style.bg_color = Color(INK, 0.97)
			style.border_color = Color(GOLD, 0.72)
			style.border_width_bottom = 2
			style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
			style.shadow_size = 5
		"duel_stage":
			style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
			style.border_color = Color(PAPER_INK, 0.82)
			style.set_border_width_all(2)
		"planning":
			style.bg_color = Color(INK, 0.98)
			style.border_color = Color(GOLD, 0.76)
			style.border_width_top = 3
			style.set_border_width_all(1)
			style.border_width_top = 3
			style.shadow_color = Color(0.0, 0.0, 0.0, 0.56)
			style.shadow_size = 6
		_:
			style.bg_color = Color(INK, 0.90)
	add_theme_stylebox_override("panel", style)
