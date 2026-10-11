class_name FigureIcon
extends Control
## Desenha a "figura" de um token exatamente como no tabuleiro (sparkle para a
## posicao especial, casa para o inicio, estrela para o fim, texto para tokens).
## Usado pelas instrucoes da HUD para o alvo bater com o que aparece no mapa.

var symbol: String = "":
	set(value):
		symbol = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if symbol == "":
		return
	var r := minf(size.x, size.y) * 0.46
	var center := size * 0.5
	var base := StyleFactory.color_for(symbol)

	draw_style_box(StyleFactory.organic_panel(base, int(r * 0.85)),
			Rect2(center - Vector2(r, r), Vector2(r * 2.0, r * 2.0)))
	draw_circle(center + Vector2(-r * 0.30, -r * 0.34), r * 0.30, Color(1, 1, 1, 0.26))

	var white := Color.WHITE
	if LevelMatrix.is_special(symbol):
		_draw_sparkle(center, r, white)
	elif LevelMatrix.is_start(symbol):
		_draw_home(center, r, white)
	elif LevelMatrix.is_end(symbol):
		_draw_star(center, r, white)
	else:
		_draw_token(center, r, white)


func _draw_token(center: Vector2, r: float, c: Color) -> void:
	var font := ThemeDB.fallback_font
	var fs := int(r * 1.09)
	if symbol.length() >= 2:
		fs = int(r * 0.78)
	var s := font.get_string_size(symbol, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	draw_string(font, center + Vector2(-s.x * 0.5, fs * 0.36), symbol,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)


func _draw_sparkle(center: Vector2, r: float, c: Color) -> void:
	var pts := PackedVector2Array()
	var n := 8
	for i in n:
		var a := TAU * float(i) / float(n) - PI * 0.5
		var rad := r * (0.62 if i % 2 == 0 else 0.26)
		pts.append(center + Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, c)


func _draw_home(center: Vector2, r: float, c: Color) -> void:
	var s := r * 0.5
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0, -s), center + Vector2(-s, 0), center + Vector2(s, 0)
	]), c)
	draw_rect(Rect2(center + Vector2(-s * 0.66, 0.0), Vector2(s * 1.32, s)), c)


func _draw_star(center: Vector2, r: float, c: Color) -> void:
	var pts := PackedVector2Array()
	var n := 10
	for i in n:
		var a := TAU * float(i) / float(n) - PI * 0.5
		var rad := r * (0.68 if i % 2 == 0 else 0.28)
		pts.append(center + Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, c)
