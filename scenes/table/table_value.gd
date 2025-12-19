class_name TableValue
extends HBoxContainer

@export var is_header: bool = false

func set_value(value) -> void:
	if is_header:
		$Label.set("theme_override_font_sizes/font_size", 18)
		$Label.set("theme_override_colors/font_color", Color.WHITE)
	
	if not (value is int or value is float):
		print("Not a number, type: ", type_string(typeof(value)))
		return
	
	if value is int or (value is float and fmod(value, 1.0) == 0.0):
		$Label.text = "%.0f" % value
	else:
		$Label.text = "%.2f" % value
