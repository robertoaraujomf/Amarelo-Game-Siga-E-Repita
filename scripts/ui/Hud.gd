class_name Hud
extends CanvasLayer
## HUD: título da fase, sequência atual, próxima posição especial, controles
## (D-pad ou dica de swipe), botões de desfazer/reiniciar e overlay de vitória.

signal back_pressed
signal dpad(direction: Vector2i)
signal undo_pressed
signal restart_pressed
signal next_level_pressed

var _title: Label
var _seq_box: HBoxContainer
var _special_box: HBoxContainer
var _special_chip: FigureIcon
var _grid: GridContainer
var _swipe_hint: Label
var _overlay: Control
var _blocked_label: Label
var _blocked_tween: Tween

var _vbox: VBoxContainer
var _top_panel: PanelContainer
var _bottom_panel: PanelContainer


func _ready() -> void:
	_build_root()
	_build_top()
	_build_controls()
	_build_blocked()
	_build_overlay()


func _build_root() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 14)
	margin.add_child(_vbox)


func _build_top() -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", StyleFactory.rounded_panel(StyleFactory.CARD, 44))
	_vbox.add_child(panel)
	_top_panel = panel

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	panel.add_child(inner)

	# Cabeçalho: voltar + título
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	inner.add_child(header)

	var back := StyleFactory.make_button("<", Color("ff8fab"), 42)
	back.custom_minimum_size = Vector2(72, 72)
	back.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(func() -> void: back_pressed.emit())
	header.add_child(back)

	_title = Label.new()
	_title.text = "Fase"
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color.WHITE)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(_title)

	# Sequência de imagens
	var caption := Label.new()
	caption.text = "Sequência atual"
	caption.add_theme_font_size_override("font_size", 20)
	caption.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(caption)

	_seq_box = HBoxContainer.new()
	_seq_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_seq_box.add_theme_constant_override("separation", 10)
	inner.add_child(_seq_box)

	_special_box = HBoxContainer.new()
	_special_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_special_box.add_theme_constant_override("separation", 10)
	_special_box.visible = false
	inner.add_child(_special_box)

	var approach := Label.new()
	approach.text = "Chegue até"
	approach.add_theme_font_size_override("font_size", 24)
	approach.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	approach.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_special_box.add_child(approach)

	_special_chip = FigureIcon.new()
	_special_chip.custom_minimum_size = Vector2(56, 56)
	_special_box.add_child(_special_chip)


func _build_controls() -> void:
	# Espaço elástico: empurra os controles para o rodapé, liberando o mapa.
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vbox.add_child(spacer)

	_bottom_panel = PanelContainer.new()
	_bottom_panel.add_theme_stylebox_override("panel", StyleFactory.rounded_panel(StyleFactory.CARD, 44))
	_vbox.add_child(_bottom_panel)

	var inner := MarginContainer.new()
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		inner.add_theme_constant_override(s, 14)
	_bottom_panel.add_child(inner)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	inner.add_child(col)

	# Botões de ação (sempre visiveis)
	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	action_row.add_theme_constant_override("separation", 14)
	col.add_child(action_row)

	var undo := StyleFactory.make_button("Desfazer", Color("ff9f1c"), 28)
	undo.custom_minimum_size = Vector2(180, 70)
	undo.pressed.connect(func() -> void: undo_pressed.emit())
	action_row.add_child(undo)

	var restart := StyleFactory.make_button("Reiniciar", Color("ff5d6c"), 28)
	restart.custom_minimum_size = Vector2(180, 70)
	restart.pressed.connect(func() -> void: restart_pressed.emit())
	action_row.add_child(restart)

	# D-pad (modo setas)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	col.add_child(_grid)

	_grid.add_child(_spacer())
	_grid.add_child(_dpad_button("^", Vector2i(0, -1)))
	_grid.add_child(_spacer())
	_grid.add_child(_dpad_button("<", Vector2i(-1, 0)))
	_grid.add_child(_spacer())
	_grid.add_child(_dpad_button(">", Vector2i(1, 0)))
	_grid.add_child(_spacer())
	_grid.add_child(_dpad_button("v", Vector2i(0, 1)))
	_grid.add_child(_spacer())

	# Dica de swipe (modo toque)
	_swipe_hint = Label.new()
	_swipe_hint.text = "Deslize o dedo sobre o mapa para mover"
	_swipe_hint.add_theme_font_size_override("font_size", 22)
	_swipe_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	_swipe_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_swipe_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_swipe_hint.add_theme_stylebox_override("normal", StyleFactory.rounded_panel(StyleFactory.HINT, 34))
	_swipe_hint.custom_minimum_size = Vector2(420, 70)
	_swipe_hint.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(_swipe_hint)


func _spacer() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(96, 96)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _dpad_button(glyph: String, dir: Vector2i) -> Button:
	var b := StyleFactory.make_button(glyph, Color("7c5cff"), 44)
	b.custom_minimum_size = Vector2(96, 96)
	b.pressed.connect(func() -> void: dpad.emit(dir))
	return b


func _build_blocked() -> void:
	var center := CenterContainer.new()
	center.anchor_left = 0.0
	center.anchor_right = 1.0
	center.anchor_top = 0.0
	center.anchor_bottom = 0.45
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_blocked_label = Label.new()
	_blocked_label.text = "Caminho bloqueado!"
	_blocked_label.add_theme_font_size_override("font_size", 30)
	_blocked_label.add_theme_color_override("font_color", Color.WHITE)
	_blocked_label.add_theme_stylebox_override("normal",
			StyleFactory.rounded_panel(Color("ff5d6c"), 34))
	_blocked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_blocked_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_blocked_label.custom_minimum_size = Vector2(380, 76)
	_blocked_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_blocked_label.modulate.a = 0.0
	_blocked_label.pivot_offset = Vector2(190, 38)
	center.add_child(_blocked_label)


func _build_overlay() -> void:
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	add_child(_overlay)

	var dim := ColorRect.new()
	dim.color = StyleFactory.OVERLAY_DIM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",
			StyleFactory.rounded_panel(StyleFactory.WIN_PANEL, 56))
	center.add_child(panel)

	var margin := MarginContainer.new()
	for s in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(s, 30)
	panel.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	margin.add_child(col)

	var title := Label.new()
	title.text = "Fase concluída!"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("ffe24d"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	var star := Label.new()
	star.text = "Você passou por todas as posições!"
	star.add_theme_font_size_override("font_size", 20)
	star.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	star.custom_minimum_size = Vector2(360, 0)
	col.add_child(star)

	var next := StyleFactory.make_button("Continuar", Color("6bcb77"), 34)
	next.pressed.connect(func() -> void:
		_overlay.visible = false
		next_level_pressed.emit())
	col.add_child(next)


# ------------------------------------------------------------------ API
## Altura da HUD no topo, em pixels (para a câmera não cobrir o jogador).
func top_margin() -> float:
	if _top_panel == null:
		return 0.0
	return _top_panel.global_position.y + _top_panel.size.y


## Altura da HUD no rodapé, em pixels.
func bottom_margin() -> float:
	if _bottom_panel == null:
		return 0.0
	var height := get_viewport().get_visible_rect().size.y
	return height - _bottom_panel.global_position.y


func set_level_info(index: int, total: int) -> void:
	_title.text = "Fase %d de %d" % [index, total]


func set_sequence(seq: Array, step: int) -> void:
	for c in _seq_box.get_children():
		c.queue_free()
	if seq.is_empty():
		return
	var active := step % seq.size()
	for i in seq.size():
		var sym := str(seq[i])
		var col := StyleFactory.color_for(sym)

		var chip := PanelContainer.new()
		chip.custom_minimum_size = Vector2(60, 60)
		var sb := StyleFactory.rounded_panel(col, 26)
		if i == active:
			sb.bg_color = col.lightened(0.10)
			sb.set_border_width_all(5)
			sb.border_color = StyleFactory.HIGHLIGHT
		else:
			sb.bg_color = col.darkened(0.20)
		chip.add_theme_stylebox_override("panel", sb)

		var icon := FigureIcon.new()
		icon.symbol = sym
		icon.draw_background = false
		icon.custom_minimum_size = Vector2(48, 48)
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		chip.add_child(icon)

		_seq_box.add_child(chip)


func set_next_special(pos: Vector2i, symbol: String) -> void:
	if pos == Vector2i(-1, -1) or symbol == "":
		_special_box.visible = false
		return
	_special_box.visible = true
	_special_chip.symbol = symbol


func set_control_mode(mode: int) -> void:
	var arrows := mode == Settings.ControlMode.ARROWS
	_grid.visible = arrows
	_swipe_hint.visible = not arrows


func pop_blocked() -> void:
	if _blocked_tween != null and _blocked_tween.is_valid():
		_blocked_tween.kill()
	_blocked_label.modulate.a = 1.0
	_blocked_label.scale = Vector2(0.8, 0.8)
	_blocked_tween = create_tween()
	_blocked_tween.tween_property(_blocked_label, "scale", Vector2.ONE, 0.15) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_blocked_tween.tween_interval(0.5)
	_blocked_tween.tween_property(_blocked_label, "modulate:a", 0.0, 0.3)


func show_win() -> void:
	_overlay.visible = true
	_overlay.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_overlay, "modulate:a", 1.0, 0.25)


func hide_win() -> void:
	_overlay.visible = false
