extends Control
## Tela inicial.

func _ready() -> void:
	add_child(Background.new())

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(s, 40)
	add_child(margin)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 20)
	margin.add_child(col)

	var title := Label.new()
	title.text = "Siga e Repita"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 66)
	title.add_theme_color_override("font_color", Color.WHITE)
	col.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Siga a sequencia e chegue ao fim passando por tudo!"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	col.add_child(subtitle)

	col.add_child(_gap(30))

	var play := StyleFactory.make_button("Jogar", Color("6bcb77"), 40)
	play.pressed.connect(_on_play)
	col.add_child(play)

	var settings := StyleFactory.make_button("Configuracoes", Color("b983ff"), 34)
	settings.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/ui/Settings.tscn"))
	col.add_child(settings)

	var quit := StyleFactory.make_button("Sair", Color("ff6b6b"), 30)
	quit.pressed.connect(func() -> void: get_tree().quit())
	col.add_child(quit)


func _gap(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _on_play() -> void:
	# A trilha de fases e o hub: sempre passa por ela antes de jogar.
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
