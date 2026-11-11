class_name PuzzleRules
extends RefCounted
## Motor de regras: sequências (tokens livres), visitas e vitória.
##
## Regras:
##  - So avança para célula adjacente cujo token seja o próximo da sequência.
##  - A sequência e cíclica e tem no mínimo 4 elementos (recomendado).
##  - Posição especial "E": so pode ser usada DEPOIS de usar o ÚLTIMO item da
##    sequência atual; ao entrar nela, ativa a próxima sequência (transição).
##  - Vence ao visitar todas as posições válidas (exceto o Fim) e entrar no Fim.

const MIN_SEQUENCE_LEN := 4

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
			if s.size() < MIN_SEQUENCE_LEN:
				push_warning("Sequência com menos de %d elementos: %s"
						% [MIN_SEQUENCE_LEN, str(s)])
			clean.append(s)
	if clean.is_empty():
		clean = [["1", "2", "3", "4"]]
	sequences = clean

	visited[matrix.start_pos] = true


func current_sequence() -> Array:
	return sequences[active_sequence]


func next_symbol() -> String:
	var seq: Array = current_sequence()
	if seq.is_empty():
		return ""
	return str(seq[step % seq.size()])


## A sequência atual ja foi concluída (usou o último item) e pode transicionar?
func sequence_completed() -> bool:
	var seq: Array = current_sequence()
	if seq.is_empty():
		return false
	return step > 0 and step % seq.size() == 0


## O jogador so avança para célula adjacente cujo token casa com a sequência.
func can_move(from: Vector2i, to: Vector2i) -> bool:
	if not matrix.is_inside(to):
		return false
	var sym := matrix.symbol_at(to)
	if LevelMatrix.is_empty(sym):
		return false
	if LevelMatrix.is_end(sym):
		return all_visited()
	if LevelMatrix.is_special(sym):
		# Exige ter usado o último item da sequência antes de transicionar.
		return sequence_completed()
	if LevelMatrix.is_start(sym):
		# A posição inicial só pode ser a partida; não pode ser revisitada.
		return false
	return sym == next_symbol()


func register_arrival(to: Vector2i) -> void:
	var sym := matrix.symbol_at(to)
	visited[to] = true

	if LevelMatrix.is_end(sym):
		return
	if LevelMatrix.is_special(sym):
		active_sequence = (active_sequence + 1) % sequences.size()
		step = 0
		return
	if LevelMatrix.is_start(sym):
		return
	if sym == next_symbol():
		step += 1


## Todas as posições obrigatórias (válidas, exceto o Fim) ja visitadas?
func all_visited() -> bool:
	for p in matrix.required_positions():
		if not visited.has(p):
			return false
	return true


func is_won(at: Vector2i) -> bool:
	return at == matrix.end_pos and all_visited()
