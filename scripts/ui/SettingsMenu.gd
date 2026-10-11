extends Control
## Tela de configuracoes: metodo de controle e feedback.

var _swipe_btn: Button
var _arrows_btn: Button
var _haptics_btn: Button


func _ready() -> void:
	add_child(Background.new())

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(s, 40)
	add_child(margin)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 18)
	margin.add_child(col)

	var title := Label.new()
	title.text = "Configuracoes"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.WHITE)
	col.add_child(title)

	var caption := Label.new()
	caption.text = "Metodo de controle"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 24)
	caption.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	col.add_child(caption)

	_swipe_btn = StyleFactory.make_button("Toque / Deslizar", Color("6bcb77"), 34)
	_swipe_btn.pressed.connect(func() -> void:
		Settings.set_control_mode(Settings.ControlMode.SWIPE)
		_refresh())
	col.add_child(_swipe_btn)

	_arrows_btn = StyleFactory.make_button("Setas direcionais", Color("4d96ff"), 34)
	_arrows_btn.pressed.connect(func() -> void:
		Settings.set_control_mode(Settings.ControlMode.ARROWS)
		_refresh())
	col.add_child(_arrows_btn)

	_haptics_btn = StyleFactory.make_button("Vibracao", Color("b983ff"), 30)
	_haptics_btn.pressed.connect(func() -> void:
		Settings.toggle_haptics()
		_refresh())
	col.add_child(_haptics_btn)

	var back := StyleFactory.make_button("Voltar", Color("ff6b6b"), 30)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	col.add_child(back)

	_refresh()


func _refresh() -> void:
	_mark(_swipe_btn, Settings.control_mode == Settings.ControlMode.SWIPE)
	_mark(_arrows_btn, Settings.control_mode == Settings.ControlMode.ARROWS)
	_haptics_btn.text = "Vibracao: %s" % ("ligada" if Settings.haptics_enabled else "desligada")


func _mark(btn: Button, selected: bool) -> void:
	btn.text = btn.text.replace("  [ativo]", "")
	if selected:
		btn.text += "  [ativo]"
