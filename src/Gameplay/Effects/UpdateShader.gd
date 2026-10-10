extends ColorRect

@export var ShaderParameter1:StringName = ""
@export var ShaderParameter2:StringName = ""
@export var ShaderParameter3:StringName = ""

func UpdateShader(duration:float, usestart:bool, startvalue:Variant, endvalue:Variant, easing:int) -> Tween:
	var twn = create_tween().set_parallel(true)
	twn.set_ease(Utils.GetfluXisEasing(easing))
	twn.set_trans(Utils.GetfluXisTrans(easing))
	
	var catch = Vector3(
		get_material().get_shader_parameter(ShaderParameter1) if ShaderParameter1 != "" else 0.0,
		get_material().get_shader_parameter(ShaderParameter2) if ShaderParameter2 != "" else 0.0,
		get_material().get_shader_parameter(ShaderParameter3) if ShaderParameter3 != "" else 0.0
		)
	
	var truestartval = startvalue if usestart else catch
	twn.tween_method(_internal_shader_value_update, truestartval, endvalue, duration)
	twn.play()
	
	return twn

func _internal_shader_value_update(value:Variant) -> void:
	if value.x == 0.0: self.visible = false
	else: self.visible = true
	
	if ShaderParameter1 != "": get_material().set_shader_parameter(ShaderParameter1, value.x)
	if ShaderParameter2 != "": get_material().set_shader_parameter(ShaderParameter2, value.y)
	if ShaderParameter3 != "": get_material().set_shader_parameter(ShaderParameter3, value.z)
	
	if self.name == "SplitScreen":
		get_material().set_shader_parameter("SplitInv", Vector2(1.0/float(get_material().get_shader_parameter(ShaderParameter2)), 1.0/float(get_material().get_shader_parameter(ShaderParameter3))))
