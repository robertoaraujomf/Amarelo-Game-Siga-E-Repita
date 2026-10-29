class_name Background
extends Control
## Fundo gradiente colorido com "bolhas" organicas. Nunca usa branco/preto/cinza
## como fundo: apenas tons de roxo, rosa, laranja e amarelo.

const TOP := Color("5b2a86")
const BOTTOM := Color("ff8fab")
const BANDS := 96

var _time := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _process(_delta: float) -> void:
	_time += _delta
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	for i in BANDS:
		var t := float(i) / float(BANDS)
		var c := TOP.lerp(BOTTOM, t)
		draw_rect(Rect2(0.0, h * t, w, h / BANDS + 1.5), c)

	# Bolhas decorativas animadas, com brilho e cores vivas (nunca cinza/preto/branco).
	_draw_blob(Vector2(w * 0.16, h * 0.10 + sin(_time * 0.8) * 30.0), w * 0.30, Color("ffd93d", 0.16))
	_draw_blob(Vector2(w * 0.92, h * 0.30 + cos(_time * 0.6) * 26.0), w * 0.24, Color("7c5cff", 0.18))
	_draw_blob(Vector2(w * 0.08, h * 0.82 + sin(_time * 0.7 + 1.3) * 34.0), w * 0.34, Color("ff6b6b", 0.16))
	_draw_blob(Vector2(w * 0.80, h * 0.92 + cos(_time * 0.9) * 22.0), w * 0.20, Color("6bcb77", 0.16))
	_draw_blob(Vector2(w * 0.55, h * 0.45 + sin(_time * 0.5) * 40.0), w * 0.15, Color("ff8fab", 0.14))


func _draw_blob(center: Vector2, radius: float, color: Color) -> void:
	var n := 3.0
	var pts := PackedVector2Array()
	var count := 32
	for i in count:
		var a := TAU * float(i) / float(count) - PI / 2.0
		var c := cos(a)
		var s := sin(a)
		var x := signf(c) * pow(absf(c), 2.0 / n) * radius
		var y := signf(s) * pow(absf(s), 2.0 / n) * radius
		pts.append(center + Vector2(x, y))
	draw_colored_polygon(pts, color)
