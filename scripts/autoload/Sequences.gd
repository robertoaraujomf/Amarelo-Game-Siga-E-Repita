extends Node
## Autoload "Sequences" - sequências canônicas de figuras usadas nas fases.
## Cada entrada é um conjunto de 4 figuras (a ordem de jogo é definida pela fase).

const SEQUENCIAS: Array = [
	["arvore", "aviao", "balao", "bicicleta"],
	["bombom", "carro", "castelo", "coracao"],
	["elefante", "escada", "flauta", "livro"],
	["macaco", "melancia", "morango", "passarinho"],
	["peixe", "piano", "tenis", "tigre"],
]


func sequencia_da_fase(phase_number: int) -> Array:
	# Fases 1..5 usam sequencias 0..4; depois reinicia (6->0, 7->1, ...).
	if SEQUENCIAS.is_empty():
		return []
	var idx := (phase_number - 1) % SEQUENCIAS.size()
	return SEQUENCIAS[idx]