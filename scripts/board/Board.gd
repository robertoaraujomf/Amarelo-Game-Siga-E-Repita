class_name Board
extends Node2D
## Monta o grid a partir da matriz da fase, interpreta os controles,
## valida movimentos, desenha o trajeto e comanda a camera suave.

signal state_changed
signal sequence_changed
signal blocked
signal won

const MOVE_DURATION := 0.16
const SWIPE_MIN_DISTANCE := 36.0
const CAMERA_SPEED := 7.0
const BOARD_PADDING := 26.0

var matrix: LevelMatrix
var rules: PuzzleRules
var tiles: Dictionary = {}          # Vector2i -> Tile
var player: Player
var trail: TrailLayer
var camera: Camera2D

var cell_size: float = 96.0
var board_size := Vector2.ZERO
var player_cell := Vector2i.ZERO

## Pixels reservados pela HUD no topo/rodape; a camera mantem o jogador
## dentro da faixa visivel entre essas margens.
var view_top: float = 0.0
var view_bottom: float = 0.0

var _cell_offset := Vector2.ZERO
var _level: Dictionary = {}
var _trail_cells: Array[Vector2i] = []
var _is_moving := false
var _pending_win := false
var _swipe_start := Vector2.ZERO
var _swipe_active := false
var _history: Array = []            # snapshots para "desfazer"


# ---------------------------------------------------------------- construcao
func load_level(level: Dictionary) -> void:
	_level = level
	_clear()

	matrix = LevelMatrix.new(level.get("matrix", []))
	rules = PuzzleRules.new(matrix, level.get("sequences", []))

	_compute_layout()
	_build_tiles()
	_build_trail()
	_build_player()
	_build_camera()

	player_cell = matrix.start_pos
	_trail_cells = [player_cell]
	if trail:
		trail.set_cells(_trail_cells)
	_refresh_visuals()
	_snap_camera()
	queue_redraw()

	state_changed.emit()
	sequence_changed.emit()


func _clear() -> void:
	for child in get_children():
		child.queue_free()
	tiles.clear()
	player = null
	trail = null
	camera = null
	_is_moving = false
	_pending_win = false
	_history.clear()


func _compute_layout() -> void:
	var cols: int = maxi(matrix.cols, 1)
	var rows: int = maxi(matrix.rows, 1)
	var max_w := 660.0
	var max_h := 820.0
	cell_size = clampf(min(max_w / float(cols), max_h / float(rows)), 44.0, 150.0)
	board_size = Vector2(float(cols), float(rows)) * cell_size
	_cell_offset = -board_size * 0.5 + Vector2(cell_size, cell_size) * 0.5


func _cell_center(p: Vector2i) -> Vector2:
	return _cell_offset + Vector2(float(p.x), float(p.y)) * cell_size


func _build_tiles() -> void:
	for pos in matrix.all_positions():
		var sym := matrix.symbol_at(pos)
		if LevelMatrix.is_empty(sym):
			continue
		var tile := Tile.new()
		tile.symbol = sym
		tile.cell_size = cell_size
		tile.position = _cell_center(pos)
		add_child(tile)
		tiles[pos] = tile


func _build_trail() -> void:
	trail = TrailLayer.new()
	trail.cell_size = cell_size
	trail.cell_offset = _cell_offset
	add_child(trail)


func _build_player() -> void:
	player = Player.new()
	player.cell_size = cell_size
	player.position = _cell_center(matrix.start_pos)
	player.arrived.connect(_on_player_arrived)
	add_child(player)


func _build_camera() -> void:
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = CAMERA_SPEED
	camera.ignore_rotation = true
	add_child(camera)
	camera.make_current()


# ------------------------------------------------------------------ camera
func _process(_delta: float) -> void:
	if camera == null or player == null:
		return
	camera.position = _camera_target()


## Segue o jogador suavemente, sem deformar proporcao, respeitando as margens
## da HUD. Se o tabuleiro couber na faixa visivel ele fica centralizado; se for
## maior, a camera rola mantendo o jogador sempre dentro da faixa livre.
func _camera_target() -> Vector2:
	var vp := get_viewport_rect().size / camera.zoom
	var half_view := vp * 0.5
	var half_board := board_size * 0.5 + Vector2(BOARD_PADDING, BOARD_PADDING)

	# Centro que deixa o jogador no meio da faixa visivel (entre as margens).
	var desired := Vector2(
		player.position.x,
		player.position.y - (view_top - view_bottom) * 0.5
	)

	return Vector2(
		_clamp_camera_axis(desired.x, half_view.x, half_board.x, 0.0, 0.0),
		_clamp_camera_axis(desired.y, half_view.y, half_board.y, view_top, view_bottom)
	)


## Restringe o centro da camera para que a faixa visivel nunca passe das bordas
## do tabuleiro. `lo`/`hi` sao as margens da HUD nas extremidades do eixo; quando
## o tabuleiro cabe na faixa, o resultado e o centro fixo.
func _clamp_camera_axis(desired: float, half_view: float, half_board: float, lo: float, hi: float) -> float:
	var min_c := -half_board + half_view - lo
	var max_c := half_board - half_view + hi
	if min_c <= max_c:
		return clampf(desired, min_c, max_c)
	return (min_c + max_c) * 0.5


func _snap_camera() -> void:
	if camera == null:
		return
	camera.reset_smoothing()
	camera.position = _camera_target()


## Recentraliza a camera imediatamente (usado quando as margens da HUD ficam
## conhecidas, para evitar um deslize inicial).
func refresh_camera() -> void:
	_snap_camera()


# ------------------------------------------------------------------- input
func _unhandled_input(event: InputEvent) -> void:
	if matrix == null or _is_moving:
		return

	if event.is_action_pressed("move_up"):
		try_move(Vector2i(0, -1)); return
	if event.is_action_pressed("move_down"):
		try_move(Vector2i(0, 1)); return
	if event.is_action_pressed("move_left"):
		try_move(Vector2i(-1, 0)); return
	if event.is_action_pressed("move_right"):
		try_move(Vector2i(1, 0)); return

	if event is InputEventScreenTouch:
		if event.pressed:
			_swipe_start = event.position
			_swipe_active = true
		elif _swipe_active:
			_swipe_active = false
			_resolve_swipe(event.position - _swipe_start)
	elif event is InputEventScreenDrag and _swipe_active:
		var d: Vector2 = event.position - _swipe_start
		if d.length() >= SWIPE_MIN_DISTANCE:
			_swipe_active = false
			_resolve_swipe(d)


func _resolve_swipe(delta: Vector2) -> void:
	if delta.length() < SWIPE_MIN_DISTANCE:
		return
	if absf(delta.x) >= absf(delta.y):
		try_move(Vector2i(int(signf(delta.x)), 0))
	else:
		try_move(Vector2i(0, int(signf(delta.y))))


# --------------------------------------------------------------- movimento
func try_move(dir: Vector2i) -> void:
	if _is_moving or matrix == null or dir == Vector2i.ZERO:
		return
	var target := player_cell + dir
	if not matrix.is_inside(target) or not rules.can_move(player_cell, target):
		_emit_blocked()
		return

	_history.append(_snapshot())
	player_cell = target
	rules.register_arrival(target)
	_trail_cells.append(target)
	if trail:
		trail.set_cells(_trail_cells)

	_is_moving = true
	_pending_win = rules.is_won(target)
	_refresh_visuals()
	sequence_changed.emit()
	player.animate_to(_cell_center(target), MOVE_DURATION)


func _on_player_arrived() -> void:
	_is_moving = false
	if _pending_win:
		_pending_win = false
		won.emit()


func _emit_blocked() -> void:
	if Settings.haptics_enabled:
		Input.vibrate_handheld(40)
	blocked.emit()


# ---------------------------------------------------------- desfazer/reiniciar
func _snapshot() -> Dictionary:
	return {
		"cell": player_cell,
		"active": rules.active_sequence,
		"step": rules.step,
		"visited": rules.visited.duplicate(),
		"trail_size": _trail_cells.size(),
	}


func can_undo() -> bool:
	return not _history.is_empty()


## Desfaz o ultimo movimento, restaurando posicao, sequencia e visitas.
func undo_move() -> void:
	if _is_moving or _history.is_empty() or matrix == null:
		return
	var s: Dictionary = _history.pop_back()

	player_cell = s["cell"]
	rules.active_sequence = int(s["active"])
	rules.step = int(s["step"])
	rules.visited = s["visited"]

	var kept: Array[Vector2i] = []
	var n: int = int(s["trail_size"])
	for i in n:
		kept.append(_trail_cells[i])
	_trail_cells = kept
	if trail:
		trail.set_cells(_trail_cells)

	player.position = _cell_center(player_cell)
	_refresh_visuals()
	state_changed.emit()
	sequence_changed.emit()


## Reinicia a fase atual do zero.
func restart() -> void:
	if _level.is_empty():
		return
	load_level(_level)


# ------------------------------------------------------------------ estado
func _refresh_visuals() -> void:
	var next_sym := rules.next_symbol()
	for pos in tiles.keys():
		var tile: Tile = tiles[pos]
		tile.visited = rules.visited.has(pos)
		tile.is_player = pos == player_cell
		tile.is_next = tile.symbol == next_sym
		tile.queue_redraw()


## Proxima posicao especial (E) ainda nao visitada, ou (-1,-1) se nao houver.
func get_next_special() -> Vector2i:
	if rules == null or matrix.special_positions.is_empty():
		return Vector2i(-1, -1)
	var best := Vector2i(-1, -1)
	var best_d := INF
	for pos in matrix.special_positions:
		if rules.visited.has(pos):
			continue
		var d := Vector2(pos - player_cell).length()
		if d < best_d:
			best_d = d
			best = pos
	return best


func current_sequence() -> Array:
	return rules.current_sequence()


func current_step() -> int:
	return rules.step


# ------------------------------------------------------------------- draw
func _draw() -> void:
	if matrix == null:
		return
	# Painel de fundo do tabuleiro (arredondado).
	var pad := BOARD_PADDING
	var rect := Rect2(-board_size * 0.5 - Vector2(pad, pad),
			board_size + Vector2(pad, pad) * 2.0)
	draw_style_box(StyleFactory.rounded_panel(StyleFactory.CARD, 60), rect)

	# Marcas sutis nas posicoes vazias (amarelo suave, nunca branco/cinza).
	for pos in matrix.all_positions():
		if LevelMatrix.is_empty(matrix.symbol_at(pos)):
			draw_circle(_cell_center(pos), cell_size * 0.05, Color("ffe24d", 0.14))
