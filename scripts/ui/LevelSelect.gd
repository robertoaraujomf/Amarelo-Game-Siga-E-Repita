extends Control
## Tela de seleção/transição de fases: uma TRILHA serpenteante onde cada "no"
## representa uma fase (concluída / atual / próxima / bloqueada).

var _scroll: ScrollContainer


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
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	col.add_child(_scroll)

	var trail := LevelTrail.new()
	trail.selected.connect(_on_selected)
	trail.build(Levels.levels, GameState)
	_scroll.add_child(trail)

	# Foca a trilha na fase atual do jogador (nao no inicio).
	call_deferred("_focus_current_phase", trail)

	# Oculta as barras de rolagem (movimentacao manual por clique/dedo).
	call_deferred("_hide_scroll_bars")

	var reset := StyleFactory.make_button("Zerar progresso", Color("ff6b6b"), 28)
	reset.custom_minimum_size = Vector2(0, 72)
	reset.pressed.connect(func() -> void:
		GameState.reset_progress()
		get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn"))
	col.add_child(reset)


func _focus_current_phase(trail: LevelTrail) -> void:
	if _scroll == null or trail == null:
		return
	var target_id := clampi(GameState.next_level_id(), 1, maxi(Levels.count(), 1))
	var pos := trail.node_pos(target_id)
	# Centraliza o circulo da fase atual na viewport.
	_scroll.scroll_horizontal = int(pos.x - _scroll.size.x * 0.5)
	_scroll.scroll_vertical = int(pos.y - _scroll.size.y * 0.5)


func _hide_scroll_bars() -> void:
	if _scroll == null:
		return
	if _scroll.get_v_scroll_bar() != null:
		_scroll.get_v_scroll_bar().visible = false
		_scroll.get_v_scroll_bar().modulate.a = 0.0
	if _scroll.get_h_scroll_bar() != null:
		_scroll.get_h_scroll_bar().visible = false
		_scroll.get_h_scroll_bar().modulate.a = 0.0


func _process(_delta: float) -> void:
	# Garante que as barras permanecam ocultas.
	if _scroll != null:
		if _scroll.get_v_scroll_bar() != null:
			_scroll.get_v_scroll_bar().visible = false
		if _scroll.get_h_scroll_bar() != null:
			_scroll.get_h_scroll_bar().visible = false


func _on_selected(level_id: int) -> void:
	GameState.start_level(level_id)
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")