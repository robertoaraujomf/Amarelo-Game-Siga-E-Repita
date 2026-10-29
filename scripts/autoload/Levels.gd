extends Node
## Autoload "Levels" - carrega e expoe as fases (arquivos JSON em res://levels).

const LEVELS_DIR := "res://levels"

var levels: Array[Dictionary] = []


func _ready() -> void:
	_load_levels()


func _load_levels() -> void:
	levels.clear()
	var dir := DirAccess.open(LEVELS_DIR)
	if dir == null:
		push_warning("Pasta de níveis não encontrada: %s" % LEVELS_DIR)
		return

	var files: Array[String] = []
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.ends_with(".json"):
			files.append(f)
		f = dir.get_next()
	dir.list_dir_end()
	files.sort()

	for file in files:
		var path := "%s/%s" % [LEVELS_DIR, file]
		var text := FileAccess.get_file_as_string(path)
		var parsed: Variant = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("matrix"):
			levels.append(parsed)
		else:
			push_warning("Nivel invalido/ignorado: %s" % path)


func count() -> int:
	return levels.size()


func get_level_by_index(index: int) -> Dictionary:
	if index < 0 or index >= levels.size():
		return {}
	return levels[index]


func get_level_by_id(id: int) -> Dictionary:
	for lvl in levels:
		if int(lvl.get("id", -1)) == id:
			return lvl
	return {}


func index_of_id(id: int) -> int:
	for i in levels.size():
		if int(levels[i].get("id", -1)) == id:
			return i
	return -1
