extends RefCounted
## Screen identity selects art only; it never selects routes, rewards or opponents.
const ROOT := "res://assets/backgrounds/ink_wuxia/"
const INK := Color("272920")
const PAPER := Color("eee5d2")

static func backdrop(screen: String, resting := false) -> Texture2D:
	var surface := "setup"
	if resting: surface = "rest"
	elif screen == "MAIN": surface = "main"
	elif screen == "BRIEFING": surface = "briefing"
	elif screen in ["RESULT","COMPLETION","FAILURE_RETRY","FAILURE_END"]: surface = "result"
	elif screen in ["JIANGHU","ROUTE_GROWTH","ROUTE_INFO"]: surface = "journey"
	return load(ROOT + surface + ".png") as Texture2D

static func theme() -> Theme:
	var result := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Batang","Noto Serif CJK KR","serif"])
	result.default_font = font
	result.default_font_size = 18
	for kind in ["Label","Button","OptionButton","CheckButton","RichTextLabel"]:
		result.set_color("font_color",kind,INK)
		result.set_color("default_color",kind,INK)
		for key in ["font_hover_color","font_focus_color"]:
			result.set_color(key,kind,INK)
		result.set_color("font_pressed_color",kind,PAPER)
		result.set_color("font_hover_pressed_color",kind,PAPER)
		result.set_color("font_disabled_color",kind,Color("676155"))
	for kind in ["Button","OptionButton","CheckButton"]:
		for state in ["normal","hover","pressed","disabled","focus"]:
			var box := StyleBoxFlat.new()
			box.bg_color = Color("f0e7d5")
			box.border_color = Color("93866e")
			box.set_border_width_all(1)
			box.content_margin_left = 14
			box.content_margin_right = 14
			box.content_margin_top = 7
			box.content_margin_bottom = 7
			if state == "hover": box.bg_color = Color("dfd1b3")
			elif state == "pressed": box.bg_color = Color("304c4d")
			elif state == "disabled": box.bg_color = Color("d7ceb9")
			elif state == "focus":
				box.bg_color = Color.TRANSPARENT
				box.border_color = Color("853f31")
				box.set_border_width_all(2)
			result.set_stylebox(state,kind,box)
	return result
