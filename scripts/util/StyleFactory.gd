class_name StyleFactory
extends RefCounted
## Fabrica de estilos "orgânicos" (bordas muito arredondadas, sombras suaves).
## Direcao de arte: nada de cantos secos, linhas retas nem fundos brancos,
## pretos ou cinzas - apenas cores vivas.

const COLORS := {
	"1": Color("ff6b6b"),
	"2": Color("ffd93d"),
	"3": Color("6bcb77"),
	"4": Color("4d96ff"),
	"E": Color("b983ff"),
	"A": Color("2ec4b6"),
	"B": Color("ff5da2"),
	"F": Color("ff5da2"),
}

const BG_TOP := Color("5b2a86")
const BG_BOTTOM := Color("ff8fab")
const TRAIL := Color("8a2be2")
const HIGHLIGHT := Color("ffe24d")

# Cores de UI (todas coloridas - sem branco/preto/cinza).
const CARD := Color("5a2aa6", 0.50)          # painel violeta translucido
const OVERLAY_DIM := Color("3a1c5a", 0.74)   # escurecimento violeta (não preto)
const WIN_PANEL := Color("7c5cff")           # painel de vitória
const SHADOW := Color("2a0f4a", 0.32)        # sombra violeta (não preta)
const HINT := Color("7c5cff", 0.38)          # caixa de dica


## Cor de um símbolo/token. Aceita tokens arbitrarios ("10", "K", "P"...).
static func color_for(symbol: String) -> Color:
	if COLORS.has(symbol):
		var c: Color = COLORS[symbol]
		return c
	return _hash_color(symbol)


static func _hash_color(s: String) -> Color:
	var h := 0
	for i in s.length():
		h = (h * 131 + s.unicode_at(i)) % 360
	return Color.from_hsv(float(h) / 360.0, 0.62, 0.95)


## Painel com cantos igualmente arredondados (mas bem suaves).
static func rounded_panel(color: Color, radius: int = 40) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.corner_detail = 14
	sb.anti_aliasing = true
	return sb


## Painel "orgânico": cada canto com raio diferente + sombra colorida.
static func organic_panel(color: Color, radius: int = 48) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = int(radius * 0.7)
	sb.corner_radius_bottom_right = radius
	sb.corner_radius_bottom_left = int(radius * 0.85)
	sb.corner_detail = 18
	sb.anti_aliasing = true
	sb.shadow_color = SHADOW
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 6)
	return sb


## Botao padrao do jogo (arredondado, colorido, estilo infantil).
static func make_button(text: String, color: Color, font_size: int = 34) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 80)
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.55))
	b.add_theme_stylebox_override("normal", rounded_panel(color, 40))
	b.add_theme_stylebox_override("hover", rounded_panel(color.lightened(0.10), 40))
	b.add_theme_stylebox_override("pressed", rounded_panel(color.darkened(0.12), 40))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("disabled", rounded_panel(color.darkened(0.30), 40))
	return b
