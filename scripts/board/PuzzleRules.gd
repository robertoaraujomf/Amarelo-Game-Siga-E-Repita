class_name PuzzleRules
extends RefCounted
## Motor de regras do puzzle: sequencias, visitas e condicao de vitoria.

var matrix: LevelMatrix
var sequences: Array = []
var active_sequence: int = 0
var step: int = 0
var visited: Dictionary = {}    # Vector2i -> true


func _init(p_matrix: LevelMatrix, p_sequences: Array) -> void:
	matrix = p_matrix

	var clean: Array = []
	for seq in p_sequences:
		var s: Array = []
		for item in seq:
			s.append(str(item))
		if s.size() > 0:
			clean.append(s)
	if clean.is_empty():
		clean = [["1"]]
	sequences = clean

	visited[matrix.start_pos] = true


func current_sequence() -> Array:
	return sequences[active_sequence]


func next_symbol() -> String:
	var seq: Array = current_sequence()
	if seq.is_empty():
		return ""
	return str(seq[step % seq.size()])


## O jogador so avanca para celula adjacente cujo simbolo casa com a sequencia.
func can_move(from: Vector2i, to: Vector2i) -> bool:
	if not matrix.is_inside(to):
		return false
	var sym := matrix.symbol_at(to)
	if LevelMatrix.is_empty(sym):
		return false
	if LevelMatrix.is_end(sym):
		return all_visited()
	if LevelMatrix.is_special(sym):
		return true
	if LevelMatrix.is_start(sym):
		return true
	return sym == next_symbol()


func register_arrival(to: Vector2i) -> void:
	var sym := matrix.symbol_at(to)
	visited[to] = true

	if LevelMatrix.is_end(sym):
		return
	if LevelMatrix.is_special(sym):
		# Alterna para o proximo conjunto de regras.
		active_sequence = (active_sequence + 1) % sequences.size()
		step = 0
		return
	if LevelMatrix.is_start(sym):
		return
	if sym == next_symbol():
		step += 1


## Todas as posicoes obrigatorias (validas, exceto o Fim) ja visitadas?
func all_visited() -> bool:
	for p in matrix.required_positions():
		if not visited.has(p):
			return false
	return true


func is_won(at: Vector2i) -> bool:
	return at == matrix.end_pos and all_visited()
