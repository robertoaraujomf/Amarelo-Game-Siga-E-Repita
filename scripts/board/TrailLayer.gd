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
		pts.append(_cell_center(cells[0]))
		for i in cells.size() - 1:
			var p0: Vector2 = _cell_center(cells[i])
			var p1: Vector2 = _cell_center(cells[i + 1])
			var mid := (p0 + p1) / 2.0
			var d := p1 - p0
			var perp := Vector2(-d.y, d.x)
			if perp.length() < 0.001:
				perp = Vector2(0, -1)
			var wobble := 16.0 + 10.0 * sin(float(i) * 2.3) + 7.0 * cos(float(i) * 1.7)
			var c := mid + perp.normalized() * wobble
			for s in range(12):
				var t := float(s) / 12.0
				var mt := 1.0 - t
				pts.append(mt * mt * p0 + 2.0 * mt * t * c + t * t * p1)
		draw_polyline(pts, col, cell_size * 0.11, true)

	# Juntas arredondadas para a linha não ter cantos secos.
	for p in cells:
		draw_circle(_cell_center(p), cell_size * 0.055, col)
