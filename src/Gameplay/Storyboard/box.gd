extends Panel

@export var corner := 0.0
@export var using_blend := false
## This does not work lmao
@export_enum("None", "Mix", "Add", "Subtract", "Screen", "Multiply", "Difference") var blend_mode := 0
@export var Width := 0.0
@export var Height := 0.0
