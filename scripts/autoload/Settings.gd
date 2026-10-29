extends Node
## Autoload "Settings" - preferências do jogador (método de controle, etc).

enum ControlMode { SWIPE, ARROWS }

const CONFIG_PATH := "user://settings.cfg"

var control_mode: int = ControlMode.SWIPE
var haptics_enabled: bool = true
var music_enabled: bool = true


func _ready() -> void:
	_register_input_actions()
	load_settings()


## Cria as ações de input programaticamente (setas + WASD) para não depender
## de serialização no project.godot.
func _register_input_actions() -> void:
	var map := {
		"move_up": [KEY_UP, KEY_W],
		"move_down": [KEY_DOWN, KEY_S],
		"move_left": [KEY_LEFT, KEY_A],
		"move_right": [KEY_RIGHT, KEY_D],
	}
	for action in map.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in map[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)


func set_control_mode(mode: int) -> void:
	control_mode = mode
	save_settings()


func toggle_haptics() -> void:
	haptics_enabled = not haptics_enabled
	save_settings()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) == OK:
		control_mode = int(cfg.get_value("input", "control_mode", ControlMode.SWIPE))
		haptics_enabled = bool(cfg.get_value("feedback", "haptics", true))
		music_enabled = bool(cfg.get_value("audio", "music", true))


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("input", "control_mode", control_mode)
	cfg.set_value("feedback", "haptics", haptics_enabled)
	cfg.set_value("audio", "music", music_enabled)
	cfg.save(CONFIG_PATH)
