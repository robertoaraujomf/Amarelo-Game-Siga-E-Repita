extends Node
## Autoload "GameState" - progresso do jogador e fase atual.

const PROGRESS_PATH := "user://progress.cfg"

var current_level_id: int = 1
var completed: Dictionary = {}  # level_id (int) -> true


func _ready() -> void:
	load_progress()


func start_level(id: int) -> void:
	current_level_id = id
	save_progress()


func mark_completed(id: int) -> void:
	if not completed.has(id):
		completed[id] = true
		save_progress()


func is_completed(id: int) -> bool:
	return completed.has(id)


func is_unlocked(id: int) -> bool:
	if id <= 1:
		return true
	return completed.has(id - 1)


func level_status(id: int) -> String:
	if is_completed(id):
		return "completed"
	if not is_unlocked(id):
		return "locked"
	if id == current_level_id:
		return "current"
	return "open"


func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "current_level_id", current_level_id)
	cfg.set_value("progress", "completed", completed)
	cfg.save(PROGRESS_PATH)


func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PROGRESS_PATH) == OK:
		current_level_id = int(cfg.get_value("progress", "current_level_id", 1))
		var c: Variant = cfg.get_value("progress", "completed", {})
		if typeof(c) == TYPE_DICTIONARY:
			completed = c
