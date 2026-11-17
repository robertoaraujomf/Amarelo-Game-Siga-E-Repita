class_name Player
extends Node2D
## Personagem (blob fofo). A movimentação é tweenada pelo Board.

signal arrived

var cell_size: float = 96.0
var _bob: float = 0.0
var _pulse: float = 0.0


func _process(delta: float) -> void:
	_bob += delta
	_pulse += delta
	queue_redraw()


func animate_to(target: Vector2, duration: float) -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position", target, duration)
	tw.finished.connect(func() -> void: arrived.emit())


func _draw() -> void:
	var p := 0.5 + 0.5 * sin(_pulse * 3.2)
	var r := cell_size * (0.34 + 0.07 * p)

	# Sombra pulsante (violeta, nunca preta).
	var shadow_a := 0.22 + 0.18 * p
	var shadow_r := r * (0.86 + 0.16 * p)
	draw_circle(Vector2(0.0, r * 1.05), shadow_r, Color(StyleFactory.SHADOW, shadow_a))

	# Brilho externo (glow) pulsante em tamanho e intensidade.
	var glow_a := 0.18 + 0.32 * p
	var glow_r := r * (1.35 + 0.25 * p)
	draw_circle(Vector2.ZERO, glow_r, Color(StyleFactory.HIGHLIGHT, glow_a))

	# Anel colorido pulsante ao redor da figura.
	var ring_a := 0.35 + 0.55 * p
	draw_arc(Vector2.ZERO, r * (1.12 + 0.18 * p), 0.0, TAU, 56,
			Color(StyleFactory.HIGHLIGHT, ring_a), r * 0.14, true)

	# Corpo com cor pulsante.
	var body := Color("fff1c9").lerp(Color("ffe24d"), 0.35 * p)
	draw_circle(Vector2.ZERO, r, body)
	draw_circle(Vector2(-r * 0.3, -r * 0.3), r * 0.42, Color(1, 1, 1, 0.45 + 0.15 * p))

	# Olhos com leve "olhar" animado.
	var eye := Color("2b1a3d")
	var look := Vector2(0.0, sin(_bob * 2.0) * r * 0.05)
	draw_circle(Vector2(-r * 0.32, -r * 0.10) + look, r * 0.13, eye)
	draw_circle(Vector2(r * 0.32, -r * 0.10) + look, r * 0.13, eye)
	# Sorriso
	draw_arc(Vector2(0.0, r * 0.18), r * 0.34, deg_to_rad(20.0), deg_to_rad(160.0),
			16, eye, r * 0.10, true)
