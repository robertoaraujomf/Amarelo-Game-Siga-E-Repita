class_name OrganicButton
extends Button
## Botao com fundo em GRADIENTE (nunca cor solida) e formato organico (blob).

var _bg := Color(0.42, 0.16, 0.64)


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var w := int(size.x)
	var h := int(size.y)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var light := _bg.lightened(0.30)
	for y in range(h):
		img.set_pixel(int((size.x - 1) * float(y) / maxf(1.0, float(h - 1.0))), y, _bg.lerp(light, float(y) / maxf(1.0, float(h - 1.0))))
	var tex := ImageTexture.create_from_image(img)
	draw_texture(tex, Vector2.ZERO, Color(1, 1, 1, 1))

	# Texto do botao por cima do gradiente.
	var font: Font = get_theme_font("font")
	var fs: float = float(get_theme_font_size("font_size"))
	var txt := str(text)
	var sz := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	draw_string(font, Vector2(size.x / 2.0 - sz.x / 2.0, size.y / 2.0 - fs * 0.36), txt,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 1, 1, 1))


func _notification(what: int) -> void:
	if what == NOTIFICATION_DISABLED or what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_RESIZED:
		queue_redraw()


func set_bg(c: Color) -> void:
	_bg = c
	queue_redraw()
