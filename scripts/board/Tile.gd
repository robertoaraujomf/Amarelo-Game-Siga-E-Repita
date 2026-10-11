class_name Tile
extends Node2D
## Celula do tabuleiro: desenha uma forma organica arredondada + icone/token.

var symbol: String = "."
var cell_size: float = 96.0
var visited: bool = false
var is_player: bool = false
var is_next: bool = false

var _time: float = 0.0


func _process(delta: float) -> void:
	if is_player or is_next or LevelMatrix.is_special(symbol) \
			or LevelMatrix.is_start(symbol) or LevelMatrix.is_end(symbol):
		_time += delta
		queue_redraw()


func _draw() -> void:
	var r := cell_size * 0.46
	var rect := Rect2(Vector2(-r, -r), Vector2(r * 2.0, r * 2.0))
	var base := StyleFactory.color_for(symbol)

	# Corpo organico (bem arredondado, cantos irregulares).
	draw_style_box(StyleFactory.organic_panel(base, int(r * 0.85)), rect)

	# Brilho superior (aspecto de bala/gelatina) - highlight, nao fundo.
	draw_circle(Vector2(-r * 0.30, -r * 0.34), r * 0.30, Color(1, 1, 1, 0.26))

	# Anel interno indicando que a posicao ja foi visitada.
	if visited:
		draw_arc(Vector2.ZERO, r * 0.74, 0.0, TAU, 40, Color(1, 1, 1, 0.5), r * 0.10, true)

	_draw_glyph(r)

	if LevelMatrix.is_start(symbol):
		_draw_start_marker(r)
	if LevelMatrix.is_end(symbol):
		_draw_end_marker(r)
	if is_next:
		_draw_next_hint(r)
	if is_player:
		_draw_player_halo(r)


func _draw_glyph(r: float) -> void:
	var white := Color.WHITE
	if LevelMatrix.is_special(symbol):
		_draw_sparkle(r, white)
	elif LevelMatrix.is_start(symbol):
		_draw_home(r, white)
	elif LevelMatrix.is_end(symbol):
		_draw_star(r, white)
	else:
		_draw_token(r, white)


## Desenha o token (numero, letra ou multi-caractere como "10").
func _draw_token(r: float, c: Color) -> void:
	var font := ThemeDB.fallback_font
	var fs := int(cell_size * 0.5)
	if symbol.length() >= 2:
		fs = int(cell_size * 0.36)
	var s := font.get_string_size(symbol, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	draw_string(font, Vector2(-s.x * 0.5, fs * 0.36), symbol,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, c)


func _draw_sparkle(r: float, c: Color) -> void:
	var pts := PackedVector2Array()
	var n := 8
	for i in n:
		var a := TAU * float(i) / float(n) - PI * 0.5
		var rad := r * (0.62 if i % 2 == 0 else 0.26)
		pts.append(Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, c)


func _draw_home(r: float, c: Color) -> void:
	var s := r * 0.5
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -s), Vector2(-s, 0), Vector2(s, 0)
	]), c)
	draw_rect(Rect2(Vector2(-s * 0.66, 0.0), Vector2(s * 1.32, s)), c)


func _draw_star(r: float, c: Color) -> void:
	var pts := PackedVector2Array()
	var n := 10
	for i in n:
		var a := TAU * float(i) / float(n) - PI * 0.5
		var rad := r * (0.68 if i % 2 == 0 else 0.28)
		pts.append(Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, c)


## Sinalizacao constante do Inicio (anel ciano pulsante).
func _draw_start_marker(r: float) -> void:
	var pulse := 0.6 + 0.4 * sin(_time * 3.0)
	draw_arc(Vector2.ZERO, r * 1.02, 0.0, TAU, 48,
			Color(0.18, 0.77, 0.71, 0.25 + 0.35 * pulse), r * 0.14, true)


## Sinalizacao constante do Fim (anel rosa pulsante).
func _draw_end_marker(r: float) -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 3.0 + PI)
	draw_arc(Vector2.ZERO, r * 1.05, 0.0, TAU, 48,
			Color(1.0, 0.36, 0.64, 0.30 + 0.40 * pulse), r * 0.16, true)


## Dica do proximo alvo (casou com a sequencia atual).
func _draw_next_hint(r: float) -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 6.0)
	draw_arc(Vector2.ZERO, r * 0.98, 0.0, TAU, 48,
			Color(1, 1, 1, 0.15 + 0.5 * pulse), r * 0.09, true)


## Borda amarela, brilhante e piscando na posicao atual do player.
func _draw_player_halo(r: float) -> void:
	var t := _time * 5.0
	for i in 4:
		var a := 0.55 * (0.5 + 0.5 * sin(t - float(i) * 0.7))
		var rr := r * (1.02 + float(i) * 0.09)
		draw_arc(Vector2.ZERO, rr, 0.0, TAU, 56,
				Color(StyleFactory.HIGHLIGHT, a), r * 0.10, true)
