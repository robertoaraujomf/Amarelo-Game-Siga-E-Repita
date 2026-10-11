extends Node2D
## Cena de jogo: liga o Board (tabuleiro) ao HUD e gerencia o fluxo da fase.

@onready var board: Board = $Board
@onready var hud: Hud = $HUD

var _level: Dictionary = {}


func _ready() -> void:
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

	board.state_changed.connect(_refresh_hud)
	board.sequence_changed.connect(_refresh_hud)
	board.blocked.connect(hud.pop_blocked)
	board.won.connect(_on_won)

	board.load_level(_level)

	var idx := Levels.index_of_id(int(_level.get("id", 1)))
	hud.set_level_info(str(_level.get("name", "Fase")), idx + 1, Levels.count())
	hud.set_control_mode(Settings.control_mode)
	_refresh_hud()


func _refresh_hud() -> void:
	hud.set_sequence(board.current_sequence(), board.current_step())
	hud.set_next_special(board.get_next_special())


func _on_won() -> void:
	GameState.mark_completed(int(_level.get("id", 1)))
	hud.show_win()


func _on_next() -> void:
	var next_id := int(_level.get("id", 1)) + 1
	if Levels.get_level_by_id(next_id).is_empty():
		get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
	else:
		GameState.start_level(next_id)
		get_tree().reload_current_scene()


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
