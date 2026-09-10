extends Control

@export var ID = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ID < 0 or typeof(ID) != TYPE_INT: push_error("ID is not valid")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
