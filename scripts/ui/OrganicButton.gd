class_name OrganicButton
extends Button
## Botao com fundo em GRADIENTE (shader com gradiente vertical, nunca cor solida).

var _bg := Color(0.42, 0.16, 0.64)
var _mat: ShaderMaterial


func _ready() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = Shader.new()
	var c := _bg
	var light := c.lightened(0.30)
	mat.shader.code = "shader_type canvas_item;\nuniform vec4 top_c = vec4(%.4f, %.4f, %.4f, 1.0);\nuniform vec4 bot_c = vec4(%.4f, %.4f, %.4f, 1.0);\nvoid fragment() { COLOR = mix(top_c, bot_c, UV.y); }" % [c.r, c.g, c.b, light.r, light.g, light.b]
	_mat = mat
	self.material = mat


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	# Fundo via material (shader com gradiente); aqui desenhamos o texto.
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
	var mat := ShaderMaterial.new()
	mat.shader = Shader.new()
	var light := c.lightened(0.30)
	mat.shader.code = "shader_type canvas_item;\nuniform vec4 top_c = vec4(%.4f, %.4f, %.4f, 1.0);\nuniform vec4 bot_c = vec4(%.4f, %.4f, %.4f, 1.0);\nvoid fragment() { COLOR = mix(top_c, bot_c, UV.y); }" % [c.r, c.g, c.b, light.r, light.g, light.b]
	_mat = mat
	self.material = mat
	queue_redraw()
