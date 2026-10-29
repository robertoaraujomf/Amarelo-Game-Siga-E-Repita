class_name Player
extends Node2D
## Personagem (blob fofo). A movimentação é tweenada pelo Board.

signal arrived

var cell_size: float = 96.0
var _bob: float = 0.0


func _process(delta: float) -> void:
	_bob += delta
	queue_redraw()


func animate_to(target: Vector2, duration: float) -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position", target, duration)
	tw.finished.connect(func() -> void: arrived.emit())


func _draw() -> void:
	var r := cell_size * 0.34
	# Sombra (violeta, nunca preta)
	draw_circle(Vector2(0.0, r * 0.95), r * 0.8, StyleFactory.SHADOW)
	# Corpo
	draw_circle(Vector2.ZERO, r, Color("fff1c9"))
	draw_circle(Vector2(-r * 0.3, -r * 0.3), r * 0.4, Color(1, 1, 1, 0.4))
	# Olhos com leve "olhar" animado
	var eye := Color("2b1a3d")
	var look := Vector2(0.0, sin(_bob * 2.0) * r * 0.05)
	draw_circle(Vector2(-r * 0.32, -r * 0.10) + look, r * 0.12, eye)
	draw_circle(Vector2(r * 0.32, -r * 0.10) + look, r * 0.12, eye)
	# Sorriso
	draw_arc(Vector2(0.0, r * 0.18), r * 0.34, deg_to_rad(20.0), deg_to_rad(160.0),
			16, eye, r * 0.10, true)
