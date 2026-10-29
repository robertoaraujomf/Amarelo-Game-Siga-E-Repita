extends Node2D
## Cena de jogo: liga o Board (tabuleiro) ao HUD e gerencia o fluxo da fase.

@onready var board: Board = $Board
@onready var hud: Hud = $HUD

var _level: Dictionary = {}
var _camera_ready := false


func _ready() -> void:
	# Não permite abrir uma fase fora de ordem (pular fases).
	if not GameState.is_completed(GameState.current_level_id) \
			and GameState.current_level_id != GameState.next_level_id():
		get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
		return

	_level = Levels.get_level_by_id(GameState.current_level_id)
	if _level.is_empty() and Levels.count() > 0:
		_level = Levels.get_level_by_index(0)
		GameState.current_level_id = int(_level.get("id", 1))

	if _level.is_empty():
		push_error("Nenhuma fase encontrada em res://levels")
		return

	hud.back_pressed.connect(_on_back)
	hud.dpad.connect(board.try_move)
	hud.next_level_pressed.connect(_on_next)
	hud.undo_pressed.connect(_on_undo)
	hud.restart_pressed.connect(_on_restart)

	board.state_changed.connect(_refresh_hud)
	board.sequence_changed.connect(_refresh_hud)
	board.blocked.connect(hud.pop_blocked)
	board.won.connect(_on_won)

	board.load_level(_level)

	var idx := Levels.index_of_id(int(_level.get("id", 1)))
	hud.set_level_info(idx + 1, Levels.count())
	hud.set_control_mode(Settings.control_mode)
	_sync_view_margins()
	_refresh_hud()


func _process(_delta: float) -> void:
	_sync_view_margins()
	if not _camera_ready and board.view_top > 0.0:
		_camera_ready = true
		board.refresh_camera()


## Informa ao tabuleiro quanto de tela a HUD ocupa no topo/rodapé, para a
## câmera manter o jogador na faixa livre entre os paineis.
func _sync_view_margins() -> void:
	if board == null or hud == null:
		return
	board.view_top = hud.top_margin()
	board.view_bottom = hud.bottom_margin()


func _refresh_hud() -> void:
	hud.set_sequence(board.current_sequence(), board.current_step())
	hud.set_next_special(board.get_next_special(), board.get_next_special_symbol())


func _on_won() -> void:
	GameState.mark_completed(int(_level.get("id", 1)))
	hud.show_win()


func _on_undo() -> void:
	hud.hide_win()
	board.undo_move()
	_refresh_hud()


func _on_restart() -> void:
	hud.hide_win()
	board.restart()
	_refresh_hud()


func _on_next() -> void:
	# A trilha de fases e SEMPRE exibida entre uma fase e outra.
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
