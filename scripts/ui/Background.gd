class_name Background
extends Control
## Fundo gradiente colorido com "bolhas" orgânicas. Nunca usa branco/preto/cinza
## como fundo: apenas tons de roxo, rosa, laranja e amarelo.

const TOP := Color("5b2a86")
const BOTTOM := Color("ff8fab")
const BANDS := 96


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	for i in BANDS:
		var t := float(i) / float(BANDS)
		var c := TOP.lerp(BOTTOM, t)
		draw_rect(Rect2(0.0, h * t, w, h / BANDS + 1.5), c)

	# Bolhas decorativas (cores suaves, nunca cinza/preto/branco).
	draw_circle(Vector2(w * 0.16, h * 0.10), w * 0.30, Color("ffd93d", 0.14))
	draw_circle(Vector2(w * 0.92, h * 0.30), w * 0.24, Color("7c5cff", 0.18))
	draw_circle(Vector2(w * 0.08, h * 0.82), w * 0.34, Color("ff6b6b", 0.14))
	draw_circle(Vector2(w * 0.80, h * 0.92), w * 0.20, Color("6bcb77", 0.16))
