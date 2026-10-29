extends SceneTree

func _init() -> void:
	var names: Array = []
	for p in Control.new().get_property_list():
		names.append(str(p["name"]))
	print("HAS_MATERIAL=", "material" in names)
	print("HAS_DRAW_TEXTURE=", Control.new().has_method("draw_texture"))
	quit()
