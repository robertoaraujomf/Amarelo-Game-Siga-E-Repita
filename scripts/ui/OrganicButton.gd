class_name OrganicButton
extends Button
## Botao com fundo colorido, cantos organicos (blob) e texto do proprio Button.

var _bg := Color(0.42, 0.16, 0.64)


func _ready() -> void:
	_apply_style()


func _apply_style() -> void:
	add_theme_stylebox_override("normal", StyleFactory.organic_panel(_bg))
	add_theme_stylebox_override("hover", StyleFactory.organic_panel(_bg.lightened(0.12)))
	add_theme_stylebox_override("pressed", StyleFactory.organic_panel(_bg.darkened(0.12)))
	add_theme_stylebox_override("focus", StyleFactory.organic_panel(_bg))
	add_theme_stylebox_override("disabled", StyleFactory.organic_panel(_bg.darkened(0.25)))


func set_bg(c: Color) -> void:
	_bg = c
	if is_inside_tree():
		_apply_style()
