class_name LevelTrail
extends Control
## Trilha ilustrativa e ludica de fases: um caminho serpenteante com "nos"
## clicaveis, em vez de uma lista vertical.

signal selected(level_id: int)

const NODE_R := 46.0
const TOP_PAD := 80.0
const SPACING := 160.0
const DESIGN_W := 660.0

var _entries: Array = []
var _time := 0.0


func build(levels: Array, progress: Node) -> void:
	_entries.clear()
	for c in get_children():
		c.queue_free()

	var n := levels.size()
	for i in n:
		var id := int(levels[i].get("id", i + 1))
		var t := float(i)
		var pos := Vector2(
			DESIGN_W * 0.5 + sin(t * 1.5) * DESIGN_W * 0.26,
			TOP_PAD + t * SPACING)
		var status := "open"
		if progress != null:
			status = progress.level_status(id)
		_entries.append({"id": id, "status": status, "pos": pos})

		var btn := Button.new()
		btn.flat = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.size = Vector2(NODE_R * 2.2, NODE_R * 2.2)
		btn.position = pos - btn.size * 0.5
		btn.disabled = status == "locked"
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			btn.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		var lid := id
		btn.pressed.connect(func() -> void: selected.emit(lid))
		add_child(btn)

	custom_minimum_size = Vector2(DESIGN_W, TOP_PAD * 2.0 + maxf(0.0, float(n - 1)) * SPACING)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if not _entries.is_empty():
		queue_redraw()


func _draw() -> void:
	# Caminho serpenteante
	if _entries.size() >= 2:
		var pts := PackedVector2Array()
		for e in _entries:
			pts.append(e["pos"])
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

	draw_circle(pos, NODE_R, col)
	draw_circle(pos + Vector2(-NODE_R * 0.28, -NODE_R * 0.30), NODE_R * 0.34,
			Color(1, 1, 1, 0.25))

	if status == "current":
		var pulse := 0.5 + 0.5 * sin(_time * 5.0)
		for i in 3:
			var a := 0.55 * (1.0 - float(i) / 3.0) * (0.5 + 0.5 * pulse)
			draw_arc(pos, NODE_R * (1.06 + float(i) * 0.10), 0.0, TAU, 56,
					Color(StyleFactory.HIGHLIGHT, a), 8.0, true)
	elif status == "completed":
		draw_arc(pos, NODE_R * 1.08, 0.0, TAU, 56, Color("b8ffb0", 0.8), 6.0, true)

	# Numero da fase
	var font := ThemeDB.fallback_font
	var txt := str(e["id"])
	var fs := 42
	var sz := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	draw_string(font, pos + Vector2(-sz.x * 0.5, fs * 0.36), txt,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)

	if status == "locked":
		_draw_lock(pos)


func _draw_lock(pos: Vector2) -> void:
	var body := Rect2(pos.x - 14.0, pos.y + 6.0, 28.0, 22.0)
	draw_rect(body, Color(1, 1, 1, 0.95))
	draw_arc(pos + Vector2(0, 6), 10.0, PI, TAU, 22, Color(1, 1, 1, 0.95), 5.0, true)
