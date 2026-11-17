extends Node
## Autoload "Sequences" - sequências canônicas de figuras usadas nas fases.
## Cada entrada é um conjunto de figuras (a ordem de jogo é definida pela fase).

const TODAS_FIGURAS: Array = [
	"arvore", "aviao", "balao", "bicicleta",
	"bombom", "carro", "castelo", "coracao",
	"elefante", "escada", "flauta", "livro",
	"macaco", "melancia", "morango", "passarinho",
	"peixe", "piano", "tenis", "tigre",
]

const SEQUENCIAS: Array = [
	["arvore", "aviao", "balao", "bicicleta"],
	["bombom", "carro", "castelo", "coracao"],
	["elefante", "escada", "flauta", "livro"],
	["macaco", "melancia", "morango", "passarinho"],
	["peixe", "piano", "tenis", "tigre"],
]


## Quantidade de figuras por sequência é sempre 4 (sem aumento por faixa de fases).
func quantidade_figuras(phase_number: int) -> int:
	return 4


func sequencia_da_fase(phase_number: int) -> Array:
	# Fases 1..5 usam sequencias 0..4; depois reinicia (6->0, 7->1, ...).
	if SEQUENCIAS.is_empty():
		return []
	var idx := (maxi(phase_number, 1) - 1) % SEQUENCIAS.size()
	return SEQUENCIAS[idx].duplicate()
