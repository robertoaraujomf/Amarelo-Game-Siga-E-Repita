extends Control
## Tela de selecao/transicao de fases: mostra concluidas, atual e proxima.

func _ready() -> void:
	add_child(Background.new())

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(s, 24)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)

	# Cabecalho
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	col.add_child(header)

	var back := StyleFactory.make_button("<", Color("ff8fab"), 42)
	back.custom_minimum_size = Vector2(72, 72)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
	header.add_child(back)

	var title := Label.new()
	title.text = "Mapa de Fases"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)

	# Lista rolavel
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 14)
	scroll.add_child(list)

	for i in Levels.count():
		var lvl: Dictionary = Levels.get_level_by_index(i)
		list.add_child(_make_card(lvl))


func _make_card(lvl: Dictionary) -> Button:
	var id := int(lvl.get("id", 1))
	var name := str(lvl.get("name", "Fase"))
	var status := GameState.level_status(id)

	var label := "%d. %s" % [id, name]
	var color := Color("4d96ff")
	match status:
		"completed":
			label += "   concluida"
			color = Color("6bcb77")
		"current":
			label += "   atual"
			color = Color("ffb14d")
		"locked":
			label += "   bloqueada"
			color = Color("6b6b7b")
		_:
			label += "   jogar"

	var card := StyleFactory.make_button(label, color, 30)
	card.custom_minimum_size = Vector2(0, 96)
	card.disabled = status == "locked"
	card.alignment = HORIZONTAL_ALIGNMENT_LEFT
	if not card.disabled:
		card.pressed.connect(func() -> void:
			GameState.start_level(id)
			get_tree().change_scene_to_file("res://scenes/game/Game.tscn"))
	return card
