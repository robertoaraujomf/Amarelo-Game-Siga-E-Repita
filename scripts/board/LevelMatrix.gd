class_name LevelMatrix
extends RefCounted
## Le e interpreta a matriz alfanumerica de uma fase.

const EMPTY := "."
const START := "A"
const END := "F"        # aceitamos tambem "B" (ver is_end)
const SPECIAL := "E"
const DIGITS: Array[String] = ["1", "2", "3", "4"]

var rows: int = 0
var cols: int = 0
var cells: Array = []           # Array de Array[String]
var start_pos := Vector2i.ZERO
var end_pos := Vector2i(-1, -1)
var special_positions: Array[Vector2i] = []


func _init(raw: Array) -> void:
	rows = raw.size()
	var width := 0
	for r in raw:
		width = maxi(width, str(r).length())
	cols = maxi(width, 1)

	var found_start := false
	for y in rows:
		var row_str := str(raw[y])
		var line: Array = []
		for x in cols:
			var ch := EMPTY
			if x < row_str.length():
				ch = row_str[x]
			line.append(ch)
			var p := Vector2i(x, y)
			if is_start(ch):
				start_pos = p
				found_start = true
			elif is_end(ch):
				end_pos = p
			elif is_special(ch):
				special_positions.append(p)
		cells.append(line)

	if not found_start:
		push_warning("Fase sem posicao inicial 'A'; usando (0,0).")
	if end_pos == Vector2i(-1, -1):
		push_warning("Fase sem posicao final 'B'/'F'.")


static func is_empty(s: String) -> bool:
	return s == "." or s == "X" or s == "x"


static func is_start(s: String) -> bool:
	return s == "A"


static func is_end(s: String) -> bool:
	return s == "F" or s == "B"


static func is_special(s: String) -> bool:
	return s == "E"


static func is_digit(s: String) -> bool:
	return DIGITS.has(s)


func is_inside(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < cols and p.y < rows


func symbol_at(p: Vector2i) -> String:
	if is_inside(p):
		return str(cells[p.y][p.x])
	return EMPTY


func is_valid(p: Vector2i) -> bool:
	return is_inside(p) and not is_empty(symbol_at(p))


## Todas as posicoes do retangulo.
func all_positions() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in rows:
		for x in cols:
			out.append(Vector2i(x, y))
	return out


## Posicoes validas para o jogador pisar.
func valid_positions() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in all_positions():
		if is_valid(p):
			out.append(p)
	return out


## Posicoes obrigatorias: todas as validas, exceto o Fim.
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
