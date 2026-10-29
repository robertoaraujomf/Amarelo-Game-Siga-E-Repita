extends Control
## Tela de seleção/transição de fases: uma TRILHA serpenteante onde cada "no"
## representa uma fase (concluída / atual / próxima / bloqueada).

func _ready() -> void:
	add_child(Background.new())

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(s, 20)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	margin.add_child(col)

	# Cabeçalho
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	col.add_child(header)

	var back := StyleFactory.make_button("<", Color("ff8fab"), 42)
	back.custom_minimum_size = Vector2(72, 72)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	header.add_child(back)

	var title := Label.new()
	title.text = "Trilha das Fases"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)

	# Trilha rolavel
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)

	var trail := LevelTrail.new()
	trail.selected.connect(_on_selected)
	trail.build(Levels.levels, GameState)
	scroll.add_child(trail)

	var reset := StyleFactory.make_button("Zerar progresso", Color("ff6b6b"), 28)
	reset.custom_minimum_size = Vector2(0, 72)
	reset.pressed.connect(func() -> void:
		GameState.reset_progress()
		get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn"))
	col.add_child(reset)


func _on_selected(level_id: int) -> void:
	GameState.start_level(level_id)
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
