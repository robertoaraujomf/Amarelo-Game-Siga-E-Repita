class_name LevelMatrix
extends RefCounted
## Le e interpreta a matriz alfanumerica de uma fase.
##
## Cada linha pode ser escrita como tokens separados por espaço (permite
## tokens de mais de um caractere, ex.: "10", "K", "P") OU como caracteres
## colados (ex.: "XXX43XXXX"). As quebras de linha definem as linhas.

const EMPTY := "."
const START := "A"
const END_PRIMARY := "B"      # marcador de fim padrao (Fase 1 usa "B")
const END_ALT := "F"          # "F" tambem e aceito como fim (spec original)
const SPECIAL := "E"
const START_MARK := "&"       # marcador alternativo de Início (posição inicial)
const END_MARK := "§"         # marcador alternativo de Fim (posição final)

var rows: int = 0
var cols: int = 0
var cells: Array = []           # Array de Array[String] (tokens)
var start_pos := Vector2i.ZERO
var end_pos := Vector2i(-1, -1)
var special_positions: Array[Vector2i] = []


func _init(raw: Array) -> void:
	# "br" funciona como quebra de linha entre as linhas do mapa.
	var token_rows: Array = []
	for row in raw:
		var row_str := str(row).strip_edges()
		var toks: Array = []
		if row_str.contains(" "):
			for t in row_str.split(" ", false):
				toks.append(str(t))
		else:
			for ch in row_str:
				toks.append(ch)
		var cur: Array = []
		for t in toks:
			var tt: String = str(t)
			if tt == "br":
				if not cur.is_empty():
					token_rows.append(cur)
					cur = []
				continue
			cur.append(tt)
		if not cur.is_empty():
			token_rows.append(cur)

	rows = maxi(token_rows.size(), 1)
	var width := 0
	for toks in token_rows:
		width = maxi(width, int(toks.size()))
	cols = maxi(width, 1)

	# Segunda passada: monta a grade e localiza os marcadores.
	var found_start := false
	var y := 0
	for toks in token_rows:
		var line: Array = []
		for x in cols:
			var tok := EMPTY
			if x < toks.size():
				tok = str(toks[x])
			line.append(tok)
			var p := Vector2i(x, y)
			if is_start(tok):
				start_pos = p
				found_start = true
			elif is_end(tok):
				end_pos = p
			elif is_special(tok):
				special_positions.append(p)
		cells.append(line)
		y += 1

	if not found_start:
		push_warning("Fase sem posição inicial 'A'; usando (0,0).")
	if end_pos == Vector2i(-1, -1):
		push_warning("Fase sem posição final 'B'.")


static func is_empty(s: String) -> bool:
	return s == "." or s == "X" or s == "x"


static func is_start(s: String) -> bool:
	return s == START or s == START_MARK


static func is_end(s: String) -> bool:
	return s == END_MARK or s == END_ALT


static func is_special(s: String) -> bool:
	return s == "E"


func is_inside(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < cols and p.y < rows


func symbol_at(p: Vector2i) -> String:
	if is_inside(p):
		return str(cells[p.y][p.x])
	return EMPTY


func is_valid(p: Vector2i) -> bool:
	return is_inside(p) and not is_empty(symbol_at(p))


## Todas as posições do retângulo.
func all_positions() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in rows:
		for x in cols:
			out.append(Vector2i(x, y))
	return out


## Posições válidas para o jogador pisar.
func valid_positions() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in all_positions():
		if is_valid(p):
			out.append(p)
	return out


## Posições obrigatórias: todas as válidas, exceto o Fim.
func required_positions() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in valid_positions():
		if p != end_pos:
			out.append(p)
	return out


## Vizinhos ortogonais (4 direcoes), sem diagonais.
func neighbors(p: Vector2i) -> Array[Vector2i]:
	var dirs := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	var out: Array[Vector2i] = []
	for d in dirs:
		var n: Vector2i = p + d
		if is_inside(n):
			out.append(n)
	return out
