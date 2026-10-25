extends Control

var hovered = false
var rotationsine = 0.0;

func Setup(text:String, icon:String) -> Error:
    if (text == null or icon == null): return Error.ERR_BUG
    $Icon.texture = icon
    $Label.text = text
    return Error.OK

func _process(delta: float):
    rotationsine = lerp(rotationsine, 0.03 if hovered else 0.0, 12*delta)
    self.offset_transform_rotation = sin(deg_to_rad(Time.get_ticks_msec() * 0.16)) * rotationsine

func _on_mouse_entered(): hovered = true
func _on_mouse_exited(): hovered = false
