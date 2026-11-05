class_name FigureIcon
extends Control
## Desenha a "figura" de um token exatamente como no tabuleiro (sparkle para a
## posição especial, casa para o Início, estrela para o fim, texto para tokens).
## Usado pelas instruções da HUD para o alvo bater com o que aparece no mapa.

var symbol: String = "":
	set(value):
		symbol = value
		_texture = null
		_texture_tried = false
		_sheet = null
		_sheet_tried = false
		queue_redraw()

var draw_background: bool = true

var _texture: Texture2D = null
var _texture_tried: bool = false
var _sheet: Texture2D = null
var _sheet_frames: int = 1
var _sheet_fps: float = 10.0
var _sheet_tried: bool = false
var _time: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(delta: float) -> void:
	_ensure_sheet()
	if _sheet != null:
		_time += delta
		queue_redraw()


func _ensure_sheet() -> void:
	if _sheet_tried:
		return
	_sheet_tried = true
	var path := "res://assets/figuras/%s_sheet.png" % symbol
	if ResourceLoader.exists(path):
		_sheet = load(path)
		var meta_path := "res://assets/figuras/%s.json" % symbol
		if ResourceLoader.exists(meta_path):
			var f := FileAccess.open(meta_path, FileAccess.READ)
			if f:
				var parsed: Variant = JSON.parse_string(f.get_as_text())
				f.close()
				if typeof(parsed) == TYPE_DICTIONARY:
					_sheet_frames = int(parsed.get("frames", 1))
					_sheet_fps = float(parsed.get("fps", 10.0))
		if _sheet_frames < 1:
			_sheet_frames = 1
		if _sheet_fps <= 0.0:
			_sheet_fps = 10.0


func _ensure_texture() -> void:
	if _texture_tried:
		return
	_texture_tried = true
	if _sheet != null:
		return
	var path := "res://assets/figuras/%s.png" % symbol
	if ResourceLoader.exists(path):
		_texture = load(path)


func _draw() -> void:
	if symbol == "":
		return
	var r := minf(size.x, size.y) * 0.46
	var center := size * 0.5
	var base := StyleFactory.color_for(symbol)

	if draw_background:
		draw_style_box(StyleFactory.organic_panel(base, int(r * 0.85)),
				Rect2(center - Vector2(r, r), Vector2(r * 2.0, r * 2.0)))
		draw_circle(center + Vector2(-r * 0.30, -r * 0.34), r * 0.30, Color(1, 1, 1, 0.26))

	_ensure_sheet()
	_ensure_texture()
	if _sheet != null:
		var frame_w := _sheet.get_size().x / float(_sheet_frames)
		var frame_h := _sheet.get_size().y
		var frame_index := int(_time * _sheet_fps) % _sheet_frames
		var atlas := AtlasTexture.new()
		atlas.atlas = _sheet
		atlas.region = Rect2(Vector2(frame_w * frame_index, 0), Vector2(frame_w, frame_h))
		var max_dim := r * 1.7
		var scale := minf(max_dim / frame_w, max_dim / frame_h)
		var draw_size := Vector2(frame_w, frame_h) * scale
		draw_texture_rect(atlas, Rect2(center - draw_size * 0.5, draw_size), false)
		return

	if _texture != null:
		var tex_size := _texture.get_size()
		var max_dim := r * 1.7
		var scale := minf(max_dim / tex_size.x, max_dim / tex_size.y)
		var draw_size := tex_size * scale
		draw_texture_rect(_texture, Rect2(center - draw_size * 0.5, draw_size), false)
		return

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
