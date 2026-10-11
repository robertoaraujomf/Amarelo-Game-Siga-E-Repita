class_name StyleFactory
extends RefCounted
## Fabrica de estilos "organicos" (bordas muito arredondadas, sombras suaves).
## Centraliza a direcao de arte: nada de cantos secos ou linhas retas.

const COLORS := {
	"1": Color("ff6b6b"),
	"2": Color("ffd93d"),
	"3": Color("6bcb77"),
	"4": Color("4d96ff"),
	"E": Color("b983ff"),
	"A": Color("2ec4b6"),
	"B": Color("ff5da2"),
	"F": Color("ff5da2"),
	"empty": Color("3b2f52"),
}

const BG_TOP := Color("5b2a86")
const BG_BOTTOM := Color("ff8fab")
const TRAIL := Color("8a2be2")
const HIGHLIGHT := Color("ffe24d")
const INK := Color("2b1a3d")
const CARD := Color(1, 1, 1, 0.16)


static func color_for(symbol: String) -> Color:
	var c: Color = COLORS.get(symbol, Color("7f8fa6"))
	return c


## Painel com cantos igualmente arredondados (mas bem suaves).
static func rounded_panel(color: Color, radius: int = 40) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.corner_detail = 14
	sb.anti_aliasing = true
	return sb


## Painel "organico": cada canto com raio diferente + sombra suave.
static func organic_panel(color: Color, radius: int = 48) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = int(radius * 0.7)
	sb.corner_radius_bottom_right = radius
	sb.corner_radius_bottom_left = int(radius * 0.85)
	sb.corner_detail = 18
	sb.anti_aliasing = true
	sb.shadow_color = Color(0, 0, 0, 0.22)
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
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.5))
	b.add_theme_stylebox_override("normal", rounded_panel(color, 40))
	b.add_theme_stylebox_override("hover", rounded_panel(color.lightened(0.10), 40))
	b.add_theme_stylebox_override("pressed", rounded_panel(color.darkened(0.12), 40))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("disabled", rounded_panel(color.darkened(0.35), 40))
	return b
