extends Control

var hovered = false
var rotationsine = 0.0;

func Setup(text:String, icon:String) -> Error:
	if (text == null or icon == null): return Error.ERR_BUG
	$Icon.texture = load(icon)
	$Label.text = text
	return Error.OK

func _process(delta: float):
	if hovered: offset_transform_scale = Vector2(lerp(offset_transform_scale.x, 1.05, 12*delta), lerp(offset_transform_scale.y, 0.95, 12*delta))
	else: offset_transform_scale = Vector2(lerp(offset_transform_scale.x, 1.0, 12*delta), lerp(offset_transform_scale.y, 1.0, 12*delta))

func _on_mouse_entered(): hovered = true
func _on_mouse_exited(): hovered = false
