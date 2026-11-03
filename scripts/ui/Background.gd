class_name Background
extends Control
## Fundo totalmente animado e colorido: gradiente vivo + formas orgánicas
## em movimento (bolhas, blobs, estrelas, anéis, confetes, círculos).
## Paleta arco-íris vibrante — nunca usa branco/preto/cinza como fundo.

const PALETTE: Array[Color] = [
	Color("ffd93d"), # amarelo-sol
	Color("7c5cff"), # violeta
	Color("ff6b6b"), # coral
	Color("6bcb77"), # verde-lima
	Color("4d96ff"), # azul
	Color("ff8fab"), # rosa
	Color("2ec4b6"), # turquesa
	Color("ff9f1c"), # laranja
	Color("b983ff"), # lilás
	Color("ff5da2"), # pink
	Color("00d9c0"), # verde-água brilhante
	Color("ffe24d"), # amarelo-brilho
]

const BANDS := 48
var _time := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	# Gradiente vertical vivo (roxo → rosa → laranja no meio, via 3 paradas).
	for i in BANDS:
		var t := float(i) / float(BANDS)
		var c: Color
		if t < 0.48:
			c = Color("5b2a86").lerp(Color("8a2be2"), t / 0.48)
		elif t < 0.78:
			c = Color("8a2be2").lerp(Color("ff8fab"), (t - 0.48) / 0.30)
		else:
			c = Color("ff8fab").lerp(Color("ff9f1c"), (t - 0.78) / 0.22)
		draw_rect(Rect2(0.0, h * t, w, h / BANDS + 2.0), c)

	# Bolhas grandes lentas com brilho aninhado.
	_draw_giant_blob(Vector2(w * 0.16, h * 0.12 + sin(_time * 0.8) * 34.0), w * 0.30, Color("ffd93d", 0.18))
	_draw_giant_blob(Vector2(w * 0.94, h * 0.28 + cos(_time * 0.6) * 30.0), w * 0.24, Color("7c5cff", 0.20))
	_draw_giant_blob(Vector2(w * 0.06, h * 0.80 + sin(_time * 0.7 + 1.3) * 38.0), w * 0.32, Color("ff6b6b", 0.18))
	_draw_giant_blob(Vector2(w * 0.82, h * 0.94 + cos(_time * 0.9) * 24.0), w * 0.20, Color("6bcb77", 0.18))
	_draw_giant_blob(Vector2(w * 0.55, h * 0.45 + sin(_time * 0.5) * 44.0), w * 0.15, Color("ff8fab", 0.16))
	_draw_giant_blob(Vector2(w * 0.30, h * 0.65 + cos(_time * 0.75 + 2.0) * 30.0), w * 0.12, Color("2ec4b6", 0.16))
	_draw_giant_blob(Vector2(w * 0.70, h * 0.08 + sin(_time * 1.1 + 0.6) * 20.0), w * 0.10, Color("ff9f1c", 0.16))

	# Círculos sólidos flutuantes (tamanhos variados) subindo/deslizando.
	for i in 7:
		var col := PALETTE[i % PALETTE.size()]
		var speed := 14.0 + float(i) * 7.0
		var y := fmod(h * 0.15 + float(i) * h * 0.11 - _time * speed, h * 1.3) - h * 0.15
		var x := w * (0.08 + 0.14 * float((i * 3 + 1) % 7)) + sin(_time * (0.5 + float(i) * 0.1) + float(i) * 1.7) * 26.0
		var r := 10.0 + float((i * 17) % 3) * 8.0
		_draw_bubble(Vector2(x, y), r, Color(col, 0.28 + 0.08 * sin(_time * 2.0 + float(i))))

	# Anéis (donuts) coloridos, pulsando e girando.
	for i in 5:
		var col := PALETTE[(i + 4) % PALETTE.size()]
		var cx := w * (0.12 + 0.19 * float(i)) + cos(_time * (0.4 + float(i) * 0.07) + float(i) * 2.1) * 22.0
		var cy := h * (0.18 + 0.18 * float((i * 2 + 1) % 5)) + sin(_time * (0.55 + float(i) * 0.09) + float(i)) * 20.0
		var rr := 22.0 + 10.0 * sin(_time * 1.3 + float(i) * 1.4)
		if rr > 6.0:
			draw_arc(Vector2(cx, cy), rr, 0.0, TAU, 48, Color(col, 0.55), 6.0, true)
			draw_arc(Vector2(cx, cy), rr * 0.55, 0.0, TAU, 36, Color(col, 0.30), 4.0, true)

	# Estrelinhas de 4 pontas cintilando.
	for i in 9:
		var col := PALETTE[(i + 2) % PALETTE.size()]
		var tw := 0.5 + 0.5 * sin(_time * (2.0 + float(i) * 0.35) + float(i) * 2.4)
		var cx := w * (0.07 + 0.11 * float((i * 5 + 2) % 9))
		var cy := h * (0.10 + 0.09 * float((i * 7 + 3) % 10))
		var s := (10.0 + 9.0 * tw) * (0.7 + 0.3 * sin(_time * 1.5 + float(i)))
		_draw_sparkle(Vector2(cx, cy), s, Color(col, 0.25 + 0.55 * tw))

	# Confetes retangulares caindo e girando.
	for i in 10:
		var col := PALETTE[(i + 6) % PALETTE.size()]
		var fall := fmod(_time * (34.0 + float(i) * 5.0) + float(i) * 140.0, h + 80.0) - 40.0
		var sway := sin(_time * 1.2 + float(i) * 1.9) * 22.0
		var cx := w * (0.06 + 0.09 * float((i * 3 + 1) % 10)) + sway
		var ang := _time * (1.2 + float(i) * 0.15) + float(i)
		var len := 16.0 + float(i % 3) * 6.0
		var wid := 6.0
		var rect := Rect2(-len * 0.5, -wid * 0.5, len, wid)
		var xform := Transform2D(ang, Vector2(cx, fall))
		draw_set_transform_matrix(xform)
		draw_rect(rect, Color(col, 0.50))
		draw_set_transform_matrix(Transform2D.IDENTITY)

	# Vignette colorida nas bordas (sombra violeta, nunca preta).
	var steps := 5
	for s in steps:
		var t := float(s) / float(steps)
		var inset := t * 90.0
		var a := (1.0 - t) * 0.10
		draw_rect(Rect2(inset, inset, w - inset * 2.0, h - inset * 2.0), Color("2a0f4a", a))


## Blob gigante = preenche o squircle + núcleo mais opaco + brilho superior.
func _draw_giant_blob(center: Vector2, radius: float, color: Color) -> void:
	var r := maxf(radius, 20.0)
	_draw_squircle(center, r, color)
	_draw_squircle(center, r * 0.62, Color(color, minf(color.a + 0.10, 0.4)))
	draw_circle(center + Vector2(-r * 0.28, -r * 0.30), r * 0.28, Color(1, 1, 1, 0.16))


func _draw_blob(center: Vector2, radius: float, color: Color) -> void:
	_draw_squircle(center, radius, color)


func _draw_squircle(center: Vector2, radius: float, color: Color) -> void:
	var n := 3.0
	var pts := PackedVector2Array()
	var count := 36
	for i in count:
		var a := TAU * float(i) / float(count) - PI / 2.0
		var c := cos(a)
		var s := sin(a)
		var x := signf(c) * pow(absf(c), 2.0 / n) * radius
		var y := signf(s) * pow(absf(s), 2.0 / n) * radius
		pts.append(center + Vector2(x, y))
	draw_colored_polygon(pts, color)


func _draw_bubble(center: Vector2, r: float, color: Color) -> void:
	draw_circle(center, r, color)
	draw_circle(center + Vector2(-r * 0.3, -r * 0.3), r * 0.34, Color(1, 1, 1, 0.35))


func _draw_sparkle(center: Vector2, s: float, color: Color) -> void:
	var pts := PackedVector2Array()
	var n := 8
	for i in n:
		var a := TAU * float(i) / float(n) - PI * 0.5
		var rad := s if i % 2 == 0 else s * 0.28
		pts.append(center + Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, color)
