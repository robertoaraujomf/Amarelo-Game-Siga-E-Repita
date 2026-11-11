class_name LevelTrail
extends Control
## Trilha ilustrativa e ludica de fases: um caminho serpenteante com "nos"
## clicaveis, em vez de uma lista vertical.

signal selected(level_id: int)

const NODE_R := 46.0
const TOP_PAD := 80.0
const SPACING := 160.0
const DESIGN_W := 660.0
const TRAIL_STEP := 135.0
const TRAIL_MIN_NODE_DIST := 118.0
# Direção de cada trecho entre fases consecutivas (1..34).
const TRAIL_PHASE_DIRS := [
	4, 5, 3, 2, 3, 3,
	2, 3, 2, 1, 8, 7, 7, 8, 2, 3, 3, 2, 2, 2, 3, 4, 5, 5, 5, 5, 5, 4, 5, 4, 5, 6, 5,
]
# Ordem das 8 direções (1..8) conforme convenção:
# 1 N, 2 NE, 3 E, 4 SE, 5 S, 6 SW, 7 W, 8 NW.
const TRAIL_DIRS := [
	Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1),
	Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1),
]

var _entries: Array = []
var _time := 0.0

# Pan manual da trilha (mesma logica dos mapas).
var _panning := false
var _pan_touch_index := -1
var _pan_start_pointer := Vector2.ZERO
var _pan_start_scroll_v := 0
var _pan_start_scroll_h := 0


func build(levels: Array, progress: Node) -> void:
	_entries.clear()
	for c in get_children():
		c.queue_free()

	var n := levels.size()
	var positions := _generate_trail_positions(n)
	for i in n:
		var id := int(levels[i].get("id", i + 1))
		var pos: Vector2 = positions[i] if i < positions.size() else Vector2(DESIGN_W * 0.5, TOP_PAD + float(i) * SPACING)
		var status := "open"
		if progress != null:
			status = progress.level_status(id)
		_entries.append({"id": id, "status": status, "pos": pos})

		var btn := Button.new()
		btn.flat = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.size = Vector2(NODE_R * 2.2, NODE_R * 2.2)
		btn.position = pos - btn.size * 0.5
		# A fase atual e a unica que pode ser jogada agora; anteriores nao voltam.
		btn.disabled = status != "current"
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			btn.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		var lid := id
		btn.pressed.connect(func() -> void: selected.emit(lid))
		add_child(btn)

	var max_y := TOP_PAD
	var max_x := 40.0
	for pos in positions:
		max_y = maxf(max_y, pos.y)
		max_x = maxf(max_x, pos.x)
	max_y = maxf(max_y, TOP_PAD + float(n - 1) * SPACING)
	var trail_w := maxf(DESIGN_W, max_x + 80.0)
	custom_minimum_size = Vector2(trail_w, max_y + TOP_PAD * 1.5)
	queue_redraw()



func _generate_trail_positions(n: int) -> Array[Vector2]:
	var pts: Array[Vector2] = []
	if n <= 0:
		return pts
	var cur := Vector2(40.0, TOP_PAD)
	pts.append(cur)
	var segments: Array = []
	var min_x := 40.0
	var y_min := TOP_PAD - 2000.0
	var y_max := TOP_PAD + float(n + 8) * SPACING
	for i in range(1, n):
		var dir_num := 4
		if i - 1 < TRAIL_PHASE_DIRS.size():
			dir_num = TRAIL_PHASE_DIRS[i - 1]
		var dir: Vector2 = TRAIL_DIRS[dir_num - 1]
		var placed := false
		# Linha entre fases com comprimento dobrado.
		for length in [2, 3, 1]:
			var cand := cur + dir * (float(length) * TRAIL_STEP)
			if cand.x < min_x:
				cand.x = min_x
			if cand.y < y_min:
				cand.y = y_min
			if cand.y > y_max:
				cand.y = y_max
			if cand.distance_to(cur) < TRAIL_MIN_NODE_DIST:
				continue
			var ok := true
			for p in pts:
				if p.distance_to(cand) < TRAIL_MIN_NODE_DIST:
					ok = false
					break
			if not ok:
				continue
			var seg_ok := true
			for seg in segments:
				if _segments_intersect(cur, cand, seg["a"], seg["b"]):
					seg_ok = false
					break
			if not seg_ok:
				continue
			segments.append({"a": cur, "b": cand})
			pts.append(cand)
			cur = cand
			placed = true
			break
		if not placed:
			var cand := cur + dir * (2.0 * TRAIL_STEP)
			if cand.x < min_x:
				cand.x = min_x
			if cand.y < y_min:
				cand.y = y_min
			if cand.y > y_max:
				cand.y = y_max
			segments.append({"a": cur, "b": cand})
			pts.append(cand)
			cur = cand
	# Garante que nada fique acima da area visivel inicial (desloca se preciso).
	var min_y := INF
	for p in pts:
		min_y = minf(min_y, p.y)
	if min_y < TOP_PAD:
		var shift := TOP_PAD - min_y
		for i in pts.size():
			pts[i].y += shift
	# Mantem as posicoes (nao distorce a trilha); a altura minima para rolagem
	# e garantida no custom_minimum_size em build().
	return pts


func _segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1 := _cross(p3, p4, p1)
	var d2 := _cross(p3, p4, p2)
	var d3 := _cross(p1, p2, p3)
	var d4 := _cross(p1, p2, p4)
	if ((d1 > 0.0 and d2 < 0.0) or (d1 < 0.0 and d2 > 0.0)) and ((d3 > 0.0 and d4 < 0.0) or (d3 < 0.0 and d4 > 0.0)):
		return true
	return false


func _cross(a: Vector2, b: Vector2, c: Vector2) -> float:
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)


## Indica se a posição de tela (em coordenadas globais) cai fora de qualquer nó
## da trilha (area vazia), para permitir o pan manual (como nos mapas).
func is_empty_at(screen_pos: Vector2) -> bool:
	var local: Vector2 = screen_pos - global_position
	for e in _entries:
		if local.distance_to(e["pos"]) <= NODE_R * 1.35:
			return false
	return true


## Posição (no espaço de conteúdo da trilha) do nó da fase informada.
func node_pos(level_id: int) -> Vector2:
	for e in _entries:
		if int(e["id"]) == level_id:
			return e["pos"]
	if not _entries.is_empty():
		return _entries[0]["pos"]
	return Vector2.ZERO


func _is_empty_local(pos: Vector2) -> bool:
	for e in _entries:
		if pos.distance_to(e["pos"]) <= NODE_R * 1.35:
			return false
	return true


func _input(event: InputEvent) -> void:
	var sc := get_parent() as ScrollContainer
	if sc == null:
		return
	var local: Vector2 = event.position - global_position if event is InputEventWithModifiers else Vector2.ZERO
	# event.position para mouse/touch e em coordenadas de viewport; converte.
	if event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventScreenTouch or event is InputEventScreenDrag:
		local = event.position - global_position
	if not _panning:
		# Fora da area da trilha: ignora (exceto quando ja arrastando).
		if local.x < 0.0 or local.y < 0.0 or local.x > size.x or local.y > size.y:
			return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _is_empty_local(local):
					_panning = true
					_pan_touch_index = -1000
					_pan_start_pointer = local
					_pan_start_scroll_v = sc.scroll_vertical
					_pan_start_scroll_h = sc.scroll_horizontal
					accept_event()
			else:
				if _panning and _pan_touch_index == -1000:
					_panning = false
					_pan_touch_index = -1
	elif event is InputEventScreenTouch:
		if event.pressed:
			if _is_empty_local(local):
				_panning = true
				_pan_touch_index = event.index
				_pan_start_pointer = local
				_pan_start_scroll_v = sc.scroll_vertical
				_pan_start_scroll_h = sc.scroll_horizontal
				accept_event()
		else:
			if _panning and event.index == _pan_touch_index:
				_panning = false
				_pan_touch_index = -1
	elif event is InputEventScreenDrag:
		if _panning and event.index == _pan_touch_index:
			_update_pan(sc, local)
			accept_event()
	elif event is InputEventMouseMotion:
		if _panning and _pan_touch_index == -1000:
			_update_pan(sc, local)
			accept_event()


func _update_pan(sc: ScrollContainer, pos: Vector2) -> void:
	if not _panning:
		return
	var delta := pos - _pan_start_pointer
	sc.scroll_vertical = int(_pan_start_scroll_v - delta.y)
	sc.scroll_horizontal = int(_pan_start_scroll_h - delta.x)


func _process(delta: float) -> void:
	_time += delta
	if not _entries.is_empty():
		queue_redraw()


func _trail_path() -> PackedVector2Array:
	var pts := PackedVector2Array()
	if _entries.size() < 2:
		return pts
	pts.append(_entries[0]["pos"])
	for i in _entries.size() - 1:
		var p0: Vector2 = _entries[i]["pos"]
		var p1: Vector2 = _entries[i + 1]["pos"]
		var mid := (p0 + p1) / 2.0
		var d := p1 - p0
		var perp := Vector2(-d.y, d.x)
		if perp.length() < 0.001:
			perp = Vector2(0, -1)
		var wobble := 20.0 + 12.0 * sin(float(i) * 2.3) + 8.0 * cos(float(i) * 1.9)
		var c := mid + perp.normalized() * wobble
		for s in range(11):
			var t := float(s) / 10.0
			var mt := 1.0 - t
			pts.append(mt * mt * p0 + 2.0 * mt * t * c + t * t * p1)
	return pts


func _draw() -> void:
	# Caminho serpenteante
	if _entries.size() >= 2:
		var pts := _trail_path()
		draw_polyline(pts, Color(StyleFactory.TRAIL, 0.5), 22.0, true)
		for e in _entries:
			draw_circle(e["pos"], 11.0, Color(StyleFactory.TRAIL, 0.5))

	for e in _entries:
		_draw_node(e)


func _draw_node(e: Dictionary) -> void:
	var pos: Vector2 = e["pos"]
	var status: String = e["status"]

	var col := Color("4d96ff")
	match status:
		"completed":
			col = Color("6bcb77")
		"current":
			col = Color("ffb14d")
		"locked":
			col = Color("8a6fbf")
		_:
			col = Color("4d96ff")

	var r := NODE_R + sin(float(e["id"]) * 1.7) * 9.0
	var glow := Color("4d96ff")
	var glow_a := 0.0
	match status:
		"completed":
			glow = Color("6bcb77")
			glow_a = 0.42
		"current":
			glow = Color("ffb14d")
			glow_a = 0.55
		"locked":
			glow = Color("8a6fbf")
			glow_a = 0.18
		_:
			glow = Color("4d96ff")
			glow_a = 0.0
	# Brilho colorido + sombra suave por baixo do globo da fase.
	draw_circle(pos + Vector2(0, 10.0), r * 1.30, Color(glow, glow_a))
	draw_circle(pos + Vector2(0, 10.0), r * 1.22, Color("2a0f4a", 0.30))
	draw_circle(pos, r, col)
	draw_circle(pos + Vector2(-r * 0.28, -r * 0.30), r * 0.34, Color(1, 1, 1, 0.25))

	if status == "current":
		var pulse := 0.5 + 0.5 * sin(_time * 5.0)
		draw_arc(pos, r * (1.05 + 0.14 * pulse), 0.0, TAU, 56, Color(StyleFactory.HIGHLIGHT, glow_a * (0.35 + 0.65 * pulse)), 8.0, true)
	elif status == "completed":
		draw_arc(pos, r * 1.16, 0.0, TAU, 56, Color("b8ffb0", glow_a), 6.0, true)

	# Numero da fase
	var font := ThemeDB.fallback_font
	var txt := str(e["id"])
	var fs := 42
	var sz := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	draw_string(font, pos + Vector2(-sz.x * 0.5, fs * 0.36), txt,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)

	# Roda de status (ludica, sem perfeicao).
	var label := ""
	var lcol := Color.WHITE
	match status:
		"completed":
			label = "Concluída"
			lcol = Color("b8ffb0")
		"current":
			label = "Próxima"
			lcol = Color(StyleFactory.HIGHLIGHT)
		"locked":
			label = "Bloqueada"
			lcol = Color("cbb4ff")
	if not label.is_empty():
		var lfs := 20.0
		var lsz := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, lfs)
		draw_string(font, pos + Vector2(-lsz.x * 0.5, r + 34.0 + lfs * 0.36), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, lfs, lcol)

	if status == "locked":
		_draw_lock(pos)


func _draw_lock(pos: Vector2) -> void:
	var body := Rect2(pos.x - 14.0, pos.y + 6.0, 28.0, 22.0)
	draw_rect(body, Color(1, 1, 1, 0.95))
	draw_arc(pos + Vector2(0, 6), 10.0, PI, TAU, 22, Color(1, 1, 1, 0.95), 5.0, true)
