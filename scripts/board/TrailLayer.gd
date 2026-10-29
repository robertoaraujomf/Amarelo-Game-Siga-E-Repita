class_name TrailLayer
extends Node2D
## Desenha a linha violeta do trajeto percorrido, por cima do tabuleiro.

var cell_size: float = 96.0
var cell_offset := Vector2.ZERO
var cells: Array[Vector2i] = []


func set_cells(new_cells: Array) -> void:
	cells.clear()
	for c in new_cells:
		cells.append(c)
	queue_redraw()


func _cell_center(p: Vector2i) -> Vector2:
	return cell_offset + Vector2(float(p.x), float(p.y)) * cell_size


func _draw() -> void:
	if cells.size() < 1:
		return
	var col := Color(StyleFactory.TRAIL, 0.55)

	if cells.size() >= 2:
		var pts := PackedVector2Array()
		for p in cells:
			pts.append(_cell_center(p))
		draw_polyline(pts, col, cell_size * 0.22, true)

	# Juntas arredondadas para a linha não ter cantos secos.
	for p in cells:
		draw_circle(_cell_center(p), cell_size * 0.11, col)
