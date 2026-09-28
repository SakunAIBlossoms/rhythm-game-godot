extends ColorRect

@export var ShaderParameter:StringName = "None"

func UpdateShader(duration:float, usestart:bool, startvalue:Variant, endvalue:Variant, easing:int) -> Tween:
	var twn = create_tween()
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	var truestartval = startvalue if usestart else get_material().get_shader_parameter(ShaderParameter)
	twn.tween_method(_internal_shader_value_update, truestartval, endvalue, duration)
	twn.play()
	
	return twn

func _internal_shader_value_update(value:Variant) -> void:
	get_material().set_shader_parameter(ShaderParameter, value)
